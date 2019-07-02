image_name="athene2-dbsetup-cronjob"
local_image=serlo/$(image_name)

major_version=1
minor_version=0
#patch version is automatically generated from minor_version + number of commits so we do not need to maintain it

include ../../mk/dockerci.mk

#every hour check if database is empty after initial check
cron_pattern=0 0/1 * * *

.PHONY: docker_build_ci
# builds the docker image in the ci and pushes it to eu.gcr.io
docker_build_ci:
	../../scripts/check_changes.sh . ; if [ $$? != 0 ] ; then \
		$(MAKE) docker_build; \
	else \
		$(MAKE) docker_push; \
	fi

.PHONY: docker_build_minikube
# checks if the docker images is in the remote docker and builds it if not
docker_build_minikube:
	docker images | grep $(local_image) && echo "image $(local_image) already exists use docker_build" || $(MAKE) docker_build

.PHONY: docker_build
# build the docker container
# builds the docker image in the local docker environment
docker_build:
	docker build --build-arg git_revision=$(shell git log | head -n 1 | cut  -f 2 -d ' ') --build-arg cron_pattern="$(cron_pattern)" -t $(local_image) .

