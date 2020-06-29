FROM flant/shell-operator:v1.0.0-beta.5-alpine3.9

RUN apk --no-cache add  gcc  musl-dev libffi-dev openssl-dev linux-headers python3-dev py3-pip make openssl curl unzip git && \
    pip3 install --no-cache-dir psutil ansible_runner ansible==2.8.12 redis kubernetes && \
    wget https://get.helm.sh/helm-v3.2.1-linux-amd64.tar.gz && \
    tar -zxf helm-v3.2.1-linux-amd64.tar.gz && \
    mv linux-amd64/helm /bin/helm && \
    rm -rf *linux-amd64* && \
    chmod +x /bin/helm && \
    helm plugin install https://github.com/helm/helm-2to3.git && \
    wget https://storage.googleapis.com/kubernetes-release/release/v1.16.9/bin/linux/amd64/kubectl -O /bin/kubectl && \
    chmod +x /bin/kubectl && \
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
