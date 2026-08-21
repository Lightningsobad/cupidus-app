#!/usr/bin/env bash
# STORY-001: idempotent, fail-closed Cloudflare DNS provisioning for
# api.cupidus.app -> the production VPS (root@84.247.140.178).
#
# Enumerates existing `cupidus.app` DNS records first. If a record named
# "api" already exists and does NOT already match the expected
# type/content/proxied target, this script exits non-zero WITHOUT mutating
# anything and prints the conflicting record verbatim (AC1). If a matching
# record already exists, re-running is a no-op success. Otherwise it creates
# a new A record.
#
# The record is created DNS-only (grey cloud, proxied=false) on purpose: the
# stock Caddy binary on the VPS has no DNS-01 ACME plugin, so the first
# certificate issuance must reach the origin directly via HTTP-01. Flip to
# proxied only after `verify-api-cert-issued.sh` confirms a publicly trusted
# certificate is being served — see set-api-dns-proxied.sh.
#
# Required env:
#   CLOUDFLARE_API_TOKEN  - scoped API token with Zone:DNS:Edit on the
#                            cupidus.app zone
#   CLOUDFLARE_ZONE_ID    - the cupidus.app zone id
#
# No dashboard steps: this is the only supported way to create this record.

set -euo pipefail

RECORD_NAME="api.cupidus.app"
RECORD_TYPE="A"
RECORD_CONTENT="84.247.140.178"
RECORD_PROXIED="false"
API_BASE="https://api.cloudflare.com/client/v4"

log() { printf '[create-api-dns-record] %s\n' "$*"; }
die() { printf '[create-api-dns-record] ERROR: %s\n' "$*" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

require_cmd curl
require_cmd jq

: "${CLOUDFLARE_API_TOKEN:?CLOUDFLARE_API_TOKEN must be set}"
: "${CLOUDFLARE_ZONE_ID:?CLOUDFLARE_ZONE_ID must be set}"

log "enumerating existing DNS records named ${RECORD_NAME} on zone ${CLOUDFLARE_ZONE_ID}"
list_response="$(curl -sS -X GET \
  "${API_BASE}/zones/${CLOUDFLARE_ZONE_ID}/dns_records?name=${RECORD_NAME}" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json")"

list_success="$(printf '%s' "${list_response}" | jq -r '.success')"
if [[ "${list_success}" != "true" ]]; then
  die "record lookup failed: $(printf '%s' "${list_response}" | jq -c '.errors')"
fi

existing_count="$(printf '%s' "${list_response}" | jq -r '.result | length')"

if [[ "${existing_count}" -gt 0 ]]; then
  existing_record="$(printf '%s' "${list_response}" | jq -c '.result[0]')"
  existing_type="$(printf '%s' "${existing_record}" | jq -r '.type')"
  existing_content="$(printf '%s' "${existing_record}" | jq -r '.content')"
  existing_proxied="$(printf '%s' "${existing_record}" | jq -r '.proxied')"
  existing_id="$(printf '%s' "${existing_record}" | jq -r '.id')"

  if [[ "${existing_type}" == "${RECORD_TYPE}" \
     && "${existing_content}" == "${RECORD_CONTENT}" \
     && "${existing_proxied}" == "${RECORD_PROXIED}" ]]; then
    log "existing record already matches expected target; no-op success"
    log "record: ${existing_record}"
    exit 0
  fi

  die "conflicting record for ${RECORD_NAME} already exists, refusing to mutate: ${existing_record}"
fi

log "no existing record found; creating DNS-only (grey cloud) ${RECORD_TYPE} record -> ${RECORD_CONTENT}"
create_response="$(curl -sS -X POST \
  "${API_BASE}/zones/${CLOUDFLARE_ZONE_ID}/dns_records" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  --data "$(jq -n \
    --arg type "${RECORD_TYPE}" \
    --arg name "${RECORD_NAME}" \
    --arg content "${RECORD_CONTENT}" \
    '{type: $type, name: $name, content: $content, proxied: false, ttl: 300}')")"

create_success="$(printf '%s' "${create_response}" | jq -r '.success')"
if [[ "${create_success}" != "true" ]]; then
  die "record creation failed: $(printf '%s' "${create_response}" | jq -c '.errors')"
fi

log "created record: $(printf '%s' "${create_response}" | jq -c '.result')"
