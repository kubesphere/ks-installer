#！/bin/bash

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


#helm delete
helms="elasticsearch-logging elasticsearch-logging-curator istio istio-init jaeger-operator ks-jenkins ks-sonarqube logging-fluentbit-operator metrics-server uc"

for id in `helm list|awk '{print $1}'|grep -v NAME`; do
     result=$(echo $helms | grep "$id")
     if [[ "$result" != "" ]]
     then
        helm delete --purge $id
     else
        echo "helm resource 已删除"
     fi   
done

#namespace resource delete
namespaces="kubesphere-system openpitrix-system kubesphere-monitoring-system kubesphere-alerting-system kubesphere-controls-system"

for namespace in `kubectl get namespaces|awk '{print $1}'|grep -v NAME`; do
     result=$(echo $namespaces | grep "$namespace")
     if [[ "$result" != "" ]]
     then
        kubectl delete all --all -n $namespace
     else
        echo "namespace resource 已删除"
     fi   
done

