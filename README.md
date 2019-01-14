Gorgeous Code Assessment Test Operations
=======

# What has been done:

## Some general changes:
- Added database.yml which accepts from ENV Username Password and Hostname
- Added secrets.yml which again accepts from ENV secrets.
- Upgraded ruby version to 2.5.3 since ruby community claims teeny version does not break backwards compatibility, only brings in bug fixes.

### 1. CI
There is a Jenkinsfile (Jenkins Pipeline with Docker Plugin) which can be executed. What it does is, it builds the container, then it runs the tests and at the end it pushes the container to Docker registry. Of course if the tests pass.
Building is done from a Dockerfile which is setting up a new user not to run the app as root and sets timezone for easier debugging. I used alpine because I tested both alpine and ubuntu images and alpine is way smaller. 
Tests are ran with 2 containers, one with the app and another one which runs postgresdb.
Push is done to a registry.
### 2. CD
Helm chart is generated with a requirements.yml to get postgres database. I use secrets exposed by postgres helm chart.
### 3. Local development
When you change the code you can just do ```docker buid -t <your tag> . ``` to build the container. Then you do ```docker run -p 3000:300 <containerID> rails server``` to run the app. 
You can use a named containers to connect to a database which you have locally as a docker container.
Once you are done with the change you can commit it and then Jenkins will take over.
## Helm deployment and minikube.
If you want to run the application in minikube, you just need to do ```helm install test-ops-deployment``` after you pushed the container to your private registry. This will spin up both the app and postgres DB in your minikube.
If you already have it running, you can do ```helm install --upgrade test-ops-deployment```
## What can be improved
- Adding logging as a DaemonSet 
- Adding prometheus endpoint to be available for scraping.
- Play around with different number of replicas to see which one fits the best with traffic we are getting. Also play around with resource consumption to optimize the app and resources.
- Use ingress if you want to expose it as just a resource and share domain name?
- Make postgres username configurable

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
