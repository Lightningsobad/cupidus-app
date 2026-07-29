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

GENERATED_PUBSPEC="${GENERATED_DIR}/pubspec.yaml"
APP_PUBSPEC="${MOBILE_DIR}/pubspec.yaml"

echo "Normalizing generated package SDK floor to match ${APP_PUBSPEC}"
APP_SDK_CONSTRAINT="$(awk '
  /^environment:/ { in_env=1; next }
  in_env && /^[^[:space:]]/ { in_env=0 }
  in_env && /sdk:/ {
    sub(/^[[:space:]]*sdk:[[:space:]]*/, "");
    print;
    exit
  }
' "${APP_PUBSPEC}")"

if [[ -z "${APP_SDK_CONSTRAINT}" ]]; then
  echo "ERROR: could not read 'sdk:' constraint from the environment: block of ${APP_PUBSPEC}" >&2
  exit 1
fi

if ! awk '
  /^environment:/ { in_env=1; next }
  in_env && /^[^[:space:]]/ { in_env=0 }
  in_env && /sdk:/ { found=1 }
  END { exit(found ? 0 : 1) }
' "${GENERATED_PUBSPEC}"; then
  echo "ERROR: expected 'sdk:' line not found in the environment: block of ${GENERATED_PUBSPEC}; the generator template may have changed" >&2
  exit 1
fi

# Idempotent: rewrites the sdk: value on every run regardless of its
# current contents, so re-running the generator never drifts (AC3).
TMP_PUBSPEC="$(mktemp)"
awk -v sdk="${APP_SDK_CONSTRAINT}" '
  /^environment:/ { in_env=1; print; next }
  in_env && /^[^[:space:]]/ { in_env=0 }
  in_env && /sdk:/ {
    sub(/sdk:.*/, "sdk: " sdk);
    print;
    next
  }
  { print }
' "${GENERATED_PUBSPEC}" > "${TMP_PUBSPEC}"
mv "${TMP_PUBSPEC}" "${GENERATED_PUBSPEC}"
echo "Generated package sdk floor set to: ${APP_SDK_CONSTRAINT}"

echo "Running build_runner in the generated package"
(
  cd "${GENERATED_DIR}"
  dart pub get
  dart run build_runner build --delete-conflicting-outputs
)

echo "Generated package ready at ${GENERATED_DIR}"
