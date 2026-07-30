# Phase P6 – Verification

## 1. Objective

Verify the mobile lane output and story-level readiness for the review gate:
AC1-AC4 traceability, the ADR-007 offline bounds, and the resolved contract
conflicts.

## 1A. Ownership

- Phase ID: P6
- Canonical Phase File: `phase-P6-verification.md`
- Owner: Mobile Developer
- Lane: Mobile Verification

## 1B. Phase Metadata

- Depends On: P5
- Parallelizable: NO
- Write Scope:
  - `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-015_expenses/coding-plan/test-results.md`
  - lane-owned test files only, if a gap is found while verifying
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE — the registry readiness signal for this app is a
    widget test (`Key('home_screen_ready_signal')` via `flutter test`), not an HTTP
    probe, and it is already covered by the P5 regression check
  - Build Command Source: runtime registry `buildCommand` = `flutter build apk --debug`
  - Startup Command Source: N/A
  - Readiness Check: `home_screen_ready_signal` widget test
  - Port Contract: N/A
  - SDK note: Flutter is **not on PATH** on this machine; resolve via
    `FLUTTER_SDK_PATH` (default `$HOME/flutter`) per the registry `sdk.resolutionOrder`

## 2. Required Reads

- `../story_master.md` (AC1-AC4)
- `../architecture/solution.md` §4 risk table and §7 ADRs
- the `## 6. Test Scope` section of `phase-P1` … `phase-P5`
- P1-P5 implementation outputs
- `../ux/uiux-spec.md` §5 only (the offline bound is the story's highest-risk surface)

## 3. Verification Tasks

- Confirm `master-plan.md` still uses the required Phase Overview table schema.
- Confirm each of P1-P6 maps to exactly one canonical `phase-Px-*.md` file and no
  duplicates exist.
- Run `flutter analyze` (clean) and the full `flutter test` suite.
- Run `flutter build apk --debug` as the mobile build/type-check gate.
- Re-run each implementation phase's declared minimum gate and record pass/fail.
- Verify AC1-AC4 with a traceability table (see §4A).
- Verify the three resolved contract conflicts actually shipped as decided, since
  they deliberately deviate from the UX spec's literal text:
  - "Paid by" is a non-interactive display row, not a partner toggle (ADR-015.2);
  - no literal partner display names anywhere (ADR-015.2);
  - `/expenses/report` is not called; the summary is computed client-side (ADR-015.3).
- Verify the ADR-007 bounds by inspection **and** by test: no outbox/pending-write
  table, no optimistic insert, no background retry, no "queued"/"will sync" copy.
- Verify exactly one Drift database class exists in `mobile/lib/core/database/`
  (R-015.1). If two exist, stop and raise a typed blocker.
- Verify `Key('home_screen_ready_signal')` is intact.
- Do **not** plan or run mobile e2e, emulator/simulator lifecycle commands,
  signing, store upload, traces, or scenario reruns.
- Document results concisely in `test-results.md`.

## 4. Acceptance Criteria

- `flutter analyze` clean, full `flutter test` green, `flutter build apk --debug` succeeds.
- AC1-AC4 each have named passing evidence.
- Every critical gate for the touched risk surfaces is recorded as pass, not
  required, or blocked with a typed blocker.
- The three deliberate UX deviations are recorded so the Reviewer checks them
  against the ADRs rather than against the UX spec verbatim.
- Exactly one Drift database class exists.
- Next owner (Reviewer) can resume without guessing.

## 4A. Verification Test Scope

- Source implementation phases: P1, P2, P3, P4, P5
- Platform / Surface: Flutter mobile (`mobile-app`)
- Required levels:
  - unit: decoders, month aggregation, `PairingStateReader`, repository failure mapping
  - integration: `ExpenseDao` against in-memory Drift
  - widget: history screen states, add sheet, pairing gate, entry-point navigation
  - accessibility: numeric keyboard + currency in accessible label; selected-state
    semantics on category chips; text-paired offline/empty signals (UX §7)
  - backend e2e: `DO NOT PLAN for ordinary continue`
  - browser e2e: `DO NOT PLAN for ordinary continue`
  - mobile e2e: `DO NOT PLAN for ordinary continue`
  - desktop/electron e2e: `DO NOT PLAN for ordinary continue`
  - mobile build/type-check/static-analysis: REQUIRED — `flutter analyze` + `flutter build apk --debug`
  - local dev startup gate: `STORY-RUNTIME-SMOKE only; implementation lanes do not run scripts/start-dev.sh`
- AC traceability table (fill in `test-results.md`):

| AC | Evidence | Phase | Result |
|----|----------|-------|--------|
| AC1 paired user can add an expense | add-sheet widget + `AddExpenseCubit` success `bloc_test`; `POST` body key-set assertion | P4 | |
| AC2 both partners view shared history | history widget test (shared dataset, no per-partner filter); `who` own-vs-partner label test | P3 | |
| AC3 history readable offline after one sync; writes need connectivity | offline widget test with cached rows + freshness caption; never-synced vs empty states; no-optimistic-write `verifyNever` test | P2, P3, P4 | |
| AC4 unpaired users cannot access | unpaired gate widget test; 404 ⇒ `ExpensesNotPairedFailure` unit test; mid-session flip-to-gate test | P1, P5 | |

- Required runtime signals:
  - backend response/log/assertion evidence: mocked-Dio request/response assertions only; no live backend required
  - route/navigation entrypoint: entry affordance → `ExpenseHistoryScreen`
  - screenshot artifacts: `requirement visual audit only`
- Evidence format: concise `coding-plan/test-results.md` rows only
- Requirement frontend visual audit:
  - Required when requirement has frontend participation: NO — no web surface in this story
- Requirement mobile visual audit:
  - Required when requirement has mobile participation: YES, but **requirement-level and deferred** — planned once after all REQ-001 mobile stories are otherwise complete, not inside this story
  - Affected screens/routes: `expense` history screen, Add-Expense sheet, Pairing-Required gate
  - Required entry surfaces: the P5 entry affordance
  - Provided runtime/artifact/screenshot command: to be supplied by the requirement-level audit owner
  - Screenshot budget: optimized small device/simulator screenshots
  - Required visual evidence: screenshot paths plus broken/misaligned mobile UI findings
- Risk-surface gates:
  - touched risk surfaces: `amount` wire type; unpaired 404 gating; offline read;
    offline write fail-fast; canonical Drift owner; entry-point discoverability;
    money-number correctness
  - source-of-truth artifacts: `../architecture/solution.md` §4 risk table
  - critical gates: the ADR-007 no-optimistic-write test (P4) and the unpaired gate
    test (P5) are blocking
  - blocked gates: record R-015.1 as blocked if two database classes exist
- Story-level runtime startup smoke: NOT_APPLICABLE — the `mobile-app` readiness
  signal is a widget test already covered by P5; `flutter run` needs an interactive
  device and is not started headlessly per the registry notes
- Local runtime/port safety gate: NOT_APPLICABLE — no Docker, Compose, script, or
  registry change in this story
- Backend e2e gate: do not add for ordinary continue

## 5. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
