# Review Report: STORY-048 Pairing Choice Viewport Regression Hardening

Reviewer: Iris-QC
Date: 2026-08-18
Review type: compact-story-review
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Story: STORY-048_pairing_choice_viewport_regression_hardening
Retro item: RWB-20260816-022 (RED-PATCH, fixes STORY-045)
Complexity: trivial | Implementation Lane: mobile (single-lane, confirmed)

Outcome: CLEAN

## Scope Gate

- Review type: `compact-story-review` (inline gate; no separate `scope-gate.md`).
- Git boundary: `BaseHead 4fb2426742f50de22c71066fa1ce6f31fbf8b54c`, Worktree
  `/Users/alantravala/workspace/snapsofts/cupid-apps`, Branch `main`.
- Source/test files in scope (2, within the 8-file compact budget):
  - `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart`
  - `mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`
- Evidence in scope: `story_master.md` `## Product Owner Triage (2026-08-18)`,
  `## Mobile Implementation (2026-08-18)`; `git diff <BaseHead>`;
  `data/devops/system/design-fidelity-config.json`.
- Focused query keys: AC1 overflow / `RenderFlex overflowed`, AC2 portrait
  geometry, AC3 `does not overflow on a rotated short viewport (AC1)`, AC4
  changed-file set, `PairingChoiceScreen` mount sites.
- Not loaded (per handoff `Do Not Re-read`): `rework-backlog.md` RWB-022 detail,
  STORY-045 `review/review-report.md` DF1.
- Phase 2 permitted: YES.

## Acceptance Criteria

| AC | Verdict | Evidence |
|----|---------|----------|
| AC1 — no overflow at reduced/rotated viewport incl. 1.3x font scale | PASS | Independently reproduced, see below |
| AC2 — no visible change in locked portrait frame | PASS | Independently measured, see below |
| AC3 — regression test required (not exempt) | PASS | Test is real and non-vacuous, see below |
| AC4 — scope boundary held | PASS | Diff-verified, see below |

### AC1 — verified independently, not accepted on report

The implementer's claim of `RenderFlex overflowed by 72 pixels` was reproduced
by this review rather than trusted. Method: a hardlink copy of
`mobile/{lib,test,openapi,assets}` plus `pubspec*`/`.dart_tool/*.json` was built
under the session scratchpad
(`.../scratchpad/neg`), the screen file there was replaced with
`git show 4fb2426:mobile/lib/.../pairing_choice_screen.dart` (pre-fix), and the
story's own committed test was run against it. No repository file was modified
(`git diff --name-only <BaseHead> -- mobile/` re-checked as exactly 2 files
before and after).

Result against pre-fix source:
`Expected: null / Actual: FlutterError:<A RenderFlex overflowed by 72 pixels on the bottom.>`
— exactly the figure reported. Against current HEAD the same file passes 5/5.
The other 4 pre-existing tests pass under both source versions, so the new test
is the only one sensitive to the change. The 72dp figure is larger than the
STORY-045 reviewer's ~13-38dp arithmetic derivation because that derivation was
at font scale 1.0; at 1.3x the title, CTA and `TextButton` all grow. The
derivation was directionally right and is now superseded by a reproduction.

### AC2 — verified by independent measurement, not by the implementer's probe

The implementer's throwaway geometry probe was not committed, so its result was
not accepted on trust. This review wrote its own probe into the isolated copy
(scratchpad only, never the repository) recording the rects of the title, CTA,
secondary `TextButton` and its label at 360x800, 412x915 and the 800x600 test
default, and ran it once against the restored pre-fix source and once against
current HEAD. All 24 measured values are identical to 3 decimal places, e.g. at
360x800: `title t=150.000 h=105.000`, `cta t=287.000 h=54.000`,
`secondary t=349.000 h=56.000`. Portrait layout is provably inert.

This matches the structural reading of the diff: `Align(topCenter)` is retained
above the new `SingleChildScrollView`, and a vertical `SingleChildScrollView`
passes the cross-axis constraint through unchanged, so the `Padding`'s
load-bearing 28dp inset still sets the same title wrap bound; it sizes to
`min(content, available)`, so with 350dp of content in an 800dp viewport it is
top-anchored at the identical offset and does not scroll. No token, spacing,
string, color or callback changed — the rest of the file diff is indentation
reflow only. The AC2 exception path correctly did not trigger.

### AC3 — the assertion is meaningful

`does not overflow on a rotated short viewport (AC1)`
(`pairing_choice_screen_test.dart:91-108`) sets `physicalSize Size(640, 360)`,
`devicePixelRatio 1.0`, `FakeViewPadding(top: 24, bottom: 24)` — 360-48 = 312dp
usable inside `SafeArea`, exactly AC1's stated worst case, not a harsher one —
pumps at `TextScaler.linear(1.3)` (AC1's stated "at least 1.3x") and asserts
`tester.takeException()` is null after `pumpAndSettle`. The setup is faithful,
not artificially harsh, and the negative run above proves the assertion is not
always-passing. `addTearDown(tester.view.reset)` prevents view-state leakage.
The `_harness({TextScaler? textScaler})` extension applies the override through
`MaterialApp.builder`, which wraps the Navigator, so `home` does inherit it; with
`textScaler == null` the builder is null, leaving the 4 pre-existing tests
behaviourally unchanged (confirmed by running them).

### AC4 — scope boundary held

`git diff --name-only <BaseHead> -- mobile/` returns exactly the screen and its
test. `invite_screen.dart`, `joincode_screen.dart`, `mobile/main.dart` and
`android/app/src/main/AndroidManifest.xml` are absent from the full diff; no
orientation lock or `configChanges` edit was made. STORY-045's
`visual-fidelity/` directory is untouched (absent from `git status` and the
diff) and its `DONE` status is unmodified — the only workflow-artifact changes
are Scrum Master bookkeeping in `req_master.md` and `rework-backlog.md` flipping
RWB-20260816-022 `PENDING -> IN_PROGRESS` and linking STORY-048.

## Risk Surfaces And Critical Gates

| Surface | Gate | Result |
|---------|------|--------|
| Mobile interaction / layout | Targeted widget tests | PASS — 5/5 on `pairing_choice_screen_test.dart`, re-run by reviewer |
| Mobile regression | Negative (pre-fix) run of the new test | PASS — reproduces `overflowed by 72 pixels`, so the guard is real |
| Mobile static analysis | `flutter analyze --no-pub lib test` | PASS — 80 issues, all `info`, 0 errors/warnings; re-run by reviewer, count and content match the implementer's claim; the 2 hits in `pairing_choice_screen.dart` are pre-existing `prefer_initializing_formals` on the constructor (lines 28-29), untouched by this diff |
| Mobile navigation / discoverability | Entry point reachability | PASS — `PairingChoiceScreen` still mounted at `mobile/lib/core/di/service_locator.dart:410` (`OnboardingNode.pairingChoice`) and `mobile/lib/core/navigation/pair_gate_shell.dart:139` (`PairGateUnpaired`), both outside the diff; the screen's own two entry actions still push `InviteScreen`/`JoincodeScreen` per the two pre-existing tests re-run here |
| Runtime startup smoke (rule 12g) | Not required | `Complexity: trivial`; 12g scopes the mandatory smoke to non-trivial stories |
| Design fidelity (rules 12e2/12e3) | See disposition below | No new evidence owed |
| Setup/configuration | Not required | No env, dependency, registry or config surface touched |

### Design-fidelity disposition

`design-fidelity-config.json` has `ui_surface: true` and a locked
`claude-design` source, and this story does touch a screen widget, so the
per-story rendered check is nominally in range. It is recorded as **not owed**
here on the governing artifact plus measured evidence, not on a prose waiver:

- PO AC2 designates STORY-045's existing `visual-fidelity/` pair as the
  governing visual evidence for `pairing_choice` and directs that it not be
  redone; that pair is intact and its comparison still holds.
- The design source is a fixed portrait frame. Portrait rendering is measured
  identical pre/post at three viewports (AC2 above), so a fresh capture would
  compare the same pixels against the same reference.
- The only new painting `SingleChildScrollView` can introduce on Android is the
  overscroll indicator, which is gesture-triggered and absent from a static
  frame.

Flagging for Scrum Master: this is a judgment that the story creates no new
design-fidelity surface, not a claim of exemption under
`design-fidelity-config.json`. If the story-level visual gate rejects a passing
outcome on the absence of `STORY-048/visual-fidelity/`, the correct resolution
is to route Mobile Developer to capture STORY-048's own pair for
`pairing_choice` on the STORY-045 device (`emulator-5560`) — writing only under
`STORY-048/visual-fidelity/` and leaving STORY-045's directory untouched, which
AC2 permits. It is not a defect in this implementation and does not change any
AC verdict above.

## Findings

- Blocking findings: 0
- Deferred findings: 0

## Traceability

- Requirements: `story_master.md` `## Product Owner Triage (2026-08-18)` AC1-AC4.
- UX / Architecture: `SKIPPED:trivial` per this requirement's Lane Consistency
  Rule; no UX or architecture artifact governs this change, and the design
  source's portrait frame is unaffected.
- Implementation: `pairing_choice_screen.dart:66-115`.
- Tests: `pairing_choice_screen_test.dart:91-108` (new), `:15-43` (harness
  extension).
- Evidence re-run by reviewer, not accepted on report: targeted test file,
  negative pre-fix run, portrait geometry probe, `flutter analyze`.
- Not re-run: the full `flutter test` suite (`+1285 ~2`). The targeted suite and
  the analysis gate were reproduced and matched, and the diff cannot reach other
  suites; rule 18 favours existing evidence here.

## Recommendation

- Keep `Implementation (Development)` checked.
- Check `Review (Reviewer)`.
- Story status: `DONE`.
- RWB-20260816-022 may move `IN_PROGRESS -> RESOLVED` once Scrum Master applies
  the story closure.
