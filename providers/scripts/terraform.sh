#!/bin/bash
# Runs a Terraform command that takes variables, e.g. plan or apply, with the environment's values from providers/config.yaml
set -euo pipefail
source "$(dirname "$0")/config.sh"
COMMAND=${2:?Usage: $0 <provider>.<environment> <command> [terraform arguments]}
shift 2

case $PROVIDER in
aws)
    terraform -chdir=providers/aws "$COMMAND" \
        -var="region=$(config region)" \
        -var="domain=$(config domain)" \
        -var="cluster_name=$(config cluster_name)" \
        -var="repository_name=$(config repository_name)" \
        "$@"
    ;;
gcp)
    terraform -chdir=providers/gcp "$COMMAND" \
        -var="project=$(config project)" \
        -var="region=$(config region)" \
        -var="zone=$(config zone)" \
        -var="domain=$(config domain)" \
        -var="cluster_name=$(config cluster_name)" \
        -var="repository_name=$(config repository_name)" \
        -var="admin_email=${GCP_ADMIN_EMAIL:?GCP_ADMIN_EMAIL must be set}" \
        "$@"
    ;;
*)
    echo "ERROR: Unsupported provider $PROVIDER" >&2
    exit 1
    ;;
esac
