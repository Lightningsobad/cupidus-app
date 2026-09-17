# Review Report: STORY-012 Trạng thái theo pha, widget, và bộ đếm "của cải đang lớn"

Outcome: BLOCKED

Reviewer: Iris-QC · Date: 2026-09-17 · Requested mode: `compact-story-review`
Scope gate: `review/scope-gate.md` (`SCOPE_GATE_COMPLETE: YES`, Phase 2 approval `NO`)
Worktree: `story-REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget`
Diff baseline: `b58afbe073eff4e1ebb9151735221532a9cf5a82..759c6cbcfe2c567d314c5c4e966fbe3b56317808`

## Scope Gate

Written in full to `review/scope-gate.md`. Summary: the requested mode cannot
hold this story, so Phase 2 focused verification was not entered and no
AC-1..AC-8 verdict is recorded below. The gate proposes the exact re-scope.

## Blocking Finding

### B-1 · `BLOCKER: REVIEW_SCOPE_TOO_BROAD`

The handoff requests `compact-story-review` for a story that `story_master.md:4`
classifies `Complexity: complex`, and the actual change set is:

| Measure | Value | Compact budget | Full budget |
|---|---|---|---|
| Changed files (total) | 76 | — | — |
| Source/test/config files | ~55 | 8 | 12 |
| Insertions | 12,108 | — | — |
| Governing artifacts > 20 KB | `coding-plan/test-results.md` (71 KB) | 1 | 2 |
| Phases in one pass | P1-P8 | — | — |
| Native platforms | 2 (Kotlin + Swift, incl. `project.pbxproj`) | — | — |

The handoff also names no exact files or query keys — it asks for the whole
story plus AC-1..AC-8, the R-1(f)/R-1b invariants, the narrowed guard test and
the visual-fidelity evidence in a single bounded pass. Reviewer SKILL.md rule 1c
requires stopping here before reading broadly, and rule 1b rejects a whole-story
sweep supplied without exact files/query keys.

This is not a formality. A single pass over 55 files spanning an Android
`AppWidgetProvider`, a WidgetKit extension, an Xcode project mutation, a
notification scheduler and a four-phase state machine would produce a verdict
whose confidence is not backed by the reading behind it — the failure mode the
tiered review gate exists to prevent. Splitting is the cheaper path, not the
slower one: every slice below is independently verifiable against its own phase
file and its own tests.

**Action (owner: Scrum Master).** Re-dispatch as the seven passes inventoried in
`review/scope-gate.md` → `## Source/Test Files In Scope`: S1 (P1 content
packages + gate), S2 (P2+P7 resolver/line/countdown), S3 (P4 Android widget),
S4 (P5 iOS widget), S5 (P6 evening check-in + guard narrowing — this one needs
the `full-story-review` file budget at 10 files), S6a (P3 counter/milestone/
drip), S6b (P8 quiet surfaces + hub integration), then one
`Reviewer: final-synthesis`. Each slice carries its exact file list and query
keys already; they can be pasted straight into the spawn handoffs.

## Evidence Gaps Confirmed At Gate Cost

These three were established from the scope-gate inputs alone (directory
listing, `test-results.md` headings grep, `design-fidelity-config.json`). They
are reported now so the mobile-dev/DevOps lane can close them in parallel with
the re-scope, rather than having a slice pass rediscover them. They are NOT the
reason for the `BLOCKED` verdict above; each is independently `PATCH_REQUIRED`
grade once the review is correctly scoped.

### G-1 · Mobile design-fidelity comparison is asserted, not performed (rule 12e2/12e3)

`data/devops/system/design-fidelity-config.json` has `ui_surface: true` and a
locked `design_source` (`claude-design`, `cupid-app-design-system`), so the
rendered check applies — the no-design-source exemption does not. The story is
UI-bearing (`story_master.md:89` `UI-facing story: YES`). `visual-fidelity/`
holds six `implemented-*.png` and:

- zero `design-reference-<screen>-<device>.png`
- no `visual-fidelity-report.md`, therefore no `VISUAL_FIDELITY: PASS` verdict
  (the `| VISUAL-FIDELITY | ... | PASS |` at `test-results.md:336` is a row in
  the P7 AC-coverage table, not the required report)
- no resolved `Design-Screen: <id>` and no `Design-Surface: <id>` recorded,
  which matters here specifically: `design_sources` lists **three** mobile
  canvases (`cupid-app`, `cupid-d-u-m-c`, `cupid-ch-ng-1`). Rule 12e2 requires
  the surface and screen to be pinned before a comparison means anything.

`test-results.md:346-354` is a prose self-comparison ("khớp") of the implemented
screenshots against a design nobody rendered. Rule 12e3 names exactly this: "a
bare token with no deltas and no named states is not a comparison that happened;
it is a comparison that was asserted."

Note `test-results.md:373-376`, where mobile-dev already escalated that
`visual-fidelity/` was outside the P7 write scope while the phase file mandated
the capture. That unresolved conflict is the likely cause of G-1 and should be
fixed in the re-spawn's `WriteScope`, not worked around.

**Action (owner: mobile-dev).** Resolve and record `Design-Surface` +
`Design-Screen`, render the reference screens, write
`visual-fidelity/visual-fidelity-report.md` with per-device verdicts and named
AC states, and include `visual-fidelity/` in the handoff `WriteScope`.

### G-2 · No `## Entry Point Reachability` evidence (rule 12e1, non-waivable)

`coding-plan/test-results.md` has no such section — its only `##` headings are
`Phase Status` and the eight phase sections. The story is UI-facing and
`story_master.md:91-92` describes two entry routes (an OS home-screen widget the
user adds, and in-screen surfaces on màn (1)). The OS widget path in particular
needs an explicit reachability statement, since "user adds it from the OS widget
gallery" is a discoverability claim about a surface outside the app's own
navigation.

**Action (owner: mobile-dev).** Add `## Entry Point Reachability` with
`Reachable: YES` and the concrete path for each surface. The slice reviewer will
verify it in code independently, per rule 12e1.

### G-3 · No `## Story Runtime Startup Smoke` evidence (rule 12g)

Absent from `test-results.md`, and `story_master.md` records no
`Runtime-Smoke: WAIVED — <reason>`. Rule 12g makes this mandatory for a
non-trivial `mobile` lane story: the app must launch on the provided
device/emulator and reach its first screen without a crash or error screen. This
story adds an `AppDelegate.swift` change, new entitlements and an Xcode target —
precisely the class of change that red-screens at launch while unit tests stay
green. The DONE gate enforces this independently.

**Action (owner: mobile-dev or DevOps).** Supply the smoke, or have Scrum Master
record an explicit `Runtime-Smoke: WAIVED — <reason>` in `story_master.md`.

## Verified In Passing

One item was checked because the handoff named it explicitly and it is a single
small file. Recording it so no slice pass repeats the work:

- **The narrowed cross-requirement guard is substantive, not vacuous.**
  `mobile/test/features/reminders/reminder_copy_guard_test.dart:102-134` scans
  `lib/features/reminders/**.dart` recursively, keeps only lines starting
  `import `/`export `, and fails on any containing `flutter_local_notifications`.
  The substring-match pitfall from prior experience does not apply here: the
  target is a *package* name, and a Dart package import is always
  `package:flutter_local_notifications/...`, never a relative path. The scanned
  directory holds 17 real `.dart` files, so the assertion is not vacuously green
  on an empty tree. The `pubspec.yaml` ban on the other three packages
  (`android_alarm_manager`, `alarm`, `awesome_notifications`) is retained at
  lines 28-32 and 82-100, matching the 2026-09-17 user decision.
- **Deferred (D-1, non-blocking):** the guard catches only *direct* imports. A
  file under `lib/features/reminders/` importing
  `lib/features/phase_status/data/local_notification_scheduler.dart` — which
  does import the plugin — reaches the same capability and stays green. Worth an
  import-boundary note or a transitive check later; it does not weaken the
  decision taken on 2026-09-17, and no such transitive import exists today.

## Traceability

| Input | Used for |
|---|---|
| `story_master.md` | complexity, lane, AC-1..AC-8 inventory, UI-facing flag, smoke-waiver check |
| `git diff --name-only`/`--stat` vs `BaseHead` | scope measurement (B-1) |
| `coding-plan/test-results.md` (headings grep + L330-414) | evidence-gate inventory (G-1..G-3), AC-id correction note |
| `visual-fidelity/` listing | G-1 |
| `data/devops/system/design-fidelity-config.json` | G-1 applicability, multi-canvas surface risk |
| `mobile/test/features/reminders/reminder_copy_guard_test.dart` | guard verification + D-1 |

Not opened (Phase 2 not approved): `requirements/requirements.md`, `ux/uiux-spec.md`,
`architecture/solution.md`, `architecture/contract-summary.md`, `coding-plan/master-plan.md`,
the eight phase files, and every implementation source file except the one named above.

## Findings Count

- Blocking: 1 (B-1)
- Evidence gaps pending re-scope: 3 (G-1, G-2, G-3)
- Deferred: 1 (D-1)

## State Recommendation

- Leave `Review (Reviewer)` **unchecked** in `story_master.md`.
- Story status: `BLOCKED` until Scrum Master re-scopes the review.
- Do **not** mark STORY-012 `DONE`: no AC was verified in this pass, and the
  DONE gate would independently reject it on the missing visual-fidelity and
  runtime-smoke evidence (G-1, G-3).
- Next step: Scrum Master re-dispatches the seven passes listed in
  `review/scope-gate.md`, and routes G-1/G-2/G-3 to the mobile-dev lane in
  parallel.
