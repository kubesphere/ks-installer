# kube-events

[kube-events](https://github.com/kubesphere/kube-events) is an integration for Kubernetes Event exporting, filtering and alerting.
 

## Introduction

This chart includes multiple components and is suitable for a variety of use-cases.

## Prerequisites
- Kubernetes v1.13+
- Helm 3+ 

## Installing the Chart

To install the chart with the release name `kube-events` into the namespace `kubesphere-logging-system`:

```console
helm install kube-events ./ --namespace kubesphere-logging-system
```

The command deploys kube-events on the Kubernetes cluster with the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

The default installation includes kube-events-operator, kube-events-exporter, kube-events-ruler, and default rules in cluster scope.

## Uninstalling the Chart

To uninstall/delete the `kube-events` release in the namespace `kubesphere-logging-system`:

```console
helm delete kube-events --namespace kubesphere-logging-system
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

CRDs created by this chart are not removed and should be manually cleaned up:

```console
kubectl delete crd rulers.events.kubesphere.io
kubectl delete crd exporters.events.kubesphere.io
kubectl delete crd rules.events.kubesphere.io
```

## Configuration

The following tables list the configurable parameters of the kube-events chart and their default values.

### Rule
| Parameter | Description | Default |
| ----- | ----------- | ------ |
| rule.createDefaults | Whether to create default rules for filtering events | `true` |
| rule.overrideDefaults | Whether to override default rules when upgrade release | `false` |

### Operator
| Parameter | Description | Default |
| ----- | ----------- | ------ |
| operator.enabled | Deploy kube-events-operator. Only one of these should be deployed into the cluster | `true` |
| operator.image.repository | Repository for kube-events-operator image | `kubespheredev/kube-events-operator` |
| operator.image.tag | Tag for kube-events-operator image | `v0.1.0` |
| operator.image.pullPolicy | Pull policy for kube-events-operator image | `IfNotPresent` |
| operator.configReloader.image | Image for config reloader | `jimmidyson/configmap-reload:v0.3.0` |
| operator.serviceAccount.create | Create a service account for kube-events-operator | `true` |
| operator.serviceAccount.name | Kube-events-operator service account name | `""` |
| operator.cleanupAllCustomResources | Whether to clean up all custom resources(not crds) when uninstall release | `false` |

### Exporter
| Parameter | Description | Default |
| ----- | ----------- | ------ |
| exporter.enabled | Deploy kube-events-exporter | `true` |
| exporter.image.repository | Repository for kube-events-operator image | `kubespheredev/kube-events-exporter` |
| exporter.image.tag | Tag for kube-events-exporter image | `v0.1.0` |
| exporter.image.pullPolicy | Pull policy for kube-events-exporter image | `IfNotPresent` |
| exporter.resources | Define resources requests and limits for single Pods | `{}` |
| exporter.sinks.stdout.enabled | Enable stdout sink for events | `true` |
| exporter.sinks.additionalWebhooks | List of webhook sinks for events | `[]` |

### Ruler
| Parameter | Description | Default |
| ----- | ----------- | ------ |
| ruler.enabled | Deploy kube-events-ruler | `true` |
| ruler.image.repository | Repository for kube-events-ruler image | `kubespheredev/kube-events-ruler` |
| ruler.image.tag | Tag for kube-events-ruler image | `v0.1.0` |
| ruler.image.pullPolicy | Pull policy for kube-events-ruler image | `IfNotPresent` |
| ruler.resources | Define resources requests and limits for single Pods | `{}` |
| ruler.ruleNamespaceSelector | Namespaces to be selected for Rules discovery. If nil, select all namespaces | `{}` |
| ruler.ruleSelector | A selector to select which Rules to use for ruler | `{}` |
| ruler.sinks.alertmanager.namespace | Namespace of alertmanager service | `kubesphere-monitoring-system` |
| ruler.sinks.alertmanager.name | Name of alertmanager service | `alertmanager-main` |
| ruler.sinks.webhooks | List of webhook sinks for events notification or alerting | `[]` |