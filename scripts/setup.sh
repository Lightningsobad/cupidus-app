#!/usr/bin/env bash
# Sets up local infrastructure only: Docker Compose Postgres + Redis for the
# backend, with project-scoped naming and non-fixed loopback host ports so
# several generated projects can run on the same machine without colliding.
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
install_err_trap

log_info "Preflight: checking Docker availability"
require_cmd docker
if ! docker info >/dev/null 2>&1; then
  log_error "Docker daemon is not reachable. Start Docker (or OrbStack) and re-run."
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  log_error "the 'docker compose' plugin is not available"
  exit 1
fi

PROJECT_NAME="$(env_get COMPOSE_PROJECT_NAME "$(compose_project_name)")"
env_set COMPOSE_PROJECT_NAME "${PROJECT_NAME}"
env_set POSTGRES_USER "$(env_get POSTGRES_USER postgres)"
env_set POSTGRES_PASSWORD "$(env_get POSTGRES_PASSWORD password)"
env_set POSTGRES_DB "$(env_get POSTGRES_DB cupid)"

log_info "Resolving local-only dependency host ports for project '${PROJECT_NAME}'"

PG_PORT="$(env_get POSTGRES_HOST_PORT 15432)"
if ! is_service_running postgres && ! port_is_free "${PG_PORT}"; then
  PG_PORT="$(find_free_port "${PG_PORT}")"
  log_info "Default Postgres host port busy, using ${PG_PORT}"
fi
env_set POSTGRES_HOST_PORT "${PG_PORT}"

REDIS_PORT="$(env_get REDIS_HOST_PORT 16379)"
if ! is_service_running redis && ! port_is_free "${REDIS_PORT}"; then
  REDIS_PORT="$(find_free_port "${REDIS_PORT}")"
  log_info "Default Redis host port busy, using ${REDIS_PORT}"
fi
env_set REDIS_HOST_PORT "${REDIS_PORT}"

# BACKEND_HOST_PORT is resolved here for start-dev.sh/start-prod.sh to reuse,
# but no backend container is started by this script (app processes are not
# local infrastructure). It is a configurable, non-fixed port: if the
# default is already taken by another process/project on this machine, pick
# the next free one instead of failing.
BACKEND_PORT="$(env_get BACKEND_HOST_PORT 3000)"
if ! port_is_free "${BACKEND_PORT}"; then
  RESOLVED_BACKEND_PORT="$(find_free_port "${BACKEND_PORT}")"
  log_info "Default backend host port ${BACKEND_PORT} busy, using ${RESOLVED_BACKEND_PORT}"
  BACKEND_PORT="${RESOLVED_BACKEND_PORT}"
fi
env_set BACKEND_HOST_PORT "${BACKEND_PORT}"

log_info "Bringing up local infrastructure (postgres, redis)"
dc up -d postgres redis

log_info "Waiting for Postgres readiness"
PG_USER="$(env_get POSTGRES_USER postgres)"
if ! wait_for "dc exec -T postgres pg_isready -U '${PG_USER}'" 30 "postgres pg_isready"; then
  exit 1
fi

log_info "Waiting for Redis readiness"
if ! wait_for "[[ \"\$(dc exec -T redis redis-cli ping 2>/dev/null | tr -d '\\r')\" == 'PONG' ]]" 30 "redis PING"; then
  exit 1
fi

log_info "Local infrastructure ready: postgres=127.0.0.1:${PG_PORT} redis=127.0.0.1:${REDIS_PORT} (project ${PROJECT_NAME})"
