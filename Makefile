.PHONY: tests docker docker-push save-docker-image load-docker-image helm-setup helm-db helm-delete helm-lint helm

APP_NAME := gorgeous-code-assessment
DOCKER_IMAGE_VERSION := latest

ENV := development
MIGRATION_STRATEGY := initContainer

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

helm-setup:
	helm init --history-max 100
	helm dep up "${PWD}/ops/${APP_NAME}"

helm-db:
	# The database helm release can be separated, allowing it to be used from other apps
	helm install --replace "${PWD}/ops/${APP_NAME}/charts/postgresql-5.0.0.tgz" \
		--name ${APP_NAME}-${ENV}-db \
		--namespace ${ENV}

helm-delete:
	# XXX: Wipe the helm release
	helm list --namespace ${ENV} \
		--chart-name ${APP_NAME} && \
		helm delete ${APP_NAME}-${ENV} --purge || true

helm-lint:
	helm lint --set application.environment="${ENV}" \
		"${PWD}/ops/${APP_NAME}"

helm:
	# helm install --dep-up --replace ${PWD}/ops/${APP_NAME}
	helm upgrade --install ${APP_NAME}-${ENV} "${PWD}/ops/${APP_NAME}" \
		--set image.repository="${REMOTE_REGISTRY}/${REMOTE_USERNAME}/${APP_NAME}" \
		--set database.migrationStrategy="${MIGRATION_STRATEGY}" \
		--set application.environment="${ENV}" \
		--namespace ${ENV} # Isolating namespaces by environment