# 在 Kubernetes 集群在线部署 KubeSphere

> [English](README.md) | 中文

KubeSphere 支持在已有 Kubernetes 集群之上部署 [KubeSphere](https://kubesphere.io/)。

## 准备工作

1. 确认现有的 `Kubernetes` 版本为 `1.19.x, 1.20.x, 1.21.x, 1.22.x (experimental)`，可以执行 `kubectl version` 来确认 :

```bash
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.8", GitCommit:"fd5d41537aee486160ad9b5356a9d82363273721", GitTreeState:"clean", BuildDate:"2021-02-17T12:41:51Z", GoVersion:"go1.15.8", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.8", GitCommit:"fd5d41537aee486160ad9b5356a9d82363273721", GitTreeState:"clean", BuildDate:"2021-02-17T12:33:08Z", GoVersion:"go1.15.8", Compiler:"gc", Platform:"linux/amd64"}
```

注意输出结果中的 `Server Version` 这行，如果显示 `GitVersion` 大于 `v1.17.0`，Kubernetes 的版本是可以安装的。如果低于 `v1.17.0`，可以先对 K8s 版本进行升级。


2. 集群现有的可用内存至少在 `2G` 以上。 如果是执行的 `allinone` 安装，那么执行 `free -g` 可以看下可用资源

```bash
$ free -g
              total        used        free      shared  buff/cache   available
Mem:              16          4          10           0           3           2
Swap:             0           0           0
```

3. KubeSphere 需配合持久化存储使用，执行`kubectl get sc` 查看当前环境中的存储类型 (当使用默认存储类型时，配置文件中可以不填存储相关信息)。

```bash
$ kubectl get sc
NAME                      PROVISIONER               AGE
ceph                      kubernetes.io/rbd         3d4h
csi-qingcloud (default)   disk.csi.qingcloud.com    54d
glusterfs                 kubernetes.io/glusterfs   3d4h
```

4. CSR signing 功能在 kube-apiserver 中被激活，参考 [RKE installation issue](https://github.com/kubesphere/kubesphere/issues/1925#issuecomment-591698309)。

如果你的 Kubernetes 环境满足以上的要求，那么可以接着执行下面的步骤了。

## 部署 KubeSphere

### 最小化快速部署

```bash
kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.1.1/kubesphere-installer.yaml
kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.1.1/cluster-configuration.yaml

 # 查看部署进度及日志
 $ kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f
```

部署完成后可执行如下命令查看控制台的服务端口，使用 `IP:consolePort(default: 30880)` 访问 KubeSphere UI 界面，默认的集群管理员账号为 `admin/P@88w0rd`。

```bash
kubectl get svc/ks-console -n kubesphere-system
```

以上为最小化部署，如需开启更多功能，请参考如下步骤配置相关依赖：

### 安装可插拔功能组件

> 注意：
> - KubeSphere 支持在安装前或完成后开启可插拔功能组件的安装，各功能组件的介绍请参考 [cluster-configuration.yaml](deploy/cluster-configuration.yaml)；
> - 在开启可插拔功能组件之前，请确保您的集群可用 CPU 与内存满足其可插拔功能组件所需的 CPU 和内存要求。

1. [可选项] 创建集群 Etcd 的证书 Secret。(仅开启 Etcd 监控需要设置)

> 注：根据集群实际 Etcd 证书位置创建；

- 若 Etcd 已经配置过证书，则参考如下创建（以下命令适用于 Kubeadm 创建的 Kubernetes 集群环境）：

```bash
$ kubectl create ns kubesphere-monitoring-system
$ kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs  \
--from-file=etcd-client-ca.crt=/etc/kubernetes/pki/etcd/ca.crt  \
--from-file=etcd-client.crt=/etc/kubernetes/pki/etcd/healthcheck-client.crt  \
--from-file=etcd-client.key=/etc/kubernetes/pki/etcd/healthcheck-client.key
```

- 若 Etcd 没有配置证书，则创建空 Secret：

```bash
kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs
```

2. 编辑 ClusterConfiguration 开启可插拔的功能组件:

```bash
kubectl edit cc ks-installer -n kubesphere-system
```

> 按功能需求编辑配置文件之后，退出等待生效即可，如长时间未生效请使用如下命令查看相关日志:

```bash
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f
```

> 如果你正在启用 KubeEdge ，在运行或重启 ks-installer 之前，需要配置集群外网访问地址advertiseAddress，暴露相应的访问端口，更多内容请参考[Kubeedge 指南](https://kubesphere.io/docs/pluggable-components/kubeedge/)：
```yaml
 kubeedge:
    cloudCore:
      cloudHub:
        advertiseAddress:
        - xxxx.xxxx.xxxx.xxxx
```

## 升级

部署新版本的ks-installer:
```bash
# 注意: ks-installer会自动迁移cluster-configuration. 请勿自行修改.

kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.1.1/kubesphere-installer.yaml
```


> 注意: 如果当前集群中部署的 KubeSphere 版本是 v2.1.1 或更早的版本，请先升级到 v3.0.0。