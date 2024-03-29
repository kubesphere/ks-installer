#!/usr/bin/env python3
# encoding: utf-8

import os
import sys
import logging
from kubernetes import client, config
from lib import *



def main():
    '''
    playbookBasePath: The folder where the playbooks is located.
    privateDataDir: The folder where the playbooks execution results are located.
    configFile: Define the parameters in the installation process. Generated by cluster configuration
    statusFile: Define the status in the installation process.
    '''
    playbookBasePath = '/kubesphere/playbooks'
    privateDataDir = '/kubesphere/results'
    configFile = '/kubesphere/config/ks-config.json'
    statusFile = '/kubesphere/config/ks-status.json'

    logging.basicConfig(level=logging.INFO, format="%(message)s")

    infoGetter = Info('taskInfo')
    viewer = InfoViewer()
    infoGetter.attach(viewer)

    if len(sys.argv) > 1 and sys.argv[1] == "--config":
        print(ks_hook)
        return

    if len(sys.argv) > 1 and sys.argv[1] == "--debug":
        privateDataDir = os.path.abspath('./results')
        playbookBasePath = os.path.abspath('./playbooks')
        configFile = os.path.abspath('./results/ks-config.json')
        statusFile = os.path.abspath('./results/ks-status.json')
        config.load_kube_config()
    else:
        config.load_incluster_config()

    if not os.path.exists(privateDataDir):
        os.makedirs(privateDataDir)

    api = client.CustomObjectsApi()
    generate_new_cluster_configuration(api)
    generateConfig(api,configFile,statusFile)
    preInstallTasks(playbookBasePath,privateDataDir)
    resultState = getResultInfo(playbookBasePath,privateDataDir,configFile,infoGetter)
    resultInfo(playbookBasePath,privateDataDir,resultState, api)


if __name__ == '__main__':
    main()
