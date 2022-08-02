#!/bin/bash

# GitHub Actions: ${{ github.event.number }}
# export PR_NUM=67GHA
# export APP_NAME=peeq-sms
#
# export SECRET_NAMESPACE=jx-staging
# export SECRETS_STAGING=("rabbitmq" "peeq-users" "peeq-sms-twilio" "jx-staging-peeq-sms-pg")
# ./preview_copy_secrets.sh "${SECRETS_STAGING[@]}"
#
# export SECRET_NAMESPACE=jx
# export SECRETS_JX=("stackhawk-fan" "stackhawk-preview")
# ./preview_copy_secrets.sh "${SECRETS_JX[@]}"

# PREVIEW_NAMESPACE=$(tr '[:upper:]' '[:lower:]' <<< ${APP_NAME}-PR-${PR_NUM})

echo "PREVIEW_NAMESPACE: ${PREVIEW_NAMESPACE}"

check_vars() {
    var_names=("$@")
    for var_name in "${var_names[@]}"; do
        [ -z "${!var_name}" ] && echo "$var_name is unset." && var_unset=true
    done
    [ -n "$var_unset" ] && exit 1
    return 0
}

function copy-secret() {
    check_vars \
    SECRET_NAMESPACE
    # APP_NAME \
    # PR_NUM \


    local arraySecrets=("$@")
    if [ ${#arraySecrets[@]} -lt 1 ] ; then
      echo "Array length: ${#arraySecrets[@]}"
      echo "Secret array invalid"
      exit 1
    fi

    for i in "${arraySecrets[@]}"; do
        echo ""
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        echo "Copy secret..."
        echo "PREVIEW_NAMESPACE : ${PREVIEW_NAMESPACE}"
        echo "SECRET_NAMESPACE  : ${SECRET_NAMESPACE}"
        echo "SECRET            : ${i}"
        echo "---------------------------------------------"
        kubectl delete secret --namespace=${PREVIEW_NAMESPACE} ${i} --ignore-not-found
        kubectl get secret ${i} --namespace=${SECRET_NAMESPACE} -o yaml | sed 's/namespace: '${SECRET_NAMESPACE}'/namespace: '${PREVIEW_NAMESPACE}'/g' | kubectl create --namespace=${PREVIEW_NAMESPACE} -f -
        echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    done
}

## MAIN
copy-secret "$@"