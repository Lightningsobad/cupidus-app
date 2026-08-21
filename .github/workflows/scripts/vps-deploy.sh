#!/usr/bin/env bash
# OID-2: runner-owned OpenSSH client, no third-party marketplace action in the
# credential path. Host key is pinned from VPS_SSH_KNOWN_HOSTS; StrictHostKeyChecking
# is never disabled. Never echoes key material or secret values.
set -euo pipefail

: "${VPS_SSH_HOST:?missing}"
: "${VPS_SSH_USER:?missing}"
: "${VPS_SSH_PORT:?missing}"
: "${VPS_DEPLOY_PATH:?missing}"
: "${BACKEND_IMAGE:?missing}"
: "${GHCR_PULL_TOKEN:?missing}"
: "${GHCR_PULL_USER:?missing}"

SSH_KEY_PATH="${RUNNER_TEMP:?missing}/vps_deploy_key"
KNOWN_HOSTS_PATH="${RUNNER_TEMP:?missing}/vps_known_hosts"

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

# The deploy key is restricted server-side by a forced-command wrapper
# (/root/.ssh/deploy-wrapper.sh) that only eval's SSH_ORIGINAL_COMMAND when it
# is prefixed with the literal, unquoted string "cd ${VPS_DEPLOY_PATH} && "
# (currently "cd /var/www/backend && "). A quoted "cd '...' && " prefix does
# not match and is rejected outright, so every command below must interpolate
# VPS_DEPLOY_PATH unquoted at that exact position.
ssh_exec() {
  ssh "${SSH_OPTS[@]}" "${VPS_SSH_USER}@${VPS_SSH_HOST}" "$1"
}

# Same forced-command prefix rule as ssh_exec, but forwards stdin so a secret
# value (the GHCR pull token) travels on stdin instead of appearing in the
# command string, where it could be logged or show up in remote `ps` output.
ssh_exec_stdin() {
  ssh "${SSH_OPTS[@]}" "${VPS_SSH_USER}@${VPS_SSH_HOST}" "$1"
}

echo "::group::Pre-deploy record"
# Record the currently-running image reference for automatic restore on gate failure.
PRIOR_IMAGE=$(ssh_exec "cd ${VPS_DEPLOY_PATH} && docker inspect --format '{{.Config.Image}}' cupid-backend 2>/dev/null || echo NONE")
echo "prior image reference: ${PRIOR_IMAGE}"

# Pre-deploy database dump; must be non-zero size (AC6 / SCHEMA_SAFETY_UNMET
# mitigation). -f docker-compose.prod.yml pins the loopback-only compose
# project (the legacy compose file publishes 5432/6379 on all interfaces).
# POSTGRES_USER is expanded inside the postgres container's own shell (from
# the VPS-owned .env via docker compose's environment:), not in this VPS
# login shell, so a non-default value in production is honored instead of
# silently falling back to "postgres" and failing safe.
DUMP_CMD="cd ${VPS_DEPLOY_PATH} && docker compose -f docker-compose.prod.yml up -d postgres && sleep 5 && mkdir -p backups && docker compose -f docker-compose.prod.yml exec -T postgres sh -c 'pg_dumpall -U \"\$POSTGRES_USER\"' > backups/pre-deploy-\$(date +%Y%m%dT%H%M%SZ).sql && ls -la backups/ | tail -5"
ssh_exec "$DUMP_CMD"
DUMP_SIZE=$(ssh_exec "cd ${VPS_DEPLOY_PATH} && ls -1t backups/pre-deploy-*.sql 2>/dev/null | head -1 | xargs -r stat -c '%s' || echo 0")
if [ "${DUMP_SIZE:-0}" -le 0 ]; then
  echo "pre-deploy dump is zero-size or missing" >&2
  exit 1
fi
echo "pre-deploy dump size bytes: ${DUMP_SIZE}"
echo "::endgroup::"

echo "::group::GHCR authentication"
# OID-3: the ghcr.io package stays private, so the VPS must authenticate
# before it can pull. Token is piped on stdin, never embedded in the command
# string or echoed anywhere in this script's output.
ssh_exec_stdin "cd ${VPS_DEPLOY_PATH} && docker login ghcr.io -u '${GHCR_PULL_USER}' --password-stdin" <<< "$GHCR_PULL_TOKEN"
echo "::endgroup::"

echo "::group::Pull and promote"
ssh_exec "cd ${VPS_DEPLOY_PATH} && BACKEND_IMAGE='${BACKEND_IMAGE}' docker compose -f docker-compose.prod.yml pull"

# AC7 negative rollback proof only: deliberately withhold the service-account.json
# bind-mount source so the container crashes in bootstrap() before it listens.
# The mount source itself is never deleted; a temporary path is swapped in for the
# duration of this one deploy and restored unconditionally afterward.
SIMULATE_FAILURE="${SIMULATE_HEALTH_GATE_FAILURE:-false}"
if [ "$SIMULATE_FAILURE" = "true" ]; then
  echo "SIMULATE_HEALTH_GATE_FAILURE=true: temporarily hiding service-account.json to force a health-gate failure (AC7 proof)"
  ssh_exec "cd ${VPS_DEPLOY_PATH} && mv service-account.json service-account.json.ac7-hidden"
  restore_service_account() {
    ssh_exec "cd ${VPS_DEPLOY_PATH} && mv service-account.json.ac7-hidden service-account.json" || true
  }
  trap 'restore_service_account' EXIT
fi

ssh_exec "cd ${VPS_DEPLOY_PATH} && BACKEND_IMAGE='${BACKEND_IMAGE}' docker compose -f docker-compose.prod.yml up -d"

if [ "$SIMULATE_FAILURE" = "true" ]; then
  restore_service_account
  trap - EXIT
  trap cleanup EXIT
fi
echo "::endgroup::"

echo "::group::Health gate"
BACKEND_PORT="${BACKEND_PORT:-3010}"
HEALTH_OK=0
for i in $(seq 1 20); do
  if ssh_exec "cd ${VPS_DEPLOY_PATH} && curl -sf -o /dev/null -w '%{http_code}' http://127.0.0.1:${BACKEND_PORT}/ | grep -q '^200$'"; then
    HEALTH_OK=1
    break
  fi
  sleep 3
done

if [ "$HEALTH_OK" -ne 1 ]; then
  echo "health gate failed after retries; restoring prior image reference: ${PRIOR_IMAGE}" >&2
  if [ "$PRIOR_IMAGE" != "NONE" ]; then
    ssh_exec "cd ${VPS_DEPLOY_PATH} && BACKEND_IMAGE='${PRIOR_IMAGE}' docker compose -f docker-compose.prod.yml up -d"
  fi
  exit 1
fi
echo "health gate passed"
echo "::endgroup::"

echo "::group::Post-cutover row-count check"
# -f docker-compose.prod.yml pins the loopback-only compose project (same
# reason as the pre-deploy dump above). POSTGRES_USER/POSTGRES_DB are
# expanded inside the postgres container's own shell, not this VPS login
# shell, for the same reason described at the pre-deploy dump above.
ssh_exec "cd ${VPS_DEPLOY_PATH} && docker compose -f docker-compose.prod.yml exec -T postgres sh -c 'psql -U \"\$POSTGRES_USER\" -d \"\$POSTGRES_DB\" -c \"SELECT count(*) FROM users;\"' || echo 'users table check skipped (table may not exist yet)'"
echo "::endgroup::"
