#！/bin/bash

#helm delete
helms="elasticsearch-logging elasticsearch-logging-curator istio istio-init jaeger-operator ks-jenkins ks-sonarqube logging-fluentbit-operator metrics-server uc"

for id in `helm list|awk '{print $1}'|grep -v NAME`; do
     result=$(echo $helms | grep "$id")
     if [[ "$result" != "" ]]
     then
        helm delete --purge $id
     else
        echo "helm resource 已删除"
     fi   
done

#namespace resource delete
namespaces="kubesphere-system openpitrix-system kubesphere-monitoring-system kubesphere-alerting-system kubesphere-controls-system"

for namespace in `kubectl get namespaces|awk '{print $1}'|grep -v NAME`; do
     result=$(echo $namespaces | grep "$namespace")
     if [[ "$result" != "" ]]
     then
        kubectl delete all --all -n $namespace
     else
        echo "namespace resource 已删除"
     fi   
done

