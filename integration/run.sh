#!/bin/sh
# SPDX-FileCopyrightText: Magenta ApS
#
# SPDX-License-Identifier: MPL-2.0

# We don't lock the terraform workspace to avoid bugs such as
#  - https://github.com/hashicorp/terraform/issues/33217
#  - https://github.com/hashicorp/terraform/issues/33217
#  - https://github.com/hashicorp/terraform/issues/22338
#  - https://github.com/hashicorp/terraform/pull/26924
# This assumes that A) we only run one of these init containers per integration and
# B) that the keycloak client configuration is somewhat static anyway, and
# as such potential conflicts, should they happen, are not too dangerous anyway.
terraform init -backend-config="conn_str=$POSTGRES_CONNECTION_STRING" -backend-config="schema_name=$POSTGRES_SCHEMA_NAME" -lock=false
terraform apply -auto-approve -lock=false
