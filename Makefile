REPO?=kubespheredev/ks-installer
TAG:=$(shell git rev-parse --abbrev-ref HEAD)-dev

build:
	docker build . --file Dockerfile --tag $(REPO):$(TAG)
push:
	docker push $(REPO):$(TAG)
all: build push
