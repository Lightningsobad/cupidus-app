# Vendored OpenAPI Spec

This directory holds the vendored backend OpenAPI spec (`cupid-api.json`) and
the generated `cupid_api` Dart package (`cupid_api/`), per ADR-006/ADR-009 in
`data/architecture/system/system_architecture_memory.md` and ADR-010 in
`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-002_api_client/architecture/solution.md`.

`cupid-api.json` is the contract of record. Codegen (`tool/generate_api_client.sh`)
always runs offline against this vendored file — never against a live server.
Everything under `cupid_api/` is machine output and is never hand-edited;
review the `cupid-api.json` diff as the contract diff.

## 1. Fetch the spec (requires a booted backend)

The backend needs `backend/service-account.json` (Firebase Admin credential,
a manually supplied local secret) to boot. Start local infrastructure and the
backend in dev mode from the repo root, e.g. `scripts/setup.sh` followed by
`npm run start:dev` in `backend/` (or `scripts/start-dev.sh`), then run:

```bash
mobile/tool/fetch_openapi_spec.sh
```

This writes `mobile/openapi/cupid-api.json`. Set `CUPID_BACKEND_URL` (or
`BACKEND_HOST_PORT`) to override the default `http://127.0.0.1:3000`.

## 2. Generate the client (offline, deterministic)

```bash
mobile/tool/generate_api_client.sh
```

This deletes and regenerates `mobile/openapi/cupid_api/` from the vendored
spec using the `openapi-generator-cli` version pinned in
`mobile/openapitools.json`, then runs `build_runner` inside the generated
package. Running it twice in a row must produce an empty
`git status --porcelain mobile/openapi/cupid_api` (AC3).

## Toolchain preconditions

- Node (already required by `backend/`)
- A JDK (already required by `flutter build apk`)
- `openapi-generator-cli` version is pinned exactly (no `^`) in
  `mobile/openapitools.json`; generator options are configured in
  `mobile/openapi/openapi-generator-config.yaml`
  (`generatorName: dart-dio`, `serializationLibrary: json_serializable`).
