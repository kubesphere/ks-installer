#!/bin/bash

V1alpha1="v1alpha1"
V2alpha1="v2alpha1"
V2beta1="v2beta1"

version=$1
notification_name=$2
notification_namespace=$3
backup_dir=$4

mkdir -p "$backup_dir"

backup_v1alpha1() {
  # export dingtalk config
  str=$(kubectl get dingtalkconfigs.notification.kubesphere.io -A | sed -n '1!p' | awk '{print $1}')
  # shellcheck disable=SC2206
  ns=($str)

  str=$(kubectl get dingtalkconfigs.notification.kubesphere.io -A | sed -n '1!p' | awk '{print $2}')
  # shellcheck disable=SC2206
  dingtalkconfigs=($str)

  for ((i = 0; i < ${#ns[@]}; i++)); do
    src=$(kubectl get dingtalkconfigs.notification.kubesphere.io "${dingtalkconfigs[i]}" -n "${ns[i]}" -ojson)
    echo "$src" | jq >"${backup_dir}/dingtalkconfig-$(echo "$src" | jq -r '.metadata.namespace')-$(echo "$src" | jq -r '.metadata.name').json"
  done

  # export email config
  str=$(kubectl get emailconfigs.notification.kubesphere.io -A | sed -n '1!p' | awk '{print $1}')
  # shellcheck disable=SC2206
  ns=($str)

  str=$(kubectl get emailconfigs.notification.kubesphere.io -A | sed -n '1!p' | awk '{print $2}')
  # shellcheck disable=SC2206
  emailconfigs=($str)

  for ((i = 0; i < ${#ns[@]}; i++)); do
    src=$(kubectl get emailconfigs.notification.kubesphere.io "${emailconfigs[i]}" -n "${ns[i]}" -ojson)
    echo "$src" | jq >"${backup_dir}/emailconfig-$(echo "$src" | jq -r '.metadata.namespace')-$(echo "$src" | jq -r '.metadata.name').json"
  done

  # export email receiver
  str=$(kubectl get emailreceivers.notification.kubesphere.io -A | sed -n '1!p' | awk '{print $1}')
  # shellcheck disable=SC2206
  ns=($str)

  str=$(kubectl get emailreceivers.notification.kubesphere.io -A | sed -n '1!p' | awk '{print $2}')
  # shellcheck disable=SC2206
  emailreceivers=($str)

  for ((i = 0; i < ${#ns[@]}; i++)); do
    src=$(kubectl get emailreceivers.notification.kubesphere.io "${emailreceivers[i]}" -n "${ns[i]}" -ojson)
    echo "$src" | jq >"${backup_dir}/emailreceiver-$(echo "$src" | jq -r '.metadata.namespace')-$(echo "$src" | jq -r '.metadata.name').json"
  done

  # export slack config
  str=$(kubectl get slackconfigs.notification.kubesphere.io -A | sed -n '1!p' | awk '{print $1}')
  # shellcheck disable=SC2206
  ns=($str)

  str=$(kubectl get slackconfigs.notification.kubesphere.io -A | sed -n '1!p' | awk '{print $2}')
  # shellcheck disable=SC2206
  slackconfigs=($str)

  for ((i = 0; i < ${#ns[@]}; i++)); do
    src=$(kubectl get slackconfigs.notification.kubesphere.io "${slackconfigs[i]}" -n "${ns[i]}" -ojson)
    echo "$src" | jq >"${backup_dir}/slackconfig-$(echo "$src" | jq -r '.metadata.namespace')-$(echo "$src" | jq -r '.metadata.name').json"
  done

  # export slack receiver
  str=$(kubectl get slackreceivers.notification.kubesphere.io -A | sed -n '1!p' | awk '{print $1}')
  # shellcheck disable=SC2206
  ns=($str)

  str=$(kubectl get slackreceivers.notification.kubesphere.io -A | sed -n '1!p' | awk '{print $2}')
  # shellcheck disable=SC2206
  slackreceivers=($str)

  for ((i = 0; i < ${#ns[@]}; i++)); do
    src=$(kubectl get slackreceivers.notification.kubesphere.io "${slackreceivers[i]}" -n "${ns[i]}" -ojson)
    echo "$src" | jq >"${backup_dir}/slackreceiver-$(echo "$src" | jq -r '.metadata.namespace')-$(echo "$src" | jq -r '.metadata.name').json"

  done

  # export webhook config
  str=$(kubectl get webhookconfigs.notification.kubesphere.io -A | sed -n '1!p' | awk '{print $1}')
  # shellcheck disable=SC2206
  ns=($str)

  str=$(kubectl get webhookconfigs.notification.kubesphere.io -A | sed -n '1!p' | awk '{print $2}')
  # shellcheck disable=SC2206
  webhookconfigs=($str)

  for ((i = 0; i < ${#ns[@]}; i++)); do
    src=$(kubectl get webhookconfigs.notification.kubesphere.io "${webhookconfigs[i]}" -n "${ns[i]}" -ojson)
    echo "$src" | jq >"${backup_dir}"/webhookconfig-"$(echo "$src" | jq -r '.metadata.namespace')"-"$(echo "$src" | jq -r '.metadata.name')".json
  done

  # export wechat config
  str=$(kubectl get wechatconfigs.notification.kubesphere.io -A | sed -n '1!p' | awk '{print $1}')
  # shellcheck disable=SC2206
  ns=($str)

  str=$(kubectl get wechatconfigs.notification.kubesphere.io -A | sed -n '1!p' | awk '{print $2}')
  # shellcheck disable=SC2206
  wechatconfigs=($str)

  for ((i = 0; i < ${#ns[@]}; i++)); do
    src=$(kubectl get wechatconfigs.notification.kubesphere.io "${wechatconfigs[i]}" -n "${ns[i]}" -ojson)
    echo "$src" | jq >"${backup_dir}/wechatconfig-$(echo "$src" | jq -r '.metadata.namespace')-$(echo "$src" | jq -r '.metadata.name').json"
  done

  # export wechat receiver
  str=$(kubectl get wechatreceivers.notification.kubesphere.io -A | sed -n '1!p' | awk '{print $1}')
  # shellcheck disable=SC2206
  ns=($str)

  str=$(kubectl get wechatreceivers.notification.kubesphere.io -A | sed -n '1!p' | awk '{print $2}')
  # shellcheck disable=SC2206
  wechatreceivers=($str)

  for ((i = 0; i < ${#ns[@]}; i++)); do
    src=$(kubectl get wechatreceivers.notification.kubesphere.io "${wechatreceivers[i]}" -n "${ns[i]}" -ojson)
    echo "$src" | jq >"${backup_dir}/wechatreceiver-$(echo "$src" | jq -r '.metadata.namespace')-$(echo "$src" | jq -r '.metadata.name').json"
  done
}

backup_v2alpha1() {
  str=$(kubectl get notification-manager | sed -n '1!p' | awk '{print $1}')
  # shellcheck disable=SC2206
  array=($str)

  for ((i = 0; i < ${#array[@]}; i++)); do

    if [ "name" = "${array[i]}" ]; then
      continue
    fi

    # shellcheck disable=SC2206
    names=(${array[i]//\// })

    if [ "${#names[@]}" = "1" ]; then
      continue
    fi

    src=$(kubectl get "${names[0]}" "${names[1]}" -ojson)
    kind=$(echo "$src" | jq -r '.kind')$(echo "$src" | jq -r '.kind' | awk '{ print tolower($0) }')
    echo "$src" | jq >"${backup_dir}/$kind-$(echo "$src" | jq -r '.metadata.name').json"
  done
}

if [ "${version}" = "$V1alpha1" ]; then
  backup_v1alpha1
elif [ "${version}" = "$V2alpha1" ]; then
  backup_v2alpha1
elif [ "${version}" = "$V2beta1" ]; then
  echo "This is the latest version"
else
  echo "Unknown version"
fi
