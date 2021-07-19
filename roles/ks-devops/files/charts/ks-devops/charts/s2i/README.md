# S2i Helm Charts

- Install s2i charts into Kubernetes
```shell
cd charts/ks-devops/charts/s2i
helm install s2ioperator . -n kubesphere-devops-system --create-namespace
```
- Debug s2i charts locally 
```shell
cd charts/ks-devops/charts/s2i
helm install s2ioperator . --debug --dry-run -n kubesphere-devops-system --create-namespace
```
