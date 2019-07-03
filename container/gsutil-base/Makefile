image_name="gsutil-base"
local_image=serlo/$(image_name)

major_version=1
minor_version=0
#patch version is automatically generated from minor_version + number of commits so we do not need to maintain it

include ../../mk/dockerci.mk

.PHONY: docker_build_ci
# builds the docker image in the ci and pushes it to eu.gcr.io
docker_build_ci:
	@../../scripts/check_changes.sh . ; if [ $$? != 0 ] ; then $(MAKE) docker_build && $(MAKE) docker_push; fi

.PHONY: docker_build_minikube
# checks if the docker images is in the remote docker and builds it if not
docker_build_minikube:
	docker images | grep $(local_image) && echo "image $(local_image) already exists use docker_build" || $(MAKE) docker_build

.PHONY: docker_build
# build the docker container
docker_build:
	docker build --build-arg git_revision=$(shell git log | head -n 1 | cut  -f 2 -d ' ') -t $(local_image) .

.PHONY: docker_run
# runs the docker image locally
docker_run:
	docker run --rm serlo/gsutil-base
