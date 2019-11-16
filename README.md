# Install KubeSphere on Existing Kubernetes Cluster

> English | [中文](README_zh.md)

In addition to supporting deploy on VM and BM, KubeSphere also supports installing on cloud-hosted and on-premises Kubernetes clusters,

## Prerequisites

- Kubernetes Version: 1.13.x, 1.14.x, 1.15.x;
- Helm Version: `>= 2.10.0` (excluding 2.16.0), see [Install and Configure Helm in Kubernetes](https://devopscube.com/install-configure-helm-kubernetes/);
- CPU > 1 Core, Memory > 2 G;
- An existing Storage Class in your Kubernetes clusters.

1. Make sure your Kubernetes version is greater than 1.13.0, run `kubectl version` in your cluster node. The output looks like the following:
```bash
root@kubernetes:~# kubectl version
Client Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.1", GitCommit:"4485c6f18cee9a5d3c3b4e523bd27972b1b53892", GitTreeState:"clean", BuildDate:"2019-07-18T09:09:21Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.1", GitCommit:"4485c6f18cee9a5d3c3b4e523bd27972b1b53892", GitTreeState:"clean", BuildDate:"2019-07-18T09:09:21Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
```

> Note: Pay attention to `Server Version` line, if `GitVersion` is greater than `v1.13.0`, it's good. Otherwise you need to upgrade your kubernetes first. You can refer to [Upgrading kubeadm clusters from v1.12 to v1.13](https://v1-13.docs.kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade-1-13/).

2. Make sure you've already installed `Helm`, and it's version is greater than `2.10.0`. You can run `helm version` to check, the output looks like below:
```bash
root@kubernetes:~# helm version
Client: &version.Version{SemVer:"v2.13.1", GitCommit:"618447cbf203d147601b4b9bd7f8c37a5d39fbb4", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.13.1", GitCommit:"618447cbf203d147601b4b9bd7f8c37a5d39fbb4", GitTreeState:"clean"}
```

> Note: If you get `helm: command not found`, it means `Helm` is not installed yet. You can refer to [Install Helm](https://helm.sh/docs/using_helm/#from-the-binary-releases) to find out how to install `Helm`, and don't forget to run `helm init` first after installation. If you use an older version (<2.10.0), you need to  [Upgrade Helm and Tiller](https://github.com/helm/helm/blob/master/docs/install.md#upgrading-tiller).

3. Check if the available resources meet the minimal prerequisite in your cluster.

```bash
root@kubernetes:~# free -g
              total        used        free      shared  buff/cache   available
Mem:              16          4          10           0           3           2
Swap:             0           0           0
```

4. Check if there is a default Storage Class in your cluster, an existing Storage Class is the prerequisite for KubeSphere installation.

```bash
root@kubernetes:~$ kubectl get sc
NAME                      PROVISIONER               AGE
glusterfs (default)               kubernetes.io/glusterfs   3d4h
```

If your Kubernetes cluster environment meets all above 4 requirements, then you can install it.


## To Start Deploying KubeSphere

### Minimal Installation

> Attention: Following section is only used for minimal installation by default, KubeSphere has decoupled some core components in v2.1.0, for more pluggable components installation, see `Enable Pluggable Components` below.


```yaml
$ kubectl apply -f https://raw.githubusercontent.com/kubesphere/ks-installer/master/kubesphere-minimal.yaml
```

Then inspect the logs of installation.

```bash
$ kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f
```

When all Pods of KubeSphere are running, it means the installation is successsful. Then you can use `http://IP:30880` to access the dashboard with default account `admin/P@88w0rd`.


### Enable Pluggable Components


1. Create the Secret of CA certificate of your Kubernetes cluster. The CA certificate is the prerequisite of enabling DevOps and OpenPitrix components installation.

> Note: To create this secret according to the certificate paths of `ca.crt` and `ca.key` of your cluster. Generally, the certificate path of cluster which is created by `kubeadm` is `/etc/kubernetes/pki`.

```bash
$ kubectl create ns kubesphere-system

$ kubectl -n kubesphere-system create secret generic kubesphere-ca  \
--from-file=ca.crt=/etc/kubernetes/pki/ca.crt  \
--from-file=ca.key=/etc/kubernetes/pki/ca.key
```

2. Create the Secret of certificate for etcd in your Kubernetes cluster. This step is only needed when you prefer enabling etcd monitoring.

> Note: Create the secret according to the actual ETCD certificate path of your cluster; If the ETCD has not been configured certificate, an empty secret need to be created



  - If the ETCD has been configured with certificates, refer to the following step （The following command is an example which is only used for the cluster created by `kubeadm`）:

```bash
$ kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs  \
--from-file=etcd-client-ca.crt=/etc/kubernetes/pki/etcd/ca.crt  \
--from-file=etcd-client.crt=/etc/kubernetes/pki/etcd/healthcheck-client.crt  \
--from-file=etcd-client.key=/etc/kubernetes/pki/etcd/healthcheck-client.key
```

 - If the ETCD has not been configured with certificates.

```bash
$ kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs
```


3. Then we can edit the ConfigMap to enable any pluggable components that you need.


```bash
$ kubectl edit cm ks-installer -n kubesphere-system
```
> Attention: After complete ConfigMap edit, you can exit directly then it'll  automatically trigger the installation.

4. Inspect the logs of installation.

```bash
$ kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f
```

When all Pods of KubeSphere are running, it means the installation is successsful. Then you can use `http://IP:30880` to access the dashboard with default account `admin/P@88w0rd`.

![](https://pek3b.qingstor.com/kubesphere-docs/png/20191116004533.png)

## Configuration Table

<table border=0 cellpadding=0 cellspacing=0 width=1288 style='border-collapse:
 collapse;table-layout:fixed;width:966pt'>
 <col width=202 style='mso-width-source:userset;mso-width-alt:7196;width:152pt'>
 <col width=232 style='mso-width-source:userset;mso-width-alt:8248;width:174pt'>
 <col width=595 style='mso-width-source:userset;mso-width-alt:21162;width:446pt'>
 <col class=xl6519753 width=259 style='mso-width-source:userset;mso-width-alt:
 9216;width:194pt'>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 class=xl6619753 width=434 style='height:13.8pt;
  width:326pt'>Parameter</td>
  <td class=xl6619753 width=595 style='width:446pt'>Description</td>
  <td class=xl6819753 width=259 style='width:194pt'>Default</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>persistence</td>
  <td class=xl6719753>storageClass</td>
  <td class=xl1519753>Installer will uses the default StorageClass, you can appoint any other StorageClass</td>
  <td class=xl6519753>“”</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td rowspan=4 height=84 class=xl6719753 style='height:62.4pt'>etcd</td>
  <td class=xl6719753>monitoring</td>
  <td class=xl1519753>Whether to enable etcd monitoring</td>
  <td class=xl6519753>False</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>endpointIps</td>
  <td class=xl1519753>etcd address（for etcd cluster, see an example value like `192.168.0.7,192.168.0.8,192.168.0.9`）</td>
  <td class=xl6519753></td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>port</td>
  <td class=xl1519753>etcd port (Default port: 2379, you can appoint any other port)</td>
  <td class=xl6519753>2379</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>tlsEnable</td>
  <td class=xl1519753>Whether to enable etcd TLS certificate authentication.（True / False）</td>
  <td class=xl6519753>True</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td rowspan=5 height=105 class=xl6719753 style='height:78.0pt'>common</td>
  <td class=xl6719753>mysqlVolumeSize</td>
  <td class=xl1519753>MySQL volume size (cannot be modified after set)</td>
  <td class=xl6519753>20Gi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>minioVolumeSize</td>
  <td class=xl1519753>Minio volume size (cannot be modified after set)</td>
  <td class=xl6519753>20Gi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>etcdVolumeSize</td>
  <td class=xl1519753>etcd volume size (cannot be modified after set)</td>
  <td class=xl6519753>20Gi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>openldapVolumeSize</td>
  <td class=xl1519753>openldap volume size (cannot be modified after set)</td>
  <td class=xl6519753>2Gi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>redisVolumSize</td>
  <td class=xl1519753>redis volume size (cannot be modified after set)</td>
  <td class=xl6519753>2Gi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td rowspan=2 height=42 class=xl6719753 style='height:31.2pt'>console</td>
  <td class=xl6719753>enableMultiLogin</td>
  <td class=xl1519753>是否启动多点登录 （True / False）Whether to enable multiple point login</td>
  <td class=xl6519753>False</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>port</td>
  <td class=xl1519753>Console Port（NodePort）</td>
  <td class=xl6519753>30880</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td rowspan=4 height=84 class=xl6719753 style='height:62.4pt'>monitoring</td>
  <td class=xl6719753>prometheusReplicas</td>
  <td class=xl1519753>Prometheus replicas</td>
  <td class=xl6519753>1</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>prometheusMemoryRequest</td>
  <td class=xl1519753>Prometheus memory request </td>
  <td class=xl6519753>400Mi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>prometheusVolumeSize</td>
  <td class=xl1519753>Prometheus volume size</td>
  <td class=xl6519753>20Gi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>grafana.enabled</td>
  <td class=xl1519753>Whether to enable Grafana installation（True / False）</td>
  <td class=xl6519753>False</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td rowspan=9 height=189 class=xl6619753 style='height:140.4pt'>logging</td>
  <td class=xl6719753>enabled</td>
  <td class=xl1519753>Whether to enable logging system installation<span
  style='mso-spacerun:yes'>&nbsp;&nbsp; </span>（True / False）</td>
  <td class=xl6519753>False</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>elasticsearchMasterReplicas</td>
  <td class=xl1519753>Elasticsearch master replicas</td>
  <td class=xl6519753>1</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>elasticsearchDataReplicas</td>
  <td class=xl1519753>elasticsearch data replicas</td>
  <td class=xl6519753>1</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>logsidecarReplicas</td>
  <td class=xl1519753>logsidecar replicas</td>
  <td class=xl6519753>2</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>elasticsearchVolumeSize</td>
  <td class=xl1519753>elasticsearch volume size</td>
  <td class=xl6519753>20Gi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>logMaxAge</td>
  <td class=xl1519753>Log remaining time (days)</td>
  <td class=xl6519753>7</td>
 </tr>



## Support, Discussion, and Community

If you need any help with KubeSphere, please join us at [Slack Channel](https://join.slack.com/t/kubesphere/shared_invite/enQtNTE3MDIxNzUxNzQ0LTZkNTdkYWNiYTVkMTM5ZThhODY1MjAyZmVlYWEwZmQ3ODQ1NmM1MGVkNWEzZTRhNzk0MzM5MmY4NDc3ZWVhMjE).
