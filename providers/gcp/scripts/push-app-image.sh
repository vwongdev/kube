#!/bin/bash

IMAGE_URL=$1

gcloud auth configure-docker ${IMAGE_URL%%/*} --quiet
docker push $IMAGE_URL
