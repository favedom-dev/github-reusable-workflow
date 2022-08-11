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

get_branch_protection() {
  filename="branch_protection.json"
  echo ""
  echo "GETTING: ${filename}"
  wget -O ${filename} https://raw.githubusercontent.com/${ORG_NAME}/github-reusable-workflow/${BRANCH_NAME}/templates/${CI_DIR}/${filename}
}

# takes 1 arg to add to output name
list_branch_protection() {
  output_file="${APP_NAME}-$1-branch_protection.json"
  echo ""
  echo "Dumping branch proection rule: ${output_file}"
  gh api repos/${ORG_NAME}/${APP_NAME}/branches/${BRANCH_NAME}/protection > ${output_file}
}

update_branch_protection() {
  # https://docs.github.com/en/rest/branches/branch-protection#update-branch-protection
  echo ""
  echo "UPDATING: branch protection: https://github.com/${ORG_NAME}/${APP_NAME}/settings/branches"
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
arg_ci_dir $@
setup_app_name
get_branch_protection
list_branch_protection orig
update_branch_protection
list_branch_protection updated
cleanup
