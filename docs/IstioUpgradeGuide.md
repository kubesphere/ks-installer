# Upgrade Notes For Istio

Istio does NOT support skip level upgrades. 

If you want to upgrade to 1.5.x, you need to upgrade 1.4.x firstly.


# upgrade to 1.4.8 from 1.3.3

Support to ***upgrade to 1.4.8 from istio 1.3.3*** on KubeSphere platform by helm2.

[official upgarde notes](https://archive.istio.io/v1.4/news/releases/1.4.x/announcing-1.4/upgrade-notes/)

1. Get the Istio 1.4.8 packages

```bash
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.4.8 sh - && cd istio-1.4.8/install/kubernetes/helm
```

2. Get custom setting files from ks-installer

```bash
pod=$(kubectl get pod -n kubesphere-system -l app=ks-installer -o jsonpath={.items[0].metadata.name})
kubectl -n kubesphere-system exec $pod cat /etc/kubesphere/istio/custom-values-istio-init.yaml > custom-values-istio-init.yaml
kubectl -n kubesphere-system exec $pod cat /etc/kubesphere/istio/custom-values-istio.yaml > custom-values-istio.yaml
kubectl -n kubesphere-system exec $pod  sed -i 's/1.3.3/1.4.8/g' /kubesphere/installer/roles/download/defaults
sed -i 's/tag: .*$/tag: 1.4.8/' custom-values-istio-init.yaml
sed -i 's/tag: .*$/tag: 1.4.8/' custom-values-istio.yaml
sed -i 's/image: proxy_init/image: proxyv2/' custom-values-istio.yaml
```

3. Upgrade control plane (pilot/galley/policy/temetry/sidecar injector)

```bash
helm upgrade --install istio-init ./istio-init --namespace istio-system -f ./custom-values-istio-init.yaml  --force  
helm upgrade --install istio ./istio --namespace istio-system -f ./custom-values-istio.yaml 
kubectl rollout restart deployment -n istio-system
```

4. Upgrade sidecar

Upgrade the sidecar by doing a rolling update for all the pods, so that the new version of the sidecar will be automatically re-injected.

```bash
kubectl rollout restart deployment -n demo-project  # User's Project Namespaces
```

5. Verify and inspect the version (optional)

Now you have upgarded completely, ensure all pods run in correct status.

You can describe compenent pods to verify the version. Such as below:
    
Firstly, inspect pods status. 

```bash
# kubectl get pods -n istio-system
NAME                                      READY   STATUS      RESTARTS   AGE
istio-citadel-7dc9cbfbbc-nlxqc            1/1     Running     0          3h28m
istio-galley-5766bfbcb9-6wkzg             1/1     Running     0          3h28m
istio-ingressgateway-57485bc4f6-wr555     1/1     Running     0          3h28m
istio-init-crd-10-1.4.8-pxh8s             0/1     Completed   0          3h30m
istio-init-crd-11-1.4.8-s98vn             0/1     Completed   0          3h30m
istio-init-crd-14-1.4.8-ms7h2             0/1     Completed   0          3h30m
istio-pilot-b59cdb558-wwhmk               2/2     Running     0          3h28m
istio-policy-57674d7c97-8fbvr             2/2     Running     0          3h28m
istio-sidecar-injector-58d4466cfd-vdxs5   1/1     Running     0          3h28m
istio-telemetry-5cb5cd84d6-fjwzw          2/2     Running     0          3h28m
jaeger-collector-544bdd5f9f-28lp2         1/1     Running     0          3h38m
jaeger-operator-bdbb4954b-cs2mm           1/1     Running     0          3h38m
jaeger-query-5d86f5fcf-82jgh              2/2     Running     0          3h38m

```

Describe pods to verify the version, such as:

**control plane**:

```bash
# kubectl describe pod istio-citadel-7dc9cbfbbc-nlxqc -n istio-system|grep Image
Image:         istio/citadel:1.4.8
``` 

**sidecar**:

```bash
# kubectl get po -n demo-project
NAME                            READY   STATUS    RESTARTS   AGE
details-v1-58994c779c-snbdw     2/2     Running   0          3h38m

# kubectl describe po/details-v1-58994c779c-snbdw -n demo-project
...
Init Containers:
istio-init:
    Image:         istio/proxyv2:1.4.8
    ...
istio-proxy:
    Image:         istio/proxyv2:1.4.8
    ...
```
    
