#!/usr/bin/env bash

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

url="http://192.168.6.2"
user="admin"
passwd="Harbor12345"

harbor_projects=(library
    jimmidyson
    kubesphere
    csiplugin
    openpitrix
    mirrorgitlabcontainers
    google-containers
    istio
    k8scsi
    osixia
    goharbor
    minio
    openebs
    kubernetes-helm
    coredns
    jenkins
    jaegertracing
    calico
    oliver006
    fluent
    kubernetes_ingress_controller
    kibana
    gitlab_org
    coreos
    google_containers
    grafana
    external_storage
    pires
    nginxdemos
    gitlab
    joosthofman
    mirrorgooglecontainers
    wrouesnel
    dduportal
)

for project in "${harbor_projects[@]}"; do
    echo "creating $project"
    curl -u "${user}:${passwd}" -X POST -H "Content-Type: application/json" "${url}/api/projects" -d "{ \"project_name\": \"${project}\", \"public\": 1}"
done
