# Install KubeSphere on Existing Kubernetes Cluster

> English | [中文](README_zh.md)

In addition to supporting deploying on VM and BM, KubeSphere also supports installing on cloud-hosted and on-premises existing Kubernetes clusters.

## Prerequisites

> - Kubernetes Version: 1.20.x, 1.21.x, 1.22.x, 1.23.x;
> - CPU > 1 Core, Memory > 2 G;
> - An existing default Storage Class in your Kubernetes clusters.
> - The CSR signing feature is activated in kube-apiserver when it is started with the `--cluster-signing-cert-file` and `--cluster-signing-key-file` parameters, see [RKE installation issue](https://github.com/kubesphere/kubesphere/issues/1925#issuecomment-591698309).

1. Make sure your Kubernetes version is compatible by running `kubectl version` in your cluster node. The output looks as the following:

```bash
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.8", GitCommit:"fd5d41537aee486160ad9b5356a9d82363273721", GitTreeState:"clean", BuildDate:"2021-02-17T12:41:51Z", GoVersion:"go1.15.8", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.8", GitCommit:"fd5d41537aee486160ad9b5356a9d82363273721", GitTreeState:"clean", BuildDate:"2021-02-17T12:33:08Z", GoVersion:"go1.15.8", Compiler:"gc", Platform:"linux/amd64"}
```

> Note: Pay attention to `Server Version` line, if `GitVersion` is greater than `v1.19.0`, it's good to go. Otherwise you need to upgrade your Kubernetes first.

2. Check if the available resources meet the minimal prerequisite in your cluster.

```bash
$ free -g
              total        used        free      shared  buff/cache   available
Mem:              16          4          10           0           3           2
Swap:             0           0           0
```

3. Check if there is a default Storage Class in your cluster. An existing Storage Class is the prerequisite for KubeSphere installation.

```bash
$ kubectl get sc
NAME                      PROVISIONER               AGE
glusterfs (default)               kubernetes.io/glusterfs   3d4h
```

If your Kubernetes cluster environment meets all requirements mentioned above, then you can start to install KubeSphere.

## To Start Deploying KubeSphere

### Minimal Installation

```bash
kubectl apply -f https://raw.githubusercontent.com/kubesphere/kse-installer/v3.3.1-rc.0/deploy/kubesphere-installer.yaml
kubectl apply -f https://raw.githubusercontent.com/kubesphere/kse-installer/v3.3.1-rc.0/deploy/cluster-configuration.yaml
```

Then inspect the logs of installation.

```bash
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-installer -o jsonpath='{.items[0].metadata.name}') -f
```

When all Pods of KubeSphere are running, it means the installation is successful. Check the port (30880 by default) of the console service by the following command. Then you can use `http://IP:30880` to access the console with the default account `admin/P@88w0rd`.

```bash
kubectl get svc/ks-console -n kubesphere-system
```
### Enable Pluggable Components

> Attention:
> - KubeSphere supports enable the pluggable components before or after the installation, you can refer to the [cluster-configuration.yaml](deploy/cluster-configuration.yaml) for more details.
> - Make sure there is enough CPU and memory available in your cluster.

1. [Optional] Create the secret of certificate for Etcd in your Kubernetes cluster. This step is only needed when you want to enable Etcd monitoring.

> Note: Create the secret according to the actual Etcd certificate path of your cluster; If the Etcd has not been configured certificate, an empty secret needs to be created.

- If the Etcd has been configured with certificates, refer to the following step (The following command is an example that is only used for the cluster created by `kubeadm`):

```bash
$ kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs  \
--from-file=etcd-client-ca.crt=/etc/kubernetes/pki/etcd/ca.crt  \
--from-file=etcd-client.crt=/etc/kubernetes/pki/etcd/healthcheck-client.crt  \
--from-file=etcd-client.key=/etc/kubernetes/pki/etcd/healthcheck-client.key
```

- If the Etcd has not been configured with certificates.

```bash
kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs
```

2. If you already have a minimal KubeSphere setup, you still can enable the pluggable components by editing the ClusterConfiguration of ks-installer using the following command.

> Note: Please make sure there is enough CPU and memory available in your cluster.

```bash
kubectl edit cc ks-installer -n kubesphere-system
```
> Note: When you're enabling KubeEdge, please set advertiseAddress as below and expose corresponding ports correctly before you run or restart ks-installer. Please refer to [KubeEdge Guide](https://kubesphere.io/docs/pluggable-components/kubeedge/) for more details.
```yaml
kubeedge:
    cloudCore:
      cloudHub:
        advertiseAddress:
        - xxxx.xxxx.xxxx.xxxx
```

3. Inspect the logs of installation.

```bash
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-installer -o jsonpath='{.items[0].metadata.name}') -f
```

## Upgrade

Deploy the new version of ks-installer:
```bash
# Notice: ks-installer will automatically migrate the configuration. Do not modify the cluster configuration by yourself.

kubectl apply -f https://raw.githubusercontent.com/kubesphere/kse-installer/v3.3.1-rc.0/deploy/kubesphere-installer.yaml
```

> Note: If your KubeSphere version is v3.1.x or eariler, please upgrade to v3.2.x first.
