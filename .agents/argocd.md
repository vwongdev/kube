# ArgoCD Management

ArgoCD provides GitOps-based continuous delivery for Kubernetes applications in this project.

## Installation

ArgoCD is installed via the `install-argocd.sh` script:
```bash
sh common/install-argocd.sh
```

This creates the `argocd` namespace and installs ArgoCD using the official stable manifests.

## Structure

ArgoCD Applications are defined in the `bootstrap/` directory:

```
bootstrap/
├── base/
│   ├── root.yaml        # Root application (bootstraps core infrastructure)
│   ├── apps.yaml        # ApplicationSet (auto-discovers apps)
│   └── secret.yaml      # Git repository credentials
└── overlays/
    ├── aws-prod/         # Production environment patches
    └── k3d-dev/          # Development environment patches
```

## Application Types

### Root Application (`root.yaml`)
- Bootstraps core infrastructure components
- Points to `core/overlays/{environment}` paths
- Uses automated sync with self-heal and prune

### ApplicationSet (`apps.yaml`)
- Automatically discovers applications from Git repository
- Uses directory-based generator to find `apps/*/overlays/{environment}` paths
- Creates ArgoCD Applications dynamically for each app

### Individual Applications
- `cnpg.yaml` - CloudNativePG operator (Helm chart)
- `load-balancer-controller.yaml` - AWS Load Balancer Controller (Helm chart)
- `external-dns-controller.yaml` - External DNS Controller (Helm chart)

## Configuration

### Sync Policy
Applications use automated sync with:
- `selfHeal: true` - Automatically corrects drift
- `prune: true` - Removes resources deleted from Git
- `CreateNamespace: true` - Creates namespaces if missing

### Repository Access
Git repository credentials are stored in `bootstrap/base/secret.yaml`:
- Uses GitHub token (`$GH_TOKEN`) for private repository access
- Token is injected during deployment via CI/CD

## Environment-Specific Configuration

Overlays customize ArgoCD Applications per environment:
- **aws-prod**: Points to `apps/*/overlays/aws-prod` and `core/overlays/aws-prod`
- **k3d-dev**: Points to `apps/*/overlays/k3d-dev` and `core/overlays/k3d-dev`

## Usage

After ArgoCD is installed and bootstrap applications are applied:
```bash
# Apply bootstrap for specific environment
kubectl apply -k bootstrap/overlays/aws-prod

# ArgoCD will automatically:
# 1. Discover and sync all applications
# 2. Monitor Git repository for changes
# 3. Self-heal any manual changes
```

## Access

ArgoCD UI can be accessed via port-forward:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Default admin password can be retrieved:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

