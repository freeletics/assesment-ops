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

# Deployment on Kubernetes

### Getting code into container
1. `git clone` in Dockerfile with **single branch clone** is `option-1`. Git Credentials can be passed while building image using `mount paths` (sharing file paths) so that credentials are not left inside intermediate layers as well as with final image.
2. To make sure `git clone` is not cached, echo `timestamp` to a temporary file before `git clone` in Dockerfile.
3. `COPY . .` is `option-2`

### build abd ship docker image
1. Build Docker image for application when new changes are pushed to repository using webhooks to repository
2. Push to Container Registry if using AWS or similar. Add two tags to the image to be deployed at the end of CI pipeline - `1. :vX.Y.Z` `2. :latest`
[This is to know which version is deployed currently and to keep track of version history when it comes to rollback]
3. Image policy is `PullAlways` with `image tag = latest` in `deployment.yaml`

### Kubernetes Topology
1. Each namespace represents an environment.
2. Database and application deployments are exposed as `service` so that they can be resolved using `K8S DNS`

### database deployment:
1. To persist data, one can use `persistent volumes` and `persistent volume claim` objects for database pods. The pods      could be handled by `statefulsets` with `volume claim templates`.
2. Periodic snapshots to take backup especially before running any new migrations.
3. DB pod will not be replaced during deployment unless it is killed externally. Only migration jobs will be run to         update the state of database.
4. A schema migration `kubernetes job` should be run before application deployment happens. This should use same `image:latest` as application container

### application deployment:
1. Replace application container with rolling deployment strategy for e.g min of `x` number of pods to be available while updating the deployment.

### data loss recovery/rollback:
1. Restore volume from back up snapshots. Create new `pv` and `pvc` objects. Make changes in database deployment.yaml so    that pods will find the restored volume. This approach may not be suitable for all kinds of providers. Public cloud providers like AWS do support this approach. 
2. Tag the previously deployed stable image as `latest` and roll out application `deployment.yaml`. Do not run migration    job this time.