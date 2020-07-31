# Install k8s with kk

Install a pure k8s cluster as the installer guide

# Install default csi

Install csi , such as csi-qingcloud:

1. use helm to install

```bash
helm repo add test https://charts.kubesphere.io/test
# replace your key/secret and  zone(or region)
helm install test/csi-qingcloud --name-template csi-qingcloud --namespace kube-system --set config.qy_access_key_id=xxx,config.qy_secret_access_key=xxx,config.zone=ap2a,sc.enable=true,sc.type=0,driver.tag=v1.2.0-rc.4
```

verify the csi

```
# kubectl get sc 
NAME                      PROVISIONER              RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
csi-qingcloud   disk.csi.qingcloud.com   Delete          Immediate           true                   36m
```

2. modify it to default sc 

```bash
# kubectl edit sc csi-qingcloud
...
metadata
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
...

# kubectl get sc 
NAME                      PROVISIONER              RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
csi-qingcloud (default)   disk.csi.qingcloud.com   Delete          Immediate           true
```

3. install kubesphere using default sc

```bash
kubectl apply -f https://github.com/kubesphere/ks-installer/blob/master/deploy/kubesphere-installer.yaml
kubectl apply -f https://github.com/kubesphere/ks-installer/blob/master/deploy/cluster-configuration.yaml
```

