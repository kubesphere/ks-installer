kind=(applications.app.k8s.io
      clusterrolebindings.rbac.authorization.k8s.io
      clusterroles.rbac.authorization.k8s.io
      configmaps deployments.apps
      ingresses.networking.k8s.io
      globalrolebindings.iam.kubesphere.io
      globalroles.iam.kubesphere.io
      groupbindings.iam.kubesphere.io
      groups.iam.kubesphere.io
      jobs.batch
      limitranges
      namespaces
      persistentvolumeclaims
      replicasets.apps
      secrets
      serviceaccounts
      services
      statefulsets.apps
      users.iam.kubesphere.io
      workspacerolebindings.iam.kubesphere.io
      workspaceroles.iam.kubesphere.io
      workspaces.tenant.kubesphere.io)
for item in "${kind[@]}";
do
  kubefedctl enable $item --output yaml > ${item}.yaml
done
