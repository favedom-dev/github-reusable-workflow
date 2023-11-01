#!/bin/bash

# invoke function using:
# bash setup_gcp_wif.sh functionName
# See https://github.com/google-github-actions/auth#setting-up-workload-identity-federation

# 1. Google Cloud project
export PROJECT_ID="favedom-dev"
export SERVICE_ACCOUNT_ID="github-actions-core"
export SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"
export WORKLOAD_IDENTITY_POOL="ci-cd"
# export WORKLOAD_IDENTITY_POOL_ID set BELOW in function get_workload_identity_pool()
export CONTAINER_BUCKET="artifacts.favedom-dev.appspot.com"
export GH_ORG="favedom-dev"
export REPO="${GH_ORG}/peeq-tracking-db"

display_standard_vars() {
  echo ""
  echo "========================================================="
  echo "PROJECT_ID               : ${PROJECT_ID}"
  echo "SERVICE_ACCOUNT_ID       : ${SERVICE_ACCOUNT_ID}"
  echo "SERVICE_ACCOUNT_EMAIL    : ${SERVICE_ACCOUNT_EMAIL}"
  echo "WORKLOAD_IDENTITY_POOL   : ${WORKLOAD_IDENTITY_POOL}"
  echo "CONTAINER_BUCKET         : ${CONTAINER_BUCKET}"
  echo "GH_ORG                   : ${GH_ORG}"
  echo "REPO                     : ${REPO}"
  echo "========================================================="
}

# 2. Optional) Create a Google Cloud Service Account. If you already have a Service Account, take note of the email address and skip this step
init_service_account() {
  gcloud iam service-accounts create ${SERVICE_ACCOUNT_ID} \
  --project="${PROJECT_ID}" \
  --display-name="${SERVICE_ACCOUNT_ID}" \
  --description="core github action service account using workload identity federation"
}

# id: github-actions-core
# email: github-actions-core@favedom-dev.iam.gserviceaccount.com

list_service_accounts() {
  gcloud iam service-accounts list
}

# delete_custom_role
# init_custom_cloud_run_role() {
#   gcloud iam roles create run.writer \
#   --project="${PROJECT_ID}" \
#   --file="custom-roles/cloud-run-writer.yaml"
# }

set_service_account_roles() {
  gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/artifactregistry.writer"

# REMOVE no longer needed - remove_roles
#   gcloud projects add-iam-policy-binding ${PROJECT_ID} \
#   --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
#   --role="roles/run.invoker"

# DELETE no longer needed - delete_custom_role
#   gcloud projects add-iam-policy-binding ${PROJECT_ID} \
#   --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
#   --role="projects/${PROJECT_ID}/roles/run.writer"
}

# https://cloud.google.com/storage/docs/access-control/iam-roles
set_service_account_roles_storage() {
  gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/storage.objectAdmin"
}

# https://cloud.google.com/compute/docs/access/iam
set_service_account_roles_compute() {
  gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/compute.viewer"
}

# https://cloud.google.com/secret-manager/docs/access-control
set_service_account_roles_secret_accessor() {
  echo "PROJECT_ID           : ${PROJECT_ID}"
  echo "SERVICE_ACCOUNT_EMAIL: ${SERVICE_ACCOUNT_EMAIL}"
  gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/secretmanager.secretAccessor"
}

remove_roles() {
    gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/run.invoker"

    gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="projects/${PROJECT_ID}/roles/run.writer"
}

delete_custom_role() {
    gcloud iam roles delete run.writer --project=${PROJECT_ID}
}

add_role_admin() {
  gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/run.admin"
}

add_role_serviceAccountUser() {
  gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/iam.serviceAccountUser"
}


add_principal_to_bucket() {
  gsutil iam ch \
  serviceAccount:${SERVICE_ACCOUNT_EMAIL}:roles/storage.admin gs://${CONTAINER_BUCKET}
}

view_bucket_policy() {
  gsutil iam get gs://${CONTAINER_BUCKET}
}


get_service_account_roles() {
  gcloud projects get-iam-policy ${PROJECT_ID}  \
  --flatten="bindings[].members" \
  --format="table(bindings.role)" \
  --filter="bindings.members:${SERVICE_ACCOUNT_EMAIL}"
}

# 4. Enable the IAM Credentials API
enable_iam_credentials_api() {
  gcloud services enable iamcredentials.googleapis.com \
  --project="${PROJECT_ID}"
}

# 5. Create a Workload Identity Pool
init_workload_identity_pool() {
  gcloud iam workload-identity-pools create "${WORKLOAD_IDENTITY_POOL}" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --display-name="${WORKLOAD_IDENTITY_POOL}" \
  --description="identity pool for ${WORKLOAD_IDENTITY_POOL}"
}

# RUN THIS
# 6. Get the full ID of the Workload Identity Pool
get_workload_identity_pool() {
  export WORKLOAD_IDENTITY_POOL_ID=$( \
  gcloud iam workload-identity-pools describe "${WORKLOAD_IDENTITY_POOL}" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --format="value(name)")
  echo "WORKLOAD_IDENTITY_POOL_ID: ${WORKLOAD_IDENTITY_POOL_ID}"
}

# 7. Create a Workload Identity Provider in that pool
init_workload_identity_provider() {
  gcloud iam workload-identity-pools providers create-oidc "github" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="${WORKLOAD_IDENTITY_POOL}" \
  --display-name="github" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com"
}

# 8. Allow authentications from the Workload Identity Provider originating from your repository to impersonate the Service Account created above
set_workload_identity_provider_service_account_access() {
#   get_workload_identity_pool
  echo "WORKLOAD_IDENTITY_POOL_ID: ${WORKLOAD_IDENTITY_POOL_ID}"
  gcloud iam service-accounts add-iam-policy-binding "${SERVICE_ACCOUNT_EMAIL}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${REPO}"
#   --member="principalSet://iam.googleapis.com/projects/863599699918/locations/global/workloadIdentityPools/${WORKLOAD_IDENTITY_POOL}/attribute.repository/${REPO}"
}

# 9. Extract the Workload Identity Provider resource name
get_workload_identity_provider() {
  display_standard_vars
  echo ""
  echo "Use this value as the workload_identity_provider value in your GitHub Actions YAML:"
  echo "Set as GitHub Organization secret WIF_PROVIDER -- https://github.com/organizations/${GH_ORG}/settings/secrets/actions"
  gcloud iam workload-identity-pools providers describe "github" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="${WORKLOAD_IDENTITY_POOL}" \
  --format="value(name)"
}

full_flow() {
    # 1
    display_standard_vars

    # 2
    # only run if need an account
    # init_service_account

    list_service_accounts

    # 3
    init_custom_cloud_run_role
    set_service_account_roles
    get_service_account_roles

    # 4
    enable_iam_credentials_api

    # 5
    init_workload_identity_pool


    # RUN THIS
    # 6
    get_workload_identity_pool

    # 7
    init_workload_identity_provider

    # 8
    set_workload_identity_provider_service_account_access

    # 9
    get_workload_identity_provider
}

setup_repo() {
  display_standard_vars
  get_workload_identity_pool
  set_workload_identity_provider_service_account_access
}

## MAIN
"$@"