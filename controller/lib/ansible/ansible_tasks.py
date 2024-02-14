import os
import ansible_runner
import collections
from ..config import get_cluster_configuration

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

def preInstallTasks(playbookBasePath,privateDataDir):


    preInstallTasks = [
        ('preInstall', 'preinstall.yaml'),
        ('metrics-server', 'metrics_server.yaml'),
        ('common', 'common.yaml'),
        ('ks-core', 'ks-core.yaml'),
    ]

    # Construct the tasks dictionary using a comprehension
    tasks = collections.OrderedDict(
        (task_name, [
            os.path.join(playbookBasePath, playbook_file),
            os.path.join(privateDataDir, task_name)
        ]) for task_name, playbook_file in preInstallTasks
    )

    for task, paths in tasks.items():
        pretask = ansible_runner.run(
            playbook=paths[0],
            private_data_dir=privateDataDir,
            artifact_dir=paths[1],
            ident=str(task),
            quiet=False
        )
        if pretask.rc != 0:
            exit()


def resultInfo(playbookBasePath,privateDataDir, resultState=False, api=None):
    ks_config = ansible_runner.run(
        playbook=os.path.join(playbookBasePath, 'ks-config.yaml'),
        private_data_dir=privateDataDir,
        artifact_dir=os.path.join(privateDataDir, 'ks-config'),
        ident='ks-config',
        quiet=True
    )

    if ks_config.rc != 0:
        print("Failed to ansible-playbook ks-config.yaml")
        exit()

    result = ansible_runner.run(
        playbook=os.path.join(playbookBasePath, 'result-info.yaml'),
        private_data_dir=privateDataDir,
        artifact_dir=os.path.join(privateDataDir, 'result-info'),
        ident='result',
        quiet=True
    )

    if result.rc != 0:
        print("Failed to ansible-playbook result-info.yaml")
        exit()

    resource = get_cluster_configuration(api)

    if "migration" in resource['status']['core'] and resource['status']['core']['migration'] and resultState == False:
        migration = ansible_runner.run(
            playbook=os.path.join(playbookBasePath, 'ks-migration.yaml'),
            private_data_dir=privateDataDir,
            artifact_dir=os.path.join(privateDataDir, 'ks-migration'),
            ident='ks-migration',
            quiet=False
        )
        if migration.rc != 0:
            exit()

    if not resultState:
        with open(os.path.join(playbookBasePath, 'kubesphere_running'), 'r') as f:
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
