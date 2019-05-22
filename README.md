Gorgeous Code Assessment Test Operations
=======
This repo is ment to be as permanent work in progress.
The code in this repo should be dockerizable and been run on top of
kubernetes.

## Changes

1. Added Dockerfile
2. Added Helm charts for postgres and the app:
```console
$ tree charts -L 1
charts
├── app
└── postgres
```


## CI/CD

All the secret variables (passwords etc.) we insert only at deploy runtime
(don't store them in git).

1. Docker build and push (every upgrade)
```console
$ docker build -t $TAG .
$ docker push $TAG
```
2. Deploy/upgrade postgres (only the first time or on postgres upgrade)
```console
$ helm template --name postgres \
    -f charts/postgres/production.yaml \
    --set postgresql.postgresqlPassword=$DB_PASSWORD \
    charts/postgres > templated.yaml
$ kubectl apply -n $NAMESPACE -f templated.yaml
```
3. Run job db-create (only the first time)
```console
$ helm template --name app \
    -f charts/app/production.yaml \
    --set deviseSecret=foo \
    --set db.password=pass \
    --set dbCreate.render=true \
    -x templates/job-db-create.yaml \
    charts/app > templated.yaml
$ kubectl apply -n $NAMESPACE -f templated.yaml
```
4. Run job db-upgrade (every upgrade)
```console
$ helm template --name app \
    -f charts/app/production.yaml \
    --set deviseSecret=foo \
    --set db.password=pass \
    --set dbMigrate.render=true \
    -x templates/job-db-migrate.yaml \
    charts/app > templated.yaml
$ kubectl apply -n $NAMESPACE -f templated.yaml
```
5. Deploy/upgrade the app (every upgrade)
```console
$ helm template --name app \
    -f charts/app/production.yaml \
    --set deviseSecret=$DEVISE_SECRET \
    --set db.password=$DB_PASSWORD \
    charts/app > templated.yaml
$ kubectl apply -n $NAMESPACE -f templated.yaml
```
