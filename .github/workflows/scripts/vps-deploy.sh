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

ssh_exec() {
  ssh "${SSH_OPTS[@]}" "${VPS_SSH_USER}@${VPS_SSH_HOST}" "$1"
}

echo "::group::Pre-deploy record"
# Record the currently-running image reference for automatic restore on gate failure.
PRIOR_IMAGE=$(ssh_exec "docker inspect --format '{{.Config.Image}}' cupid-backend 2>/dev/null || echo NONE")
echo "prior image reference: ${PRIOR_IMAGE}"

# Pre-deploy database dump; must be non-zero size (AC6 / SCHEMA_SAFETY_UNMET mitigation).
DUMP_CMD="cd '${VPS_DEPLOY_PATH}' && docker compose up -d postgres && sleep 5 && mkdir -p backups && docker compose exec -T postgres pg_dumpall -U \${POSTGRES_USER:-postgres} > backups/pre-deploy-\$(date +%Y%m%dT%H%M%SZ).sql && ls -la backups/ | tail -5"
ssh_exec "$DUMP_CMD"
DUMP_SIZE=$(ssh_exec "cd '${VPS_DEPLOY_PATH}' && ls -1t backups/pre-deploy-*.sql 2>/dev/null | head -1 | xargs -r stat -c '%s' || echo 0")
if [ "${DUMP_SIZE:-0}" -le 0 ]; then
  echo "pre-deploy dump is zero-size or missing" >&2
  exit 1
fi
echo "pre-deploy dump size bytes: ${DUMP_SIZE}"
echo "::endgroup::"

echo "::group::Pull and promote"
ssh_exec "cd '${VPS_DEPLOY_PATH}' && BACKEND_IMAGE='${BACKEND_IMAGE}' docker compose -f docker-compose.prod.yml pull"

# AC7 negative rollback proof only: deliberately withhold the service-account.json
# bind-mount source so the container crashes in bootstrap() before it listens.
# The mount source itself is never deleted; a temporary path is swapped in for the
# duration of this one deploy and restored unconditionally afterward.
SIMULATE_FAILURE="${SIMULATE_HEALTH_GATE_FAILURE:-false}"
if [ "$SIMULATE_FAILURE" = "true" ]; then
  echo "SIMULATE_HEALTH_GATE_FAILURE=true: temporarily hiding service-account.json to force a health-gate failure (AC7 proof)"
  ssh_exec "cd '${VPS_DEPLOY_PATH}' && mv service-account.json service-account.json.ac7-hidden"
  restore_service_account() {
    ssh_exec "cd '${VPS_DEPLOY_PATH}' && mv service-account.json.ac7-hidden service-account.json" || true
  }
  trap 'restore_service_account' EXIT
fi

ssh_exec "cd '${VPS_DEPLOY_PATH}' && BACKEND_IMAGE='${BACKEND_IMAGE}' docker compose -f docker-compose.prod.yml up -d"

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
  if ssh_exec "curl -sf -o /dev/null -w '%{http_code}' http://127.0.0.1:${BACKEND_PORT}/ | grep -q '^200$'"; then
    HEALTH_OK=1
    break
  fi
  sleep 3
done

if [ "$HEALTH_OK" -ne 1 ]; then
  echo "health gate failed after retries; restoring prior image reference: ${PRIOR_IMAGE}" >&2
  if [ "$PRIOR_IMAGE" != "NONE" ]; then
    ssh_exec "cd '${VPS_DEPLOY_PATH}' && BACKEND_IMAGE='${PRIOR_IMAGE}' docker compose -f docker-compose.prod.yml up -d"
  fi
  exit 1
fi
echo "health gate passed"
echo "::endgroup::"

echo "::group::Post-cutover row-count check"
ssh_exec "cd '${VPS_DEPLOY_PATH}' && docker compose exec -T postgres psql -U \${POSTGRES_USER:-postgres} -d \${POSTGRES_DB:-cupid} -c 'SELECT count(*) FROM users;' || echo 'users table check skipped (table may not exist yet)'"
echo "::endgroup::"
