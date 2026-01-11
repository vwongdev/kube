# k3d Management

k3d provides a local Kubernetes development environment using Docker containers.

## Structure

```
providers/k3d/
└── Makefile            # Cluster lifecycle and development commands
```

## Cluster Configuration

k3d clusters are created with:
- 1 server node
- Configurable agent nodes (default: 1)
- Port forwarding: `8081:80@loadbalancer` for ingress traffic
- Cluster name stored in `.cluster_created` file

## Makefile Targets

### Cluster Management
- `k3d-create` - Creates a new k3d cluster (default goal)
- `k3d-destroy` - Deletes the cluster and removes `.cluster_created`

### Dependencies
- `mac-deps` - Installs required tools via Homebrew (docker, kubernetes-cli, skaffold, k3d)

### Development
- `skaffold-init` - Initializes Skaffold configuration
- `skaffold-dev` - Runs Skaffold in development mode (build, deploy, watch)

## Usage

```bash
# Install dependencies (macOS)
make -f providers/k3d/Makefile mac-deps

# Create cluster with custom name
make -f providers/k3d/Makefile k3d-create CLUSTER_NAME=my-cluster AGENTS=2

# Destroy cluster
make -f providers/k3d/Makefile k3d-destroy

# Start development workflow
make -f providers/k3d/Makefile skaffold-dev
```

## Variables

- `CLUSTER_NAME` - Name of the k3d cluster (default: `default`)
- `AGENTS` - Number of agent nodes (default: `1`)
- `USER_WORKING_DIR` - Working directory (default: `.`)

## Integration

k3d integrates with the Kustomize structure:
- `providers/k3d/` - Provider-specific kustomizations
- `overlays/k3d-dev/` - Development environment overlays

Access applications via `http://localhost:8081` when using the default port mapping.

