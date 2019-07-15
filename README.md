# KubeSphere Installer

Requirements
------------
-   **kubernetes version > 1.13.0**
-   **helm version > 2.10.0**
-   **a default storage class must be in kubernetes cluster**

Deploy
------------
1. 集群中创建名为kubesphere-system的namespace
   ```
   kubectl create ns  kubesphere-system
   ```
2. 创建集群ca证书secret
   >注：按照当前集群ca.crt和ca.key证书路径创建（kubeadm创建集群的证书路径一般为/etc/kubernetes/pki）
   ```
   kubectl -n kubesphere-system create secret generic kubesphere-ca --from-file=ca.crt=/etc/kubernetes/ssl/ca.crt  --from-file=ca.key=/etc/kubernetes/ssl/ca.key 
   ```
3. 创建集群front-proxy-client证书secret
   >注：按照当前集群front-proxy-client.crt和front-proxy-client.key证书路径创建（kubeadm创建集群的证书路径一般为/etc/kubernetes/pki）
   ```
   kubectl -n kubesphere-system create secret generic front-proxy-client   --from-file=front-proxy-client.crt=/etc/kubernetes/pki/front-proxy-client.crt  --from-file=front-proxy-client.key=/etc/kubernetes/pki/front-proxy-client.key
4. 部署installer job
   ```
   cd deploy
   
   vim kubesphere-installer.yaml   ## 编辑kubesphere-installer.yaml中kubesphere-config相关参数为当前集群参数。（若etcd无证书，设置etcd_tls_enable: False）

   kubectl apply -f kubesphere-installer.yaml
   ```
5. 创建etcd证书secret
   >注：以集群实际etcd证书位置创建；若etcd无证书，则创建空secret
   ```
   kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs  --from-file=etcd-client-ca.crt=/etc/ssl/etcd/ssl/ca.pem  --from-file=etcd-client.crt=/etc/ssl/etcd/ssl/admin-node1.pem  --from-file=etcd-client.key=/etc/ssl/etcd/ssl/admin-node1-key.pem
   ```
   etcd无证书
   ```
   kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs
   ```