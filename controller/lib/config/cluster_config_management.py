
import json 
from kubernetes import client

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

cluster_configuration = {
    "apiVersion": "installer.kubesphere.io/v1alpha1",
    "kind": "ClusterConfiguration",
    "metadata": {
        "name": "ks-installer",
        "namespace": "kubesphere-system",
        "labels": {
            "version": "master"
        },
    },
}


def get_cluster_configuration(api_instance, name="ks-installer", namespace="kubesphere-system"):
    """Retrieve a ClusterConfiguration resource."""
    try:
        resource = api_instance.get_namespaced_custom_object(
            group="installer.kubesphere.io",
            version="v1alpha1",
            namespace=namespace,
            plural="clusterconfigurations",
            name=name,
        )
        return resource
    except client.rest.ApiException as e:
        print(f"Exception when calling CustomObjectsApi->get_namespaced_custom_object: {e}")
        return None


def create_cluster_configuration(api_instance, resource, namespace="kubesphere-system"):
    """Create a new ClusterConfiguration resource."""
    try:
        api_instance.create_namespaced_custom_object(
            group="installer.kubesphere.io",
            version="v1alpha1",
            namespace=namespace,
            plural="clusterconfigurations",
            body=resource,
        )
        print("ClusterConfiguration created successfully.")
    except client.rest.ApiException as e:
        print(f"Exception when calling CustomObjectsApi->create_namespaced_custom_object: {e}")


def delete_cluster_configuration(api_instance, name="ks-installer", namespace="kubesphere-system"):
    """Delete an existing ClusterConfiguration resource."""
    try:
        api_instance.delete_namespaced_custom_object(
            group="installer.kubesphere.io",
            version="v1alpha1",
            namespace=namespace,
            plural="clusterconfigurations",
            name=name,
            body=client.V1DeleteOptions(),
        )
        print("ClusterConfiguration deleted successfully.")
    except client.rest.ApiException as e:
        print(f"Exception when calling CustomObjectsApi->delete_namespaced_custom_object: {e}")