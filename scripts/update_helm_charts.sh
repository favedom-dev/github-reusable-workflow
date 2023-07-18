#!/usr/bin/env bash

CHART_APP_NAME="pvz-connect-fe" # CHANGE
DOCKER_REGISTRY_NAME="peeq-docker"
# DOCKER_REGISTRY_NAME="powervz-docker"
VERSION="0.0.0-SNAPSHOT-PR-9-9-9"
# SET if testing HEAD
# GH_REF="refs/heads/master"

DOCKER_REGISTRY="us-central1-docker.pkg.dev"
PROJECT_ID="favedom-dev"

sed -i -e "s/version:.*/version: ${VERSION}/" Chart.yaml
sed -i -e "s/tag:.*/tag: ${VERSION}/" values.yaml
echo "GAR: repository update"
sed -i -e "s|repository:.*|repository: ${DOCKER_REGISTRY}\/${PROJECT_ID}\/${DOCKER_REGISTRY_NAME}\/${CHART_APP_NAME}|" values.yaml
if [ "${GH_REF}" == "refs/heads/master" ]; then
  echo "appVersion: ${VERSION}" >> Chart.yaml
  # if [ "" != "release" ]; then
  #   YAML_FILE="Chart.yaml"
  #   echo "Updating ${YAML_FILE} with: name: ${CHART_APP_NAME}"
  #   sed -i -e "s|name:.*|name: ${CHART_APP_NAME}|" ${YAML_FILE}
  # fi
else
  sed -i -e "s/version:.*/version: ${VERSION}/" ../*/Chart.yaml
  echo "  version: ${VERSION}" >> requirements.yaml
fi
