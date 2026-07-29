# Vendored OpenAPI Spec (Placeholder)

This directory will hold the vendored backend OpenAPI spec
(`cupid-api.json`), per ADR-006/ADR-009 in
`data/architecture/system/system_architecture_memory.md`.

The spec is not fetched or generated in this scaffold pass. The backend
requires `backend/service-account.json` to boot, and codegen must not depend
on a live server, so the spec must be exported and vendored deliberately.

This will be produced in the `api_client` foundation story (F2):

1. Start the backend with a valid `service-account.json`.
2. Export the spec from `/api-docs-json`.
3. Commit it here as `mobile/openapi/cupid-api.json`.
4. Generate the typed REST client from the vendored file (never hand-edited,
   never generated against a live server at build time).
