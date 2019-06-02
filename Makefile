.PHONY: tests docker dev docker-push

APP_NAME := gourgeous-code-assessment
DOCKER_IMAGE_VERSION := latest

REMOTE_REGISTRY := docker.io
REMOTE_USERNAME := macunha1
KUBE_NAMESPACE := default

tests: docker
	docker run -it --name 'gourgeous-test-$(shell date +"%s")' \
		-v ${PWD}/test:/opt/${APP_NAME}/test --rm \
		${REMOTE_REGISTRY}/${REMOTE_USERNAME}/${APP_NAME}:${DOCKER_IMAGE_VERSION} \
		rake test

docker:
	docker build -t ${REMOTE_REGISTRY}/${REMOTE_USERNAME}/${APP_NAME}:${DOCKER_IMAGE_VERSION} .

docker-push: docker
	docker tag ${REMOTE_REGISTRY}/${REMOTE_USERNAME}/${APP_NAME}:${DOCKER_IMAGE_VERSION} \
		${REMOTE_REGISTRY}/${REMOTE_USERNAME}/${APP_NAME}:$(shell date -u --iso-8601)
	docker push ${REMOTE_REGISTRY}/${REMOTE_USERNAME}/${APP_NAME}:$(shell date -u --iso-8601)
	docker push ${REMOTE_REGISTRY}/${REMOTE_USERNAME}/${APP_NAME}:${DOCKER_IMAGE_VERSION}

save-docker-image:
	docker save -o ${CACHE_DIR}/${APP_NAME}.tar \
		${REMOTE_REGISTRY}/${REMOTE_USERNAME}/${APP_NAME}:${DOCKER_IMAGE_VERSION}

load-docker-image:
	docker load -i ${CACHE_DIR}/${APP_NAME}.tar || true
