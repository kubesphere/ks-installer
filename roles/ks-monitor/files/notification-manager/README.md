# notification-manager

```console
helm install notification-manager
```

## Requirements

- Kubernetes v1.13+.
- helm v3.

## Installing

To install the chart with the release name `my-release`:

```console
helm install my-release ./helm -n ${namespace}
```

The command deploys the notification-manager chart to the namespace ${namespace} of the Kubernetes cluster with the default configuration. The configuration section lists the parameters that can be configured during installation.

## Uninstalling

To uninstall/delete the `my-release` deployment:

```console
helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the notification-manager chart and their default values.

Parameter | Description | Default
--- | --- | ---
`operator.containers.proxy.image.tag` | The image tag of container kube-rbac-proxy | `v0.4.1`
`operator.containers.proxy.image.pullPolicy` | The image pull policy of container kube-rbac-proxy | `IfNotPresent`
`operator.containers.proxy.resources` | The resource quota of container kube-rbac-proxy | {}
`operator.containers.operator.image.tag` | The image tag of container notification-manager-operator | `latest`
`operator.containers.operator.image.pullPolicy` | The image pull policy of the container notification-manager-operator | `IfNotPresent`
`operator.containers.operator.resources` | The resource quota of container notification-manager-operator | {}
`operator.nodeSelector` | The nodeSelector of notification-manager-operator | {}
`operator.tolerations` | The tolerations of notification-manager-operator | []
`operator.affinity` | The affinity of notification-manager-operator | {}
`notificationmanager.name` | The name of notification-manager | notification-manager
`notificationmanager.replicas` | The replicas of notification-manager | 1
`notificationmanager.image.tag` | The image tag of notification-manager | `latest`
`notificationmanager.image.pullPolicy` | The image pull policy of notification-manager | `IfNotPresent`
`notificationmanager.resources` | The resource quota of notification-manager | {}
`notificationmanager.nodeSelector` | The nodeSelector of notification-manager | {}
`notificationmanager.tolerations` | The tolerations of notification-manager | []
`notificationmanager.affinity` | The affinity of notification-manager | {}
`notificationmanager.receivers` | The receivers configure of notification-manager | {}
`notificationmanager.globalConfigSelector` | The global config selector of notification-manager | {}
