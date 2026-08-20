#!/usr/bin/env bash
# Starts the backend in local production mode from built artifacts
# (backend/dist), against this project's private tenant on the shared
# devstack Postgres/Redis (see .env.devstack). This is a local
# production-mode smoke path only; staging/production (VPS) deployment stays
# direct-instruction-only and is not performed by this script.
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
install_err_trap

require_cmd node
require_cmd npm
require_cmd curl

SECRET_FILE="${REPO_ROOT}/backend/service-account.json"
if [[ ! -f "${SECRET_FILE}" ]]; then
  log_error "missing required local secret: backend/service-account.json (Firebase Admin credential). The backend cannot boot without it."
  exit 1
fi

if [[ ! -f "${REPO_ROOT}/backend/dist/main.js" ]]; then
  log_info "No build output found; building backend first"
  (cd "${REPO_ROOT}/backend" && npm ci && npm run build)
fi

log_info "Ensuring local infrastructure is up"
"${SCRIPT_DIR}/setup.sh"

require_devstack_env
BACKEND_HOST_PORT="${DEVSTACK_PORT_API}"

BACKEND_PID=""
cleanup() {
  if [[ -n "${BACKEND_PID}" ]] && kill -0 "${BACKEND_PID}" 2>/dev/null; then
    log_info "Stopping backend production process (pid ${BACKEND_PID})"
    kill "${BACKEND_PID}" 2>/dev/null || true
    wait "${BACKEND_PID}" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

log_info "Starting backend in production mode on 127.0.0.1:${BACKEND_HOST_PORT}"
(
  cd "${REPO_ROOT}/backend"
  export NODE_ENV=production
  export PORT="${BACKEND_HOST_PORT}"
  export POSTGRES_HOST
  export POSTGRES_PORT
  export POSTGRES_USER
  export POSTGRES_PASSWORD
  export POSTGRES_DB
  exec npm run start:prod
) &
BACKEND_PID=$!

log_info "Waiting for backend readiness (GET /api-docs-json)"
if ! wait_for "curl -sf -o /dev/null http://127.0.0.1:${BACKEND_HOST_PORT}/api-docs-json" 60 "backend /api-docs-json"; then
  exit 1
fi
log_info "Backend ready in production mode at http://127.0.0.1:${BACKEND_HOST_PORT}"

log_info "Local production environment is up. Press Ctrl+C to stop."
wait "${BACKEND_PID}" || true
