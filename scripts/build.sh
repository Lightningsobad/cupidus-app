#!/usr/bin/env bash
# Installs dependencies and builds every project component: the NestJS
# backend and the Flutter mobile app.
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
install_err_trap

require_cmd node
require_cmd npm

log_info "Installing backend dependencies (npm ci)"
(cd "${REPO_ROOT}/backend" && npm ci)

log_info "Building backend (nest build)"
(cd "${REPO_ROOT}/backend" && npm run build)

FLUTTER="$(flutter_bin)" || {
  log_error "Flutter SDK not found on PATH or at \${FLUTTER_SDK_PATH:-\$HOME/flutter}/bin/flutter. Set FLUTTER_SDK_PATH to override."
  exit 1
}
log_info "Using Flutter at ${FLUTTER}"

log_info "Installing mobile dependencies (flutter pub get)"
(cd "${REPO_ROOT}/mobile" && "${FLUTTER}" pub get)

log_info "Building mobile app (flutter build apk --debug)"
(cd "${REPO_ROOT}/mobile" && "${FLUTTER}" build apk --debug)

log_info "Build complete: backend/dist, mobile/build/app/outputs/flutter-apk"
