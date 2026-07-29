#!/usr/bin/env bash
# Verifies/starts local infrastructure, then starts the backend in dev/watch
# mode and verifies the mobile app is ready to run. The backend runs
# directly on the host (not in Docker) so `nest start --watch` hot reload
# works; it talks to the Compose-managed Postgres/Redis over their resolved
# loopback host ports.
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

POSTGRES_HOST_PORT="$(env_get POSTGRES_HOST_PORT 15432)"
REDIS_HOST_PORT="$(env_get REDIS_HOST_PORT 16379)"
BACKEND_HOST_PORT="$(env_get BACKEND_HOST_PORT 3000)"
POSTGRES_USER="$(env_get POSTGRES_USER postgres)"
POSTGRES_PASSWORD="$(env_get POSTGRES_PASSWORD password)"
POSTGRES_DB="$(env_get POSTGRES_DB cupid)"

BACKEND_PID=""
cleanup() {
  if [[ -n "${BACKEND_PID}" ]] && kill -0 "${BACKEND_PID}" 2>/dev/null; then
    log_info "Stopping backend dev process (pid ${BACKEND_PID})"
    kill "${BACKEND_PID}" 2>/dev/null || true
    wait "${BACKEND_PID}" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

log_info "Starting backend in dev/watch mode on 127.0.0.1:${BACKEND_HOST_PORT}"
(
  cd "${REPO_ROOT}/backend"
  export PORT="${BACKEND_HOST_PORT}"
  export POSTGRES_HOST=127.0.0.1
  export POSTGRES_PORT="${POSTGRES_HOST_PORT}"
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

FLUTTER="$(flutter_bin)" || {
  log_error "Flutter SDK not found on PATH or at \${FLUTTER_SDK_PATH:-\$HOME/flutter}/bin/flutter. Set FLUTTER_SDK_PATH to override."
  exit 1
}
log_info "Verifying mobile app is ready to run (flutter pub get + flutter test)"
(cd "${REPO_ROOT}/mobile" && "${FLUTTER}" pub get)
(cd "${REPO_ROOT}/mobile" && "${FLUTTER}" test)
log_info "Mobile app verified ready (home_screen_ready_signal). Flutter's own dev server needs a connected device/emulator: run 'cd mobile && ${FLUTTER} run' interactively to launch it."

log_info "Local dev environment is up. Press Ctrl+C to stop the backend dev process."
wait "${BACKEND_PID}" || true
