#!/bin/bash
# Prints the name servers of the Terraform-managed DNS zone, to be delegated at the domain registrar
set -euo pipefail
source "$(dirname "$0")/config.sh"

providers/scripts/terraform-init.sh "$TARGET" >/dev/null

case $PROVIDER in
aws)
    terraform -chdir=providers/aws output route53_name_servers
    ;;
gcp)
    terraform -chdir=providers/gcp output dns_name_servers
    ;;
*)
    echo "ERROR: Unsupported provider $PROVIDER" >&2
    exit 1
    ;;
esac
