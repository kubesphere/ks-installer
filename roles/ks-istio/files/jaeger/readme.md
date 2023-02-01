# deploy jaeger-operator

```bash
helm upgrade --install jaeger-operator jaeger-operator-2.39.0.tgz -f custom-values-jaeger.yaml -n istio-system
```


# deploy jaeger CR

```bash
kubectl apply -f jaeger-production.yaml -n istio-system
```