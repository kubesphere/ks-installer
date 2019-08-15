# KubeSphere Installer

&ensp;&ensp;&ensp;&ensp;该项目支持在已有kubernetes集群之上部署[KubeSphere](https://kubesphere.io/)。

Requirements
------------
-   **kubernetes version: 1.13.0+**
-   **helm version: 2.10.0+**
> 注：
  1. 请确保集群中剩余可用内存  >10G
  2. 建议使用持久化存储

Deploy
------------
1. 集群中创建名为kubesphere-system和kubesphere-monitoring-system的namespace
   ```
   cat <<EOF | kubectl create -f -
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
2. 创建集群ca证书secret
   >注：按照当前集群ca.crt和ca.key证书路径创建（kubeadm创建集群的证书路径一般为/etc/kubernetes/pki）
   ```
   kubectl -n kubesphere-system create secret generic kubesphere-ca  \
   --from-file=ca.crt=/etc/kubernetes/pki/ca.crt  \
   --from-file=ca.key=/etc/kubernetes/pki/ca.key 
   ```
3. 创建etcd证书secret
   >注：以集群实际etcd证书位置创建；若etcd没有配置证书，则创建空secret
   ```
   kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs  \
   --from-file=etcd-client-ca.crt=/etc/ssl/etcd/ssl/ca.pem  \
   --from-file=etcd-client.crt=/etc/ssl/etcd/ssl/admin-node1.pem  \
   --from-file=etcd-client.key=/etc/ssl/etcd/ssl/admin-node1-key.pem
   ```
   etcd没有配置证书
   ```
   kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs
   ```

4. 部署
   ```
   cd deploy

   vim kubesphere.yaml   ## 根据参数说明编辑kubesphere.yaml中kubesphere-config为当前集群参数信息。（若etcd无证书，设置etcd_tls_enable: False）
   
   kubectl apply -f kubesphere.yaml
   ```
5. 部署日志查看
   ```
   kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l job-name=kubesphere-installer -o jsonpath='{.items[0].metadata.name}') -f
   ```


Configuration 
------------
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
  <td class=xl69>“”</td>
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


离线部署
------------
1. 下载镜像包并解压
   ```
   wget https://kubesphere-installer.pek3b.qingstor.com/ks-only/kubesphere-images-advanced-2.0.2.tar.gz

   tar -zxvf kubesphere-images-advanced-2.0.2.tar.gz
   ```
2. 导入镜像（镜像包较大，导入时间较久）
   ```
   docker load < kubesphere-images-advanced-2.0.2.tar
   ```
3. 将安装所需镜像导入本地镜像仓库
   ```
   cd scripts
   ./download-docker-images.sh  仓库地址

   注：“仓库地址” 请替换为本地镜像仓库地址，例：

   ./download-docker-images.sh  192.168.1.2:5000
   ```
4. 替换deploy/kubesphere-installer.yaml中镜像
   >注：以下命令中192.168.1.2:5000/kubespheredev/ks-installer:advanced-2.0.2为示例镜像，执行时请替换。
   ```
   sed -i 's|kubespheredev/ks-installer:advanced-2.0.2|192.168.1.2:5000/kubespheredev/ks-installer:advanced-2.0.2|g' deploy/kubesphere-installer.yaml
   ```
5. 按Deploy中步骤执行安装

