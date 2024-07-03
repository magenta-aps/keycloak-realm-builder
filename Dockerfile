# SPDX-FileCopyrightText: Magenta ApS
#
# SPDX-License-Identifier: MPL-2.0
FROM hashicorp/terraform:1.9.1@sha256:0b7aa0ef4da09938e38fd8182f9828e1af6f242c28f5e30339790f658ee8f8fd

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

RUN apk add python3 py3-pip
RUN pip install --no-cache-dir click pydantic[email]==1.10.12

WORKDIR /app

COPY keycloak.tf .
COPY .terraform.lock.hcl .
RUN terraform init -backend=false

COPY main.py .
COPY run.sh .
ENTRYPOINT [ "sh", "run.sh" ]
