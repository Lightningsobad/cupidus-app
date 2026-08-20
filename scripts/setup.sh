#!/usr/bin/env bash
# Adopts this project onto the shared local infrastructure stack (devstack):
# provisions its Postgres/Redis tenant, reserves its application ports, and
# writes/refreshes the generated env contract (.env.devstack, merged into
# .env). No repo-local Postgres/Redis containers are started here; that
# service lives once per machine in ~/.devstack.
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
install_err_trap

log_info "Preflight: checking devstack availability"
require_cmd devstack

log_info "Adopting/refreshing this project on the shared devstack stack"
devstack use "${REPO_ROOT}"

log_info "Verifying reserved ports are not held by another process"
devstack port check --project "$(devstack_project_name)"

require_devstack_env
log_info "Local infrastructure ready: postgres=${POSTGRES_HOST}:${POSTGRES_PORT} redis=${REDIS_HOST}:${REDIS_PORT} (project $(devstack_project_name), api port ${DEVSTACK_PORT_API})"
