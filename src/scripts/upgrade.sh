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

if [[ `whoami` != 'root' ]]; then
    user_flag=1
    notice_user="Please upgrade KubeSphere using the root user !"
    echo -e "\033[1;36m$notice_user\033[0m"
    exit
fi

export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
pip install  -r os/requirements.txt  > /dev/null

LOG_FOLDER=$BASE_FOLDER/../logs
if [ ! -d $LOG_FOLDER ];then
   mkdir -p $LOG_FOLDER
fi
current=`date "+%Y-%m-%d~%H:%M:%S"`
export ANSIBLE_LOG_PATH=$LOG_FOLDER/Upgrade[$current].log
export DEFAULT_FORKS=10
export ANSIBLE_RETRY_FILES_ENABLED=False
export ANSIBLE_CALLBACK_WHITELIST=profile_tasks
export ANSIBLE_TIMEOUT=300
export ANSIBLE_HOST_KEY_CHECKING=False

allinone_hosts=$BASE_FOLDER/../k8s/inventory/local/hosts.ini
multinode_hosts=$BASE_FOLDER/../k8s/inventory/my_cluster/hosts.ini

kube_version=$(grep -r "kube_version" $BASE_FOLDER/../conf/vars.yml | awk '{print $2}')
etcd_version=$(grep -r "etcd_version" $BASE_FOLDER/../conf/vars.yml | awk '{print $2}')


function Upgrade_Confirmation(){
	echo ""
	read -p "The relevant information is shown above, Please confirm:  (yes/no) " ans
    while [[ "x"$ans != "xyes" && "x"$ans != "xno" ]]; do
    	echo ""
        read -p "The relevant information is shown above, Please confirm:  (yes/no) " ans
    done
    if [[ "x"$ans == "xno" ]]; then
        exit
    fi
}


function check_version_file() {
	if [[ ! -f $1 ]]; then
		pip install  -r os/requirements.txt
		ansible-playbook -i $2 $BASE_FOLDER/../kubesphere/check_version.yml -b
	fi
}


function check_nonsupport() {
	cat $1
	grep "nonsupport" $1 >/dev/null
	if [ $? -eq 0 ]; then
	   upgrade_warnning="Warnning: Parameters containing the word 'nonsupport' can't change. Please change the relevant parameters in conf/vars.yml !"
	   echo -e "\033[1;36m$upgrade_warnning\033[0m"
       exit
    fi
}


function update-allinone() {

    cp $BASE_FOLDER/../conf/vars.yml $BASE_FOLDER/../k8s/inventory/local/group_vars/k8s-cluster/k8s-cluster.yml
    
    ansible-playbook -i $allinone_hosts $BASE_FOLDER/../kubesphere/check_version.yml -b  > /dev/null

    version_file=$BASE_FOLDER/../kubesphere/version.tmp

    check_version_file $version_file $allinone_hosts

    check_nonsupport $version_file

    current_k8s_version=$(grep -c "k8s" $version_file)
    current_etcd_version=$(grep -c "etcd" $version_file)

    Upgrade_Confirmation

    if [[ $current_k8s_version -eq "1" ]]; then
  	     ansible-playbook -i $allinone_hosts $BASE_FOLDER/../k8s/upgrade-cluster.yml -b
    elif [[ $current_etcd_version -eq "1" ]]; then
    	 ansible-playbook -i $allinone_hosts $BASE_FOLDER/../k8s/upgrade-cluster.yml -b --tags=etcd 
    fi

	ansible-playbook -i $BASE_FOLDER/../k8s/inventory/local/hosts.ini $BASE_FOLDER/../kubesphere/upgrade.yml \
	                 -b \
	                 -e logging_enable=false \
	                 -e prometheus_replica=1 \
	                 -e JavaOpts_Xms='-Xms512m' \
	                 -e JavaOpts_Xmx='-Xmx512m' \
	                 -e jenkins_memory_lim="2Gi" \
	                 -e jenkins_memory_req="800Mi" 
	                 

	if [[ $? -eq 0 ]]; then
		#statements
		str="successsful!"
		echo -e "\033[30;47m$str\033[0m"  
	else
		str="failed!"
		echo -e "\033[31;47m$str\033[0m"
		exit
	fi

}

function update-multinode() {
    
    cp $BASE_FOLDER/../conf/hosts.ini $BASE_FOLDER/../k8s/inventory/my_cluster/hosts.ini
	cp $BASE_FOLDER/../conf/vars.yml $BASE_FOLDER/../k8s/inventory/my_cluster/group_vars/k8s-cluster/k8s-cluster.yml

    ids=`cat -n $multinode_hosts | grep "ansible_user" | grep -v "#" | grep -v "root" | awk '{print $1}'`
	for id in $ids; do
	     passwd=`awk '{if(NR==id){print $5}}' id="$id" $multinode_hosts | sed '/^ansible_become_pass=/!d;s/.*=//'`
	     sed -i ''$id's/$/&  ansible_ssh_pass\='$passwd'/g'  $multinode_hosts
	done

    ansible-playbook -i $multinode_hosts $BASE_FOLDER/../kubesphere/check_version.yml -b  > /dev/null

    version_file=$BASE_FOLDER/../kubesphere/version.tmp

    check_version_file $version_file $multinode_hosts

    check_nonsupport $version_file
    
    current_k8s_version=$(grep -c "k8s" $version_file)
    current_etcd_version=$(grep -c "etcd" $version_file)

    Upgrade_Confirmation

    if [[ $current_k8s_version -eq "1" ]]; then
  	    ansible-playbook -i $multinode_hosts $BASE_FOLDER/../k8s/upgrade-cluster.yml -b
    elif [[ $current_etcd_version -eq "1" ]]; then
    	ansible-playbook -i $multinode_hosts $BASE_FOLDER/../k8s/upgrade-cluster.yml -b --tags=etcd 
    fi


	ansible-playbook -i $multinode_hosts $BASE_FOLDER/../kubesphere/upgrade.yml \
	                 -b \
	                 -e local_volume_provisioner_enabled=false 
	
	                  
	if [[ $? -eq 0 ]]; then
		#statements
		str="successsful!"
		echo -e "\033[30;47m$str\033[0m"  
	else
		str="failed!"
		echo -e "\033[31;47m$str\033[0m"
		exit
	fi

}


hostname=$(hostname)

if [[ $hostname != "ks-allinone" ]]; then
	update-multinode
else
    update-allinone
fi

