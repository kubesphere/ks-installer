REPO?=kubespheredev/ks-installer
TAG:=$(shell git rev-parse --abbrev-ref HEAD | sed -e 's/\//-/g')-dev-$(shell git rev-parse --short HEAD)
CONTAINER_CLI?=docker

build:
	$(CONTAINER_CLI) build . --file Dockerfile --tag $(REPO):$(TAG)
push:
	$(CONTAINER_CLI) push $(REPO):$(TAG)
all: build push
