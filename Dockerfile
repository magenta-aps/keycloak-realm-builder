# SPDX-FileCopyrightText: Magenta ApS
#
# SPDX-License-Identifier: MPL-2.0
FROM hashicorp/terraform:1.11.1@sha256:42e70cc10f0d6ae50807e4302ff512986f48dbd49616f629d6978912bfabae70

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
