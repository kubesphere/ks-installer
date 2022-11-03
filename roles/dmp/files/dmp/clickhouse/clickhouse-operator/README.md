# Deploy ClickHouse Operator On Kubernetes

## Introduction

RadonDB ClickHouse is an open-source, cloud-native, highly availability cluster solutions based on [ClickHouse](https://clickhouse.tech/). It provides features such as high availability, PB storage, real-time analytical, architectural stability and scalability.

This tutorial demonstrates how to deploy ClickHouse Operator on Kubernetes.

## Prerequisites

- You have created a Kubernetes cluster.

## Procedure

### Step 1 : Add Helm Repository

Add and update helm repository.

```bash
$ helm repo add <repoName> https://radondb.github.io/radondb-clickhouse-kubernetes/
$ helm repo update
```

**Expected output**

```bash
$ helm repo add ck https://radondb.github.io/radondb-clickhouse-kubernetes/
"ck" has been added to your repositories

$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "ck" chart repository
Update Complete. ⎈Happy Helming!⎈
```

### Step 2 : Install ClickHouse Operator

```bash
$ helm install --generate-name -n <nameSpace> <repoName>/clickhouse-operator
```

**Expected output**

```bash
$ helm install clickhouse-operator ck/clickhouse-operator -n kube-system
NAME: clickhouse-operator
LAST DEPLOYED: Wed Aug 17 14:43:44 2021
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

Then you can deploy [ClickHouse Cluster](../clickhouse-cluster/README.md).

## License

This helm chart is published under the Apache License, Version 2.0.
See [LICENSE](../LICENSE) for more information.

Copyright (c) by [RadonDB](https://github.com/radondb).

### Attributions

* **ClickHouse**
  * Project URL: https://clickhouse.tech/
  * License: Apache License, Version 2.0
* **ClickHouse Operator**
  * Project URL: https://github.com/Altinity/clickhouse-operator/
  * License: Apache License, Version 2.0

<p align="center">
<br/><br/>
Please submit any RadonDB ClickHouse bugs, issues, and feature requests to GitHub Issue.
<br/>
</p>
