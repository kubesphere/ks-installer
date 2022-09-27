# OpenSearch Dashboards Helm Chart

 This Helm chart installs [OpenSearch Dashboards](https://github.com/opensearch-project/OpenSearch-Dashboards) with configurable TLS, RBAC and much more configurations. This chart caters to a number of different use cases and setups.

 - [Requirements](#requirements)
 - [Installing](#installing)
 - [Uninstalling](#uninstalling)

 ## Requirements

 * Kubernetes >= 1.14
 * Helm >= 2.17.0
 * We recommend you to have 8 GiB of memory available for this deployment, or at least 4 GiB for the minimum requirement. Else, the deployment is expected to fail.

 ## Installing

 Once you've added this Helm repository as per the repository-level [README](../../README.md#installing)
 then you can install the chart as follows:

 ```shell
 helm install my-release opensearch/opensearch-dashboards
```

 The command deploys OpenSearch Dashboards with its associated components on the Kubernetes cluster in the default configuration.

 **NOTE:** If using Helm 2 then you'll need to add the [`--name`](https://v2.helm.sh/docs/helm/#options-21) command line argument. If unspecified, Helm 2 will autogenerate a name for you.

 ## Uninstalling
 To delete/uninstall the chart with the release name `my-release`:

 ```shell
 helm uninstall my-release
 ```

## Configuration

| Parameter                          | Description                                                                                                                                                                                                                                               | Default                                         |
|------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------|
| `envFrom`                          | Templatable string to be passed to the [environment from variables][] which will be appended to the `envFrom:` definition for the container                                                                                                               | `[]`                                            |
| `config`                         | Allows you to add any config files in `/usr/share/opensearch-dashboards/` such as `opensearch_dashboards.yml` . See [values.yaml][] for an example of the formatting                                                                        | `{}`                                            |
| `extraContainers`                  | Array of extra containers                                                                                                                                           | `""`                                            |
| `extraEnvs`                        | Extra environments variables to be passed to OpenSearch services                                                                                                                           | `[]`                                            |
| `extraInitContainers`              | Array of extra init containers                                                                                                                                          | `[]`                                            |
| `extraVolumeMounts`                | Array of extra volume mounts                                                                                                                                       | `[] `                                           |
| `extraVolumes`                     | Array of extra volumes to be added                                                                                                                                                | `[]`                                            |
| `fullnameOverride`                 | Overrides the `clusterName` and `nodeGroup` when used in the naming of resources. This should only be used when using a single `nodeGroup`, otherwise you will have name conflicts                                                                        | `""`                                            |
| `hostAliases`                      | Configurable [hostAliases][]                                                                                                                                                                                                                              | `[]`                                            |
| `image.pullPolicy`                 | The Kubernetes [imagePullPolicy][] value                                                                                                                                                                                                                  | `IfNotPresent`                                  |
| `imagePullSecrets`                 | Configuration for [imagePullSecrets][] so that you can use a private registry for your image                                                                                                                                                              | `[]`                                            |
| `image.tag`                        | The OpenSearch Docker image tag                                                                                                                                                                                                                        | `1.0.0`                               |
| `image.repository`                 | The OpenSearch Docker image                                                                                                                                                                                                                            | `opensearchproject/opensearch` |
| `ingress`                          | Configurable [ingress][] to expose the OpenSearch service. See [values.yaml][] for an example                                                                                                                                                          | see [values.yaml][]                             |
| `labels`                           | Configurable [labels][] applied to all OpenSearch pods                                                                                                                                                                                                 | `{}`                                            |
| `nameOverride`                     | Overrides the `clusterName` when used in the naming of resources                                                                                                                                                                                          | `""`                                            |
| `nodeSelector`                     | Configurable [nodeSelector][] so that you can target specific nodes for your OpenSearch cluster                                                                                                                                                        | `{}`                                            |
| `podAnnotations`                   | Configurable [annotations][] applied to all OpenSearch pods                                                                                                                                                                                            | `{}`                                            |
| `podSecurityContext`               | Allows you to set the [securityContext][] for the pod                                                                                                                                                                                                     | see [values.yaml][]                             |
| `priorityClassName`                | The name of the [PriorityClass][]. No default is supplied as the PriorityClass must be created first                                                                                                                                                      | `""`                                            |                                        |
| `rbac`                             | Configuration for creating a role, role binding and ServiceAccount as part of this Helm chart with `create: true`. Also can be used to reference an external ServiceAccount with `serviceAccountName: "externalServiceAccountName"`                       | see [values.yaml][]                             |
| `resources`                        | Allows you to set the [resources][] for the StatefulSet                                                                                                                                                                                                   | see [values.yaml][]                             |
| `secretMounts`                     | Allows you easily mount a secret as a file inside the StatefulSet. Useful for mounting certificates and other secrets. See [values.yaml][] for an example                                                                                                 | `[]`                                            |
| `securityContext`                  | Allows you to set the [securityContext][] for the container                                                                                                                                                                                               | see [values.yaml][]                             |
| `service.annotations`              | [LoadBalancer annotations][] that Kubernetes will use for the service. This will configure load balancer if `service.type` is `LoadBalancer`                                                                                                              | `{}`                                            |
| `service.headless.annotations`     | Allow you to set annotations on the headless service                                                                                                                                                                                                      | `{}`                                            |
| `service.externalTrafficPolicy`    | Some cloud providers allow you to specify the [LoadBalancer externalTrafficPolicy][]. Kubernetes will use this to preserve the client source IP. This will configure load balancer if `service.type` is `LoadBalancer`                                    | `""`                                            |
| `service.httpPortName`             | The name of the http port within the service                                                                                                                                                                                                              | `http`                                          |
| `service.labelsHeadless`           | Labels to be added to headless service                                                                                                                                                                                                                    | `{}`                                            |
| `service.labels`                   | Labels to be added to non-headless service                                                                                                                                                                                                                | `{}`                                            |
| `service.loadBalancerIP`           | Some cloud providers allow you to specify the [loadBalancer][] IP. If the `loadBalancerIP` field is not specified, the IP is dynamically assigned. If you specify a `loadBalancerIP` but your cloud provider does not support the feature, it is ignored. | `""`                                            |
| `service.loadBalancerSourceRanges` | The IP ranges that are allowed to access                                                                                                                                                                                                                  | `[]`                                            |
| `service.nodePort`                 | Custom [nodePort][] port that can be set if you are using `service.type: nodePort`                                                                                                                                                                        | `""`                                            |
| `service.transportPortName`        | The name of the transport port within the service                                                                                                                                                                                                         | `transport`                                     |
| `service.type`                     | OpenSearch [Service Types][]                                                                                                                                                                                                                           | `ClusterIP`                                     |
| `tolerations`                      | Configurable [tolerations][]                                                                                                                                                                                                                              | `[]`                                            |
| `updateStrategy`                   | The [updateStrategy][] for the StatefulSet. By default Kubernetes will wait for the cluster to be green after upgrading each pod. Setting this to `OnDelete` will allow you to manually delete each pod during upgrades                                   | `RollingUpdate`                                 |
| `extraObjects`                     | Array of extra K8s manifests to deploy                                                                                                                                                                                                                    | list `[]`                                       |
| `autoscaling`                          | Prerequisite: Install/Configure metrics server, to install use `kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml`, See https://github.com/kubernetes-sigs/metrics-server. Configurable pod autoscaling stratergy to scale based on `targetCPUUtilizationPercentage`, configure `minReplicas` and `maxReplicas` for desired scaling                                                                                                                                                        | false                             |