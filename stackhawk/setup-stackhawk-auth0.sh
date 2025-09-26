#!/bin/bash

# Config: Replace with your Auth0 values
AUTH0_DOMAIN="${AUTH0_DOMAIN}"   # e.g., dev-abc123.us.auth0.com
AUTH0_CLIENT_ID="${AUTH0_CLIENT_ID}"         # From Auth0 SPA or M2M app
AUTH0_CLIENT_SECRET="${AUTH0_CLIENT_SECRET}" # Only for confidential clients (M2M); omit for public SPA
AUTH0_AUDIENCE="${AUTH0_AUDIENCE}"           # e.g., https://your-api.com
AUTH0_SCOPE="${AUTH0_SCOPE}"                 # Adjust scopes

STACKHAWK_API_KEY="${STACKHAWK_API_KEY}"
STACKHAWK_TMPL=${STACKHAWK_TMPL:-stackhawk-tmpl.yml}
TOKEN_FILE="${TOKEN_FILE:-/tmp/auth_token.txt}"

# App host (for scan target)
APP_HOST="${APP_HOST:-https://partner.dev.fanfuzenil.com/}"

echo "---------------------"
echo "AUTH0_DOMAIN        : ${AUTH0_DOMAIN}"
echo "AUTH0_CLIENT_ID     : ${#AUTH0_CLIENT_ID}"
echo "AUTH0_CLIENT_SECRET : ${#AUTH0_CLIENT_SECRET}"
echo "AUTH0_AUDIENCE      : ${AUTH0_AUDIENCE}"
echo "AUTH0_SCOPE         : ${AUTH0_SCOPE}"
echo "APP_HOST            : ${APP_HOST}"
echo "STACKHAWK_API_KEY   : ${#STACKHAWK_API_KEY}"
echo "STACKHAWK_TMPL      : ${STACKHAWK_TMPL}"
echo "TOKEN_FILE          : ${TOKEN_FILE}"
echo "APP_HOST            : ${APP_HOST}"
echo "====================="

# StackHawk API key (set as env var or hardcode for local; get from StackHawk UI > Settings)
STACKHAWK_API_KEY="${STACKHAWK_API_KEY:?Error: Set STACKHAWK_API_KEY env var}"

# Fetch token via Client Credentials (for M2M; for user login, use Authorization Code below)
curl -s -X POST "https://${AUTH0_DOMAIN}/oauth/token" \
  -H "Content-Type: application/json" \
  -d "{
    \"client_id\": \"${AUTH0_CLIENT_ID}\",
    \"client_secret\": \"${AUTH0_CLIENT_SECRET}\",
    \"audience\": \"${AUTH0_AUDIENCE}\",
    \"grant_type\": \"client_credentials\"
  }" | jq -r '.access_token' > "${TOKEN_FILE}"

# Alternative: For user-based Authorization Code + PKCE (run a local server or use manual login)
# 1. Start a temp server to capture code (or use browser manually).
# 2. Then: curl -s -X POST "https://${AUTH0_DOMAIN}/oauth/token" -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=authorization_code&client_id=${AUTH0_CLIENT_ID}&code=${CODE}&redirect_uri=http://localhost:3000&code_verifier=${VERIFIER}" | jq -r '.access_token'

AUTH_TOKEN=$(cat "${TOKEN_FILE}")
if [ -z "$AUTH_TOKEN" ] || [ "$AUTH_TOKEN" == "null" ]; then
  echo "Error: Failed to fetch token. Check Auth0 config."
  rm -f "${TOKEN_FILE}"
  exit 1
fi
export AUTH_TOKEN

echo "Token fetched successfully (length: ${#AUTH_TOKEN}). Creating stackhawk.yml..."

# update stackhawk.yml with variables
envsubst < ./${STACKHAWK_TMPL} > ./stackhawk.yml

rm -f "${TOKEN_FILE}"

echo "Ready to scan..."

# echo "Token fetched successfully (length: ${#AUTH_TOKEN}). Starting scan..."
# Run HawkScan via Docker
# docker run --rm \
#   -e STACKHAWK_API_KEY="${STACKHAWK_API_KEY}" \
#   -e AUTH_TOKEN="${AUTH_TOKEN}" \
#   -e APP_HOST="${APP_HOST}" \
#   -v "$(pwd):/hawk/runs" \
#   -t stackhawk/hawkscan \
#   hawkscan --debug  # Remove --debug for quieter output

# rm -f "${TOKEN_FILE}"
# echo "Scan complete. Check results at https://app.stackhawk.com"
