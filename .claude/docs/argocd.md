# ArgoCD Management

ArgoCD provides GitOps-based continuous delivery for Kubernetes applications in this project.

## Installation

ArgoCD is installed via the `install-argocd.sh` script:
```bash
sh bootstrap/install-argocd.sh
```

This creates the `argocd` namespace and installs ArgoCD using the official stable manifests.

## Structure

ArgoCD Applications are defined in the `bootstrap/` directory:

```
bootstrap/
├── install-argocd.sh    # ArgoCD installer
├── base/
│   ├── root.yaml        # Root application (bootstraps core infrastructure)
│   ├── apps.yaml        # ApplicationSet (auto-discovers the sample app only)
│   ├── apps-repository.yaml # ApplicationSet (auto-discovers apps in vwongdev/apps)
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
- Skips dry run for resources whose CRDs are not yet installed (`SkipDryRunOnMissingResource=true`) and retries indefinitely with backoff from 30s up to 5m, so the sync converges once the CRDs exist
- Resources that need CRDs installed by another Application (e.g. Gateway API resources) go in sync wave 1 (`argocd.argoproj.io/sync-wave: "1"`), after the Applications in wave 0

### ApplicationSet (`apps.yaml`)
- Auto-discovers the sample app in this repository's `apps/` only; add new apps to the dedicated manifests repository instead
- Uses directory-based generator to find `apps/*/overlays/{environment}` paths
- Creates ArgoCD Applications dynamically for each app

### ApplicationSet (`apps-repository.yaml`)
- Same as `apps.yaml`, but discovers apps from the dedicated manifests repository [vwongdev/apps](https://github.com/vwongdev/apps)
- Generated Application names must not clash with apps in this repository's `apps/`

### Individual Applications
- `cnpg.yaml` - CloudNativePG operator (Helm chart)
- `external-secrets.yaml` - External Secrets Operator (Helm chart); each provider adds the ClusterSecretStore `secrets` in sync wave 1, except k3d, whose store is applied locally outside ArgoCD
- `load-balancer-controller.yaml` - AWS Load Balancer Controller (Helm chart)
- `external-dns-controller.yaml` - External DNS Controller (Helm chart)
- `gateway-api-crds.yaml` - Gateway API standard CRDs on AWS (`prune: false` so CRDs are never deleted)
- `envoy-gateway.yaml` - Envoy Gateway on k3d (Helm chart, also installs the Gateway API CRDs)

## Configuration

### Sync Policy
Applications use automated sync with:
- `selfHeal: true` - Automatically corrects drift
- `prune: true` - Removes resources deleted from Git
- `CreateNamespace: true` - Creates namespaces if missing

### Repository Access
Git repository credentials are stored in `bootstrap/base/secret.yaml`:
- Credential template (`repo-creds`) matching every repository under `https://github.com/vwongdev`
- Uses GitHub token (`$GH_TOKEN`) with read access to the organisation's repositories
- Token is injected during deployment via CI/CD

## Environment-Specific Configuration

Overlays customize ArgoCD Applications per environment:
- **aws-prod**: Points to `apps/*/overlays/aws-prod` and `core/overlays/aws-prod`
- **gcp-prod**: Points to `apps/*/overlays/gcp-prod` and `core/overlays/gcp-prod`
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
