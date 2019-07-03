#
# goals required for continous integration builds that push to gcr.io
#

ifeq ($(image_name),)
$(error image_name not defined)
endif

ifeq ($(version),)
$(error version not defined)
endif

ifeq ($(local_image),)
$(error local_image not defined)
endif

ifeq ($(major_version),)
$(error major_version not defined)
endif

ifeq ($(minor_version),)
$(error minor_version not defined)
endif

gce_image := eu.gcr.io/serlo-containers/$(image_name)

patch_version ?= $(shell git log --pretty=format:'' | wc -l)

.PHONY: docker_push
# push docker container to gcr.io registry
docker_push:
	../../scripts/check_changes.sh . ; if [ $$? != 0 ] ; then $(MAKE) docker_push_impl; fi

docker_push_impl:
	docker tag $(local_image):latest $(gce_image):latest
	docker push $(gce_image):latest
	docker tag $(local_image):latest $(gce_image):$(major_version)
	docker push $(gce_image):$(major_version)
	docker tag $(local_image):latest $(gce_image):$(major_version).$(minor_version)
	docker push $(gce_image):$(major_version).$(minor_version)
	docker tag $(local_image):latest $(gce_image):$(version)
	docker push $(gce_image):$(gce_image):$(version)
	docker tag $(local_image):latest $(gce_image):sha-$(shell git describe --dirty --always)
	docker push $(gce_image):sha-$(shell git describe --dirty --always)


