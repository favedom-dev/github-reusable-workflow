#!/usr/bin/env bash

# TEST VALUES
# CHART_DIR="."
# NAME="fan-keycloak-theme"
# NAME="celeb-keycloak-theme"
# VERSION="9.99.999"

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <path to Keycloak Chart directory> <keycloak theme name> <new image tag>"
  exit 1
fi

CHART_DIR="${1}"
NAME="${2}"
VERSION="${3}"

YAML_FILE=${CHART_DIR}/${YAML_FILE:-"values.yaml"}
ROOT_ELEMENT=${ROOT_ELEMENT:-"image:"}
REGISTRY=${REGISTRY:-"us-central1-docker.pkg.dev"}
REPOSITORY=${REPOSITORY:-"favedom-dev/docker"}
YAML_IMAGE=${YAML_IMAGE:-"${REGISTRY}/${REPOSITORY}/${NAME}"}

if [[ "${YAML_IMAGE}" == *"\/"* ]]; then
  ESCAPED_YAML_IMAGE="${YAML_IMAGE}"
else
  ESCAPED_YAML_IMAGE="${YAML_IMAGE//\//\\\/}"
fi

SED_VERSION="${ROOT_ELEMENT} ${ESCAPED_YAML_IMAGE}:${VERSION}"
GREP_STR="${ROOT_ELEMENT} .*\/${NAME}:.*"

echo ""
echo "-------------------:--------------"
echo "CHART_DIR          : ${CHART_DIR}"
echo "NAME               : ${NAME}"
echo "VERSION            : ${VERSION}"
echo "YAML_FILE          : ${YAML_FILE}"
echo "ROOT_ELEMENT       : ${ROOT_ELEMENT}"
echo "REGISTRY           : ${REGISTRY}"
echo "REPOSITORY         : ${REPOSITORY}"
echo "YAML_IMAGE         : ${YAML_IMAGE}"
echo "ESCAPED_YAML_IMAGE : ${ESCAPED_YAML_IMAGE}"
echo "SED_VERSION        : ${SED_VERSION}"
echo "GREP_STR           : ${GREP_STR}"
echo "===================:=============="
echo ""

grep "${GREP_STR}" "${YAML_FILE}" > /dev/null 2>&1;
RC=${?}
if [ "${RC}" -ne 0 ]; then
  echo "ERROR: grep did not find \"${GREP_STR}\" in \"$(pwd)/${YAML_FILE}\""
  exit "${RC}"
fi

sed -i -e "s/${GREP_STR}/${SED_VERSION}/" "${YAML_FILE}"
