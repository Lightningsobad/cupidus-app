#!/usr/bin/env bash
# Shared helpers for repo-root local environment scripts.
# Sourced by scripts/setup.sh, build.sh, start-dev.sh, start-prod.sh.

SCRIPT_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_LIB_DIR}/../.." && pwd)"
ENV_FILE="${REPO_ROOT}/.env"
COMPOSE_FILE="${REPO_ROOT}/backend/docker-compose.yml"

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

# env_get KEY [DEFAULT] - reads KEY from the project-local .env file, falling
# back to DEFAULT when the file or key does not exist.
env_get() {
  local key="$1" default="${2:-}"
  if [[ -f "${ENV_FILE}" ]]; then
    local line
    line="$(grep -E "^${key}=" "${ENV_FILE}" 2>/dev/null | tail -n1 || true)"
    if [[ -n "${line}" ]]; then
      printf '%s' "${line#*=}"
      return 0
    fi
  fi
  printf '%s' "${default}"
}

# env_set KEY VALUE - idempotently upserts KEY=VALUE in the project-local
# .env file (created if missing). Safe to call repeatedly.
env_set() {
  local key="$1" value="$2"
  touch "${ENV_FILE}"
  if grep -qE "^${key}=" "${ENV_FILE}" 2>/dev/null; then
    local tmp
    tmp="$(mktemp)"
    awk -F= -v k="${key}" -v v="${value}" 'BEGIN{OFS="="} $1==k{$0=k"="v} {print}' "${ENV_FILE}" > "${tmp}"
    mv "${tmp}" "${ENV_FILE}"
  else
    printf '%s=%s\n' "${key}" "${value}" >> "${ENV_FILE}"
  fi
}

# port_is_free PORT - true when nothing on 127.0.0.1:PORT is accepting
# connections.
port_is_free() {
  local port="$1"
  ! (exec 3<>"/dev/tcp/127.0.0.1/${port}") 2>/dev/null
}

# find_free_port START - returns the first free port at or above START.
find_free_port() {
  local port="$1"
  while ! port_is_free "${port}"; do
    port=$((port + 1))
  done
  printf '%s' "${port}"
}

# compose_project_name - derives a Compose-safe project name from the repo
# directory name, e.g. "cupid-apps".
compose_project_name() {
  local name
  name="$(basename "${REPO_ROOT}")"
  name="$(printf '%s' "${name}" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-')"
  printf '%s' "${name}"
}

# dc [compose args...] - invokes docker compose against
# backend/docker-compose.yml with the resolved project-local env values
# exported, so it is safe to run from any working directory.
dc() {
  COMPOSE_PROJECT_NAME="$(env_get COMPOSE_PROJECT_NAME "$(compose_project_name)")" \
  POSTGRES_USER="$(env_get POSTGRES_USER postgres)" \
  POSTGRES_PASSWORD="$(env_get POSTGRES_PASSWORD password)" \
  POSTGRES_DB="$(env_get POSTGRES_DB cupid)" \
  POSTGRES_HOST_PORT="$(env_get POSTGRES_HOST_PORT 15432)" \
  REDIS_HOST_PORT="$(env_get REDIS_HOST_PORT 16379)" \
  BACKEND_HOST_PORT="$(env_get BACKEND_HOST_PORT 3000)" \
  docker compose -f "${COMPOSE_FILE}" "$@"
}

# is_service_running SERVICE - true when the named Compose service already
# has a running container in our project.
is_service_running() {
  dc ps --status running --services 2>/dev/null | grep -qx "$1"
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
