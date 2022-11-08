#!/bin/bash

# VARIABLES NEEDED FOR SCRIPT TO WORK
# GITHUB_SHA=$(git rev-parse --short HEAD)
# SEARCH_FOR="src/main/java/com/bot/utils/CommonUtils.java"

# COMMIT_CHANGES=$(git diff-tree --no-commit-id --name-only -r ${GITHUB_SHA})
COMMIT_CHANGES_COUNT=$(git whatchanged -1 --format=oneline | tail -n +2 | wc -l)
IS_NORMAL_PIPELINE='true'

if [ ${COMMIT_CHANGES_COUNT} -eq 1 ]; then
  git diff-tree --no-commit-id --name-only -r ${GITHUB_SHA} | grep '^'${SEARCH_FOR}'$'
  rc=$?
  if [ ${rc} -eq 0 ]; then
    IS_NORMAL_PIPELINE='false'
  fi
fi

echo ${IS_NORMAL_PIPELINE}
echo "::set-output name=IS_NORMAL_PIPELINE::${IS_NORMAL_PIPELINE}"