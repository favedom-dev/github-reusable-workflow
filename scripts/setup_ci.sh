#!/usr/bin/env bash

get_ci_yaml() {
  filename="ci.yaml"
  echo "GETTING: ${filename}"
  mkdir -p .github/workflows
  wget -O .github/workflows/ci.yaml https://raw.githubusercontent.com/favedom-dev/github-reusable-workflow/master/templates/${CI_DIR}/ci.yaml
}

get_preview_cleanup() {
  filename="preview-cleanup.yaml"
  echo ""
  echo "GETTING: ${filename}"
  mkdir -p .github/workflows
  wget -O .github/workflows/${filename} https://raw.githubusercontent.com/favedom-dev/github-reusable-workflow/master/templates/${filename}
}

get_secrets_template() {
  filename="scripts/preview_secrets.txt"
  echo ""
  echo "GETTING: ${filename}"
  mkdir -p scripts
  wget -O ${filename} https://raw.githubusercontent.com/favedom-dev/github-reusable-workflow/master/${filename}
}

update_stackhawk() {
  filename="stackhawk/stackhawk-tmpl.yml"
  if [ -f "${filename}" ]; then
    echo "UPDATING: ${filename}"
    sed -i -e "s/{PR_HOST}/{APP_HOST}/" ${filename}
    sed -i -e "s/{PQ_API_PATH}/{API_PATH}/" ${filename}
  fi
}

get_extras() {
  case "${CI_DIR}" in
    "node")
     ;&
    "bpm")
     ;&
    "maven")
      echo ""
      echo "Getting more files"
      get_preview_cleanup
      get_secrets_template
      update_stackhawk
      ;;
    *)
      echo "Nothing more to get"
  esac
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
get_extras
cleanup
