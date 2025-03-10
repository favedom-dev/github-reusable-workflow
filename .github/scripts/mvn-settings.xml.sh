#!/usr/bin/env bash

# Input and output files
INPUT_FILE=${INPUT_FILE:-../settings.xml}
OUTPUT_FILE=${OUTPUT_FILE:-${HOME}/.m2/settings.xml}

echo "-----------------------------------------------------"
echo "INPUT_FILE : ${INPUT_FILE}"
echo "OUTPUT_FILE: ${OUTPUT_FILE}"
echo "====================================================="

if command -v envsubst >/dev/null 2>&1; then
  echo "envsubst is installed"
  envsubst < "${INPUT_FILE}" > "${OUTPUT_FILE}"
else
  echo "envsubst is not installed..."
  mkdir -p ~/.m2

  # Read the entire content of the file into a variable
  file_content=$(< "${INPUT_FILE}")

  # Replace variables dynamically in the file content
  # Escape quotes and use eval for variable expansion
  eval "echo \"$(echo "${file_content}" | sed 's/"/\\"/g')\"" > "${OUTPUT_FILE}"
fi

echo "Variables replaced and saved to: ${OUTPUT_FILE}"

cat ${OUTPUT_FILE}
