<<<<<<< HEAD
REPO?=kubesphere/ks-installer
TAG:=$(shell git rev-parse --abbrev-ref HEAD)-dev
=======
REPO?=kubesphere/ks-installer
TAG:=$(shell git rev-parse --abbrev-ref HEAD | sed -e 's/\//-/g')-dev
>>>>>>> upstream/master

build:
	docker build . --file Dockerfile --tag $(REPO):$(TAG)
push:
	docker push $(REPO):$(TAG)
all: build push
