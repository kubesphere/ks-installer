# 在 Kubernetes 集群在线部署 KubeSphere

> [English](README.md) | 中文

KubeSphere 支持在已有 Kubernetes 集群之上部署 [KubeSphere](https://kubesphere.io/)。

## 准备工作

1. 确认现有的 `Kubernetes` 版本为 `1.15.x, 1.16.x, 1.17.x`，可以执行 `kubectl version` 来确认 :

```bash
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.1", GitCommit:"4485c6f18cee9a5d3c3b4e523bd27972b1b53892", GitTreeState:"clean", BuildDate:"2019-07-18T09:09:21Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.1", GitCommit:"4485c6f18cee9a5d3c3b4e523bd27972b1b53892", GitTreeState:"clean", BuildDate:"2019-07-18T09:09:21Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
```

注意输出结果中的 `Server Version` 这行，如果显示 `GitVersion` 大于 `v1.15.0`，Kubernetes 的版本是可以安装的。如果低于 `v1.15.0`，可以先对 K8s 版本进行升级。

2. 确认已安装 `Helm`，且 `2.10.0` ≤ Helm version < `3.0`。在终端执行 `helm version`，得到类似下面的输出：

> 注: helm v2.16.0 以及 v2.16.5 存在已知问题，如果已安装该版本，建议升级或更换其他版本。

```bash
$ helm version
Client: &version.Version{SemVer:"v2.13.1", GitCommit:"618447cbf203d147601b4b9bd7f8c37a5d39fbb4", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.13.1", GitCommit:"618447cbf203d147601b4b9bd7f8c37a5d39fbb4", GitTreeState:"clean"}
```

如果提示 `helm: command not found`, 表示还未安装 `Helm`。参考这篇 [Install Helm](https://helm.sh/docs/using_helm/#from-the-binary-releases) 安装 `Helm`, 安装完成后执行  `helm init` .

如果 `helm` 的版本比较老 (<2.10.0), 需要先升级，参考 [Upgrading Tiller](https://github.com/helm/helm/blob/master/docs/install.md#upgrading-tiller) 升级

3. 集群现有的可用内存至少在 `10G` 以上。 如果是执行的 `allinone` 安装，那么执行 `free -g` 可以看下可用资源

```bash
$ free -g
              total        used        free      shared  buff/cache   available
Mem:              16          4          10           0           3           2
Swap:             0           0           0
```

4. KubeSphere 需配合持久化存储使用，执行`kubectl get sc` 查看当前环境中的存储类型 (当使用默认存储类型时，配置文件中可以不填存储相关信息).

```bash
$ kubectl get sc
NAME                      PROVISIONER               AGE
ceph                      kubernetes.io/rbd         3d4h
csi-qingcloud (default)   disk.csi.qingcloud.com    54d
glusterfs                 kubernetes.io/glusterfs   3d4h
```

5. CSR signing 功能在 kube-apiserver 中被激活，参考 [RKE installation issue](https://github.com/kubesphere/kubesphere/issues/1925#issuecomment-591698309)。

如果你的 Kubernetes 环境满足以上的要求，那么可以接着执行下面的步骤了。

## 部署 KubeSphere

### 最小化快速部署

```bash
 $ kubectl apply -f https://raw.githubusercontent.com/kubesphere/ks-installer/master/kubesphere-minimal.yaml

 # 查看部署进度及日志
 $ kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f
```

部署完成后可执行如下命令查看控制台的服务端口，使用 `IP:consolePort(default: 30880)` 访问 KubeSphere UI 界面，默认的集群管理员账号为 `admin/P@88w0rd`。

```bash
kubectl get svc/ks-console -n kubesphere-system
```

![Dashboard](https://pek3b.qingstor.com/kubesphere-docs/png/20190912002602.png)

以上为最小化部署，如需开启更多功能，请参考如下步骤配置相关依赖：

### 安装功能组件

1. [可选项] 创建集群 Etcd 的证书 Secret。(仅开启 Etcd 监控需要设置)

> 注：根据集群实际 Etcd 证书位置创建；

- 若 Etcd 已经配置过证书，则参考如下创建（以下命令适用于 Kubeadm 创建的 Kubernetes 集群环境）：

```bash
$ kubectl create ns kubesphere-monitoring-system
$ kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs  \
--from-file=etcd-client-ca.crt=/etc/kubernetes/pki/etcd/ca.crt  \
--from-file=etcd-client.crt=/etc/kubernetes/pki/etcd/healthcheck-client.crt  \
--from-file=etcd-client.key=/etc/kubernetes/pki/etcd/healthcheck-client.key
```

- 若 Etcd 没有配置证书，则创建空 Secret：

```bash
kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs
```

2. 编辑 configmap 开启相关功能:

```bash
kubectl edit cm ks-installer -n kubesphere-system
```

> 按功能需求编辑配置文件之后，退出等待生效即可，如长时间未生效请使用如下命令查看相关日志:

```bash
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f
```

## 升级

1. 获取 2.1.1 的 Yaml 文件，若服务器提示无法访问 GitHub，可以将静态文件拷贝至服务器执行。

```bash
wget https://raw.githubusercontent.com/kubesphere/ks-installer/master/kubesphere-minimal.yaml
```

2. 编辑 `kubesphere-minimal.yaml` 中 config 部分，与旧版本的存储类型配置与组件开启状态等配置需保持一致。确认配置同步后，使用 kubectl 执行如下命令进行升级。

```bash
kubectl apply -f kubesphere-minimal.yaml
```

> 提示：不再提供 Harbor、Gitlab 部署，如需要相关功能，建议通过 [Harbor](https://github.com/goharbor/harbor-helm)，[Gitlab](https://about.gitlab.com/install/)官方文档进行部署。

## 参数说明

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
  <td class=xl1519753>存储类型，不填则使用默认存储类型(sc)</td>
  <td class=xl6519753>“”</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td rowspan=4 height=84 class=xl6719753 style='height:62.4pt'>etcd</td>
  <td class=xl6719753>monitoring</td>
  <td class=xl1519753>是否开启etcd监控</td>
  <td class=xl6519753>False</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>endpointIps</td>
  <td class=xl1519753>etcd地址，如etcd为集群，地址以逗号分离（如：192.168.0.7,192.168.0.8,192.168.0.9）</td>
  <td class=xl6519753></td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>port</td>
  <td class=xl1519753>etcd端口 (默认2379，如使用其它端口，请配置此参数)</td>
  <td class=xl6519753>2379</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>tlsEnable</td>
  <td class=xl1519753>是否开启etcd TLS证书认证（True / False）</td>
  <td class=xl6519753>True</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td rowspan=5 height=105 class=xl6719753 style='height:78.0pt'>common</td>
  <td class=xl6719753>mysqlVolumeSize</td>
  <td class=xl1519753>mysql存储卷大小，设置后不可修改</td>
  <td class=xl6519753>20Gi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>minioVolumeSize</td>
  <td class=xl1519753>minio存储卷大小，设置后不可修改</td>
  <td class=xl6519753>20Gi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>etcdVolumeSize</td>
  <td class=xl1519753>etcd存储卷大小，设置后不可修改</td>
  <td class=xl6519753>20Gi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>openldapVolumeSize</td>
  <td class=xl1519753>openldap存储卷大小，设置后不可修改</td>
  <td class=xl6519753>2Gi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>redisVolumSize</td>
  <td class=xl1519753>redis存储卷大小，设置后不可修改</td>
  <td class=xl6519753>2Gi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td rowspan=2 height=42 class=xl6719753 style='height:31.2pt'>console</td>
  <td class=xl6719753>enableMultiLogin</td>
  <td class=xl1519753>是否启动多点登录 （True / False）</td>
  <td class=xl6519753>False</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>port</td>
  <td class=xl1519753>console登录端口 （NodePort）</td>
  <td class=xl6519753>30880</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td rowspan=4 height=84 class=xl6719753 style='height:62.4pt'>monitoring</td>
  <td class=xl6719753>prometheusReplicas</td>
  <td class=xl1519753>prometheus副本数</td>
  <td class=xl6519753>1</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>prometheusMemoryRequest</td>
  <td class=xl1519753>prometheus内存请求空间</td>
  <td class=xl6519753>400Mi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>prometheusVolumeSize</td>
  <td class=xl1519753>prometheus持久化存储空间</td>
  <td class=xl6519753>20Gi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>grafana.enabled</td>
  <td class=xl1519753>是否开启grafana （True / False）</td>
  <td class=xl6519753>False</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td rowspan=9 height=189 class=xl6619753 style='height:140.4pt'>logging </br> (至少 56 M, 2.76 G)</td>
  <td class=xl6719753>enabled</td>
  <td class=xl1519753>是否启用日志组件elasticsearch<span
  style='mso-spacerun:yes'>&nbsp;&nbsp; </span>（True / False）</td>
  <td class=xl6519753>False</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>elasticsearchMasterReplicas</td>
  <td class=xl1519753>elasticsearch主节点副本数</td>
  <td class=xl6519753>1</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>elasticsearchDataReplicas</td>
  <td class=xl1519753>elasticsearch数据节点副本数</td>
  <td class=xl6519753>1</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>logsidecarReplicas</td>
  <td class=xl1519753>日志sidecar副本数</td>
  <td class=xl6519753>2</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>elasticsearchVolumeSize</td>
  <td class=xl1519753>elasticsearch数据盘尺寸</td>
  <td class=xl6519753>20Gi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>logMaxAge</td>
  <td class=xl1519753>日志留存时间（天）</td>
  <td class=xl6519753>7</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>elkPrefix</td>
  <td class=xl1519753>日志索引<span style='mso-spacerun:yes'>&nbsp;</span></td>
  <td class=xl6519753>logstash<span style='mso-spacerun:yes'>&nbsp;</span></td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>containersLogMountedPath</td>
  <td class=xl1519753>容器日志挂载路径</td>
  <td class=xl6519753>“”</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>kibana.enabled</td>
  <td class=xl1519753>是否启动kibana<span style='mso-spacerun:yes'>&nbsp;
  </span>（True / False）</td>
  <td class=xl6519753>False</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td rowspan=8 height=168 class=xl6619753 style='height:124.8pt'>devops </br>(集群的可用资源至少 0.47 core, 8.6 G )</td>
  <td class=xl6719753>enabled</td>
  <td class=xl1519753>是否启用DevOps功能<span style='mso-spacerun:yes'>&nbsp;
  </span>（True / False）</td>
  <td class=xl6519753>False</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>jenkinsMemoryLim</td>
  <td class=xl1519753>jenkins内存限制</td>
  <td class=xl6519753>2Gi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>jenkinsMemoryReq</td>
  <td class=xl1519753>jenkins内存请求</td>
  <td class=xl6519753>1500Mi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>jenkinsVolumeSize</td>
  <td class=xl1519753>jenkins持久化存储空间</td>
  <td class=xl6519753>8Gi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>jenkinsJavaOpts_Xms</td>
  <td class=xl1519753>jenkins<span style='mso-spacerun:yes'>&nbsp;
  </span>jvm参数（Xms）</td>
  <td class=xl6519753>512m</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>jenkinsJavaOpts_Xmx</td>
  <td class=xl1519753>jenkins<span style='mso-spacerun:yes'>&nbsp;
  </span>jvm参数（Xmx）</td>
  <td class=xl6519753>512m</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>jenkinsJavaOpts_MaxRAM</td>
  <td class=xl1519753>jenkins<span style='mso-spacerun:yes'>&nbsp;
  </span>jvm参数（MaxRAM）</td>
  <td class=xl6519753>2Gi</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>sonarqube.enabled</td>
  <td class=xl1519753>是否启用 SonarQube 的安装（True / False）</td>
  <td class=xl6519753>False</td>
 </tr>
  <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>openpitrix </br>(至少 0.3 core, 300 MiB)</td>
  <td class=xl6719753>enable</td>
  <td class=xl1519753>平台的应用商店与应用模板、应用管理都基于 OpenPitrix，建议开启安装（True / False）</td>
  <td class=xl6519753>False</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6719753 style='height:15.6pt'>metrics_server </br>(至少 5 m, 44.35 MiB)</td>
  <td class=xl6719753>enabled</td>
  <td class=xl1519753>是否安装metrics_server<span
  style='mso-spacerun:yes'>&nbsp;&nbsp;&nbsp; </span>（True / False）</td>
  <td class=xl6519753>False</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6619753 style='height:15.6pt'>servicemesh </br>(至少 2 core, 3.6 G)</td>
  <td class=xl6719753>enabled</td>
  <td class=xl1519753>是否启用微服务治理功能<span style='mso-spacerun:yes'>&nbsp;
  </span>（True / False）</td>
  <td class=xl6519753>False</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6619753 style='height:15.6pt'>notification </br>(Notification 和 Alerting 一共至少需要 0.08 core, 80 M) </td>
  <td class=xl6719753>enabled</td>
  <td class=xl1519753>是否启用通知功能 （True / False）</td>
  <td class=xl6519753>False</td>
 </tr>
 <tr height=21 style='height:15.6pt'>
  <td height=21 class=xl6619753 style='height:15.6pt'>alerting</td>
  <td class=xl6719753>enabled</td>
  <td class=xl1519753>是否启用告警功能 （True / False）</td>
  <td class=xl6519753>False</td>
 </tr>
 <![if supportMisalignedColumns]>
 <tr height=0 style='display:none'>
  <td width=202 style='width:152pt'></td>
  <td width=232 style='width:174pt'></td>
  <td width=595 style='width:446pt'></td>
  <td width=259 style='width:194pt'></td>
 </tr>
 <![endif]>
</table>

## 未来计划

- 组件解耦，做成可插拔式的设计，使安装更轻量，资源消耗率更低。
