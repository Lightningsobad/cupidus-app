# Coding Agent Guide — STORY-002 API Client

## 1. Start Here

Always read:

- `coding-plan/master-plan.md` (phase detail is inline in §6; there are no `phase-*.md` files for this story)
- `architecture/solution.md` §2 Downstream Contract Summary and §4 Interceptor Pipeline Contract

## 2. Context Loading Rule

Read only the artifacts named in your phase's `Primary Inputs` (§5 of the master
plan). Do not load UX specs — this story has no UI surface and `UX-Spec` is
WAIVED. Do not load other stories' artifacts. `backend/` is read-only: the only
permitted interaction is booting it once in P0 to export `/api-docs-json`.

## 3. Execution Rule

1. Phases are strictly sequential: P0 -> P1 -> P2 -> P3 -> P4. Never start a phase whose predecessor is not `DONE`.
2. All phases belong to the Mobile lane. There is no backend, frontend, or DevOps work.
3. Update the §5 Status column immediately when a phase changes state.
4. Never hand-edit anything under `mobile/openapi/cupid_api/` — it is machine output and is replaced wholesale on regeneration. If generated code looks wrong, fix the config or the spec, then regenerate.
5. Do not implement auth. `CupidInterceptorSlot.auth` stays occupied by `PassthroughInterceptor`; STORY-003 replaces it.
6. Do not add `get_it`, `injectable`, or `freezed` (ADR-010f). The only new app dependencies are `dio` and the `cupid_api` path package.
7. Do not rename any symbol listed in solution §2 — later stories are written against those names.
8. Flutter is not on PATH on this machine. Resolve it via `$FLUTTER_SDK_PATH/bin/flutter` (default `$HOME/flutter`) per `data/devops/system/runtime-command-registry.json` -> `mobile-app`.

## 4. Stop And Escalate

Stop and report to Scrum Master, do not work around, if:

- `backend/service-account.json` cannot be obtained, so the spec cannot be exported (P0 hard blocker).
- Regeneration is not byte-stable and the instability cannot be removed by a supported generator option.
- The spec is missing an endpoint a later story needs — that is an A1 backend-freeze escalation.
- `dart-dio` + `json_serializable` generation fails. The `built_value` fallback changes the model shape in solution §2, so report it before adopting it.

## 5. Plan Update Rule

- Update phase status and test evidence in place; record evidence in `coding-plan/test-results.md`.
- Do not redesign the plan during implementation. Escalate if it is materially wrong.
