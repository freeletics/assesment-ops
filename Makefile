VERSION=stable

build:
	docker build . -t operationaldev/test-ops:${VERSION}

compose-db:
	docker-compose up -d postgres && sleep 10 && docker-compose run web rake db:create && docker-compose run web rake db:migrate #RAILS_ENV=development

push: build
	docker push operationaldev/test-ops:${VERSION}

k8s-secrets:
	kubectl create secret generic db-user-pass --from-literal=password=mysecretpass && kubectl create secret generic db-user --from-literal=username=postgres && kubectl create secret generic secret-key-base --from-literal=secret-key-base=50dae16d7d1403e175ceb2461605b527cf87a5b18479740508395cb3f1947b12b63bad049d7d1545af4dcafa17a329be4d29c18bd63b421515e37b43ea43df64

k8s-database:
	kubectl apply -f kube/database.yaml
	sleep 10
	kubectl apply -f kube/database_create.yaml
	sleep 10
	kubectl apply -f kube/database_migrate.yaml
	sleep 10
k8s-deploy: k8s-database
	kubectl apply -f kube/ingress.yaml -f kube/rails-kube-app.yaml -f kube/rails-service.yaml

k8s-cleanup-db:
	kubectl delete jobs database-create
	kubectl delete jobs database-migrate
	kubectl delete service postgres
	kubectl delete replicationcontroller postgres
	kubectl delete pvc postgres-pvc
	kubectl delete pv postgres-pv

k8s-cleanup: k8s-cleanup-db
	kubectl delete service rails
	kubectl delete replicationcontroller rails
	kubectl delete ingress rails-ingress
