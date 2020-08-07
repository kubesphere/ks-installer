#!/usr/bin/env python3
# encoding: utf-8

import os
import sys
import time
import shutil
import json
import datetime
import ansible_runner
import collections
from kubernetes import client, config

playbookBasePath = '/kubesphere/playbooks'
privateDataDir = '/kubesphere/results'
configFile = '/kubesphere/config/ks-config.json'
statusFile = '/kubesphere/config/ks-status.json'

ks_hook = '''
{
	"onKubernetesEvent": [{
		"name": "Monitor clusterconfiguration",
		"kind": "ClusterConfiguration",
		"event": [ "add", "update" ],
		"objectName": "ks-installer",
		"namespaceSelector": {
			"matchNames": ["kubesphere-system"]
		},
		"jqFilter": ".spec",
		"allowFailure": false
	}]
}
'''

# Define components to install


class component():

    def __init__(
            self,
            playbook,
            private_data_dir,
            artifact_dir,
            ident,
            quiet,
            rotate_artifacts):
        '''
        :param private_data_dir: The directory containing all runner metadata needed to invoke the runner
                                 module. Output artifacts will also be stored here for later consumption.
        :param ident: The run identifier for this invocation of Runner. Will be used to create and name
                      the artifact directory holding the results of the invocation.
        :param playbook: The playbook that will be invoked by runner when executing Ansible.
        :param artifact_dir: The path to the directory where artifacts should live, this defaults to 'artifacts' under the private data dir
        :param quiet: Disable all output
        '''

        self.playbook = playbook
        self.private_data_dir = private_data_dir
        self.artifact_dir = artifact_dir
        self.ident = ident
        self.quiet = quiet
        self.rotate_artifacts = rotate_artifacts

    # Generate ansible_runner objects based on parameters

    def installRunner(self):
        installer = ansible_runner.run_async(
            playbook=self.playbook,
            private_data_dir=self.private_data_dir,
            artifact_dir=self.artifact_dir,
            ident=self.ident,
            quiet=self.quiet,
            rotate_artifacts=self.rotate_artifacts
        )
        return installer[1]


def getResultInfo():
    resultsList = checkExecuteResult()
    resultState = False
    for taskResult in resultsList:
        taskName = list(taskResult.keys())[0]
        taskRC = list(taskResult.values())[0]

        if taskRC != 0:
            resultState = resultState or True
            resultInfoPath = os.path.join(
                privateDataDir,
                str(taskName),
                str(taskName),
                'job_events'
            )
            if os.path.exists(resultInfoPath):
                jobList = os.listdir(resultInfoPath)
                jobList.sort(
                    key=lambda x: int(x.split('-')[0])
                )

                errorEventFile = os.path.join(resultInfoPath, jobList[-2])
                with open(errorEventFile, 'r') as f:
                    failedEvent = json.load(f)
                print("\n")
                print("Task '{}' failed:".format(taskName))
                print('*' * 150)
                print(json.dumps(failedEvent, sort_keys=True, indent=2))
                print('*' * 150)
    return resultState
# Operation result check


def checkExecuteResult(interval=10):
    '''
    :param interval: Result inspection cycle. Unit: second(s)
    '''
    taskProcessList = executeTask()
    taskProcessListLen = len(taskProcessList)
    print('*' * 50)
    while True:
        time.sleep(interval)
        completedTasks = []
        statusInfo = []
        for taskProcess in taskProcessList:
            taskName = list(taskProcess.keys())[0]
            result = taskProcess[taskName].rc
            if result is not None:
                statusInfo.append("task {} status is {}".format(
                        taskName,
                        taskProcess[taskName].status))
                completedTasks.append({taskName: result})
            else:
                statusInfo.append("task {} status is running".format(taskName))

        if len(completedTasks) != 0:
            statusInfo.append("total: {}     completed:{}".format(
                    taskProcessListLen,
                    len(completedTasks)))
            statusInfo.append('*' * 50)

            print("\n".join(statusInfo))

        if len(completedTasks) == taskProcessListLen:
            break

    return completedTasks
# Execute and add the installation task process


def executeTask():
    taskProcessList = []

    tasks = generateTaskLists()
    for taskName, taskObject in tasks.items():
        taskProcess = {}
        print("Start installing {}".format(taskName))
        taskProcess[taskName] = taskObject.installRunner()
        taskProcessList.append(
            taskProcess
        )
    return taskProcessList

# Generate a objects list of components


def generateTaskLists():
    readyToEnabledList, readyToDisableList = getComponentLists()
    tasksDict = {}
    for taskName in readyToEnabledList:
        playbookPath = os.path.join(playbookBasePath, str(taskName) + '.yaml')
        artifactDir = os.path.join(privateDataDir, str(taskName))
        if os.path.exists(artifactDir):
            shutil.rmtree(artifactDir)

        tasksDict[str(taskName)] = component(
            playbook=playbookPath,
            private_data_dir=privateDataDir,
            artifact_dir=artifactDir,
            ident=str(taskName),
            quiet=True,
            rotate_artifacts=1
        )

    return tasksDict

# Generate a list of components to install based on the configuration file


def getComponentLists():
    readyToEnabledList = ['monitoring', 'multicluster']
    readyToDisableList = []
    global configFile

    if os.path.exists(configFile):
        with open(configFile, 'r') as f:
            configs = json.load(f)
        f.close()
    else:
        print("The configuration file does not exist !  {}".format(configFile))
        exit()

    for component, parameters in configs.items():
        if (type(parameters) is not str) or (type(parameters) is not int):
            try: 
                for j, value in parameters.items():
                    if (j == 'enabled') and (value == True):
                        readyToEnabledList.append(component)
                        break
                    elif (j == 'enabled') and (value == False):
                        readyToDisableList.append(component)
                        break
            except:
                pass
    try:
        readyToEnabledList.remove("metrics_server")
    except:
        pass

    try:
        readyToEnabledList.remove("networkpolicy")
    except:
        pass

    try:
        readyToEnabledList.remove("telemetry")
    except:
        pass

    return readyToEnabledList, readyToDisableList


def preInstallTasks():
    preInstallTasks = collections.OrderedDict()
    preInstallTasks['preInstall'] = [
        os.path.join(playbookBasePath, 'preinstall.yaml'),
        os.path.join(privateDataDir, 'preinstall')
    ]
    preInstallTasks['metrics-server'] = [
        os.path.join(playbookBasePath, 'metrics_server.yaml'),
        os.path.join(privateDataDir, 'metrics_server')
    ]
    preInstallTasks['common'] = [
        os.path.join(playbookBasePath, 'common.yaml'),
        os.path.join(privateDataDir, 'common')
    ]
    preInstallTasks['ks-core'] = [
        os.path.join(playbookBasePath, 'ks-core.yaml'),
        os.path.join(privateDataDir, 'ks-core')
    ]

    for task, paths in preInstallTasks.items():
        pretask = ansible_runner.run(
            playbook=paths[0],
            private_data_dir=privateDataDir,
            artifact_dir=paths[1],
            ident=str(task),
            quiet=False
        )
        if pretask.rc != 0:
            exit()


def resultInfo(resultState=False):
    config = ansible_runner.run(
        playbook=os.path.join(playbookBasePath, 'ks-config.yaml'),
        private_data_dir=privateDataDir,
        artifact_dir=os.path.join(privateDataDir, 'ks-config'),
        ident='ks-config',
        quiet=True
    )

    if config.rc != 0:
        exit()

    result = ansible_runner.run(
        playbook=os.path.join(playbookBasePath, 'result-info.yaml'),
        private_data_dir=privateDataDir,
        artifact_dir=os.path.join(privateDataDir, 'result-info'),
        ident='result',
        quiet=True
    )

    if result.rc != 0:
        exit()
    
    if resultState == False:
        with open('/kubesphere/playbooks/kubesphere_running', 'r') as f:
            info = f.read()
            print(info)        


    telemeter = ansible_runner.run(
        playbook=os.path.join(playbookBasePath, 'telemetry.yaml'),
        private_data_dir=privateDataDir,
        artifact_dir=os.path.join(privateDataDir, 'telemetry'),
        ident='telemetry',
        quiet=True
    )

    if telemeter.rc != 0:
        exit()

def generateConfig():
    config.load_incluster_config()
    api = client.CustomObjectsApi()

    resource = api.get_namespaced_custom_object(
        group="installer.kubesphere.io",
        version="v1alpha1",
        name="ks-installer",
        namespace="kubesphere-system",
        plural="clusterconfigurations",
    )
     
    cluster_config = resource['spec']
    
    api = client.CoreV1Api()
    nodes = api.list_node().items
    
    cluster_config['nodeNum'] = len(nodes)

    try:
      with open(configFile, 'w', encoding='utf-8') as f:
        json.dump(cluster_config, f, ensure_ascii=False, indent=4)
    except:
      with open(configFile, 'w', encoding='utf-8') as f:
        json.dump({"config": "new"}, f, ensure_ascii=False, indent=4)

    try:
      with open(statusFile, 'w', encoding='utf-8') as f:
        json.dump({"status": resource['status']}, f, ensure_ascii=False, indent=4)
    except:
      with open(statusFile, 'w', encoding='utf-8') as f:
        json.dump({"status": {"enabledComponents": []}}, f, ensure_ascii=False, indent=4)

def main():
    if not os.path.exists(privateDataDir):
        os.makedirs(privateDataDir)

    if len(sys.argv) > 1 and sys.argv[1] == "--config":
        print(ks_hook)
    else:
        generateConfig()
        # execute preInstall tasks
        preInstallTasks()
        resultState = getResultInfo()
        resultInfo(resultState)


if __name__ == '__main__':
    main()
