#!/bin/bash
# Bootstraps an account or project for Terraform management. Workflows re-apply it after the first manual run.
set -euo pipefail
source "$(dirname "$0")/config.sh"

read -r ORG_NAME ORG_ID REPO_NAME REPO_ID < <(
    gh api 'repos/{owner}/{repo}' --jq '"\(.owner.login) \(.owner.id) \(.name) \(.id)"'
)

case $PROVIDER in
aws)
    ACCOUNT=$(config account)
    if [ "$(aws sts get-caller-identity --query Account --output text)" != "$ACCOUNT" ]; then
        echo "ERROR: AWS credentials are not for account $ACCOUNT" >&2
        exit 1
    fi

    aws cloudformation deploy \
        --region "$(config region)" \
        --stack-name bootstrap \
        --template-file providers/aws/bootstrap.yaml \
        --parameter-overrides OrgName="$ORG_NAME" OrgId="$ORG_ID" RepoName="$REPO_NAME" RepoId="$REPO_ID" \
        --capabilities CAPABILITY_NAMED_IAM
    ;;
gcp)
    PROJECT=$(config project)
    SA=infra-manager@$PROJECT.iam.gserviceaccount.com

    gcloud services enable config.googleapis.com --project "$PROJECT"
    if ! gcloud iam service-accounts describe "$SA" --project "$PROJECT" >/dev/null 2>&1; then
        gcloud iam service-accounts create infra-manager --project "$PROJECT"
        until gcloud iam service-accounts describe "$SA" --project "$PROJECT" >/dev/null 2>&1; do sleep 5; done
    fi
    for role in roles/config.agent roles/owner; do
        gcloud projects add-iam-policy-binding "$PROJECT" --member "serviceAccount:$SA" --role "$role"
    done

    rm -rf providers/gcp/bootstrap/.terraform # Infrastructure Manager rejects a local .terraform directory
    # The deployment location only holds Infrastructure Manager metadata; resources use the input region
    gcloud infra-manager deployments apply \
        "projects/$PROJECT/locations/us-central1/deployments/bootstrap" \
        --project "$PROJECT" \
        --service-account "projects/$PROJECT/serviceAccounts/$SA" \
        --local-source providers/gcp/bootstrap \
        --input-values "project=$PROJECT,region=$(config region),org_name=$ORG_NAME,org_id=$ORG_ID,repo_name=$REPO_NAME,repo_id=$REPO_ID"
    ;;
*)
    echo "ERROR: Unsupported provider $PROVIDER" >&2
    exit 1
    ;;
esac
