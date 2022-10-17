# Configurable Parameters in KubeSphere


installer configuration, used when install a KubeSphere
```yaml
persistence:
  storageClass: ""
etcd:
  monitoring: false
  endpointIps: localhost
  port: 2379
  tlsEnable: true
common:
  mysqlVolumeSize: 20Gi
  minioVolumeSize: 20Gi
  etcdVolumeSize: 20Gi
  openldapVolumeSize: 2Gi
  redisVolumSize: 2Gi
  monitoring:
    endpoint: http://prometheus-operated.kubesphere-monitoring-system.svc:9090
console:
  enableMultiLogin: false  # enable/disable multi login
  port: 30880
alerting:
  enabled: false
auditing:
  enabled: false
devops:
  enabled: false             # Enable or disable the KubeSphere DevOps System.
  jenkinsMemoryLim: 4Gi      # Jenkins memory limit.
  jenkinsMemoryReq: 1500Mi   # Jenkins memory request.
  jenkinsVolumeSize: 8Gi     # Jenkins volume size.
events:
  enabled: false
logging:
  enabled: false
  containerruntime: docker
  elasticsearchMasterReplicas: 1
  elasticsearchDataReplicas: 1
  logsidecarReplicas: 2
  elasticsearchMasterVolumeSize: 4Gi
  elasticsearchDataVolumeSize: 20Gi
  logMaxAge: 7
  elkPrefix: logstash
metrics_server:
  enabled: true
monitoring:
  prometheusReplicas: 1
  prometheusMemoryRequest: 400Mi
  prometheusVolumeSize: 20Gi
  alertmanagerReplicas: 1
multicluster:
  # host: means installer will install current cluster as a Host Cluster. There should be only one HOST CLUSTER in KubeSphere multicluster.
  # member: means installer will install current cluster as a Member Cluster
  # none: means install current cluster as a standalone cluster
  clusterRole: none  # host | member | none
  # proxyPublishAddress: proxy public address for member clusters to use proxy connection with host cluster. It is the external address access to the tower service of host cluster.
  proxyPublishAddress: ""
networkpolicy:
  enabled: false
notification:
  enabled: false
openpitrix:
  enabled: false
servicemesh:
  enabled: false
```
