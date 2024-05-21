#!/usr/bin/env bash

BRANCH_NAME="tmp-fanfuze"
TAG_NAME="v2"

# Get the latest commit on the specified branch
LATEST_COMMIT=$(git rev-parse origin/${BRANCH_NAME})

echo "--------------:--------------"
echo "TAG_NAME      : ${TAG_NAME}"
echo "BRANCH_NAME   : ${BRANCH_NAME}"
echo "LATEST_COMMIT : ${LATEST_COMMIT}"
echo "==============:=============="

# Check if the tag exists
if git rev-parse "${TAG_NAME}" >/dev/null 2>&1; then
  # Update the tag to the latest commit
  git tag -d "${TAG_NAME}"
  git push origin ":refs/tags/${TAG_NAME}"
fi

# Create the tag at the latest commit
git tag "${TAG_NAME}" "${LATEST_COMMIT}"
git push origin "${TAG_NAME}"
