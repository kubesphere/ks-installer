#!/usr/bin/env python
# encoding: utf-8

import os
import sys
import time
import shutil
import yaml
import json
import datetime
import ansible_runner
import collections


# playbookBasePath = '/root/ks-installer/playbooks'
# privateDataDir = '/etc/kubesphere/results'
# configFile = '/root/ks-installer/controller/config.yaml'

playbookBasePath = '/kubesphere/playbooks'
privateDataDir = '/kubesphere/results'
configFile = '/kubesphere/config/ks-config.yaml'

ks_hook = '''
{
        "schedule": [{
                "allowFailure": true,
        "name": "every month",
        "crontab": "0 0 1 * *"
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
        :param private_data_dir: The directory containing all runner metadata needed to i                                                                                                                      nvoke the runner
                                 module. Output artifacts will also be stored here for la                                                                                                                      ter consumption.
        :param ident: The run identifier for this invocation of Runner. Will be used to c                                                                                                                      reate and name
                      the artifact directory holding the results of the invocation.
        :param playbook: The playbook that will be invoked by runner when executing Ansib                                                                                                                      le.
        :param artifact_dir: The path to the directory where artifacts should live, this                                                                                                                       defaults to 'artifacts' under the private data dir
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


def resultInfo():
    result = ansible_runner.run(
        playbook=os.path.join(playbookBasePath, 'result-info.yaml'),
        private_data_dir=privateDataDir,
        artifact_dir=os.path.join(privateDataDir, 'result-info'),
        ident='result',
        quiet=True
    )

    if result.rc != 0:
        exit()

    with open('/kubesphere/playbooks/kubesphere_running', 'r') as f:
        info = f.read()
        print(info)





def main():
    if not os.path.exists(privateDataDir):
        os.makedirs(privateDataDir)

    if len(sys.argv) > 1 and sys.argv[1] == "--config":
        print(ks_hook)
    else:
        resultInfo()


if __name__ == '__main__':
    main()