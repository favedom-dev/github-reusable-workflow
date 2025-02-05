#!/usr/bin/env bash

BRANCH_NAME
TAG

run_cmd() {
  echo "----------------------------------"
  echo -e "${COLOR_CMD}${_cmd[*]}${NOCOLOR}"
  eval "${_cmd[@]}"
  RC=${?}
  echo "=================================="
  echo ""
}

handle_rc() {
  if [ "${RC}" -ne 0 ]; then
    echo -e "${COLOR_ERROR}ERROR: rc=${RC} ${ERROR_MESSAGE}${NOCOLOR}"
    exit "${RC}"
  fi
}

get_latest_info() {
  # Get the latest commit on the specified branch
  LATEST_COMMIT=$(git rev-parse "origin/${BRANCH_NAME}")
  PREVIOUS_TAG_COMMIT=$(git rev-parse "${TAG}")
  display_info
}

display_info() {
  echo "--------------------:--------------------"
  echo "TAG_NAME            : ${TAG_NAME}"
  echo "BRANCH_NAME         : ${BRANCH_NAME}"
  echo "LATEST_COMMIT       : ${LATEST_COMMIT}"
  echo "PREVIOUS_TAG_COMMIT : ${PREVIOUS_TAG_COMMIT}"
  echo "====================:===================="
}

tag_repo() {
  # Check if the tag exists
  if git rev-parse "${TAG_NAME}" >/dev/null 2>&1; then
    # Update the tag to the latest commit
    _cmd=(git tag -d "${TAG_NAME}")
    run_cmd
    _cmd=(git push origin :refs/tags/${TAG_NAME})
    run_cmd
  fi

  # Create the tag at the latest commit
  _cmd=(git tag "${TAG_NAME}" "${LATEST_COMMIT}")
  run_cmd
  _cmd=(git push origin "${TAG_NAME}")
  run_cmd

  echo "Push the new tag"
  _cmd=(git push origin --tags)
  run_cmd
}

# MAIN
get_latest_info
tag_repo
