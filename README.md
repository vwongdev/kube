# Multicloud Kubernetes Provisioning
This repository contains IaC and scripts to provision a Kubernetes cluster across multiple cloud providers.

## k3d (Local / Self-Hosted)
### Prerequisites
All dependencies can be installed via a Makefile task
```sh
make -f providers/k3d/Makefile mac-deps
```

### Usage
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

## Amazon Web Services
### Prerequisites
A new AWS account can be bootstrapped for Terraform management. This must be run manually outside CI/CD for the first time
```sh 
aws cloudformation deploy --stack-name bootstrap --template-file providers/aws/bootstrap.yaml --parameter-overrides OrgName=org-name RepoName=repo-name --capabilities CAPABILITY_NAMED_IAM
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