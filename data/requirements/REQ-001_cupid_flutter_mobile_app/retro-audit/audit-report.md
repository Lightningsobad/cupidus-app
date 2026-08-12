# Retro Audit Report: REQ-001 cupid_flutter_mobile_app

Audit Date: 2026-08-12
Audited By: scrum-master (structural) + reviewer (substantive)
Trigger: user request "review REQ-001" with pre-existing mobile visual audit evidence (Result: FAIL) to be folded into Design Fidelity
Mode: single-req

## Structural Findings

| Story | Type | Lane | Requirements | UX Spec | Architecture | Master Plan | Review | Review Verdict |
|-------|------|------|--------------|---------|--------------|-------------|--------|----------------|
| STORY-001 design_system | shared-foundation | mobile | ✅ (REQ-level `requirements/requirements.md`) | ✅ | ✅ | ✅ | ✅ | CLEAN |
| STORY-002 api_client | standard | mobile | ✅ (REQ-level) | ❌ not applicable (non-UI backend-client story) | ✅ | ✅ | ✅ | (recorded DONE, outcome not re-verified structurally) |
| STORY-003 auth | standard | mobile | ✅ (REQ-level) | ✅ | ✅ | ✅ | ✅ | (recorded DONE) |
| STORY-004 realtime_coordinator_spike | standard | mobile | ✅ (REQ-level) | ❌ not applicable (spike, non-UI) | ✅ | ✅ | ✅ | (recorded DONE) |
| STORY-005 pairing | standard | mobile | ✅ (REQ-level) | ✅ | ❌ missing (`architecture/` dir has 0 files) | ✅ | ✅ | (recorded DONE) |
| STORY-006 love_contracts | standard | mobile | ✅ (REQ-level) | ✅ | ✅ | ✅ | ✅ | CLEAN |
| STORY-007 chat | standard | mobile | ✅ (REQ-level) | ✅ | ✅ | ✅ | ✅ | CLEAN |
| STORY-008 anti_ghosting | standard | mobile | ✅ (REQ-level) | ✅ | ✅ | ✅ | ✅ | CLEAN |
| STORY-009 nhac_nho_dong_bo | standard | mobile | ✅ (REQ-level) | ✅ | ✅ | ✅ | ✅ | CLEAN |
| STORY-010 vibes | standard | mobile | ✅ (REQ-level) | ✅ | ✅ | ✅ | ✅ | DEFERRED_ONLY (AC3 deferred to integration, R-010-1) |
| STORY-011 bun_pet | standard | mobile | ✅ (REQ-level) | ✅ | ✅ | ✅ | ✅ | CLEAN |
| STORY-012 timeline | standard | mobile | ✅ (REQ-level) | ✅ | ✅ | ✅ | ✅ | DEFERRED_ONLY |
| STORY-013 gallery | standard | mobile | ✅ (story-level override `requirements/`) | ✅ | ✅ | ✅ | ✅ | DEFERRED_ONLY |
| STORY-014 dream_jar | standard | mobile | ✅ (REQ-level) | ✅ | ✅ | ✅ | ✅ | DEFERRED_ONLY (re-review closing prior PATCH_REQUIRED) |
| STORY-015 expenses | standard | mobile | ✅ (REQ-level) | ✅ | ✅ | ✅ | ✅ | CLEAN |
| STORY-016 profile_privacy_notifs | standard | mobile | ✅ (story-level override `requirements/`) | ✅ | ✅ | ✅ | ✅ | CLEAN |

Structural gap found: **STORY-005 (pairing)** has an `architecture/` directory with zero files — no architecture artifact exists despite `story_master.md` recording the story as DONE with review outcome recorded. This is a genuine missing-artifact finding, not a legacy-path resolution issue (no legacy filename found under the story directory either).

All 16 stories have `coding-plan/master-plan.md` and `review/review-report.md` present (file-level verified, not content-verified beyond what is recorded in `story_master.md`).

None of the 16 stories' acceptance criteria assert pixel/visual conformance to the locked design source (`cupid-app-design-system`). All ACs are capability-based (e.g. "a paired user can create/propose a love contract"). Per the Classification Guardrails, this is an AC-coverage gap, not a reason to exempt design fidelity from scope — the requirement master's founding design intent outranks the story ACs.

## Legacy Compatibility Notes

None. All resolved artifacts are at canonical or REQ-level shared paths; no legacy filename substitutions were required for structural resolution.

## Open Question Impact Gaps

| Story | OQs Unresolved at Build Time | Scope Removed | Justified? |
|-------|------------------------------|---------------|------------|
| STORY-006 love_contracts | OQ-006A (dual-signature ritual) | Reduced to creator-only capability (backend limitation) | ⚠️ recorded as non-blocking in story artifact only — no central OQ triage/user override located; reviewer must confirm |
| STORY-010 vibes | R-010-1 (AC3 unpaired-gating) | AC3 deferred to requirement integration (app-level paired route gate did not exist at STORY-010 BaseHead) | ⚠️ needs confirmation the gate was actually implemented at integration — not confirmed by any story-level review; reviewer must verify against current code |
| STORY-014 dream_jar | none formal, but flagged AC/reality mismatch | Text "wish list" AC vs. actual monetary savings-jar implementation; 4th custom-amount tile, edit/archive/delete, multi-currency deferred | ⚠️ flagged in story artifact for PO wording correction — not yet triaged as an approved change record |
| REQ-001 (central) | OQ4 (Drift vs hydrated_bloc for offline) | Resolved — architecture decision D-series in `req_master.md` | ✅ resolved centrally |
| REQ-001 (central) | OQ5 (light theme & EN in v1) | Resolved — STORY-001 built-but-not-enabled | ✅ resolved centrally |

OQ selection above includes central-registry-relevant items surfaced in `req_master.md` and story artifacts. Reviewer audits must independently re-verify the STORY-006, STORY-010, and STORY-014 rows above; none of them currently has a Product-Owner-owned `## Open Question Triage` / `## Approved Scope Change` record, so per the classification guardrails they cannot be treated as approved by story documentation alone.

## Reviewer Delegation Log

| Story | Reviewer Called? | Handoff Type | Result |
|-------|------------------|--------------|--------|
| STORY-001 | YES | Reviewer: retro-audit | NEEDS_WORK / RED-PATCH |
| STORY-002 | YES | Reviewer: retro-audit | CLEAN / GREEN |
| STORY-003 | YES | Reviewer: retro-audit | NEEDS_WORK / RED-PATCH |
| STORY-004 | YES | Reviewer: retro-audit | CLEAN / GREEN |
| STORY-005 | YES | Reviewer: retro-audit | NEEDS_WORK / RED-PATCH |
| STORY-006 | YES | Reviewer: retro-audit | SIGNIFICANT_GAPS / RED-PATCH |
| STORY-007 | YES | Reviewer: retro-audit | CLEAN / AMBER |
| STORY-008 | YES | Reviewer: retro-audit | SIGNIFICANT_GAPS / RED-PATCH |
| STORY-009 | YES | Reviewer: retro-audit | NEEDS_WORK / RED-PATCH |
| STORY-010 | YES | Reviewer: retro-audit | CLEAN / GREEN |
| STORY-011 | YES | Reviewer: retro-audit | NEEDS_WORK / AMBER |
| STORY-012 | YES | Reviewer: retro-audit | CLEAN / GREEN |
| STORY-013 | YES | Reviewer: retro-audit | NEEDS_WORK / RED-PATCH |
| STORY-014 | YES | Reviewer: retro-audit | NEEDS_WORK / RED-PATCH |
| STORY-015 | YES | Reviewer: retro-audit | CLEAN / AMBER |
| STORY-016 | YES | Reviewer: retro-audit | SIGNIFICANT_GAPS / RED-PATCH |

## Substantive Findings (Reviewer Only)

Each story's reviewer writes its own `audit-report-<STORY-ID>.md` in this folder. Scrum Master merges the per-story verdicts into the table below AFTER each batch returns.

| Story | Findings File | Substantive Verdict | Classification Impact | REVIEW_COMPLETE |
|-------|---------------|---------------------|-----------------------|-----------------|
| STORY-001 | `audit-report-STORY-001.md` | NEEDS_WORK | RED-PATCH | YES |
| STORY-002 | `audit-report-STORY-002.md` | CLEAN | GREEN | YES |
| STORY-003 | `audit-report-STORY-003.md` | NEEDS_WORK | RED-PATCH | YES |
| STORY-004 | `audit-report-STORY-004.md` | CLEAN | GREEN | YES |
| STORY-005 | `audit-report-STORY-005.md` | NEEDS_WORK | RED-PATCH | YES |
| STORY-006 | `audit-report-STORY-006.md` | SIGNIFICANT_GAPS | RED-PATCH | YES |
| STORY-007 | `audit-report-STORY-007.md` | CLEAN | AMBER | YES |
| STORY-008 | `audit-report-STORY-008.md` | SIGNIFICANT_GAPS | RED-PATCH | YES |
| STORY-009 | `audit-report-STORY-009.md` | NEEDS_WORK | RED-PATCH | YES |
| STORY-010 | `audit-report-STORY-010.md` | CLEAN | GREEN | YES |
| STORY-011 | `audit-report-STORY-011.md` | NEEDS_WORK | AMBER | YES |
| STORY-012 | `audit-report-STORY-012.md` | CLEAN | GREEN | YES |
| STORY-013 | `audit-report-STORY-013.md` | NEEDS_WORK | RED-PATCH | YES |
| STORY-014 | `audit-report-STORY-014.md` | NEEDS_WORK | RED-PATCH | YES |
| STORY-015 | `audit-report-STORY-015.md` | CLEAN | AMBER | YES |
| STORY-016 | `audit-report-STORY-016.md` | SIGNIFICANT_GAPS | RED-PATCH | YES |

### Per-Story Assessment

- **STORY-001 design_system** — All 4 ACs PASS on independent code/test read (theme matrix, ARB parity, dark+`vi` default gating, no-fork source-scan guard). Sole gap: Design Fidelity is `UNVERIFIED` — this story owns the token/theme/adaptive-widget surface but no rendered comparison against the locked design source exists anywhere (no `visual-fidelity/` dir; the reused `mobile-visual-audit.md` only captured full screens, none of which are this story's surface). Recommend capturing a rendered token/theme diff via `mobile/lib/main_preview.dart`. The `alarm`/`home` FAILs recorded in Design Fidelity are screen-building work explicitly Out of Scope for this story per `story_master.md`; ownership of `home` specifically is unclear from `req_master.md`'s story table and should be confirmed by PO, not assumed here.
- **STORY-002 api_client** — All 4 ACs PASS, independently re-run (10/10 tests, deterministic regenerate with empty `git status --porcelain`). Design Fidelity correctly NOT APPLICABLE (zero UI/screen code, confirmed by source inspection of all four `core/network/*.dart` files). No OQ-driven scope cut. Clean.
- **STORY-003 auth** — All 4 ACs PASS, independently re-run in isolation (7/7, 4/4, 9, 2/2, 2/2 across 5 test files). Design Fidelity `UNVERIFIED` for all 6 owned screens (`splash`/`welcome`/`login`/`register`/`otp`/`forgot`) — none are among the 10 captured pairs in the reused evidence and no story-level `visual-fidelity/` artifact exists. R8 forward-compat token exposure delivered in code; backend-side gap correctly tracked separately, not silently absorbed.
- **STORY-004 realtime_coordinator_spike** — All 4 ACs PASS. Design Fidelity correctly not-applicable (confirmed zero widgets/screens/routes in `mobile/lib/core/realtime/**`; `story_master.md` places realtime UI Out of Scope for epic-2/epic-3). No silent scope cuts (R8, R9 both properly disclosed/deferred). Clean.
- **STORY-005 pairing** — All 4 ACs PASS on independently traced navigation/state code (invite → accept → paired convergence, couple-only 409 mapping, pair-gate fail-closed default). Design Fidelity `UNVERIFIED` across all 4 owned screens (`invite`/`joincode`/`paired` are ratio-only weak evidence per the reused audit; `waiting` has zero evidence at all) — this alone forecloses GREEN/AMBER for the story regardless of AC pass. Confirms the structural finding: `architecture/` directory is genuinely absent (0 files, not a legacy-path issue), though the underlying decisions are traceable in `coding-plan/master-plan.md`. Separately flags a legitimate AC-coverage gap: the design source bundles a couple-type picker and a "Continue → Fingerprint Vow" CTA into `invite` that the story deliberately excluded (flagged to PO in UX §7, no supporting endpoint) — recommend PO-owned AC correction, not treated as a fidelity defect since no AC/`req_master.md` line names it.
- **STORY-006 love_contracts** — AC1 and AC4 PASS; **AC2 and AC3 FAIL** — independent trace of `love-contracts.service.ts` shows `partnerId` is never populated anywhere in the module (`CreateContractDto` has no such field), so `getMyContract()`'s `{requesterId} OR {partnerId}` query can never match the partner: the partner cannot see the contract at all, not merely "cannot sign it" as the story's own artifacts (`test-results.md`, `review/review-report.md`) describe. OQ-006A is confirmed a **self-declared, self-approved, unapproved scope cut** — no row in the central OQ registry or `req_master.md`, only recorded in downstream story-local artifacts. Design Fidelity `UNVERIFIED` (no love-contracts screen captured in the reused evidence). This is the most severe single-story finding in Batch 1.
- **STORY-007 chat** — All 5 ACs PASS on independent source/test verification (realtime send/receive via socket-only ack contract, typing-ghost throttle/idle/stale timers matching ADR-013b exactly, Drift read-through history with a real dedup/paging test, and a schema-absence regression test proving no offline queue column exists). ADR-013a (no attachments) and ADR-013d (`markDelivered` never emitted) spot-checked directly, not re-trusted from `test-results.md`. R8's Socket.IO auth gap (`chat.gateway.ts` `// MOCK AUTH`) reiterated as a still-live, already-tracked, non-blocking production-readiness gap — not a new or story-specific finding. Design Fidelity `UNVERIFIED`: neither `chat` nor `ghostset` is among the 10 captured screens in the reused evidence — a requirement-wide capture-tooling gap, not a story defect, so this story alone is Classification Impact `AMBER` rather than `RED-PATCH`.
- **STORY-008 anti_ghosting** — AC1/AC3 PASS; **AC2 FAIL** — `GhostStateRow`, the widget STORY-008 built and tested specifically to surface anti-ghosting state in chat (per ADR-3), is never mounted into `chat_screen.dart`/`app_shell.dart` (confirmed by full reads: no import or reference anywhere). This was a known, explicitly tracked deferral in `architecture/solution.md` (ADR-3/§7/§8) meant to be picked up by STORY-007 or requirement integration, but it fell through both: STORY-007's own artifacts never mention it, and the requirement integration review's cross-story navigation check (§6) verified DI registration and home-entry mounting but never verified this specific named deferred item before recording `CLEAN`. Fix is narrow (mount `GhostStateRow(partnerId:)` into `ChatScreen`; dependencies already constructed) — no architecture rework needed. Design Fidelity `UNVERIFIED` (antighost settings screen is ratio-only weak evidence with known design drift; chat screen was never captured).
- **STORY-009 nhac_nho_dong_bo** — All 4 ACs PASS on independent source/test re-verification. Design Fidelity **FAIL confirmed as genuinely attributable to this story** (`main_preview.dart` maps the `alarm` screen fixture directly to this story's `ReminderScheduleScreen`, no other candidate fixture exists). Of the 3 deltas recorded in the reused visual audit: (1) hero-card gradient vs. dark translucent card — code matches this story's own `ux-spec.md`, most likely post-DONE design drift, not a story defect; (2) weekday chips stacking vertically instead of horizontally — **confirmed real layout bug**, `Wrap` of 7 chips with min tap-target sizing plus double padding doesn't fit one row on typical phone widths; (3) "missing confirmation cards/CTA" — likely a **false positive**: the code has `_ConfirmationRow`/`_PrimaryAction` gated on non-null `state.reminder`, and the visual audit ran without a live backend (an exclusion the audit's own methodology already carves out elsewhere but didn't apply consistently here). Fix scope is narrow (weekday-chip layout only), no architecture rework.
- **STORY-010 vibes** — All 4 ACs PASS; **R-010-1 (AC3 unpaired-gating) confirmed RESOLVED on current `main`** via 3 independent evidence layers: direct code trace (`cupid_app.dart` → `PairGateShell` is the sole app root, unpaired users held in `_PairingStack` with no route to `HomeScreen`/`VibeScreen`), the requirement integration review's independent confirmation of the same wiring, and a fresh isolated run of `pair_gate_cubit_test.dart` — 9/9 pass, including direct `HomeScreen findsNothing`/`findsOneWidget` assertions (the integration review's note about a pre-existing "constructor mismatch" failure in this file does not reproduce on current `main`). Design Fidelity `UNVERIFIED` for `vibe` (ratio-only weak evidence); `home`'s already-tracked FAIL is a requirement-level gap, not a new STORY-010 finding.
- **STORY-011 bun_pet** — All 3 ACs PASS on independent source verification, no functional/contract defects. Design Fidelity `UNVERIFIED` (not PASS): `pet` sits in the reused audit's ratio-only "captured, not yet reviewed" table (6.9x, same range as confirmed-FAIL screens) and `home` (hosting the pet entry point) is independently confirmed FAIL. No screenshots were recaptured, per the forbidden-by-default constraint. Recommends routing `pet`+`home` through the visual audit's own recommended harness fix before treating this story's Design Fidelity gate as resolved.
- **STORY-012 timeline** — All 4 ACs PASS on independent verification against current `main`. The story's prior `DEFERRED_ONLY` finding (parallel `AppDatabase`/`CupidDatabase` Drift-schema duplication risk) is **confirmed RESOLVED**: `git ls-files` shows no remaining `app_database.dart`, and direct reads of `cupid_database.dart`/`timeline_dao.dart` confirm timeline tables now live in the canonical `CupidDatabase`. Design Fidelity `UNVERIFIED` (no timeline screen among the 10 captured pairs) — a requirement-level gap, not a story-specific regression.
- **STORY-013 gallery** — AC1 (upload) and AC3 (unpaired gate) PASS on independent source verification; AC2 (both partners view) is a **disclosed** limitation, not a hidden failure: `gallery.service.ts` `findAll` is still `where: { userId }` on current `main` (no `coupleId`), consistent with the A1 backend-freeze/out-of-mobile-scope framing. `gallery` IS one of the 10 screens in the reused visual audit but sits in the ratio-only "captured, not yet reviewed" bucket (6.0x gap) — `UNVERIFIED`, not one of the two fully-reviewed FAIL screens. OQ Discipline gap: Open Item #1 (shared gallery vs. design's "Private Gallery" device-encrypted model) was ruled only inside the story-level `requirements/requirements.md` artifact, never escalated to the central OQ registry or `req_master.md` — notably, the story's own UX spec cites the sibling DND/Critical-Alerts conflict (which *was* escalated) as the precedent to follow, and this one wasn't. The engineering call itself is sound; the traceability isn't.
- **STORY-014 dream_jar** — AC1-AC3 functionally met on independent source verification. The prior `PATCH_REQUIRED` finding (orphaned `ContributionHistoryScreen`) is **confirmed genuinely fixed and still effective** on `main` via `git merge-base --is-ancestor` plus direct source confirmation, not merely recorded as closed. Most significant finding: the story's AC1-AC3 reinterpretation from a text "wish list" to a monetary savings-jar contribution model is real, but the approval for that reinterpretation exists only in Tech Lead-owned artifacts (`architecture/solution.md`, `coding-plan/master-plan.md`) — not a valid Scope Authority. `req_master.md` and the central OQ registry have no Open Question Triage/Approved Scope Change section covering it, and `story_master.md`'s own canonical AC text was never amended to match, despite REQ-001 being DONE and deployed since 2026-08-01 with a CLEAN integration review. This gap passed through every downstream gate unblocked. Design Fidelity `UNVERIFIED` (no capture).
- **STORY-015 expenses** — All 4 ACs independently PASS, notably re-verified with a **live re-run** of the scoped test suite (81/81 passing, matching `test-results.md`) since `flutter`/`dart` were available in this reviewer's session — the first Batch 1-3 story confirmed by direct test execution rather than source-read inference alone. All governing ADRs (ADR-007 no offline write, ADR-015.2 no client-settable "paid by", ADR-015.3 client-side aggregation, R-015.1 single Drift owner, R-015.6 schema-bump collateral fix) independently HOLD. One non-blocking evidence-hygiene finding: a scoped `flutter analyze` re-run surfaced 1 info-level lint not mentioned in prior reports, traced via `git blame` to a pre-existing STORY-012 field, not a STORY-015 regression. Design Fidelity `UNVERIFIED` — the `expense` screen has zero capture evidence at all (not even ratio-only), and its `home` entry point is independently confirmed FAIL.
- **STORY-016 profile_privacy_notifs** — AC1 (profile view/edit) and AC4 (no admin/export surface) PASS; **AC2 and AC3 FAIL as literally written** — `privacy_screen.dart` has zero editable controls (only STORY-008's `isGhostModeEnabled` exists on the backend `User` entity) and `notification_settings_screen.dart` is device-local only (`SharedPreferences`, no backend call at all), while the ACs as written promise "view and change... exposed by backend contract." This rescope (change→view-only; backend-exposed→device-local) traces only to the story-level PO artifact `requirements/requirements.md` — not a valid Scope Authority; `req_master.md` and the central OQ registry have no covering Triage/Approved Scope Change entry, and `story_master.md`'s own canonical AC text was never amended, with the prior review chain explicitly working from a "reworded" worktree copy instead of the canonical wording. A separate data-export-button conflict (system UX memory §8 vs AC4) was flagged by UX and PO but also never escalated. The underlying engineering call (respecting the A1 backend freeze) is sound; the governance/traceability isn't. Design Fidelity `UNVERIFIED`/weak across all 3 owned screens. Report file for this story was written by Scrum Master transcribing the reviewer's returned findings verbatim, since the reviewer's own tooling did not persist it.

### AC-by-AC Implementation Traceability

| Story | AC | Result | Evidence |
|-------|----|--------|----------|
| STORY-001 | AC1 (4-combination theme matrix) | PASS | `cupid_theme.dart` `buildCupidTheme` + `theme_matrix_test.dart` |
| STORY-001 | AC2 (vi/en ARB pipeline) | PASS | `l10n/arb/app_{vi,en}.arb` + `arb_parity_test.dart` |
| STORY-001 | AC3 (dark+vi default, flag-gated light/en) | PASS | `cupid_feature_flags.dart` + `cupid_app.dart` + `feature_flags_test.dart` |
| STORY-001 | AC4 (no screen-specific forking) | PASS | `design_system.dart` barrel + `no_fork_guard_test.dart` source-scan guard |
| STORY-002 | AC1 (client generated, not hand-written) | PASS | Vendored spec + independently re-run offline generator, byte-identical |
| STORY-002 | AC2 (typed models/methods per epic) | PASS | Generated API classes per epic + smoke test re-run |
| STORY-002 | AC3 (deterministic regeneration) | PASS | Full generate+build_runner re-run, `git status --porcelain` empty |
| STORY-002 | AC4 (backend untouched) | PASS | Repo-wide `git status --porcelain` before/after, no `backend/` change |
| STORY-003 | AC1 (sign-in reaches authenticated area) | PASS | `auth_repository.dart` + `splash_screen.dart` routing, `splash_screen_test.dart` |
| STORY-003 | AC2 (expired token refreshed transparently) | PASS | `cupid_auth_interceptor.dart` single-flight refresh, 7/7 isolated test pass |
| STORY-003 | AC3 (session persists across cold start) | PASS | `cupid_session.dart` + `session_gate_cubit.dart`, 4/4 isolated test pass |
| STORY-003 | AC4 (sign-out clears session + cached data) | PASS | `cupid_session.dart:signOut()` teardown + confirm dialog, tests pass |
| STORY-004 | AC1-4 | PASS | Dedup/lifecycle tests, Firebase token in handshake auth, spike findings documented (per `Iris-QC-3` summary; source file not independently re-read by Scrum Master) |
| STORY-005 | AC1 (generate/send invitation) | PASS | `pairing_repository.dart` + `invite_screen.dart`, backend confirmed live |
| STORY-005 | AC2 (accept → both sides reflect active pair) | PASS | `joincode_screen.dart`/`waiting_screen.dart` converge on `PairedScreen` |
| STORY-005 | AC3 (couple-only enforcement) | PASS | `pairing_failure.dart` 409 classification, inline error rendering |
| STORY-005 | AC4 (paired vs unpaired gating) | PASS | `pair_gate_cubit.dart` fail-closed default + `pair_gate_shell.dart` switch |
| STORY-006 | AC1 (create/propose contract) | PASS | `love_contract_repository.dart` + `love-contracts.service.ts:create()` |
| STORY-006 | AC2 (partner can view/acknowledge/accept) | **FAIL** | `partnerId` never populated; `getMyContract()`'s partner-branch can never match; no partner-visible view exists anywhere in the client |
| STORY-006 | AC3 (both partners can view list/detail) | **FAIL** | Same root cause — only the creator can view anything |
| STORY-006 | AC4 (unpaired users cannot access) | PASS | `love_contract_entry_tile.dart` `resolvePairingState()`-gated, fails closed |
| STORY-007 | AC1 (send/receive text realtime) | PASS | `chat_repository.dart` socket-only send+ack, `newMessage` upsert; `chat.gateway.ts` fan-out contract |
| STORY-007 | AC2 (typing-ghost both directions) | PASS | `ghost_cubit.dart` throttle/idle/stale timers match ADR-013b table exactly |
| STORY-007 | AC3 (message history on reopen) | PASS | `chat_repository.dart` `watchThread()` + `message_dao_test.dart` dedup/paging assertions |
| STORY-007 | AC4 (no offline queue) | PASS | `messages_table.dart` schema has no pending/queue column; `message_dao_test.dart` scans column names as a regression gate |
| STORY-007 | AC5 (chat inaccessible unpaired) | PASS | `chat_entry_gate.dart` + `app_shell.dart` tab removed (not just hidden) when locked |
| STORY-008 | AC1 (home entry card) | PASS | Confirmed present in current source |
| STORY-008 | AC2 (anti-ghosting state surfaced in chat) | **FAIL** | `GhostStateRow` built/tested per ADR-3 but never mounted into `chat_screen.dart`/`app_shell.dart` — no import/reference anywhere |
| STORY-008 | AC3 (pairing guard) | PASS | Confirmed present in current source |
| STORY-009 | AC1-AC4 | PASS | Independently re-verified against `mobile/lib/features/reminders/**` and `test-results.md` |
| STORY-010 | AC1-AC2 | PASS | No regression signal |
| STORY-010 | AC3 (unpaired-gating, R-010-1) | PASS | `PairGateShell` sole app root + `pair_gate_cubit_test.dart` 9/9 pass incl. direct `HomeScreen findsNothing`/`findsOneWidget` |
| STORY-011 | AC1-AC3 | PASS | `pet_repository.dart`/`pet_cubit.dart`/`pet_screen.dart` independently verified, no defects |
| STORY-012 | AC1-AC4 | PASS | Create-flow wiring, offline fail-fast, pairing-gate at `home_screen.dart:72/312` |
| STORY-013 | AC1 (upload photo to shared gallery) | PASS | `gallery_screen.dart` both add-photo call sites wire a real `GalleryUploadCubit`/`GalleryUploadSheet`; `GalleryApi` two-step `POST /uploads`→`POST /gallery` matches frozen A1 contract |
| STORY-013 | AC2 (both partners view gallery contents) | **DEFERRED** (disclosed, backend-only) | `gallery.service.ts` `findAll` still `where: { userId }` on current `main`, no `coupleId`; client is correctly built couple-scoped and needs zero further mobile changes once backend is fixed; A1 freeze forbids in-story fix |
| STORY-013 | AC3 (unpaired users cannot access) | PASS | `gallery_cubit.dart` emits `GalleryLocked()` before any fetch when `partnerId == null`; real always-mounted tab destination in `app_shell.dart`, not a hidden route |
| STORY-014 | AC1 (add dream/wish entry) | MET, against re-mapped feature | `create_dream_jar_sheet.dart` + `dream_jar_hero_card.dart` — shipped as a monetary savings-jar contribution, not a text wish/dream list (see OQ Discipline) |
| STORY-014 | AC2 (both partners view jar contents) | MET | `dream_jar_detail_screen.dart` wires `ContributionHistoryScreen` navigation; prior PATCH_REQUIRED fix (`99bbd8e`) confirmed merged via `git merge-base --is-ancestor` |
| STORY-014 | AC3 (unpaired users cannot access) | MET | `dream_jar_detail_screen.dart` `BlocBuilder` has explicit `DreamJarDetailUnpaired()` branch sourced from backend 404 mapping |
| STORY-015 | AC1 (add expense entry) | PASS | `expenses_repository.dart` `create()` posts exactly `{category, amount, description?, date}`; `add_expense_sheet_test.dart` re-run live by reviewer against mocked HTTP, passed |
| STORY-015 | AC2 (both partners view shared expense history) | PASS | `expense_history_cubit.dart` `filteredRows` filters by category only, no `userId` predicate anywhere in the read path |
| STORY-015 | AC3 (offline-readable history; new entries need connectivity) | PASS | `ExpenseDao` has no user-write method at all; `AddExpenseCubit` holds no DAO reference — structural guarantee, not convention |
| STORY-015 | AC4 (unpaired users cannot access) | PASS | `ExpensesEntryPoint` resolves `PairingStateReader.isPaired()` once per mount, renders `PairingRequiredGate` when false; secondary corroborating watch-repository re-gate on 404 |
| STORY-016 | AC1 (profile view/edit) | PASS | `me_screen.dart`/`profile_edit_screen.dart` — editable name/DOB/zodiac, avatar read-only (disclosed DEC-1 limitation) |
| STORY-016 | AC2 ("view and change privacy... exposed by backend contract", as literally written) | **FAIL** | `privacy_screen.dart` has zero `Switch`/`PATCH`/editable control; `isGhostModeEnabled` (STORY-008-owned) is the only privacy field on the backend `User` entity |
| STORY-016 | AC3 ("view and change notification... exposed by backend contract", as literally written) | **FAIL** | `notification_settings_screen.dart` is device-local only (`SharedPreferences`), zero `Dio`/`CupidApi` import; backend has no notification module/field at all |
| STORY-016 | AC4 (no admin/data-export surface) | PASS | `me_screen.dart` has exactly 4 forward-link rows, no Digital Divorce, no export button, no functional `role` mapping |

### OQ Discipline Findings

| Story | Relevant OQ | Blocking Scope | Triage / Override Present? | Classification Impact |
|-------|-------------|-----------------|------------------------------|-----------------------|
| STORY-001 | OQ5 (light theme & EN in v1) | Light theme / en locale exposure | YES — resolved explicitly in `story_master.md` + central `conflicts_open_questions.md`, confirmed at code level | none |
| STORY-002 | none | — | n/a | none |
| STORY-003 | R8 (forward-compat token exposure only) | Firebase token for handshake.auth.token | YES — delivered in code (`idToken()`/`idTokenStream`); backend-side gap separately tracked, not absorbed | none |
| STORY-004 | none (per Iris-QC-3 summary) | — | n/a | none |
| STORY-005 | D2 (couple-type picker exclusion, story-local) | `invite` screen picker + CTA | Flagged to PO/Tech Lead (UX §7, master-plan §1), not silently dropped, but no central OQ or `## Approved Scope Change` confirms it | RED-PATCH-eligible AC-coverage gap — recommend PO-owned AC correction |
| STORY-006 | OQ-006A (dual-signature ritual) | Partner sign (AC2) and partner view (AC3, broader than story records) | **NO** — self-declared/self-approved only in downstream story artifacts; no central OQ, no PO triage, no user decision found | **RED-PATCH** — confirmed unapproved scope cut |
| STORY-007 | none (attachments conditionally-in-scope determination is a Tech Lead ADR-authority call, not a scope cut) | — | n/a — no new OQ Triage/Approved Scope Change needed | none |
| STORY-008 | ADR-3 deferred `GhostStateRow` mounting (implementation gap, not an OQ) | Anti-ghosting visibility in chat (AC2) | Tracked in `architecture/solution.md`/`master-plan.md`/`test-results.md` as a scheduling item for STORY-007/integration, but never actually picked up by either | **RED-PATCH** — AC FAIL, not merely an evidence gap |
| STORY-009 | ASSUMPTION-1 (reminder copy wording) | Non-blocking copy choice only | Known, non-blocking, no PO ruling yet | none (does not affect AC pass) |
| STORY-010 | R-010-1 (AC3 unpaired-gating) | — | Confirmed RESOLVED on `main` via 3-layer independent evidence | none — resolved |
| STORY-011 | none | — | n/a | none |
| STORY-012 | none (dual-database DEFERRED_ONLY risk, not an OQ) | Merge-to-main risk, not an AC | Confirmed RESOLVED — no `app_database.dart` remains, tables migrated to canonical `CupidDatabase` | none — resolved |
| STORY-013 | Open Item #1 (gallery model conflict — "shared" vs. design source's "Private Gallery") | Scope-defining ruling (shared/backend model stands) | **NO** — ruled only in story-level `requirements/requirements.md`; not in central OQ registry or `req_master.md`, despite the story's own UX spec citing the DND/Critical-Alerts sibling conflict (which *was* escalated) as the precedent to follow | **RED-PATCH** — confirmed unapproved traceability gap (engineering call itself is sound) |
| STORY-014 | wish-list-vs-savings-jar AC1-AC3 reinterpretation | Text "wish/dream list" AC reinterpreted as monetary savings-jar feature | **NO** — authorized only in Tech Lead's own `architecture/solution.md`/`coding-plan/master-plan.md`; `req_master.md` and central OQ registry (both read in full) have no covering entry; flagged Product Owner correction never made even after REQ-001 reached DONE/deployed | **RED-PATCH** — confirmed unapproved scope/meaning cut |
| STORY-015 | none — pre-authorized delegation | `expenses` contract-field question (currency, splitting, "paid by") delegated to Tech Lead before coding-plan per `story_master.md` | YES — pre-authorized condition; Tech Lead's ADR-015.2/015.4/015.4a determinations are technical calls inside that delegated authority, not a silent cut | none |
| STORY-016 | AC2/AC3 rescope (change→view-only; backend-exposed→device-local) | Privacy/notification "change" capability and backend-contract exposure | **NO** — ruled only in story-level PO artifact `requirements/requirements.md`; `req_master.md` and central OQ registry have no covering entry; `story_master.md`'s own canonical AC text never amended | **RED-PATCH** — confirmed AC FAIL as literally written, not merely an unapproved cut |

### Open Question Relevance

| OQ | Status | Relevant To | Blocked Scope | Unblocked Scope | Triage / Approval Source | Classification Impact |
|----|--------|-------------|---------------|-----------------|---------------------------|------------------------|
| OQ4 (Drift vs hydrated_bloc) | RESOLVED | REQ-001 (all stories) | none | offline persistence architecture | `req_master.md` D-series architecture decisions | none |
| OQ5 (light theme / EN in v1) | RESOLVED | STORY-001 | light theme / EN enablement | dark theme / VI shipped; light/EN built-but-not-enabled | `req_master.md` | none |
| OQ-006A (dual-signature ritual) | **CONFIRMED UNRESOLVED** (reviewer-verified, `Iris-QC-5`) | STORY-006 | dual-signature capability — worse than documented: partner cannot even view the contract (AC2/AC3 FAIL) | none — reduced to private, creator-only clause checklist | story artifact only, not central/PO-owned; confirmed no `## Open Question Triage`/`## Approved Scope Change` exists in `req_master.md` or `conflicts_open_questions.md` | **RED-PATCH (confirmed)** |
| D2 (couple-type picker exclusion, STORY-005, story-local) | UNRESOLVED (no central triage found) | STORY-005 | Couple-type picker + "Continue → Fingerprint Vow" CTA on `invite` | Screen ships without personalization | Flagged to PO in UX §7 + master-plan §1, not silently dropped, but no central OQ/PO triage confirms the exclusion | RED-PATCH-eligible AC-coverage gap |
| R-010-1 (AC3 unpaired-gating) | **RESOLVED** (reviewer-confirmed, `Iris-QC-10`) | STORY-010, requirement integration | none | AC3 enforced on current `main` — `PairGateShell` sole app root + 9/9 `pair_gate_cubit_test.dart` pass | independent 3-layer verification (code trace, integration review corroboration, fresh isolated test run) | none — confirmed resolved |
| ADR-3 `GhostStateRow` mounting (STORY-008, cross-story scheduling gap) | **CONFIRMED UNRESOLVED** (reviewer-verified, `Iris-QC-8`) | STORY-008 AC2 | Anti-ghosting state never visibly surfaced in chat | none — explicitly tracked as a "STORY-007 or requirement integration" scheduling item in `architecture/solution.md` ADR-3/§7/§8 but never picked up by either | Tech Lead ADR tracked it; no story or integration review ever verified the mount happened | **RED-PATCH** — confirmed AC FAIL, narrow fix identified (mount `GhostStateRow` into `ChatScreen`) |
| Open Item #1 (gallery model conflict, STORY-013, story-local) | **CONFIRMED UNRESOLVED** (reviewer-verified, `Iris-QC-13`) | STORY-013 | none — AC2 (both-partners view) already independently DEFERRED for the unrelated backend-freeze reason | Shared/backend gallery model ships as-is; "Private Gallery" design concept deferred to a separate, unnamed future backlog item | Ruled only in story-level `requirements/requirements.md`; sibling DND/Critical-Alerts conflict *was* escalated to `conflicts_open_questions.md`, this one was not | **RED-PATCH** — confirmed unapproved traceability gap (engineering call itself sound) |
| wish-list-vs-savings-jar AC reinterpretation (STORY-014, story-local) | **CONFIRMED UNRESOLVED** (reviewer-verified, `Iris-QC-14`) | STORY-014 AC1-AC3 | none functionally — feature ships and works as a savings jar | Text "wish/dream list" AC reinterpreted and shipped as a monetary VND savings-jar contribution feature | Authorized only in Tech Lead's `architecture/solution.md`/`coding-plan/master-plan.md`; Product Owner correction flagged but never made, even post-DONE/deployed | **RED-PATCH** — confirmed unapproved scope/meaning cut |
| AC2/AC3 rescope (STORY-016, story-local) | **CONFIRMED UNRESOLVED** (reviewer-verified, `Iris-QC-16`) | STORY-016 AC2/AC3 | Privacy/notification "change" capability and backend-contract exposure, as literally written | Privacy is view-only (no editable control beyond STORY-008's ghost-mode field); notifications are device-local only | Ruled only in story-level `requirements/requirements.md`; `story_master.md`'s canonical AC2/AC3 text never amended; review chain worked from a "reworded" worktree copy, not canonical wording | **RED-PATCH** — confirmed AC FAIL as literally written, not merely an unapproved cut |

### UX System Memory Violations

None found in Batch 1 (STORY-001..006), Batch 2 (STORY-007..012), or Batch 3
(STORY-013..016). STORY-016's secondary data-export-button conflict (system
UX memory §8 vs AC4) was flagged by UX and PO but never escalated — noted
under OQ Discipline Findings, not counted as a UX Memory violation since no
implementation contradicts the memory itself.

### Overall Substantive Verdict

**COMPLETE — all 16 stories (STORY-001..016) audited across Batch 1
(STORY-001..006), Batch 2 (STORY-007..012), and Batch 3 (STORY-013..016).**

Per-story classification impact: **RED-PATCH** — STORY-001, STORY-003,
STORY-005, STORY-006, STORY-008, STORY-009, STORY-013, STORY-014, STORY-016
(9 stories). **AMBER** — STORY-007, STORY-011, STORY-015 (3 stories).
**GREEN** — STORY-002, STORY-004, STORY-010, STORY-012 (4 stories).

Confirmed RED-PATCH-sufficient findings, independent of Design Fidelity:
- STORY-006 AC2/AC3 FAIL + unapproved OQ-006A scope cut (partner cannot view
  or sign the contract at all).
- STORY-008 AC2 FAIL (`GhostStateRow` never mounted — a cross-story
  scheduling gap that fell through both STORY-007 and requirement
  integration review; narrow fix identified).
- STORY-016 AC2/AC3 FAIL as literally written (privacy/notifications
  rescoped to view-only/device-local without authoritative approval, and the
  canonical AC text was never amended to match).
- STORY-009's Design Fidelity FAIL confirmed as a real, narrow-scope layout
  bug (weekday chips).
- Unapproved OQ/scope-authority gaps confirmed across STORY-005 (D2, couple-
  type picker exclusion), STORY-013 (Open Item #1, gallery model conflict —
  its own UX spec cites an escalated sibling precedent it didn't follow),
  and STORY-014 (wish-list-vs-savings-jar reinterpretation, flagged but never
  resolved even after the requirement went DONE/deployed).

Items reviewer-confirmed RESOLVED, not gaps: R-010-1 (STORY-010 AC3
unpaired-gating), STORY-012's dual-database DEFERRED_ONLY risk, STORY-013's
AC1/AC3 (upload flow + fork-guard blockers), and STORY-014's prior
PATCH_REQUIRED finding (orphaned `ContributionHistoryScreen`, confirmed
genuinely fixed and merged on `main`).

All ACs individually verified: YES (all 16 stories, all ACs) — with 4
confirmed AC FAILs: STORY-006 AC2/AC3, STORY-008 AC2, STORY-016 AC2/AC3.
OQ discipline satisfied: **NO** — 6 confirmed unapproved scope/traceability
gaps across STORY-005 (D2), STORY-006 (OQ-006A), STORY-008 (ADR-3 scheduling
gap), STORY-013 (Open Item #1), STORY-014 (wish-list/savings-jar), and
STORY-016 (AC2/AC3 rescope). None of these traces to a central OQ registry
row, a `req_master.md` `## Open Question Triage`/`## Approved Scope Change`
section, or an explicit user decision — every one was ruled only in a
downstream story-level, Tech-Lead-owned, or UX/PO-local artifact.
Design Fidelity: **FAIL** (see below) — independently forecloses GREEN/AMBER
for the whole requirement regardless of the AC/OQ picture above.

## Design Fidelity

Source of truth reused verbatim per user instruction — **not recaptured**:
`data/requirements/REQ-001_cupid_flutter_mobile_app/integration-review/mobile-visual-audit.md`
(screenshots: `integration-review/mobile-screenshots/`)

- **Result: FAIL**
- Design source: locked `claude-design` (`cupid-app-design-system`, entry `Cupid App.dc.html`), confirmed mandatory-gating via `data/devops/system/design-fidelity-config.json` (`ui_surface: true`).
- Scope captured: 10 of 37 design screens, Android emulator only, dark theme only. 27/37 design screens have **zero** capture or evidence.
- Capture method: `lib/main_preview.dart` on `emulator-5554` vs. `render-design-canvas.js` renders of the locked design source.
- Non-defect callouts already recorded in the source evidence (preserved, not re-litigated): missing tab bar in harness captures is a harness limitation, not a defect; empty/error states reflect backend being down during capture, not a design defect.
- **Screens reviewed in full detail (2 of 37): `alarm` and `home` — both FAIL.**
  - `alarm`: gradient, color, and layout mismatches; missing design elements versus the reference render.
  - `home`: still renders the literal STORY-001 placeholder text — never built to the design at all.
- **Screens with weak evidence only (8 of 37):** `antighost`, `gallery`, `invite`, `joincode`, `paired`, `pet`, `privacy`, `vibe` — PNG-size-ratio comparison only (ratios 1.0x–9.8x versus reference), not a full visual comparison. Not sufficient to call PASS or FAIL on their own.
- **Screens with zero evidence (27 of 37):** never captured under this audit.

Per the Classification Guardrails: a Design Fidelity row of `DEVIATION` or `UNVERIFIED` blocks `GREEN`/`AMBER` exactly like a failed AC. Given 2/2 detailed-comparison screens are FAIL, 8/37 screens are UNVERIFIED (ratio-only), and 27/37 screens are entirely UNVERIFIED, this requirement **cannot** be classified `GREEN` or `AMBER` regardless of AC pass results, and this holds independent of the reviewer fan-out outcome below. No story's acceptance criteria assert conformance to the design reference, which is itself an AC-coverage gap requiring Product-Owner-owned correction under the RED-PATCH path.

## Audit Classification

**Overall Verdict: RED-PATCH — CONFIRMED (all 16 stories audited, fan-out complete).**

This verdict is independently over-determined by three separate, non-overlapping
categories of confirmed finding, any one of which alone would already require
RED-PATCH:

1. **Design Fidelity FAIL** (requirement-wide) — 2/37 screens fully compared
   (both FAIL: `alarm`, `home`), 8/37 screens ratio-only/weak evidence, 27/37
   screens never captured. No story AC asserts design conformance. Per the
   Classification Guardrails, a `DEVIATION`/`UNVERIFIED` Design Fidelity row
   blocks GREEN/AMBER exactly like a failed AC, and this holds independent of
   every other finding below.
2. **Confirmed AC FAILs** (4 across 3 stories) — STORY-006 AC2/AC3 (partner
   cannot view or sign the love contract at all — worse than the story's own
   documentation describes), STORY-008 AC2 (`GhostStateRow` anti-ghosting
   indicator never mounted into the chat screen — a cross-story scheduling
   gap that fell through both STORY-007 and requirement integration review),
   STORY-016 AC2/AC3 (privacy/notification "change" capability promised by
   the canonical AC text does not exist — privacy is view-only, notifications
   are device-local with no backend contract at all).
3. **Confirmed unapproved scope/traceability gaps** (6 across 5 stories) —
   STORY-005 (D2, couple-type picker exclusion), STORY-006 (OQ-006A,
   dual-signature ritual dropped to creator-only), STORY-008 (ADR-3
   `GhostStateRow` scheduling gap), STORY-013 (Open Item #1, gallery model
   conflict — its own UX spec cites an escalated sibling precedent it didn't
   follow), STORY-014 (wish-list-vs-savings-jar AC reinterpretation, flagged
   but never resolved even after the requirement went DONE/deployed),
   STORY-016 (AC2/AC3 rescope, canonical AC text never amended). None of
   these six traces to a central OQ registry row, a `req_master.md`
   `## Open Question Triage`/`## Approved Scope Change` section, or an
   explicit user decision — every one was ruled only in a downstream
   story-level, Tech-Lead-owned, or UX/PO-local artifact, per this audit's
   Scope Authority Gate.

Per-story classification impact: **RED-PATCH** (9) — STORY-001, STORY-003,
STORY-005, STORY-006, STORY-008, STORY-009, STORY-013, STORY-014, STORY-016.
**AMBER** (3) — STORY-007, STORY-011, STORY-015. **GREEN** (4) — STORY-002,
STORY-004, STORY-010, STORY-012.

Justification: this is exactly the guardrail scenario the audit exists to
catch — "a full AC pass on capability criteria is compatible with shipping
the wrong screen entirely" — compounded here by four genuine AC FAILs and
six unapproved scope cuts that passed through every downstream gate (story
review, requirement integration review `Outcome: CLEAN`, and deployment)
without ever being caught.

## Recommended Path

The Substantive Reviewer Audit fan-out is complete (16/16 stories, 3
batches, named `Iris-QC` reviewers). Per `shared-verdict-and-plan.md`
"User Confirmation Before State Changes," this combined verdict (Design
Fidelity FAIL + the 4 confirmed AC FAILs + the 6 confirmed unapproved scope
cuts) must be presented to the user for explicit confirmation before any
RED-PATCH hardening stories, AC corrections, or other state changes are
created. No such state change has been made yet.

Proposed hardening scope, pending user confirmation, prioritized by severity:
1. STORY-006 (AC2/AC3 FAIL) — mount partner-visibility (`partnerId`
   population + partner-branch query fix); narrow, root cause identified.
2. STORY-008 (AC2 FAIL) — mount `GhostStateRow(partnerId:)` into
   `ChatScreen`; narrow, dependencies already constructed.
3. STORY-016 (AC2/AC3 FAIL) — Product-Owner-owned ruling on whether to build
   the promised change/backend-exposed capability or formally amend the
   canonical AC text to view-only/device-local.
4. STORY-014 — Product-Owner-owned ruling on the wish-list-vs-savings-jar
   reinterpretation and the epic-4/epic-5 tag.
5. STORY-013 — central escalation of Open Item #1 (gallery model conflict),
   following the same precedent as the sibling DND/Critical-Alerts conflict.
6. STORY-005 — PO-owned AC correction for the D2 couple-type-picker
   exclusion.
7. STORY-006 — central OQ-registry disposition of OQ-006A (dual-signature
   ritual).
8. STORY-009 — narrow layout fix for the weekday-chip `Wrap` overflow.
9. Design Fidelity — broaden capture-tooling coverage (27/37 screens
   currently uncapturable) before any future fidelity re-audit.
