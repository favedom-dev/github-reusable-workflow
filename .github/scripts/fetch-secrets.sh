#!/usr/bin/env bash

# Prerequisites
# - Install `gcloud` CLI in your runner (pre-installed on GitHub-hosted `ubuntu-latest` runners).
# - Install `jq` for JSON processing (available on GitHub-hosted runners).
# - GCP service account with `roles/secretmanager.secretAccessor` role.

# Inputs
# - `gcp_credentials_json`: (Required) GCP service account JSON key.
# - `secrets`: (Required) Multiline string of secrets in the format `secret-name:output-name` or `secret-name:env-name`.
# - `export_to_environment`: (Optional) Set to `true` to export secrets as environment variables. Default: `false`.
# - `min_mask_length`: (Optional) Minimum length for a secret to be masked in logs. Default: `4`.
# - `encoding`: (Optional) Encoding for secrets (e.g., `utf8`, `base64`, `hex`). Default: `utf8`.

# Outputs
# - `secrets`: JSON object containing all fetched secrets as key-value pairs.
# - Individual outputs for each secret based on the `output-name`.

set -e

# Set defaults
EXPORT_TO_ENV=${EXPORT_TO_ENV:-false}
MIN_MASK_LENGTH=${MIN_MASK_LENGTH:-4}
ENCODING=${ENCODING:-utf8}
GCP_PROJECT=${GCP_PROJECT:-core-services-370815}
GOOGLE_APPLICATION_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS:-"/tmp/gcp-credentials.json"}

echo "EXPORT_TO_ENV                  : ${EXPORT_TO_ENV}"
echo "MIN_MASK_LENGTH                : ${MIN_MASK_LENGTH}"
echo "ENCODING                       : ${ENCODING}"
echo "GCP_PROJECT                    : ${GCP_PROJECT}"
echo "GOOGLE_APPLICATION_CREDENTIALS : ${GOOGLE_APPLICATION_CREDENTIALS}"

# Validate inputs
if [[ -z "${SECRETS}" ]]; then
  echo "::error::Secrets input is required"
  exit 1
fi

if [[ "${GITHUB_ACTIONS}" == "true" ]]; then
  if [[ ! -f "${GOOGLE_APPLICATION_CREDENTIALS}" ]]; then
    echo "::error::GCP credentials file not found"
    exit 1
  fi
else
  echo "Local: Not checking ${GOOGLE_APPLICATION_CREDENTIALS}"
fi

# Authenticate with GCP
if [[ "${GITHUB_ACTIONS}" == "true" ]]; then
  export GOOGLE_APPLICATION_CREDENTIALS="${GOOGLE_APPLICATION_CREDENTIALS}"
  gcloud auth activate-service-account --key-file="${GOOGLE_APPLICATION_CREDENTIALS}"
fi

# Initialize JSON output for secrets
secrets_json="{}"

# Process each secret
while IFS= read -r line || [[ -n "${line}" ]]; do
  # Skip empty lines
  [[ -z "${line}" ]] && continue

  # Parse secret-name:output-name
  secret_name=$(echo "${line}" | cut -d':' -f1 | xargs)
  output_name=$(echo "${line}" | cut -d':' -f2 | xargs)

  if [[ -z "${secret_name}" || -z "${output_name}" ]]; then
    echo "::warning::Invalid secret format: ${line}"
    continue
  fi

  # Fetch secret
  # echo "secret_name : ${secret_name}"
  secret_value=$(gcloud secrets versions access latest --secret="${secret_name}" --project="${GCP_PROJECT}" || true)
  if [[ -z "$secret_value" ]]; then
    echo "::warning::Failed to fetch secret ${secret_name}"
    continue
  fi

  # Handle encoding (base64, hex, etc.)
  if [[ "$ENCODING" == "base64" ]]; then
    secret_value=$(echo "${secret_value}" | base64 -d)
  elif [[ "$ENCODING" == "hex" ]]; then
    secret_value=$(echo "${secret_value}" | xxd -r -p)
  fi

  # Mask secret in logs if length is sufficient and running in GitHub Actions
  if [[ ${#secret_value} -ge ${MIN_MASK_LENGTH} ]]; then
    if [[ "${GITHUB_ACTIONS}" == "true" ]]; then
      echo "Mask secret ${output_name}"
      echo "::add-mask::${secret_value}"
    else
      echo "Local: Would mask secret for ${output_name} (length: ${#secret_value})"
    fi
  fi

  # Set as output
  if [[ "${GITHUB_ACTIONS}" == "true" ]]; then
    echo "GITHUB_OUTPUT ${output_name}..."
    echo "${output_name}=${secret_value}" >> "$GITHUB_OUTPUT"
  else
    echo "Local: ${output_name}=${secret_value}"
  fi

  # Update JSON output
  secrets_json=$(echo "${secrets_json}" | jq --arg key "${output_name}" --arg value "${secret_value}" '. + {($key): $value}')

  # Export to environment if requested
  if [[ "${EXPORT_TO_ENV}" == "true" ]]; then
    if [[ "${GITHUB_ACTIONS}" == "true" ]]; then
      echo "GITHUB_ENV: ${output_name}..."
      echo "${output_name}=${secret_value}" >> "${GITHUB_ENV}"
    else
      echo "Local: Env Exporting ${output_name}=${secret_value}"
      export "${output_name}=${secret_value}"
    fi
  fi
done <<< "${SECRETS}"

# Set combined secrets output
if [[ "$GITHUB_ACTIONS" == "true" ]]; then
  echo "GITHUB_OUTPUT combined secrets..."
  echo "secrets=$(echo "${secrets_json}" | jq -c .)" >> "${GITHUB_OUTPUT}"
else
  echo "Local: Secrets JSON:"
  echo "${secrets_json}" | jq .
fi

# Clean up
if [[ "${GITHUB_ACTIONS}" == "true" ]]; then
  echo "Deleting: ${GOOGLE_APPLICATION_CREDENTIALS}"
  rm -f "${GOOGLE_APPLICATION_CREDENTIALS}"
else
  echo "Local: Not deleting ${GOOGLE_APPLICATION_CREDENTIALS}"
fi
