#/bin/bash

# NAME="peeq-fan-keycloak-theme"
# YAML_FILE="helm/values/identityx-v17.yaml"
# VERSION="9.99.999"
# SED_GCR_REPO="gcr.io\/favedom-dev\/"
# SED_GAR_REPO="us-central1-docker.pkg.dev\/favedom-dev\/peeq-docker\/"

echo "--------------:--------------"
echo "NAME          : ${NAME}"
echo "VERSION       : ${VERSION}"
echo "YAML_FILE     : ${YAML_FILE}"
echo "SED_GCR_REPO  : ${SED_GCR_REPO}"
echo "SED_GAR_REPO  : ${SED_GAR_REPO}"
echo "--------------:--------------"

if [[ $(grep "image: ${SED_GAR_REPO}${NAME}:" ${YAML_FILE}) ]]; then
  echo "SED_GAR_REPO: ${SED_GAR_REPO}"
  REPO_STR=${SED_GAR_REPO}
elif [[ $(grep "image: ${SED_GCR_REPO}${NAME}:" ${YAML_FILE}) ]]; then
  echo "SED_GCR_REPO: ${SED_GCR_REPO}"
  REPO_STR=${SED_GCR_REPO}
else
  echo "ERROR: not found image: ***${NAME}:"
  exit 1
fi

REPO_STR=${REPO_STR}

echo "--------------:--------------"
echo "REPO_STR      : ${REPO_STR}"
echo "--------------:--------------"

sed -i -e "s/image: ${REPO_STR}${NAME}:.*/image: ${SED_GAR_REPO}${NAME}:${VERSION}/" ${YAML_FILE}