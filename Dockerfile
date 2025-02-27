# SPDX-FileCopyrightText: Magenta ApS
#
# SPDX-License-Identifier: MPL-2.0
FROM hashicorp/terraform:1.11.0@sha256:ece24a48464368a6b59aeb949ccaefd415d0c9c7bf8db1011db5701a83d3d26e

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
