# logsidecar-injector

[logsidecar-injector](https://github.com/kubesphere/logsidecar-injector) a Kubernetes mutating webhook server that adds a sidecar to your pod. This sidecar is just to forward logs from files on volumes to stdout.
 
## Prerequisites
- Kubernetes v1.13+
- Helm 3+ 

## Installing the Chart

To install the chart with the release name `logsidecar-injector` into the namespace `kubesphere-logging-system`:

```console
helm install logsidecar-injector ./ --namespace kubesphere-logging-system
```

The command deploys logsidecar-injector on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `logsidecar-injector` release in the namespace `kubesphere-logging-system`:

```console
helm delete -f logsidecar-injector --namespace kubesphere-logging-system
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables list the configurable parameters of the logsidecar-injector chart and their default values.

| Parameter | Description | Default |
| ----- | ----------- | ------ |
| image.repository | Repository for logsidecar-injector | `kubespheredev/log-sidecar-injector` |
| image.tag | Tag for logsidecar-injector | `1.1` |
| image.pullPolicy | Pull policy for logsidecar-injector image | `IfNotPresent` |
| resources | Define resources requests and limits for logsidecar-injector container | `{}` |
| configReloader.image.repository | Repository for config reloader | `jimmidyson/configmap-reload` |
| configReloader.image.tag | Tag for config reloader | `v0.3.0` |
| configReloader.image.pullPolicy | Pull policy for config reloader image | `IfNotPresent` |
| configReloader.resources | Define resources requests and limits for config reloader | `{}` |
| sidecar.container.image.repository | Repository for image of sidecar container | `elastic/filebeat` |
| sidecar.container.image.tag | Tag for image of sidecar container  | `6.7.0` |
| sidecar.container.image.pullPolicy | Pull policy for image of sidecar container  | `IfNotPresent` |
| sidecar.container.resources | Define resources requests and limits for image of sidecar container | `{}` |
| sidecar.initContainer.image.repository | Repository for image of sidecar init container | `alpine` |
| sidecar.initContainer.image.tag | Tag for image of sidecar init container | `3.9` |
| sidecar.initContainer.image.pullPolicy | Pull policy for image of sidecar init container | `IfNotPresent` |
| sidecar.initContainer.resources | Define resources requests and limits for sidecar init container | `{}` |