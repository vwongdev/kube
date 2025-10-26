# Multicloud Kubernetes Provisioning
This repository contains IaC and scripts to provision a Kubernetes cluster across multiple cloud providers.

## k3d (Local / Self-Hosted)
### Prerequisites
All dependencies can be installed via a Makefile task
```sh
make -f k3d/Makefile mac-deps
```

### Usage
Create k3d cluster:
```sh
make -f k3d/Makefile k3d-create CLUSTER_NAME=cluster-name
```

Initialize local development environment:
```sh
make -f k3d/Makefile skaffold-init
```

Start local development environment:
```sh
make -f k3d/Makefile skaffold-dev
```

## Amazon Web Services
### Prerequisites
A new AWS account can be bootstrapped for Terraform management. This must be run manually outside CI/CD for the first time
```sh 
aws cloudformation deploy --stack-name bootstrap --template-file aws/bootstrap.yaml --parameter-overrides OrgName=org-name RepoName=repo-name ApiBaseDomain=api.example.com --capabilities CAPABILITY_NAMED_IAM
```

This will also create a public Route 53 zone with associated namespace servers on the specified domain. These namespace servers must be manually added to the namespace registrar
```sh
aws cloudformation describe-stacks --stack-name bootstrap
```

After manually adding the namespace servers to the namespace registrar, subsequent runs for bootstrapping can be triggered via Github workflows. This requires setting the following environment configuration variables in the repository settings
```
AWS_ACCOUNT=123456789012
AWS_REGION=us-east-1
```