FROM flant/shell-operator:v1.0.0-beta.5-alpine3.9

RUN apk --no-cache add  gcc  musl-dev libffi-dev openssl-dev linux-headers python2-dev py-pip make openssl curl unzip && \
    pip install --no-cache-dir psutil ansible_runner ansible redis && \
    wget https://get.helm.sh/helm-v2.10.0-linux-amd64.tar.gz && \
    tar -zxf helm-v2.10.0-linux-amd64.tar.gz && \
    mv linux-amd64/helm /bin/helm && \
    rm -rf *linux-amd64* && \
    chmod +x /bin/helm && \
    curl https://rclone.org/install.sh | bash && \
    ln -s /bin/kubectl /usr/local/bin/kubectl && \
    ln -s /bin/helm /usr/local/bin/helm && \
    mkdir -p /hooks/kubesphere /kubesphere/installer/roles /kubesphere/results/env /kubesphere/playbooks /kubesphere/config &&\
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

ENV  ANSIBLE_ROLES_PATH /kubesphere/installer/roles

ADD controller/installRunner.py /hooks/kubesphere
ADD roles /kubesphere/installer/roles
ADD env /kubesphere/results/env
ADD playbooks /kubesphere/playbooks
