#!/bin/bash
source "$(dirname "$0")/aws-env.sh"

export $(
    printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
    $(
        aws sts assume-role \
        --role-arn arn:aws:iam::${AWS_ACCOUNT}:role/ClusterAccessRole \
        --role-session-name cluster-session \
        --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
        --output text
    )
)