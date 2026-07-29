#!/usr/bin/env bash
# Fetches the vendored OpenAPI spec from a locally booted backend and writes
# it to mobile/openapi/cupid-api.json. Run this deliberately, after the
# backend is up (see repo-root scripts/start-dev.sh or scripts/setup.sh +
# `npm run start:dev` in backend/). Codegen itself (generate_api_client.sh)
# never talks to a live server; only this fetch step does (ADR-010c).
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOBILE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_FILE="${MOBILE_DIR}/openapi/cupid-api.json"

BACKEND_URL="${CUPID_BACKEND_URL:-http://127.0.0.1:${BACKEND_HOST_PORT:-3000}}"

echo "Fetching OpenAPI spec from ${BACKEND_URL}/api-docs-json"
curl -fsS "${BACKEND_URL}/api-docs-json" | jq . > "${OUTPUT_FILE}"
echo "Wrote $(wc -l < "${OUTPUT_FILE}" | tr -d ' ') lines to ${OUTPUT_FILE}"
