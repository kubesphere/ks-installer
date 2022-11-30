#!/usr/bin/env bash

TMP_DIR=/tmp/migrate-alertrules
JQ_SCRIPT=$TMP_DIR/migrate.jq
if [ -e "$TMP_DIR" ]; then
  rm -rf $TMP_DIR
fi
mkdir $TMP_DIR

# prepare jq script
cat > $JQ_SCRIPT <<\EOF
# migrateRule migrates one rule to one RuleGroup or ClusterRuleGroup by the rule level
def migrateRule($namespace; $ruleLevel): 
	({
    "node:node_cpu_utilisation:avg1m": {type: "cpu", name: "utilization", factor: 0.01},
	  "node:load1:ratio": {type: "cpu", name: "load1m", factor: 1},
	  "node:load5:ratio": {type: "cpu", name: "load5m", factor: 1},
	  "node:load15:ratio": {type: "cpu", name: "load15m", factor: 1},
	  "node:node_memory_utilisation:": {type: "memory", name: "utilization", factor: 0.01},
	  "node:node_memory_bytes_available:sum": {type: "memory", name: "available", factor: (1024*1024*1024)},
	  "node:node_net_bytes_transmitted:sum_irate": {type: "netowrk", name: "transmittedRate", factor: (1000*1000)},
	  "node:node_net_bytes_received:sum_irate": {type: "network", name: "receivedRate", factor: (1000*1000)},
	  "node:disk_space_utilization:ratio": {type: "disk", name: "spaceUtilization", factor: 0.01},
	  "node:disk_space_available:": {type: "disk", name: "spaceAvailable", factor: (1000*1000*1000)},
	  "node:disk_inode_utilization:ratio": {type: "disk", name: "inodeUtilization", factor: 0.01},
	  "node:data_volume_iops_reads:sum": {type: "disk", name: "iopsRead", factor: 1},
	  "node:data_volume_iops_writes:sum": {type: "disk", name: "iopsWrite", factor: 1},
	  "node:data_volume_throughput_bytes_read:sum": {type: "disk", name: "throughputRead", factor: 1000},
	  "node:data_volume_throughput_bytes_write:sum": {type: "disk", name: "throughputWrite", factor: 1000},
	  "node:pod_utilization:ratio": {type: "pod", name: "utilization", factor: 0.01},
	  "node:pod_abnormal:ratio": {type: "pod", name: "abnormalRatio", factor: 0.01}
  } +
  {
    "namespace:workload_cpu_usage:sum": {type: "cpu", name: "usage", factor: 1},
	  "namespace:workload_memory_usage:sum": {type: "memory", name: "usage", factor: (1024*1024)},
	  "namespace:workload_memory_usage_wo_cache:sum": {type: "memory", name: "usageWoCache", factor: (1024*1024)},
	  "namespace:workload_net_bytes_transmitted:sum_irate": {type: "network", name: "transmittedRate", factor: (1000*1000)},
	  "namespace:workload_net_bytes_received:sum_irate": {type: "network", name: "receivedRate", factor: (1000*1000)},
	  "namespace:$2_unavailable_replicas:ratio": {type: "replica", name: "unavailableRatio", factor: 0.01}
  }) as $metricsInfo
  | (. | getpath(["labels", "severity"])) as $severity
  | (. | getpath(["annotations", "kind"])) as $kind
  | (. | getpath(["annotations", "resources"])) as $resources
  | (. | getpath(["annotations", "aliasName"])) as $aliasName
  | (. | getpath(["annotations", "description"])) as $description
  | (if $resources != null then ($resources | fromjson) else null end) as $resourceNames
  | (. | getpath(["annotations", "rules"])) as $rules
  | (if $rules != null then ($rules | fromjson)[0] else null end) as $ruleInfo
  | ($ruleInfo | getpath(["condition_type"])) as $conditionType
  | ($ruleInfo | getpath(["thresholds"])) as $thresholds
  | ($ruleInfo | getpath(["unit"])) as $unit
  | ($ruleInfo | getpath(["_metricType"])) as $metricType
  | ($metricType | index("{")) as $index 
  | $metricType[0:$index] as $metric
  | (if $metric != null then $metricsInfo[$metric] else null end) as $metricInfo
  | . +
    (if $severity != null then {severity: $severity} else {} end) +
    (if $kind != null and $metricInfo != null and $conditionType != null and $thresholds != null and $unit != null then {
      exprBuilder: {
        (if $kind == "Node" then "node" else "workload" end): (({
          names: $resourceNames,
          comparator: $conditionType,
          metricThreshold: {
            ($metricInfo.type): {($metricInfo.name): (($thresholds | tonumber) * ($metricInfo.factor))}
          }
        }) + (if $kind != "Node" then {kind: $kind} else {} end))
      }
    } else {} end)
  | delpaths([["labels", "severity"], 
              ["labels", "alerttype"],
              ["labels", "rule_id"],
              ["annotations", "kind"], 
              ["annotations", "resources"], 
              ["annotations", "rules"],
              ["annotations", "rule_update_time"],
              ["annotations", "aliasName"],
              ["annotations", "description"]]) 
  | {
    kind: (if $ruleLevel == "cluster" then "ClusterRuleGroup" else "RuleGroup" end),
    apiVersion: "alerting.kubesphere.io/v2beta1",
    metadata: (({
      name: .alert,
      labels: {
        "alerting.kubesphere.io/enable": "true"
      },
      annotations: {
        "kubesphere.io/alias-name": ($aliasName + ""),
        "kubesphere.io/description": ($description + "")
      }
    }) + (if $ruleLevel == "namespace" then {namespace: $namespace} else {} end)),
    spec: {
      rules: [.]
    }
  };

# migrateRuleList migrates one PrometheusRuleList (generated only by alerting v2alpha1 apis) 
# to one RuleGroupList/ClusterRuleGroupList
def migrateRuleList:
  . 
  | 
    [.items[] 
      | (. | getpath(["metadata","namespace"])) as $namespace 
      | (. | getpath(["metadata", "labels", "custom-alerting-rule-level"])) as $ruleLevel
      | .spec.groups[].rules[]
      | migrateRule($namespace; $ruleLevel)] 
  | flatten 
  | {
    kind: "List",
    apiVersion: "v1",
    items: .
  };

. | migrateRuleList

EOF


LABEL_MIGRATED=migrated-to-alerting-v2beta1

# migrate rules in cluster level
CLUSTER_RULES_FILE=$TMP_DIR/cluster.json
kubectl -n kubesphere-monitoring-system get prometheusrules -l custom-alerting-rule-level=cluster,$LABEL_MIGRATED!=true -ojson | jq -f $JQ_SCRIPT > $CLUSTER_RULES_FILE
len=$(cat $CLUSTER_RULES_FILE | jq '.items | length')
if [ "$len" -gt 0 ] 
then 
  kubectl apply -f $CLUSTER_RULES_FILE && \
  kubectl -n kubesphere-monitoring-system label prometheusrules -l custom-alerting-rule-level=cluster,$LABEL_MIGRATED!=true $LABEL_MIGRATED=true --overwrite=true
fi


# migrate rules in namespace level
NAMESPACE_RULES_FILE=$TMP_DIR/namespace.json
for ns in $(kubectl get ns -o jsonpath="{.items[*].metadata.name}"); do 
  kubectl -n $ns get prometheusrules -l custom-alerting-rule-level=namespace,$LABEL_MIGRATED!=true -ojson | jq -f $JQ_SCRIPT > $NAMESPACE_RULES_FILE
  len=$(cat $NAMESPACE_RULES_FILE | jq '.items | length')
  if [ "$len" -gt 0 ] 
  then 
    kubectl apply -f $NAMESPACE_RULES_FILE && \
    kubectl -n $ns label prometheusrules -l custom-alerting-rule-level=namespace,$LABEL_MIGRATED!=true $LABEL_MIGRATED=true --overwrite=true
  fi
done
