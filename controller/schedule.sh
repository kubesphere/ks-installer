#!/usr/bin/env bash

if [[ $1 == "--config" ]] ; then
  cat <<EOF
{
  "configVersion":"v1",
  "schedule": [
    {
      "allowFailure": true,
      "name": "every month",
      "crontab": "0 0 1 * *"
    }
  ]
}
EOF
else
  ansible-playbook /kubesphere/playbooks/telemetry.yaml -e @/kubesphere/config/ks-config.json
  if [[ $? -eq 0 ]]; then
    #statements
    str="successful!"
    echo -e "$str"
  else
    exit
  fi

fi

