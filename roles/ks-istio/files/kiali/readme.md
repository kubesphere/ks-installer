# deploy kiali-operator

```bash
helm upgrade --install kiali-operator kiali-operator-1.59.1.tgz -n istio-system -f custom-values-kiali.yaml -n istio-system
```

# create kiali-cr

```bash
kubectl apply -f kiali-cr.yaml -n istio-system
```