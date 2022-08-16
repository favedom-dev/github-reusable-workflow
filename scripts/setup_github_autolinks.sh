#!/bin/bash

ORG_NAME="favedom-dev"

setup_repo_name() {
  export REPO_NAME=$(basename `git rev-parse --show-toplevel`)
  display_vars
}

display_vars() {
  echo ""
  echo "-----------:-------------------"
  echo "ORG_NAME   : ${ORG_NAME}"
  echo "REPO_NAME   : ${REPO_NAME}"
  echo "-----------:-------------------"
}

set_autolink() {
  echo ""
  echo "Setup: PQ-"
  gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /repos/${ORG}/${REPO_NAME}/autolinks \
  -f key_prefix='PQ-'
  -f url_template='https://velocityz.atlassian.net/browse/PQ-<num>'

  echo ""
  echo "Setup: PQK-"
  gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /repos/${ORG}/${REPO_NAME}/autolinks \
  -f key_prefix='PQK-'
  -f url_template='https://velocityz.atlassian.net/browse/PQK-<num>'
}

cleanup() {
  rm $0
}

## MAIN
setup_repo_name
set_autolink
cleanup
