# Deployment

## Introduction

I've included a few different options for deployment. I find this helps with debugging and understanding how things work. I've included the version of tools I used when building as things age it's good to have context sometimes on the versions used. Also most of the deployment is done using a make file. This can totally be stripped out. I just find I can never remember the commands.

### Docker Compose

I included docker-compose as it's useful to get the app up and running and understand all the initialization steps required. This is especially useful if you aren't the author of the code or you are not a rails guru. This will create an app and db container. It will also initialize the db container so that the application is ready to use.

#### System requirements
    - docker-compose version 1.23.2, build 1110ad01
    - docker desktop community 2.0.0.0-mac81 (29211)

#### Steps to build
```sh
cd test-ops
make build
make compose-db
compose up
```

To access the app, go to http://127.0.0.1:3000 in your browser.

#### Troubleshooting

Issue: Database - Could not connect to server: Connection refused
Fix: run `make compose-db` again.

#### Cleanup
```sh
docker-compose down
rm -r tmp
```

### Kubernetes

For those who don't like helm, to deploy with native kubernetes.

#### System requirements
    - minikube version: v0.31.0
    - VirtualBox Version 5.2.18 r124319 (Qt5.6.3)
    - docker desktop community 2.0.0.0-mac81 (29211)

#### Steps to build
```sh
make push
make k8s-secrets
make k8s-deploy
```
Because the deployment is using ingress, you will need to create a host entry.
In your hostfile create a host entry as follows:
<minikube ip> gcode.co.za

Where <minikube ip> is your minikube ip. To get your minkube ip you can run:
```sh
minikube ip
```

To access the app, go to http://gcode.co.za in your browser.

#### Troubleshooting
Issue: 404 not found. Use incognito mode.

#### Cleanup
```sh
make k8s-cleanup
```


### Helm Chart

Here is a helm chart because thats what everyone wants these days.

#### System requirements
    - minikube version: v0.31.0
    - VirtualBox Version 5.2.18 r124319 (Qt5.6.3)
    - docker desktop community 2.0.0.0-mac81 (29211)
    - Helm(Client): &version.Version{SemVer:"v2.12.1", GitCommit:"02a47c7249b1fc6d8fd3b94e6b4babf9d818144e", GitTreeState:"clean"}
    - Tiller(Server): &version.Version{SemVer:"v2.12.1", GitCommit:"02a47c7249b1fc6d8fd3b94e6b4babf9d818144e", GitTreeState:"clean"}

#### Steps to build
```sh
make push
make k8s-database
helm install gcode
```

The default host used is gcode.co.za if not changed or overridden. If you use a different host value, you'll need to create a host entry for this. 

To access the app, go to http://gcode.co.za in your browser (or your custom URL).

#### Troubleshooting
Issue: 404 not found. Use incognito mode.

#### Cleanup
```sh
helm list
helm delete <deploymentname>
```

## To do (or stuff I would do if I worked on this further)

- Automate the build and destroy of minikube and helm so that this can be used as part of a CD pipeline.
- Switch to certs for k8s auth
- Add SSL
- Add rbac
- Make Helm Chart more flexible
- Add dependency community postgres chart rather than creating database outside of helm.
