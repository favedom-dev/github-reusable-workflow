#!/usr/bin/env bash

export GH_TOKEN="${GH_TOKEN}"

echo "-----------------------------------------------------"
echo "NAME             : ${NAME}"
echo "VERSION          : ${VERSION}"
echo "DOCKER_URL       : ${DOCKER_URL}"
echo "GITHUB_EVENT_NAME: ${GITHUB_EVENT_NAME}"
echo "====================================================="

echo "${DOCKER_URL}"
if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]]; then
  # Extract PR number from GitHub event payload
  PR_NUMBER=$(jq --raw-output .number "${GITHUB_EVENT_PATH}")
  echo "PR_NUMBER : ${PR_NUMBER}"

  gh pr comment ${PR_NUMBER} \
  --repo "${GITHUB_REPOSITORY}" \
  --body "🐳 Container: [${NAME} ${VERSION}](${DOCKER_URL})"
else
  echo "ℹ️ Not a pull request event, skipping comment."
fi