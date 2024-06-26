#!/bin/bash

echo "-----------"
# env | sort
echo "ACT : \"${ACT}\""
echo "==========="

# if a monorepo pass the app name
MONOREPO_APP_NAME=$1

if [[ ! -z ${MONOREPO_APP_NAME} ]]; then
  echo "MONOREPO: ${MONOREPO_APP_NAME}"
  NEW_TAG_PREFIX="${MONOREPO_APP_NAME}/v"
  # get highest tag number
  FULL_VERSION=$(git tag -l "${MONOREPO_APP_NAME}/*" --sort=-version:refname | head -1)
  VERSION=${FULL_VERSION//$MONOREPO_APP_NAME\//}
else
  echo "SINGLE REPO"
  NEW_TAG_PREFIX="v"
  # get highest tag number
  FULL_VERSION=$(git tag --sort=-version:refname | head -1)
  VERSION=${FULL_VERSION}
fi

echo "==============:======================="
echo "NEW_TAG_PREFIX: ${NEW_TAG_PREFIX}"
echo "FULL_VERSION  : ${FULL_VERSION}"
echo "VERSION       : ${VERSION}"
echo "==============:======================="

# replace . with space so can split into an array
VERSION_BITS=(${VERSION//./ })

# get number parts and increase last one by 1
VNUM1=${VERSION_BITS[0]:-0}
VNUM2=${VERSION_BITS[1]:-0}
VNUM3=${VERSION_BITS[2]}
VNUM1=${VNUM1//v/}

# Check for #major or #minor in commit message and increment the relevant version number
MAJOR=$(git log --format=%B -n 1 HEAD | grep '#major')
MINOR=$(git log --format=%B -n 1 HEAD | grep '#minor')

echo ""
if [ "$MAJOR" ]; then
    echo "Update major version"
    VNUM1=$((VNUM1+1))
    VNUM2=0
    VNUM3=0
elif [ "$MINOR" ]; then
    echo "Update minor version"
    VNUM2=$((VNUM2+1))
    VNUM3=0
else
    echo "Update patch version"
    VNUM3=$((VNUM3+1))
fi

# create new tag
NEW_VERSION="${VNUM1}.${VNUM2}.${VNUM3}"
NEW_TAG="${NEW_TAG_PREFIX}${NEW_VERSION}"

echo ""
echo "Updating \"${FULL_VERSION}\" to \"${NEW_TAG}\""
echo ""

# get current hash and see if it already has a tag
# GIT_COMMIT=`git rev-parse HEAD`
# NEEDS_TAG=`git describe --contains $GIT_COMMIT`

# only tag if no tag already (would be better if the git describe command above could have a silent option)
# if [ -z "$NEEDS_TAG" ]; then
    # echo "Tagged with $NEW_TAG (Ignoring fatal:cannot describe - this means commit is untagged) "
    # env | sort
    echo "ACT : \"${ACT}\""
    if [ ! ${ACT} ]; then
      gh release create "${NEW_TAG}" --generate-notes
      rc=$?
      if [ ${rc} -ne 0 ] ; then
        exit ${rc}
      fi
    else
      echo "RUNNING LOCALLY with act, skipped gh release create"
    fi
    echo "${NEW_VERSION}" > VERSION
    echo "${VNUM1}" > VERSION_MAJOR
    echo "${VNUM2}" > VERSION_MINOR
    echo "${VNUM3}" > VERSION_PATCH
    echo "${NEW_TAG}" > TAG
# else
#     echo "Already a tag on this commit"
#     echo $(echo "${VERSION}" | sed 's/v//') > VERSION
#     echo $(echo "${VERSION}" | sed 's/v//' | cut -f1 -d .) > VERSION_MAJOR
#     echo $(echo "${VERSION}" | sed 's/v//' | cut -f2 -d .) > VERSION_MINOR
#     echo $(echo "${VERSION}" | sed 's/v//' | cut -f3 -d .) > VERSION_PATCH
#     echo ${NEW_TAG_PREFIX}"${VERSION}" > TAG
# fi
exit 0