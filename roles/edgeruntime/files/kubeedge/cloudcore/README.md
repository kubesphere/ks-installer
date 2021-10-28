# EdgeMesh app

Visit https://github.com/kubeedge/edgemesh for more information.

## Install examples

```
helm upgrade --install cloudcore ./cloudcore --namespace kubeedge --create-namespace -f ./cloudcore/values.yaml --set cloudCore.modules.cloudHub.advertiseAddress[0]=192.168.88.6
```

## Uninstall

```
helm uninstall cloudcore -n kubeedge
```
