# Install KubeSphere on Existing Kubernetes Cluster

> English | [中文](README_zh.md)

In addition to supporting deploy on VM and BM, KubeSphere also supports installing on cloud-hosted and on-premises Kubernetes clusters,

## Prerequisites

- Kubernetes Version: 1.13.x, 1.14.x, 1.15.x
- Helm Version: `>= 2.10.0` (excluding 2.16.0)

1. Make sure your Kubernetes version is greater than 1.13.0, run `kubectl version` in your cluster node. The output looks like the following:
```bash
root@kubernetes:~# kubectl version
Client Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.1", GitCommit:"4485c6f18cee9a5d3c3b4e523bd27972b1b53892", GitTreeState:"clean", BuildDate:"2019-07-18T09:09:21Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.1", GitCommit:"4485c6f18cee9a5d3c3b4e523bd27972b1b53892", GitTreeState:"clean", BuildDate:"2019-07-18T09:09:21Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
```

Pay attention to `Server Version` line, if `GitVersion` is greater than `v1.13.0`, it's good. Otherwise you need to upgrade your kubernetes first. You can refer to [Upgrading kubeadm clusters from v1.12 to v1.13](https://v1-13.docs.kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade-1-13/).

2. Make sure you've already installed `Helm`, and it's version is greater than `2.10.0`. You can run `helm version` to check, the output looks like below:
```bash
root@kubernetes:~# helm version
Client: &version.Version{SemVer:"v2.13.1", GitCommit:"618447cbf203d147601b4b9bd7f8c37a5d39fbb4", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.13.1", GitCommit:"618447cbf203d147601b4b9bd7f8c37a5d39fbb4", GitTreeState:"clean"}
```

If you get `helm: command not found`, it means `Helm` is not installed yet. You can check this doc [Install Helm](https://helm.sh/docs/using_helm/#from-the-binary-releases) to find out how to install `Helm`, and don't forget to run `helm init` first after installation.

If you use an older version (<2.10.0), you need to upgrade your helm first. [Upgrading Tiller](https://github.com/helm/helm/blob/master/docs/install.md#upgrading-tiller)

3. Check the available resources in your cluster is meets the requirement. For `allinone` installation, means there is just one node in your cluster, you must have at least `10Gi` memory left to finish installation. You can run `free -g` to get a roughly estimate.
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
ceph                      kubernetes.io/rbd         3d4h
csi-qingcloud (default)   disk.csi.qingcloud.com    54d
glusterfs                 kubernetes.io/glusterfs   3d4h
```

If your Kubernetes cluster environment meets all above requirements, you are good to go.

> Note:
> - Make sure the remaining available memory in the cluster is `10G at least`.
> - It's recommended that the K8s cluster use persistent storage and has created default storage class.

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

<table border=0 cellpadding=0 cellspacing=0 width=1364 style='border-collapse:
 collapse;table-layout:fixed;width:1023pt;font-variant-ligatures: normal;
 font-variant-caps: normal;orphans: 2;text-align:start;widows: 2;-webkit-text-stroke-width: 0px;
 text-decoration-style: initial;text-decoration-color: initial'>
 <col width=112 style='mso-width-source:userset;mso-width-alt:3982;width:84pt'>
 <col width=156 style='mso-width-source:userset;mso-width-alt:5546;width:117pt'>
 <col width=757 style='mso-width-source:userset;mso-width-alt:26908;width:568pt'>
 <col width=339 style='mso-width-source:userset;mso-width-alt:12060;width:254pt'>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 class=xl67 width=268 style='height:13.8pt;width:201pt'>Parameter</td>
  <td class=xl65 width=757 style='width:568pt'><span style='font-variant-ligatures: normal;
  font-variant-caps: normal;orphans: 2;widows: 2;-webkit-text-stroke-width: 0px;
  text-decoration-style: initial;text-decoration-color: initial'>Description</span></td>
  <td class=xl65 width=339 style='width:254pt'><span style='font-variant-ligatures: normal;
  font-variant-caps: normal;orphans: 2;widows: 2;-webkit-text-stroke-width: 0px;
  text-decoration-style: initial;text-decoration-color: initial'>Default</span></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>kube_apiserver_host</td>
  <td>The address of kube-apiserver of your current Kubernetes cluster（i.e. IP:NodePort）</td>
  <td class=xl69></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>etcd_tls_enable</td>
  <td>Whether to enable etcd TLS certificate authentication（True / False）</td>
  <td class=xl69>True</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 class=xl66 style='height:13.8pt'>etcd_endpoint_ips</td>
  <td>Etcd addresses, such as ETCD clusters, you need to separate IPs by commas（e.g.192.168.0.7,192.168.0.8,192.168.0.9）</td>
  <td class=xl69></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>etcd_port</td>
  <td>ETCD Port (2379 by default, you can configure this parameter if you are using another port)</td>
  <td class=xl69>2379</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>disableMultiLogin<span
  style='mso-spacerun:yes'>&nbsp;</span></td>
  <td>Whether to turn off multipoint login for accounts<span style='mso-spacerun:yes'>&nbsp;&nbsp; </span>（True / False）</td>
  <td class=xl69>True</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>elk_prefix</td>
  <td>Logging index<span style='mso-spacerun:yes'>&nbsp;</span></td>
  <td class=xl69>logstash<span style='mso-spacerun:yes'>&nbsp;</span></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>keep_log_days</td>
  <td>Log retention time (days)</td>
  <td class=xl69>7</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>metrics_server_enable</td>
  <td>whether to install metrics_server<span style='mso-spacerun:yes'>&nbsp;&nbsp;&nbsp;
  </span>（True / False）</td>
  <td class=xl69>True</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>istio_enable</td>
  <td>whether to install Istio<span
  style='mso-spacerun:yes'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span>（True / False）</td>
  <td class=xl69>True</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td rowspan=2 height=36 class=xl68 style='height:27.6pt'>persistence</td>
  <td class=xl66>enable</td>
  <td>Whether the persistent storage server is enabled<span style='mso-spacerun:yes'>&nbsp;&nbsp; </span>（True / False）（It is recommended tp enable persistent storage in a formal environment）</td>
  <td class=xl69></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td height=18 class=xl66 style='height:13.8pt'>storageClass</td>
  <td>Enabling persistent storage requires that the storageClass has been created already in the cluster (The default value is empty, which means it'll use default StorageClass)</td>
  <td class=xl69>“”</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>containersLogMountedPath（Optional）</td>
  <td>Mount path of container logs</td>
  <td class=xl69>"/var/lib/docker/containers"</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>external_es_url（Optional）</td>
  <td>External Elasticsearch address, it supports integrate your external ES or install internal ES directly. If you have ES, you can directly integrate it into KubeSphere</td>
  <td class=xl69></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>external_es_port（Optional）</td>
  <td>External ES port, supports integrate external ES</td>
  <td class=xl69></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>local_registry (Offline installation only)</td>
  <td>Integrate with the local repository when deploy on offline environment（To use this parameter, import the installation image into the local repository using "scripts/downloader-docker-images.sh"）</td>
  <td class=xl69></td>
 </tr>
 <![if supportMisalignedColumns]>
 <tr height=0 style='display:none'>
  <td width=112 style='width:84pt'></td>
  <td width=156 style='width:117pt'></td>
  <td width=757 style='width:568pt'></td>
  <td width=339 style='width:254pt'></td>
 </tr>
 <![endif]>
</table>

## Quick Start Guide

[10 Quick Start guides of KubeSphere](https://github.com/kubesphere/kubesphere.github.io/tree/master/blog/advanced-2.0/en)

## Support, Discussion, and Community

If you need any help with KubeSphere, please join us at [Slack Channel](https://join.slack.com/t/kubesphere/shared_invite/enQtNTE3MDIxNzUxNzQ0LTZkNTdkYWNiYTVkMTM5ZThhODY1MjAyZmVlYWEwZmQ3ODQ1NmM1MGVkNWEzZTRhNzk0MzM5MmY4NDc3ZWVhMjE).


## Installer RoadMap

- Support multiple public cloud and private cloud, network plug-ins and storage plug-ins.
- All components are designed to be loosely-coupled, and all features are pluggable. Installation will become very light and fast.
