# Install KubeSphere on Existing Kubernetes Cluster

> English | [中文](README_zh.md)

In addition to supporting deploying on VM and BM, KubeSphere also supports installing on cloud-hosted and on-premises existing Kubernetes clusters.

## Prerequisites

> - Kubernetes Version: 1.15.x, 1.16.x, 1.17.x, 1.18.x;
> - CPU > 1 Core, Memory > 2 G;
> - An existing default Storage Class in your Kubernetes clusters.
> - The CSR signing feature is activated in kube-apiserver when it is started with the `--cluster-signing-cert-file` and `--cluster-signing-key-file` parameters, see [RKE installation issue](https://github.com/kubesphere/kubesphere/issues/1925#issuecomment-591698309).

1. Make sure your Kubernetes version is compatible by running `kubectl version` in your cluster node. The output looks as the following:

```bash
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.1", GitCommit:"4485c6f18cee9a5d3c3b4e523bd27972b1b53892", GitTreeState:"clean", BuildDate:"2019-07-18T09:09:21Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.1", GitCommit:"4485c6f18cee9a5d3c3b4e523bd27972b1b53892", GitTreeState:"clean", BuildDate:"2019-07-18T09:09:21Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
```

> Note: Pay attention to `Server Version` line, if `GitVersion` is greater than `v1.15.0`, it's good to go. Otherwise you need to upgrade your kubernetes first.

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
kubectl apply -f https://raw.githubusercontent.com/kubesphere/ks-installer/v3.0.0-alpha.1/deploy/kubesphere-installer.yaml
kubectl apply -f https://raw.githubusercontent.com/kubesphere/ks-installer/v3.0.0-alpha.1/deploy/cluster-configuration.yaml
```

Then inspect the logs of installation.

```bash
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f
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

3. Inspect the logs of installation.

```bash
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f
```
