#!/usr/bin/env bash

echo "-----------------------------------------------------"
echo "DOCKER_NAME      : ${DOCKER_NAME}"
echo "DOCKER_PUSH      : ${DOCKER_PUSH}"
echo "DOCKER_PUSH_PR   : ${DOCKER_PUSH_PR}"
echo "DOCKER_REGISTRY  : ${DOCKER_REGISTRY}"
echo "GAR_LOCATION     : ${GAR_LOCATION}"
echo "GITHUB_EVENT_NAME: ${GITHUB_EVENT_NAME}"
echo "NAME             : ${NAME}"
echo "PROJECT_ID       : ${PROJECT_ID}"
echo "====================================================="


if [ -n "${DOCKER_NAME}" ]; then
  D_NAME=${DOCKER_NAME}
else
  D_NAME=${NAME}
fi
echo "D_NAME : ${D_NAME}"
DOCKER_LOCATION=${GAR_LOCATION}-docker.pkg.dev/${PROJECT_ID}/${DOCKER_REGISTRY}/${D_NAME}
# DOCKER_LOCATION=${GAR_LOCATION}-docker.pkg.dev/${PROJECT_ID}/${DOCKER_REGISTRY}/${NAME}
echo "DOCKER_LOCATION : ${DOCKER_LOCATION}"
echo "DOCKER_LOCATION=${DOCKER_LOCATION}" >> $GITHUB_ENV
echo "DOCKER_LOCATION=${DOCKER_LOCATION}" >> $GITHUB_OUTPUT

DOCKER_URL="https://console.cloud.google.com/artifacts/docker/${PROJECT_ID}/${GAR_LOCATION}/${DOCKER_REGISTRY}/${NAME}?project=${PROJECT_ID}/"
echo "DOCKER_URL : ${DOCKER_URL}"
echo "DOCKER_URL=${DOCKER_URL}" >> $GITHUB_ENV
echo "DOCKER_URL=${DOCKER_URL}" >> $GITHUB_OUTPUT

DOCKER_PUSH="${DOCKER_PUSH}"
if [ "${GITHUB_EVENT_NAME}" = "pull_request" ] && [ -n "${DOCKER_PUSH_PR}" ]; then
  DOCKER_PUSH="${DOCKER_PUSH_PR}"
fi
echo "DOCKER_PUSH : ${DOCKER_PUSH}"
echo "DOCKER_PUSH=${DOCKER_PUSH}" >> $GITHUB_ENV
echo "DOCKER_PUSH=${DOCKER_PUSH}" >> $GITHUB_OUTPUT
