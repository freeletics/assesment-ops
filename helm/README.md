# The helm chart for deploying GorgeousCode on Kubernetes

## Prerequisites Details

* Kubernetes 1.10+

## Chart Details
This chart will do the following:

* deploy PostgreSQL as a subchart and make the environment variables visible to the  application chart, following the DRY principles 

## Requirements
- A running Kubernetes cluster
  - Dynamic storage provisioning enabled
  - Default StorageClass set to allow services using the default StorageClass for persistent storage
- [Helm](https://helm.sh/) installed and setup to use the cluster (helm init)


### Deploy Testcode, ovirun is an example release name
Deploy the test-ops tools and services
```bash
# Get required dependency charts
$ helm dependency update test-ops

# Deploy Test-ops
$ helm install -n ovirun ./test-ops
```

## Status
See the status of your deployed **helm** releases
```bash
$ helm status ovirun
```

## Upgrade
To upgrade an existing test-ops, you still use **helm**
```bash
# Update existing deployed version to tagx
$ helm upgrade --set opsApp.imageTag=tagx ovirun
```

## Cleanup
Removing a **helm** release is done with
```bash
# Remove the test-ops services and data tools
$ helm delete --purge ovirun

#Remove also the persistence volume from the PostgreSQL 
kubectl delete pvc $(kubectl get pvc | grep -v NAME | awk {'print $1'})

```
