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

python os/get-pip.py > /dev/null
pip install  -r os/requirements.txt  > /dev/null

LOG_FOLDER=$BASE_FOLDER/../logs
if [ ! -d $LOG_FOLDER ];then
   mkdir -p $LOG_FOLDER
fi
current=`date "+%Y-%m-%d~%H:%M:%S"`
export ANSIBLE_LOG_PATH=$LOG_FOLDER/Upgrade[$current].log
export DEFAULT_FORKS=50
export ANSIBLE_RETRY_FILES_ENABLED=False
export ANSIBLE_CALLBACK_WHITELIST=profile_tasks
export ANSIBLE_TIMEOUT=300
export ANSIBLE_HOST_KEY_CHECKING=False

allinone_hosts=$BASE_FOLDER/../k8s/inventory/local/hosts.ini
multinode_hosts=$BASE_FOLDER/../k8s/inventory/my_cluster/hosts.ini

allinone_vars_path=$BASE_FOLDER/../k8s/inventory/local/group_vars/k8s-cluster
multinode_vars_path=$BASE_FOLDER/../k8s/inventory/my_cluster/group_vars/k8s-cluster

vars_path=$BASE_FOLDER/../conf
common_file=$vars_path/common.yaml
version_file=$BASE_FOLDER/../kubesphere/version.tmp

kube_version=$(grep -r "kube_version" $common_file | awk '{print $2}')
etcd_version=$(grep -r "etcd_version" $common_file | awk '{print $2}')

sed -i "/openpitrix_enabled/s/\:.*/\: true/g" $common_file

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
    ansible-playbook -i $2 $BASE_FOLDER/../kubesphere/check_version.yml -b > /dev/null
    # if [[ ! -f $1 ]]; then
    #    ansible-playbook -i $2 $BASE_FOLDER/../kubesphere/check_version.yml -b
    # fils

}


function result_cmd(){
   commandline='kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f'
   cat << eof

$(echo -e "\033[1;36mNOTE:\033[0m")

Verify the upgrade logs and result:

   $commandline


eof
}


function check_nonsupport() {
    cat $1
    grep "nonsupport" $1 >/dev/null
    if [ $? -eq 0 ]; then
       upgrade_warnning="Warnning: Parameters containing the word 'nonsupport' can't change. Please change the relevant parameters in conf/common.yaml !"
       echo -e "\033[1;36m$upgrade_warnning\033[0m"
       exit
    fi
}

function notes() {

    cat << eof

$(echo -e "\033[1;36mNOTES:\033[0m")

Before upgrading:

1. Please sync your configuration changes from previous version to 2.1.1 in the conf directory.

2. Please backup your configuration if you modified the configuration of KubeSphere and Kubernetes components.

eof
}



function task_check() {
    if [[ $? -ne 0 ]]; then
       str="failed!"
       echo -e "\033[31;47m$str\033[0m"
       exit
    fi
}

function upgrade_k8s_version() {

   current_k8s_version=$(grep "k8s" $version_file | awk -F '[ ]' '{print $a}' a=2 | awk -F '[.]' '{print $2}')
   target_k8s_version=$(grep "k8s" $version_file | awk -F '[ ]' '{print $a}' a=4 | awk -F '[.]' '{print $2}')
   
   while [[ $(($target_k8s_version-$current_k8s_version)) -ne 0 ]]; do

      if [[ $current_k8s_version -eq 13 ]]; then
         sed -i "/kube_version/s/\:.*/\: v1.14.8/g" $1/common.yaml
      elif [[ $current_k8s_version -eq 14 ]]; then
         sed -i "/kube_version/s/\:.*/\: v1.15.5/g" $1/common.yaml
      elif [[ $current_k8s_version -eq 15 ]]; then
         sed -i "/kube_version/s/\:.*/\: v1.16.7/g" $1/common.yaml
      elif [[ $current_k8s_version -eq 16 ]]; then
         sed -i "/kube_version/s/\:.*/\: v1.17.3/g" $1/common.yaml
      fi

      ansible-playbook -i $2 $BASE_FOLDER/../k8s/upgrade-cluster.yml -b

      task_check
      cp -f $vars_path/*.yaml $1
      ansible-playbook -i $2 $BASE_FOLDER/../kubesphere/check_version.yml -b

      task_check
      if [[ $(grep -c "k8s" $version_file) -eq 0 ]]; then
         break
      fi
      current_k8s_version=$(grep "k8s" $version_file | awk -F '[ ]' '{print $a}' a=2 | awk -F '[.]' '{print $2}')
      target_k8s_version=$(grep "k8s" $version_file | awk -F '[ ]' '{print $a}' a=4 | awk -F '[.]' '{print $2}')

   done

}


function update-allinone() {
    
    cp -f $BASE_FOLDER/../conf/*.yaml $allinone_vars_path

    check_version_file $version_file $allinone_hosts

    check_nonsupport $version_file
    notes
    Upgrade_Confirmation

    if [[ $(grep -c "k8s" $version_file) -ne 0 ]]; then
       upgrade_k8s_version $allinone_vars_path $allinone_hosts
    fi

    ansible-playbook -i $BASE_FOLDER/../k8s/inventory/local/hosts.ini $BASE_FOLDER/../kubesphere/upgrade.yml \
                     -b \
                     -e prometheus_replicas=1 \
                     -e ks_console_replicas=1 \
                     -e jenkinsJavaOpts_Xms='512m' \
                     -e jenkinsJavaOpts_Xmx='512m' \
                     -e jenkinsJavaOpts_MaxRAM='2g' \
                     -e jenkins_memory_lim="2Gi" \
                     -e jenkins_memory_req="1500Mi" \
                     -e logsidecar_replicas=1 \
                     -e elasticsearch_data_replicas=1 \
                     --skip-tags=bootstrap-os,container-engine,apps,helm


    if [[ $? -eq 0 ]]; then
        #statements
        str="successsful!"
        echo -e "\033[30;47m$str\033[0m"
        echo
        result_cmd
    else
        str="failed!"
        echo -e "\033[31;47m$str\033[0m"
        exit
    fi

}

function update-multinode() {

#    sed -i "/local_volume_enabled/s/\:.*/\: false/g" $common_file

    cp -f $BASE_FOLDER/../conf/hosts.ini $multinode_hosts
    cp -f $BASE_FOLDER/../conf/*.yaml $multinode_vars_path

    ids=`cat -n $multinode_hosts | grep "ansible_user" | grep -v "#" | grep -v "root" | awk '{print $1}'`
    for id in $ids; do
       passwd=`awk '{if(NR==id){print $5}}' id="$id" $multinode_hosts | sed '/^ansible_become_pass=/!d;s/.*=//'`
       sed -i ''$id's/$/&  ansible_ssh_pass\='$passwd'/g'  $multinode_hosts
    done

    check_version_file $version_file $multinode_hosts

    check_nonsupport $version_file
    notes
    Upgrade_Confirmation

    if [[ $(grep -c "k8s" $version_file) -ne 0 ]]; then
       upgrade_k8s_version $multinode_vars_path $multinode_hosts
    fi

    ansible-playbook -i $multinode_hosts $BASE_FOLDER/../kubesphere/upgrade.yml \
                     -b \
                     -e local_volume_provisioner_enabled=false \
                     --skip-tags=bootstrap-os,container-engine,apps,helm


    if [[ $? -eq 0 ]]; then
        #statements
        str="successsful!"
        echo -e "\033[30;47m$str\033[0m"
        echo
        result_cmd
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
