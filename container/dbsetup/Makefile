image_name=athene2-dbsetup-cronjob
local_image=serlo/$(image_name)

major_version=2
minor_version=0
patch_version=1
version=$(major_version).$(minor_version).$(patch_version)

include ../../mk/dockerci.mk

#every hour check if a new dump is available
cron_pattern=0 0/1 * * *

.PHONY: docker_build
# build the docker container
# builds the docker image in the local docker environment
docker_build:
	docker build --build-arg version=$(version) --build-arg git_revision=$(shell git log | head -n 1 | cut  -f 2 -d ' ') --build-arg cron_pattern="$(cron_pattern)" -t $(local_image) .

