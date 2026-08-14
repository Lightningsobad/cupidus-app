# Review Report — STORY-009 Design Fidelity: Permissions

Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Story: STORY-009 Design Fidelity — Permissions
Mode: compact-story-review (mobile lane, rendered visual-fidelity verification)
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-009`
BaseHead: `8396273e6a5e6a2798557aa68864f0ef24cd939b`
Reviewed commit: `01bc1281e267a32d586406c3abfaf0ac3d46286d`

Review round: 1

Outcome: DEFERRED_ONLY

## Scope Gate

Review type: compact-story-review, `mobile` lane, `ui_surface: true`,
`design_source` locked — so the rendered visual check of rule 12e3 applies and
is verified, not re-captured.

Source/test files in scope (5, within the compact budget):

- `mobile/lib/features/onboarding/presentation/screens/permissions_screen.dart` (new, 372)
- `mobile/lib/features/onboarding/presentation/onboarding_strings.dart` (new, 14)
- `mobile/lib/main_preview.dart` (+16 −1, dev-only preview registry)
- `mobile/test/features/onboarding/permissions_screen_test.dart` (new, 132)
- `story_master.md` (implementation-finding log)

Evidence in scope: `visual-fidelity/visual-fidelity-report.md` and both PNGs;
`data/devops/system/design-fidelity-config.json`; design source
`cupid-app-design-system/project/Cupid Screens.dc.html:1532-1548`.

Query keys: `isPermissions`, `permList`, `PermissionsScreen`, `permission`,
AC1–AC4, `_notImplementedCanvasIds`.

No `coding-plan/` exists. Correct for a `trivial` story (rule 9) and consistent
with every already-merged Scope B sibling (STORY-005, STORY-006), which carry
`story_master.md` + `visual-fidelity/` + `review/` and no coding-plan.

## Evidence Independently Re-Run

Re-executed in the story worktree with `/Users/alantravala/flutter/bin/flutter`.
Nothing below is accepted from the implementer's report.

| Command | Result |
| --- | --- |
| `flutter gen-l10n` | ran clean (required first; `lib/l10n/generated/` is not committed) |
| `flutter analyze lib/features/onboarding lib/main_preview.dart test/features/onboarding` | `No issues found! (ran in 4.2s)` |
| `flutter test test/features/onboarding test/design_system` | `00:01 +39: All tests passed!` |

The 39 include `no_fork_guard_test.dart`, so the new feature code introduces no
raw `Color(0x` / `Colors.` / `Platform.is` / `defaultTargetPlatform` fork.

## Visual Fidelity Verification (rule 12e3)

Both images exist, open as real images, and I looked at both.

- `design-reference-permissions-android.png` (406x900) genuinely depicts the
  permissions screen of the canvas — not a neighbouring screen, placeholder, or
  error frame. `Design-Screen: permissions` is recorded in `story_master.md`.
- `implemented-permissions-emulator-5554.png` (405x900) shows this story's
  screen in the built app: title, subtitle, three cards, CTA, footer link. No
  red error screen, no spinner, no wrong screen.
- The report's comparison is concrete, not a bare token: per-state verdicts for
  granted / not-yet-decided / body, each naming the design property and its
  implemented counterpart.
- Nothing I see in the two frames contradicts the `VISUAL_FIDELITY: PASS`,
  **given** that the three chrome deltas below are recorded rather than hidden.
  Side by side, those three are the only differences I can see, and all three
  are reproduced identically on every other screen.

I spot-checked the report's fidelity table against the real markup rather than
trusting it. Every value in `Cupid Screens.dc.html:1532-1548` matches what the
table claims and what the code implements: `padding:16px 20px 40px` / `gap:13px`,
title block `padding:4px 0 6px`, Nunito 900 25px/1.25, subtitle 13px `--tx2`
`margin-top:8px`, card `padding:16px` + `--r-card` + `--surf` + `--shadow` +
`gap:13px` + `flex-start`, icon tile 44x44 r15, glyph 23px, card title 15px/800,
body 12px/1.5 `margin-top:4px`, toggle 50x30 r999 `padding:3px` with a 24x24
`#fff` knob, CTA `margin-top:4px` h54 `--r-btn` `--grad-hot` 16.5px/800 `--glow`,
footer centred 13px/700 `--tx2`. The table is accurate.

## Acceptance Criteria

| AC | Status | Note |
| --- | --- | --- |
| AC1 layout/spacing/token/typography match exactly | MET for the screen's own surface | Verified against the design markup and the rendered pair. Three shared-chrome deltas remain — D2, deferred with a named owner |
| AC2 deviations corrected in the app, not documented | MET | The screen was built against the design source; the CTA treatment was built locally rather than written up as a known gap |
| AC3 Material Symbols Rounded, never emoji | MET | Three `CupidIcon` glyphs, `fontFamily == CupidIcons.fontFamily`, asserted by test and visible in the capture. Codepoints `0xe90d`/`0xe413` were read out of the bundled font's cmap rather than recalled — the right way to avoid a plausible-but-wrong glyph |
| AC4 no new entry point required | MET only in the literal sense | The patch adds no user-facing route. But the AC's premise — that the screen is "already reachable in the shipped app" — is false. See D1 |

## D1 — the delivered screen is not reachable by any user (deferred to STORY-002)

This is the finding that must not get lost.

`git grep PermissionsScreen -- mobile/` returns exactly three sites: its own
file, `main_preview.dart:370` (the DEV-ONLY preview registry), and its test. A
case-insensitive search for `permission` across `mobile/lib` outside
`features/onboarding` returns nothing at all. There is no route, no navigation
edge, and no OS permission plumbing anywhere in the real app. `main.dart` never
mounts this screen. Its `onContinue`/`onSkip` are both null, so even the CTA and
"Để sau" — both wired to `goProfile` in the design source — are inert.

Why this is not `PATCH_REQUIRED` against STORY-009:

- STORY-002 (same requirement, `Status: PENDING`, lane `shared`) AC2 explicitly
  owns this edge: "otp succeeds → routed through permissions → onboarding
  profile setup → invite/join-code choice, in that order". The surface that
  hosts the entry point is named, so this is not the missing/contradictory-scope
  case that would make it `BLOCKED`.
- STORY-009's `WriteScope` excludes routing, and its own AC4 forbids adding an
  entry point. Demanding one here would contradict a governing AC and collide
  with STORY-002 in the same parallel wave.
- The story strictly improved matters: `permissions` was previously in
  `_notImplementedCanvasIds` rendering `PreviewNotImplementedScreen`. Placeholder
  → correct screen is not a regression (rule 7).

Why it is nonetheless dangerous, and what must happen:

STORY-009 says the screen is "already reachable in the shipped app". STORY-002
says it only "fixes the transitions between already-existing screens" and
"no new entry point created". **Both stories assume the other side handles
reachability, and neither does.** That is precisely how a finished screen ships
that no user can open.

Required actions, owner Scrum Master:

1. Correct STORY-002's `System Integration And Discoverability` premise — the
   permissions screen is new as of STORY-009 and needs an inbound edge built,
   not merely a corrected transition.
2. Make the REQ-002 integration review verify a real otp → permissions →
   profile-setup path in `main.dart`'s navigation, and do not let REQ-002 close
   with the screen reachable only from `main_preview.dart`.
3. Correct STORY-009's own false premise line so a later reader does not
   re-derive the wrong conclusion from it.

## Deferred Findings

- **D2 — three shared-chrome deltas, still unowned at requirement level.**
  Sky-gradient backdrop absent (`CupidColorTokens.skyGradient` holds the raw CSS
  string; nothing paints it), `CupidHeader` back arrow rendered `colorText` white
  on `colorSurface` instead of `--pink` on transparent with a Nunito 800 title,
  and the three decorative twinkle dots absent. All three live in
  `mobile/lib/design_system/**`, outside this story's write scope, and all three
  reproduce on every screen. Correctly deferred — fixing them from inside one
  feature would fork a shared widget, which `no_fork_guard_test.dart` exists to
  prevent. These are the same items STORY-006's approved review carried as N1/N2,
  and they are **still unassigned**. Scrum Master: raise the one design-system
  story and do not let REQ-002 integration review close with them unowned.
- **D3 — the CTA divergence is now forked two ways.** `CupidPrimaryButton`
  renders a flat `colorAccentPink` fill where the design wants `--grad-hot` plus
  `--glow`. STORY-006 accepted the shared widget as-is; STORY-009 instead built a
  local `_GradientCta`. Both choices are defensible in isolation, but the
  requirement now has two different CTA treatments across two screens. The
  design-system story from D2 must reconcile both, not just one.
- **D4 — `Complexity: trivial` no longer describes this story.** It created a new
  feature directory and a 372-line screen, reversing what STORY-018 recorded as
  an "approved scope cut — placeholder only". The work was necessary (AC1/AC2 are
  unsatisfiable otherwise) and `story_master.md` documents the reversal openly,
  which is the right handling. Two consequences to settle: Product Owner should
  ratify reversing an approved scope cut, and the classification should move to
  `standard` per the STORY-017 precedent. Note the runtime-smoke exemption of
  rule 12g was taken on the `trivial` classification — the actual risk is nil
  here, because the new code is unreachable from `main.dart` and so cannot affect
  app launch, and the preview APK did build and launch on emulator-5554 during
  capture. Reclassify for correctness, not because a smoke gap was hidden.
- **D5 — local icon constants.** `_fingerprintIcon` / `_photoLibraryIcon` are
  declared in the screen because `CupidIcons` exposes neither and the design
  system is out of write scope. Promote them into `CupidIcons` with the D2 story.
- **D6 — inert primary actions.** `onContinue`/`onSkip` are null and the preview
  passes neither; the design source wires both to `goProfile`. Owned by STORY-002
  along with D1.

Recorded so a later reviewer does not re-litigate it: the per-permission toggles
were made interactive. The static canvas fixture has no handler, but the design
markup sets `cursor:pointer` on the toggle div, and both card states must be
reachable to satisfy the story's In Scope item 3. Accepted as design-source
interpretation, not new scope.

## Risk Surfaces And Gates

| Surface | Gate | Result |
| --- | --- | --- |
| Mobile interaction / UI rendering | targeted widget tests | PASS — 6 new tests, re-run |
| Mobile build / static analysis | `flutter analyze` | PASS — re-run, clean |
| Design fidelity (12e2/12e3) | rendered pair + report, images inspected | PASS with D2 deferred |
| Design-source provenance | `Design-Screen` recorded; reference image confirmed to be the permissions screen | PASS |
| Shared-widget forking | `no_fork_guard_test.dart` | PASS |
| Navigation / discoverability (12e1) | user-facing entry point | **FAIL — deferred to STORY-002 as D1** |
| Runtime startup smoke (12g) | not required for `trivial`; preview APK built and launched during capture; unreachable from `main.dart` | Not required — see D4 |
| Setup/configuration | no env, dependency, or runtime config touched | Not applicable |

## Residual Risks

1. D1 — the screen has no user-facing entry point and depends entirely on
   STORY-002 landing correctly. This is the one item that can silently ship.
2. Only dark theme + `vi` were visually verified, per the story's Out of Scope
   (OQ5). `en` copy is covered by a widget test but not by a rendered capture.
3. Fidelity was verified on one Android emulator frame at 412dp; no other device
   size or iOS frame was captured. `Face ID` iOS copy is test-covered only.
4. D2 remains unowned at requirement level across at least three stories now.

## Verdict

The screen itself is a faithful, well-evidenced implementation: every design
value I checked against the source markup matches, both rendered frames are real
and depict the right screen, analyze and 39/39 tests pass on independent re-run,
and the icon codepoints were sourced properly rather than guessed. The
implementer also disclosed the false premise it inherited instead of quietly
building around it, which is why D1 was findable at all.

Approved as DEFERRED_ONLY with D1–D6 carried. D1 and D2 are named required
actions for the REQ-002 integration review, not blockers on this story.

## State Recommendation

- Keep `Implementation (Development)` checked; check `Review (Reviewer)`.
- Story status: `DONE`.
- Scrum Master: carry D1 (entry point, → STORY-002) and D2 (design-system
  chrome story) as explicit REQ-002 integration-review preconditions.

REVIEW_COMPLETE: DEFERRED_ONLY
