Offline environment
------------
1. clone 或者下载此 ks-installer 项目  
2. 下载镜像包并解压
   > 可按需下载对应功能镜像包，也可下载完整功能镜像包，下载连接如下（二选一）
   ```
    下载完整镜像包（包含所有功能使用到的镜像）：
    kubesphere-images-v2.1.1.tar.gz
    wget https://kubesphere-installer.pek3b.qingstor.com/offline/v2.1.1/images/kubesphere-images-v2.1.1.tar.gz
   
   
    按功能下载镜像包（如已下载完整镜像包，则无需重复下载）：
    ks_minimal_images.tar.gz
    wget https://kubesphere-installer.pek3b.qingstor.com/offline/v2.1.1/images/ks_minimal_images.tar.gz

    openpitrix_images.tar.gz
    wget https://kubesphere-installer.pek3b.qingstor.com/offline/v2.1.1/images/openpitrix_images.tar.gz

    ks_logging_images.tar.gz
    wget https://kubesphere-installer.pek3b.qingstor.com/offline/v2.1.1/images/ks_logging_images.tar.gz

    ks_devops_images.tar.gz
    wget https://kubesphere-installer.pek3b.qingstor.com/offline/v2.1.1/images/ks_devops_images.tar.gz

    istio_images.tar.gz
    wget https://kubesphere-installer.pek3b.qingstor.com/offline/v2.1.1/images/istio_images.tar.gz

    ks_notification_images.tar.gz
    wget https://kubesphere-installer.pek3b.qingstor.com/offline/v2.1.1/images/ks_notification_images.tar.gz

    example_images.tar.gz
    wget https://kubesphere-installer.pek3b.qingstor.com/offline/v2.1.1/images/example_images.tar.gz
   ```
3. 导入镜像（镜像包较大，导入时间较久）
   ```
   docker load < xxx.tar
   ```
4. 将安装所需镜像导入本地镜像仓库
   ```
   cd scripts
   ./download-docker-images.sh  仓库地址

   注：“仓库地址” 请替换为本地镜像仓库地址，例：

   ./download-docker-images.sh  192.168.1.2:5000
   ```
5. 在kubesphere-minimal.yaml中添加镜像仓库地址参数
   >注：以下命令中192.168.1.2:5000为示例仓库，执行时请替换。
   ```
   local_registry: "192.168.1.2:5000"
   ```
6. 替换kubesphere-minimal.yaml中镜像
   >注：以下命令中192.168.1.2:5000/kubesphere/ks-installer:v2.1.0为示例镜像，执行时请替换。
   ```
   sed -i 's|kubesphere/ks-installer:v2.1.1|192.168.1.2:5000/kubesphere/ks-installer:v2.1.1|g' kubesphere-minimal.yaml
   sed -i 's|Always|IfNotPresent|g' kubesphere-minimal.yaml
   ```
7. 按Deploy中步骤执行安装
