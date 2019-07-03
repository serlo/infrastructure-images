version := 6.2.2

.PHONY: docker_build_ci
# builds the docker image in the ci and pushes it to eu.gcr.io
docker_build_ci:
	 docker pull eu.gcr.io/serlo-containers/${image_name}:$(version) 2>/dev/null >/dev/null || $(MAKE) docker_push

.PHONY: docker_push_ci
# push grafana image to gcr.io
docker_push_ci:
	docker pull eu.gcr.io/serlo-containers/grafana:$(version) || docker pull grafana/grafana:$(version)
	docker tag grafana/grafana:$(version) eu.gcr.io/serlo-containers/grafana:$(version);
	docker push eu.gcr.io/serlo-containers/grafana:$(version)

.PHONY: docker_build_minikube
# checks if the docker images is in the remote docker and builds it if not
docker_build_minikube:
	@echo nothing to do minikube pulls grafana from github


docker_build:
	@echo nothing to do we take grafana from github

