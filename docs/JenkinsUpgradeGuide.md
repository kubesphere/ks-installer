# Upgrade Notes for Jenkins

This document only for who enabled DevOps in Kubesphere. If this is the first time that 
you install Jenkins via enable DevOps, then you don't need this document.

# Background

Considering Jenkins just has the filesystem as its backend storage. There's not a official  
upgrade guide about how to deal with the configuration files from the community. And users 
might install other plugins by themselves, it's very hard to provide a automatic way to 
upgrade [Kubesphere Jenkins](https://github.com/kubesphere/ks-jenkins).

# Upgrade to v3.0.1

> Please notice, v3.0.1 has not been released yet.

## Backup
Firstly, please backup your Jenkins. You can do it by [thin-backup-plugin](https://github.com/jenkinsci/thin-backup-plugin). 
Jenkins backup plugins are not quite active, but this one was still maintained this year.

Basicly, you can backup everything in the Jenkins home directory. The home directory in the Jenkins pod is `/var/jenkins_home`.

If you've installed other plugins by yourself, or you've upgraded some plugins. You need to export a list of these plugins. 

Before you do that, please install and config the [Jenkins CLI](https://github.com/jenkins-zh/jenkins-cli).

You can get the token of Jenkins via: `kubectl get cm kubesphere-config -o jsonpath={.data.kubesphere\\.yaml} | grep devops -A 2 | grep password`.

Then export the plugins list via: `jcli plugin formula > jenkins.yaml`. This file is similar to [formula.yaml](https://github.com/kubesphere/ks-jenkins/blob/master/formula.yaml) which comes from [ks-jenkins](https://github.com/kubesphere/ks-jenkins).

## Upgrade

### Step1:

Update the image from deploy to `kubespheredev/ks-jenkins:2.249.1`

```
kubectl -n kubesphere-devops-system patch deploy ks-jenkins --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value": "kubespheredev/ks-jenkins:2.249.1"}]'
kubectl -n kubesphere-devops-system patch deploy ks-jenkins --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/initContainers/0/image", "value": "kubespheredev/ks-jenkins:2.249.1"}]'
```

### Step2:

`uc-jenkins-update-center` was removed from `v3.0.1`. So you can just remove it. Do it via the following command:

```
kubectl -n kubesphere-devops-system delete deploy uc-jenkins-update-center
kubectl -n kubesphere-devops-system delete service uc-jenkins-update-center

kubectl -n kubesphere-devops-system patch configmap ks-jenkins --type='json' -p='[{"op": "remove", "path": "/data/plugins.txt"}]'
kubectl -n kubesphere-devops-system patch configmap ks-jenkins --type='json' -p='[{"op": "replace", "path": "/data/apply_config.sh", "value":"mkdir -p /usr/share/jenkins/ref/secrets/;\n
echo false > /usr/share/jenkins/ref/secrets/slave-to-master-security-kill-switch;\n
cp --no-clobber /var/jenkins_config/config.xml /var/jenkins_home;\n
cp --no-clobber /var/jenkins_config/jenkins.CLI.xml /var/jenkins_home;\n
cp --no-clobber /var/jenkins_config/jenkins.model.JenkinsLocationConfiguration.xml /var/jenkins_home;\n
mkdir -p /var/jenkins_home/init.groovy.d/;\n
yes | cp -i /var/jenkins_config/*.groovy /var/jenkins_home/init.groovy.d/"}]'
```

### Step3:

Restart `ks-installer`

```
kubectl -n kubesphere-system scale deploy ks-installer --replicas=0
kubectl -n kubesphere-system scale deploy ks-installer --replicas=1
```

Then you can check the logs via: `kubectl -n kubesphere-system logs deploy/ks-installer --tail=50 -f`

It's ready if you can see something like below from the logs output:

```
#####################################################
###              Welcome to KubeSphere!           ###
#####################################################
```

### Step4 (Optional):

Normally, you don't need to this step. But in order to make sure everything is ok. Please check the plugin list after 
you upgrade Jenkins. If you found out there're part of them missed, please install these plugins by the following command:

`jcli plugin install --formula jenkins.yaml`

### Verify

Do some tests to make sure everything works well as you expected.
