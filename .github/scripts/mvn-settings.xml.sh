#!/usr/bin/env bash

# Input and output files
INPUT_FILE="./settings.xml"
OUTPUT_FILE="~/.m2/settings.xml"

echo "-----------------------------------------------------"
echo "INPUT_FILE : ${INPUT_FILE}"
echo "OUTPUT_FILE: ${OUTPUT_FILE}"
echo "====================================================="

# envsubst < ./settings.xml > ~/.m2/settings.xml
mkdir -p ~/.m2

# Read the entire content of the file into a variable
file_content=$(< "${INPUT_FILE}")

# Replace variables dynamically in the file content
# Escape quotes and use eval for variable expansion
eval "echo \"$(echo "$file_content" | sed 's/"/\\"/g')\"" > "${OUTPUT_FILE}"

echo "Variables replaced and saved to ${OUTPUT_FILE}"

echo "====="
cat ${OUTPUT_FILE}
echo "====="
