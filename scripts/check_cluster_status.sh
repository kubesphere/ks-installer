#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

function check_installer_ok(){
    echo "waiting for ks-installer pod ready"
    kubectl -n kubesphere-system wait --timeout=180s --for=condition=Available deployment/ks-installer
    kubectl -n kubesphere-system wait --timeout=180s --for=condition=Ready $(kubectl -n kubesphere-system get pod -l app=ks-install -oname)
    echo "waiting for KubeSphere ready"
    while IFS= read -r line; do
        echo "$line"
        if [[ $line =~ "Welcome to KubeSphere" ]]
            then
                return
        fi
    done < <(timeout 1800 kubectl logs -n kubesphere-system deploy/ks-installer -f --tail 1)
    echo "ks-installer not output 'Welcome to KubeSphere'"
    exit 1
}

function wait_status_ok(){
    for ((n=0;n<60;n++))
    do
        OK=`kubectl get pod -A| grep -E 'Running|Completed' | wc | awk '{print $1}'`
        Status=`kubectl get pod -A | sed '1d' | wc | awk '{print $1}'`
        echo "Success rate: ${OK}/${Status}"
        if [[ $OK == $Status ]]
        then
            n=$((n+1))
        else
            n=0
            kubectl get pod -A | grep -vE 'Running|Completed'
        fi
        sleep 1
    done
}

export -f wait_status_ok

check_installer_ok

timeout 1800 bash -c wait_status_ok
