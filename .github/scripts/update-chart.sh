#!/usr/bin/env bash

# CHART_NAME=users
# CHART_DIR=dev/tmp-fanfuze/users
# VERSION=9.9.9
# YAML_FILE=requirements.yaml
CHART_DIR=${CHART_DIR}
CHART_NAME=${CHART_NAME}
VERSION=${VERSION}
YAML_FILE=${YAML_FILE}
CHART_YAML_PATH=${CHART_DIR}/${YAML_FILE}

echo ""
echo "CHART_NAME      : ${CHART_NAME}"
echo "CHART_DIR       : ${CHART_DIR}"
echo "VERSION         : ${VERSION}"
echo "YAML_FILE       : ${YAML_FILE}"
echo "CHART_YAML_PATH : ${CHART_YAML_PATH}"
echo ""


init() {
  NOCOLOR='\033[0m'
  BLUE='\033[0;34m'
  COLOR_VALUE="${BLUE}"
}

run_cmd() {
  echo -e "${COLOR_CMD}${_cmd[*]}${NOCOLOR}"
  eval "${_cmd[@]}"
  RC=${?}
  if [ "${RC}" -ne 0 ]; then
    revert_chart
    echo "ERROR: rc = ${RC}"
    exit "${RC}"
  fi
  echo ""
}

update_chart() {
  chart="${CHART_NAME}" newver="${VERSION}" yq '(.dependencies[] | select (.name == strenv(chart))).version = strenv(newver)' -i "${CHART_YAML_PATH}"
  echo ""
  echo -e "${COLOR_VALUE}${CHART_YAML_PATH}${NOCOLOR}:"
  yq "${CHART_YAML_PATH}"
  echo ""
}

# ####
# MAIN
init
update_chart
