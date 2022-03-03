

# If no 'ENV=xxx' is provided when calling the targets we will asume 'docker' as the environment
ENV ?= docker
include ./envs/${ENV}.env
export

define hr
	@printf '%.s─' $$(seq 1 $$(tput cols))
	@echo "$$(tput setaf 3)Running 'make $@'$$(tput sgr0)"
	@printf '%.s─' $$(seq 1 $$(tput cols))
endef

# Image info
IMAGE_REPO := donhector
IMAGE_NAME := fastapi-hello-world
IMAGE := $(IMAGE_REPO)/$(IMAGE_NAME)
TAG ?= latest

# Build args
DATE := $$(date "+%Y%m%dT%H%M%S")
COMMIT := $$(git rev-parse --short HEAD)

.DEFAULT_GOAL := help

.PHONY: help
help: ## Shows this help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: build
build: ## Build the docker image.
	$(call hr)
	@docker build -t ${IMAGE_NAME}:${TAG} \
		--build-arg BUILD_DATE=${DATE} \
		--build-arg VERSION=${TAG} \
		--build-arg COMMIT=${COMMIT} \
		.

.PHONY: build-nc
build-nc: ## Build the docker image without reusing the cache
	$(call hr)
	@docker build --no-cache -t ${IMAGE_NAME} .

.PHONY: tag
tag: ## Tag the docker image for a specific registry (ie: make tag ENV=aws)
	$(call hr)
	docker tag ${IMAGE_NAME} ${REGISTRY}/${IMAGE}:${TAG}

.PHONY: run
run: build  ## Run the docker container.
	$(call hr)
	@docker run --name ${IMAGE_NAME} --rm -d -p 8000:80 ${IMAGE_NAME}

.PHONY: health
health:  ## Check application health
	@curl -sk 127.0.0.1:8000 | jq .

.PHONY: docs
docs:  ## Open the application documentation (assuming you are inside WSL2).
	$(call hr)
	@wslview http://127.0.0.1:8000/docs

.PHONY: stop
stop:  ## Stop the docker container.
	$(call hr)
	@docker stop ${IMAGE_NAME}

.PHONY: clean
clean: stop  ## Remove the docker container and image.
	$(call hr)
	@docker rmi -f $$(docker images -q ${IMAGE_NAME})

.PHONY: shell
shell:  ## Run and shell into the docker container.
	$(call hr)
	@docker run --name ${IMAGE_NAME} --rm -it -v $(shell pwd)/app:/app/ ${REGISTRY}/${IMAGE}:${TAG} /bin/sh

.PHONY: exec
exec:  ## Exec inside the running docker container.
	$(call hr)
	@docker exec -ti ${IMAGE_NAME} /bin/sh

.PHONY: login
login:  ## Login to a docker registry.
	$(call hr)
	@echo "Login into '${REGISTRY}' with username '${REGISTRY_USERNAME}'..."
	@echo ${REGISTRY_PASSWORD} | docker login --username ${REGISTRY_USERNAME} --password-stdin ${REGISTRY}

.PHONY: push
push:  ## Push the docker image to a specific registry (ie: make push ENV=aws).
	$(call hr)
	@if [ "${ENV}" = "aws" ]; then aws ecr create-repository --repository-name ${IMAGE} || true; fi
	@docker push ${REGISTRY}/${IMAGE}:${TAG}

.PHONY: release
release: build tag push  ## Build and push image to registry.

.PHONY: logs
logs:  ## Show container logs
	@docker logs ${IMAGE_NAME}

.PHONY: registry-start
registry-start:  ## Start a local docker registry on port 5000.
	$(call hr)
	@mkdir -p /tmp/docker-registry
	@docker run --rm --name httpd --entrypoint htpasswd \
		httpd:2 -Bbn ${REGISTRY_USERNAME} ${REGISTRY_PASSWORD} > /tmp/docker-registry/htpasswd
	@docker run --rm --name registry -d -p 5000:5000 \
		-v /tmp/docker-registry:/var/lib/registry \
		-e REGISTRY_AUTH=htpasswd \
		-e 'REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm' \
		-e REGISTRY_AUTH_HTPASSWD_PATH=/var/lib/registry/htpasswd \
		registry:2

.PHONY: registry-stop
registry-stop:  ## Delete a local docker registry.
	$(call hr)
	@docker stop registry
	@sudo rm -rfv /tmp/docker-registry
