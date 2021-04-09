# Contributing

Welcome to kubesphere/ks-installer! To learn more about contributing to the [ks-installer code repo](README.md), check out the [Developer Guide](https://github.com/kubesphere/community/tree/master/developer-guide/development).

The [KubeSphere community repo](https://github.com/kubesphere/community) contains information about how to get started, how the community organizes, and more.

# Manual Test

If you want to test against a component with `ks-installer`. Please follow these steps:

* Create a new git feature branch
* Change the Docker image tags of your desired component in file [main.yml](roles/download/defaults/main.yml)
* Build the Docker image of `ks-installer`
    * Please provide a accessible image path, e.g. `make all -e REPO=surenpi/ks-installer`
* Create a Kubernetes cluster without KubeSphere
    * Install a [k3s](https://github.com/k3s-io/k3s/) might be easy solution for the test purpose
* Install the ks-installer
    * Switch the image to your desired one in file `deploy/kubesphere-installer.yaml`
    * Install it via: `kubectl apply -f deploy/`
