#!/bin/bash

caBundle=$(kubectl get secret ks-controller-manager-webhook-cert -n kubesphere-system -o jsonpath='{.data.ca\.crt}')
cat > /tmp/patch.yaml <<EOF
spec:
  conversion:
    webhook:
      clientConfig:
        caBundle: ${caBundle}
EOF

kubectl patch crd federatednotificationconfigs.types.kubefed.io --type=merge --patch-file /tmp/patch.yaml
kubectl patch crd federatednotificationreceivers.types.kubefed.io --type=merge --patch-file /tmp/patch.yaml