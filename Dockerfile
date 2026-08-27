# SPDX-FileCopyrightText: Magenta ApS
#
# SPDX-License-Identifier: MPL-2.0
FROM alpine:3.22@sha256:14358309a308569c32bdc37e2e0e9694be33a9d99e68afb0f5ff33cc1f695dce

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Install OpenTofu from the release apk (verified by checksum), as the
# official images deliberately fail when used as a base image
# (opentofu/opentofu#1931).
ARG TOFU_VERSION=1.10.10
ARG TOFU_APK_SHA256=3e6d7920294e00cab1fc4cc8ef01b9f27df21e1e94f70752666d64161087e0f8
RUN apk add --no-cache curl \
 && curl -fsSLo tofu.apk https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_amd64.apk \
 && echo "${TOFU_APK_SHA256}  tofu.apk" | sha256sum -c - \
 && apk add --no-cache --allow-untrusted tofu.apk \
 && rm tofu.apk

RUN apk add --no-cache python3 py3-pip
RUN pip install --no-cache-dir --break-system-packages click pydantic[email]==1.10.12

WORKDIR /app

COPY keycloak.tf .
COPY .terraform.lock.hcl .
RUN tofu init -backend=false

COPY main.py .
COPY run.sh .
ENTRYPOINT [ "sh", "run.sh" ]
