# Configurable Parameters in KubeSphere

ConfigMap 
------------
```
apiVersion: v1
data:
  ks-config.yaml: |
    kubeApiServerHost: 192.168.0.2:6443
    etcdTlsEnable: True
    etcdEndPointIps: 192.168.0.2
    etcdPort: 2379
    metricsServerEnable: True
    persistence:
      enable: false
      storageClass: ""
    ksCore:
      disableMultiLogin: True
      ingress:
        enable: False
        hosts: console.kubesphere.local
    monitoring:
      enable: True
      prometheusReplica: 2
      prometheusVolumeSize: 20Gi
    logging:
      enable: True
      elkPrefix: logstash
      keepLogDays: 7
      elasticsearchVolumeSize: 20Gi
      containersLogMountedPath: ""
    # externalElasticsearchUrl:
    # externalElasticsearchPort: 
    openPitrix:
      enable: False
    devOps:
      enable: False
    microService:
      enable: False
    noticeAndAlarm:
      enable: False
kind: ConfigMap
metadata:
  name: kubesphere-config
  namespace: kubesphere-system
```
Description 
------------

<table border=0 cellpadding=0 cellspacing=0 width=1550 style='border-collapse:
 collapse;table-layout:fixed;width:1162pt'>
 <col width=232 style='mso-width-source:userset;mso-width-alt:8248;width:174pt'>
 <col width=222 style='mso-width-source:userset;mso-width-alt:7879;width:166pt'>
 <col width=757 style='mso-width-source:userset;mso-width-alt:26908;width:568pt'>
 <col class=xl68 width=339 style='mso-width-source:userset;mso-width-alt:12060;
 width:254pt'>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 width=454 style='height:13.8pt;width:340pt'>Parameter</td>
  <td width=757 style='width:568pt'>Description</td>
  <td width=339 style='width:254pt'>Default</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>kubeApiServerHost</td>
  <td>当前集群kube-apiserver地址（ip:port）</td>
  <td></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>etcdTlsEnable</td>
  <td>是否开启etcd TLS证书认证（True / False）</td>
  <td class=xl68>True</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 class=xl65 style='height:13.8pt'>etcdEndPointIps</td>
  <td>etcd地址，如etcd为集群，地址以逗号分离（如：192.168.0.7,192.168.0.8,192.168.0.9）</td>
  <td class=xl68></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>etcdPort</td>
  <td>etcd端口 (默认2379，如使用其它端口，请配置此参数)</td>
  <td class=xl68>2379</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 class=xl67 style='height:13.8pt'>metricsServerEnable</td>
  <td>是否安装metrics_server<span style='mso-spacerun:yes'>&nbsp;&nbsp;&nbsp;
  </span>（True / False）</td>
  <td class=xl68>True</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td rowspan=2 height=36 class=xl66 style='height:27.6pt'>persistence</td>
  <td class=xl65>enabled</td>
  <td>是否启用持久化存储<span style='mso-spacerun:yes'>&nbsp;&nbsp; </span>（True /
  False）（非测试环境建议开启数据持久化）</td>
  <td class=xl68></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td height=18 class=xl65 style='height:13.8pt'>storageClass</td>
  <td>启用持久化存储要求环境中存在已经创建好的storageClass（默认为空，使用default storageClass）</td>
  <td class=xl68>“”</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td rowspan=3 height=54 class=xl66 style='height:41.4pt'>ksCore</td>
  <td>disableMultiLogin<span style='mso-spacerun:yes'>&nbsp;</span></td>
  <td>是否关闭多点登录<span style='mso-spacerun:yes'>&nbsp;&nbsp; </span>（True / False）</td>
  <td class=xl68>True</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td height=18 style='height:13.8pt'>ingress.enable</td>
  <td>是否为kubesphere<span style='mso-spacerun:yes'>&nbsp;
  </span>console创建ingress<span style='mso-spacerun:yes'>&nbsp; </span>（True /
  False）</td>
  <td class=xl68>False</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td height=18 style='height:13.8pt'>ingress.hosts</td>
  <td>kubesphere<span style='mso-spacerun:yes'>&nbsp; </span>console访问域名</td>
  <td class=xl68>console.kubesphere.local</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td rowspan=3 height=54 class=xl66 style='height:41.4pt'>monitoring</td>
  <td>enable</td>
  <td>是否启用监控组件prometheus<span style='mso-spacerun:yes'>&nbsp;&nbsp;
  </span>（True / False）</td>
  <td class=xl68>True</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td height=18 style='height:13.8pt'>prometheusReplica</td>
  <td>prometheus副本数</td>
  <td class=xl68>2</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td height=18 style='height:13.8pt'>prometheusVolumeSize</td>
  <td>prometheus持久化存储空间</td>
  <td class=xl68>20Gi</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td rowspan=7 height=126 class=xl66 style='height:96.6pt'>logging</td>
  <td>enable</td>
  <td>是否启用日志组件elasticsearch<span style='mso-spacerun:yes'>&nbsp;&nbsp;
  </span>（True / False）</td>
  <td class=xl68>True</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td height=18 style='height:13.8pt'>elkPrefix</td>
  <td>日志索引<span style='mso-spacerun:yes'>&nbsp;</span></td>
  <td class=xl68>logstash<span style='mso-spacerun:yes'>&nbsp;</span></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td height=18 style='height:13.8pt'>keepLogDays</td>
  <td>日志留存时间（天）</td>
  <td class=xl68>7</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td height=18 style='height:13.8pt'>elasticsearchVolumeSize</td>
  <td>elasticsearch持久化存储空间</td>
  <td class=xl68>20Gi</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td height=18 style='height:13.8pt'>containersLogMountedPath</td>
  <td>容器日志挂载路径</td>
  <td class=xl68>“”</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td height=18 style='height:13.8pt'>externalElasticsearchUrl（可选）</td>
  <td>外部es地址，支持对接外部es用</td>
  <td class=xl68></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td height=18 style='height:13.8pt'>externalElasticsearchPort（可选）</td>
  <td>外部es端口，支持对接外部es用</td>
  <td class=xl68></td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td height=18 style='height:13.8pt'>openPitrix</td>
  <td>enable</td>
  <td>是否启用应用管理组件openpitrix<span style='mso-spacerun:yes'>&nbsp;&nbsp;
  </span>（True / False）</td>
  <td class=xl68>False</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td height=18 style='height:13.8pt'>devOps</td>
  <td>enable</td>
  <td>是否启用DevOps功能<span style='mso-spacerun:yes'>&nbsp; </span>（True / False）</td>
  <td class=xl68>False</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td height=18 style='height:13.8pt'>microService</td>
  <td>enable</td>
  <td>是否启用微服务治理功能<span style='mso-spacerun:yes'>&nbsp; </span>（True / False）</td>
  <td class=xl68>False</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td height=18 style='height:13.8pt'>noticeAndAlarm</td>
  <td>enable</td>
  <td>是否启用通知告警功能<span style='mso-spacerun:yes'>&nbsp; </span>（True / False）</td>
  <td class=xl68>False</td>
 </tr>
 <tr height=18 style='height:13.8pt'>
  <td colspan=2 height=18 style='height:13.8pt'>local_registry (离线部署使用)</td>
  <td>离线部署时，对接本地仓库 （使用该参数需将安装镜像使用scripts/download-docker-images.sh导入本地仓库中）</td>
  <td class=xl68></td>
 </tr>
 <![if supportMisalignedColumns]>
 <tr height=0 style='display:none'>
  <td width=232 style='width:174pt'></td>
  <td width=222 style='width:166pt'></td>
  <td width=757 style='width:568pt'></td>
  <td width=339 style='width:254pt'></td>
 </tr>
 <![endif]>
</table>