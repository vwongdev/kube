#!/bin/bash
eksctl utils associate-iam-oidc-provider --cluster kube-cluster --region $AWS_REGION --approve

eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster kube-cluster \
  --region $AWS_REGION \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --override-existing-serviceaccounts \
  --approve

ROLE_ARN=$(eksctl get iamserviceaccount --cluster kube-cluster --name ebs-csi-controller-sa --namespace kube-system -o json | jq -r '.[0].status.roleARN')

eksctl create addon \
  --name aws-ebs-csi-driver \
  --cluster kube-cluster \
  --region $AWS_REGION \
  --service-account-role-arn $ROLE_ARN