function wait_status_ok(){
    for ((n=0;n<30;n++))
    do
        # Get the number of Running or Completed stats of all pods.
        OK=$(kubectl get pod -A| grep -cE 'Running|Completed')
        # Get the number of pod of the whole cluster.
        Status=$(kubectl get pod -A | sed '1d' | wc -l)
        # print the success rate.
        echo "Success rate: ${OK}/${Status}"
        if [[ $OK == $Status ]]
        then
            n=$((n+1))
        else
            n=0
        fi
        # loop for 30 times every 10 seconds.
        sleep 10
        kubectl get all -A
    done
}

# install the linux packages.
yum install -y vim openssl socat conntrack ipset wget
# download the kubeKey
curl -sfL https://get-kk.kubesphere.io | VERSION=v1.1.0 sh -
chmod +x kk
echo "yes" | ./kk create cluster --with-kubernetes v1.20.4

# Use openebs-operator to install the OpenEBS storage.
kubectl apply -f https://openebs.github.io/charts/openebs-operator.yaml
wait_status_ok
# Setup the openebs-hostpath as default storageClass.
kubectl patch storageclass openebs-hostpath -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
# Online download the kubesphere-installer.yaml file.
kubectl apply -f https://raw.githubusercontent.com/kubesphere/ks-installer/master/deploy/kubesphere-installer.yaml
# Online download the cluster-configuration.yaml file.
kubectl apply -f https://raw.githubusercontent.com/kubesphere/ks-installer/master/deploy/cluster-configuration.yaml
# Edit ks-installer configmap, and replace the false with true.
kubectl -n kubesphere-system get cc ks-installer -o yaml | sed "s/false/true/g" | kubectl replace -n kubesphere-system cc -f -
# update configmap ks-installer and add new etcd to spec.
kubectl -n kubesphere-system patch cc ks-installer --type merge --patch '{"spec":{"etcd":{"monitoring":false}}}'
kubectl -n kubesphere-system patch cc ks-installer --type merge --patch '{"spec":{"etcd":{"tlsEnable":false}}}'
# restart the deployment ks-installer.
kubectl -n kubesphere-system rollout restart deploy ks-installer