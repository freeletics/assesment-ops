Gorgeous Code Assessment Test Operations
=======

The result:
- The application is made parameterized as much as possible so that it can take variables from environment(secrets, configs and environment variables).
- The application is Dockerized.
- After setting up kubectl and Helm;
```bash
$ docker build -t frl-g:0.1 .
# Push if needed
$ cd /path/to/repo/helm-test-ops
$ helm install --name frl .
$ kubectl get pods
```

The progress:
- I have used Docker for Mac both as Docker machine and Kubernetes cluster. In that way I did not have to set up a Docker registry or push image to somewhere.
- Firstly, I had to run the application. I have started working with a Ruby container and tried to run the application. Since it is a Ruby on Rails app, I started reading some documents about Rails. The most helpful one for me is [that post on freeCodeCamp](https://medium.freecodecamp.org/lets-create-an-intermediate-level-ruby-on-rails-application-d7c6e997c63f).
- Afterwards, I created a Docker network and started a PostgreSQL container attached to that network. I created a new Ruby container with the cloned repo directory bind-mounted and port 3000 exposed.
- I had to make some small arrangements about Devise and Ruby versions on Gemfile and Gemfile.lock (that was the most time-consuming thing due to a bug on Devise the need of upgrading it).
- After running the application is done, the rest was pretty straightforward. I prepared a Dockerfile with the commands that I wrote when running the application on Ruby:2.5.3 Docker image and tried to optimize its build time. I also make database configuration as environment variables.
- A Helm package with PostgreSQL dependency is created. (It needs some improvements like getting Postgres username from its package).




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
