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

---

### Note: 

Since I should only be spending one hour on this task, I'll only work on scaffolding the deployment by implementing the most essential bits.

In reality, I had to do some digging beforehand because I'm not familiar with the Rails ecosystem and Ruby in general. :D

I focused on deploying the app locally firstly using docker-compose, then I started on the Helm Chart but didn't finish it.

I avoided changing too much in the code and kept the configuration simple as I don't want to spend more time than a few of hours on this test.

Each of the Todos would need to be considered and implemented to some degree before releasing the app on production.


Most obvious things to fix in order:

- Remove all secrets which are in plaintext in a production deployment
- Configure PG Chart through exposed values
- Add ConfigMaps & Secrets for the rails app
- Database setup in post-install hook of Helm ?
- Database migrate in post-update & post-rollback hook of Helm ?
- Database backup with pre-upgrade, cleanup deployments if migrations can't run with existing connections  
- InitContainer: wait for the database to be up, or handle this inside the app.
- Add CI/CD Pipeline

  <Helm Charts are very complex in feature so this could be extended more and more, but these are some things that need to be done off the top of my head>
### TODOs:


- [ ] Containerization
- [ ] Development documentation
- [ ] Deployment documentation
- [ ] Local development environment
- [ ] Staging environment
- [ ] Production environment
- [ ] CI/CD Pipeline
- [ ] Secret Management 
- [ ] Logging
- [ ] Metrics
- [ ] Crash & Error Reporting / Analysis
- [ ] Stateful Data / Persistent Volumes
- [ ] Backups

### QUESTIONS:

- Where / how to handle secrets?
    > Putting in secrets as env variables?  
    > We can't save the kubernetes secret object into the VCS without encrypting it.  
    > Possible solution:  
    > 1 Master key to encrypt the secret configurations directory and commit the encrypted dir into VCS.
    > Problem in this approach: Now where do we save the master key, more importantly, how we do we secure the key while injecting it for decryption?  
    > We need to save these secrets somewhere so that we can edit or view them when necessary, but the secrets need to stay encrypted at rest.  
    > Alternatives: Special Kubernetes Secret plugins & projects. They need to be setup properly,
    > but they allow us to solve this exact problem.

- Env variables or configuration files for secrets?  
    > Configuration files are more secure. Env variables might leak due to wrongly configured debugging or logging. Env Variables, however, are the simplest option.

- Secret management using something like Vault?
    > Is possible but definitely harder than using env variables.  
    > This usually depends on the platform being used. Every major cloud platform have some secret management solution.

- Local development alternatives?
  > Docker-compose is certainly the easiest to setup. But a local / remote development cluster + Helm based development is much better for maintaining parity.  
  > This is a cutting edge topic: Possible tools to achieve this are Skaffold, Draft... etc.  
  > Depends on what needs to be achieved. 

- Local development / deployment documentation?
  > There should be enough documentation for any developer to get started contributing to the project without asking someone first. This includes writing new features, as well as how to test deployed branches, how deployment works and so on.

- CI/CD Pipeline?
  > The build / test / push / deploy stages are very common for a CI pipeline.  
  > It's also good to include dependency licence checkers / vulnerability analysis on application level / OS-level for the dev && master branches
  > In the end, every branch should be automatically testable with a URL by the end of the pipeline.

- Logging / Metrics / Error reporting?
  > Before an app is deployed onto production, it would be great to have unified logging, metrics collection for common stats and error reporting.  
  > Examples: ELK Stack for logging, Prometheus for metrics, Sentry for error reporting, Pagerduty? 

- Stateful Data Handling / Backups?
  > Easiest option is to make this somebody else's responsibility.  
  > This means using a 3rd party / managed service for production use.  
  > It's okay to deploy stateful apps to your own Kubernetes cluster for testing, development etc.
  > Managing stateful apps get harder as they scale and you need to introduce horizontal scaling.
  > If you have to use Kubernetes, the best option is to stick to a good operator implementation.
  > Understanding how an operator works internally is  quite difficult however, becase it requires expert knowledge in managing the stateful application as well as how kubernetes components work in general.
  > It's best to not introduce unnecessary complexity like this if you can avoid it.

- Microservices debugging / analysis?
  > Either use a third-party service to debug what's going on if there are multiple requests between the services, or use a tool which would let you track what's going on.
  > Linkerd, Jaeger and so on are some options to look at.

Versions of tools used:  

- OS: macOS Mojave 10.4.4
- Editor: VSCode Insiders 1.35.0
- Docker Desktop on Mac: 2.0.0.3
- Kubectl (via Docker Desktop):
  - Client Version: v1.10.11
  - Server Version: v1.10.11
- Helm:
  - Client: &version.Version{SemVer:"v2.12.3", GitCommit:"eecf22f77df5f65c823aacd2dbd30ae6c65f186e", GitTreeState:"clean"}
  - Server: &version.Version{SemVer:"v2.12.3", GitCommit:"eecf22f77df5f65c823aacd2dbd30ae6c65f186e", GitTreeState:"clean"}

---

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
