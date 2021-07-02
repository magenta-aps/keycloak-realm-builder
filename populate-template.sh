#!/bin/bash

# Install Jinja2 CLI
pip install -r requirements.txt

# Populate Keycloak realm JSON template with data from ENV file
j2 keycloak-realm.json.j2 keycloak.env

