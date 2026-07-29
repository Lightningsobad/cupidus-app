#!/usr/bin/env bash
# Regenerates the cupid_api package from the vendored OpenAPI spec. Offline
# and deterministic: never talks to a live backend (ADR-010c). Whole-directory
# replace on every run (ADR-010b) — never hand-edit files under
# mobile/openapi/cupid_api/.
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOBILE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
GENERATED_DIR="${MOBILE_DIR}/openapi/cupid_api"

cd "${MOBILE_DIR}"

echo "Removing existing generated package at ${GENERATED_DIR}"
rm -rf "${GENERATED_DIR}"

echo "Running openapi-generator-cli (version pinned in openapitools.json)"
npx @openapitools/openapi-generator-cli generate -c openapi/openapi-generator-config.yaml

echo "Running build_runner in the generated package"
(
  cd "${GENERATED_DIR}"
  dart pub get
  dart run build_runner build --delete-conflicting-outputs
)

echo "Generated package ready at ${GENERATED_DIR}"
