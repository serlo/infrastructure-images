.PHONY: push_grafana_image

version := 6.2.2

build_image: docker_build
docker_build:
	docker pull eu.gcr.io/serlo-containers/grafana:$(version) || docker pull grafana/grafana:$(version)

docker_push:
	docker tag grafana/grafana:$(version) eu.gcr.io/serlo-containers/grafana:$(version);
	docker push eu.gcr.io/serlo-containers/grafana:$(version)
