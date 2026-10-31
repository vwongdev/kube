#!/bin/bash
# Sourced by the other scripts to load a <provider>.<environment> entry, e.g. aws.prod, from providers/config.yaml

TARGET=${1:?Usage: $0 <provider>.<environment>}
PROVIDER=${TARGET%%.*}
ENVIRONMENT=${TARGET#*.}

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

if ! yq -e ".$TARGET" providers/config.yaml >/dev/null 2>&1; then
    echo "ERROR: $TARGET not found in providers/config.yaml" >&2
    exit 1
fi

config() {
    yq -e ".$TARGET.$1" providers/config.yaml
}
