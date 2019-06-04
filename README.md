Gorgeous Code Assessment Test Operations
=======
This repo is ment to be as permanent work in progress.

# Requirements

What we use for operations development:

* [Minikube](https://github.com/kubernetes/minikube) to represent the kubernetes we use
* [Helm Package Manager](https://github.com/kubernetes/helm) to package the kubernetes manifests
* [Charts](https://github.com/kubernetes/charts) for public available components someone may need in addition on kubernetes.


# Quickstart

To setup your gourgeous environment all you have to do is:

If it's necessary to init the `helm` and configure `tiller` in minikube:
```bash
make helm-setup # Then wait some time for tiller pod to come up
```

And just fire!
```bash
make helm
```

This will download the remote image from Docker hub and release in Kubernetes

## Setting up another environment

By default it will use development for environment, if you want to deploy somewhere else, just pass it through
```bash
make ENV=somewhere helm # "somewhere" must exist in our rails envs
```

## Getting image from another registry

There's parameters to set the `helm` remote registry, user, image name and some other configurations.
You can see it all in [Makefile](Makefile)

```bash
make REMOTE_REGISTRY=top.private.com \
    REMOTE_USERNAME=janedoe \
    APP_NAME=another-gorgeous-code \
    helm
```

## Installing the database in a different release

It's useful if you want to deattach this database release from the gourgeous app
```bash
make helm-db
```

# Build and update

To upgrade this code and maintain it, these instructions should be helpful

## Docker build

We also have a gourgeous command to build docker, guess what?

```bash
make docker
```

To change the configurations, like registry and username (same in Getting from another registry...):
```bash
make REMOTE_REGISTRY=top.private.com \
    REMOTE_USERNAME=janedoe \
    docker
```

## Running tests inside docker

```bash
make tests
```

## Docker publish in registry

```bash
make docker-push
```

Accept the same parameters (here comes janedoe again!):
```bash
make REMOTE_REGISTRY=top.private.com \
    REMOTE_USERNAME=janedoe \
    docker-push
```

## Most relevant entities overview

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
