# Review Report: STORY-045 Pairing Choice Surface/CTA Styling Fidelity

Outcome: DEFERRED_ONLY

Review type: `compact-story-review`
Story: `STORY-045_pairing_choice_design_fidelity_hardening` (REQ-002)
Complexity: trivial | Implementation Lane: mobile (single lane) | Retro origin: RWB-20260816-012
Reviewed at BaseHead `e570c5eda608c3e6956c0897c9b2b48c1919b157`

## Scope Gate

- Review report path: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-045_pairing_choice_design_fidelity_hardening/review/review-report.md`
- Source files in scope (1 changed, from `git diff --name-only <BaseHead>` restricted to `mobile/`):
  `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart` (+13/-3)
- Source files read for claim verification only (not changed by this story):
  `cupid_primary_button.dart`, `cupid_app_background.dart`, `cupid_app.dart`,
  `pair_gate_shell.dart`, `joincode_screen.dart` (ranged), `cupid_spacing.dart`,
  `main.dart`, `android/app/src/main/AndroidManifest.xml`
- Evidence files in scope: `visual-fidelity/visual-fidelity-report.md`,
  `visual-fidelity/design-reference-pairingchoice-android.png`,
  `visual-fidelity/implemented-pairingchoice-emulator-5560.png`
- Governing artifacts: `story_master.md`, `requirements/requirements.md` (6 ACs), `scrum-master-checkpoint.md`
- Touched risk surfaces: mobile interaction / UI layout only. No contract, persistence,
  migration, permission, deep-link, security, or runtime-configuration surface touched.
- Query keys: AC1-AC6, `gradientHot`, `glowShadow`, `CupidAppBackground`, `PairingChoiceScreen`,
  `Align`/`EdgeInsets.fromLTRB`, `type.display`
- Phase 2 proceeded: YES. Within compact budget (1 changed file, 0 governing artifacts over ~20 KB).

## Acceptance Criteria

| AC | Verdict | Basis |
|----|---------|-------|
| 1 — background gradient + particles | PASS | Verified in both PNGs; `CupidAppBackground` mounted at composition root (`cupid_app.dart:58-59`), 3 twinkle stars from `CupidSkyPalette.stars`. Already closed pre-story. |
| 2 — CTA gradient + glow | PASS | Verified in both PNGs; `CupidPrimaryButton` applies `colors.gradientHot` + `colors.glowShadow` (`cupid_primary_button.dart:53,55`). Already closed pre-story. |
| 3 — type scale, pill label 1 line, title wraps at same word | PASS | Both PNGs show a 1-line pill label and the title wrapping before `Cupid`. Delivered by `type.display.copyWith(fontSize: 27, height: 1.3)` + the 28dp horizontal inset. |
| 4 — title vertical offset ~23% | PASS | Both PNGs place the title ink top at ~22% of frame. Delivered by `Center` -> `Align(topCenter)` + `EdgeInsets.fromLTRB(28, 150, 28, 0)`. |
| 5 — paired same-state evidence + `VISUAL_FIDELITY: PASS` | PASS | Both PNGs present and readable; report records the verdict with a per-AC measured table, named device, theme, locale, and state. |
| 6 — content/structure/navigation unchanged | PASS | Diff touches only `Align`, `Padding`, and the title `TextStyle`. No string, widget, or navigation edge changed; `_openInvite`/`_openJoincode` untouched. Confirmed by rerunning `pairing_choice_screen_test.dart` (4/4 pass). |

## Root-Cause Claim Verification

The implementer's claim that AC1/AC2 were already closed before this story, and that
STORY-034 finding D1 measured them off a stale, mis-scaled STORY-002-era capture, is
CONFIRMED independently in code — not accepted on the report's word:

- `mobile/lib/design_system/adaptive/cupid_primary_button.dart:53,55` already applies
  `gradient: colors.gradientHot` and `boxShadow: colors.glowShadow`.
- `mobile/lib/app/cupid_app.dart:58-59` already mounts `CupidAppBackground` via
  `MaterialApp.builder`; that widget paints the sky gradient layers plus three star
  particles, and `pairing_choice_screen.dart`'s `Scaffold` sets no `backgroundColor`, so
  the theme's transparent `scaffoldBackgroundColor` lets it through.

Neither file is in this story's diff, so both were in that state at BaseHead. Only AC3
and AC4 required a code change, which matches the delivered diff exactly.

Carry-forward for Scrum Master: this substantiates the checkpoint's note that still-PENDING
RWB-20260816-013..021 may also have been scoped off the same stale/mis-scaled capture set.
Worth a baseline re-capture before each of those items is scoped. Not a STORY-045 blocker.

## Design Fidelity (rule 12e3, mobile lane — verified, not re-captured)

- Both images exist, open as real images, and were read visually.
- The implemented capture shows THIS story's screen in the built app — not a placeholder,
  error frame, spinner, or wrong screen.
- The reference depicts the same pairing-choice screen (title `Ghép đôi để mở khoá Cupid`,
  primary pair CTA, `Tôi đã có mã` secondary link). Correct screen confirmed by reading the
  image, not by filename.
- Resolved screen id is recorded as `--screen=pairingchoice` in the reference render command
  rather than a literal `Design-Screen:` field; the substance is traceable and correct.
- What I see in the two images does not contradict the `PASS`: same layout, gradient,
  particles, CTA treatment, type scale, wrap point, and title position. The two small deltas
  the report itself names are carried as DF3 below.

## Entry Point Reachability (rule 12e1)

Independently verified in code, not accepted on an evidence line: `CupidApp` -> `SplashScreen`
-> `PairGateShell` -> `_AppShellView`, where `PairGateUnpaired()` mounts `PairingChoiceScreen`
(`mobile/lib/core/navigation/pair_gate_shell.dart:139`). Real in-flow, discoverable entry
point; not direct-URL-only. This story adds no new entry point and changes no navigation.

## Critical Gates

| Gate | Status | Evidence |
|------|--------|----------|
| Targeted mobile widget tests | PASS | Report records 170/170 across `test/features/pairing test/design_system test/app`. Independently reran `pairing_choice_screen_test.dart` — 4/4 pass, including both navigation edges and the NO_CHROME/NO_TABS assertion. |
| Static analysis | PASS (reported) | `flutter analyze lib test` — 80 `info`, 0 errors, 0 warnings, byte-identical to pre-change baseline. |
| Mobile build | PASS (reported) | `flutter build apk --debug -t lib/main_preview.dart`. |
| Rendered design fidelity | PASS | See section above. |
| Entry point reachability | PASS | Verified in code (see above). |
| Runtime startup smoke | NOT REQUIRED | Rule 12g scopes this to non-trivial stories; `Complexity: trivial`. De facto satisfied anyway — the APK was installed on `emulator-5560` and the screen captured from the running app. |
| Configuration guide | NOT REQUIRED | No setup, env, integration, or runtime-configuration surface touched. |

## Deferred Findings

**DF1 — Layout no longer tolerates short viewports; introduced by this story.**
`mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart:66-76`
replaced `Center` + `EdgeInsets.all(CupidSpacing.lg)` with `Align(topCenter)` +
`EdgeInsets.fromLTRB(28, 150, 28, 0)` and no scroll fallback. The required height inside
`SafeArea` rises from roughly 211dp to roughly 350dp (150 top pad + 2-line title at
27x1.3x2 = 70.2 + `xl` 32 + CTA 54 + `sm` 8 + `TextButton` ~36). Neither `main.dart` nor
`AndroidManifest.xml` locks orientation, and `configChanges` includes `orientation|screenSize`,
so landscape is reachable. On a 360x640dp phone rotated (usable height ~312dp) this overflows
by roughly 38dp; on the capture device rotated it fits by only ~13dp and overflows once
`font_scale` reaches ~1.3. The sibling screen in the same flow, `joincode_screen.dart:138`,
made the identical "design column flows from the top" transcription and guarded it with
`SingleChildScrollView`.
Derived arithmetically from the widget tree and the token values; not empirically reproduced
(writing a probe test or re-capturing is outside the reviewer lane).
Remediation: wrap the `Padding` in `SingleChildScrollView`, matching the `joincode_screen.dart`
precedent. One line, no visual change in portrait, so the existing evidence pair stays valid.
Not blocking: no AC, UX section, or design reference in scope covers landscape or elevated
font scale — the locked design source is a fixed 412x915 portrait frame — and all six ACs pass
with real rendered evidence in the specified state.
Owner: mobile.

**DF2 — No `## Entry Point Reachability` evidence section exists.**
This trivial story produced no `coding-plan/test-results.md`; verification commands live in
`visual-fidelity-report.md` instead, which is acceptable under rule 9 for trivial stories.
The substantive requirement of rule 12e1 is met — I verified the entry point directly in the
router rather than on trust (see above), which is the stronger of the rule's two checks.
Recording the gap so it is not read later as an unexamined skip.
Owner: process.

**DF3 — Two small visual deltas, both pre-existing and outside AC scope.**
Already disclosed in the implementer's report rather than hidden, and both confirmed against
the images: the pill renders 52px against the reference's 48px, from the shared
`_primaryCtaHeight = 54` constant in `cupid_primary_button.dart:20` that applies identically
on every screen using the primary CTA; and the secondary link sits ~13px lower, from
`TextButton`'s default internal padding. AC2 scopes the CTA check to gradient and glow, and
neither delta is among D1's four deviations. Changing either would be a cross-screen visual
change this story's AC6 excludes. Correctly left alone.
Owner: none — cross-screen, would need its own scoped item.

## Blocking Findings

None.

## Rationale

All six acceptance criteria pass against real rendered evidence in the specified state
(dark theme, `vi` locale, unpaired, Android). The change is minimal and well-targeted: one
file, +13/-3, no shared component modified or forked, no design token added, no string or
navigation edge touched. The implementer's inverted root-cause finding — that two of D1's
four deviations were measurement artifacts rather than defects — is correct and I confirmed
it in code independently. The one regression I found (DF1) is real and attributable to this
story, but it falls entirely outside the story's acceptance surface and has a known one-line
remediation already established elsewhere in the same feature, so it is recorded rather than
returned.

`DEFERRED_ONLY` rather than `CLEAN` because DF1 is a genuine behavioral regression introduced
here and must not be lost, and because DF2/DF3 are worth preserving for the retro trail.

## State Recommendation

- Keep `Implementation (Development)` checked.
- Check `Review (Reviewer)`.
- Story status: `DONE`.
- Resolve `RWB-20260816-012` — D1's four deviations are closed (two were pre-closed
  measurement artifacts, two fixed here).
- Queue DF1 as its own small mobile item.
- Apply the DF-carry-forward note above when scoping RWB-20260816-013..021.
