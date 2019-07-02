#
# Makefile for local development for the serlo KPI project.
#

IMAGES := dbdump dbsetup varnish grafana

include mk/help.mk

.PHONY: _help
# print help as the default target. 
# since hte actual help recipe is quite long, it is moved
# to the bottom of this makefile.
_help: help

# forbid parallel building of prerequisites
.NOTPARALLEL:

.PHONY: build_image_%
.ONESHELL:
# build a specific docker image
build_image_%:
	@set -e
	eval "$(DOCKER_ENV)" && if test -d container/$* ; then $(MAKE) -C container/$* build_image; fi

.PHONY: build_image_forced_%
.ONESHELL:
# force rebuild of a specific docker image
build_image_forced_%:
	@set -e
	eval "$(DOCKER_ENV)" && if test -d container/$* ; then $(MAKE) -C container/$* docker_build; fi

.PHONY: build_images
# build docker images for local dependencies in the cluster
build_images: $(foreach CONTAINER,$(IMAGES),build_image_$(CONTAINER))

.PHONY: build_images_forced
# build docker images for local dependencies in the cluster (forced rebuild)
build_images_forced: $(foreach CONTAINER,$(IMAGES),build_image_forced_$(CONTAINER))



# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
BLUE   := $(shell tput -Txterm setaf 4)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)
DIM  := $(shell tput -Txterm dim)
