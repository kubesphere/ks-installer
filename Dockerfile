FROM kubespheredev/shell-operator:v1.0.0-beta.5-alpine3.12


ENV  ANSIBLE_ROLES_PATH /kubesphere/installer/roles

ADD controller/schedule.py /hooks/kubesphere
ADD controller/installRunner.py /hooks/kubesphere
ADD roles /kubesphere/installer/roles
ADD env /kubesphere/results/env
ADD playbooks /kubesphere/playbooks
