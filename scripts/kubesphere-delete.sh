#!/usr/bin/env bash

function delete_sure(){
  cat << eof
$(echo -e "\033[1;36mNote:\033[0m")

Delete the KubeSphere cluster, including the module kubesphere-system kubesphere-devops-system kubesphere-devops-worker kubesphere-monitoring-system kubesphere-logging-system openpitrix-system.
eof

read -p "Please reconfirm that you want to delete the KubeSphere cluster.  (yes/no) " ans
while [[ "x"$ans != "xyes" && "x"$ans != "xno" ]]; do
    read -p "Please reconfirm that you want to delete the KubeSphere cluster.  (yes/no) " ans
done

if [[ "x"$ans == "xno" ]]; then
    exit
fi
}


delete_sure

# delete ks-installer
kubectl delete deploy ks-installer -n kubesphere-system 2>/dev/null

# delete helm
for namespaces in kubesphere-system kubesphere-devops-system kubesphere-monitoring-system kubesphere-logging-system openpitrix-system kubesphere-monitoring-federated dmp-system
do
  helm list -n $namespaces | grep -v NAME | awk '{print $1}' | sort -u | xargs -r -L1 helm uninstall -n $namespaces 2>/dev/null
done

# delete kubefed
kubectl get cc -n kubesphere-system ks-installer -o jsonpath="{.status.multicluster}" | grep enable
if [[ $? -eq 0 ]]; then
  helm uninstall -n kube-federation-system kubefed 2>/dev/null
  #kubectl delete ns kube-federation-system 2>/dev/null
fi


helm uninstall -n kube-system snapshot-controller 2>/dev/null

# delete kubesphere deployment & statefulset
kubectl delete deployment -n kubesphere-system `kubectl get deployment -n kubesphere-system -o jsonpath="{.items[*].metadata.name}"` 2>/dev/null
kubectl delete statefulset -n kubesphere-system `kubectl get statefulset -n kubesphere-system -o jsonpath="{.items[*].metadata.name}"` 2>/dev/null

# delete monitor resources
kubectl delete prometheus -n kubesphere-monitoring-system k8s 2>/dev/null
kubectl delete Alertmanager -n kubesphere-monitoring-system main 2>/dev/null
kubectl delete DaemonSet -n kubesphere-monitoring-system node-exporter 2>/dev/null
kubectl delete statefulset -n kubesphere-monitoring-system `kubectl get statefulset -n kubesphere-monitoring-system -o jsonpath="{.items[*].metadata.name}"` 2>/dev/null

# delete grafana
kubectl delete deployment -n kubesphere-monitoring-system grafana 2>/dev/null
kubectl --no-headers=true get pvc -n kubesphere-monitoring-system -o custom-columns=:metadata.namespace,:metadata.name | grep -E kubesphere-monitoring-system | xargs -n2 kubectl delete pvc -n 2>/dev/null

# delete pvc
pvcs="kubesphere-system|openpitrix-system|kubesphere-devops-system|kubesphere-logging-system"
kubectl --no-headers=true get pvc --all-namespaces -o custom-columns=:metadata.namespace,:metadata.name | grep -E $pvcs | xargs -n2 kubectl delete pvc -n 2>/dev/null


# delete rolebindings
delete_role_bindings() {
  for rolebinding in `kubectl -n $1 get rolebindings -l iam.kubesphere.io/user-ref -o jsonpath="{.items[*].metadata.name}"`
  do
    kubectl -n $1 delete rolebinding $rolebinding 2>/dev/null
  done
}

# delete roles
delete_roles() {
  kubectl -n $1 delete role admin 2>/dev/null
  kubectl -n $1 delete role operator 2>/dev/null
  kubectl -n $1 delete role viewer 2>/dev/null
  for role in `kubectl -n $1 get roles -l iam.kubesphere.io/role-template -o jsonpath="{.items[*].metadata.name}"`
  do
    kubectl -n $1 delete role $role 2>/dev/null
  done
}

# remove useless labels and finalizers
for ns in `kubectl get ns -o jsonpath="{.items[*].metadata.name}"`
do
  kubectl label ns $ns kubesphere.io/workspace-
  kubectl label ns $ns kubesphere.io/namespace-
  kubectl patch ns $ns -p '{"metadata":{"finalizers":null,"ownerReferences":null}}'
  delete_role_bindings $ns
  delete_roles $ns
done

# delete clusterroles
delete_cluster_roles() {
  for role in `kubectl get clusterrole -l iam.kubesphere.io/role-template -o jsonpath="{.items[*].metadata.name}"`
  do
    kubectl delete clusterrole $role 2>/dev/null
  done

  for role in `kubectl get clusterroles | grep "kubesphere" | awk '{print $1}'| paste -sd " "`
  do
    kubectl delete clusterrole $role 2>/dev/null
  done
}
delete_cluster_roles

# delete clusterrolebindings
delete_cluster_role_bindings() {
  for rolebinding in `kubectl get clusterrolebindings -l iam.kubesphere.io/role-template -o jsonpath="{.items[*].metadata.name}"`
  do
    kubectl delete clusterrolebindings $rolebinding 2>/dev/null
  done

  for rolebinding in `kubectl get clusterrolebindings | grep "kubesphere" | awk '{print $1}'| paste -sd " "`
  do
    kubectl delete clusterrolebindings $rolebinding 2>/dev/null
  done
}
delete_cluster_role_bindings

# delete clusters
for cluster in `kubectl get clusters -o jsonpath="{.items[*].metadata.name}"`
do
  kubectl patch cluster $cluster -p '{"metadata":{"finalizers":null}}' --type=merge
done
kubectl delete clusters --all 2>/dev/null

# delete workspaces
for ws in `kubectl get workspaces -o jsonpath="{.items[*].metadata.name}"`
do
  kubectl patch workspace $ws -p '{"metadata":{"finalizers":null}}' --type=merge
done
kubectl delete workspaces --all 2>/dev/null

# make DevOps CRs deletable
for devops_crd in $(kubectl get crd -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep "devops.kubesphere.io"); do
    for ns in $(kubectl get ns -ojsonpath='{.items..metadata.name}'); do
        for devops_res in $(kubectl get $devops_crd -n $ns -oname); do
            kubectl patch $devops_res -n $ns -p '{"metadata":{"finalizers":[]}}' --type=merge
        done
    done
done

# delete validatingwebhookconfigurations
for webhook in ks-events-admission-validate users.iam.kubesphere.io network.kubesphere.io validating-webhook-configuration resourcesquotas.quota.kubesphere.io
do
  kubectl delete validatingwebhookconfigurations.admissionregistration.k8s.io $webhook 2>/dev/null
done

# delete mutatingwebhookconfigurations
for webhook in ks-events-admission-mutate logsidecar-injector-admission-mutate mutating-webhook-configuration
do
  kubectl delete mutatingwebhookconfigurations.admissionregistration.k8s.io $webhook 2>/dev/null
done

# delete users
for user in `kubectl get users -o jsonpath="{.items[*].metadata.name}"`
do
  kubectl patch user $user -p '{"metadata":{"finalizers":null}}' --type=merge
done
kubectl delete users --all 2>/dev/null


# delete helm resources
for resource_type in `echo helmcategories helmapplications helmapplicationversions helmrepos helmreleases`; do
  for resource_name in `kubectl get ${resource_type}.application.kubesphere.io -o jsonpath="{.items[*].metadata.name}"`; do
    kubectl patch ${resource_type}.application.kubesphere.io ${resource_name} -p '{"metadata":{"finalizers":null}}' --type=merge
  done
  kubectl delete ${resource_type}.application.kubesphere.io --all 2>/dev/null
done

# delete workspacetemplates
for workspacetemplate in `kubectl get workspacetemplates.tenant.kubesphere.io -o jsonpath="{.items[*].metadata.name}"`
do
  kubectl patch workspacetemplates.tenant.kubesphere.io $workspacetemplate -p '{"metadata":{"finalizers":null}}' --type=merge
done
kubectl delete workspacetemplates.tenant.kubesphere.io --all 2>/dev/null

# delete federatednamespaces in namespace kubesphere-monitoring-federated
for resource in $(kubectl get federatednamespaces.types.kubefed.io -n kubesphere-monitoring-federated -oname); do
  kubectl patch "${resource}" -p '{"metadata":{"finalizers":null}}' --type=merge -n kubesphere-monitoring-federated
done

# delete crds
for crd in `kubectl get crds -o jsonpath="{.items[*].metadata.name}"`
do
  if [[ $crd == *kubesphere.io ]]; then kubectl delete crd $crd 2>/dev/null; fi
done

# delete relevance ns
for ns in kube-federation-system kubesphere-alerting-system kubesphere-controls-system kubesphere-devops-system kubesphere-devops-worker kubesphere-logging-system kubesphere-monitoring-system kubesphere-monitoring-federated openpitrix-system kubesphere-system
do
  kubectl delete ns $ns 2>/dev/null
done

