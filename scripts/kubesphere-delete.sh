#！/bin/bash

#helm delete
helms="elasticsearch-logging elasticsearch-logging-curator istio istio-init jaeger-operator ks-jenkins ks-sonarqube logging-fluentbit-operator metrics-server uc"

for id in `helm list|awk '{print $1}'|grep -v NAME`; do
     result=$(echo $helms | grep "$id")
     if [[ "$result" != "" ]]
     then
        helm delete --purge $id
     else
        echo "helm resource deleted"
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
        echo "namespace resource deleted"
     fi   
done

# pvc delete
pvcs="kubesphere-system openpitrix-system kubesphere-monitoring-system kubesphere-devops-system kubesphere-logging-system"
for pvcnamespace in `kubectl get pvc --all-namespaces|awk '{print $1}'|grep -v NAMESPACE`; do
     result=$(echo $pvcs | grep "$pvcnamespace")
     if [[ "$result" != "" ]]
     then
        kubectl delete pvc -n ${pvcnamespace} `kubectl get pvc -n ${pvcnamespace}|awk '{print $1}'|grep -v NAME`
     else
        echo "pvc resource deleted"
     fi   
done

