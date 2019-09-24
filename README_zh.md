# 在 Kubernetes 集群在线部署 KubeSphere

> [English](README.md) | 中文 

KubeSphere 支持在已有 Kubernetes 集群之上部署 [KubeSphere](https://kubesphere.io/)。

## 前提条件

- Kubernetes 版本: **1.13.0+**
- Helm 版本: **2.10.0+**

> 注：
> - 请确保集群中**剩余可用内存 > 10G**；
> - 建议使用持久化存储。

## 部署 KubeSphere

1. 在 Kubernetes 集群中创建名为 `kubesphere-system` 和 `kubesphere-monitoring-system` 的 `namespace`。

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

2. 创建 Kubernetes 集群 CA 证书的 Secret。

> 注：按照当前集群 ca.crt 和 ca.key 证书路径创建（Kubeadm 创建集群的证书路径一般为 `/etc/kubernetes/pki`）

```bash
$ kubectl -n kubesphere-system create secret generic kubesphere-ca  \
--from-file=ca.crt=/etc/kubernetes/pki/ca.crt  \
--from-file=ca.key=/etc/kubernetes/pki/ca.key 
```

3. 创建集群 etcd 的证书 Secret。

> 注：根据集群实际 etcd 证书位置创建；

   - 若 etcd 已经配置过证书，则参考如下创建：

```
$ kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs  \
--from-file=etcd-client-ca.crt=/etc/kubernetes/pki/etcd/ca.crt  \
--from-file=etcd-client.crt=/etc/kubernetes/pki/etcd/healthcheck-client.crt  \
--from-file=etcd-client.key=/etc/kubernetes/pki/etcd/healthcheck-client.key
```

- 若 etcd 没有配置证书，则创建空 Secret（以下命令适用于 Kubeadm 创建的 Kubernetes 集群环境）：

- It will create an empty Secret if the ETCD doesn'st have a configured certificate (The following command has been tested in the Kubernetes created by Kubeadm)

```
$ kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs
```

4. 克隆 kubesphere-installer 仓库至本地。

```
$ git clone https://github.com/kubesphere/ks-installer.git
```

5. 进入 ks-installer，然后在 Kubernetes 集群部署 KubeSphere。


```
$ cd deploy

$ vim kubesphere.yaml   
# 根据下方的参数说明列表，编辑 kubesphere.yaml 中 kubesphere-config 为当前集群参数信息（若etcd 无证书，设置 etcd_tls_enable: False）。

$ kubectl apply -f kubesphere.yaml
```

6. 查看部署日志。

```
$ kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l job-name=kubesphere-installer -o jsonpath='{.items[0].metadata.name}') -f
```

7. 查看控制台的服务端口，使用 `IP:30880` 访问 KubeSphere UI 界面，默认的集群管理员账号为 `admin/P@88w0rd`。

```
$ kubectl get svc -n kubesphere-system    
# 查看 ks-console 服务的端口  默认为 NodePort: 30880
```

![](https://pek3b.qingstor.com/kubesphere-docs/png/20190912002602.png)

## 参数说明

<table border=0 cellpadding=0 cellspacing=0 width=1364 style='border-collapse:
 collapse;table-layout:fixed;width:1023pt;font-variant-ligatures: normal;
 font-variant-caps: normal;orphans: 2;text-align:start;widows: 2;-webkit-text-stroke-width: 0px;
 text-decoration-style: initial;text-decoration-color: initial'>
 <col width=112 style='mso-width-source:userset;mso-width-alt:3982;width:84pt'>
 <col width=156 style='mso-width-source:userset;mso-width-alt:5546;width:117pt'>
 <col width=757 style='mso-width-source:userset;mso-width-alt:26908;width:568pt'>
 <col width=339 style='mso-width-source:userset;mso-width-alt:12060;width:254pt'>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 class=xl67 width=268 style='height:13.8pt;width:201pt'>参数</td>
  <td class=xl65 width=757 style='width:568pt'><span style='font-variant-ligatures: normal;
  font-variant-caps: normal;orphans: 2;widows: 2;-webkit-text-stroke-width: 0px;
  text-decoration-style: initial;text-decoration-color: initial'>描述</span></td>
  <td class=xl65 width=339 style='width:254pt'><span style='font-variant-ligatures: normal;
  font-variant-caps: normal;orphans: 2;widows: 2;-webkit-text-stroke-width: 0px;
  text-decoration-style: initial;text-decoration-color: initial'>默认值</span></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>kube_apiserver_host</td>
  <td>当前集群kube-apiserver地址（ip:port）</td>
  <td class=xl69></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>etcd_tls_enable</td>
  <td>是否开启etcd TLS证书认证（True / False）</td>
  <td class=xl69>True</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 class=xl66 style='height:13.8pt'>etcd_endpoint_ips</td>
  <td>etcd地址，如etcd为集群，地址以逗号分离（如：192.168.0.7,192.168.0.8,192.168.0.9）</td>
  <td class=xl69></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>etcd_port</td>
  <td>etcd端口 (默认2379，如使用其它端口，请配置此参数)</td>
  <td class=xl69>2379</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>disableMultiLogin<span
  style='mso-spacerun:yes'>&nbsp;</span></td>
  <td>是否关闭多点登录<span style='mso-spacerun:yes'>&nbsp;&nbsp; </span>（True / False）</td>
  <td class=xl69>True</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>elk_prefix</td>
  <td>日志索引<span style='mso-spacerun:yes'>&nbsp;</span></td>
  <td class=xl69>logstash<span style='mso-spacerun:yes'>&nbsp;</span></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>keep_log_days</td>
  <td>日志留存时间（天）</td>
  <td class=xl69>7</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>metrics_server_enable</td>
  <td>是否安装metrics_server<span style='mso-spacerun:yes'>&nbsp;&nbsp;&nbsp;
  </span>（True / False）</td>
  <td class=xl69>True</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>istio_enable</td>
  <td>是否安装istio<span
  style='mso-spacerun:yes'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </span>（True / False）</td>
  <td class=xl69>True</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td rowspan=2 height=36 class=xl68 style='height:27.6pt'>persistence</td>
  <td class=xl66>enable</td>
  <td>是否启用持久化存储<span style='mso-spacerun:yes'>&nbsp;&nbsp; </span>（True /
  False）（非测试环境建议开启数据持久化）</td>
  <td class=xl69></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td height=18 class=xl66 style='height:13.8pt'>storageClass</td>
  <td>启用持久化存储要求环境中存在已经创建好的storageClass（默认为空，使用default storageClass）</td>
  <td class=xl69>“”</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>containersLogMountedPath（可选）</td>
  <td>容器日志挂载路径</td>
  <td class=xl69>"/var/lib/docker/containers"</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>external_es_url（可选）</td>
  <td>外部es地址，支持对接外部es用</td>
  <td class=xl69></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>external_es_port（可选）</td>
  <td>外部es端口，支持对接外部es用</td>
  <td class=xl69></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>local_registry (离线部署使用)</td>
  <td>离线部署时，对接本地仓库 （使用该参数需将安装镜像使用scripts/download-docker-images.sh导入本地仓库中）</td>
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


## 未来计划

- 支持多个公有云的网络插件与存储插件；
- 组件解耦，做成可插拔式的设计，使安装更轻量，资源消耗率更低。
