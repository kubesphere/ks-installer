# KubeSphere Installer

Requirements
------------
-   **kubernetes version > 1.13.0**
-   **helm version > 2.10.0**
-   **a default storage class must be in kubernetes cluster**
> 注：请确保集群中剩余可用内存  >16G

Deploy
------------
1. 集群中创建名为kubesphere-system和kubesphere-monitoring-system的namespace
   ```
   kubectl create ns kubesphere-system
   kubectl create ns kubesphere-monitoring-system
   ```
2. 创建集群ca证书secret
   >注：按照当前集群ca.crt和ca.key证书路径创建（kubeadm创建集群的证书路径一般为/etc/kubernetes/pki）
   ```
   kubectl -n kubesphere-system create secret generic kubesphere-ca  \
   --from-file=ca.crt=/etc/kubernetes/ssl/ca.crt  \
   --from-file=ca.key=/etc/kubernetes/ssl/ca.key 
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

4. 部署installer job
   ```
   cd deploy

   vim kubesphere-installer.yaml   ## 根据参数说明编辑kubesphere-installer.yaml中kubesphere-config为当前集群参数信息。（若etcd无证书，设置etcd_tls_enable: False）
   
   kubectl apply -f kubesphere-installer.yaml
   ```
5. 部署日志查看
   ```
   kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l job-name=kubesphere-installer -o jsonpath='{.items[0].metadata.name}') -f
   ```

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

Configuration 
------------
| Parameter                            | Description                                      | Default                                                 |
| ------------------------------------ | ------------------------------------------------ | ------------------------------------------------------- |
|      kube_apiserver_host             |     当前集群kube-apiserver地址（ip:port）          |                                                        |
|      etcd_tls_enable                 |     是否开启etcd TLS证书认证（True / False）                       |  True                                                  |
|      etcd_endpoint_ips               |     etcd地址，如etcd为集群，地址以逗号分离（如：192.168.0.7,192.168.0.8,192.168.0.9）             |                           |
|      disableMultiLogin               |     是否关闭多点登录   （True / False）                            |  True                                                  |
|      elk_prefix                      |     日志索引                                      |  logstash                                                |
|      keep_log_days                   |     日志保存时间（天）                                  |   7                                    |
|      metrics_server_enable            |    是否安装metrics_server    （True / False）                 |   True
|      istio_enable                    |     是否安装istio           （True / False）                   |   True
|      containersLogMountedPath（可选）        |     容器日志挂载路径                               | “”
|      external_es_url（可选）          |     外部es地址，支持对接外部es用                    |                                                       |
|      external_es_port（可选）         |     外部es端口，支持对接外部es用                    |                                                        | 
|      local_registry (离线部署使用)                 |     离线部署时，对接本地仓库 （使用该参数需将安装镜像使用scripts/download-docker-images.sh导入本地仓库中）                   |                                                        | 