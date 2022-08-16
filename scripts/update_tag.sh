#/bin/bash

# YAML_FILE="helm/values/identityx-v17.yaml"
# VERSION="9.9.999"
# NAME="peeq-keycloak"
# SED_GCR_REPO="gcr.io\/favedom-dev\/"
# SED_GAR_REPO="us-central1-docker.pkg.dev\/favedom-dev\/peeq-docker\/"

ELEMENT_NAME_1="repository"
ELEMENT_NAME_2="tag"

echo "--------------:--------------"
echo "NAME          : ${NAME}"
echo "VERSION       : ${VERSION}"
echo "YAML_FILE     : ${YAML_FILE}"
echo "SED_GCR_REPO  : ${SED_GCR_REPO}"
echo "SED_GAR_REPO  : ${SED_GAR_REPO}"
echo "ELEMENT_NAME_1: ${ELEMENT_NAME_1}"
echo "ELEMENT_NAME_2: ${ELEMENT_NAME_2}"
echo "--------------:--------------"


if [[ $(grep ${SED_GCR_REPO} ${YAML_FILE}) ]]; then
  echo "SED_GAR_REPO: ${SED_GAR_REPO}"
  REPO_STR=${SED_GAR_REPO}
if [[ $(grep ${SED_GCR_REPO} ${YAML_FILE}) ]]; then
  echo "SED_GCR_REPO: ${SED_GCR_REPO}"
  REPO_STR=${SED_GCR_REPO}
else
  echo "ERROR: not found image.${ELEMENT_NAME_1}: ${NAME}"
  exit 1
fi

REPO_STR=${REPO_STR}${NAME}

echo "--------------:--------------"
echo "REPO_STR      : ${REPO_STR}"
echo "--------------:--------------"

sed -i -e '/'${ELEMENT_NAME_1}': '${REPO_STR}'$/{n' -e 's/'${ELEMENT_NAME_2}': [0-9,.]*/'${ELEMENT_NAME_2}': '${VERSION}'/' -e '}' ${YAML_FILE}