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
version="v2" #support v1 or v2

harbor_projects=(library
    kubesphere
    calico
    coredns
    csiplugin
    minio
    mirrorgooglecontainers
    osixia
    prom
    thanosio
    jimmidyson
    grafana
    elastic
    istio
    jaegertracing
    jenkins
    openpitrix
    joosthofman
    nginxdemos
    kubeedge
    weaveworks

)

for project in "${harbor_projects[@]}"; do
    echo "creating $project"
    if [ $version == 'v2' ]; then
      curl -u "${user}:${passwd}" -X POST -H "Content-Type: application/json" "${url}/api/v2.0/projects" -d "{\"project_name\": \"${project}\", \"metadata\": {\"public\": \"true\"}, \"storage_limit\": -1}"
    else
      curl -u "${user}:${passwd}" -X POST -H "Content-Type: application/json" "${url}/api/projects" -d "{ \"project_name\": \"${project}\", \"public\": 1}"
    fi
done
