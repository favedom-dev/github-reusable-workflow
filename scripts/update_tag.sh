#!/usr/bin/env bash

# TEST VALUES
# NAME="identityx-24"
# VERSION="9.9.999"

YAML_FILE="${YAML_FILE:-"values.yaml"}"
REGISTRY="${REGISTRY:-"us-central1-docker.pkg.dev"}"
REPOSITORY="${REPOSITORY:-"favedom-dev/docker"}"
ROOT_ELEMENT="${ROOT_ELEMENT:-${NAME}}"
SUB_ELEMENT="${SUB_ELEMENT:-"image"}"
BASE_ELEMENT="${BASE_ELEMENT:-${ROOT_ELEMENT}.${SUB_ELEMENT}}"

echo "---------------:--------------"
echo "YAML_FILE      : ${YAML_FILE}"
echo "NAME           : ${NAME}"
echo "VERSION        : ${VERSION}"
echo "REGISTRY       : ${REGISTRY}"
echo "REPOSITORY     : ${REPOSITORY}"
echo "ROOT_ELEMENT   : ${ROOT_ELEMENT}"
echo "SUB_ELEMENT    : ${SUB_ELEMENT}"
echo "BASE_ELEMENT  -: ${BASE_ELEMENT}"
echo "---------------:--------------"

YAML_REGISTRY=$(cat ./${YAML_FILE} | yq eval '.'"${BASE_ELEMENT}"'.registry')
YAML_REPOSITORY=$(cat ./${YAML_FILE} | yq eval '.'"${BASE_ELEMENT}"'.repository')
YAML_TAG=$(cat ./${YAML_FILE} | yq eval '.'"${BASE_ELEMENT}"'.tag')

echo "YAML_REGISTRY  : ${YAML_REGISTRY}"
echo "YAML_REPOSITORY: ${YAML_REPOSITORY}"
echo "YAML_TAG       : ${YAML_TAG}"
echo "---------------:--------------"
echo ""

update_yaml() {
  echo "Updating ${YAML_ELEMENT}: ${NEW_VALUE}"
  yq eval -i '.'"${YAML_ELEMENT}"' = "'"${NEW_VALUE}"'"' "${YAML_FILE}"
}

update_registry() {
  YAML_ELEMENT="${BASE_ELEMENT}.registry"
  NEW_VALUE="${NEW_REGISTRY}"
  update_yaml
}

update_repository() {
  YAML_ELEMENT="${BASE_ELEMENT}.repository"
  NEW_VALUE="${NEW_REPOSITORY}"
  update_yaml
}

update_tag() {
  YAML_ELEMENT="${BASE_ELEMENT}.tag"
  NEW_VALUE="${NEW_TAG}"
  update_yaml
}

NEW_REGISTRY="${REGISTRY}"
NEW_REPOSITORY="${REPOSITORY}/${NAME}"
NEW_TAG="${VERSION}"

if [ "${YAML_TAG}" != "null" ]; then
  update_tag
else
  NEW_REPOSITORY="${NEW_REPOSITORY}:${NEW_TAG}"
fi

if [ "${YAML_REGISTRY}" != "null" ]; then
  update_registry
else
  NEW_REPOSITORY="${NEW_REGISTRY}/${NEW_REPOSITORY}"
fi

if [ "${YAML_REPOSITORY}" != "null" ]; then
  update_repository
fi
