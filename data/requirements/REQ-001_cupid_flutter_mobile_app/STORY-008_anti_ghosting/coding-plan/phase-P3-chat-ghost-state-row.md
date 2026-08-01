# Phase P3 – Chat Ghost-State Row And Storm-Status Polling (AC2 Seam)

## 1. Objective

Deliver AC2's surfacing widget: a self-contained ghost-state row that renders the
"seen, no reply" signal and the penalty-branched action, exported as the mount
seam STORY-007's chat screen consumes (ADR-3).

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-chat-ghost-state-row.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P0
- Parallelizable: YES (disjoint from P1 and P2 except the append-only ARB files)
- Write Scope:
  - `mobile/lib/features/anti_ghosting/presentation/ghost_storm_cubit.dart`
  - `mobile/lib/features/anti_ghosting/presentation/widgets/ghost_state_row.dart`
  - `mobile/test/features/anti_ghosting/presentation/ghost_storm_cubit_test.dart`
  - `mobile/test/features/anti_ghosting/presentation/ghost_state_row_test.dart`
  - `mobile/lib/l10n/arb/app_en.arb` (append keys only)
  - `mobile/lib/l10n/arb/app_vi.arb` (append keys only)
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A for this phase
  - Readiness Check: N/A for this phase
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `GhostStormCubit`
  - `GhostStateRow(partnerId: ...)` — the chat mount seam
- Shared Interfaces Consumed:
  - `GhostConfigRepository.fetchStormStatus`, `Penalty`, `StormStatus` (P0)
  - `CupidColorTokens`, `CupidIcon`
- Risk Surfaces:
  - Storm polling lifecycle
  - Design-system no-fork guard
  - l10n parity
  - AC2 end-to-end mount (cross-story, non-blocking here)
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §2.4;
    `../architecture/solution.md` ADR-2 and ADR-3
  - consumer contract: `GhostStateRow` takes only `partnerId` and needs no chat
    types, so STORY-007 can mount it with one line
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC2
  - architecture: `../architecture/solution.md` §6 ADR-2 (refresh triggers and
    timer lifecycle), ADR-3 (mount seam)
  - OQ constraints: none
  - upstream phase outputs: P0 repository, `StormStatus`, `Penalty`
  - UX constraints, if truly required: `../ux/uiux-spec.md` §2.4 (row placement,
    penalty branching, CTA suppression), §4 (live-region announcement, no
    colour-only signalling)
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: one polling cubit plus one presentational row
  - Source/Test File Count: 4 source/test files, plus 2 append-only ARB edits
  - Split Required: NO
  - Split Rationale: N/A

## 2. Required Reads

- `../story_master.md` AC2
- `../architecture/solution.md` §6 ADR-2, ADR-3; §4 Risk Surfaces
- `../ux/uiux-spec.md` §2.4, §4
- P0 outputs: `ghost_config_repository.dart`, `ghost_config_models.dart`
- `mobile/lib/features/anti_ghosting/anti_ghosting.dart` (append exports; created
  by P2 — if P3 runs first, create the barrel and let P2 append to it)

## 3. Tasks

- Add `GhostStormCubit(partnerId)` that fetches storm status on start, on
  external `refresh()` (called by the host screen on focus), and on app
  foreground resume. While the row is visible and the app is foregrounded, run a
  single 60s periodic refresh; cancel the timer on `close()` and whenever the app
  backgrounds, and restart it on resume (ADR-2). No polling in any other state.
- Add `GhostStateRow(partnerId:)`, a self-contained widget that owns its
  `GhostStormCubit` and requires no chat-module type, so STORY-007 mounts it with
  one line below the message list and above the composer.
- Render nothing when there is no seen/no-reply signal. When there is one, render
  the neutral amber "Seen {n} min ago, no reply" line paired with a timer icon and
  text label — never colour alone.
- Branch the action pill on the active penalty: `emoji_storm` -> the storm CTA;
  `noise` -> the noise CTA with its own icon and copy; `none` or no active config
  -> suppress the CTA entirely while still showing the neutral seen line.
- Only render the CTA when `eligible` is true **and** the penalty is
  `emoji_storm` or `noise`.
- Announce the CTA once via a live region when it newly appears; do not
  re-announce on every rebuild or poll tick (UX §4).
- Do not add a configuration entry point inside the row — configuration lives on
  the home card (UX §2.4).
- Do not create, edit, or import anything under `mobile/lib/features/chat/`. The
  actual mount is STORY-007's or requirement integration's one-line change.
- Append the row's copy keys to both `app_en.arb` and `app_vi.arb`, keeping
  "Emoji Storm" untranslated in `vi`.
- Record the mount instruction as a doc comment on `GhostStateRow` so the
  consuming story does not need to re-read this plan.

## 4. Acceptance Criteria

- The row renders the neutral seen/no-reply line whenever the repository reports
  a seen-but-unanswered message, verified by widget test.
- The CTA appears only for `eligible: true` with `emoji_storm` or `noise`, and is
  suppressed for `none`, for no active config, and for `eligible: false` —
  verified by widget test across all five cases.
- The 60s timer starts only while visible and foregrounded, and is cancelled on
  `close()` and on background, verified by cubit test with a controlled clock.
- The CTA live-region announcement fires once per appearance, not per rebuild.
- `GhostStateRow`'s constructor takes only `partnerId`, so it has no compile
  dependency on chat code.
- No file under `mobile/lib/features/chat/` is created or modified.
- `arb_parity_test` and `no_fork_guard_test` stay green.
- Known deferral: end-to-end AC2 evidence requires the STORY-007 chat mount and
  is explicitly out of this phase (ADR-3). Report this in `test-results.md`
  rather than claiming AC2 is fully demonstrated in-branch.

## 5. Planned Outputs

- Code directories or files: the six paths in Write Scope
- Contracts or schemas: `GhostStateRow` mount seam exported from the feature barrel
- Requirement configuration guide updates: none
- Notes or evidence: the mount instruction plus the AC2 deferral note for P4

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, chat-surfacing widget
- Required levels:
  - unit: `ghost_storm_cubit_test.dart` — fetch on start, refresh on focus,
    timer start/cancel on foreground/background/close, failure handling
  - integration: `ghost_state_row_test.dart` — the five render cases driven
    through a fake repository
  - mobile build/type-check/static-analysis: `flutter analyze` on `mobile/`
- Required checks: `flutter test test/features/anti_ghosting/`,
  `flutter test test/l10n/arb_parity_test.dart`,
  `flutter test test/design_system/no_fork_guard_test.dart`, `flutter analyze`
- Mobile discoverability / navigation integration: not applicable to this phase —
  the row is mounted by its host screen; the story's discoverable entry point is
  delivered in P2
- Minimum gates by risk surface: polling lifecycle -> timer cancellation test;
  no-fork guard and ARB parity -> existing tests green
- Required regression or contract coverage: no chat-path file appears in this
  phase's diff
- Evidence format: concise rows appended to `coding-plan/test-results.md` in P4
- Verification strategy:
  - Targeted tests/regression/contract checks: as above
  - Build/type-check/lint command when required:
    `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter analyze` in `mobile/`
  - Required assertion evidence: per-case CTA presence/absence assertions and an
    explicit timer-cancellation assertion

## 7. Status

- Status: DONE
- Last updated: 2026-07-30
- Evidence:
  - `flutter test test/features/anti_ghosting/` — 62 passed, 0 failed
  - `flutter test test/l10n/arb_parity_test.dart` — 4 passed, 0 failed
  - `flutter test test/design_system/no_fork_guard_test.dart` — 1 passed, 0 failed
  - `flutter analyze` (full `mobile/`): exits non-zero, but every reported
    issue is inside the untracked, gitignored
    `build/ios/SourcePackages/checkouts/flutterfire/...` CocoaPods checkout
    tree (pre-existing stale build artifact, unrelated to any Dart source
    under `lib/`/`test/`, not touched by this phase). Scoped re-run —
    `flutter analyze lib/features/anti_ghosting test/features/anti_ghosting
    test/l10n test/design_system` — reports 0 errors/warnings and 7 `info`
    lint hints, 4 net-new in `ghost_storm_cubit.dart` for
    `prefer_initializing_formals`, the same info-level style already present
    and accepted in this codebase's `anti_ghost_cubit.dart` and
    `ghost_config_repository.dart` (kept as named public constructor
    parameters distinct from private field names; not addressed for the same
    reason those precedents were not).
- Deviations from literal task wording:
  - Task 3/AC1 literally read "Seen {n} min ago, no reply". The real
    `GET /ghost-config/storm-status/:partnerId` contract
    (`backend/src/modules/ghost-config/ghost-config.service.ts`) returns only
    `{eligible, penalty}` — no seen timestamp. Per ADR-5 ("nothing
    client-only invented"), no client-side elapsed-time clock was added.
    `eligible: true` alone is the row's "seen, no reply" trigger (this is
    already the backend's own definition of eligibility — a seen, unanswered
    message past the couple's configured timeout), and the copy is the
    static "Seen, no reply yet" / vi "Đã xem, chưa trả lời" instead of a
    literal minute count. Documented in the `GhostStateRow` doc comment.
- Known deferral (anticipated by AC list): end-to-end AC2 evidence requires
  the STORY-007 chat mount and is out of this phase's scope (ADR-3); to be
  reported in `coding-plan/test-results.md` in P4, not claimed here.
