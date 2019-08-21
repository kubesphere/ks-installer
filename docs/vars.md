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

<table>
 <tr>
  <td  colspan=2>Parameter</td>
  <td>Description</td>
  <td>Default</td>
 </tr>
 <tr>
  <td  colspan=2>kubeApiServerHost</td>
  <td>当前集群kube-apiserver地址（ip:port）</td>
  <td></td>
 </tr>
 <tr>
  <td  colspan=2>etcdTlsEnable</td>
  <td>是否开启etcd TLS证书认证（True / False）</td>
  <td>True</td>
 </tr>
 <tr>
  <td colspan=2>etcdEndPointIps</td>
  <td>etcd地址，如etcd为集群，地址以逗号分离（如：192.168.0.7,192.168.0.8,192.168.0.9）</td>
  <td></td>
 </tr>
 <tr>
  <td colspan=2>etcdPort</td>
  <td>etcd端口 (默认2379，如使用其它端口，请配置此参数)</td>
  <td>2379</td>
 </tr>
 <tr>
  <td colspan=2>metricsServerEnable</td>
  <td>是否安装metrics_server<span>&nbsp;&nbsp;&nbsp;
  </span>（True / False）</td>
  <td>True</td>
 </tr>
 <tr>
  <td rowspan=2>persistence</td>
  <td>enabled</td>
  <td>是否启用持久化存储<span>&nbsp;&nbsp; </span>（True /
  False）（非测试环境建议开启数据持久化）</td>
  <td></td>
 </tr>
 <tr>
  <td>storageClass</td>
  <td>启用持久化存储要求环境中存在已经创建好的storageClass（默认为空，使用default storageClass）</td>
  <td>“”</td>
 </tr>
 <tr>
  <td rowspan=3>ksCore</td>
  <td>disableMultiLogin<span>&nbsp;</span></td>
  <td>是否关闭多点登录<span>&nbsp;&nbsp; </span>（True / False）</td>
  <td>True</td>
 </tr>
 <tr>
  <td>ingress.enable</td>
  <td>是否为kubesphere<span>&nbsp;
  </span>console创建ingress<span>&nbsp; </span>（True /
  False）</td>
  <td>False</td>
 </tr>
 <tr>
  <td>ingress.hosts</td>
  <td>kubesphere<span>&nbsp; </span>console访问域名</td>
  <td>console.kubesphere.local</td>
 </tr>
 <tr>
  <td rowspan=3>monitoring</td>
  <td>enable</td>
  <td>是否启用监控组件prometheus<span>&nbsp;&nbsp;
  </span>（True / False）</td>
  <td>True</td>
 </tr>
 <tr>
  <td>prometheusReplica</td>
  <td>prometheus副本数</td>
  <td>2</td>
 </tr>
 <tr>
  <td>prometheusVolumeSize</td>
  <td>prometheus持久化存储空间</td>
  <td>20Gi</td>
 </tr>
 <tr>
  <td rowspan=7>logging</td>
  <td>enable</td>
  <td>是否启用日志组件elasticsearch<span>&nbsp;&nbsp;
  </span>（True / False）</td>
  <td>True</td>
 </tr>
 <tr>
  <td>elkPrefix</td>
  <td>日志索引<span>&nbsp;</span></td>
  <td>logstash<span>&nbsp;</span></td>
 </tr>
 <tr>
  <td>keepLogDays</td>
  <td>日志留存时间（天）</td>
  <td>7</td>
 </tr>
 <tr>
  <td>elasticsearchVolumeSize</td>
  <td>elasticsearch持久化存储空间</td>
  <td>20Gi</td>
 </tr>
 <tr>
  <td>containersLogMountedPath</td>
  <td>容器日志挂载路径</td>
  <td>“”</td>
 </tr>
 <tr>
  <td>externalElasticsearchUrl（可选）</td>
  <td>外部es地址，支持对接外部es用</td>
  <td></td>
 </tr>
 <tr>
  <td>externalElasticsearchPort（可选）</td>
  <td>外部es端口，支持对接外部es用</td>
  <td></td>
 </tr>
 <tr>
  <td>openPitrix</td>
  <td>enable</td>
  <td>是否启用应用管理组件openpitrix<span>&nbsp;&nbsp;
  </span>（True / False）</td>
  <td>False</td>
 </tr>
 <tr>
  <td>devOps</td>
  <td>enable</td>
  <td>是否启用DevOps功能<span>&nbsp; </span>（True / False）</td>
  <td>False</td>
 </tr>
 <tr>
  <td>microService</td>
  <td>enable</td>
  <td>是否启用微服务治理功能<span>&nbsp; </span>（True / False）</td>
  <td>False</td>
 </tr>
 <tr>
  <td>noticeAndAlarm</td>
  <td>enable</td>
  <td>是否启用通知告警功能<span>&nbsp; </span>（True / False）</td>
  <td>False</td>
 </tr>
 <tr>
  <td colspan=2>local_registry (离线部署使用)</td>
  <td>离线部署时，对接本地仓库 （使用该参数需将安装镜像使用scripts/download-docker-images.sh导入本地仓库中）</td>
  <td></td>
 </tr>
</table>