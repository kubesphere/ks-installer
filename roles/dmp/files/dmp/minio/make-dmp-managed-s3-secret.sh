#!/bin/bash

ak=`kubectl get secrets minio -n kubesphere-system -o yaml |egrep "accesskey|secretkey"|grep accesskey |grep -v f: |awk '{{printf"%s",$2}}'`
sk=`kubectl get secrets minio -n kubesphere-system -o yaml |egrep "accesskey|secretkey"|grep secretkey |grep -v f: |awk '{{printf"%s",$2}}'`


echo  "
apiVersion: v1
data:
  # for mysql
  s3-access-key: $ak
  s3-secret-key: $sk
  s3-region: $(echo -n "foo" | base64)
  s3-bucket: $(echo -n "dmp-mysqlbackup" | base64)
  s3-endpoint: $(echo -n "http://minio.kubesphere-system:9000" | base64)

  # for pg
  pg-s3-key: $ak
  pg-s3-key-secret: $sk
  pg-s3-region: $(echo -n "foo" | base64)
  pg-s3-bucket: $(echo -n "dmp-pgbackup" | base64)
  pg-s3-endpoint: $(echo -n "nginx-oss-proxy.dmp-system" | base64)
  pg-s3-uri-style: $(echo -n "path" | base64)

kind: Secret
metadata:
  name: dmp-managed-s3-secret
  namespace: dmp-system
type: Opaque
" > /kubesphere/kubesphere/dmp/minio/dmp-managed-s3-secret.yaml
