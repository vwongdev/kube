#!/bin/bash
# Prompts for the secrets and variables a provider workflow needs that are kept out of the repository
set -euo pipefail
source "$(dirname "$0")/config.sh"

case $PROVIDER in
aws) ;;
gcp)
    gh variable set GCP_ADMIN_EMAIL --env "$ENVIRONMENT"
    ;;
*)
    echo "ERROR: Unsupported provider $PROVIDER" >&2
    exit 1
    ;;
esac

# Personal access token with read access to the repository contents, used by ArgoCD to read the manifests
gh secret set GH_TOKEN --env "$ENVIRONMENT"
