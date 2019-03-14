# The helm chart for deploying GorgeousCode on Kubernetes

## Prerequisites Details

* Kubernetes 1.10+

## Chart Details
This chart will do the following:

* Optionally deploy PostgreSQL

## Requirements
- A running Kubernetes cluster
  - Dynamic storage provisioning enabled
  - Default StorageClass set to allow services using the default StorageClass for persistent storage
- [Helm](https://helm.sh/) installed and setup to use the cluster (helm init)


### Deploy Testcode
Deploy the test-ops tools and services
```bash
# Get required dependency charts
$ helm dependency update test-ops

# Deploy Test-ops
$ helm install -n test-ops test-ops
```

## Status
See the status of your deployed **helm** releases
```bash
$ helm status test-ops
```

## Upgrade
To upgrade an existing test-ops, you still use **helm**
```bash
# Update existing deployed version to tagx
$ helm upgrade --set ops-app.image-tag=tagx test-ops
```

## Remove
Removing a **helm** release is done with
```bash
# Remove the test-ops services and data tools
$ helm delete --purge test-ops

```
