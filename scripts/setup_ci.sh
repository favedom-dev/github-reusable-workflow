#!/bin/bash

get_ci_yaml() {
  mkdir -p .github/workflows
  wget -O .github/workflows/ci.yaml https://raw.githubusercontent.com/favedom-dev/github-reusable-workflow/master/templates/${CI_DIR}/ci.yaml
  wget -O .github/workflows/preview-cleanup.yaml https://raw.githubusercontent.com/favedom-dev/github-reusable-workflow/master/templates/preview-cleanup.yaml
}

get_secrets_template() {
  mkdir -p scripts
  wget -O scripts/preview_secrets.txt https://raw.githubusercontent.com/favedom-dev/github-reusable-workflow/master/scripts/preview_secrets.txt
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
get_ci_yaml
get_secrets_template
cleanup
