# delete additional-scrape-configs secret firstly

```bash
kubectl -n kubesphere-monitoring-system delete secret additional-scrape-configs
```

# create additional-scrape-configs secret from prometheus file

```bash
kubectl -n kubesphere-monitoring-system create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml
```

