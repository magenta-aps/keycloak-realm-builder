#!/bin/bash

# Install Jinja2 CLI
pip install -r requirements.txt

# Populate Keycloak realm JSON template with data from ENV file
j2 --filters=filters.py keycloak-realm.json.j2 keycloak.env > realm.json

# Populate keycloak.json template with data from ENV file
j2 --filters=filters.py keycloak.json.j2 keycloak.env > keycloak.json
