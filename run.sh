#!/bin/sh
# SPDX-FileCopyrightText: Magenta ApS
#
# SPDX-License-Identifier: MPL-2.0

tofu init -backend-config="conn_str=$POSTGRES_CONNECTION_STRING"

python3 main.py > arguments.json
cat arguments.json

tofu apply -var-file arguments.json -auto-approve
