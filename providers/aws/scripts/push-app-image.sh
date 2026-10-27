#!/bin/bash
source "$(dirname "$0")/aws-env.sh"

REPOSITORY_URL=$1

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${REPOSITORY_URL%%/*}
docker push $REPOSITORY_URL