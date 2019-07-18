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
3. 创建集群front-proxy-client证书secret
   >注：按照当前集群front-proxy-client.crt和front-proxy-client.key证书路径创建（kubeadm创建集群的证书路径一般为/etc/kubernetes/pki）
   ```
   kubectl -n kubesphere-system create secret generic front-proxy-client  \
   --from-file=front-proxy-client.crt=/etc/kubernetes/pki/front-proxy-client.crt  \
   --from-file=front-proxy-client.key=/etc/kubernetes/pki/front-proxy-client.key
4. 创建etcd证书secret
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

5. 部署installer job
   ```
   cd deploy

   vim kubesphere-installer.yaml   ## 根据参数说明编辑kubesphere-installer.yaml中kubesphere-config为当前集群参数信息。（若etcd无证书，设置etcd_tls_enable: False）
   
   kubectl apply -f kubesphere-installer.yaml
   ```
   部署日志查看:
   ```
   kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l job-name=kubesphere-installer -o jsonpath='{.items[0].metadata.name}') -f
   ```
Configuration 
------------
| Parameter                            | Description                                      | Default                                                 |
| ------------------------------------ | ------------------------------------------------ | ------------------------------------------------------- |
|      kube_apiserver_host             |     当前集群kube-apiserver地址（ip:port）          |                                                        |
|      etcd_tls_enable                 |     是否开启etcd TLS证书认证（True / False）                       |  True                                                  |
|      etcd_endpoint_ips               |     etcd地址，如etcd为集群，地址以逗号分离（如：192.168.0.7,192.168.0.8,192.168.0.9）             |                                                        |
|      disableMultiLogin               |     是否关闭多点登录   （True / False）                            |  True                                                  |
|      elk_prefix                      |     日志索引                                      |  logstash                                                |
|      containersLogMountedPath（可选）        |     容器日志挂载路径                               | “”
|      external_es_url（可选）          |     外部es地址，支持对接外部es用                    |                                                       |
|      external_es_port（可选）         |     外部es端口，支持对接外部es用                    |                                                        | 