#!/usr/bin/env bash

export GH_TOKEN="${GH_TOKEN}"
ARTIFACT_TYPE=${ARTIFACT_TYPE:-docker}

echo "-----------------------------------------------------"
echo "NAME               : ${NAME}"
echo "VERSION            : ${VERSION}"
# 'docker' or 'jar' or 'helm'
echo "ARTIFACT_TYPE      : ${ARTIFACT_TYPE}"
# Renamed from DOCKER_URL
echo "ARTIFACT_URL       : ${ARTIFACT_URL}"
echo "GITHUB_EVENT_NAME  : ${GITHUB_EVENT_NAME}"
echo "GITHUB_EVENT_PATH  : ${GITHUB_EVENT_PATH}"
echo "GITHUB_EVENT_NUMBER: ${GITHUB_EVENT_NUMBER}"
echo "GITHUB_REPOSITORY  : ${GITHUB_REPOSITORY}"
echo "====================================================="

# Handle Docker-specific digest if provided
if [ "${ARTIFACT_TYPE}" = "docker" ] && [ -n "${ARTIFACT_DIGEST}" ]; then
  ARTIFACT_URL="${ARTIFACT_URL%%\?*}/${ARTIFACT_DIGEST}?${ARTIFACT_URL#*\?}"
fi
echo "${ARTIFACT_URL}"
echo "${ARTIFACT_URL}" >>GITHUB_OUTPUT

# Customize PR body based on ARTIFACT_TYPE
case "${ARTIFACT_TYPE}" in
  "docker")
    TABLE_ROWS="| Container | [${NAME} ${VERSION}](${ARTIFACT_URL}) |"
    CODE="bash"
    GET_CMD="docker pull us-central1-docker.pkg.dev/favedom-dev/docker/${NAME}:${VERSION}"
    ;;

  "jar")
    TABLE_ROWS="| 📦 JAR Lib | [${NAME} ${VERSION}](${ARTIFACT_URL}) |"
    CODE="xml"
    GET_CMD=$(cat <<EOF
  <dependency>
    <groupId>com.velocityz</groupId>
    <artifactId>${NAME}</artifactId>
    <version>${VERSION}</version>
  </dependency>
EOF
    )
    ;;

  "helm")
    TABLE_ROWS="| ☸ Helm Chart | [${NAME} ${VERSION}](${ARTIFACT_URL}) |"
    CODE="xml"
    GET_CMD="docker pull us-central1-docker.pkg.dev/favedom-dev/helm/${NAME}:${VERSION}"
    ;;

  *)
    echo "❌ Unsupported ARTIFACT_TYPE: ${ARTIFACT_TYPE}"
    exit 1
    ;;
esac

PR_BODY=$(cat <<EOF
| 🐳 | 🔗 |
| --- | --- |
${TABLE_ROWS}

\`\`\`${CODE}
${GET_CMD}
\`\`\`
EOF
)

if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]]; then
  # Use GITHUB_EVENT_NUMBER if provided, otherwise extract from event payload
  PR_NUMBER="${GITHUB_EVENT_NUMBER:-$(jq --raw-output .number "${GITHUB_EVENT_PATH}")}"
  echo "PR_NUMBER : ${PR_NUMBER}"

  gh pr comment "${PR_NUMBER}" \
    --repo "${GITHUB_REPOSITORY}" \
    --body "${PR_BODY}"
else
  echo "ℹ️ Not a pull request event, skipping comment."
fi

echo "${PR_BODY}" >> "$GITHUB_STEP_SUMMARY"
