#!/usr/bin/env bash
# STORY-001: flip the existing api.cupidus.app DNS record from DNS-only
# (grey cloud) to Cloudflare-proxied (orange cloud).
#
# Run this ONLY after verifying the origin already serves a publicly trusted
# certificate for api.cupidus.app (see verify-api-cert-issued.sh /
# coding-plan/phase-P1-api-hostname-tls-edge.md task 9). Flipping proxied
# before the origin certificate exists breaks nothing by itself, but running
# set-zone-ssl-full-strict.sh before the origin certificate exists produces a
# hard 526 — keep these steps in order.
#
# Idempotent: exits 0 with a no-op message if the record is already proxied.
# Fails closed if the record does not exist yet (run
# create-api-dns-record.sh first) or if more than one record is found.
#
# Required env:
#   CLOUDFLARE_API_TOKEN  - scoped API token with Zone:DNS:Edit on the
#                            cupidus.app zone
#   CLOUDFLARE_ZONE_ID    - the cupidus.app zone id

set -euo pipefail

RECORD_NAME="api.cupidus.app"
API_BASE="https://api.cloudflare.com/client/v4"

log() { printf '[set-api-dns-proxied] %s\n' "$*"; }
die() { printf '[set-api-dns-proxied] ERROR: %s\n' "$*" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

require_cmd curl
require_cmd jq

: "${CLOUDFLARE_API_TOKEN:?CLOUDFLARE_API_TOKEN must be set}"
: "${CLOUDFLARE_ZONE_ID:?CLOUDFLARE_ZONE_ID must be set}"

log "looking up existing record for ${RECORD_NAME}"
list_response="$(curl -sS -X GET \
  "${API_BASE}/zones/${CLOUDFLARE_ZONE_ID}/dns_records?name=${RECORD_NAME}" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json")"

list_success="$(printf '%s' "${list_response}" | jq -r '.success')"
if [[ "${list_success}" != "true" ]]; then
  die "record lookup failed: $(printf '%s' "${list_response}" | jq -c '.errors')"
fi

existing_count="$(printf '%s' "${list_response}" | jq -r '.result | length')"
[[ "${existing_count}" -eq 1 ]] || die "expected exactly one ${RECORD_NAME} record, found ${existing_count}; resolve manually before proxying"

existing_record="$(printf '%s' "${list_response}" | jq -c '.result[0]')"
existing_id="$(printf '%s' "${existing_record}" | jq -r '.id')"
existing_proxied="$(printf '%s' "${existing_record}" | jq -r '.proxied')"

if [[ "${existing_proxied}" == "true" ]]; then
  log "record already proxied; no-op success"
  log "record: ${existing_record}"
  exit 0
fi

log "flipping record ${existing_id} to proxied"
update_response="$(curl -sS -X PATCH \
  "${API_BASE}/zones/${CLOUDFLARE_ZONE_ID}/dns_records/${existing_id}" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  --data '{"proxied": true}')"

update_success="$(printf '%s' "${update_response}" | jq -r '.success')"
if [[ "${update_success}" != "true" ]]; then
  die "proxy flip failed: $(printf '%s' "${update_response}" | jq -c '.errors')"
fi

log "record now proxied: $(printf '%s' "${update_response}" | jq -c '.result')"
