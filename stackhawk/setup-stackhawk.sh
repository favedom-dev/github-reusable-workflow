#!/usr/bin/env bash

# NOTE: requires the following env variables which are used in stackhawk-tmpl.yml
# APP_NAME
# APP_HOST
# APP_ID (optional)
# API_PATH
# KEYCLOAK_AUTH
# TEST_USERNAME
# TEST_PASSWORD

chmod 777 *

# Get token and save value to variable
echo "Get AUTH_TOKEN"
export AUTH_TOKEN=$(curl -X POST "${KEYCLOAK_AUTH}" \
 -H "Content-Type: application/x-www-form-urlencoded" \
 -d "username=${TEST_USERNAME}" \
 -d "password=${TEST_PASSWORD}" \
 -d 'grant_type=password' \
 -d "client_id=peeq-query" | jq -r '.access_token')

# update stackhawk.yml with variables
envsubst < ./stackhawk-tmpl.yml > ./stackhawk.yml
