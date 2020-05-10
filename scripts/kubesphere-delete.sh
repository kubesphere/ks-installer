#！/bin/bash
# set -x: Print commands and their arguments as they are executed.
# set -e: Exit immediately if a command exits with a non-zero status.
set -xe
#delete ks-install 
kubectl delete deploy ks-installer -n kubesphere-system

#helm delete
helms="ks-minio ks-openldap\|ks-openpitrix\|ks-redis\|elasticsearch-logging\|elasticsearch-logging-curator\|istio\|istio-init\|jaeger-operator\|ks-jenkins\|ks-sonarqube\|logging-fluentbit-operator\|uc"
helm list | grep -o $helms | sort -u | xargs -r -L1 helm delete --purge

#namespace resource delete
namespaces="kubesphere-system\|openpitrix-system\|kubesphere-monitoring-system\|kubesphere-alerting-system\|kubesphere-controls-system"
kubectl get ns --no-headers=true -o custom-columns=:metadata.name | grep -o $namespaces | sort -u | xargs -r -L1 kubectl delete all --all -n

# pvc delete
pvcs="kubesphere-system\|openpitrix-system\|kubesphere-monitoring-system\|kubesphere-devops-system\|kubesphere-logging-system"
kubectl --no-headers=true get pvc --all-namespaces -o custom-columns=:metadata.namespace,:metadata.name | grep $pvcs | xargs | xargs -n2 sh -c 'kubectl delete pvc -n $1 $2' sh