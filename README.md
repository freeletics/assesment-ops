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


### Assignment

- Prereqs (on host machine)
  ```
   Docker
   Minikube
   Helm
   kubectl
  ```
- Deployment
    - Start minikube
        ```
        minikube start --memory 8192 --cpus 4 --disk-size 40g
        ```
    - Switch to minikube docker env
        ```
        eval $(minikube docker-env)

        # IMPORTANT: Docker images MUST be built using THIS shell
        ```
    - Build a base image (will only install required gems)
        ```
        # the image will be 'local' for minikube

        docker build  -f Dockerfile-base -t flbase .
        ```
    - Build the app image
        ```
        docker build -t freeletics-app .
        ```
    - Create `freeletics` namespace
        ```
        kubectl create namespace freeletics
        ```
    - Generate secrets and add them as k8s secrets
        ```
        PGPASS=$(dd if=/dev/urandom bs=100 count=1 2>/dev/null | base64 | head -c 16)
        DEVISE_SECRET=$(dd if=/dev/urandom bs=100 count=1 2>/dev/null | base64 | head -c 64)

        kubectl create secret generic flapp-secrets -n freeletics \
        --from-literal=postgresql-user=postgres \
        --from-literal=postgresql-password=${PGPASS} \
        --from-literal=devise_secret=${DEVISE_SECRET}
        ```
    - Add `tiller` to the cluster
        ```
        helm init

        # watch pods until it is in Running state

        ```
    - Add a postgres database
        ```
        helm install --name postgres \
             --namespace freeletics \
             --set fullnameOverride=pg-database \
             --set replication.enabled=false \
             --set postgresqlDataDir=/data/pgdata \
             --set persistence.mountPath=/data/ \
             --set existingSecret=flapp-secrets \
             stable/postgresql

        # watch until the pod is running
        ```
    - Deploy test app
        ```
        cd kubernetes/charts
        helm install --namespace freeletics --name freeletics-app app-test
        #
        # follow instructions on how to access the app
        #
        ```
- Thoughts
    - Goal
        - to be able to install and have it running in minikube
        - to use Helm for deploying it (installing it)
        - to avoid exposing secrets in config files outside containers

    - Deployment
        - Jenkins for building and pushing the artifacts (docker images). Artifactory for docker repos.
        - Spinnaker for deploying the app in Kubernetes
        - blue/green, canary etc deployment strategies implemented

    - 'database.yml' and .gitignore
        ```
        database.yml cannot go into git because it may contain sensitive database credentials.

        Well, I took a risk and commented the line in .gitignore because I templated it with <%= ENV['...'] %> which are set in the container (taken from k8s secrets)
        ```
    - 'database.yml' MUST be ignored!!!
        ```
        # the ConfigMap patch is available, still templated but adds
        # a lot of duplicate code in this version :)

        cd kubernetes/
        patch -p1 < database-yml-configmap.patch

        ```
    - 'config/initializers/devise.rb'
        ```
        I had to add it, it wouldn't work without it. It uses ENV just like database.yml
        ```
    - liveness and readiness
        ```
        readiness probe is dummy because I couldn't find a /health endpoint for it
        ```
    - DB creation/migration
        ```
        used Helm hooks to accomodate this since 'db:create' and 'db:migrate' rake jobs can be run multiple times and not fail.
        ```
    - Monitoring
        ```
        there is no monitoring added but Newrelic and/or Prometheus stack would be a choice. Grafana for ploting.
        measure at least latency, throughput, error rate.
        ```
    - RBAC authorization
    - Ingress
        ```
        Did not add any, they make sense if you have multiple deployments and need to access them like:

        https://my-app1.cluster.tld
        https://my-app2.cluster.tld
        https://my-app3.cluster.tld

        ...with the help of an ingress controller (like nginx)

        ```
