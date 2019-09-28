FROM flant/shell-operator:latest-alpine3.9

RUN apk --no-cache add  gcc  musl-dev libffi-dev openssl-dev linux-headers python2-dev py-pip make openssl curl && \
    pip install --no-cache-dir psutil ansible_runner ansible && \
    wget https://get.helm.sh/helm-v2.10.0-linux-amd64.tar.gz && \
    tar -zxf helm-v2.10.0-linux-amd64.tar.gz && \
    mv linux-amd64/helm /bin/helm && \
    rm -rf *linux-amd64* && \
    chmod +x /bin/helm && \
    ln -s /bin/kubectl /usr/local/bin/kubectl && \
    ln -s /bin/helm /usr/local/bin/helm && \
    mkdir -p /hooks/kubesphere /kubesphere/installer/roles /kubesphere/env /kubesphere/playbooks

ENV  ANSIBLE_ROLES_PATH /kubesphere/installer/roles

ADD controller/installer.py /hooks/kubesphere
ADD kubesphere.yaml /kubesphere/installer
ADD roles /kubesphere/installer/roles
ADD env /kubesphere/env
ADD playbooks /kubesphere/playbooks