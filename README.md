# Multicloud Kubernetes Provisioning
This repository contains IaC and scripts to provision a Kubernetes cluster across multiple cloud providers.

## Repository Layout
Directories are listed in deployment order.

1. [`providers/`](providers): Cluster provisioning for each infrastructure provider.
2. [`bootstrap/`](bootstrap): ArgoCD installer and Applications that deploy core components and discover apps.
3. [`core/`](core): Cluster components such as operators and controllers, synced by ArgoCD.
4. [`apps/`](apps): Workloads deployed by ArgoCD, one directory per app.

## Providers
### k3d (Local / Self-Hosted)
#### Prerequisites
All dependencies can be installed via a Makefile task
```sh
make -f providers/k3d/Makefile mac-deps
```

#### Usage
Create k3d cluster:
```sh
make -f providers/k3d/Makefile k3d-create CLUSTER_NAME=cluster-name
```

Initialize local development environment:
```sh
make -f providers/k3d/Makefile skaffold-init
```

Start local development environment:
```sh
make -f providers/k3d/Makefile skaffold-dev
```

### Amazon Web Services
#### Setup
Requires the AWS CLI, GitHub CLI and [yq](https://github.com/mikefarah/yq), with credentials for the target account.

1. Add an entry to [`providers/config.yaml`](providers/config.yaml):
   ```yaml
   aws:
     prod:
       account: "123456789012"
       region: us-east-1
       domain: api.example.com
       cluster_name: kube-cluster
       repository_name: kube
   ```
2. Bootstrap the account. Only needed once; the workflow re-applies it afterwards:
   ```sh
   providers/scripts/bootstrap.sh aws.prod
   ```
3. Set the GitHub environment secrets. `GH_TOKEN` needs read access to this repository:
   ```sh
   providers/scripts/set-github-env.sh aws.prod
   ```
4. Run the workflow. The first run halts until these name servers are added at the domain registrar:
   ```sh
   providers/scripts/name-servers.sh aws.prod
   ```

### Google Cloud
#### Setup
Requires the gcloud CLI, GitHub CLI and yq, and a project with billing linked.

1. Add an entry to [`providers/config.yaml`](providers/config.yaml). Get the project number with `gcloud projects describe project-id --format='value(projectNumber)'`:
   ```yaml
   gcp:
     prod:
       project: project-id
       project_number: "123456789012"
       region: us-east1
       domain: api.gcp.example.com
       cluster_name: kube-cluster
       repository_name: kube
   ```
2. Bootstrap the project. Only needed once; the workflow re-applies it afterwards:
   ```sh
   providers/scripts/bootstrap.sh gcp.prod
   ```
3. Set the GitHub environment secrets and the admin email:
   ```sh
   providers/scripts/set-github-env.sh gcp.prod
   ```
4. Run the workflow. The first run halts until these name servers are added at the domain registrar:
   ```sh
   providers/scripts/name-servers.sh gcp.prod
   ```
