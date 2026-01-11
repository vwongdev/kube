# Kustomize Structure and Hierarchy

This project uses Kustomize to manage Kubernetes manifests with a three-layer hierarchy:

## Structure

```
<component>/
├── base/              # Base Kubernetes manifests
├── providers/         # Provider-specific configurations (AWS, k3d)
└── overlays/          # Environment-specific overlays (aws-prod, k3d-dev)
```

## Hierarchy

1. **base/** - Contains the core Kubernetes resources (Deployments, Services, Ingress, etc.)
   - Foundation layer with no environment-specific configuration

2. **providers/** - Provider-specific layer that references `base/`
   - Customizes resources for specific infrastructure providers (AWS, k3d)
   - Example: `providers/k3d/` references `../../base`

3. **overlays/** - Environment-specific layer that references `providers/`
   - Applies environment-specific patches, image tags, and configurations
   - Example: `overlays/aws-prod/` references `../../providers/aws` and adds patches

## Usage

Build for a specific environment:
```bash
kustomize build apps/sample-app/overlays/aws-prod
```

