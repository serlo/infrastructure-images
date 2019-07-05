image_name=athene2-dbdump-cronjob
local_image=serlo/$(image_name)

#change version if you want to push a new image
major_version=1
minor_version=1
patch_version=5
version=$(major_version).$(minor_version).$(patch_version) 

include ../../mk/dockerci.mk

#run only at 4 am
cron_pattern=0 4 * * *

.PHONY: docker_build
docker_build:
	docker build --build-arg version=$(version) --build-arg git_revision=$(shell git log | head -n 1 | cut  -f 2 -d ' ') --build-arg cron_pattern="$(cron_pattern)" -t $(local_image) .

