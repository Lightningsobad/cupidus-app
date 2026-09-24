## Story Runtime Startup Smoke

- Runtime Id: backend-api
- Registry: data/devops/system/runtime-command-registry.json
- Reason: `guard-parallel-spawn.sh` refused to spawn Alex-Mobile-Dev for this
  story's Phase P1 with "no declared service runtime is running" even though
  Phase P1 itself declares `Runtime startup smoke: NO`. This section satisfies
  that blanket repo-level spawn-guard precondition; it is not a Phase P1 test
  result.
- Command: `npm run start:dev` in `backend/`, `PORT` sourced from
  `DEVSTACK_PORT_API` in `.env.devstack` (shared devstack tenant `cupid_apps`,
  reserved port 21020 per `sharedInfra.reservedPorts.api`)
- Ready Check: `GET http://127.0.0.1:21020/api-docs-json` expecting HTTP 200
- Result: PASS (HTTP 200, valid OpenAPI JSON body returned; process listening
  on `*:21020`, backend `[NestApplication] Nest application successfully
  started` logged)
- Shutdown: PASS (SIGTERM to the nest dev process; process exited within 2s;
  port 21020 confirmed free afterward)

Notes:
- Worktree-local setup performed to make this runnable: `backend/node_modules`
  installed via `npm ci` (worktrees do not share installed dependencies), and
  two pre-existing local secrets/generated files copied from the control
  checkout into this worktree since git worktrees do not carry untracked
  files: `backend/service-account.json` (pre-supplied Firebase Admin
  credential, not generated) and `.env.devstack` (devstack-generated env
  contract for the same shared `cupid-apps` tenant; `devstack use --check`
  confirms this worktree resolves to the same adopted tenant as the control
  checkout, and `devstack port check` showed no conflicts before starting).
- This smoke does not leave backend-api running; per the handoff, only proof
  it can start and answer ready was required.

## Phase P1 — Content Pack And Gate (Mobile)

All commands run from the story worktree's `mobile/` directory on
`codex/REQ-016_solo_stage1_relationship_assistant-STORY-011_zodiac_quiz_shell`.

### Targeted tests

- Command: `flutter test test/features/zodiac_shell/`
- Result: PASS (67/67 — 46 gate tests, 21 parser/schema tests)
- Covers: shipped packages parse under their contract schema id, mapping keys
  decompose into `questions_per_round` tokens, N read only from
  `ContentPackage.length`, parser rejections, gate rules one control per rule,
  time-gating key refusal per key in `zodiacTimeGatingKeys`, lexical delegation
  to `core/content/invariant_terms.dart`, input-side probe refusal in question
  prompts, and the offline/content-free source scans (AC-22/AC-23/R-15a).

### Regression

- Command: `flutter test test/core/content/`
- Result: PASS (15/15, unchanged — the shared `ContentPackage` parser was reused
  verbatim, not modified)
- Combined confirmation run: `flutter test test/features/zodiac_shell/
  test/core/content/` — PASS (82/82)

### Static analysis

- Command: `flutter analyze lib/features/zodiac_shell test/features/zodiac_shell`
- Result: PASS (`No issues found!`)
- Scoping note: the repository-wide `flutter analyze lib test` baseline is
  non-zero (pre-existing warnings, 0 errors), so analysis is scoped to the
  Phase P1 write scope. Delta introduced by this phase: 0 issues. One
  `unnecessary_import` (`dart:typed_data`) raised on the first run was fixed
  before this result.

### Contract deviation recorded

- `architecture/contract-summary.md` §1 sketches the package envelope key as
  `"schemaId"`, but the same section mandates reusing
  `core/content/content_package.dart` verbatim, and `ContentPackage.parse`
  reads `schema_id`. The shipped packages therefore use `schema_id`; the §2
  schema id *values* (`req016.zodiac_quiz.v1`, `req016.zodiac_outcomes.v1`) are
  matched exactly.

### Notes

- `mobile/pubspec.yaml` already declares the `assets/data/req016/` directory, so
  both new packages bundle with no pubspec change (no edit was made to it).
### Design reference resolved (design-side only)

- `Design-Screen: 7-vo-hoang-dao-3-viec` — resolved by this lane and recorded in
  `story_master.md`; no `Design-Screen:` line had been written before.
- Enumerated first, never guessed:
  `node .ai-team-bundle/runtime/tools/render-design-canvas.js
  --surface=cupid-ch-ng-1 --list-screens`
- Rendered:
  `node .ai-team-bundle/runtime/tools/render-design-canvas.js
  --surface=cupid-ch-ng-1 --screen=7-vo-hoang-dao-3-viec --platform=ios
  --out=<story-dir>/visual-fidelity`
  → `DESIGN_CANVAS: OK .../visual-fidelity/design-reference-7-vo-hoang-dao-3-viec-ios.png 415x900`
- Confirmed by looking, not by string match. The render is the "Cung & trắc
  nghiệm" screen and it corroborates the P1 data contract: a self-addressed
  insight, an `about_other` block whose ask line renders as a quoted question
  (AC-15), exactly three suggestion cards each with a title plus a meta note
  (AC-4/BR-2 → `minimumSuggestionsPerOutcome`), and a closing disclaimer with no
  percentage, score, or verdict anywhere (AC-13/AC-14). Candidate
  `tro-doan-khong-thang-thua` was rejected: it is the guessing game, not this
  result surface.

- Visual fidelity: the *implemented* side is NOT_APPLICABLE for this phase —
  P1 ships data and domain code only, no widget. `implemented-*.png` and
  `visual-fidelity-report.md` belong to Phase P3 (result surface screens), which
  now has its design reference in place rather than building blind. This phase
  deliberately wrote no `VISUAL_FIDELITY:` verdict: there is nothing rendered to
  compare yet, and a typed token without a capture is exactly what the gate
  exists to refuse.
