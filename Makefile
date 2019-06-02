.PHONY: tests docker dev docker-push

APP_NAME := gorgeous-code-assessment
DOCKER_IMAGE_VERSION := latest

ENV := development

REMOTE_REGISTRY := docker.io
REMOTE_USERNAME := macunha1
KUBE_NAMESPACE := default

tests: docker
	docker run -it --name 'gorgeous-test-$(shell date +"%s")' \
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

helm-delete:
	# XXX: Unsafe method to restart the helm release
	helm list --namespace ${ENV} \
		--chart-name ${APP_NAME} && \
		helm delete ${APP_NAME}-${ENV} || true

helm-db:
	# The database helm "deploy" is separated to allow it to be used for more applications
	helm install --replace ${PWD}/ops/${APP_NAME}/charts/postgresql-5.0.0.tgz \
		--name ${APP_NAME}-${ENV}-db \
		--namespace ${ENV}

helm: helm-delete # XXX: Uncomment if you need to always reset helm release
	# helm install --dep-up --replace ${PWD}/ops/${APP_NAME}
	helm install --replace ${PWD}/ops/${APP_NAME} \
		--set application.environment="${ENV}" \
		--name ${APP_NAME}-${ENV} \
		--namespace ${ENV} # Isolating namespaces by environment
