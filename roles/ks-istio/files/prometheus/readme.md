# create additional-scrape-configs secret directly
kubectl -n kubesphere-monitoring-system create secret generic additional-scrape-configs --from-file=servicemesh/istio/prometheus-additional.yaml

# create additional-scrape-configs secret from prometheus file
kubectl -n kubesphere-monitoring-system create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml

