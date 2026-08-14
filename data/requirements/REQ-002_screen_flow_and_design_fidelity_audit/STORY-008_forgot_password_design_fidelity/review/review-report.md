# Review Report: STORY-008 Design Fidelity — Forgot Password

Reviewer: Iris-QC
Mode: compact-story-review
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Story: STORY-008 Design Fidelity — Forgot Password
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-008`
BaseHead: `8396273e6a5e6a2798557aa68864f0ef24cd939b`
Reviewed HEAD: `4aba0580a76a5f1fc20ae27f3b2e7091a189cadc`
Review date: 2026-08-13

Outcome: DEFERRED_ONLY

## Review scope note (read this first)

This report covers the **FULL story diff, both implementation rounds**, and
supersedes the round-1 report previously stored at this path.

- Round 1 = `625cb09` + `12761f5`. It *was* reviewed (the prior report at this
  path closed `DEFERRED_ONLY` against `625cb09`), and it was then merged into
  `codex/REQ-002_...-integration`. `git merge-base integration HEAD` =
  `12761f5`, which confirms round 1 is already on the integration branch.
- Round 2 = `4aba058` ("restore forgot-screen design fidelity"). It is the only
  delta still outstanding versus the integration branch.
- The handoff's session-recovery note stated that no review report existed and
  that round 1 was merged without any review. The first half of that is
  incorrect — a round-1 report existed. The premature-merge concern is real in
  the sense that the merge happened while `story_master.md` still showed
  `Status: PENDING` and an unchecked `Review (Reviewer)` box, i.e. the workflow
  state was never advanced to match the review that did occur.
- Because round 1 was already merged before this gate ran, I reviewed
  `8396273..4aba058` as a single first-time review rather than reviewing only
  the round-2 increment. Nothing in round 1 is being taken on trust.

## Diff reviewed

`git -C <worktree> diff 8396273e6a5e6a2798557aa68864f0ef24cd939b` — 8 files,
+774/-22:

| File | Change |
| --- | --- |
| `mobile/lib/features/auth/presentation/screens/forgot_screen.dart` | +177/-19, screen rebuilt against the design source |
| `mobile/lib/design_system/icons/cupid_icons.dart` | +10, two new icon constants (additive only) |
| `mobile/test/features/auth/presentation/screens/forgot_screen_test.dart` | +191, new widget test |
| `.../visual-fidelity/visual-fidelity-report.md` | +204, evidence |
| `.../visual-fidelity/design-reference-forgot-android.png` | new, 166 KB |
| `.../visual-fidelity/implemented-forgot-emulator-5554.png` | new, 72 KB |
| `.../story_master.md` | +44/-… audit trail and screen-chrome correction |
| `.../review/review-report.md` | round-1 report (superseded by this file) |

Worktree is clean; no uncommitted work. No file outside the mobile lane and
this story's own artifact directory was touched.

## Visual-fidelity evidence: verified as real rendered evidence

The handoff asked me to confirm the evidence is genuine rendered before/after
material and not prose. It is. I opened both PNGs directly rather than relying
on the report's description:

- `design-reference-forgot-android.png` — real render of the locked canvas
  (406x900), showing the purple/magenta sky wash, transparent header with a
  pink back glyph, `lock_reset` hero glyph, gradient CTA pill with glow, and
  the mint privacy note with a `shield_moon` glyph.
- `implemented-forgot-emulator-5554.png` — real device capture from
  `emulator-5554` (405x900), same screen from the built APK.

Scale parity is legitimate: the emulator's `1080x2400 @ 420dpi` = 411.4 x
914.3 dp, natively matching the canvas's 412x915 Android frame. The report
also records that a forced `--width=412` attempt without matching density was
discarded as non-comparable, and that the capture ran under an exclusive
device lease because six sibling mobile agents share the same emulator and the
same package id. Both details are the kind of thing a fabricated report does
not contain, and the first capture attempt showing a sibling's screen is
disclosed rather than hidden.

Comparing the two images myself, the claimed outcomes hold visually:

- Hero glyph is a padlock-with-circular-arrow in both → `lock_reset` fix is
  real, not a `lock` substitute.
- Privacy-note glyph is a shield in both → `shield_moon` fix is real.
- Header with `Quên mật khẩu` and a back arrow is present in both → the
  missing-header fix is real.
- The three deferred items are also visually confirmed as still-present
  differences: flat pink CTA vs the design's gradient+glow pill (D-1), opaque
  surface header band vs the design's transparent/blurred header with a pink
  glyph (D-2), and a flat background vs the design's sky wash (D-3).

## Acceptance criteria traceability

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 — layout/spacing/token/typography match exactly, dark + `vi` | MET IN SCOPE, 3 deferrals | Element table in `visual-fidelity-report.md` cross-checked against both captures. Every screen-local element matches. D-1/D-2/D-3 are shared-component deviations that remain visible; see the deferral judgment below. |
| AC2 — deviations corrected in the app, not merely documented | MET | All 3 screen-local deviations are real code changes in `forgot_screen.dart` / `cupid_icons.dart`, each locked by a test assertion. This is the AC that most cleanly distinguishes this story from an audit-only writeup, and it is satisfied. |
| AC3 — form-field / response states match | MET | Empty state (`forgot_screen.dart:160-194`), error state (`:195-205`, `colorRed`), submitted/confirmation state (`:206-219`, `colorMint`). All three are covered by named tests. The design's `isForgot` block does not specify error/confirmation treatments, so re-using the block's own 12.5/1.55 supporting-text scale in the red/mint tokens is the correct non-inventive choice. |
| AC4 — no new entry point | MET | `ForgotScreen`'s constructor, its route, and the `LoginScreen` push site are untouched. The added `CupidHeader` back action uses `Navigator.maybePop()`, which preserves the existing pop target (`login`, matching the source's `BACK_TO`) rather than declaring a new one. |

## Verification re-run by reviewer

Run in the story worktree's `mobile/` with the repository Flutter SDK. Full
untruncated output was read in both cases.

| Gate | Command | Recorded | Reviewer re-run |
| --- | --- | --- | --- |
| Analyzer (3 touched files) | `flutter analyze --no-pub --no-fatal-infos lib/features/auth/presentation/screens/forgot_screen.dart lib/design_system/icons/cupid_icons.dart test/features/auth/presentation/screens/forgot_screen_test.dart` | No issues | **`No issues found! (ran in 1.2s)`** — reproduced |
| Tests (touched + dependent) | `flutter test --no-pub test/features/auth/presentation/screens/forgot_screen_test.dart test/design_system/no_fork_guard_test.dart test/design_system/adaptive_widgets_test.dart test/design_system/contrast_test.dart` | `+25` all passed | **`+25: All tests passed!`** — reproduced exactly |

The full suite (`+926`) and the release APK build were not re-run; the scoped
re-runs above plus the no-fork guard are sufficient for a compact gate on a
single-screen change, and the handoff explicitly excluded a full-suite re-run.

`no_fork_guard_test.dart` passing independently confirms the screen introduces
no raw color literal, no `Colors.` reference and no per-screen platform fork.
`adaptive_widgets_test.dart` and `contrast_test.dart` passing confirms the
shared design-system contract that sibling stories depend on was not disturbed.

Test quality is genuinely adequate for a fidelity story rather than
presence-only: assertions check the rendered `TextStyle` family/weight/size/
color, the actual `BoxDecoration` tint alpha values, and icon size/color. The
negative assertion `expect(find.byIcon(CupidIcons.lock), findsNothing)` at
`forgot_screen_test.dart:151` is what stops the substituted-glyph defect from
silently regressing.

## Deferral judgment on D-1 / D-2 / D-3

The handoff asked whether deferring these is a legitimate scope boundary or a
blocking gap against AC1's "matches exactly" bar. **Legitimate — Deferred
findings, not a blocker.** Reasoning, including the part that weakens the
developer's own case:

Legitimate because:

1. All three live in shared design-system code consumed app-wide —
   `CupidPrimaryButton` (24 `lib` consumers, 7 test files), `CupidHeader` (18
   `lib` consumers), and the frame background (every screen). Landing them here
   restyles every other screen in the app.
2. Six sibling mobile agents are merging into the same integration branch this
   wave. A shared-component restyle from one screen's branch would collide with
   in-flight sibling work and would break `adaptive_widgets_test.dart`, which
   asserts the current tap-target height and 20dp radius.
3. The only in-story alternative — a screen-local gradient CTA fork inside
   `forgot_screen.dart` — is explicitly forbidden by ADR-004 / the no-fork rule
   and would be caught by `no_fork_guard_test.dart`. So "fix it here" has no
   compliant form.
4. None of the three is a defect *introduced* by this change. All three
   pre-date the story and affect `login`, `register` and `otp` identically.
5. D-3 additionally needs real design work, not a patch: `skyGradient` is
   currently declared as a **`String`** of raw CSS in `cupid_color_tokens.dart`
   with zero render-path consumers. It needs a typed Flutter gradient plus a
   shared screen scaffold.

Honest caveat that Scrum Master should weigh:

- The justification **changed between rounds**. In round 1 the defence was
  "these files are outside my WriteScope, I am not allowed to touch them." In
  round 2 the WriteScope did include `mobile/lib` — the developer edited
  `cupid_icons.dart`, which is itself under `design_system/` — so the defence
  shifted to blast radius and wave sequencing. The report states this openly
  ("reachable from this pass's WriteScope but deliberately not landed here"),
  which is the correct disclosure, but it means the deferral is now a
  **scheduling decision that belongs to Scrum Master**, not a technical
  impossibility. It is a sound decision; it just is not the reviewer's or the
  developer's to make unilaterally.
- Strictly read, AC1's "no visible deviation" is not fully satisfied: the two
  captures show three differences a user could see. `DEFERRED_ONLY` is the
  right outcome precisely because it records that gap rather than pretending
  AC1 is clean.

Therefore this approval is conditional in one respect: **D-1, D-2 and D-3 must
be carried into a single tracked REQ-002 design-system follow-up story before
this wave closes.** They have now been deferred across multiple sibling
auth-screen stories in this wave, and the count of screens shipping a
non-matching CTA is growing. If that follow-up story is not created, the
correct outcome for the *requirement* integration review is not CLEAN.

## Secondary findings (non-blocking)

1. **Marker string mismatch.** `story_master.md:92` cites
   `VISUAL_FIDELITY: PASS_WITH_DEFERRALS`, but the actual machine-readable
   block at `visual-fidelity-report.md:188` reads `VISUAL_FIDELITY: PASS` with
   `Shared-Component-Deviations-Deferred: 3` on a separate line. The two agree
   in substance but not in literal text. If any gate greps for the marker, the
   story record will not match the evidence file. Recommend aligning the
   `story_master.md` prose to the literal marker.
2. **Shared file touched from a story branch.** `cupid_icons.dart` is a shared
   design-system file modified on a story branch mid-wave. The change is purely
   additive (two `static const IconData` declarations, no edits to existing
   entries), and there are no competing changes to that file on the integration
   branch since the merge-base, so merge risk is currently low. Flagging it
   only so Scrum Master watches for a textual conflict if a sibling story also
   appends icons to the same region.
3. **New back affordance.** The screen previously had no `appBar` at all, so
   the added `CupidHeader` introduces a visible back control that did not exist
   before. This is design-source-mandated (`forgot` is absent from `NO_CHROME`
   at source line 1951) and `maybePop()` preserves the existing pop target, so
   it does not redefine the navigation contract Scope A owns. Informational for
   STORY-001 / STORY-002 only.
4. **`story_master.md` screen-chrome correction is correct.** The story was
   originally recorded `NO_CHROME / NO_TABS`; I confirmed the locked source
   lists `forgot` only under `NO_TABS` (line 1952) and not under `NO_CHROME`
   (line 1951). The correction in the story record is right, and the missing
   header was a genuine fidelity defect rather than an over-correction.

## Residual risks

- Fidelity was judged by comparing two rendered PNGs by eye plus token-level
  test assertions, not by an automated pixel/golden diff. Sub-pixel or font
  metric differences that survive identical token values would not be caught.
- Only dark theme + `vi` was audited, per the story's Out of Scope and OQ5.
  Light theme and `en` remain visually unverified. Tokens are theme-aware, so
  this is a coverage gap rather than a known defect.
- Round 1 reached the integration branch before this gate completed. Nothing
  defective was found in it, so no corrective action is needed for the code,
  but the process gap (merge ahead of a recorded gate) should be noted in the
  wave retro so it is not repeated.

## Decision

**DEFERRED_ONLY.** Every deviation this story legitimately owns was found,
fixed in app code, verified against a real device capture, and locked by tests
that would fail on regression. Analyzer and the scoped test suite were re-run
by me and reproduce the recorded results exactly (`No issues found!`, `+25`).

The three remaining deviations are real and user-visible but are shared
design-system defects that pre-date this story and cannot be fixed from a
single-screen `trivial` story without violating the no-fork architecture rule
or destabilising six sibling branches mid-wave.

Story may be marked DONE, provided D-1, D-2 and D-3 are carried forward as one
tracked REQ-002 design-system follow-up story rather than being deferred a
further time per screen.
