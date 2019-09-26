#!/usr/bin/env python
# encoding: utf-8

import os
import sys
import time
import shutil
import yaml
import json
import ansible_runner
import collections


# playbookBasePath = '/home/ubuntu/ks-installer/playbooks'
# privateDataDir = '/etc/kubesphere'
# configFile = '/home/ubuntu/ks-installer/playbooks/vars.yaml'

playbookBasePath = '/kubesphere/playbooks'
privateDataDir = '/etc/kubesphere'
configFile = '/kubesphere/config/ks-config.yaml'

ks_hook = '''
{
	"onKubernetesEvent": [{
		"name": "Monitor configmap",
		"kind": "ConfigMap",
		"event": ["update"],
		"objectName": "ks-installer",
		"namespaceSelector": {
			"any": true
		},
		"jqFilter": ".data",
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
    for taskResult in resultsList:
        taskName = taskResult.keys()[0]
        taskRC = taskResult.values()[0]

        if taskRC != 0:
            resultInfoPath = os.path.join(
                privateDataDir,
                str(taskName),
                'artifacts/',
                str(taskName),
                'job_events'
            )

            jobList = os.listdir(resultInfoPath)
            jobList.sort(
                key=lambda x: int(x.split('-')[0])
            )

            errorEventFile = os.path.join(resultInfoPath, jobList[-2])
            with open(errorEventFile, 'r') as f:
                failedEvent = json.load(f)
            errorMsg = failedEvent["stdout"]
            print("\n")
            print("Task '{}' failed:".format(taskName))
            print('*' * 150)
            print(errorMsg)
            print('*' * 150)

# Operation result check


def checkExecuteResult(interval=2):
    '''
    :param interval: Result inspection cycle. Unit: second(s)
    '''
    taskProcessList = executeTask()
    while True:
        time.sleep(interval)
        completedTasks = []

        for taskProcess in taskProcessList:
            taskName = taskProcess.keys()[0]
            result = taskProcess[taskName].rc
            if result is not None:
                print(
                    "task {} status is {}".format(
                        taskName,
                        taskProcess[taskName].status))
                completedTasks.append({taskName: result})

        if len(completedTasks) != 0:
            print('*' * 50)
        if len(completedTasks) == len(taskProcessList):
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
    readyToEnabledList = []
    readyToDisableList = []
    global configFile

    if os.path.exists(configFile):
        with open(configFile, 'r') as f:
            configs = yaml.load(f.read())
        f.close()
    else:
        print("The configuration file does not exist !  {}".format(configFile))
        exit()

    for component, parameters in configs.items():
        for j, value in parameters.items():
            if (j == 'enabled') and (value):
                readyToEnabledList.append(component)
                break
            elif (j == 'enabled') and (value == False):
                readyToDisableList.append(component)
                break

    return readyToEnabledList, readyToDisableList


def preInstallTasks():
    preInstallTasks = collections.OrderedDict()
    preInstallTasks['preInstall'] = [
        os.path.join(playbookBasePath, 'preinstall.yaml'),
        os.path.join(privateDataDir, 'preinstall')
    ]
    preInstallTasks['plugins'] = [
        os.path.join(playbookBasePath, 'plugins.yaml'),
        os.path.join(privateDataDir, 'plugins')
    ]
    preInstallTasks['common'] = [
        os.path.join(playbookBasePath, 'common.yaml'),
        os.path.join(privateDataDir, 'common')
    ]

    for task, paths in preInstallTasks.items():
        ansible_runner.run(
            playbook=paths[0],
            private_data_dir=privateDataDir,
            artifact_dir=paths[1],
            ident=str(task),
            quiet=False
        )


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "--config":
        print(ks_hook)
    else:
        time.sleep(10)
        # execute preInstall tasks
        preInstallTasks()
        getResultInfo()


if __name__ == '__main__':
    main()
