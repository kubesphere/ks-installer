#! /bin/bash

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

BASE_FOLDER=$(dirname $(readlink -f "$0"))
cp $BASE_FOLDER/../conf/hosts.ini $BASE_FOLDER/../k8s/inventory/my_cluster/hosts.ini
cp $BASE_FOLDER/../conf/vars.yml $BASE_FOLDER/../k8s/inventory/my_cluster/group_vars/k8s-cluster/k8s-cluster.yml


ids=`cat -n $BASE_FOLDER/../k8s/inventory/my_cluster/hosts.ini | grep "ansible_user" | grep -v "#" | grep -v "root" | awk '{print $1}'`
for id in $ids; do
     passwd=`awk '{if(NR==id){print $5}}' id="$id" $BASE_FOLDER/../k8s/inventory/my_cluster/hosts.ini | sed '/^ansible_become_pass=/!d;s/.*=//'`
     sed -i ''$id's/$/&  ansible_ssh_pass\='$passwd'/g'  $BASE_FOLDER/../k8s/inventory/my_cluster/hosts.ini
done


LOG_FOLDER=$BASE_FOLDER/../logs
if [ ! -d $LOG_FOLDER ];then
   mkdir -p $LOG_FOLDER
fi
current=`date "+%Y-%m-%d~%H:%M:%S"`
export ANSIBLE_LOG_PATH=$LOG_FOLDER/Scale[$current].log
export DEFAULT_FORKS=10
export ANSIBLE_RETRY_FILES_ENABLED=False
export ANSIBLE_CALLBACK_WHITELIST=profile_tasks
export ANSIBLE_TIMEOUT=300
export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook -i $BASE_FOLDER/../k8s/inventory/my_cluster/hosts.ini $BASE_FOLDER/../preinstall/init.yml -b 
if [[ $? -eq 0 ]]; then
	#statements
	str="successsful!"
	echo -e "\033[30;47m$str\033[0m"  
else
	str="failed!"
	echo -e "\033[31;47m$str\033[0m"
	exit
fi


ansible-playbook -i $BASE_FOLDER/../k8s/inventory/my_cluster/hosts.ini $BASE_FOLDER/../k8s/scale.yml -b
if [[ $? -eq 0 ]]; then
	#statements
	str="successsful!"
	echo -e "\033[30;47m$str\033[0m"  
else
	str="failed!"
	echo -e "\033[31;47m$str\033[0m"
	exit
fi


ansible-playbook -i $BASE_FOLDER/../k8s/inventory/my_cluster/hosts.ini $BASE_FOLDER/../kubesphere/scale.yml -b -e local_volume_provisioner_enabled=false
if [[ $? -eq 0 ]]; then
	#statements
	str="successsful!"
	echo -e "\033[30;47m$str\033[0m"  
else
	str="failed!"
	echo -e "\033[31;47m$str\033[0m"
	exit
fi
