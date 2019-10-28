Gorgeous Code Assessment Test Operations
=======
This repo is ment to be as permanent work in progress.
The code in this repo should be dockerizable and been run on top of
kubernetes.

**What we use for operations development:
**

[Minikube](https://github.com/kubernetes/minikube) to represent the kubernetes we use

[Helm Package Manager](https://github.com/kubernetes/helm) to package the kubernetes manifests

[Charts](https://github.com/kubernetes/charts) for public available components someone may need in addition on kubernetes.

What to achieve with this repo is to replace at least this readme in a pr with your thoughts how to handle the deployment of the app
in this repo. In addition a Dockerfile and a helm chart for basic usage are fine too.
Please do not invest much time in a perfect solution. Unless you like it as a good practice.
The result is very useful too, even it is only short brainstorming of the thoughts.


Regarding this code....


## Most relevant entities overview:

### Models
* Project: has the git information about each project
* Report: represents a full report with RBP analysis and Model Diagram analysis. Stores the commit hash, branch and the gc_config for each report.
* Rails BestPractices Analysis: belongs to one report and has the score and nbp_report for the analysis.
* Model Diagram Analysis: has the json_data attribute for the analysed project, representing the model diagram.

### Services
* Create Project: Creates new project and deals with github hooks.
* Start Report: Creates new report and associated ModelDiagram and RBP analyses.

### Jobs
* Create Report Job: Just to pass the HooksController to the StartReport service.
* Perform Analyses

### Modules/lib:
* VM Connection: Acts as an abstraction, for what could be in fact a Virtual Machine or Docker container where a GitHub project would be downloaded and analyzed. At the moment is just creating folders and playing with RVM and Gemsets to achieve this abstraction. Establishes new VM connection, prepares repository and gemsets, runs commands, generates DOT and JSON files. All around badass.

## Installation and other notes
* If you have errors with the gem `eventmachine` maybe this solution helps <https://stackoverflow.com/questions/30818391/gem-eventmachine-fatal-error-openssl-ssl-h-file-not-found>
* Check if you "/usr/locpsql -U postgres -h localhost" works, the gc.yml from the projects will probably create databases


## Basic deployment checklist

[] get Amazon Aurora with PostgreSQL credentials 

https://console.aws.amazon.com/rds/

* https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.CreateInstance.html

[] check minickube and helm installation

```sh
minikube status
kubectl cluster-info
kubectl --namespace kube-system get pods | grep tiller
```

[] setup secrets

```sh
SECRET_KEY_BASE=$(dd if=/dev/urandom bs=100 count=1 2>/dev/null | base64 | head -c 64)
DATABASE_HOST=mycluster.cluster-2128500.eu-west-1.rds.amazonaws.com
DATABASE_PORT=5432
GC_DATABASE=gc
GC_DATABASE_USERNAME=gc-database
GC_DATABASE_PASSWORD=gc-database-password

kubectl create secret generic gc-secrets \
--from-literal=gc-secret-key-base=postgres \
--from-literal=gc-database-host=${DATABASE_HOST} \
--from-literal=gc-database-port=${DATABASE_PORT} \
--from-literal=gc-database=${GC_DATABASE} \
--from-literal=gc-database-username=${GC_DATABASE_USERNAME} \
--from-literal=gc-database-password=${GC_DATABASE_PASSWORD}

```

[] build container

```sh
eval $(minikube docker-env)
docker build -t gc:minikube .
```

[] install chart

```sh
cd charts/gc/
helm install . 
```
[] migrate database schema

```sh
kubectl exec -it gc-pod sh
bundle exec rake db:migrate
```

[] enjoy :)

```sh
kubectl port-forward gc-pod 80:80
```
