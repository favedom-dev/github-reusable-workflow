#!/bin/bash

ORG_NAME="favedom-dev"
BRANCH_NAME="master"

setup_app_name() {
  export APP_NAME=$(basename `git rev-parse --show-toplevel`)
  display_vars
}

display_vars() {
  echo ""
  echo "-----------:-------------------"
  echo "CI_DIR     : ${CI_DIR}"
  echo "ORG_NAME   : ${ORG_NAME}"
  echo "BRANCH_NAME: ${BRANCH_NAME}"
  echo "APP_NAME   : ${APP_NAME}"
  echo "-----------:-------------------"
}

get_() {
  wget https://raw.githubusercontent.com/${ORG_NAME}/github-reusable-workflow/${BRANCH_NAME}/templates/${CI_DIR}/branch_protection.json
}

delete_branch_protection() {
  gh api -X DELETE repos/${ORG_NAME}/${APP_NAME}/branches/${BRANCH_NAME}/protection
}

list_branch_protection() {
  gh api repos/${ORG_NAME}/${APP_NAME}branches/${BRANCH_NAME}/protection
}

update_branch_protection() {
  # https://docs.github.com/en/rest/branches/branch-protection#update-branch-protection
  gh api \
  --method PUT \
  repos/${ORG_NAME}/${APP_NAME}/branches/${BRANCH_NAME}/protection \
  --input ./branch_protection.json >/dev/null
}

arg_ci_dir() {
  if [ -z "$1" ] ; then
    echo "Must pass an arg that matches a dir under: https://github.com/favedom-dev/github-reusable-workflow/tree/master/templates"
    exit 1;
  else
    CI_DIR=$1
  fi
}

cleanup() {
  rm $0
}

## MAIN
# arg_ci_dir $@
# setup_app_name
# get_branch_protection
# update_branch_protection
# cleanup
echo "TODO:"
echo "Will create branch rules based on the CI"