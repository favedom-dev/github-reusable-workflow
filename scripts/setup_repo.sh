#!/usr/bin/env bash

REPO_NAME=$(basename `git rev-parse --show-toplevel`)
echo "REPO_NAME: ${REPO_NAME}"

export PROJECT_ID="favedom-dev"
export SERVICE_ACCOUNT_ID="github-actions-core"
export SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"
export WORKLOAD_IDENTITY_POOL="ci-cd"
export GH_ORG="favedom-dev"
export REPO="${GH_ORG}/${REPO_NAME}"

get_workload_identity_pool() {
  export WORKLOAD_IDENTITY_POOL_ID=$( \
  gcloud iam workload-identity-pools describe "${WORKLOAD_IDENTITY_POOL}" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --format="value(name)")
  echo "WORKLOAD_IDENTITY_POOL_ID: ${WORKLOAD_IDENTITY_POOL_ID}"
}

set_workload_identity_provider_service_account_access() {
#   get_workload_identity_pool
  echo "WORKLOAD_IDENTITY_POOL_ID: ${WORKLOAD_IDENTITY_POOL_ID}"
  gcloud iam service-accounts add-iam-policy-binding "${SERVICE_ACCOUNT_EMAIL}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${REPO}"
}

cleanup() {
  rm $0
}

## MAIN
get_workload_identity_pool
set_workload_identity_provider_service_account_access
cleanup
