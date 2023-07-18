#!/usr/bin/env bash

VERSION="0.0.0-SNAPSHOT-PR-9-9-9"
HELM_DEBUG_FLAG="--debug"

check_rc() {
  if [ "${rc}" -ne 0 ]; then
    echo "ERROR: ${rc}"
    exit ${rc}
  fi
}

HELM_VERSION=$(helm version)

echo "HELM_VERSION: ${HELM_VERSION}"
echo "HELM_DEBUG_FLAG: ${HELM_DEBUG_FLAG}"
# echo "=================================="
# echo "RUN: helm repo list"
# helm repo list
echo "=================================="
echo "RUN: helm dependency update ${HELM_DEBUG_FLAG}"
helm dependency update ${HELM_DEBUG_FLAG}
rc=${?}
check_rc

echo "=================================="
echo "RUN: helm dependency build ${HELM_DEBUG_FLAG}"
helm dependency build ${HELM_DEBUG_FLAG}
rc=${?}
check_rc

echo "=================================="
echo "RUN: helm lint -f ./values.yaml . ${HELM_DEBUG_FLAG}"
helm lint -f ./values.yaml .
rc=${?}
check_rc

echo "=================================="
echo "RUN: helm package . --version ${VERSION} ${HELM_DEBUG_FLAG}"
helm package . --version ${VERSION} ${HELM_DEBUG_FLAG}
rc=${?}
check_rc
