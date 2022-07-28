#!/bin/bash

setup_app_name() {
  export APP_NAME=$(basename `git rev-parse --show-toplevel`)
}

get_ci_yaml() {
  wget https://raw.githubusercontent.com/favedom-dev/github-reusable-workflow/master/templates/${CI_DIR}/ci.yaml
}

update_ci_yaml() {
  mkdir -p .github/workflows
  envsubst < ci.yaml > .github/workflows/ci.yaml
  rm ci.yaml
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
get_ci_yaml
update_ci_yaml
cleanup
