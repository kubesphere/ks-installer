# Install KubeSphere on Existing Kubernetes Cluster

> English | [中文](README_zh.md)

In addition to supporting deploy on VM and BM, KubeSphere also supports installing on cloud-hosted and on-premises Kubernetes clusters,

## Prerequisites

- Kubernetes Version: v1.13.0 ≤ K8s version < v1.16
- Helm Version: >= 2.10.0

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

4. (Optional) Check if there is default storage class in your class. This is not required, but it's highly recommended use a Persistent Volume (not local volume).
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

1. First, you need to create 2 namespaces in Kubernetes cluster, named `kubesphere-system` and `kubesphere-monitoring-system`.

```
$ cat <<EOF | kubectl create -f -
---
apiVersion: v1
kind: Namespace
metadata:
    name: kubesphere-system
---
apiVersion: v1
kind: Namespace
metadata:
    name: kubesphere-monitoring-system
EOF
```

2. Create the Secret of CA certificate of your current Kubernetes cluster.

> Note: Follow the certificate paths of `ca.crt` and `ca.key` of your current cluster to create this secret.

```bash
kubectl -n kubesphere-system create secret generic kubesphere-ca  \
--from-file=ca.crt=/etc/kubernetes/pki/ca.crt  \
--from-file=ca.key=/etc/kubernetes/pki/ca.key
```

3. Create the Secret of certificate for ETCD in your Kubernetes cluster.

> Note: Create with the actual ETCD certificate location of the cluster; If the ETCD does not have a configured certificate, an empty secret is created（The following command applies to the cluster created by Kubeadm）

> Note: Create the secret according to the your actual path of ETCD for the k8s cluster;

  - If the ETCD has been configured with certificates, refer to the following step:

```bash
$ kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs  \
--from-file=etcd-client-ca.crt=/etc/kubernetes/pki/etcd/ca.crt  \
--from-file=etcd-client.crt=/etc/kubernetes/pki/etcd/healthcheck-client.crt  \
--from-file=etcd-client.key=/etc/kubernetes/pki/etcd/healthcheck-client.key
```

 - If the ETCD has been not configured with certificates.

```bash
$ kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs
```

4. Clone kubesphere-installer to your local

```
$ git clone https://github.com/kubesphere/ks-installer.git
```

5. Then we can start to install KubeSphere.

```bash
$ cd deploy

$ vim kubesphere-installer.yaml
# According to the parameter table at the bottom, replace the value of "kubesphere-config" in "kubesphere.yaml" file with your current Kubernetes cluster parameters (If the ETCD has no certificate, set etcd_tls_enable: False).

$ kubectl apply -f kubesphere-installer.yaml
```

6. Inspect the logs of installation.

```bash
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l job-name=kubesphere-installer -o jsonpath='{.items[0].metadata.name}') -f
```

7. Finally, you can access the Web UI via `IP:NodePort`, the default account is `admin/P@88w0rd`.

```bash
$ kubectl get svc -n kubesphere-system
# Inspect the NodePort of ks-console, it's 30880 by default.
```

![](https://pek3b.qingstor.com/kubesphere-docs/png/20190912020300.png)

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
  <td colspan=2 height=18 style='height:13.8pt'>sonarqube_enable</td>
  <td>whether to install Sonarqube<span
  style='mso-spacerun:yes'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
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
