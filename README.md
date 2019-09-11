# Install KubeSphere on Existing Kubernetes Cluster

> English | [中文](README_zh.md)

In addition to supporting deploy on VM and BM, KubeSphere also supports installing on cloud-hosted and on-premises Kubernetes clusters,
 
Requirements

- Kubernetes Version: **1.13.0+**
- Helm Version: **2.10.0+**

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
$ kubectl -n kubesphere-system create secret generic kubesphere-ca  \
--from-file=ca.crt=/etc/kubernetes/pki/ca.crt  \
--from-file=ca.key=/etc/kubernetes/pki/ca.key 
```

 - If the ETCD has been not configured with certificates.

```bash
$ kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs
```

4. Then we can start to install KubeSphere.

```bash
$ cd deploy

$ vim kubesphere.yaml   
# According to the parameter table at the bottom, replace the value of "kubesphere-config" in "kubesphere.yaml" file with your current Kubernetes cluster parameters (If the ETCD has no certificate, set etcd_tls_enable: False).

$ kubectl apply -f kubesphere.yaml
```

5. Inspect the logs of installation.

```bash
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l job-name=kubesphere-installer -o jsonpath='{.items[0].metadata.name}') -f
```

6. Finally, you can access the Web UI via `IP:NodePort`, the default account is `admin/P@88w0rd`.

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

