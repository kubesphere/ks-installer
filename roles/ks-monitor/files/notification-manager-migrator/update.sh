#!/bin/bash

backup_dir="./backup"
output_dir="./crds"

notification_name=$1
if [ "$notification_name" = "" ]; then
  notification_name="notification-manager"
fi

notification_namespace=$2
if [ "$notification_namespace" = "" ]; then
  notification_namespace="kubesphere-monitoring-system"
fi

mkdir -p $backup_dir
mkdir -p $output_dir

version=$(kubectl get crd notificationmanagers.notification.kubesphere.io -o jsonpath='{.spec.versions[0].name}')

./backup_crds.sh "$version" $notification_name $notification_namespace $backup_dir
./update_crds.sh "$version" $notification_namespace $backup_dir $output_dir
