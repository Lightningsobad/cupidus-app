#!/usr/bin/env bash
# Shared helpers for repo-root local environment scripts.
# Sourced by scripts/setup.sh, build.sh, start-dev.sh, start-prod.sh.

SCRIPT_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_LIB_DIR}/../.." && pwd)"
DEVSTACK_ENV_FILE="${REPO_ROOT}/.env.devstack"

log_info() {
  printf '[%s] %s\n' "$(basename "${0}")" "$*"
}

log_error() {
  printf '[%s] ERROR: %s\n' "$(basename "${0}")" "$*" >&2
}

install_err_trap() {
  trap 'log_error "line ${LINENO}: command \"${BASH_COMMAND}\" failed"' ERR
}

require_cmd() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    log_error "required command not found: ${cmd}"
    exit 1
  fi
}

# devstack_project_name - derives the project name devstack itself resolves
# from the repo directory name, e.g. "cupid-apps". Needed because
# `devstack port check` takes --project rather than a path.
devstack_project_name() {
  local name
  name="$(basename "${REPO_ROOT}")"
  name="$(printf '%s' "${name}" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-')"
  printf '%s' "${name}"
}

# require_devstack_env - ensures this project is adopted onto the shared
# devstack stack and loads its generated env contract (POSTGRES_*, REDIS_*,
# DATABASE_URL, DEVSTACK_PORT_*, ...) into the current shell. Local
# dependency services and application ports always come from this contract,
# never from a repo-local container or a scanned free port.
require_devstack_env() {
  require_cmd devstack
  if [[ ! -f "${DEVSTACK_ENV_FILE}" ]]; then
    log_error "missing ${DEVSTACK_ENV_FILE}; run 'devstack use' (see scripts/setup.sh) first"
    exit 1
  fi
  set -a
  # shellcheck source=/dev/null
  source "${DEVSTACK_ENV_FILE}"
  set +a
}

# flutter_bin - resolves an absolute path to the flutter binary. Prefers
# PATH, then falls back to ${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter,
# since the Flutter SDK is not guaranteed to be on PATH on every dev machine.
flutter_bin() {
  if command -v flutter >/dev/null 2>&1; then
    command -v flutter
    return 0
  fi
  local candidate="${FLUTTER_SDK_PATH:-${HOME}/flutter}/bin/flutter"
  if [[ -x "${candidate}" ]]; then
    printf '%s' "${candidate}"
    return 0
  fi
  return 1
}

# android_sdk_root - resolves an absolute path to the Android SDK root.
# Prefers ANDROID_HOME, then ANDROID_SDK_ROOT, then the per-OS default
# install locations, since neither variable is guaranteed to be exported on
# every dev machine.
android_sdk_root() {
  local candidate
  for candidate in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" \
    "${HOME}/Library/Android/sdk" "${HOME}/Android/Sdk"; do
    if [[ -n "${candidate}" && -d "${candidate}" ]]; then
      printf '%s' "${candidate}"
      return 0
    fi
  done
  return 1
}

# android_tool NAME - resolves an absolute path to an Android SDK tool such
# as adb, emulator, or avdmanager. Prefers PATH, then the resolved SDK root,
# because platform-tools is commonly on PATH while emulator/ and
# cmdline-tools/ usually are not.
android_tool() {
  local name="$1" root candidate
  if command -v "${name}" >/dev/null 2>&1; then
    command -v "${name}"
    return 0
  fi
  root="$(android_sdk_root)" || return 1
  for candidate in \
    "${root}/platform-tools/${name}" \
    "${root}/emulator/${name}" \
    "${root}/cmdline-tools/latest/bin/${name}" \
    "${root}/tools/bin/${name}"; do
    if [[ -x "${candidate}" ]]; then
      printf '%s' "${candidate}"
      return 0
    fi
  done
  return 1
}

# wait_for CHECK_CMD TIMEOUT_SECS DESCRIPTION - polls CHECK_CMD (a string
# eval'd each second) until it exits 0 or TIMEOUT_SECS elapses.
wait_for() {
  local check_cmd="$1" timeout_secs="$2" description="$3"
  local waited=0
  while ! eval "${check_cmd}" >/dev/null 2>&1; do
    if (( waited >= timeout_secs )); then
      log_error "timed out after ${timeout_secs}s waiting for: ${description}"
      return 1
    fi
    sleep 1
    waited=$((waited + 1))
  done
  return 0
}
