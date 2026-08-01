#!/usr/bin/env bash
# Launches the Flutter mobile app on an Android emulator or an iOS Simulator.
# Boots a device when none is already running, waits for Flutter to see it,
# then hands control to a foreground `flutter run` session.
#
# This is an interactive, human-driven path. `flutter run` owns the terminal
# (hot reload, 'q' to quit), so this script is deliberately NOT wired into
# scripts/start-dev.sh's headless readiness gate and is not a CI entrypoint.
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
install_err_trap

BOOT_TIMEOUT_SECS=180
FLUTTER_VISIBLE_TIMEOUT_SECS=180

usage() {
  cat <<'EOF'
Usage: scripts/run-mobile.sh <android|ios> [options] [-- <flutter run args>...]

Platforms:
  android   Boot an Android emulator (AVD) if no device is online, then
            `flutter run -d <adb serial>`.
  ios       Boot an iOS Simulator if none is booted, then
            `flutter run -d <simulator udid>`. macOS only.

Options:
  --avd <name>   Android only. Boot this AVD instead of the first one
                 reported by `emulator -list-avds`.
  --udid <id>    Use this exact device and skip device selection. An adb
                 serial (e.g. emulator-5554) for android, a simulator UDID
                 for ios.
  -h, --help     Show this help.

Everything after `--` is forwarded to `flutter run`, for example:
  scripts/run-mobile.sh android -- --dart-define=CUPID_API_BASE_URL=http://10.0.2.2:3000
EOF
}

PLATFORM=""
AVD_NAME=""
DEVICE_ID=""
FLUTTER_ARGS=()

while (( $# > 0 )); do
  case "$1" in
    android|ios)
      if [[ -n "${PLATFORM}" ]]; then
        log_error "BAD_USAGE: platform given twice ('${PLATFORM}' and '$1')"
        exit 2
      fi
      PLATFORM="$1"
      shift
      ;;
    --avd)
      if [[ $# -lt 2 || -z "$2" ]]; then
        log_error "BAD_USAGE: --avd requires an AVD name"
        exit 2
      fi
      AVD_NAME="$2"
      shift 2
      ;;
    --udid)
      if [[ $# -lt 2 || -z "$2" ]]; then
        log_error "BAD_USAGE: --udid requires a device id"
        exit 2
      fi
      DEVICE_ID="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      FLUTTER_ARGS=("$@")
      break
      ;;
    *)
      log_error "BAD_USAGE: unknown argument '$1'"
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "${PLATFORM}" ]]; then
  log_error "BAD_USAGE: missing platform (android|ios)"
  usage >&2
  exit 2
fi

if [[ -n "${AVD_NAME}" && "${PLATFORM}" != "android" ]]; then
  log_error "BAD_USAGE: --avd applies to the android platform only"
  exit 2
fi

FLUTTER="$(flutter_bin)" || {
  log_error "FLUTTER_SDK_NOT_FOUND: Flutter SDK not found on PATH or at \${FLUTTER_SDK_PATH:-\$HOME/flutter}/bin/flutter. Set FLUTTER_SDK_PATH to override."
  exit 1
}
log_info "Using Flutter at ${FLUTTER}"

# flutter_sees_device DEVICE_ID - true once `flutter devices` reports the id.
flutter_sees_device() {
  "${FLUTTER}" devices --machine 2>/dev/null | grep -qF "\"$1\""
}

wait_until_flutter_sees_device() {
  log_info "Waiting up to ${FLUTTER_VISIBLE_TIMEOUT_SECS}s for 'flutter devices' to report ${DEVICE_ID}"
  if ! wait_for "flutter_sees_device '${DEVICE_ID}'" "${FLUTTER_VISIBLE_TIMEOUT_SECS}" "flutter devices to list ${DEVICE_ID}"; then
    log_error "DEVICE_NOT_VISIBLE_TO_FLUTTER: ${DEVICE_ID} never appeared in 'flutter devices'. Run '${FLUTTER} doctor' to check the toolchain."
    exit 1
  fi
}

# ---------------------------------------------------------------- android ---

ADB=""

# first_ready_adb_device - prints the serial of the first adb device in the
# 'device' state (booted and authorized), or nothing.
first_ready_adb_device() {
  "${ADB}" devices | awk '$2 == "device" { print $1; exit }'
}

adb_boot_completed() {
  local serial
  serial="$(first_ready_adb_device)"
  [[ -n "${serial}" ]] || return 1
  [[ "$("${ADB}" -s "${serial}" shell getprop sys.boot_completed 2>/dev/null | tr -d '[:space:]')" == "1" ]]
}

resolve_android_device() {
  ADB="$(android_tool adb)" || {
    log_error "ANDROID_SDK_NOT_FOUND: adb not found on PATH, under \$ANDROID_HOME/\$ANDROID_SDK_ROOT, or at ~/Library/Android/sdk. Install the Android SDK platform-tools or export ANDROID_HOME."
    exit 1
  }
  log_info "Using adb at ${ADB}"

  if [[ -n "${DEVICE_ID}" ]]; then
    log_info "Using requested Android device ${DEVICE_ID}"
    return 0
  fi

  DEVICE_ID="$(first_ready_adb_device)"
  if [[ -n "${DEVICE_ID}" ]]; then
    log_info "Reusing Android device already online: ${DEVICE_ID}"
    return 0
  fi

  local emulator
  emulator="$(android_tool emulator)" || {
    log_error "ANDROID_EMULATOR_NOT_FOUND: no device is online and the 'emulator' binary was not found under the Android SDK. Install the SDK 'emulator' package, or start a device yourself and re-run."
    exit 1
  }

  local avds
  avds="$("${emulator}" -list-avds)"
  if [[ -z "${avds}" ]]; then
    log_error "ANDROID_NO_AVD: no Android Virtual Device exists ('emulator -list-avds' is empty). Create one in Android Studio's Device Manager or with avdmanager."
    exit 1
  fi

  if [[ -z "${AVD_NAME}" ]]; then
    AVD_NAME="$(printf '%s\n' "${avds}" | head -n1)"
  elif ! printf '%s\n' "${avds}" | grep -qxF "${AVD_NAME}"; then
    log_error "ANDROID_UNKNOWN_AVD: no AVD named '${AVD_NAME}'. Available: $(printf '%s' "${avds}" | tr '\n' ' ')"
    exit 1
  fi

  local emulator_log="${TMPDIR:-/tmp}/cupid-emulator-${AVD_NAME}.log"
  log_info "Booting Android emulator AVD '${AVD_NAME}' (log: ${emulator_log})"
  nohup "${emulator}" -avd "${AVD_NAME}" >"${emulator_log}" 2>&1 &

  log_info "Waiting up to ${BOOT_TIMEOUT_SECS}s for the emulator to finish booting"
  if ! wait_for adb_boot_completed "${BOOT_TIMEOUT_SECS}" "Android emulator '${AVD_NAME}' boot"; then
    log_error "ANDROID_EMULATOR_BOOT_TIMEOUT: AVD '${AVD_NAME}' did not report sys.boot_completed=1 within ${BOOT_TIMEOUT_SECS}s. See ${emulator_log}."
    exit 1
  fi

  DEVICE_ID="$(first_ready_adb_device)"
  log_info "Android emulator online as ${DEVICE_ID}"
}

# -------------------------------------------------------------------- ios ---

booted_simulator_udid() {
  xcrun simctl list devices available | awk -F '[()]' '/\(Booted\)/ { print $2; exit }'
}

first_available_simulator_udid() {
  local udid
  udid="$(xcrun simctl list devices available | awk -F '[()]' '/^[[:space:]]+iPhone/ { print $2; exit }')"
  if [[ -z "${udid}" ]]; then
    udid="$(xcrun simctl list devices available | awk -F '[()]' '/^[[:space:]]+[A-Za-z]/ { print $2; exit }')"
  fi
  printf '%s' "${udid}"
}

simulator_is_booted() {
  xcrun simctl list devices | awk -F '[()]' -v udid="$1" \
    '$2 == udid && /\(Booted\)/ { found = 1 } END { exit found ? 0 : 1 }'
}

resolve_ios_device() {
  local host_os
  host_os="$(uname -s)"
  if [[ "${host_os}" != "Darwin" ]]; then
    log_error "IOS_UNSUPPORTED_HOST: the iOS Simulator exists only on macOS (this host is ${host_os}). Use 'scripts/run-mobile.sh android' instead."
    exit 1
  fi
  require_cmd xcrun
  if ! xcrun simctl help >/dev/null 2>&1; then
    log_error "XCODE_TOOLS_NOT_FOUND: 'xcrun simctl' is unavailable. Install Xcode, then run 'sudo xcode-select --switch /Applications/Xcode.app'."
    exit 1
  fi

  if [[ -z "${DEVICE_ID}" ]]; then
    DEVICE_ID="$(booted_simulator_udid)"
    if [[ -n "${DEVICE_ID}" ]]; then
      log_info "Reusing iOS Simulator already booted: ${DEVICE_ID}"
      return 0
    fi
    DEVICE_ID="$(first_available_simulator_udid)"
  fi

  if [[ -z "${DEVICE_ID}" ]]; then
    log_error "IOS_NO_SIMULATOR: no available iOS Simulator device found. Install a simulator runtime via Xcode > Settings > Components."
    exit 1
  fi

  log_info "Booting iOS Simulator ${DEVICE_ID}"
  if ! xcrun simctl boot "${DEVICE_ID}"; then
    log_error "IOS_SIMULATOR_BOOT_FAILED: 'xcrun simctl boot ${DEVICE_ID}' failed. Check the UDID against 'xcrun simctl list devices available'."
    exit 1
  fi
  open -a Simulator >/dev/null 2>&1 || log_info "Could not foreground the Simulator app; continuing"

  log_info "Waiting up to ${BOOT_TIMEOUT_SECS}s for the simulator to reach Booted"
  if ! wait_for "simulator_is_booted '${DEVICE_ID}'" "${BOOT_TIMEOUT_SECS}" "iOS Simulator ${DEVICE_ID} boot"; then
    log_error "IOS_SIMULATOR_BOOT_TIMEOUT: simulator ${DEVICE_ID} did not reach Booted within ${BOOT_TIMEOUT_SECS}s."
    exit 1
  fi
  log_info "iOS Simulator booted: ${DEVICE_ID}"
}

# ------------------------------------------------------------------- run ---

case "${PLATFORM}" in
  android) resolve_android_device ;;
  ios) resolve_ios_device ;;
esac

wait_until_flutter_sees_device

log_info "Handing off to interactive 'flutter run -d ${DEVICE_ID}'. Press 'r' to hot reload, 'q' to quit; the emulator/simulator keeps running afterwards."
cd "${REPO_ROOT}/mobile"
exec "${FLUTTER}" run -d "${DEVICE_ID}" ${FLUTTER_ARGS[@]+"${FLUTTER_ARGS[@]}"}
