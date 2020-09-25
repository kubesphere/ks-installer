#!/usr/bin/env bash

# set -x: Print commands and their arguments as they are executed.
# set -e: Exit immediately if a command exits with a non-zero status.

# set -xe

# delete ks-install
kubectl delete deploy ks-installer -n kubesphere-system

# helm delete
helms="ks-minio|ks-openldap|ks-openpitrix|elasticsearch-logging|elasticsearch-logging-curator|istio|istio-init|jaeger-operator|ks-events|ks-jenkins|kube-auditing|kubefed|logsidecar-injector|metrics-server|notification-manager|uc"
helm list --all-namespaces | grep -E -o $helms | sort -u | xargs -r -L1 helm delete --purge

# namespace resource delete
namespaces="kubesphere-system|openpitrix-system|kubesphere-monitoring-system|kubesphere-alerting-system|kubesphere-controls-system|kubesphere-logging-system|istio-system|kube-federation-system|kubesphere-alerting-system"
#kubectl get ns --no-headers=true -o custom-columns=:metadata.name | grep -E -o $namespaces | sort -u | xargs -r -L1 kubectl delete all --all -n

# pvc delete
pvcs="kubesphere-system|openpitrix-system|kubesphere-monitoring-system|kubesphere-devops-system|kubesphere-logging-system"
kubectl --no-headers=true get pvc --all-namespaces -o custom-columns=:metadata.namespace,:metadata.name | grep -E $pvcs | xargs -n2 kubectl delete pvc -n

# delete rolebindings
delete_role_bindings() {
  for rolebinding in `kubectl -n $1 get rolebindings -l iam.kubesphere.io/user-ref -o jsonpath="{.items[*].metadata.name}"`
  do
    kubectl -n $1 delete rolebinding $rolebinding
  done
}

# delete roles
delete_roles() {
  kubectl -n $1 delete role admin
  kubectl -n $1 delete role operator
  kubectl -n $1 delete role viewer
  for role in `kubectl -n $1 get roles -l iam.kubesphere.io/role-template -o jsonpath="{.items[*].metadata.name}"`
  do
    kubectl -n $1 delete role $role
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

# delete workspaces
for ws in `kubectl get workspaces -o jsonpath="{.items[*].metadata.name}"`
do
  kubectl patch workspace $ws -p '{"metadata":{"finalizers":null}}' --type=merge
done
kubectl delete workspaces --all

# delete clusters
for cluster in `kubectl get clusters -o jsonpath="{.items[*].metadata.name}"`
do
  kubectl patch cluster $cluster -p '{"metadata":{"finalizers":null}}' --type=merge
done

# delete validatingwebhookconfigurations
for webhook in ks-events-admission-validate users.iam.kubesphere.io validating-webhook-configuration
do
  kubectl delete validatingwebhookconfigurations.admissionregistration.k8s.io $webhook
done

# delete mutatingwebhookconfigurations
for webhook in ks-events-admission-mutate logsidecar-injector-admission-mutate mutating-webhook-configuration
do
  kubectl delete mutatingwebhookconfigurations.admissionregistration.k8s.io $webhook
done

# delete users
for user in `kubectl get users -o jsonpath="{.items[*].metadata.name}"`
do
  kubectl patch user $user -p '{"metadata":{"finalizers":null}}' --type=merge
done
kubectl delete users --all

# delete crds
for crd in `kubectl get crds -o jsonpath="{.items[*].metadata.name}"`
do
  if [[ $crd == *kubesphere.io ]]; then kubectl delete crd $crd; fi
done

# delete namespaces
#kubectl get ns --no-headers=true -o custom-columns=:metadata.name | grep -E -o $namespaces | sort -u | xargs -r -L1 kubectl delete ns
