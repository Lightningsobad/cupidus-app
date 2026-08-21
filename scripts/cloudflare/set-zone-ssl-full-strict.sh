#!/usr/bin/env bash
# STORY-001: raise the cupidus.app zone SSL/TLS mode to Full (strict).
#
# Run this LAST, only after:
#   1. create-api-dns-record.sh created the DNS-only record and
#      verify-api-cert-issued.sh confirmed the origin serves a publicly
#      trusted certificate for api.cupidus.app, and
#   2. set-api-dns-proxied.sh flipped the record to proxied and
#      https://api.cupidus.app was re-verified through the Cloudflare edge.
#
# Raising this mode before the origin has a valid certificate breaks every
# request through this zone with a hard 526, not just api.cupidus.app —
# never run this step out of order.
#
# Idempotent: exits 0 with a no-op message if the zone is already Full
# (strict).
#
# Required env:
#   CLOUDFLARE_API_TOKEN  - scoped API token with Zone:Edit (or Zone:SSL and
#                            Certificates:Edit) on the cupidus.app zone
#   CLOUDFLARE_ZONE_ID    - the cupidus.app zone id

set -euo pipefail

API_BASE="https://api.cloudflare.com/client/v4"

log() { printf '[set-zone-ssl-full-strict] %s\n' "$*"; }
die() { printf '[set-zone-ssl-full-strict] ERROR: %s\n' "$*" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

require_cmd curl
require_cmd jq

: "${CLOUDFLARE_API_TOKEN:?CLOUDFLARE_API_TOKEN must be set}"
: "${CLOUDFLARE_ZONE_ID:?CLOUDFLARE_ZONE_ID must be set}"

log "reading current zone SSL mode"
current_response="$(curl -sS -X GET \
  "${API_BASE}/zones/${CLOUDFLARE_ZONE_ID}/settings/ssl" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json")"

current_success="$(printf '%s' "${current_response}" | jq -r '.success')"
if [[ "${current_success}" != "true" ]]; then
  die "ssl mode lookup failed: $(printf '%s' "${current_response}" | jq -c '.errors')"
fi

current_mode="$(printf '%s' "${current_response}" | jq -r '.result.value')"

if [[ "${current_mode}" == "strict" ]]; then
  log "zone already Full (strict); no-op success"
  exit 0
fi

log "raising zone SSL mode from ${current_mode} to strict (Full strict)"
update_response="$(curl -sS -X PATCH \
  "${API_BASE}/zones/${CLOUDFLARE_ZONE_ID}/settings/ssl" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  --data '{"value": "strict"}')"

update_success="$(printf '%s' "${update_response}" | jq -r '.success')"
if [[ "${update_success}" != "true" ]]; then
  die "ssl mode update failed: $(printf '%s' "${update_response}" | jq -c '.errors')"
fi

log "zone SSL mode now: $(printf '%s' "${update_response}" | jq -r '.result.value')"
