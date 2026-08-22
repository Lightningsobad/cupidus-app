#!/usr/bin/env bash
# OID-2 (mirrored from vps-deploy.sh): runner-owned OpenSSH client, no
# third-party marketplace action in the credential path. Host key is pinned
# from VPS_SSH_KNOWN_HOSTS; StrictHostKeyChecking is never disabled. Never
# echoes key material or secret values.
#
# Ships the static Astro build in WEB_DIST_DIR to VPS_WEB_DEPLOY_PATH over the
# same SSH mechanism vps-deploy.sh uses for the backend, since a static site
# needs no container/registry. The remote layout is release-swap based so a
# failed post-deploy health gate can restore the prior release without
# rebuilding:
#   <VPS_WEB_DEPLOY_PATH>/current   - live directory; the VPS Caddy site
#                                      block's `root` points here
#   <VPS_WEB_DEPLOY_PATH>/previous  - backup of the release this deploy
#                                      replaces, used only for rollback
#   <VPS_WEB_DEPLOY_PATH>/incoming  - staging area for the new build while it
#                                      is being uploaded, swapped into
#                                      `current` only after a full upload
set -euo pipefail

: "${VPS_SSH_HOST:?missing}"
: "${VPS_SSH_USER:?missing}"
: "${VPS_SSH_PORT:?missing}"
: "${VPS_WEB_DEPLOY_PATH:?missing}"
: "${WEB_DIST_DIR:?missing}"

if [ ! -d "${WEB_DIST_DIR}" ] || [ -z "$(ls -A "${WEB_DIST_DIR}" 2>/dev/null)" ]; then
  echo "WEB_DIST_DIR (${WEB_DIST_DIR}) does not exist or is empty; nothing to deploy" >&2
  exit 1
fi

SSH_KEY_PATH="${RUNNER_TEMP:?missing}/vps_web_deploy_key"
KNOWN_HOSTS_PATH="${RUNNER_TEMP:?missing}/vps_web_known_hosts"

cleanup() {
  rm -f "$SSH_KEY_PATH" "$KNOWN_HOSTS_PATH"
}
trap cleanup EXIT

umask 077
printf '%s\n' "${VPS_SSH_PRIVATE_KEY:?missing}" > "$SSH_KEY_PATH"
printf '%s\n' "${VPS_SSH_KNOWN_HOSTS:?missing}" > "$KNOWN_HOSTS_PATH"
chmod 600 "$SSH_KEY_PATH"

SSH_OPTS=(
  -i "$SSH_KEY_PATH"
  -p "$VPS_SSH_PORT"
  -o StrictHostKeyChecking=yes
  -o UserKnownHostsFile="$KNOWN_HOSTS_PATH"
  -o BatchMode=yes
)

# This script authenticates with its own dedicated deploy key
# (VPS_WEB_SSH_PRIVATE_KEY), server-side forced-command-restricted to
# "cd ${VPS_WEB_DEPLOY_PATH} && " via /root/.ssh/deploy-web-wrapper.sh on the
# VPS — mirroring, but never sharing authorized_keys lines with, the
# backend deploy key/wrapper pair. Every remote command below must therefore
# start with that exact literal prefix (see the requirement configuration
# guide §5 for the live finding that made a dedicated key necessary instead
# of reusing the backend's VPS_SSH_PRIVATE_KEY).
ssh_exec() {
  ssh "${SSH_OPTS[@]}" "${VPS_SSH_USER}@${VPS_SSH_HOST}" "$1"
}

# Same forced-command prefix rule as ssh_exec, but forwards stdin so the built
# site (as a tar stream) travels without ever landing in a command string.
ssh_exec_stdin() {
  ssh "${SSH_OPTS[@]}" "${VPS_SSH_USER}@${VPS_SSH_HOST}" "$1"
}

echo "::group::Pre-deploy record"
# VPS_WEB_DEPLOY_PATH itself must already exist before the first CI-driven
# deploy: the web deploy key's server-side forced-command wrapper only
# authorizes commands whose SSH_ORIGINAL_COMMAND string starts with the
# literal "cd ${VPS_WEB_DEPLOY_PATH} && " prefix, so this script cannot
# `mkdir -p` the deploy root itself (same bootstrap convention as
# VPS_DEPLOY_PATH for the backend deploy key/wrapper).
ssh_exec "cd ${VPS_WEB_DEPLOY_PATH} && rm -rf incoming previous && mkdir -p incoming && if [ -d current ]; then cp -a current previous; echo prior release backed up; else echo no prior release; fi"
echo "::endgroup::"

echo "::group::Upload build"
tar -czf - -C "${WEB_DIST_DIR}" . | ssh_exec_stdin "cd ${VPS_WEB_DEPLOY_PATH} && cd incoming && tar -xzf -"
UPLOADED_FILES=$(ssh_exec "cd ${VPS_WEB_DEPLOY_PATH} && cd incoming && find . -type f | wc -l")
echo "uploaded file count: ${UPLOADED_FILES}"
if [ "${UPLOADED_FILES:-0}" -le 0 ]; then
  echo "upload produced zero files in incoming/" >&2
  exit 1
fi
echo "::endgroup::"

echo "::group::Swap to live"
ssh_exec "cd ${VPS_WEB_DEPLOY_PATH} && rm -rf current && mv incoming current"
echo "::endgroup::"

echo "::group::Health gate"
HEALTH_CHECK_URL="${HEALTH_CHECK_URL:-https://cupidus.app/}"
HEALTH_OK=0
for i in $(seq 1 20); do
  if curl -sf -o /dev/null -w '%{http_code}' "${HEALTH_CHECK_URL}" | grep -q '^200$'; then
    HEALTH_OK=1
    break
  fi
  sleep 3
done

if [ "$HEALTH_OK" -ne 1 ]; then
  echo "health gate failed after retries against ${HEALTH_CHECK_URL}; restoring prior release" >&2
  ssh_exec "cd ${VPS_WEB_DEPLOY_PATH} && if [ -d previous ]; then rm -rf current && mv previous current; echo restored prior release; else echo no prior release to restore; fi"
  exit 1
fi
echo "health gate passed against ${HEALTH_CHECK_URL}"
echo "::endgroup::"
