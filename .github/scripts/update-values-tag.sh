#!/usr/bin/env bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <path to Chart directory> <dependency name or alias> <new image tag>"
  exit 1
fi

# Assign arguments to variables
CHART_DIR=$1
TARGET_DEP=$2
NEW_IMAGE_TAG=$3
NEW_REPO=${4:-"us-central1-docker.pkg.dev/favedom-dev/docker/${TARGET_DEP}"}
# Build variables
REQUIREMENTS_YAML=${CHART_DIR}/requirements.yaml
CHART_YAML=${CHART_DIR}/Chart.yaml
VALUES_YAML=${CHART_DIR}/values.yaml
DEPENDENCIES_YAML="${REQUIREMENTS_YAML}"

if [ "${NEW_IMAGE_TAG:0:1}" != "\"" ]; then
  NEW_IMAGE_TAG=\"${NEW_IMAGE_TAG}\"
fi

echo ""
echo "CHART_DIR         : ${CHART_DIR}"
echo "TARGET_DEP        : ${TARGET_DEP}"
echo "NEW_IMAGE_TAG     : ${NEW_IMAGE_TAG}"
echo "NEW_REPO          : ${NEW_REPO}"
echo ""
echo "DEPENDENCIES_YAML : ${DEPENDENCIES_YAML}"
echo "REQUIREMENTS_YAML : ${REQUIREMENTS_YAML}"
echo "CHART_YAML        : ${CHART_YAML}"
echo "VALUES_YAML       : ${VALUES_YAML}"
echo ""

# Check if yq is installed
if ! command -v yq &> /dev/null
then
  echo "yq could not be found, please install it first."
  exit 1
fi

# Check if the file exists and determine its type
if [ ! -f "${REQUIREMENTS_YAML}" ]; then
  echo "File not found: $CHART_YAML"
  DEPENDENCIES_YAML="${CHART_YAML}"
  if [ ! -f "${CHART_YAML}" ]; then
    echo "File not found: $CHART_YAML"
    exit 1
  fi
fi
echo "DEPENDENCIES_YAML : ${DEPENDENCIES_YAML}"

# Determine if the file is Chart.yaml or requirements.yaml
if grep -q "apiVersion" "${DEPENDENCIES_YAML}" || grep -q "dependencies" "${DEPENDENCIES_YAML}"; then
  DEPENDENCIES=$(yq '.dependencies[] | (.alias // .name) | select(. == "'${TARGET_DEP}'")'  "${DEPENDENCIES_YAML}")
else
  echo ""
  echo "The file ${DEPENDENCIES_YAML} is neither a valid Chart.yaml nor a requirements.yaml."
  exit 1
fi
echo "DEPENDENCIES      : ${DEPENDENCIES}"

# Check if the target dependency exists in the dependencies list
if ! echo "${DEPENDENCIES}" | grep -q "${TARGET_DEP}"; then
  echo ""
  echo "Dependency ${TARGET_DEP} not found in ${DEPENDENCIES}"
  exit 1
fi

# Escape the dependency name for use in sed
ESCAPED_DEP=$(echo "${DEPENDENCIES}" | sed 's/\./\\./g')
echo "ESCAPED_DEP       : ${ESCAPED_DEP}"

# Use sed to update the image tag associated with the specified dependency
sed -i '/'"${ESCAPED_DEP}"':/,/^[^ ]/ s/\(tag:\s*\).*/\1'"${NEW_IMAGE_TAG}"'/' "${VALUES_YAML}"
echo ""
echo "Updated image tag in ${VALUES_YAML} to ${NEW_IMAGE_TAG} for dependency: ${TARGET_DEP}"
echo ""

sed -i '/'"${ESCAPED_DEP}"':/,/^[^ ]/ s/\(repository:\s*\).*/\1'"${NEW_REPO}"'/' "${VALUES_YAML}"
echo ""
echo "Updated image repository in ${VALUES_YAML} to ${NEW_REPO} for dependency: ${TARGET_DEP}"

echo ""
echo "${VALUES_YAML}:"
yq "${VALUES_YAML}"
echo ""
