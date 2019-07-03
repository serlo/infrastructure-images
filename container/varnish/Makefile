image_name="varnish"
local_image=serlo/$(image_name)

major_version=6
minor_version=0
patch_version=2
version=$(major_version).$(minor_version).$(patch_version) 

include ../../mk/dockerci.mk

.PHONY: docker_build_ci
# builds the docker image in the ci and pushes it to eu.gcr.io
docker_build_ci:
	 docker pull eu.gcr.io/serlo-containers/${image_name}:$(version) 2>/dev/null >/dev/null || $(MAKE) docker_build docker_push

.PHONY: docker_build_minikube
# checks if the docker images is in the remote docker and builds it if not
docker_build_minikube:
	docker images | grep $(local_image) && echo "image $(local_image) already exists use docker_build" || $(MAKE) docker_build

.PHONY: docker_build
# build the docker container
docker_build:
	docker build --build-arg git_revision=$(shell git log | head -n 1 | cut  -f 2 -d ' ') -t $(local_image) .

