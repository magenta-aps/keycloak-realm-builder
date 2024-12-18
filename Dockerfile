# SPDX-FileCopyrightText: Magenta ApS
#
# SPDX-License-Identifier: MPL-2.0
FROM hashicorp/terraform:1.10.3@sha256:460267841b38628514b75c6b0eb1cebb2d2fb5d6b596087a9c277551c801e5f1

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
