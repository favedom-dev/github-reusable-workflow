#!/bin/bash

# Format for contents of file HELM_REPOS_FILENAME is:
#    repo name + "," + repo url
# Examples:
#    repoName1,repoUrl1 repoName2,repoUrl2
#    rabbitmq,https://raw.githubusercontent.com/bitnami/charts/pre-2022/bitnami
DEFAULT_HELM_REPOS_FILENAME="./helm_add_repos.txt"
# 1st arg can override the SECRET_FILENAM name
HELM_REPOS_FILENAME="${1:-$DEFAULT_HELM_REPOS_FILENAME}"


# check that file exists
if [ ! -f "$HELM_REPOS_FILENAME" ]; then
  echo "ERROR: \"${HELM_REPOS_FILENAME}\" does not exists in: $(pwd)"
  exit 1
fi

echo "--------------------:-----------------"
echo "HELM_REPOS_FILENAME : ${HELM_REPOS_FILENAME}"
echo "--------------------:-----------------"

HELM_REPO_LIST=$(<"${HELM_REPOS_FILENAME}")
echo "HELM_REPO_LIST: ${HELM_REPO_LIST}"

for helm_repo_name in ${HELM_REPO_LIST[@]}; do
  # clean array
  unset helm_repo_url
  # get helm_repo_name
  if [[ ${HELM_REPO_LIST} == *","* ]]; then
    # split namespace name from sub-list secrets
    tmpRepoArray=(${helm_repo_name//,/ })
    helm_repo_name=${tmpRepoArray[0]}
    helm_repo_url=${tmpRepoArray[1]}
    # make array from simple string
    helm_repo_url=(${helm_repo_url//,/ })
  fi

  echo ""
  echo "===============:================"
  echo "helm_repo_name : ${helm_repo_name}"
  echo "helm_repo_url  : ${helm_repo_url}"
  echo "===============:================"

  helm repo add ${helm_repo_name} ${helm_repo_url} ${HELM_DEBUG_FLAG}

done
