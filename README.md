# Introcuction
test-ops is an application ment to ... based on Ruby on Rails.
Ruby on Rails, or simply Rails, is a web application framework written in Ruby under MIT License. Rails is a model–view–controller (MVC) framework, providing default structures for a database, a web service, and web pages.

The application will be packaged in docker and runned in a Kubernetes clusters that runs on top of AWS.

The Database and the Redis cache used by this application will not be managed in this, they are part of the managed service of AWS.

## Run the application localy
[HERE SOME DETAILS HOW TO DO THAT]


# Packaging the application
The application will run using [docker](https://www.docker.com/). Docker will allow to run the application on any docker environment.

## Building the docker image
In order to build the image that will contain the application the following command needs to be executed:
```
docker build . -t test-ops
```
Alternatively you can run the same command usign the Makefile
```
make docker.build
```

## Runing the application in docker locally
In order to test the application running inside docker. You can use the [docker-compose](https://docs.docker.com/compose/) file that is embedded to this repo.
```
docker-compose up -d
```
or using the Makefile
```
make docker.run-compose
```

# Pushing the image to the registy
Once the docker image has been tested and fully functionnal, this image will be pushed to the registry where all other versions of this image will be pushed.
**NOTE:**
I a normal application I would decouple the application and the elements to deploy this application in to production in different git repositories.
**ASSUMPTIONS:**
We will take the version number of the application a v1.0.1

push the image to the registy
```
docker tag test-ops my-ecr-registry.amazonaws.com/test-ops:v1.0.1
docker push my-ecr-registry.amazonaws.com/test-ops:v1.0.1
```
or using the Makefile
```
make docker.push-registry
```

# Application deployment
## How to deploy test-ops in Kubernetes
Deploying test-ops application as Helm is the easiest to have production grade deployments on Kubernetes.

Helm will act as application management framework, all updates to the application will be handeled by Helm.

The kubernetes application specifics will be define using [Helm Charts](https://github.com/helm/charts)

For development purposes you can use [minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/)

## Installing the chart for the first time
To run helm to setup the chart you can run the following command:

```
helm install --set image.tag=v1.0.1 --name freeletics test-ops-k8s-app
```
or use the Makefile
```
make helm.deploy
```

## Verify that the application is running:
Just run `helm status freeletics`

## Update an existing deployment
If the application was already running, you can upgrade it by running the following commands:
```
helm upgrade freeletics test-ops-k8s-app
```
or by just running the Makefile command:
```
make helm.upgrade
```

# Conclusion
Improvments:
- Having a Jenkins pipeline that run the deployment of the application
- Having the application that automatically scales according to some metrics
- Use config maps for the database configuration on the helm chart
- Use helm secrets for the password of the database
- Add a new template for the Service accout of the test-ops APP
- Add some network policies if necessary depending on the context
- Use ingress controllers and AWS ALB to reduce costs
- Update the ruby code to be able to use global environment variables for the database and redis configuration
- In the docker file set a more relevant healthcheck


# Freeletics test thoughts
Most of the code provided was untested, I don't have access to my computer. It is juste an idea how to do it. Furthermore, I will improve the deployment and add some test uses cases before deploying to production. I would use a differents kubernetes clusters to run the tests.





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
