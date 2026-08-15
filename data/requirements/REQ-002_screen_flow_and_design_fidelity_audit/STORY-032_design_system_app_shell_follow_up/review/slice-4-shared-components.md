# Review Slice 4/4 — `phase3-shared-components` (STORY-032)

Story: STORY-032 Design System — App-Shell Background, Button & Header Follow-Up
Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Slice: 4 of 4 — `phase3-shared-components`
AC in slice: AC1, AC2, AC3, AC4[Waiting For Pairing], AC5
Tier: 3 (Scoped Slice)
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-032`
BaseHead: `079d4801831037e2540a813f66efe5e4258eaae4`
Worktree HEAD at review: `fcd11de` (impl `d43d9f2` + slices 1-3 review artifacts)
Design reference: `cupid-app-design-system` (locked)
Reviewed: 2026-08-14

## Slice Verdict

PATCH_REQUIRED

Implementation is correct. Both blocking findings are **evidence-package**
defects, not code defects: AC3 has no visual proof at all, and the AC4
package is missing the rule-12e3 fields. No source change is requested by
this slice.

## Path Resolution

The handoff file list used elided paths. Resolved against
`git ls-files` before review; two differ from the naive reading of the list:

| Handoff entry | Actual tracked path |
| --- | --- |
| `features/.../waiting_screen.dart` | `mobile/lib/features/pairing/presentation/screens/waiting_screen.dart` |
| `features/.../pet_screen.dart` | `mobile/lib/features/pet/presentation/pet_screen.dart` (no `screens/` segment) |
| `features/.../reminder_schedule_screen.dart` | `mobile/lib/features/reminders/presentation/screens/reminder_schedule_screen.dart` |
| `features/.../vibe_screen.dart` | `mobile/lib/features/vibes/presentation/vibe_screen.dart` (no `screens/` segment) |
| `design_system/adaptive/cupid_header.dart` | as listed |
| `design_system/adaptive/cupid_primary_button.dart` | as listed |
| `test/design_system/adaptive_widgets_test.dart` | as listed |

## File-By-File

| File | Change | Design source check | Verdict |
| --- | --- | --- | --- |
| `mobile/lib/design_system/adaptive/cupid_primary_button.dart` | `SizedBox(height: 54)` + `DecoratedBox(gradient: gradientHot, boxShadow: glowShadow)` wrapper; `ElevatedButton` reduced to transparent bg / transparent shadow / elevation 0; label 16.5 w800 | `Cupid Screens.dc.html:519,1445,1490,1524,1545,1567` all draw the CTA as `height:54px; background:var(--grad-hot); font-size:16.5px; font-weight:800; box-shadow:var(--glow)`. `Cupid App.dc.html:27,30` define `--grad-hot: linear-gradient(120deg,#FF7FB6,#B78CF5)` and `--glow: 0 8px 28px rgba(255,107,168,.34)` | PASS (nit N-4) |
| `mobile/lib/design_system/adaptive/cupid_header.dart` | iOS: `Container(color: colorBackground)` -> `ClipRect > BackdropFilter(sigma 16) > Padding`; Material: `backgroundColor: colorSurface` -> `Colors.transparent` plus `flexibleSpace: ClipRect > BackdropFilter(sigma 16)`; back glyph `size: 26`, Material ink `colorText` -> `colorAccentPink` | `Cupid Screens.dc.html:50` = `background:transparent; backdrop-filter:blur(16px)`; `:51` back glyph = `font-size:26px; color:var(--pink)`. All four values match | PASS on code, FAIL on evidence (F2) |
| `mobile/lib/features/pairing/presentation/screens/waiting_screen.dart` | removed `backgroundColor: colors.colorBackground` (1 line) | Screen mounts neither `CupidHeader` nor `CupidPrimaryButton` (verified) — background only | PASS |
| `mobile/lib/features/pet/presentation/pet_screen.dart` | removed `backgroundColor` + the now-unused `colors` local (3 lines) | Mounts `CupidPrimaryButton` at `:152`; `colors` local correctly dropped, no other reference remained | PASS |
| `mobile/lib/features/reminders/presentation/screens/reminder_schedule_screen.dart` | removed `backgroundColor` (1 line) | Mounts `CupidHeader` at `:138` and `CupidPrimaryButton` at `:348`; `colors` local still used elsewhere, correctly retained | PASS |
| `mobile/lib/features/vibes/presentation/vibe_screen.dart` | removed `backgroundColor` (1 line) | Mounts `CupidHeader` at `:79`; `colors` local still used elsewhere, correctly retained | PASS |
| `mobile/test/design_system/adaptive_widgets_test.dart` | +110 lines, 3 new cases (Material header transparent+blur+pink ink, iOS header blur, CTA gradient/glow/54pt on both platforms) | Assertions transcribe the design values above, not invented ones | PASS (nit N-5) |

## AC Traceability

### AC1 — shared background reaches every screen — PASS

All four screens in this slice dropped their `Scaffold` `backgroundColor:
colors.colorBackground` override, which is the exact mechanism that was
occluding the shared wash. Independently confirmed at render, not just in
code: I opened
`visual-fidelity/ac4-waiting-for-pairing-dark-vi.png` directly and the
three-lobe sky wash is present (purple lobe top-left, pink lobe top-right,
teal bleed from the bottom edge), matching `--sky` in `Cupid App.dc.html:30`.

### AC2 — `CupidPrimaryButton` gradient + glow — PASS (nit N-4)

Every value in the restyle is traceable to the design source CTA block
(see file table). The `DecoratedBox`-wrapper approach is sound: the wrapper
owns fill + glow, and the button neutralizes `backgroundColor`, `shadowColor`
and `elevation` so neither is painted twice. `_primaryCtaHeight = 54` is
correctly introduced as a separate constant rather than overloading
`CupidPlatformTokens.tapTarget`, which remains the minimum-touch-size token.

Visual proof for AC2 exists only through slice 2's Forgot Password capture.
The two CTA-mounting screens in *this* slice (`pet_screen.dart:152`,
`reminder_schedule_screen.dart:348`) have no render — acceptable, since the
component is shared and slice 2 already proved it paints.

### AC3 — `CupidHeader` transparent/blurred surface — code PASS, evidence FAIL (F2)

Code matches the design source on all four changed values. Structural
coverage is real (transparent `AppBar.backgroundColor`, exactly one
`BackdropFilter` per platform, back glyph resolved to `--pink`).

But AC3 is written as a *visual* criterion — "when compared against the
locked design source, then its Material treatment ... matches exactly, with
no visible opaque-band deviation" — and there is no render of any
`CupidHeader` screen anywhere in the evidence package. The visual-fidelity
report concedes this itself at `visual-fidelity-report.md:81-82`. See F2.

### AC4 — Waiting For Pairing re-render — render PASS, package FAIL (F3, F4)

Render is genuinely correct. I inspected
`ac4-waiting-for-pairing-dark-vi.png` myself: sky wash present, and all
three twinkle stars are discernible (white top-left, pink top-right, purple
mid-right), consistent with the report's claimed positions.

Two scoping notes:
- AC4's "restyled CTA/header" clause is vacuous for this screen. Waiting
  For Pairing mounts neither `CupidHeader` nor `CupidPrimaryButton`
  (verified); its "Làm mới" is an outline pill, so AC4 reduces to the
  background wash here. The report states this correctly.
- The package itself does not satisfy reviewer rule 12e3. See F3.

**Correction to the slice-2 carry-forward hypothesis.** The handoff
suggested O-1 (`main_preview.dart` never mounting `CupidAppBackground`)
might be the shared root cause of F1. It is **not** the cause for
AC4[waiting]. The capture harness described at
`visual-fidelity-report.md:24-30` mounts `CupidAppBackground` directly in a
purpose-built `MaterialApp`, bypassing `main_preview.dart` entirely — and
the resulting render visibly *does* carry the wash. F1 and F3 are a
documentation-completeness gap in the report, not a render-path gap. Final
Synthesis should not accept an O-1 fix as closing F1/F3.

### AC5 — existing contract tests still pass, intentional edits disclosed — PASS (nit N-5)

Both halves hold. Independently re-run below, not copied from
`coding-plan/test-results.md`. The single intentional test change in Phase 3
is disclosed at `story_master.md:36-38`, and the narrowing is the correct
minimal form: it excludes the CTA's own `--grad-hot` `DecoratedBox` from the
segment count rather than bumping the expected count, so the assertion still
fails if a *third* hot-gradient surface appears.

## Test Evidence (independently re-run)

Flutter 3.44.1 stable / Dart 3.12.1, run from the story worktree
(`.../story-REQ-002_..._audit-STORY-032/mobile`). All runs unfiltered.

| Command | Result |
| --- | --- |
| `flutter test test/design_system/adaptive_widgets_test.dart` | 11/11 pass — includes all 3 new Phase 3 cases |
| `flutter test test/design_system/no_fork_guard_test.dart test/design_system/contrast_test.dart test/design_system/theme_matrix_test.dart test/design_system/icon_variant_test.dart` | 25/25 pass — the AC5-named sibling contract tests |
| `flutter test test/features/pairing/presentation/waiting_screen_test.dart test/features/vibes/presentation/vibe_screen_test.dart test/features/pet/presentation/pet_screen_test.dart test/features/pet/presentation/pet_design_fidelity_test.dart test/features/reminders/reminder_schedule_screen_test.dart` | 38/38 pass — the four slice screens |
| `flutter test test/features/anti_ghosting/presentation/anti_ghost_screen_test.dart` | 6/6 pass — the deliberately narrowed assertion |

Total 80/80 pass, 0 fail.

`flutter analyze` over the seven slice files: 2 `info` only, both
`prefer_initializing_formals` (`waiting_screen.dart:25`, `vibe_screen.dart:27`).
Both are pre-existing — this story's diff on those files removes a single
`backgroundColor` line and touches neither constructor. Not a finding.

## Verified Non-Issues

Recorded so Final Synthesis does not re-open them.

- **M3 scrolled-under tint does not reintroduce an opaque band.** The
  obvious risk with `backgroundColor: Colors.transparent` on a
  `useMaterial3: true` `AppBar` (`cupid_theme.dart:40`) is that scrolling
  content under it re-applies a surface tint, undoing exactly what AC3 asks
  for. Checked against the installed SDK: at
  `app_bar.dart:935-940`, `scrolledUnderBackground` resolves through
  `widget.backgroundColor` first, so it stays transparent; and
  `_AppBarDefaultsM3` does not define `scrolledUnderElevation`, so
  `app_bar.dart:951-956` falls back to `elevation` (0). With elevation 0 the
  `surfaceTint` at `app_bar.dart:1236-1243` contributes nothing. No band
  appears on scroll. No change needed.
- **Disabled-CTA appearance is not a regression.** With the new wrapper, a
  disabled `CupidPrimaryButton` still paints the full gradient and glow. But
  `ElevatedButton.styleFrom` was already called without
  `disabledBackgroundColor`/`disabledForegroundColor` before this story, so
  the enabled colour already applied to every state. Pre-existing, out of
  scope, not introduced here.
- **The `BackdropFilter` is visually inert on non-overlapping headers**, since
  `extendBodyBehindAppBar` is not set and the backdrop is a smooth gradient.
  This is *not* a deviation: the design source header at
  `Cupid Screens.dc.html:50` is likewise `flex:none` in normal flow with the
  page background behind it. Faithful. Noted only as a minor per-frame
  `saveLayer` cost (N-6).

## Findings

| ID | Severity | Owner | AC | Blocking |
| --- | --- | --- | --- | --- |
| F2 | Medium | mobile-dev | AC3 | Yes |
| F3 | Medium | mobile-dev | AC4[waiting] | Yes |
| F4 | Low-Medium | mobile-dev / Final Synthesis | AC4 | No |
| N-4 | Low | Final Synthesis | AC2 | No |
| N-5 | Low | Final Synthesis | AC5 | No |
| N-6 | Low | Final Synthesis | AC3 | No |

### F2 — AC3 has no visual evidence at all (Medium, blocking)

AC3 requires a comparison against the locked design source. The
`visual-fidelity/` package contains two captures, and neither screen mounts a
`CupidHeader`; the report concedes this at `visual-fidelity-report.md:81-82`
and substitutes widget-tree assertions. Those assertions cannot detect a
wrong blur sigma, a wrong glyph size, a `ClipRect` clipping the wrong rect, or
a header that is structurally right and visually wrong.

This is cheap to close. Two screens in this very slice already mount a
`CupidHeader` — `reminder_schedule_screen.dart:138` and `vibe_screen.dart:79`
— and the harness that produced the existing two captures can render either
one unchanged.

Fix: capture one dark + `vi` render of a `CupidHeader` screen, commit it to
`visual-fidelity/`, and compare it against the design source header at
`Cupid Screens.dc.html:50-56`.

### F3 — AC4[waiting] package fails reviewer rule 12e3 (Medium, blocking)

Same defect class as slice 2's F1, on the same shared file. Confirmed absent
for the Waiting For Pairing screen specifically:

- No design-reference render. `git ls-files` on
  `visual-fidelity/` returns exactly `ac4-forgot-password-dark-vi.png`,
  `ac4-waiting-for-pairing-dark-vi.png`, `visual-fidelity-report.md` — the
  two app renders have nothing to be compared *against*.
- No resolved `Design-Screen: <id>` line — 0 occurrences in the report.
- No `VISUAL_FIDELITY: PASS|FAIL` line — 0 occurrences. The report uses the
  non-conforming `Outcome: CONFIRMED AT RENDER` at
  `visual-fidelity-report.md:11`.

Because F1 and F3 are the same three omissions in one file, a single patch
closes both. Per the correction above, that patch is editorial plus one
design-reference render; it is not an O-1 code fix.

### F4 — AC4 captures are not reproducible (Low-Medium, non-blocking)

`visual-fidelity-report.md:43-45` states the capture harness is deliberately
not committed, on the grounds that the story's write scope does not cover a
new file under `mobile/test/`. The consequence is that neither this review nor
any future story can regenerate or diff these captures; the report offers
prose parameters as a substitute. The reasoning about write scope is
defensible, so I am not escalating this to blocking — but Final Synthesis
should decide explicitly whether prose parameters are an acceptable
reproducibility standard for REQ-002 visual evidence, rather than letting it
pass silently.

### N-4 — CTA label colour is `--tx`, design says `#fff` (Low)

Design source CTA blocks specify `color:#fff`;
`cupid_primary_button.dart:76` uses `colors.colorText` (`--tx` = `#F7EEFB`).
A 3-unit delta per channel, disclosed at `visual-fidelity-report.md:73`.
Below AC2's bar ("no visible flat-color deviation"), and using the token is
arguably more correct than hard-coding `#fff`. Recording only so it is a
decision rather than an oversight.

### N-5 — one new assertion is vacuous (Low)

In `adaptive_widgets_test.dart`, the iOS header case asserts
`isNot(contains(dark.colorBackground))` over `Container` descendants of
`CupidHeader`. After the change `_IosHeader` contains no `Container` at all
(it is now `ClipRect > BackdropFilter > Padding`), so the matcher runs against
an empty iterable and passes trivially — it would also pass if the header
were deleted outright. The `BackdropFilter` `findsOneWidget` assertion in the
same test carries the real coverage, so coverage is adequate overall; the
`Container` assertion is dead weight rather than a hole.

### N-6 — inert `BackdropFilter` cost (Low)

Per the Verified Non-Issues note, both headers now force a `saveLayer` plus a
16-sigma blur every frame while sampling a smooth gradient, which is close to
a visual no-op in the current composition. Correct per the design source, but
worth a note if header jank is ever reported on low-end Android.

## Out Of Slice

For Final Synthesis / Scrum Master, not actionable within slice 4:

1. **F1 and F3 are one patch.** Both are the same three missing rule-12e3
   elements in the single shared `visual-fidelity-report.md`. Do not schedule
   them as two independent fixes, and do not accept an O-1 code fix as
   closing either — see the AC4 correction above.
2. **F2 should ride along with the F1/F3 patch.** All three want the same
   thing (a conforming visual-fidelity package); adding a `CupidHeader`
   render while the harness is already open is materially cheaper than a
   separate round.
3. **STORY-033 collision on the back-arrow ink.** `story_master.md:129-141`
   records that STORY-033 owns `CupidHeader` back-arrow ink specifically.
   This story has now landed that exact change (`colorText` ->
   `colorAccentPink`, `cupid_header.dart` Material branch). Scrum Master
   should confirm STORY-033's scope is reduced accordingly before it starts,
   or the two stories will edit the same lines.
4. **AC3's "anywhere in the app" reach is unverified beyond this slice.**
   I verified the two `CupidHeader` mount sites inside my file set. A
   requirement-level sweep of every `CupidHeader`/`CupidPrimaryButton` call
   site is Final Synthesis or requirement-integration scope.
5. **`story_master.md:19-21` still shows Review unchecked and Status
   PENDING.** Expected mid-review; flagging so the DONE gate is not reached
   with stale artifact checkboxes.

SLICE_VERDICT: PATCH_REQUIRED
