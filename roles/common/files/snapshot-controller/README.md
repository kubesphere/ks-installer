# csi-neonsan 

## TL;DR;

```console
helm install test/snapshot-controller
```

## Installing

To install the chart with the release name `snapshot-controller`:

```console
helm repo add test https://charts.kubesphere.io/test
helm install test/snapshot-controller --name-template snapshot-controller --namespace kube-system
```

The command deploys the snapshot-controller chart on the Kubernetes cluster in the default configuration. The configuration section lists the parameters that can be configured during installation.

## Uninstalling

To uninstall/delete the `snapshot-controller` deployment:

```console
helm delete snapshot-controller --namespace kube-system
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the chart and their default values.

Parameter | Description | Default
--- | --- | ---
`repository` | Image of snapshot-controller | `csiplugin/snapshot-controller`
`tag` | Tag of snapshot-controller | `v2.0.1`
`pullPolicy` | Image pull policy of snapshot-controller | `IfNotPresent`

