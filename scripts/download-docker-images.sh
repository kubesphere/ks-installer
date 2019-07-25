#!/bin/bash

# Copyright 2018 The KubeSphere Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# docker login -u guest -p guest dockerhub.qingcloud.com

ks_images=(dockerhub.qingcloud.com/kubesphere/ks-console:advanced-2.0.2  \
           dockerhub.qingcloud.com/kubesphere/kubectl:advanced-1.0.0  \
           kubesphere/ks-account:advanced-2.0.2  \
           kubesphere/ks-devops:flyway-advanced-2.0.2  \
           kubesphere/ks-apigateway:advanced-2.0.2  \
           kubesphere/ks-apiserver:advanced-2.0.2 \
           kubesphere/ks-controller-manager:advanced-2.0.2 \
           kubesphere/docs.kubesphere.io:advanced-2.0.0 \
           kubesphere/ks-upgrade:advanced-2.0.0 \
           kubesphere/cloud-controller-manager:v1.3.4 \

           dockerhub.qingcloud.com/kubernetes_ingress_controller/nginx-ingress-controller:0.24.1 \
           googlecontainer/defaultbackend-amd64:1.4 \
           dockerhub.qingcloud.com/google_containers/metrics-server-amd64:v0.3.1 \

           kubesphere/notification:flyway-advanced-2.0.2 \
           kubesphere/notification:advanced-2.0.2 \
           kubesphere/alerting-dbinit:advanced-2.0.2 \
           kubesphere/alerting:advanced-2.0.2 \
           kubesphere/alert_adapter:advanced-2.0.2 \

           openpitrix/openpitrix:v0.3.5 \
           openpitrix/openpitrix:flyway-v0.3.5 \
           minio/minio:RELEASE.2018-09-25T21-34-43Z \
           dockerhub.qingcloud.com/coreos/etcd:v3.2.18 \

           dockerhub.qingcloud.com/qingcloud/jenkins-uc:0.8.0-dev \
           jenkins/jenkins:2.138.4  \
           jenkins/jnlp-slave:3.27-1  \
           kubesphere/builder-base:advanced-1.0.0  \
           kubesphere/builder-nodejs:advanced-1.0.0  \
           kubesphere/builder-maven:advanced-1.0.0  \
           kubesphere/builder-go:advanced-1.0.0  \
           docker:18.06.1-ce-dind  \
           sonarqube:7.4-community  \

           kubesphere/s2ioperator:advanced-2.0.0  \
           kubesphere/s2irun:advanced-2.0.0  \
           kubesphere/java-11-centos7:advanced-2.0.0  \
           kubesphere/java-8-centos7:advanced-2.0.0  \
           kubesphere/nodejs-8-centos7:advanced-2.0.0  \
           kubesphere/nodejs-6-centos7:advanced-2.0.0  \
           kubesphere/nodejs-4-centos7:advanced-2.0.0  \
           kubesphere/python-36-centos7:advanced-2.0.0  \
           kubesphere/python-35-centos7:advanced-2.0.0  \
           kubesphere/python-34-centos7:advanced-2.0.0  \
           kubesphere/python-27-centos7:advanced-2.0.0  \

           dockerhub.qingcloud.com/coreos/configmap-reload:v0.0.1  \
           dockerhub.qingcloud.com/prometheus/prometheus:v2.5.0  \
           dockerhub.qingcloud.com/coreos/prometheus-config-reloader:v0.27.1  \
           dockerhub.qingcloud.com/coreos/prometheus-operator:v0.27.1  \
           dockerhub.qingcloud.com/coreos/kube-rbac-proxy:v0.4.1  \
           dockerhub.qingcloud.com/coreos/kube-state-metrics:v1.5.2  \
           dockerhub.qingcloud.com/prometheus/node-exporter:ks-v0.16.0  \
           dockerhub.qingcloud.com/coreos/addon-resizer:1.8.4  \
           dockerhub.qingcloud.com/coreos/k8s-prometheus-adapter-amd64:v0.4.1  \

           dockerhub.qingcloud.com/pires/docker-elasticsearch-curator:5.5.4  \
           dockerhub.qingcloud.com/elasticsearch/elasticsearch-oss:6.7.0  \
           dockerhub.qingcloud.com/fluent/fluent-bit:0.14.7  \
           dockerhub.qingcloud.com/kibana/kibana-oss:6.7.0  \
           dduportal/bats:0.4.0  \
           kubesphere/fluentbit-operator:advanced-2.0.0  \
           kubesphere/fluent-bit:advanced-2.0.0  \
           kubesphere/configmap-reload:advanced-2.0.0  \

           docker.io/istio/kubectl:1.1.1  \
           docker.io/istio/proxy_init:1.1.1  \
           docker.io/istio/proxyv2:1.1.1  \
           docker.io/istio/citadel:1.1.1  \
           docker.io/istio/pilot:1.1.1  \
           docker.io/istio/mixer:1.1.1  \
           docker.io/istio/galley:1.1.1  \
           docker.io/istio/sidecar_injector:1.1.1  \
           docker.io/istio/node-agent-k8s:1.1.1  \
           jaegertracing/jaeger-operator:1.11.0  \
           jaegertracing/jaeger-agent:1.11  \
           jaegertracing/jaeger-collector:1.11  \
           jaegertracing/jaeger-query:1.11  \

           redis:4.0  \
           busybox:1.28.4  \
           mysql:8.0.11  \
           nginx:1.14-alpine  \
           postgres:9.6.8  \
           osixia/openldap:1.2.2  \
           alpine:3.9  \

           kubesphere/examples-bookinfo-productpage-v1:1.13.0  \
           kubesphere/examples-bookinfo-reviews-v1:1.13.0  \
           kubesphere/examples-bookinfo-reviews-v2:1.13.0  \
           kubesphere/examples-bookinfo-reviews-v3:1.13.0  \
           kubesphere/examples-bookinfo-details-v1:1.13.0  \
           kubesphere/examples-bookinfo-ratings-v1:1.13.0  \

           nginxdemos/hello:plain-text \
           mysql:5.6  \
           wordpress:4.8-apache  \
           mirrorgooglecontainers/hpa-example:latest  \
           java:openjdk-8-jre-alpine  \
           fluent/fluentd:v1.4.2-2.0  \
           perl:latest  \
           kubespheredev/ks-installer:advanced-2.0.2  \
   )
  
registryurl="$1"
qingcloudurl="dockerhub.qingcloud.com"
dockerurl="docker.io"

for image in ${ks_images[@]}; do
	## download_images
	# docker pull $image
	## retag images
    url=${image%%/*}
    ImageName=${image#*/}
    echo $image
    if [ $url == $dockerurl ] || [ $url == $qingcloudurl ]; then
          imageurl=$registryurl"/"${image#*/}
    elif [ $url == $registryurl ]; then
        if [[ $ImageName != */* ]]; then
            imageurl=$registryurl"/library/"$ImageName
        else
            imageurl=$image
        fi
    elif [ "$(echo $url | grep ':')" != "" ]; then
          imageurl=$registryurl"/library/"$image                  
    else
          imageurl=$registryurl"/"$image 
    fi  
    ## push image
    echo $imageurl
    docker tag $image $imageurl
    docker push $imageurl
    # docker rmi $i
done
