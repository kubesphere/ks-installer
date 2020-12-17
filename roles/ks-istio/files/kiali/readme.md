# deploy kiali

```bash
helm upgrade --install kiali kiali-server-1.26.1.tgz custom-values-kiali.yaml -n istio-system
```