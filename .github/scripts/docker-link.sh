#!/usr/bin/env bash

export GH_TOKEN="${GH_TOKEN}"

echo "-----------------------------------------------------"
echo "NAME               : ${NAME}"
echo "VERSION            : ${VERSION}"
echo "DOCKER_URL         : ${DOCKER_URL}"
echo "DOCKER_DIGEST      : ${DOCKER_DIGEST}"
echo "GITHUB_EVENT_NAME  : ${GITHUB_EVENT_NAME}"
echo "GITHUB_EVENT_PATH  : ${GITHUB_EVENT_PATH}"  # TODO remove
# PR_NUMBER = ${github.event.number}
echo "GITHUB_EVENT_NUMBER: ${GITHUB_EVENT_NUMBER}"  # TODO replace PR_NUMBER
echo "GITHUB_REPOSITORY  : ${GITHUB_REPOSITORY}"
echo "====================================================="

if [ -n "${DOCKER_DIGEST}" ]; then
  # direct link to the container using the digest
  DOCKER_URL="${DOCKER_URL%%\?*}/${DOCKER_DIGEST}?${DOCKER_URL#*\?}"
fi
echo "${DOCKER_URL}"

if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]]; then
  # Extract PR number from GitHub event payload
  PR_NUMBER=$(jq --raw-output .number "${GITHUB_EVENT_PATH}")  # TODO PR_NUMBER=${GITHUB_EVENT_NUMBER}
  echo "PR_NUMBER : ${PR_NUMBER}"

  gh pr comment ${PR_NUMBER} \
  --repo "${GITHUB_REPOSITORY}" \
  --body "🐳 Container: [${NAME} ${VERSION}](${DOCKER_URL})"
else
  echo "ℹ️ Not a pull request event, skipping comment."
fi

echo "${NAME} ${VERSION} Container : ${DOCKER_URL}" >> $GITHUB_STEP_SUMMARY
