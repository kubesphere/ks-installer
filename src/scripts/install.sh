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

#Get the current path
BASE_FOLDER=$(dirname $(readlink -f "$0"))


DEFAULT_MODE=
MODE=${DEFAULT_MODE}

usage() {
  echo "Examples:"
  echo "    # default install ,then choice all-in-one or multi-node"
  echo "    ./install.sh"
  echo "    # install all-in-one"
  echo "    ./install.sh all-in-one"
  echo "    # install multi-node"
  echo "    ./install.sh multi-node"
  echo "Usage:"
  echo "  ./install.sh [MODE] "
  echo "Description:"
  echo "     MODE : Value is default or all-in-one or multi-node install."
  exit -1
}

while getopts h option
do
  case "${option}"
  in
  h) usage ;;
  *) usage ;;
  esac
done



function menu() {

title="KubeSphere Installer Menu"
url="https://kubesphere.io/"
time=`date +%Y-%m-%d`
clear
cat << eof
################################################
         `echo -e "\033[36m$title\033[0m"`
################################################
*   1) All-in-one
*   2) Multi-node
*   3) Quit
################################################
$url               $time
################################################
eof

}



function storage_sure(){

    clear

    cat << eof

$(echo -e "\033[1;36mPrerequisites:\033[0m")

1. It's recommended that Your OS is clean (without any other software installed), otherwise there may be conflicts.

2. OS requirements：4 Core or faster processor，8GB or more of RAM.

3. Please make sure the storage service is available if you've configured storage parameters in the conf directory .

4. Make sure the DNS address in /etc/resolv.conf is available.

5. If your network configuration uses an firewall，you must ensure infrastructure components can communicate with each other through specific ports. 
   It's recommended that you turn off the firewall or follow the link configuriation:
   $(echo -e "\033[4mhttps://github.com/kubesphere/ks-installer/blob/master/docs/NetWorkAccess.md\033[0m")

eof

    read -p "Please ensure that your environment has met the above requirements  (yes/no) " ans
    while [[ "x"$ans != "xyes" && "x"$ans != "xno" ]]; do
        read -p "Please ensure that your environment has met the above requirements  (yes/no) " ans
    done

    if [[ "x"$ans == "xno" ]]; then
        echo "Please reprepare the machines meeting the above requirements, then restart the installation !"
        exit
    fi
}

function base_check(){
    os_info=`cat /etc/os-release`
    if [[ `whoami` != 'root' ]]; then
      notice_user="Please install KubeSphere using the root user !"
      echo -e "\033[1;36m$notice_user\033[0m"
      exit 0
    fi
    if [[ $os_info =~ "Ubuntu" ]] && [[ $os_info =~ "18.04" ]]; then
       ps -ef | grep 'apt.systemd.daily' | grep -v grep  >  /dev/null
       if [[ $? -eq 0 ]];then
          notice_apt="Apt program is occupied. Please try again later !"
          echo -e "\033[1;36m$notice_apt\033[0m"
          exit 0
       fi
    fi
}

function result_notes(){
    timeout=0
    info='The ks-installer is running'
    while [ $timeout -le 1200 ]
    do
      clear
      echo -e "\033[1;36m$info\033[0m"
      kubectl exec -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') ls kubesphere/playbooks/kubesphere_running &> /dev/null
      if [[ $? -eq 0 ]]; then
         kubectl exec -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') cat kubesphere/playbooks/kubesphere_running
         break
      else
         i=0
         b=''
         while [ $i -le 10 ]
         do
          printf "Please wait for the installation to complete %s\r" $b;
          sleep 1
          ((timeout=timeout+1))
          ((i=i+2))
          b+='.'
         done
      fi
    done
    echo
}

function failed_prompt(){
  str="failed!"
  echo -e "\033[31;47m$str\033[0m"
  echo "**********************************"
  echo "please refer to https://kubesphere.io/docs/v2.1/zh-CN/faq/faq-install/"
  echo "**********************************"
  exit
}

function config_pip(){
  mkdir ~/.pip
  if [[ ! -f ~/.pip/pip.conf ]]; then
      cat > ~/.pip/pip.conf << EOF
[global]
index-url=https://pypi.tuna.tsinghua.edu.cn/simple
EOF
  fi
}

function region_detection(){
    curl http://ip-api.com/line | grep China
    if [[ $? == 0 ]]; then
        config_pip
    fi
}

function init_env(){

  region_detection &> /dev/null
  $BASE_FOLDER/os/os_check.sh 

  if [[ $? -eq 0 ]]; then
    #statements
    echo "init_env successful" > os/install.tmp
  fi

}

#Get the current path
BASE_FOLDER=$(dirname $(readlink -f "$0"))

LOG_FOLDER=$BASE_FOLDER/../logs
if [ ! -d $LOG_FOLDER ];then
   mkdir -p $LOG_FOLDER
fi
current=`date "+%Y-%m-%d~%H:%M:%S"`
export ANSIBLE_LOG_PATH=$LOG_FOLDER/Install[$current].log
export DEFAULT_FORKS=10
export ANSIBLE_RETRY_FILES_ENABLED=False
export ANSIBLE_CALLBACK_WHITELIST=profile_tasks
export ANSIBLE_TIMEOUT=300
export ANSIBLE_HOST_KEY_CHECKING=False


function all-in-one(){

  storage_sure

  if [[ -f os/install.tmp ]]; then
    grep  "init_env successful" os/install.tmp > /dev/null
    if [[ $? -ne '0' ]]; then
          init_env
    fi
  else
          init_env
  fi

  python os/precheck.py
  cp -f $BASE_FOLDER/../conf/*.yaml $BASE_FOLDER/../k8s/inventory/local/group_vars/k8s-cluster/
#  cp $BASE_FOLDER/../conf/vars.yml $BASE_FOLDER/../k8s/inventory/local/group_vars/k8s-cluster/k8s-cluster.yml

  echo "*********************************************"
  echo "1. Initiating Environment"
  echo "*********************************************"
  ansible-playbook  -i $BASE_FOLDER/../k8s/inventory/local/hosts.ini $BASE_FOLDER/../preinstall/init.yml -b 
  if [[ $? -eq 0 ]]; then
    str="successsful!"
    echo -e "\033[32;47m$str\033[0m"  
  else
    failed_prompt
  fi

  echo "*********************************************"
  echo "2. Installing Kubernetes"
  echo "*********************************************"

  ansible-playbook -i $BASE_FOLDER/../k8s/inventory/local/hosts.ini $BASE_FOLDER/../k8s/cluster.yml -b 
  if [[ $? -eq 0 ]]; then
    #statements
    str="successsful!"
    echo -e "\033[30;47m$str\033[0m"  
  else
    failed_prompt
  fi

  echo "*********************************************"
  echo "3. Installing KubeSphere"
  echo "*********************************************"

  ansible-playbook -i $BASE_FOLDER/../k8s/inventory/local/hosts.ini $BASE_FOLDER/../kubesphere/kubesphere.yml \
                   -b \
                   -e prometheus_replicas=1 \
                   -e ks_console_replicas=1 \
                   -e jenkinsJavaOpts_Xms='512m' \
                   -e jenkinsJavaOpts_Xmx='512m' \
                   -e jenkinsJavaOpts_MaxRAM='2g' \
                   -e jenkins_memory_lim="2Gi" \
                   -e jenkins_memory_req="1500Mi" \
                   -e logsidecar_replicas=1 \
                   -e elasticsearch_data_replicas=1
  if [[ $? -eq 0 ]]; then
    #statements
    str="successsful!"
    echo -e "\033[30;47m$str\033[0m"
    result_notes
  else
    failed_prompt
  fi

}

function multi-node(){

  storage_sure

  if [[ -f os/install.tmp ]]; then
    grep  "init_env successful" os/install.tmp > /dev/null
    if [[ $? -ne '0' ]]; then
          init_env
    fi
  else
          init_env
  fi

  python os/precheck.py
  cp -f $BASE_FOLDER/../conf/hosts.ini $BASE_FOLDER/../k8s/inventory/my_cluster/hosts.ini
  cp -f $BASE_FOLDER/../conf/*.yaml $BASE_FOLDER/../k8s/inventory/my_cluster/group_vars/k8s-cluster/

  ids=`cat -n $BASE_FOLDER/../k8s/inventory/my_cluster/hosts.ini | grep "ansible_user" | grep -v "#" | grep -v "root" | awk '{print $1}'`
  for id in $ids; do
       passwd=`awk '{if(NR==id){print $5}}' id="$id" $BASE_FOLDER/../k8s/inventory/my_cluster/hosts.ini | sed '/^ansible_become_pass=/!d;s/.*=//'`
       sed -i ''$id's/$/&  ansible_ssh_pass\='$passwd'/g'  $BASE_FOLDER/../k8s/inventory/my_cluster/hosts.ini
  done

  echo "*********************************************"
  echo "1. Initiating Environment"
  echo "*********************************************"
  ansible-playbook  -i $BASE_FOLDER/../k8s/inventory/my_cluster/hosts.ini $BASE_FOLDER/../preinstall/init.yml -b
  if [[ $? -eq 0 ]]; then
    #statements
    str="successsful!"
    echo -e "\033[30;47m$str\033[0m"  
  else
    failed_prompt
  fi


  echo "*********************************************"
  echo "2. Installing Kubernetes"
  echo "*********************************************"

  ansible-playbook -i $BASE_FOLDER/../k8s/inventory/my_cluster/hosts.ini $BASE_FOLDER/../k8s/cluster.yml -b
  if [[ $? -eq 0 ]]; then
    #statements
    str="successsful!"
    echo -e "\033[30;47m$str\033[0m"  
  else
    failed_prompt
  fi

  echo "*********************************************"
  echo "3. Installing KubeSphere"
  echo "*********************************************"

  ansible-playbook -i $BASE_FOLDER/../k8s/inventory/my_cluster/hosts.ini $BASE_FOLDER/../kubesphere/kubesphere.yml -b
                    
  if [[ $? -eq 0 ]]; then
    #statements
    str="successsful!"
    echo -e "\033[30;47m$str\033[0m"
    result_notes
  else
    failed_prompt
  fi

}

base_check

#Whether there are parameters after the script，one-node or multi-node 
if [[ 1 -le $# ]]; then
  if [[ "all-in-one" = $1 ]]; then
    all-in-one
    exit
  elif [[ "multi-node" = $1 ]]; then
    multi-node
    exit
  else
    str="failed!,Parameter is wrong , Please check parameter is one or all"
    echo -e "\033[31;47m$str\033[0m"
    exit
  fi
else
  menu
  while true
  do
       # all-in-one tends to install everything on one node.
      read -p "Please input an option: " option
      echo $option

      case $option in
         1)
              all-in-one
              exit
                 ;;
         2)
              multi-node
              exit
                 ;;
         3)
              echo -e "\033[30;47mquit successsful!!\033[0m"
              break
                 ;;
      esac
  done
fi




