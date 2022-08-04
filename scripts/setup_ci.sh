#!/bin/bash

get_ci_yaml() {
  mkdir -p .github/workflows
  wget https://raw.githubusercontent.com/favedom-dev/github-reusable-workflow/master/templates/${CI_DIR}/ci.yaml -P .github/workflows/
  wget https://raw.githubusercontent.com/favedom-dev/github-reusable-workflow/master/templates/pr-cleanup.yaml -P .github/workflows/
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
cleanup
