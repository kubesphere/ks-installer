Offline environment
------------
1. clone 或者下载此 ks-installer 项目  
2. 下载镜像包并解压
   ```
   wget https://kubesphere-installer.pek3b.qingstor.com/ks-only/kubesphere-images-2.1.0.tar.gz

   tar -zxvf kubesphere-images-2.1.0.tar.gz
   ```
3. 导入镜像（镜像包较大，导入时间较久）
   ```
   docker load < kubesphere-images-2.1.0.tar
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
   sed -i 's|kubesphere/ks-installer:v2.1.0|192.168.1.2:5000/kubesphere/ks-installer:v2.1.0|g' deploy/kubesphere-minimal.yaml
   ```
7. 按Deploy中步骤执行安装
