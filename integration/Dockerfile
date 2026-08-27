# SPDX-FileCopyrightText: Magenta ApS
#
# SPDX-License-Identifier: MPL-2.0
FROM alpine:3.22@sha256:14358309a308569c32bdc37e2e0e9694be33a9d99e68afb0f5ff33cc1f695dce

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

ARG TOFU_VERSION=1.12.6
ARG TOFU_APK_SHA256=d63332b4e09cb142dbfb81123bf0156ede8c6a3449ce52fdcd187e53dedfe37d
RUN apk add --no-cache curl \
 && curl --fail --silent --show-error --location --output tofu.apk https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_amd64.apk \
 && echo "${TOFU_APK_SHA256}  tofu.apk" | sha256sum -c - \
 && apk add --no-cache --allow-untrusted tofu.apk \
 && rm tofu.apk

COPY main.tf .
COPY .terraform.lock.hcl .
COPY run.sh .
RUN tofu init --backend=false
ENTRYPOINT [ "sh", "run.sh" ]
