# upgrading to Istio 1.16.2

The current istio version is only compatible up to K8s 1.22, upgrade istio version to be compatible with higher versions of K8s.


# upgrading to Istio 1.11.1

With KubeSphere v3.2 release, Istio v1.11.1 will be installed when ServiceMesh is enabled. However, Istio v1.6.11 may still run in the cluster when upgrading from an older release. You have to rollout all your existing deployments before the Istio v1.6.11 be uninstalled.


# install istio-1.6.10

```bash
./istio-1.6.10/bin/istioctl install --set hub=istio --set tag=1.6.10 --set addonComponents.prometheus.enabled=false --set values.global.jwtPolicy=first-party-jwt --set values.global.proxy.autoInject=disabled --set values.global.tracer.zipkin.address="jaeger-collector.istio-system.svc:9411" --set values.sidecarInjectorWebhook.enableNamespacesByDefault=true --set values.global.imagePullPolicy=IfNotPresent --set values.global.controlPlaneSecurityEnabled=false --set revision=1-6-10

istio-1.6.10/bin/istioctl install -f istio-profile.yaml --set revision=1-6-10
```

# upgrade istio 1.8.4

```
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.8.4 TARGET_ARCH=x86_64 sh -
./istio-1.8.4/bin/istioctl install --set hub=istio --set values.global.proxy.autoInject=disabled --set meshConfig.defaultConfig.tracing.zipkin.address="jaeger-collector.istio-system.svc:9411" --set values.sidecarInjectorWebhook.enableNamespacesByDefault=true --set values.global.imagePullPolicy=IfNotPresent --set revision=1-8-4

```

# uninstall 1.6.10

```
./istio-1.8.4/bin/istioctl x uninstall --revision=1-6-10
```