Offline environment
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