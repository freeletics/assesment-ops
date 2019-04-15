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

# Notes

My task from the ops team was to compose a readme of my approach to the deployment of this ruby on rails app. As I do not have much practical experience with the tools, I decided to write my thoughts rather than submitting unworking/unfinished code, at a high level.

The app environment is defined in the Dockerfile.
I used a docker compose file to test the most basic services needed to run the app - in this case I just have a postgresql db.
So docker compose can create and start a running containerized app on a single host.

```
docker-compose build
docker-compose up
```

The next step is to start up minikube VM allowing a local kubernetes dev cluster.

```
minikube start
kubectl config use-context minikube
eval $(minikube docker-env)
```

From here I can test deployment of the docker container, specifying the locally built image

```
docker build -t test-ops:0.0.1 .
kubectl run test-op1s --image=test-ops:0.0.1 --port=3000 --image-pull-policy=Never
```

Now we have a pod, and can expose the app by specifying the NodePort as minikube cannot use a loadbalancer

```
kubectl expose deployment test-ops --type=NodePort --name=ext_test_ops
```

The next steps are to create a Chart to make this deployment straightforward and repeatable.
Helm charts take out the need to run kubectl commands, making it clear to kubernetes the deployment
and management of clusters (minikube only one cluster).

This begins the development workflow, changes to the app, result in changes to the image, which is deployed for testing.
Having a CI tool plugin to kubernetes for automated testing will give this workflow pratical use.

Minikube would be replaced by a complete kubernetes deployment in a staging and production setting. The database would be changed to a managaged db from the cloud, i.e. AWS RDS.

Charts can be used to handle scaling, upgrading, aswell as deployment strategies as needed, blue/green for example.

In an ideal world this entire process would be initiated via git branches, merges and tags.

As this was time limited, spending some proper time using the tools and familiarising myself with the workflow would give me a deeper understanding. I learn well by use, trial and error. Put in a business context I would learn fast and put in time upskilling.