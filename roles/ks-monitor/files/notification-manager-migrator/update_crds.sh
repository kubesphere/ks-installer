#!/bin/bash

V1alpha1="v1alpha1"
V2alpha1="v2alpha1"
V2beta1="v2beta1"

version=$1
notification_namespace=$2
input_dir=$3
output_dir=$4

delete_invalid_info() {
  dest=$1
  dest=${dest%\"}
  dest=${dest#\"}
  dest=$(echo "$dest" |
    jq 'del(.metadata.namespace)' |
    jq 'del(.metadata.creationTimestamp)' |
    jq 'del(.metadata.generation)' |
    jq 'del(.metadata.managedFields)' |
    jq 'del(.metadata.resourceVersion)' |
    jq 'del(.metadata.selfLink)' |
    jq 'del(.metadata.uid)' |
    jq 'delpaths([["metadata","annotations", "kubectl.kubernetes.io/last-applied-configuration"]])' |
    jq 'delpaths([["metadata","annotations", "reloadtimestamp"]])')
  echo "$dest"
}

update_v1alpha1() {

  files=$(ls "$input_dir")
  for file in $files; do

    src=$(jq '.' "$input_dir/$file")
    namespace=$(echo "$src" | jq -r '.metadata.namespace')
    kind=$(echo "$src" | jq -r '.kind')

    resource=$(echo "$src" | jq 'setpath(["apiVersion"]; "notification.kubesphere.io/v2beta1")')
    name=$(echo "$kind" | awk '{ print tolower($0) }')-$(echo "$resource" | jq -r '.metadata.namespace')-$(echo "$resource" | jq -r '.metadata.name')
    resource=$(echo "$resource" | jq --arg name "$name" 'setpath(["metadata", "name"]; $name)' | jq 'del(.metadata.namespace)')
    resource=$(delete_invalid_info "\"$(echo "$resource" | jq -c)\"")

    if [[ "$kind" == *Config ]]; then
      resource=$(echo "$resource" | jq 'setpath(["kind"]; "Config")')
    elif [[ "$kind" == *Receiver ]]; then
      resource=$(echo "$resource" | jq 'setpath(["kind"]; "Receiver")')
    else
      continue
    fi

    type=""
    if [[ "$kind" == DingTalk* ]]; then
      type="dingtalk"
    elif [[ "$kind" == Email* ]]; then
      type="email"
    elif [[ "$kind" == Slack* ]]; then
      type="slack"
    elif [[ "$kind" == Webhook* ]]; then
      type="webhook"
    elif [[ "$kind" == Wechat* ]]; then
      type="wechat"
    else
      continue
    fi

    resource=$(echo "$resource" | jq --arg type $type 'setpath(["spec", $type]; .spec)')
    str=$(echo "$resource" | jq '.spec' | jq 'keys')
    # shellcheck disable=SC2001
    str=$(echo "$str" | sed 's/\"//g')
    # shellcheck disable=SC2001
    str=$(echo "$str" | sed 's/\[//g')
    # shellcheck disable=SC2001
    str=$(echo "$str" | sed 's/\]//g')
    # shellcheck disable=SC2206
    keys=(${str//,/ })

    for ((j = 0; j < ${#keys[@]}; j++)); do
      if [ "${keys[j]}" = "$type" ]; then
        continue
      fi

      resource=$(echo "$resource" | jq --arg key "${keys[j]}" 'delpaths([["spec", $key]])')
    done

    if [ "$kind" = "DingTalkConfig" ]; then

      if [ "$(echo "$resource" | jq '.spec.dingtalk' | jq 'has("conversation")')" = "true" ]; then
        config=$(echo "$resource" |
          jq --arg ns "$namespace" 'setpath(["spec", "dingtalk", "conversation", "appkey", "namespace"]; $ns)' |
          jq --arg ns "$namespace" 'setpath(["spec", "dingtalk", "conversation", "appsecret", "namespace"]; $ns)' |
          jq 'del(.spec.dingtalk.conversation.chatid)' |
          jq 'del(.spec.dingtalk.chatbot)')

        echo "$config" | jq >"${output_dir}/$(echo "$config" | jq -r '.metadata.name').json"
      fi

      name=dingtalkreceiver-$(echo "$src" | jq -r '.metadata.namespace')-$(echo "$src" | jq -r '.metadata.name')
      resource=$(echo "$resource" |
        jq 'setpath(["kind"]; "Receiver")' |
        jq --arg name "$name" 'setpath(["metadata", "name"]; $name)')

      if [ "default" = "$(echo "$receiver" | jq -r '.metadata.labels.type')" ]; then
        resource=$(echo "$resource" |
          jq 'setpath(["metadata","labels", "type"]; "global")')
      fi

      if [ "$(echo "$resource" | jq '.spec.dingtalk' | jq 'has("chatbot")')" = "true" ]; then
        resource=$(echo "$resource" |
          jq --arg ns "$namespace" 'setpath(["spec", "dingtalk", "chatbot", "webhook", "namespace"]; $ns)')

        if [ "$(echo "$resource" | jq '.spec.dingtalk.chatbot' | jq 'has("secret")')" = "true" ]; then
          resource=$(echo "$resource" |
            jq --arg ns "$namespace" 'setpath(["spec", "dingtalk", "chatbot", "secret", "namespace"]; $ns)')
        fi
      fi

      if [ "$(echo "$resource" | jq '.spec.dingtalk' | jq 'has("conversation")')" = "true" ]; then
        resource=$(echo "$resource" |
          jq 'setpath(["spec", "dingtalk", "conversation", "chatids"]; [.spec.dingtalk.conversation.chatid])' |
          jq 'del(.spec.dingtalk.conversation.chatid)' |
          jq 'del(.spec.dingtalk.conversation.appkey)' |
          jq 'del(.spec.dingtalk.conversation.appsecret)')
      fi
    fi

    if [ "$kind" = "EmailConfig" ]; then

      resource=$(echo "$resource" |
        jq --arg ns "$namespace" 'setpath(["spec", "email", "authPassword", "namespace"]; $ns)')

      if [ "$(echo "$resource" | jq '.spec.email' | jq 'has("authSecret")')" = "true" ]; then
        resource=$(echo "$resource" |
          jq --arg ns "$namespace" 'setpath(["spec", "email", "authSecret", "namespace"]; $ns)')
      fi

      if [ "$(echo "$config" | jq '.spec.email' | jq 'has("tls")')" = "true" ]; then
        resource=$(echo "$resource" |
          jq --arg ns "$namespace" 'setpath(["spec", "email", "tls", "rootCA", "namespace"]; $ns)' |
          jq --arg ns "$namespace" 'setpath(["spec", "email", "tls", "clientCertificate", "cert", "namespace"]; $ns)' |
          jq --arg ns "$namespace" 'setpath(["spec", "email", "tls", "clientCertificate", "key", "namespace"]; $ns)')
      fi

      port=$(echo "$resource" | jq -r '.spec.email.smartHost.port')
      resource=$(echo "$resource" | jq --argjson port "$port" 'setpath(["spec", "email", "smartHost", "port"]; $port)')
    fi

    if [ "$kind" = "SlackConfig" ]; then
      resource=$(echo "$resource" |
        jq --arg ns "$namespace" 'setpath(["spec", "slack", "slackTokenSecret", "namespace"]; $ns)')
    fi

    if [ "$kind" = "SlackReceiver" ]; then
      resource=$(echo "$resource" |
        jq 'setpath(["spec", "slack", "channels"]; [.spec.slack.channel])' |
        jq 'del(.spec.slack.channel)')
    fi

    if [ "$kind" = "WebhookConfig" ]; then

      name=webhookreceiver-$(echo "$src" | jq -r '.metadata.namespace')-$(echo "$src" | jq -r '.metadata.name')
      resource=$(echo "$resource" | jq 'setpath(["kind"]; "Receiver")' |
        jq --arg name "$name" 'setpath(["metadata", "name"]; $name)')

      if [ "$(echo "$resource" | jq '.spec.webhook' | jq 'has("httpConfig")')" = "true" ]; then
        if [ "$(echo "$resource" | jq '.spec.webhook.httpConfig' | jq 'has("basicAuth")')" = "true" ]; then
          resource=$(echo "$resource" |
            jq --arg ns "$namespace" 'setpath(["spec", "webhook", "httpConfig", "basicAuth", "password", "namespace"]; $ns)')
        fi

        if [ "$(echo "$resource" | jq '.spec.webhook.httpConfig' | jq 'has("bearerToken")')" = "true" ]; then
          resource=$(echo "$resource" |
            jq --arg ns "$namespace" 'setpath(["spec", "webhook", "httpConfig", "bearerToken", "namespace"]; $ns)')
        fi

        if [ "$(echo "$resource" | jq '.spec.webhook.httpConfig' | jq 'has("tlsConfig")')" = "true" ]; then
          if [ "$(echo "$resource" | jq '.spec.webhook.httpConfig.tlsConfig' | jq 'has("rootCA")')" = "true" ]; then
            resource=$(echo "$resource" |
              jq --arg ns "$namespace" 'setpath(["spec", "webhook", "httpConfig", "tlsConfig", "rootCA", "namespace"]; $ns)')
          fi

          if [ "$(echo "$resource" | jq '.spec.webhook.httpConfig.tlsConfig' | jq 'has("clientCertificate")')" = "true" ]; then
            resource=$(echo "$resource" |
              jq --arg ns "$namespace" 'setpath(["spec", "webhook", "httpConfig", "tlsConfig", "clientCertificate", "cert", "namespace"]; $ns)' |
              jq --arg ns "$namespace" 'setpath(["spec", "webhook", "httpConfig", "tlsConfig", "clientCertificate", "key", "namespace"]; $ns)')
          fi
        fi
      fi

      if [ "default" = "$(echo "$resource" | jq -r '.metadata.labels.type')" ]; then
        resource=$(echo "$resource" |
          jq 'setpath(["metadata","labels", "type"]; "global")')
      fi

    fi

    if [ "$kind" = "WechatConfig" ]; then
      resource=$(echo "$resource" |
        jq --arg ns "$namespace" 'setpath(["spec", "wechat", "wechatApiSecret", "namespace"]; $ns)')
    fi

    if [ "$kind" = "WechatReceiver" ]; then

      if [ "$(echo "$resource" | jq '.spec.wechat' | jq 'has("toUser")')" = "true" ]; then
        toUser=$(echo "$resource" | jq -r '.spec.wechat.toUser')
        # shellcheck disable=SC2206
        users=(${toUser//|/ })

        receiver=$(echo "$resource" | jq 'setpath(["spec", "wechat", "toUser"]; [])')
        for ((j = 0; j < ${#users[@]}; j++)); do
          resource=$(echo "$receiver" | jq --arg user "${users[j]}" '.spec.wechat.toUser |= .+ [$user]')
        done
      fi

      if [ "$(echo "$resource" | jq '.spec.wechat' | jq 'has("toParty")')" = "true" ]; then
        toParty=$(echo "$resource" | jq -r '.spec.wechat.toParty')
        # shellcheck disable=SC2206
        parties=(${toParty//|/ })

        resource=$(echo "$resource" | jq 'setpath(["spec", "wechat", "toParty"]; [])')
        for ((j = 0; j < ${#parties[@]}; j++)); do
          resource=$(echo "$resource" | jq --arg party "${parties[j]}" '.spec.wechat.toParty |= .+ [$party]')
        done
      fi

      if [ "$(echo "$resource" | jq '.spec.wechat' | jq 'has("toTag")')" = "true" ]; then
        toTag=$(echo "$resource" | jq -r '.spec.wechat.toTag')
        # shellcheck disable=SC2206
        tags=(${toTag//|/ })

        resource=$(echo "$resource" | jq 'setpath(["spec", "wechat", "toTag"]; [])')
        for ((j = 0; j < ${#tags[@]}; j++)); do
          resource=$(echo "$resource" | jq --arg tag "${tags[j]}" '.spec.wechat.toTag |= .+ [$tag]')
        done
      fi
    fi

    echo "$resource" | jq >"${output_dir}/$(echo "$resource" | jq -r '.metadata.name').json"
  done
}

update_v2alpha1() {

  files=$(ls "$input_dir")
  for file in $files; do

    src=$(jq '.' "$input_dir/$file")
    ns="$notification_namespace"
    kind=$(echo "$src" | jq -r '.kind')

    if [ "$kind" = "NotificationManager" ]; then
      continue
    fi

    resource=$(echo "$src" | jq 'setpath(["apiVersion"]; "notification.kubesphere.io/v2beta1")')
    name=$(echo "$kind" | awk '{ print tolower($0) }')-$(echo "$resource" | jq -r '.metadata.name')
    resource=$(echo "$resource" | jq --arg name "$name" 'setpath(["metadata", "name"]; $name)')
    resource=$(delete_invalid_info "\"$(echo "$resource" | jq -c)\"")

    if [[ "$kind" == *Config ]]; then
      resource=$(echo "$resource" | jq 'setpath(["kind"]; "Config")')
    elif [[ "$kind" == *Receiver ]]; then
      resource=$(echo "$resource" | jq 'setpath(["kind"]; "Receiver")')
    else
      continue
    fi

    type=""
    if [[ "$kind" == DingTalk* ]]; then
      type="dingtalk"
    elif [[ "$kind" == Email* ]]; then
      type="email"
    elif [[ "$kind" == Slack* ]]; then
      type="slack"
    elif [[ "$kind" == Webhook* ]]; then
      type="webhook"
    elif [[ "$kind" == Wechat* ]]; then
      type="wechat"
    else
      continue
    fi

    resource=$(echo "$resource" | jq --arg type $type 'setpath(["spec", $type]; .spec)')
    str=$(echo "$resource" | jq '.spec' | jq 'keys')
    # shellcheck disable=SC2001
    str=$(echo "$str" | sed 's/\"//g')
    # shellcheck disable=SC2001
    str=$(echo "$str" | sed 's/\[//g')
    # shellcheck disable=SC2001
    str=$(echo "$str" | sed 's/\]//g')
    # shellcheck disable=SC2206
    keys=(${str//,/ })

    for ((j = 0; j < ${#keys[@]}; j++)); do
      if [ "${keys[j]}" = "$type" ]; then
        continue
      fi

      resource=$(echo "$resource" | jq --arg key "${keys[j]}" 'delpaths([["spec", $key]])')
    done

    if [[ "$kind" == "DingTalkConfig" ]]; then
      if [ "$(echo "$resource" | jq '.spec.dingtalk' | jq 'has("conversation")')" = "true" ]; then
        resource=$(echo "$resource" |
          jq --arg ns "$ns" 'setpath(["spec", "dingtalk", "conversation", "appkey", "namespace"]; $ns)' |
          jq --arg ns "$ns" 'setpath(["spec", "dingtalk", "conversation", "appsecret", "namespace"]; $ns)')
      fi

      if [ "$(echo "$resource" | jq '.spec.dingtalk')" = "null" ]; then
        continue
      fi
    fi

    if [[ "$kind" == "DingTalkReceiver" ]]; then
      if [ "$(echo "$resource" | jq '.spec.dingtalk' | jq 'has("chatbot")')" = "true" ]; then
        resource=$(echo "$resource" |
          jq --arg ns "$ns" 'setpath(["spec", "dingtalk", "chatbot", "webhook", "namespace"]; $ns)')
        if [ "$(echo "$resource" | jq '.spec.dingtalk.chatbot' | jq 'has("secret")')" = "true" ]; then
          resource=$(echo "$resource" |
            jq --arg ns "$ns" 'setpath(["spec", "dingtalk", "chatbot", "secret", "namespace"]; $ns)')
        fi
      fi

      if [ "$(echo "$resource" | jq '.spec.dingtalk' | jq 'has("conversation")')" = "true" ]; then
        resource=$(
          echo "$resource" |
            jq 'setpath(["spec", "dingtalk", "conversation", "chatids"]; [.spec.dingtalk.conversation.chatid])'
          jq 'del(.spec.dingtalk.conversation.chatid)'
        )
      fi
    fi

    if [[ "$kind" == "EmailConfig" ]]; then
      port=$(echo "$resource" | jq -r '.spec.email.smartHost.port')
      resource=$(echo "$resource" |
        jq --argjson port "$port" 'setpath(["spec", "email", "smartHost", "port"]; $port)' |
        jq --arg ns "$ns" 'setpath(["spec", "email", "authPassword", "namespace"]; $ns)')

      if [ "$(echo "$resource" | jq '.spec.email' | jq 'has("authSecret")')" = "true" ]; then
        resource=$(echo "$resource" |
          jq --arg ns "$ns" 'setpath(["spec", "email", "authSecret", "namespace"]; $ns)')
      fi

      if [ "$(echo "$resource" | jq '.spec.email' | jq 'has("tls")')" = "true" ]; then
        resource=$(echo "$resource" |
          jq --arg ns "$ns" 'setpath(["spec", "email", "tls", "rootCA", "namespace"]; $ns)' |
          jq --arg ns "$ns" 'setpath(["spec", "email", "tls", "clientCertificate", "cert", "namespace"]; $ns)' |
          jq --arg ns "$ns" 'setpath(["spec", "email", "tls", "clientCertificate", "key", "namespace"]; $ns)')
      fi
    fi

    if [[ "$kind" == "SlackConfig" ]]; then
      resource=$(echo "$resource" |
        jq --arg ns "$ns" 'setpath(["spec", "slack", "slackTokenSecret", "namespace"]; $ns)')
    fi

    if [[ "$kind" == "SlackReceiver" ]]; then
      resource=$(echo "$resource" |
        jq 'setpath(["spec", "slack", "channels"]; [.spec.slack.channel])' |
        jq 'del(.spec.slack.channel)')
    fi

    if [[ "$kind" == "WebhookConfig" ]]; then
      continue
    fi

    if [[ "$kind" == "WebhookReceiver" ]]; then
      if [ "$(echo "$resource" | jq '.spec.webhook' | jq 'has("httpConfig")')" = "true" ]; then
        if [ "$(echo "$resource" | jq '.spec.webhook.httpConfig' | jq 'has("basicAuth")')" = "true" ]; then
          resource=$(echo "$resource" |
            jq --arg ns "$ns" 'setpath(["spec", "webhook", "httpConfig", "basicAuth", "password", "namespace"]; $ns)')
        fi

        if [ "$(echo "$resource" | jq '.spec.webhook.httpConfig' | jq 'has("bearerToken")')" = "true" ]; then
          resource=$(echo "$resource" |
            jq --arg ns "$ns" 'setpath(["spec", "webhook", "httpConfig", "bearerToken", "namespace"]; $ns)')
        fi

        if [ "$(echo "$resource" | jq '.spec.webhook.httpConfig' | jq 'has("tlsConfig")')" = "true" ]; then
          if [ "$(echo "$resource" | jq '.spec.webhook.httpConfig.tlsConfig' | jq 'has("rootCA")')" = "true" ]; then
            resource=$(echo "$resource" |
              jq --arg ns "$ns" 'setpath(["spec", "webhook", "httpConfig", "tlsConfig", "rootCA", "namespace"]; $ns)')
          fi

          if [ "$(echo "$resource" | jq '.spec.webhook.httpConfig.tlsConfig' | jq 'has("clientCertificate")')" = "true" ]; then
            resource=$(echo "$resource" |
              jq --arg ns "$ns" 'setpath(["spec", "webhook", "httpConfig", "tlsConfig", "clientCertificate", "cert", "namespace"]; $ns)' |
              jq --arg ns "$ns" 'setpath(["spec", "webhook", "httpConfig", "tlsConfig", "clientCertificate", "key", "namespace"]; $ns)')
          fi
        fi
      fi
    fi

    if [[ "$kind" == "WechatConfig" ]]; then
      resource=$(echo "$resource" |
        jq --arg ns "$ns" 'setpath(["spec", "wechat", "wechatApiSecret", "namespace"]; $ns)')
    fi

    if [[ "$kind" == "WechatReceiver" ]]; then

      if [ "$(echo "$resource" | jq '.spec.wechat' | jq 'has("toUser")')" = "true" ]; then
        toUser=$(echo "$resource" | jq -r '.spec.wechat.toUser')
        # shellcheck disable=SC2206
        users=(${toUser//|/ })

        resource=$(echo "$resource" | jq 'setpath(["spec", "wechat", "toUser"]; [])')
        for ((j = 0; j < ${#users[@]}; j++)); do
          resource=$(echo "$resource" | jq --arg user "${users[j]}" '.spec.wechat.toUser |= .+ [$user]')
        done
      fi

      if [ "$(echo "$resource" | jq '.spec.wechat' | jq 'has("toParty")')" = "true" ]; then
        toParty=$(echo "$resource" | jq -r '.spec.wechat.toParty')
        # shellcheck disable=SC2206
        parties=(${toParty//|/ })

        resource=$(echo "$resource" | jq 'setpath(["spec", "wechat", "toParty"]; [])')
        for ((j = 0; j < ${#parties[@]}; j++)); do
          resource=$(echo "$resource" | jq --arg party "${parties[j]}" '.spec.wechat.toParty |= .+ [$party]')
        done
      fi

      if [ "$(echo "$resource" | jq '.spec.wechat' | jq 'has("toTag")')" = "true" ]; then
        toTag=$(echo "$resource" | jq -r '.spec.wechat.toTag')
        # shellcheck disable=SC2206
        tags=(${toTag//|/ })

        resource=$(echo "$resource" | jq 'setpath(["spec", "wechat", "toTag"]; [])')
        for ((j = 0; j < ${#tags[@]}; j++)); do
          resource=$(echo "$resource" | jq --arg tag "${tags[j]}" '.spec.wechat.toTag |= .+ [$tag]')
        done
      fi
    fi

    echo "$resource" | jq >"${output_dir}/$(echo "$resource" | jq -r '.metadata.name').json"

  done
}

version=$(kubectl get crd notificationmanagers.notification.kubesphere.io -o jsonpath='{.spec.versions[0].name}')

if [ "${version}" = "$V1alpha1" ]; then
  update_v1alpha1
elif [ "${version}" = "$V2alpha1" ]; then
  update_v2alpha1
elif [ "${version}" = "$V2beta1" ]; then
  echo "This is the latest version"
else
  echo "Unknown version"
fi
