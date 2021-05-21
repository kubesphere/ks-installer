概述
------------
&ensp;&ensp;&ensp;&ensp;项目使用kubernetes job的形式实现kubesphere在已有k8s环境快速部署，采用[ansible](https://github.com/ansible/ansible)实现对kubesphere的统一配置及部署管理。

&ensp;&ensp;&ensp;&ensp;kubesphere各组件以角色(role)的形式划分，独立部署。
> ansible playbook及roles开发可参考：[Playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html#working-with-playbooks)、[Roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#roles)

项目结构
------------
```
|-- ks-installer
    |-- deploy                      
    |   |-- kubesphere.yaml                        # 部署用manifests
    |-- kubesphere.yaml                            # kubesphere playbook
    |-- roles                                      # 组件安装按角色划分
    |   |-- download              
    |   |-- ks-alerting           
    |   |-- ks-core
    |   |   |-- ingress             
    |   |   |-- ks-account
    |   |   |-- ks-apigateway
    |   |   |-- ks-apiserver
    |   |   |-- ks-console
    |   |   |-- ks-controller-manager
    |   |   |-- meta
    |   |   |-- prepare
    |   |-- ks-devops
    |   |   |-- gitlab
    |   |   |-- harbor
    |   |   |-- jenkins
    |   |   |-- ks-devops
    |   |   |-- meta
    |   |   |-- s2i
    |   |   |-- sonarqube
    |   |-- ks-istio
    |   |-- ks-logging
    |   |-- ks-monitor
    |   |-- ks-notification
    |   |-- kubesphere-defaults
    |   |-- metrics-server
    |   |-- openpitrix
    |-- scripts                                    # 功能脚本
        |-- download-docker-images.sh
    |-- Dockerfile
    |-- LICENSE
    |-- README.md
```

## Debug ks-installer locally

> tips: This guide only works on Linux & Mac

> Prerequisite: helm v3.2.x, kubectl v1.19.x are needed.

1. Prepare local working directory
Once you have cloned ks-installer repo in your working directory. Enter the `ks-installer` folder first. You need to create a `results` folder and copy the `env` folder to the `results` folder, which will be used by Ansible for setting variables and collecting logs.

```bash
 mkdir results && cp -r ./env/ ./results/

echo "-e @$PWD/results/ks-config.json -e @$PWD/results/ks-status.json" > results/env/cmdline
```

2. Install Python & required packages

Python3 and pip3 are needed to be installed on your machine. For Ubuntu 18.04 user, you can run the following command:

```bash
pip3 install psutil cryptography==3.0 ansible_runner==1.4.6 ansible==2.8.12 redis kubernetes
```

3. Create ClusterConfiguration

The python program still needs to read the ks-installer ClusterConfiguraiton from k8s. So you have to create the CRD. Scaled the ks-installer deployment to 0 replicas, so it won't execute automatically.

```bash
kubectl apply -f deploy/kubesphere-installer.yaml

kubectl -n kubesphere-system scale deployment ks-installer --replicas=0

kubectl apply -f deploy/cluster-configuration.yaml
```

4. Launch ks-installer

```bash
export ANSIBLE_ROLES_PATH=$PWD/roles
python3 controller/installRunner.py --debug
```

