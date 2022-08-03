#!/bin/bash

export PREVIEW_NAMESPACE=$1

export SECRET_NAMESPACE=jx-staging
export SECRETS_STAGING=("rabbitmq")
./preview_copy_secrets.sh "${SECRETS_STAGING[@]}"

export SECRET_NAMESPACE=jx
export SECRETS_JX=("stackhawk-fan" "stackhawk-preview")
./preview_copy_secrets.sh "${SECRETS_JX[@]}"