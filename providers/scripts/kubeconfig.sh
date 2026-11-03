#!/bin/bash
# Adds the environment's cluster to the local kubeconfig using the current provider credentials
set -euo pipefail
source "$(dirname "$0")/config.sh"

case $PROVIDER in
aws)
    aws eks update-kubeconfig \
        --name "$(config cluster_name)" \
        --region "$(config region)"
    ;;
gcp)
    gcloud container clusters get-credentials "$(config cluster_name)" \
        --project "$(config project)" \
        --location "$(config zone)"
    ;;
*)
    echo "ERROR: Unsupported provider $PROVIDER" >&2
    exit 1
    ;;
esac
