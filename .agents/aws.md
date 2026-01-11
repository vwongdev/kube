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

**Note:** Bootstrap must be run manually outside CI/CD for the first time.

## Backend

Terraform state is stored in S3 with DynamoDB for locking:
```hcl
backend "s3" {}
```

Configure backend via environment variables or `terraform init -backend-config`.

## Scripts

- `assume-cluster-access-role.sh` - Assumes ClusterAccessRole for EKS access
- `aws-env.sh` - Sets up AWS environment variables
- `push-app-image.sh` - Pushes container images to ECR

## Usage

```bash
# Initialize Terraform
terraform init

# Plan changes
terraform plan -var="region=us-east-1" -var="domain=example.com"

# Apply changes
terraform apply -var="region=us-east-1" -var="domain=example.com"
```

