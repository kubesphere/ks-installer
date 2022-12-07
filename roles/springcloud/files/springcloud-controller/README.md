# Springcloud-controller Helm Chart

Springcloud-controller is designed to make the springcloud microservices technology stack more easily and quickly accessible to Kubernetes. Currently, it integrates three modules: "Service Registry", "Configuration Center", and "Microservice Gateway". The "Microservice Gateway" supports dynamic configuration of gateway routes. The registry and configuration center rely on the nacos component, and the microservice gateway relies on the spring cloud gateway.

## Introduction

The project relies on the nacos component, and the nacos installation uses the [nacos-k8s](https://github.com/nacos-group/nacos-k8s/).

## Prerequisites

- Kubernetes 1.10+
- Helm v3
- PV provisioner support in the underlying infrastructure

## Tips

For nacos if you use a custom database, please initialize the database script yourself first.
<https://github.com/alibaba/nacos/blob/develop/distribution/conf/nacos-mysql.sql>


## Installing the Chart

To install the chart with `release name`:

```shell
$ helm install `release name` ./springcloud-controller
```

The command deploys Nacos on the Kubernetes cluster in the default configuration. It will run without a mysql chart and persistent volume. The [configuration](#configuration) section lists the parameters that can be configured during installation. 

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete `release name`:

```shell
$ helm uninstall `release name`
```

The command removes all the Kubernetes components associated with the chart and deletes the release.




## Configuration

The following table lists the configurable parameters of the springcloud-controller chart and their default values.

### springcloud-controller

| Parameter                             | Description                                                        | Default                             |
|---------------------------------------|--------------------------------------------------------------------|-------------------------------------|
| `replicaCount`             | Number of desired springcloud-controller pods, the number should be 1 as run standalone mode | `1`            |
| `image.repository`          | springcloud-contrller container image name                   | `registry.cn-beijing.aliyuncs.com/kse/spring-cloud-controller` |
| `image.tag`                 | springcloud-controller container image tag                   | `v0.1.0`                                                     |
| `image.pullPolicy`          | springcloud-controller container image pull policy           | `IfNotPresent`                                               |
| `resources.limits.cpu`      | springcloud-controller limits cpu resource                   | `1`                                                          |
| `resources.limits.memory`   | springcloud-controller limits memory resource                | `1Gi`                                                        |
| `resources.requests.cpu`    | springcloud-controller requests cpu resource                 | `100m`                                                       |
| `resources.requests.memory` | springcloud-controller requests memory resource              | `10Mi`                                                       |



### nacos

| Parameter                             | Description                                                        | Default                             |
|---------------------------------------|--------------------------------------------------------------------|-------------------------------------|
| `nacos.global.mode`                   | Run Mode (~~quickstart,~~ standalone, cluster; )   | `standalone`            |
| `nacos.resources`                    | The [resources] to allocate for nacos container                    | `{}`                                |
| `nacos.nodeSelector`                 | Nacos labels for pod assignment                   | `{}`                                |
| `nacos.affinity`                     | Nacos affinity policy                                              | `{}`                                |
| `nacos.tolerations`                   | Nacos tolerations                                                  | `{}`                                |
| `nacos.resources.requests.cpu` |nacos requests cpu resource|`500m`|
| `nacos.resources.requests.memory` |nacos requests memory resource|`2G`|
| `nacos.nacos.replicaCount`                  | Number of desired nacos pods, the number should be 1 as run standalone mode| `1`           |
| `nacos.nacos.image.repository`              | Nacos container image name                                      | `nacos/nacos-server`                   |
| `nacos.nacos.image.tag`                     | Nacos container image tag                                       | `v2.1.2`                                |
| `nacos.nacos.image.pullPolicy`              | Nacos container image pull policy                                | `IfNotPresent`                        |
| `nacos.nacos.plugin.enable`              | Nacos cluster plugin that is auto scale                                       | `true`                   |
| `nacos.nacos.plugin.image.repository`              | Nacos cluster plugin image name                                      | `nacos/nacos-peer-finder-plugin`                   |
| `nacos.nacos.plugin.image.tag`                     | Nacos cluster plugin image tag                                       | `1.1`                                |
| `nacos.nacos.health.enabled`                | Enable health check or not                                         | `false`                              |
| `nacos.nacos.auth.enabled`                | Enable auth system or not                                         | `false`                              |
| `nacos.nacos.auth.tokenExpireSeconds` | The token expiration in seconds          | `18000`                         |
| `nacos.nacos.auth.token`           | The default token                                            | `SecretKey012345678901234567890123456789012345678901234567890123456789` |
| `nacos.nacos.auth.cacheEnabled`    | Turn on/off caching of auth information. By turning on this switch, the update of auth information would have a 15 seconds delay | `false`                              |
| `nacos.nacos.preferhostmode`            | Enable Nacos cluster node domain name support                      | `hostname`                         |
| `nacos.nacos.serverPort`                | Nacos port                                                         | `8848`                               |
| `nacos.nacos.storage.type`                | Nacos data storage method `mysql` or `embedded`. The `embedded` supports either standalone or cluster mode                                                       | `embedded`                               |
| `nacos.nacos.storage.db.host`                | mysql  host                                                       |                                |
| `nacos.nacos.storage.db.name`                | mysql  database name                                                      |                                |
| `nacos.nacos.storage.db.port`                | mysql port                                                       | 3306                               |
| `nacos.nacos.storage.db.username`                | username of  database                                                       |                               |
| `nacos.nacos.storage.db.password`                | password of  database                                                       |                               |
| `nacos.nacos.storage.db.param`                | Database url parameter                                                       | `characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useSSL=false`                               |
| `nacos.persistence.enabled`           | Enable the nacos data persistence or not                           | `false`                              |
| `nacos.persistence.data.accessModes`	| Nacos data pvc access mode										| `ReadWriteOnce`		|
| `nacos.persistence.data.storageClassName`	| Nacos data pvc storage class name									| `manual`			|
| `nacos.persistence.data.resources.requests.storage`	| Nacos data pvc requests storage									| `5G`					|
| `nacos.service.type`			| http service type													| `ClusterIP`			|
| `nacos.service.port`			| http service port													| `8848`				|
| `nacos.ingress.enabled`			| Enable ingress or not												| `false`				|
| `nacos.ingress.annotations`		| The annotations used in ingress									| `{}`					|
| `nacos.ingress.hosts`			| The host of nacos service in ingress rule							| `nacos.example.com`	|


## Example
#### nacos standalone mode(with embedded)
```console
$ helm install `release name` ./ --set nacos.global.mode=standalone
```
#### nacos cluster mode(without pv)
```console
$ helm install `release name` ./ --set nacos.global.mode=cluster
```
```console
$ kubectl scale sts `release name`-nacos --replicas=3
```
 * Use kubectl exec to get the cluster config of the Pods in the nacos StatefulSet after scale StatefulSets

