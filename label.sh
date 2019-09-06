#!/usr/bin/env bash

set -ex

APP_NAME=$1

APP_GUID="$(cf app $APP_NAME --guid)"
APP_URI="/v3/apps/${APP_GUID}"

DROPLET_GUID="$(cf curl "/v3/apps/${APP_GUID}/droplets/current" | jq -r .guid)"
DROPLET_URI="/v3/droplets/${DROPLET_GUID}"

PACKAGE_GUID="$(cf curl "/v3/droplets/${DROPLET_GUID}" | jq -r .links.package.href | xargs basename)"
PACKAGE_URI="/v3/packages/${PACKAGE_GUID}"

COMMIT_SHA="$(git rev-parse --short HEAD)"
REQUEST_BODY="$(jq -nc --arg commit "${COMMIT_SHA}" '{"metadata": { "labels": { "x-app": "reviews" } } }')"

cf curl "${APP_URI}" -X PATCH -d "${REQUEST_BODY}"
cf curl "${PACKAGE_URI}" -X PATCH -d "${REQUEST_BODY}"
cf curl "${DROPLET_URI}" -X PATCH -d "${REQUEST_BODY}"
