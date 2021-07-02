#!/bin/bash
set -e

if [ -z "${KEYCLOAK_JSON_PATH}" ]; then
    echo "'KEYCLOAK_JSON_PATH' not set, defaulting to '/srv/keycloak.json'"
    KEYCLOAK_JSON_PATH=/srv/keycloak.json
fi
if [ -z "${KEYCLOAK_REALM_JSON_PATH}" ]; then
    echo "'KEYCLOAK_REALM_JSON_PATH' not set, defaulting to '/srv/keycloak-realm.json'"
    KEYCLOAK_REALM_JSON_PATH=/srv/keycloak-realm.json
fi

env >> keycloak.env

# Populate Keycloak realm JSON template with data from ENV file
j2 --filters=filters.py keycloak.json.j2 keycloak.env -o ${KEYCLOAK_JSON_PATH}
echo "keycloak.json output to ${KEYCLOAK_JSON_PATH}"

# Populate keycloak.json template with data from ENV file
j2 --filters=filters.py keycloak-realm.json.j2 keycloak.env -o ${KEYCLOAK_REALM_JSON_PATH}
echo "keycloak-realm.json output to ${KEYCLOAK_REALM_JSON_PATH}"
