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
A new AWS account can be bootstrapped for Terraform management. This must be run manually outside CI/CD for the first time
```sh 
aws cloudformation deploy --stack-name bootstrap --template-file providers/aws/bootstrap.yaml --parameter-overrides OrgName=org-name OrgId=org-id RepoName=repo-name RepoId=repo-id --capabilities CAPABILITY_NAMED_IAM
```

Once the stack exists, subsequent runs for bootstrapping can be triggered via Github workflows.

The public Route 53 zone for the API domain is created by Terraform. The first workflow run creates the zone and then halts on certificate validation, because the name servers are not yet delegated. Read them from the Terraform output and manually add them to the domain registrar, then re-run the workflow
```sh
terraform -chdir=providers/aws output route53_name_servers
```

Running the workflow requires setting the following environment configuration variables in the repository settings
```
AWS_ACCOUNT=123456789012
AWS_REGION=us-east-1
API_DOMAIN=api.example.com
```

It also requires the following secret, which ArgoCD uses to read the manifests in this repository. A personal access token with read access to the repository contents is sufficient
```
GH_TOKEN=github_pat_xxxxxxxxxxxx
```

### Google Cloud
#### Prerequisites
Create a project and link a billing account. The project is bootstrapped for Terraform management by an Infrastructure Manager deployment, which runs as its own service account. Set that up once
```sh
gcloud services enable config.googleapis.com --project project-id
gcloud iam service-accounts create infra-manager --project project-id
until gcloud iam service-accounts describe infra-manager@project-id.iam.gserviceaccount.com --project project-id >/dev/null 2>&1; do sleep 5; done
for role in roles/config.agent roles/owner; do
  gcloud projects add-iam-policy-binding project-id --member serviceAccount:infra-manager@project-id.iam.gserviceaccount.com --role $role
done
```

Then deploy the bootstrap configuration. This must be run manually outside CI/CD for the first time. Infrastructure Manager rejects a source directory containing a local `.terraform` directory, so remove it first if `terraform init` was run there
```sh
rm -rf providers/gcp/bootstrap/.terraform
gcloud infra-manager deployments apply projects/project-id/locations/us-central1/deployments/bootstrap --project project-id --service-account projects/project-id/serviceAccounts/infra-manager@project-id.iam.gserviceaccount.com --local-source providers/gcp/bootstrap --input-values project=project-id,region=us-east1,org_name=org-name,org_id=org-id,repo_name=repo-name,repo_id=repo-id
```

Once the deployment exists, subsequent runs for bootstrapping can be triggered via Github workflows.

The public Cloud DNS zone for the API domain is created by Terraform. The first workflow run creates the zone and then halts on the certificate precondition, because the name servers are not yet delegated. Read them from the Terraform output and manually add them as NS records for the API domain at the domain registrar, then re-run the workflow
```sh
terraform -chdir=providers/gcp output dns_name_servers
```

Running the workflow requires setting the following environment configuration variables in the repository settings, alongside the `GH_TOKEN` secret above
```
GCP_PROJECT=project-id
GCP_PROJECT_NUMBER=123456789012
GCP_REGION=us-east1
GCP_API_DOMAIN=api.gcp.example.com
GCP_ADMIN_EMAIL=admin@example.com
```