# 在 Kubernetes 集群在线部署 KubeSphere

> [English](README.md) | 中文

KubeSphere 支持在已有 Kubernetes 集群之上部署 [KubeSphere](https://kubesphere.io/)。

## 准备工作

1. 确认现有的 `Kubernetes` 版本为 `1.15.x, 1.16.x, 1.17.x, 1.18.x`，可以执行 `kubectl version` 来确认 :

```bash
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.1", GitCommit:"4485c6f18cee9a5d3c3b4e523bd27972b1b53892", GitTreeState:"clean", BuildDate:"2019-07-18T09:09:21Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.1", GitCommit:"4485c6f18cee9a5d3c3b4e523bd27972b1b53892", GitTreeState:"clean", BuildDate:"2019-07-18T09:09:21Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
```

注意输出结果中的 `Server Version` 这行，如果显示 `GitVersion` 大于 `v1.15.0`，Kubernetes 的版本是可以安装的。如果低于 `v1.15.0`，可以先对 K8s 版本进行升级。


2. 集群现有的可用内存至少在 `10G` 以上。 如果是执行的 `allinone` 安装，那么执行 `free -g` 可以看下可用资源

```bash
$ free -g
              total        used        free      shared  buff/cache   available
Mem:              16          4          10           0           3           2
Swap:             0           0           0
```

3. KubeSphere 需配合持久化存储使用，执行`kubectl get sc` 查看当前环境中的存储类型 (当使用默认存储类型时，配置文件中可以不填存储相关信息).

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
kubectl apply -f https://raw.githubusercontent.com/kubesphere/ks-installer/v3.0.0-alpha.2/deploy/kubesphere-installer.yaml
kubectl apply -f https://raw.githubusercontent.com/kubesphere/ks-installer/v3.0.0-alpha.2/deploy/cluster-configuration.yaml

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
