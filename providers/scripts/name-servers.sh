#!/bin/bash
# Prints the name servers of the Terraform-managed DNS zone, to be delegated at the domain registrar
set -euo pipefail
source "$(dirname "$0")/config.sh"

case $PROVIDER in
aws)
    terraform -chdir=providers/aws init -reconfigure \
        -backend-config="bucket=tf-state-bucket-$(config account)" \
        -backend-config="key=$ENVIRONMENT/terraform.tfstate" \
        -backend-config="region=$(config region)" \
        -backend-config="dynamodb_table=tf-state-table" >/dev/null
    terraform -chdir=providers/aws output route53_name_servers
    ;;
gcp)
    terraform -chdir=providers/gcp init -reconfigure \
        -backend-config="bucket=tf-state-bucket-$(config project)" \
        -backend-config="prefix=$ENVIRONMENT" >/dev/null
    terraform -chdir=providers/gcp output dns_name_servers
    ;;
*)
    echo "ERROR: Unsupported provider $PROVIDER" >&2
    exit 1
    ;;
esac
