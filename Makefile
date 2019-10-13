APP_IMAGE=test-ops:latest
REGISTRY_URL=my-ecr-registry.amazonaws.com
APP_TAG=1.0.1 #could also use git describe --abbrev=0
HELM_APP_NAME=freeletics

docker.build:
	docker build . -t $(APP_IMAGE)

docker.run-compose:
	docker-compose up -d

docker.stop-compose:
	docker-compose down

docker.push-registry:
	docker tag $(APP_IMAGE) $(REGISTRY_URL)/$(APP_IMAGE):v$(APP_TAG)
	docker push $(REGISTRY_URL)/$(APP_IMAGE):v$(APP_TAG)


helm.deploy:
	helm install --set image.tag=v1.0.1 --name $(HELM_APP_NAME) test-ops-k8s-app


helm.upgrade:
	helm upgrade --set image.tag=v1.0.1 --name $(HELM_APP_NAME) test-ops-k8s-app

