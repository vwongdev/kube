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
aws cloudformation deploy \
  --stack-name bootstrap \
  --template-file providers/aws/bootstrap.yaml \
  --parameter-overrides OrgName=org-name OrgId=org-id RepoName=repo-name RepoId=repo-id \
  --capabilities CAPABILITY_NAMED_IAM
```

The organization and repository IDs can be read from the GitHub API
```sh
gh api repos/org-name/repo-name --jq '"OrgId=\(.owner.id) RepoId=\(.id)"'
```

Once the stack exists, subsequent runs for bootstrapping can be triggered via Github workflows.

The public Route 53 zone for the API domain is created by Terraform. The first workflow run creates the zone and then halts on certificate validation, because the name servers are not yet delegated. Read them from the Terraform output and manually add them to the domain registrar, then re-run the workflow
```sh
terraform -chdir=providers/aws output route53_name_servers
```

Running the workflow requires setting the following configuration variables in the deployment environment
```sh
ENV=prod
gh variable set AWS_ACCOUNT --env "$ENV" --body 123456789012
gh variable set AWS_REGION --env "$ENV" --body us-east-1
gh variable set API_DOMAIN --env "$ENV" --body api.example.com
```

It also requires the following secret, which ArgoCD uses to read the manifests in this repository. A personal access token with read access to the repository contents is sufficient
```sh
gh secret set GH_TOKEN --env "$ENV"
```

### Google Cloud
#### Prerequisites
Create a project and link a billing account.

A new project can be bootstrapped for Terraform management by an Infrastructure Manager deployment. Create its service account once
```sh
SA=infra-manager@project-id.iam.gserviceaccount.com
gcloud services enable config.googleapis.com --project project-id
gcloud iam service-accounts create infra-manager --project project-id
until gcloud iam service-accounts describe $SA --project project-id >/dev/null 2>&1; do sleep 5; done
for role in roles/config.agent roles/owner; do
  gcloud projects add-iam-policy-binding project-id --member serviceAccount:$SA --role $role
done
```

Then deploy the bootstrap configuration. This must be run manually outside CI/CD for the first time. Organization and repository IDs are read as for AWS
```sh
rm -rf providers/gcp/bootstrap/.terraform  # Infrastructure Manager rejects a local .terraform directory
gcloud infra-manager deployments apply \
  projects/project-id/locations/us-central1/deployments/bootstrap \
  --project project-id \
  --service-account projects/project-id/serviceAccounts/$SA \
  --local-source providers/gcp/bootstrap \
  --input-values project=project-id,region=us-east1,org_name=org-name,org_id=org-id,repo_name=repo-name,repo_id=repo-id
```

Once the deployment exists, subsequent runs for bootstrapping can be triggered via Github workflows.

The public Cloud DNS zone for the API domain is created by Terraform. The first workflow run creates the zone and then halts on the certificate precondition, because the name servers are not yet delegated. Read them from the Terraform output and manually add them to the domain registrar, then re-run the workflow
```sh
terraform -chdir=providers/gcp output dns_name_servers
```

Running the workflow requires setting the following configuration variables in the deployment environment, alongside the `GH_TOKEN` secret above
```sh
ENV=prod
gh variable set GCP_PROJECT --env "$ENV" --body project-id
gh variable set GCP_PROJECT_NUMBER --env "$ENV" --body "$(gcloud projects describe project-id --format='value(projectNumber)')"
gh variable set GCP_REGION --env "$ENV" --body us-east1
gh variable set GCP_API_DOMAIN --env "$ENV" --body api.gcp.example.com
gh variable set GCP_ADMIN_EMAIL --env "$ENV" --body admin@example.com
```