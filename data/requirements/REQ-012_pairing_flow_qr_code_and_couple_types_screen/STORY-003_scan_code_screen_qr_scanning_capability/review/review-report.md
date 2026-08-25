# Story Review Report: STORY-003 Scan-Code Screen QR Scanning Capability

Requirement: REQ-012_pairing_flow_qr_code_and_couple_types_screen
Story: STORY-003_scan_code_screen_qr_scanning_capability
Review type: `final-synthesis` over three completed `scoped-slice` reviews
Reviewer run: RUN-REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-003_scan_code_screen_qr_scanning_capability-reviewer-final
Branch: `codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-003_scan_code_screen_qr_scanning_capability`
BaseHead: `d32f02f3c5fdeb0572c2ac2e8fb4831289d9142b`

Outcome: PATCH_REQUIRED

One item, documentation-only, inside this story's own write scope: the P1
"Resolved versions" table in `coding-plan/test-results.md:20-26` states
`permission_handler` versions that the shipped `pubspec.lock` does not contain.
No code, lock, config, or test defect was found by any of the three slices.

## 1. How this verdict was reached

This run is the synthesis pass mandated by the earlier scope gate
(`REVIEW_SCOPE_TOO_BROAD`, 16 touched files against a 12-file ceiling). The
implementation was reviewed in three bounded slices, each by a separate
reviewer, and this pass reads those three reports plus the minimum source needed
to close cross-slice questions. The full diff was not re-reviewed.

| Slice | Files | ACs owned | Slice result |
|---|---|---|---|
| `review/slice-1-permission-foundation.md` | 6 (gate + test, manifest, plist, pubspec x2) | AC1, AC3 permission half | PASS on every substantive item; 1 documentation FAIL |
| `review/slice-2-decode-state.md` | 4 (parser + cubit, both tests) | AC2, AC4 logic half | PASS |
| `review/slice-3-screen-entry-preview.md` | 6 (screen + test, joincode screen + test, route, preview) | AC3 UI half, AC4 UI half, AC5 | CLEAN, with 3 deferred and 1 unverified carry-forward |

6 + 4 + 6 = 16, matching `git -C <Worktree> diff --name-only <BaseHead> -- mobile/`
exactly. Every touched file was reviewed by exactly one slice; no file was
skipped and none was double-counted.

## 2. AC coverage cross-check — no gap

| AC | Covered by | Result | Seam closed by |
|---|---|---|---|
| AC1 — permission requested at scan initiation, proceed only when granted | Slice 1 (gate correctness) + Slice 2 (consumer enforcement) | PASS | Slice 1 flagged that the "cannot proceed unless granted" half lives in the cubit. Slice 2 closed it: `_armed` starts `false` and only `start()` with `granted` arms it (`scan_code_cubit.dart:82`, `:96`), asserted by `a detection without granted permission never submits` (`scan_code_cubit_test.dart:91-100`). |
| AC2 — decode resolves to the same pairing code and the same pairing seam | Slice 2 (parse + submit logic) + Slice 3 (shared-instance wiring) | PASS | Slice 2 flagged that "same `JoincodeCubit` instance" is a wiring assertion in Slice 3's files. Slice 3 closed it: `scan_code_route.dart:28-53` provides the join-code screen's own cubit via `BlocProvider.value`, and `joincode_screen_test.dart`'s parity test asserts `submitted == ['3F9A2B','3F9A2B']` across manual and scanned entry. |
| AC3 — denied/unavailable gives a clear message and never dead-ends | Slice 1 (signal half) + Slice 3 (UI half) | PASS | `denied` / `permanentlyDenied` / `unavailable` stay distinct through the gate (Slice 1) and render as States 5/6/7 with a manual-entry escape in every one of them (Slice 3, verified against captures). |
| AC4 — accepted / expired / malformed states | Slice 2 (transitions) + Slice 3 (rendering) | PASS | Malformed → State 4 with zero network calls; backend `InvalidOrExpiredCodeFailure` → State 4 with the overlay held open; retry re-arms. Rendering, auto-dismiss, and "camera keeps running behind the card" verified from source, tests, and captures. |
| AC5 — dark theme + `vi` design fidelity | Slice 3 | PASS | Entry-point pill row re-derived independently from `Cupid Screens.dc.html:1628-1637`; overlay states compared to `ux/ux-spec.md` by reading the 6 PNGs. One deviation, ruled CLEAN — see §4. |

No AC is unowned, and no AC is claimed by two slices with conflicting verdicts.

## 3. Cross-slice items closed in this pass

Two questions were explicitly handed forward by an earlier slice and were not
answered by the later slice that owned the file. Both were resolved here by
targeted source reads.

**3.1 `closeRequests` no-replay race — CLOSED, not an issue.**
Slice 2 observation 3 noted `closeRequests` is a broadcast controller with no
replay (`scan_code_cubit.dart:74-75`, `:86`), so a close signal emitted before
the screen subscribes would be dropped, and pointed at Slice 3's file for the
subscription timing. Slice 3 did not address it. Verified directly: the cubit is
constructed with `..start()` inside the `BlocProvider` `create`
(`scan_code_screen.dart:77-81`) and `_ScanCodeViewState.initState` subscribes in
the same build pass (`:100-106`). `start()` awaits `permissionGate.status()`
before it can emit anything, and a close signal additionally requires an armed
detection plus a completed backend round trip. No synchronous emit can precede
the subscription. Not a defect.

**3.2 `CameraPermissionState.unavailable` has no Android producer — real, but
not an AC failure.** Slice 1 residual risk 1 asked Slice 2 to confirm whether
`mobile_scanner`'s start failure produces State 7; Slice 2 did not. Verified
directly: `scan_code_cubit.dart:102` is the only producer of
`ScanCodeUnavailable`, and it is fed solely from the gate's `unavailable`, which
in turn comes only from `PermissionStatus.restricted`
(`camera_permission_gate.dart:56-58`) — an iOS parental-controls value. There is
no camera-start-failure path into State 7. Consequence: on a cameraless Android
device (installable, since `AndroidManifest.xml:15-17` declares the camera
feature `required="false"`), State 7 is unreachable and the failure would surface
as a `mobile_scanner` preview error rather than the designed message. Logged as
Deferred Finding DF-4 rather than a blocker: AC3 is written about the permission
signal, all three permission outcomes are handled, and manual entry remains
reachable from the join-code screen on such a device regardless.

## 4. `_InvalidCard` radius deviation — CLEAN, carried forward unchanged

`scan_code_screen.dart:388` uses `platformTokens.radiusCard` (24 Material /
26 iOS) where `ux/ux-spec.md:104-106` and `:175` name `var(--r-btn)` (999px per
`Cupid Screens.dc.html:24-25`). Slice 3 ruled this CLEAN with reasons this
synthesis accepts and does not reopen: the spec names a convention applied to
48-54px-tall controls where 999px resolves to a stadium, the literal reading
contradicts the spec's own card-width requirement at `ux-spec.md:200-202`, no new
token was invented, the change is confined to one surface this story introduced,
and it was disclosed rather than absorbed silently.
`visual-fidelity/visual-fidelity-report.md` carries
`VISUAL_FIDELITY: PASS_WITH_FLAGGED_DELTA` for this exact delta. The capture
comparison was not re-run in this pass.

## 5. Blocking findings

**BF-1 — `coding-plan/test-results.md:20-26` misstates the shipped
`permission_handler` versions.** Owner: `mobile-dev`. Severity: documentation
integrity of the story's own verification evidence.

The table is introduced at `:16` as *"Resolved versions, quoted from
`mobile/pubspec.lock`"* and then states:

- `:21` `| `permission_handler` | `"13.0.1"` |`
- `:22` `| `permission_handler_android` | `"14.0.0"` |`

Independently re-verified against the shipped tree in this pass:

| Source | Value |
|---|---|
| `mobile/pubspec.yaml:60` | `permission_handler: ^12.0.1` (the intended pin) |
| `mobile/pubspec.lock:943-950` | `permission_handler` `12.0.3` |
| `mobile/pubspec.lock:951-958` | `permission_handler_android` `13.0.1` |
| `mobile/pubspec.lock:959-966` | `permission_handler_apple` `9.6.1` (matches the table) |

The table is a pre-downgrade snapshot that was never corrected after the P4 build
gate forced the pin back — the `compileSdk = 37` / `android-37`
platform-not-found Gradle failure documented at `test-results.md:394-412`, with
`coding-plan/master-plan.md` §6 note A1 as its origin.
`deployment/configuration-guide.md:21`, `:28-32`, and `:34-59` record the correct
values and the lift condition, so the *decision* is sound and well evidenced;
only the P1 evidence table is wrong.

Why this blocks rather than defers: P1 is the section a future engineer reads to
learn which `permission_handler` shipped, and it currently asserts, as a direct
quote from the lock file, a version the build gate rejected. Once the story is
`DONE` this artifact freezes as the record of what shipped. The review gate
certifies evidence as well as code, and a one-line correction inside the story's
own write scope is not worth trading that away for.

Required patch (exactly one edit, no code change):
> In `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/STORY-003_scan_code_screen_qr_scanning_capability/coding-plan/test-results.md`,
> correct line `:21` to `` `permission_handler` | `"12.0.3"` `` and line `:22` to
> `` `permission_handler_android` | `"13.0.1"` ``, matching `mobile/pubspec.lock:943-958`.
> Alternatively, annotate the table in place as a superseded pre-downgrade
> snapshot with a pointer to `test-results.md:394-412`. Do not change
> `pubspec.yaml`, `pubspec.lock`, or any source file.

Optional, may be folded into the same edit: add the missing
`## Entry Point Reachability` heading (DF-1 below) while the file is open.

## 6. Deferred findings (non-blocking, do not gate this story)

| Id | Finding | Owner | Source |
|---|---|---|---|
| DF-1 | `coding-plan/test-results.md` has no `## Entry Point Reachability` section; reachability is stated only indirectly inside the P4 narrative at `:318-332`. The substantive claim holds — Slice 3 traced the full chain in source and this synthesis accepts REACHABLE. Missing heading in an evidence artifact, not a defect in the screen. | `mobile-dev` | Slice 3 DEFERRED-1 |
| DF-2 | `ux/ux-spec.md:104-106` and `:175` should name a card radius for card-shaped surfaces so the spec stops contradicting the shipped `radiusCard`, per `visual-fidelity-report.md:158-160`. UX doc edit, not a code patch. | `ui-ux-designer` | Slice 3 DEFERRED-2 |
| DF-3 | `ux/ux-spec.md:74-77`'s "subtle animated scan-line or pulsing frame border" for State 2 is not implemented: `_Viewfinder` (`scan_code_screen.dart:301-324`) animates once on the State 2 → State 3 transition with no repeating controller. AC5 enumerates layout, spacing, color/token usage, and typography — motion is not among them — so this does not fail the AC as written. Queue as a small follow-up or record an explicit UX waiver, and annotate the State 2 "match" row at `visual-fidelity-report.md:112`, which a still capture cannot disclose. | `scrum-master` to route (`ui-ux-designer` waiver or `mobile-dev` follow-up) | Slice 3 §5.1 |
| DF-4 | State 7 (`ScanCodeUnavailable`) is effectively iOS-only: its sole producer is `PermissionStatus.restricted`. A cameraless Android device has no defined path into it. See §3.2. | `tech-lead` to decide whether a `mobile_scanner` start-failure producer is wanted | Slice 1 residual risk 1, closed here |

## 7. Unverified items

| Id | Item | Why not FAIL |
|---|---|---|
| UV-1 | `ux/ux-spec.md:190-193` requires focus to return to the `Quét QR` pill on plain dismiss. `joincode_screen.dart:186-192` restores focus only on `ScanCodeExit.manualEntry`; on `ScanCodeExit.dismissed` it intentionally does not touch focus (`:181-185`). Flutter's `Navigator` restores the prior route's `FocusScope` on pop, so focus very likely lands correctly, but no test asserts it and no screen-reader run was available. | The focus-*trap* half is satisfied structurally — an opaque pushed route owns its own focus scope. Behaviour is probably correct; only the assertion is missing. Recording it honestly rather than certifying it. |

## 8. Verification evidence accepted

- **Targeted tests, independently re-run by the slice reviewers, not taken on
  trust.** Slice 1 re-ran `camera_permission_gate_test.dart` → 11/11. Slice 2
  re-ran `pairing_code_parser_test.dart` + `scan_code_cubit_test.dart` → 47/47,
  matching `test-results.md:112` and reconciling against the source case split.
- **Feature regression suite.** `flutter test test/features/pairing/` → 189
  passing (`test-results.md:130-141`).
- **Static analysis.** `flutter analyze lib/features/pairing test/features/pairing`
  → 8 info-level issues, all `prefer_initializing_formals`, 6 pre-existing and 2
  new ones (`scan_code_cubit.dart:68`, `:69`) confirmed unfixable as suggested
  because Dart forbids a named parameter starting with `_`. No new warning class.
  Whole-project `flutter analyze` is documented as unusable (vendored
  `build/ios/SourcePackages`) with the scoped invocation named as the gate
  (`test-results.md:379-382`).
- **Build gate.** `flutter build apk --debug` succeeded (`test-results.md:384-392`).
- **Runtime startup smoke.** `test-results.md:522-559` records Result PASS on
  `emulator-5554` via the `mobile-app` runtime registry entry, using the
  registry's exact `readiness.command` and `readiness.shutdownCommand`, and states
  its own limit plainly at `:556-559` (launch to first screen, not the scan flow).
  That scope is correct: the scan surface itself is covered by the 28 widget tests
  and 6 device captures. Owned and executed by Scrum Master per
  `master-plan.md` §4, because ordinary mobile-dev handoffs are guard-blocked from
  device runtime work. **Sufficient — not re-requested, not routed back.**
- **Visual fidelity.** `visual-fidelity/visual-fidelity-report.md` exists with
  `VISUAL_FIDELITY: PASS_WITH_FLAGGED_DELTA`; the 6 PNGs were read (not merely
  cited) by Slice 3. Not re-run in this pass, per handoff.
- **Test quality.** Spot-checked by Slice 3 at the harness level: the stubs record
  the exact submitted string and count preview mounts/disposals, so "the camera
  keeps running under the card" and "the session dies with the subtree" are
  measured rather than asserted by comment. Tests exercise `en`, captures cover
  `vi`.

## 9. Items for Scrum Master, outside this story's scope

1. **Pre-existing suite failure.** `no_fork_guard_test.dart` fails on
   `pet_preview_card.dart:229-230`, a file absent from this worktree's diff
   against BaseHead. Disclosed rather than hidden by the implementer. Queue
   separately; it is not this story's regression.
2. **Handoff input path does not exist.** All three slices and this pass were
   handed
   `data/requirements/REQ-012_.../STORY-003_.../scrum-master-checkpoint.md`, which
   exists in neither the worktree nor the control checkout. The live checkpoint is
   the requirement-level
   `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/scrum-master-checkpoint.md`.
   No verdict in any slice depended on it. Correct the checkpoint path in the run
   files or create the story-level checkpoint.
3. **Recorded `invite_cubit_test.dart` flake** (`test-results.md:130-141`) is in a
   file this story neither touches nor imports. Disclosed correctly; track
   separately if it recurs.

## 10. State recommendation

- Do **NOT** mark STORY-003 `DONE` yet. `Outcome: PATCH_REQUIRED`.
- Route BF-1 to `mobile-dev` as a documentation-only patch. It touches one file
  and no source; no re-implementation, no re-test, and no re-capture is needed.
- On return, this gate needs only a confirmation that
  `test-results.md:20-26` matches `mobile/pubspec.lock:943-966`. Re-review of
  AC1-AC5, the diff, the test runs, or the captures is **not** required and must
  not be re-requested — all five ACs are PASS and are recorded as such above.
- After that single correction lands, this report's outcome becomes `CLEAN` with
  DF-1..DF-4 and UV-1 carried as deferred items, and the story is eligible for
  `DONE` and for merge into
  `codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-integration`.
- Blocking findings: 1 (documentation). Deferred findings: 4. Unverified: 1.
  Code defects found across all three slices: 0.

REVIEW_COMPLETE: YES
