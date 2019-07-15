FROM ubuntu:18.04

WORKDIR /usr/src/kubesphere

RUN apt update && apt install ansible python-netaddr openssl  curl jq  make software-properties-common -y &&  apt-add-repository --yes --update ppa:ansible/ansible && apt install ansible -y && apt clean

RUN curl -SsL https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl &&  chmod +x /usr/local/bin/kubectl

RUN curl -OSsL https://get.helm.sh/helm-v2.10.0-linux-amd64.tar.gz && tar -zxf helm-v2.10.0-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/helm && rm -rf *linux-amd64* && chmod +x /usr/local/bin/helm

COPY roles .

COPY kubesphere.yaml .
