#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

function wait_status_ok(){
    for ((n=0;n<30;n++))
    do  
        OK=`kubectl get pod -A| grep -E 'Running|Completed' | wc | awk '{print $1}'`
        Status=`kubectl get pod -A | sed '1d' | wc | awk '{print $1}'`
        echo "Success rate: ${OK}/${Status}"
        if [[ $OK == $Status ]]
        then
            n=$((n+1))
        else
            n=0
        fi
        sleep 10
        kubectl get all -A
    done
}

function check_installer_ok(){
    echo "waiting for ks-installer pod ready"
    kubectl -n kubesphere-system wait --timeout=180s --for=condition=Ready $(kubectl -n kubesphere-system get pod -l app=ks-install -oname)
    echo "waiting for KubeSphere ready"
    while IFS= read -r line; do
        echo $line
        if [[ $line =~ "Welcome to KubeSphere" ]]
            then
                return
        fi
    done < <(timeout 10 kubectl logs -n kubesphere-system deploy/ks-installer -f)
    echo "ks-install not output 'Welcome to KubeSphere'"
    sleep 20
    exit 1
}

yum install -y vim openssl socat conntrack ipset wget
wget https://github.com/kubesphere/kubekey/releases/download/v1.0.0/kubekey-v1.0.0-linux-amd64.tar.gz
tar xvf kubekey-v1.0.0-linux-amd64.tar.gz
ls -al
chmod +x ./kk
./kk create cluster --with-kubernetes v1.17.9 -y

kubectl apply -f https://openebs.github.io/charts/openebs-operator.yaml
wait_status_ok
kubectl patch storageclass openebs-hostpath -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

kubectl apply -f https://raw.githubusercontent.com/kubesphere/ks-installer/master/deploy/kubesphere-installer.yaml
kubectl apply -f https://raw.githubusercontent.com/kubesphere/ks-installer/master/deploy/cluster-configuration.yaml

kubectl -n kubesphere-system get cc ks-installer -o yaml | sed "s/false/true/g" | kubectl replace -n kubesphere-system cc -f -

kubectl -n kubesphere-system patch cc ks-installer --type merge --patch '{"spec":{"etcd":{"monitoring":false}}}'
kubectl -n kubesphere-system patch cc ks-installer --type merge --patch '{"spec":{"etcd":{"tlsEnable":false}}}'
kubectl -n kubesphere-system patch cc ks-installer --type merge --patch '{"spec":{"kubeedge":{"enabled":false}}}'

kubectl -n kubesphere-system rollout restart deploy ks-installer
wait_status_ok
check_installer_ok
kubectl get all -A
