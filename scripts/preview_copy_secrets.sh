#!/bin/bash

# Format for contents of file SECRET_FILENAME is:
#    namespace + ":" + secret names "," separated
# Examples:
# namespace1:secretA,secretB namespace2:secretX,secretY,secretZ
# jx-staging:rabbitmq jx:stackhawk-fan,stackhawk-preview
DEFAULT_SECRET_FILENAME="./preview_secrets.txt"
# 1st arg can override the SECRET_FILENAM name
SECRET_FILENAME="${1:-$DEFAULT_SECRET_FILENAME}"

# check that PREVIEW_NAMESPACE is set
if [ -z ${PREVIEW_NAMESPACE} ]; then
  echo "ERROR: \"PREVIEW_NAMESPACE\" is not set.  Should be done in the GitHub workflow"
  echo "   export PREVIEW_NAMESPACE=++PREVIEW_NAMESPACE++"
  exit 1
fi

# check that file exists
if [ ! -f "$SECRET_FILENAME" ]; then
  echo "WARNING: \"${SECRET_FILENAME}\" does not exists in: $(pwd)"
  exit 0
fi

# check that preview namespace exists
if [[ $(kubectl get ns | awk '{print $1}' | grep ^${PREVIEW_NAMESPACE}$) != ${PREVIEW_NAMESPACE} ]]; then
  echo "ERROR: namespace \"${PREVIEW_NAMESPACE}\" does not exist"
  exit 1
fi

echo "-----------------:-----------------"
echo "PREVIEW_NAMESPACE: ${PREVIEW_NAMESPACE}"
echo "SECRET_FILENAME  : ${SECRET_FILENAME}"
echo "-----------------:-----------------"

NAMESPACE_SECRETS=$(<"${SECRET_FILENAME}")

for secret_namespace in ${NAMESPACE_SECRETS[@]}; do
  # clean array
  unset secretList
  # get secret_namespace
  if [[ ${NAMESPACE_SECRETS} == *":"* ]]; then
    # split namespace name from sub-list secrets
    tmpNamespaceArray=(${secret_namespace//:/ })
    secret_namespace=${tmpNamespaceArray[0]}
    secretList=${tmpNamespaceArray[1]}
    # make array from simple string
    secretList=(${secretList//,/ })
  fi

  echo ""
  echo "======:==================:================"
  echo "START : secret namespace : ${secret_namespace}"
  echo "======:==================:================"

  # get secrets
  for secret in ${secretList[@]}; do
    # copy secret
    echo ""
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo "Copy secret..."
    echo "Preview Namespace : ${PREVIEW_NAMESPACE}"
    echo "Secret Namespace  : ${secret_namespace}"
    echo "Secret            : ${secret}"
    echo "---------------------------------------------"
    kubectl delete secret --namespace=${PREVIEW_NAMESPACE} ${secret} --ignore-not-found
    # kubectl get secret ${secret} --namespace=${secret_namespace} -o yaml | sed 's/namespace: '${secret_namespace}'/namespace: '${PREVIEW_NAMESPACE}'/g' | kubectl create --namespace=${PREVIEW_NAMESPACE} -f -
    kubectl get secret ${secret} --namespace=${secret_namespace} -o yaml | \
    sed 's/namespace: '${secret_namespace}'/namespace: '${PREVIEW_NAMESPACE}'/g' | \
    sed 's/app.kubernetes.io\/instance: .*/app: '${PREVIEW_NAMESPACE}'/g' | \
    kubectl create --namespace=${PREVIEW_NAMESPACE} -f -
    echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
  done

done
