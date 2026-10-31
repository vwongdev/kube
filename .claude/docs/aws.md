# AWS Terraform Management

This project uses Terraform to manage AWS infrastructure with a modular architecture.

## Structure

```
providers/aws/
├── main.tf              # Root module orchestrating all resources
├── variables.tf          # Input variables (region, domain)
├── outputs.tf            # Output values
├── bootstrap.yaml        # CloudFormation template for initial setup
└── modules/              # Reusable infrastructure modules
    ├── vpc/              # VPC, subnets, NAT gateway, routing
    ├── eks/              # EKS cluster, node groups, access control
    ├── ecr/              # Container registry with lifecycle policies
    └── route53/          # DNS hosted zone and ACM certificate
```

## Modules

1. **VPC** - Creates VPC with public/private subnets, NAT gateway, and routing
2. **EKS** - Provisions EKS cluster with node groups, IAM roles, and access entries
3. **ECR** - Sets up container registry with image scanning and lifecycle policies
4. **Route53** - Manages DNS hosted zone and SSL certificate validation

## Bootstrap

Before using Terraform, run `bootstrap.yaml` via CloudFormation to create:
- S3 bucket for Terraform state (with encryption and versioning)
- DynamoDB table for state locking
- GitHub OIDC provider and CI/CD role
- Route53 hosted zone and ACM certificate

**Note:** Bootstrap must be run manually outside CI/CD for the first time with `providers/scripts/bootstrap.sh aws.<environment>`.

## Backend

Terraform state is stored in S3 with DynamoDB for locking:
```hcl
backend "s3" {}
```

Configure backend via environment variables or `terraform init -backend-config`.

## Scripts

Shared scripts in `providers/scripts/` take a `<provider>.<environment>` argument (e.g. `aws.prod`) and read its entry from `providers/config.yaml`:
- `bootstrap.sh` - Runs the first-time bootstrap outside CI/CD
- `name-servers.sh` - Prints the DNS zone name servers to delegate at the registrar
- `set-github-env.sh` - Prompts for the GitHub environment secrets and variables kept out of the repository

Provider scripts in `providers/aws/scripts/`:
- `assume-cluster-access-role.sh` - Assumes a cluster's access role for EKS access (cluster name argument, default `kube-cluster`)
- `aws-env.sh` - Sets up AWS environment variables
- `push-app-image.sh` - Pushes container images to ECR

## Configuration

The workflow reads per-environment values (account/project, region, domain, cluster and repository names) from `providers/config.yaml` under `aws.<environment>` and passes them to Terraform as `-var` flags.

## Usage

```bash
# Initialize Terraform
terraform init

# Plan changes
terraform plan -var="region=us-east-1" -var="domain=example.com" -var="cluster_name=kube-cluster" -var="repository_name=kube"

# Apply changes
terraform apply -var="region=us-east-1" -var="domain=example.com" -var="cluster_name=kube-cluster" -var="repository_name=kube"
```
