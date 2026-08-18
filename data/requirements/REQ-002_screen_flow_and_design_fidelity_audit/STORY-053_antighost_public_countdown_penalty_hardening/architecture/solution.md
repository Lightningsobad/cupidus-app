# STORY-053 Solution — Anti-Ghosting `publicCountdown` Setting

## 0. Metadata

- Complexity: standard
- Date: 2026-08-18

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: one new persisted boolean travelling the *existing*
  `POST /ghost-config` propose -> partner-approval path (AC1, AC4); no new
  endpoint, no per-field mutation path, no change to the `Penalty` enum (AC5).
- Architectural invariants / non-goals: `GhostConfig` stays a single immutable
  proposal record per couple state transition — `publicCountdown` is another
  column on that record, never a second resource. `Penalty` remains a
  single-value enum; `publicCountdown` is never one of its members.
- Proposed technical direction: add `publicCountdown: boolean` to the TypeORM
  entity with `default: true`, accept it as an optional validated DTO field,
  thread it explicitly through `GhostConfigService.create()`, and mirror it in
  the Dart wire model / repository / cubit / propose form as one new toggle row.
- Why this fits the current system: `timeoutMinutes` and `penalty` already take
  exactly this path end to end. The new field reuses every existing hop and
  introduces no new boundary.

### Key Discovery

Three code facts change how this must be implemented, none of which are visible
from the requirement or UX spec:

1. **`GhostConfigService.create()` whitelists DTO fields explicitly**
   (`backend/src/modules/ghost-config/ghost-config.service.ts:38-44` builds
   `configRepository.create({ coupleId, timeoutMinutes, penalty, proposedBy,
   status })`). Adding the entity column and the DTO field alone would compile,
   pass validation, and then **silently drop the submitted value** — every
   proposal would persist the column default. The service passthrough is the
   load-bearing edit, and AC1's "submitted... and persisted" cannot pass without
   it.
2. **The schema is `synchronize: true`** (`backend/src/app.module.ts:38`) and
   the repository has no `backend/src/migrations/` directory at all. There is no
   migration to write and none to omit — the column materialises on boot, and
   pre-existing rows backfill to the column default `true`, which is exactly the
   default AC1 requires.
3. **`GhostConfig` is constructed from JSON everywhere except one preview
   fixture** (`mobile/lib/main_preview.dart:331`). The Dart constructor is
   all-`required` today, so keeping the new field `required` costs exactly one
   extra call-site edit and preserves the model's existing strictness.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md`

## 3. Scope And Assumptions

- In Scope: `ghost_configs.publicCountdown` column + DTO + service passthrough;
  Dart wire model, repository body, cubit param, propose-form state, one new
  settings row widget, two l10n keys per locale, one l10n value correction.
- Out Of Scope: any dashboard countdown display, `_PenaltyRadioGroup`,
  `_PendingPartnerBody`/`_ActiveSummaryBody` summary strings, any per-field
  mutation endpoint.
- Assumptions affecting design: the field name `publicCountdown` and default
  `true` are fixed by `requirements` In Scope item 1 and are treated as frozen
  for both lanes, which is what makes P1 and P2 parallelizable.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `backend/src/modules/ghost-config` (producer),
  `mobile/lib/features/anti_ghosting` (consumer).
- New or changed boundaries: none. One field widens an existing request/response
  body on an existing route.
- Shared patterns reused: the entity-column + DTO-validator + explicit
  service-passthrough triple already used by `timeoutMinutes`/`penalty`; the
  `_ConsentSwitch` gradient-pill recipe
  (`mobile/lib/features/chat/presentation/screens/ghost_settings_screen.dart:375-433`)
  for the toggle visual.

### Affected Modules

- Backend: `modules/ghost-config` (entity, dto, service, service spec).
- Mobile: `features/anti_ghosting` (data + presentation), `lib/l10n`,
  `main_preview`.

### Contracts And Integrations

- Empty-state / compatibility contract: mobile reads the field defensively as
  `json['publicCountdown'] as bool? ?? true`. A `GET /ghost-config` served by a
  backend build that predates P1 must not crash the settings screen, and the
  fallback value is the same `true` the column default produces — so the
  defensive read can never disagree with a deployed backend. This is what
  removes the deploy-order coupling between the two phases.
- Compatibility posture: additive only. Older clients that omit
  `publicCountdown` from the POST body stay valid (`@IsOptional()`) and land on
  the column default.
- Idempotency/approval semantics: unchanged. `publicCountdown` is carried on the
  pending record and becomes effective only through the existing
  `PATCH /ghost-config/:id/approve` transition (AC4). No unilateral apply path
  exists to accidentally introduce.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Service drops submitted value | `ghost-config.service.ts:38-44` | Explicit `publicCountdown: dto.publicCountdown ?? true` in the `create()` object literal | `ghost-config.service.spec.ts` asserts `configRepository.create` was called with the submitted `false` **and** with `true` when the DTO omits the field | Report `BACKEND_VERIFY_REQUIRED` naming the failing spec |
| Missing field crashes settings screen | `ghost_config_models.dart:69-81` | Nullable-tolerant `as bool? ?? true` read | Widget test seeds a config JSON **without** `publicCountdown` and asserts the row renders ON | Report the failing widget test; do not relax the model to a nullable field |
| Regression in `_PenaltyRadioGroup` (AC5) | `anti_ghost_screen.dart:773-838` | New row is a sibling widget above the `"Penalty"` heading; `_PenaltyRadioGroup` and `Penalty` are not edited | Existing `State A: penalty selector exposes single-select radio semantics` test still passes unmodified | Stop and report — a change to that test is itself the AC5 violation |
| l10n keys absent from generated Dart | `mobile/l10n.yaml`, `mobile/lib/l10n/generated/` | Run `flutter gen-l10n` and commit the regenerated files alongside the `.arb` edits | `flutter analyze` resolves `l10n.anti_ghost_public_countdown_title` | Report the analyzer error; do not hardcode the literal (AC3) |

### Lane Handoff

#### Backend Lane

- Responsibilities: entity column, DTO field, service passthrough, service spec.
- Authoritative inputs: `architecture/contract-summary.md`, requirements AC1.
- Guardrails: do not add a migration file (schema is `synchronize: true` and no
  `migrations/` directory exists); do not add a new route, a per-field PATCH, or
  any `publicCountdown` handling inside `approve()`/`reject()`/`getStormStatus()`
  — those already carry the whole record; do not make the DTO field required
  (AC1 mandates a default when not supplied).

#### Mobile Lane

- Responsibilities: wire model, repository body, cubit param, propose-form
  state + new row widget, l10n keys both locales, RWB-019 `vi` value fix, widget
  tests.
- Authoritative inputs: `architecture/contract-summary.md`, `ux/uiux-spec.md`
  §1-§6, requirements AC2-AC8.
- Guardrails: do not touch `_PenaltyRadioGroup`, `Penalty`, `_PenaltyIconTile`,
  `_PendingPartnerBody`, `_ActiveSummaryBody`, or `anti_ghost_entry_card.dart`
  (AC5, AC8); do not make the whole row tappable (UX §2); do not add a per-row
  loading state (UX §3); do not change `anti_ghost_penalty_noise`'s `en` value
  or key name (AC6); do not hand-edit `lib/l10n/generated/` — regenerate it.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Additive column on `GhostConfig` + existing propose flow | Field is per-couple settings state living on the same record as `penalty` | ACCEPTED | Reuses every hop; satisfies AC1/AC4 with zero new boundary |
| Separate `publicCountdown` toggle endpoint applied unilaterally | Would give instant feedback without waiting for partner approval | REJECTED | Explicitly out of scope in the requirement; would also break AC4's "never applied unilaterally" |
