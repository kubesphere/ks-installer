
import json
from kubernetes import client
from .cluster_config_management import *

def generateConfig(api,configFile,statusFile):

    resource = get_cluster_configuration(api)

    cluster_config = resource['spec']

    api = client.CoreV1Api()
    nodes = api.list_node(_preload_content=False)
    nodesStr = nodes.read().decode('utf-8')
    nodesObj = json.loads(nodesStr)

    cluster_config['nodeNum'] = len(nodesObj["items"])
    cluster_config['kubernetes_version'] = client.VersionApi().get_code().git_version

    try:
        with open(configFile, 'w', encoding='utf-8') as f:
            json.dump(cluster_config, f, ensure_ascii=False, indent=4)
    except BaseException:
        with open(configFile, 'w', encoding='utf-8') as f:
            json.dump({"config": "new"}, f, ensure_ascii=False, indent=4)

    try:
        with open(statusFile, 'w', encoding='utf-8') as f:
            json.dump({"status": resource['status']},
                      f, ensure_ascii=False, indent=4)
    except BaseException:
        with open(statusFile, 'w', encoding='utf-8') as f:
            json.dump({"status": {"enabledComponents": []}},
                      f, ensure_ascii=False, indent=4)


def generate_new_cluster_configuration(api):
    global old_cluster_configuration
    upgrade_flag = False
    try:
        old_cluster_configuration = get_cluster_configuration(api)
    except BaseException:
        exit(0)

    cluster_configuration_spec = old_cluster_configuration.get('spec')
    cluster_configuration_status = old_cluster_configuration.get('status')

    if "common" in cluster_configuration_spec:
        if "mysqlVolumeSize" in cluster_configuration_spec["common"]:
            del cluster_configuration_spec["common"]["mysqlVolumeSize"]
        if "etcdVolumeSize" in cluster_configuration_spec["common"]:
            del cluster_configuration_spec["common"]["etcdVolumeSize"]
        if cluster_configuration_status is not None and "redis" in cluster_configuration_status and "status" in cluster_configuration_status[
                "redis"] and cluster_configuration_status["redis"]["status"] == "enabled":
            cluster_configuration_spec["common"]["redis"] = {
                "enabled": True
            }
        else:
            cluster_configuration_spec["common"]["redis"] = {
                "enabled": False
            }

        if cluster_configuration_status is not None and "openldap" in cluster_configuration_status and "status" in cluster_configuration_status[
                "openldap"] and cluster_configuration_status["openldap"]["status"] == "enabled":
            cluster_configuration_spec["common"]["openldap"] = {
                "enabled": True
            }
        else:
            cluster_configuration_spec["common"]["openldap"] = {
                "enabled": False
            }

        if "redisVolumSize" in cluster_configuration_spec["common"]:
            cluster_configuration_spec["common"]["redis"][
                "volumeSize"] = cluster_configuration_spec["common"]["redisVolumSize"]
            del cluster_configuration_spec["common"]["redisVolumSize"]
        if "openldapVolumeSize" in cluster_configuration_spec["common"]:
            cluster_configuration_spec["common"]["openldap"][
                "volumeSize"] = cluster_configuration_spec["common"]["openldapVolumeSize"]
            del cluster_configuration_spec["common"]["openldapVolumeSize"]
        if "minio" not in cluster_configuration_spec["common"]:
            if "minioVolumeSize" in cluster_configuration_spec["common"]:
                cluster_configuration_spec["common"]["minio"] = {
                    "volumeSize": cluster_configuration_spec["common"]["minioVolumeSize"]
                }
                del cluster_configuration_spec["common"]["minioVolumeSize"]
        else:
            if "minioVolumeSize" in cluster_configuration_spec["common"]:
                cluster_configuration_spec["common"]["minio"]["volumeSize"] = cluster_configuration_spec["common"]["minioVolumeSize"]
                del cluster_configuration_spec["common"]["minioVolumeSize"]

        if cluster_configuration_status is not None and "es" in cluster_configuration_status and "status" in cluster_configuration_status[
                "es"] and cluster_configuration_status["es"]["status"] == "enabled":
            cluster_configuration_spec["common"]["es"]["enabled"] = True
            if "opensearch" in cluster_configuration_spec["common"]:
                cluster_configuration_spec["common"]["opensearch"]["enabled"] = False
            else:
                cluster_configuration_spec["common"]["opensearch"] = {
                     "enabled": False
                }
        else:
            cluster_configuration_spec["common"]["es"]["enabled"] = False
            if "opensearch" in cluster_configuration_spec["common"]:
                cluster_configuration_spec["common"]["opensearch"]["enabled"] = True
            else:
                cluster_configuration_spec["common"]["opensearch"] = {
                     "enabled": True
                }

        # Migrate the configuration of es elasticsearch
        if "es" in cluster_configuration_spec["common"]:
            if "master" not in cluster_configuration_spec["common"]["es"]:
                cluster_configuration_spec["common"]["es"]["master"] = {
                    "volumeSize": "4Gi"
                }
            if "data" not in cluster_configuration_spec["common"]["es"]:
                cluster_configuration_spec["common"]["es"]["data"] = {
                    "volumeSize": "20Gi"
                }
            if "elasticsearchMasterReplicas" in cluster_configuration_spec["common"]["es"]:
                cluster_configuration_spec["common"]["es"]["master"]["replicas"] = cluster_configuration_spec["common"]["es"]["elasticsearchMasterReplicas"]
                del cluster_configuration_spec["common"]["es"]["elasticsearchMasterReplicas"]
            if "elasticsearchDataReplicas" in cluster_configuration_spec["common"]["es"]:
                cluster_configuration_spec["common"]["es"]["data"]["replicas"] = cluster_configuration_spec["common"]["es"]["elasticsearchDataReplicas"]
                del cluster_configuration_spec["common"]["es"]["elasticsearchDataReplicas"]
            if "elasticsearchMasterVolumeSize" in cluster_configuration_spec["common"]["es"]:
                cluster_configuration_spec["common"]["es"]["master"]["volumeSize"] = cluster_configuration_spec["common"]["es"]["elasticsearchMasterVolumeSize"]
                del cluster_configuration_spec["common"]["es"]["elasticsearchMasterVolumeSize"]
            if "elasticsearchDataVolumeSize" in cluster_configuration_spec["common"]["es"]:
                cluster_configuration_spec["common"]["es"]["data"]["volumeSize"] = cluster_configuration_spec["common"]["es"]["elasticsearchDataVolumeSize"]
                del cluster_configuration_spec["common"]["es"]["elasticsearchDataVolumeSize"]
            if "externalElasticsearchHost" not in cluster_configuration_spec["common"]["es"] and "externalElasticsearchUrl" in cluster_configuration_spec["common"]["es"]:
                cluster_configuration_spec["common"]["es"]["externalElasticsearchHost"] = cluster_configuration_spec["common"]["es"]["externalElasticsearchUrl"]

        # Migrate the configuration of  opensearch
        if "opensearch" in cluster_configuration_spec["common"]:
            if "master" not in cluster_configuration_spec["common"]["opensearch"]:
                cluster_configuration_spec["common"]["opensearch"]["master"] = {
                    "volumeSize": "4Gi"
                }
            if "data" not in cluster_configuration_spec["common"]["opensearch"]:
                cluster_configuration_spec["common"]["opensearch"]["data"] = {
                    "volumeSize": "20Gi"
                }
            if "opensearchPrefix" not in cluster_configuration_spec["common"]["opensearch"]:
                cluster_configuration_spec["common"]["opensearch"]["opensearchPrefix"] = "whizard"
            if "logMaxAge" not in cluster_configuration_spec["common"]["opensearch"]:
                cluster_configuration_spec["common"]["opensearch"]["logMaxAge"] = "7"
            if "basicAuth" not in cluster_configuration_spec["common"]["opensearch"]:
                cluster_configuration_spec["common"]["opensearch"]["basicAuth"] = {
                    "enabled": True,
                    "username": "admin",
                    "password": "admin"
                }
            if "opensearchMasterReplicas" in cluster_configuration_spec["common"]["opensearch"]:
                cluster_configuration_spec["common"]["opensearch"]["master"]["replicas"] = cluster_configuration_spec["common"]["opensearch"]["elasticsearchMasterReplicas"]
                del cluster_configuration_spec["common"]["opensearch"]["opensearchMasterReplicas"]
            if "opensearchDataReplicas" in cluster_configuration_spec["common"]["opensearch"]:
                cluster_configuration_spec["common"]["opensearch"]["data"]["replicas"] = cluster_configuration_spec["common"]["opensearch"]["opensearchDataReplicas"]
                del cluster_configuration_spec["common"]["opensearch"]["opensearchDataReplicas"]
            if "opensearchMasterVolumeSize" in cluster_configuration_spec["common"]["opensearch"]:
                cluster_configuration_spec["common"]["opensearch"]["master"]["volumeSize"] = cluster_configuration_spec["common"]["opensearch"]["opensearchMasterVolumeSize"]
                del cluster_configuration_spec["common"]["opensearch"]["opensearchMasterVolumeSize"]
            if "opensearchDataVolumeSize" in cluster_configuration_spec["common"]["opensearch"]:
                cluster_configuration_spec["common"]["opensearch"]["data"]["volumeSize"] = cluster_configuration_spec["common"]["opensearch"]["opensearchDataVolumeSize"]
                del cluster_configuration_spec["common"]["opensearch"]["opensearchDataVolumeSize"]
            if "externalOpensearchHost" not in cluster_configuration_spec["common"]["opensearch"] and "externalOpensearchUrl" in cluster_configuration_spec["common"]["opensearch"]:
                cluster_configuration_spec["common"]["opensearch"]["externalOpensearchHost"] = cluster_configuration_spec["common"]["opensearch"]["externalOpensearchUrl"]

        if "console" in cluster_configuration_spec:
            if "core" in cluster_configuration_spec["common"]:
                cluster_configuration_spec["common"]["core"]["console"]=cluster_configuration_spec["console"]
            else:
                cluster_configuration_spec["common"]["core"] = {
                    "console": cluster_configuration_spec["console"]
                }
            del cluster_configuration_spec["console"]

    if "logging" in cluster_configuration_spec and "logsidecarReplicas" in cluster_configuration_spec[
            "logging"]:
        upgrade_flag = True
        if "enabled" in cluster_configuration_spec["logging"]:
            if cluster_configuration_spec["logging"]["enabled"]:
                cluster_configuration_spec["logging"] = {
                    "enabled": True,
                    "logsidecar": {
                        "enabled": True,
                        "replicas": 2
                    }
                }
            else:
                cluster_configuration_spec["logging"] = {
                    "enabled": False,
                    "logsidecar": {
                        "enabled": False,
                        "replicas": 2
                    }
                }

    if "events" in cluster_configuration_spec and "ruler" not in cluster_configuration_spec["events"]:
        upgrade_flag = True
        cluster_configuration_spec["events"]["ruler"] = {
            "enabled": True,
            "replicas": 2
        }

    if "notification" in cluster_configuration_spec:
        upgrade_flag = True
        del cluster_configuration_spec['notification']

    if "openpitrix" in cluster_configuration_spec and "store" not in cluster_configuration_spec[
            "openpitrix"]:
        upgrade_flag = True
        if "enabled" in cluster_configuration_spec["openpitrix"]:
            if cluster_configuration_spec["openpitrix"]["enabled"]:
                cluster_configuration_spec["openpitrix"] = {
                    "store": {
                        "enabled": True
                    }
                }
            else:
                cluster_configuration_spec["openpitrix"] = {
                    "store": {
                        "enabled": False
                    }
                }

    if "networkpolicy" in cluster_configuration_spec:
        upgrade_flag = True
        if "enabled" in cluster_configuration_spec[
                "networkpolicy"] and cluster_configuration_spec["networkpolicy"]["enabled"]:
            cluster_configuration_spec["network"] = {
                "networkpolicy": {
                    "enabled": True,
                },
                "ippool": {
                    "type": "none",
                },
                "topology": {
                    "type": "none",
                },
            }
        else:
            cluster_configuration_spec["network"] = {
                "networkpolicy": {
                    "enabled": False,
                },
                "ippool": {
                    "type": "none",
                },
                "topology": {
                    "type": "none",
                },
            }
        del cluster_configuration_spec["networkpolicy"]

    if "terminal" not in cluster_configuration_spec:
        upgrade_flag = True
        cluster_configuration_spec["terminal"] = {
            "timeout": 600
        }

    # add servicemesh configuration migration
    if "servicemesh" in cluster_configuration_spec and "istio" not in cluster_configuration_spec["servicemesh"]:
        upgrade_flag = True
        cluster_configuration_spec["servicemesh"]["istio"] = {
            "components": {
                "ingressGateways": [
                    {
                        "name": "istio-ingressgateway",
                        "enabled": False
                    }
                ],
                "cni": {
                    "enabled": False
                }
            }
        }

    # add edgeruntime configuration migration
    if "kubeedge" in cluster_configuration_spec:
        upgrade_flag = True
        if "enabled" in cluster_configuration_spec["kubeedge"]:
            cluster_configuration_spec["edgeruntime"] = {
                "enabled": cluster_configuration_spec["kubeedge"]["enabled"],
                "kubeedge": cluster_configuration_spec["kubeedge"]
            }

            cluster_configuration_spec["edgeruntime"]["kubeedge"]["iptables-manager"] = {
                "enabled": True,
                "mode": "external"
            }

        try:
            del cluster_configuration_spec["edgeruntime"]["kubeedge"]["edgeWatcher"]
        except:
            pass
        
        del cluster_configuration_spec["kubeedge"]

    if "devops" in cluster_configuration_spec and "enabled" in cluster_configuration_spec["devops"] and cluster_configuration_spec["devops"]["enabled"]:
        if "jenkinsCpuReq" not in  cluster_configuration_spec["devops"]:
            upgrade_flag = True
            cluster_configuration_spec["devops"]["jenkinsCpuReq"] = 0.5
        if "jenkinsCpuLim" not in  cluster_configuration_spec["devops"]:
            upgrade_flag = True
            cluster_configuration_spec["devops"]["jenkinsCpuLim"] = 4

    if isinstance(cluster_configuration_status,
                  dict) and "core" in cluster_configuration_status:
        if ("version" in cluster_configuration_status["core"] and cluster_configuration_status["core"]["version"] !=
                cluster_configuration["metadata"]["labels"]["version"]) or "version" not in cluster_configuration_status["core"]:
            upgrade_flag = True

    if upgrade_flag:
        cluster_configuration["spec"] = cluster_configuration_spec
        if isinstance(cluster_configuration_status,
                      dict) and "clusterId" in cluster_configuration_status:
            cluster_configuration["status"] = {
                "clusterId": cluster_configuration_status["clusterId"]
            }
        delete_cluster_configuration(api)
        create_cluster_configuration(api, cluster_configuration)
        exit(0)