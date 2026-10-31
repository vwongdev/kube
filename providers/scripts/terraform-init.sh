#!/bin/bash
# Initialises the provider's Terraform working directory against the environment's remote state
set -euo pipefail
source "$(dirname "$0")/config.sh"

case $PROVIDER in
aws)
    terraform -chdir=providers/aws init -reconfigure \
        -backend-config="bucket=tf-state-bucket-$(config account)" \
        -backend-config="key=$ENVIRONMENT/terraform.tfstate" \
        -backend-config="region=$(config region)" \
        -backend-config="dynamodb_table=tf-state-table"
    ;;
gcp)
    terraform -chdir=providers/gcp init -reconfigure \
        -backend-config="bucket=tf-state-bucket-$(config project)" \
        -backend-config="prefix=$ENVIRONMENT"
    ;;
*)
    echo "ERROR: Unsupported provider $PROVIDER" >&2
    exit 1
    ;;
esac
