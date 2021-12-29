# kube-auditing

```console
helm install kube-auditing
```

## Requirements

- Kubernetes v1.13+.
- helm v3.

## Installing

To install the chart with the release name `my-release`:

```console
helm install --name my-release kube-auditing ./helm-kube-auditing -n ${namespace}
```

The command deploys the kube-auditing chart to the namespace ${namespace} of the Kubernetes cluster with the default configuration. The configuration section lists the parameters that can be configured during installation.

## Uninstalling

To uninstall/delete the `my-release` deployment:

```console
helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the redis chart and their default values.

| Parameter                    | Description                                         | Default                             |
|------------------------------|-----------------------------------------------------|-------------------------------------|
| `operator.image.repository`  | The image of kube-auditing operator                 | `kubesphere/kube-auditing-operator` |
| `operator.image.tag`         | The tag of the kube-auditing operator image         | `latest`                            |
| `operator.image.pullPolicy`  | The pull policy of the kube-auditing operator image | `IfNotPresent`                      |
| `operator.image.pullSecrets` | The secret of the kube-auditing operator image      | []                                  |
| `operator.resources`         | The resource quota of the kube-auditing operator    | {}                                  |
| `operator.nodeSelector`      | The nodeSelector of the kube-auditing operator      | {}                                  |
| `operator.tolerations`       | The tolerations of the kube-auditing operator       | []                                  |
| `operator.affinity`          | The affinity of the kube-auditing operator          | {}                                  |
| `webhook.name`               | The name of the kube-auditing webhook               | kube-auditing-webhook               |
| `webhook.replicas`           | The replicas of the kube-auditing webhook           | 1                                   |
| `webhook.image.repository`   | The image of kube-auditing webhook                  | `kubesphere/kube-auditing-webhook`  |
| `webhook.image.tag`          | The tag of the kube-auditing webhook image          | `latest`                            |
| `webhook.image.pullPolicy`   | The pull policy of the kube-auditing webhook image  | `IfNotPresent`                      |
| `webhook.image.pullSecrets`  | The secret of the kube-auditing webhook image       | []                                  |
| `webhook.args`               | The args of the kube-auditing webhook               | []                                  |
| `webhook.resources`          | The resource quota of the kube-auditing webhook     | {}                                  |
| `webhook.nodeSelector`       | The nodeSelector of the kube-auditing webhook       | {}                                  |
| `webhook.tolerations`        | The tolerations of the kube-auditing webhook        | []                                  |
| `webhook.affinity`           | The affinity of the kube-auditing webhook           | {}                                  |
| `webhook.receivers`          | The receivers of the kube-auditing webhook          | []                                  |
| `webhook.priority`           | The priority of the kube-auditing webhook           | DEBUG                               |
| `webhook.auditType`          | The auditType of the kube-auditing webhook          | dynamic                             |
| `webhook.auditLevel`         | The auditLevel of the kube-auditing webhook         | Metadata                            |
