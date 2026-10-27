# Google Cloud Terraform Management

This project uses Terraform to manage Google Cloud infrastructure with a modular architecture mirroring the AWS provider.

## Structure

```
providers/gcp/
├── main.tf              # Root module orchestrating all resources
├── variables.tf         # Input variables (project, region, domain, admin email)
├── outputs.tf           # Output values
├── bootstrap/           # Terraform for initial setup, deployed via Infrastructure Manager
├── env/                 # Per-environment variables (cluster and repository names)
└── modules/
    ├── vpc/              # VPC network, subnet with pod/service ranges, Cloud NAT
    ├── gke/              # GKE Standard cluster, node pool, IAM access
    ├── artifact_registry/# Container registry with cleanup policies
    └── dns/              # Cloud DNS zone and Google-managed SSL certificate
```

## Bootstrap

Before using Terraform, deploy `bootstrap/` via Infrastructure Manager (Google's managed Terraform service, the CloudFormation equivalent) to create:
- Enabled project APIs
- GCS bucket for Terraform state (versioned; GCS provides native locking)
- Workload Identity pool and GitHub OIDC provider
- `primary-pipeline` service account impersonated by GitHub workflows

**Note:** The `infra-manager` service account and the first deployment must be created manually outside CI/CD (see README). The workflow re-applies the deployment on each run.

## Differences from AWS

- No storage driver or Load Balancer Controller: GKE ships the Persistent Disk CSI driver and the `gce` Ingress controller
- Workload Identity Federation for GKE replaces Pod Identity: IAM bindings target the Kubernetes service account principal directly
- Ingress references the Terraform-managed certificate via the `ingress.gcp.kubernetes.io/pre-shared-cert` annotation

## Scripts

- `push-app-image.sh` - Pushes container images to Artifact Registry

## Usage

```bash
terraform init -backend-config="bucket=tf-state-bucket-<project>" -backend-config="prefix=prod"

terraform apply -var-file="env/prod.tfvars" -var="project=<project>" -var="region=us-east1" \
  -var="domain=api.gcp.example.com" -var="admin_email=admin@example.com"
```
