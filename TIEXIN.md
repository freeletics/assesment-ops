# Tiexin's Solution

## App Changes

Main change is to read DB_HOST, DB_USER, DB_PWD from environment variables, and in the deployment, pass these values into the pod. DB_HOST can refer to a postgres service running in the same k8s cluster; DB_PWD can be a secret in k8s.

Also fixed some minor issues, like missing secret_key, and database.yml file. These should not be in the repo but to show what I did, I include the changes into `config/database.example.yml` and `config/initializers/devise.rb`.

## Dependency

Postgres. For testing I used one locally, also tried one in k8s cluster installed by `helm install stable/postgresql`.

## Dockerize

See `Dockerfile`.

Ideally in production ENV I would use alpine to reduce the size of the image.

## k8s Deploy

Under `k8s/` folder are the deployment and service files.

I included these to show you my work. (helm chart also included but that are mainly template changes and values, it's hard to see what I did).

Helm chart named "hello" is included under `hello/` folder.

For the deployment, can use both k8s yaml files:

```
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

or to use helm:

```
helm install hello
```

## Final Notes

According to the instructions from the tech team, I was not supposed to spend more than half an hour on this.

In reality I did some readings on Ruby no Rails first because although I have experience with Ruby, not much with rails.

Also I was not using minikube but the k8s cluster provided by docker for mac. Hope this is fine.

In fact this is a really big topic, things I considered but not have time to implement include:

- The readme file of this repo does not include detailed steps for setting it up. In an ideal world I would ensure each repo has a clearly defined readme so that no matter which one in the scrum team takes over a ticket on this repo, he knows exactly what to do.
- Optimize the docker image. As mentioned above, alpine should be used; currently the images size is huge (not pushed into docker hub).
- DB migration. Migrate db at the beginning of teach container creation is definitely not ideal because it only needs to be done once and in this way it's slow. Right now I'm doing this in the entrypoint script, removing existing pid files of the server then migrate db which is a quick hack, in production I would probably consider some other technics like Init Containers, or to let the code handle the db changes itself in order to achieve maximum backward/forward compatbilities (which is important during rolling update especially rolling back).
- Configurations. Currently I hard coded some configs in the k8s yaml file or in the helm template, which is only a quick hack to get a deployment done. In reality I would use config maps for configurations, and secrets for credentials like the database password.
- Deployment configuration. 1 replica is not OK for production env; metrics need to be defined together with horizontal pod autoscaler.

