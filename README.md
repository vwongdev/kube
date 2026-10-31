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
#### Prerequisites
Configuration for each deployment environment is read from [`providers/config.yaml`](providers/config.yaml), keyed by provider and then environment. Each GitHub deployment environment needs a matching entry
```yaml
aws:
  prod:
    account: "123456789012"
    region: us-east-1
    domain: api.example.com
    cluster_name: kube-cluster
    repository_name: kube
```

The scripts in [`providers/scripts/`](providers/scripts) read the entry named by a `<provider>.<environment>` argument and require [yq](https://github.com/mikefarah/yq) and the GitHub CLI.

A new AWS account can be bootstrapped for Terraform management. This must be run manually outside CI/CD for the first time, with credentials for the configured account
```sh
providers/scripts/bootstrap.sh aws.prod
```

Once the stack exists, subsequent runs for bootstrapping can be triggered via Github workflows.

The public Route 53 zone for the API domain is created by Terraform. The first workflow run creates the zone and then halts on certificate validation, because the name servers are not yet delegated. Read them from the Terraform output and manually add them to the domain registrar, then re-run the workflow
```sh
providers/scripts/name-servers.sh aws.prod
```

The workflow also requires the `GH_TOKEN` secret in the deployment environment, which ArgoCD uses to read the manifests in this repository. A personal access token with read access to the repository contents is sufficient. Set it with
```sh
providers/scripts/set-github-env.sh aws.prod
```

### Google Cloud
#### Prerequisites
Create a project and link a billing account.

Add an entry to [`providers/config.yaml`](providers/config.yaml) as for AWS. The project number can be read with `gcloud projects describe project-id --format='value(projectNumber)'`
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

A new project can be bootstrapped for Terraform management by an Infrastructure Manager deployment. This creates the Infrastructure Manager service account if missing, then deploys the bootstrap configuration. It must be run manually outside CI/CD for the first time
```sh
providers/scripts/bootstrap.sh gcp.prod
```

Once the deployment exists, subsequent runs for bootstrapping can be triggered via Github workflows.

The public Cloud DNS zone for the API domain is created by Terraform. The first workflow run creates the zone and then halts on the certificate precondition, because the name servers are not yet delegated. Read them from the Terraform output and manually add them to the domain registrar, then re-run the workflow
```sh
providers/scripts/name-servers.sh gcp.prod
```

The workflow also requires the `GH_TOKEN` secret as for AWS, and the admin email, which is kept out of the repository as the `GCP_ADMIN_EMAIL` configuration variable in the deployment environment. Set both with
```sh
providers/scripts/set-github-env.sh gcp.prod
```