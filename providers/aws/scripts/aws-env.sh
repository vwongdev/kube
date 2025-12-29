#!/bin/bash

export AWS_ACCOUNT=$(aws sts get-caller-identity --query "Account" --output text 2>/dev/null)

export AWS_REGION=$(aws configure get region)
export AWS_REGION=${AWS_REGION:-$AWS_DEFAULT_REGION}
export AWS_REGION=${AWS_REGION:-"us-east-1"} # Global Default

if [ -z "$AWS_ACCOUNT" ]; then
    echo "ERROR: Could not determine AWS Account ID. Are you logged in?"
fi