#!/usr/bin/env bash

# Env values
#   NAME: ${{ inputs.NAME }}
#   VERSION: ${{ inputs.VERSION }}
#   GH_TOKEN: ${{ secrets.GH_TOKEN }}
#   GH_REPO: ${{ github.repository }}
#   MONOREPO_APP: ${{ inputs.MONOREPO_APP }} (OPTIONAL)
#   DO_PR_MERGE: ${{ inputs.DO_PR_MERGE }} (OPTIONAL)

BRANCH_NAME="gha_${NAME}_${VERSION}"

# List of required environment variables
REQUIRED_VARS=("NAME" "VERSION" "BRANCH_NAME" "GH_REPO")

# Flag to track missing variables
MISSING_VARS=0

for VAR in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!VAR}" ]]; then
    echo "❌ ERROR: $VAR is not set."
    MISSING_VARS=1
  else
    echo "✅ $VAR is set: ${!VAR}"
  fi
done

# check secrets
if [[ -z ${GH_TOKEN} ]]; then
  echo "❌ ERROR: GH_TOKEN is not set."
  MISSING_VARS=1
else
  echo "✅ GH_TOKEN is set: ******"
fi

# Exit with error if any variable is missing
if [[ $MISSING_VARS -eq 1 ]]; then
  echo "❗ Some required environment variables are missing."
  exit 1
else
  echo "🎉 All required environment variables are set."
fi

echo "----------------------------------"
echo "NAME         : ${NAME}"
echo "VERSION      : ${VERSION}"
echo "BRANCH_NAME  : ${BRANCH_NAME}"
echo "GH_REPO      : ${GH_REPO}"
echo "MONOREPO_APP : ${MONOREPO_APP}"
echo "DO_PR_MERGE  : ${DO_PR_MERGE}"
echo "=================================="

## START

# set -e  # Exit immediately if any command fails
MAX_RETRIES=5
SLEEP_TIME=10

echo "Checking if branch '${BRANCH_NAME}' already exists..."
if git ls-remote --exit-code --heads origin "${BRANCH_NAME}"; then
  echo "Branch '${BRANCH_NAME}' exists. Checking it out..."
  git checkout "${BRANCH_NAME}"

  echo "Rebasing '${BRANCH_NAME}' onto '${MAIN_BRANCH}'..."
  git fetch origin "${MAIN_BRANCH}"
  git rebase origin/"${MAIN_BRANCH}" || {
    echo "Rebase conflict detected. Aborting rebase..."
    git rebase --abort
    echo "Skipping rebase. Continuing with existing branch..."
  }
else
  echo "Creating new branch '${BRANCH_NAME}'..."
  git checkout -b "${BRANCH_NAME}"
fi

echo "Staging and committing changes..."
git add .
if git diff --staged --quiet; then
  echo "No changes to commit. Exiting..."
  exit 0
fi

echo "git commit -a -m \"${NAME} ${VERSION}\""
git commit -a -m "${NAME} ${VERSION}"

echo "Force pushing branch to remote..."
git push --force-with-lease origin "${BRANCH_NAME}"

FULL_VERSION=v${VERSION}
if [ ${#MONOREPO_APP} -gt 0 ]; then
  FULL_VERSION=${MONOREPO_APP}/${FULL_VERSION}
fi

echo "Fetching release notes for ${FULL_VERSION}..."
gh release view "${FULL_VERSION}" -R "${GH_REPO}" --json author,tagName,url,body --template \
'Version: [{{.tagName}}]({{.url}})

{{.body}}
' >> ./GH_RELEASE_NOTES.txt

GH_BODY=$(cat ./GH_RELEASE_NOTES.txt)
# echo "GH_BODY : ${GH_BODY}"

echo "Creating pull request..."
for ((i=1; i<=MAX_RETRIES; i++)); do
  if gh pr create --label "approved" --title "chore: bump image.tag ${NAME} to ${VERSION}" --body "${GH_BODY}"; then
    echo "Pull request created successfully."
    break
  fi
  echo "PR creation failed. Retrying in ${SLEEP_TIME} seconds... (Attempt ${i}/${MAX_RETRIES})"
  sleep $(( SLEEP_TIME * i ))  # Exponential backoff
done

if [ "${DO_PR_MERGE}" = "true" ]; then
  echo "Auto Squash & Merge PR..."
  for ((i=1; i<=MAX_RETRIES; i++)); do
    if gh pr merge "${BRANCH_NAME}" --auto --squash; then
      echo "PR merged successfully."
      break
    fi
    echo "PR merge failed. Retrying in ${SLEEP_TIME} seconds... (Attempt ${i}/${MAX_RETRIES})"
    sleep $(( SLEEP_TIME * i ))  # Exponential backoff
  done
fi
