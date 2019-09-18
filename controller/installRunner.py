#!/usr/bin/env python
# encoding: utf-8

import sys
import time
import ansible_runner
import os
import yaml


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


class component():

    def __init__(self, playbook, private_data_dir, artifact_dir, ident, quiet):
        self.playbook = playbook
        self.private_data_dir = private_data_dir
        self.artifact_dir = artifact_dir
        self.ident = ident
        self.quiet = quiet

    def installRunner(self):
        installer = ansible_runner.run_async(
            playbook=self.playbook,
            private_data_dir=self.private_data_dir,
            artifact_dir=self.artifact_dir,
            ident=self.ident,
            quiet=self.quiet
        )
        return installer[1]


def checkExecuteResult(interval=1):
    taskProcessList = executeTask()
    completedTasks = []
    while True:
        for taskProcess in taskProcessList:
            if taskProcess[taskProcess.keys()[0]].rc is not None:
                print("task {} rc is {}".format(taskProcess.keys(),
                                                taskProcess[taskProcess.keys()[0]].rc))
                completedTasks.append(taskProcess.keys()[0])
                print("Completion of task: {}".format(taskProcess.keys()[0]))
        if len(completedTasks) == len(taskProcessList):
            break
        time.sleep(interval)
        print("Please wait patiently for the tasks to complete !")


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


def generateTaskLists():
    readyToEnabledList, readyToDisableList = getComponentLists()
    tasksDict = {}
    for taskName in readyToEnabledList:
        playbookPath = os.path.join(playbookBasePath, str(taskName) + '.yaml')
        artifactDir = os.path.join(privateDataDir, str(taskName))
        tasksDict[str(taskName)] = component(
            playbook=playbookPath,
            private_data_dir=privateDataDir,
            artifact_dir=artifactDir,
            ident=str(taskName),
            quiet=False
        )

    return tasksDict


def getComponentLists():
    readyToEnabledList = []
    readyToDisableList = []
    # current_path = os.path.abspath(os.path.dirname(__file__))
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
    print(readyToEnabledList)
    print(readyToDisableList)
    return readyToEnabledList, readyToDisableList


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "--config":
        print(ks_hook)
    else:
        time.sleep(10)
        checkExecuteResult()
        print("successful")


if __name__ == '__main__':
    main()
