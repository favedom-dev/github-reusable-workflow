#!/usr/bin/env bash

echo "-----------------------------------------------------"
echo "NAME             : ${NAME}"
echo "VERSION          : ${VERSION}"
echo "DOCKER_URL       : ${DOCKER_URL}"
echo "GITHUB_EVENT_NAME: ${GITHUB_EVENT_NAME}"
echo "====================================================="

echo "${DOCKER_URL}"
if [ "${GITHUB_EVENT_NAME}" = "pull_request" ]; then
  gh pr comment ${GITHUB_EVENT_NAME} \
  --body "🐳 Container: [${NAME} ${VERSION}](${DOCKER_URL})"
fi