#!/usr/bin/env bash
# Verifies/starts local infrastructure, then starts the backend and the web
# frontend in dev/watch mode and verifies the mobile app is ready to run. The
# backend runs directly on the host (not in Docker) so `nest start --watch`
# hot reload works; it talks to this project's private tenant on the shared
# devstack Postgres/Redis (see .env.devstack) and listens on its reserved api
# port. The web frontend (Astro, no backend/database dependency) listens on
# its own reserved port, read from the same env contract.
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

log_info "Ensuring local infrastructure is up"
"${SCRIPT_DIR}/setup.sh"

require_devstack_env
BACKEND_HOST_PORT="${DEVSTACK_PORT_API}"

BACKEND_PID=""
WEB_PID=""
cleanup() {
  if [[ -n "${BACKEND_PID}" ]] && kill -0 "${BACKEND_PID}" 2>/dev/null; then
    log_info "Stopping backend dev process (pid ${BACKEND_PID})"
    kill "${BACKEND_PID}" 2>/dev/null || true
    wait "${BACKEND_PID}" 2>/dev/null || true
  fi
  if [[ -n "${WEB_PID}" ]] && kill -0 "${WEB_PID}" 2>/dev/null; then
    log_info "Stopping web dev process (pid ${WEB_PID})"
    kill "${WEB_PID}" 2>/dev/null || true
    wait "${WEB_PID}" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

log_info "Starting backend in dev/watch mode on 127.0.0.1:${BACKEND_HOST_PORT}"
(
  cd "${REPO_ROOT}/backend"
  export PORT="${BACKEND_HOST_PORT}"
  export POSTGRES_HOST
  export POSTGRES_PORT
  export POSTGRES_USER
  export POSTGRES_PASSWORD
  export POSTGRES_DB
  exec npm run start:dev
) &
BACKEND_PID=$!

log_info "Waiting for backend readiness (GET /api-docs-json)"
if ! wait_for "curl -sf -o /dev/null http://127.0.0.1:${BACKEND_HOST_PORT}/api-docs-json" 60 "backend /api-docs-json"; then
  exit 1
fi
log_info "Backend ready at http://127.0.0.1:${BACKEND_HOST_PORT}"

WEB_HOST_PORT="${DEVSTACK_PORT_WEB}"
log_info "Starting web dev server on 127.0.0.1:${WEB_HOST_PORT}"
(
  cd "${REPO_ROOT}/web"
  exec npm run dev -- --port "${WEB_HOST_PORT}" --host 127.0.0.1
) &
WEB_PID=$!

log_info "Waiting for web readiness (GET /)"
if ! wait_for "curl -sf -o /dev/null http://127.0.0.1:${WEB_HOST_PORT}/" 60 "web /"; then
  exit 1
fi
log_info "Web ready at http://127.0.0.1:${WEB_HOST_PORT}"

FLUTTER="$(flutter_bin)" || {
  log_error "Flutter SDK not found on PATH or at \${FLUTTER_SDK_PATH:-\$HOME/flutter}/bin/flutter. Set FLUTTER_SDK_PATH to override."
  exit 1
}
log_info "Verifying mobile app is ready to run (flutter pub get + flutter test)"
(cd "${REPO_ROOT}/mobile" && "${FLUTTER}" pub get)
(cd "${REPO_ROOT}/mobile" && "${FLUTTER}" test)
log_info "Mobile app verified ready (home_screen_ready_signal). Flutter's own dev server needs a connected device/emulator: run 'cd mobile && ${FLUTTER} run' interactively to launch it."

log_info "Local dev environment is up. Press Ctrl+C to stop the backend and web dev processes."
wait "${BACKEND_PID}" || true
