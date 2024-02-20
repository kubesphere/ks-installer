import shutil
import json
from .ansible_tasks import component
import os
import logging 


logging.basicConfig(level=logging.INFO, format="%(message)s")


def getComponentLists(configFile):
    readyToEnableList = ['monitoring', 'multicluster', 'openpitrix', 'network']

    if not os.path.exists(configFile):
        print(f"The configuration file does not exist! {configFile}")
        exit()

    with open(configFile, 'r') as f:
        configs = json.load(f)

    for component, parameters in configs.items():
        # Check if parameters is a dict and contains the 'enabled' key
        if isinstance(parameters, dict) and 'enabled' in parameters:
            if parameters['enabled']:
                readyToEnableList.append(component)


    # Filter out specific components directly within the list comprehension
    componentsToRemove = {"metrics_server", "networkpolicy", "telemetry"}
    readyToEnableList = [comp for comp in readyToEnableList if comp not in componentsToRemove]

    return readyToEnableList


def generateTaskLists(playbookBasePath,privateDataDir,configFile):
    readyToEnabledList = getComponentLists(configFile)

    taskDictionary = {}

    for componentName  in readyToEnabledList:
        playbookPath = f"{playbookBasePath}/{componentName}.yaml"
        artifactDir = f"{privateDataDir}/{componentName}"

        if os.path.exists(artifactDir):
            try:
                shutil.rmtree(artifactDir)
            except OSError as e:
                print(f"Error deleting artifact directory {artifactDir}: {e}")
                continue

        taskDictionary[componentName] = component(
            playbook=playbookPath,
            private_data_dir=privateDataDir,
            artifact_dir=artifactDir,
            ident=componentName,
            quiet=True,
            rotate_artifacts=1
        )

    return taskDictionary

def getResultInfo(playbookBasePath,privateDataDir,configFile,infoGetter):
    # Execute and add the installation task process
    taskProcessList = []
    tasks = generateTaskLists(playbookBasePath,privateDataDir,configFile)
    for componentName, taskObject in tasks.items():
        taskProcess = {}
        infoGetter.info = "Start installing {}".format(componentName)
        taskProcess[componentName] = taskObject.installRunner()
        taskProcessList.append(
            taskProcess
        )

    taskProcessListLen = len(taskProcessList)
    logging.info('*' * 50)
    logging.info('Waiting for all tasks to be completed ...')
    completedTasks = []
    while True:
        for taskProcess in taskProcessList:
            taskName = list(taskProcess.keys())[0]
            result = taskProcess[taskName].rc
            if result is not None and {taskName: result} not in completedTasks:
                infoGetter.info = "task {} status is {}  ({}/{})".format(
                    taskName,
                    taskProcess[taskName].status,
                    len(completedTasks) + 1,
                    len(taskProcessList)
                )
                completedTasks.append({taskName: result})

        if len(completedTasks) == taskProcessListLen:
            break
    logging.info('*' * 50)
    logging.info('Collecting installation results ...')

    # Operation result check
    resultState = False
    for taskResult in completedTasks:
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
                logging.info("\n")
                logging.info("Task '{}' failed:".format(taskName))
                logging.info('*' * 150)
                logging.info(json.dumps(failedEvent, sort_keys=True, indent=2))
                logging.info('*' * 150)
    return resultState
