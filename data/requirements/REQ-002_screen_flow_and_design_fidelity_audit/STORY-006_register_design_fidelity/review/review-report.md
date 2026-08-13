# Review Report — STORY-006 Design Fidelity: Register

Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Story: STORY-006 Design Fidelity — Register
Mode: compact-story-review (UI lane, rendered visual-fidelity comparison)
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-006`
BaseHead: `8396273e6a5e6a2798557aa68864f0ef24cd939b`

Round 1 — reviewed commit `9f008dc` — Outcome: PATCH_REQUIRED (P1 gating)
Round 2 — reviewed commit `9919519` — Outcome: DEFERRED_ONLY

Review round: 2

Outcome: DEFERRED_ONLY

## Round 2 Scope

Patch diff reviewed: `git diff 8765e13 9919519` over

- `mobile/lib/features/auth/presentation/screens/register_screen.dart` (113 +, 82 -)
- `mobile/test/features/auth/presentation/screens/register_screen_test.dart` (80 +, 16 -)
- `story_master.md` (rework log)

Round 1's design-source fidelity table (title, subtitle, field cards,
micro-labels, input text, strength meter, consent geometry, footer, padding
rhythm, `Tên gọi` copy) is unchanged by this patch and is not re-derived here.
Only the three findings and any regression they could introduce were re-checked.

## Evidence Independently Re-Run

Re-executed in the story worktree with `/Users/alantravala/flutter/bin/flutter`.
Nothing below is accepted from the dev's report.

| Command | Result |
| --- | --- |
| `flutter analyze` on both changed files | No issues found (1.5s) |
| `flutter test test/features/auth/presentation/screens/register_screen_test.dart` | 7 tests, all passed (was 5 in round 1; +2 new) |
| `flutter test test/design_system test/features/auth` | 57 tests, all passed (was 55; no regression) |

Two additional throwaway probe suites were run against the built widget tree to
measure geometry and dump the semantics tree directly, rather than trusting the
dev's assertions. Their measurements are quoted below.

## Finding Resolution

### P1 — RESOLVED (was the only gating finding)

`register_screen.dart:465-544`. The gesture moved from the bare 24x24
`Container` to the whole consent row: `GestureDetector(behavior:
HitTestBehavior.opaque)` over a `ConstrainedBox(minHeight: platform.tapTarget)`.

Independently measured on the built tree, not from the test's own assertions:

- Semantics node for the consent control: `label="Đồng ý với Điều khoản…"`,
  `flags=[hasCheckedState,isChecked]`, `tap=true`, `rect=Size(756.0, 48.0)`.
  Both dimensions meet the Material `tapTarget` of 48.
- The painted box is still exactly `Size(24, 24)` with radius 9, first child of
  a `crossAxisAlignment: start` row, so it keeps the design's position
  (l.1486-1489).
- A tap 20dp below the painted box's centre — i.e. outside the old 24dp hit
  area — toggles consent.

The dev's reasoning that Flutter cannot hit-test outside a widget's layout
bounds is correct, so raising the row's minimum height is a legitimate way to
satisfy `ux/uiux-spec.md` section 7. The governing-artifact violation is closed.

Behaviour change worth recording: the terms/privacy link text is now inside the
tap region, so tapping it toggles consent. The design source's `<a href="#">`
placeholders have no destination and the class dartdoc already states they
carry no tap target, so nothing is shadowed.

### P2 — RESOLVED

`register_screen.dart:319-340`. The ring moved to `foregroundDecoration`;
`decoration` now carries only fill, radius and shadow, with `border` null.
Measured: each field's `TextField` node is `728.0` wide on an 800dp surface
= `800 - 2*20` screen padding `- 2*16` card padding. The previous build gave
725.0 (the 1.5dp `Border.dimensions` inset). The inset is gone and the card is
back on the design's exact `13px 16px` box.

The unfocused ring is kept non-null in the card's own fill colour so the
`Container` tree shape never changes. That is the right call — a null/non-null
swap would re-inflate the field and drop its text input connection on focus —
and the accompanying test now pins both the card size and the label origin
across the focus transition.

### P3 — PARTIALLY RESOLVED (non-gating, as in round 1)

`register_screen.dart:345-376`. `Semantics(label:, textField: true)` and
`ExcludeSemantics` are both in place and the label is now present in the tree.
The semantics dump shows the fix is incomplete, though:

```
NODE label="Tên gọi" flags=[isTextField] tap=false rect=Size(728.0, 24.0)
  NODE label=""      flags=[isTextField,isFocusable] tap=true rect=Size(728.0, 24.0)
```

The label sits on a wrapper node; the node a screen reader actually focuses —
the one carrying `isFocusable` and the tap action — still has an empty label.
`find.bySemanticsLabel('Tên gọi')` passes because it matches the wrapper, so
the new test does not catch this. Strictly better than round 1 (there was no
label anywhere), but a reader focusing the input still hears an unnamed text
field. Completing it needs the annotation merged into the field's own node
(`MergeSemantics`, or `container`/`explicitChildNodes` on the wrapper).

Carried as a deferral for the same reason as round 1: no AC in this story
covers input semantics and `ux/uiux-spec.md` section 7 does not name this case.

## New Observations Introduced By The Round-2 Patch

### N4 — the `minHeight` claim in the code comment and `story_master.md` is false

`register_screen.dart:460-464` states "The consent copy is always taller than
that in practice, so no rendered pixel moves." `story_master.md` repeats it as
"the constraint never binds and no pixel moves."

Measured directly, both are wrong at the project's own default harness surface:

```
PROBE_800 hitArea=Size(756.0, 48.0) row=Size(756.0, 48.0) text=Size(721.0, 36.0)
PROBE_390 hitArea=Size(346.0, 72.0) row=Size(346.0, 72.0) text=Size(311.0, 72.0)
```

At 800dp the consent copy is 36dp tall and the constraint binds, stretching the
row to 48 and pushing the CTA and footer down 12dp. The dev's own 320/375/430
measurements were taken with the Flutter test font, whose glyph advance is a
full em — roughly double a real UI font — so those widths do not establish the
claim for the shipped typeface either. With production metrics the vi consent
string is very likely two lines (36dp) at phone widths, in which case the
constraint binds there too.

Not gating, because the drift is *mandated* by the governing artifact rather
than being a defect: `ux/uiux-spec.md` section 7 requires 48dp with "no new
exemption", Flutter cannot hit-test outside layout bounds, and the design's
content-height consent row is what has to yield. The maximum consequence is
~12dp of extra vertical space before the CTA on a scrolling screen.

Required before REQ-002 integration review closes: correct the comment and the
`story_master.md` rework note to state the real trade-off, and record the
divergence in `visual-fidelity/visual-fidelity-report.md`, which currently does
not mention it. This is a fidelity-audit requirement; an undocumented spacing
divergence is exactly what it exists to surface.

### N5 — consent announcement now duplicates its own copy

Moving the `Semantics` wrapper outside the row merged the explicit label with
the row text into one node:

```
label="Đồng ý với Điều khoản và Chính sách riêng tư
Tôi đồng ý với Điều khoản và Chính sách riêng tư — bao gồm việc bị Bún dỗi khi lười nhắn tin."
```

A screen reader now reads the consent sentence twice in two phrasings. Before
the patch the wrapper enclosed only the box, so the two were separate nodes.
Non-gating verbosity regression; the cheap fix is to drop the explicit `label:`
and keep only `checked:`, letting the row copy name the control.

## Deferrals Carried Forward From Round 1

Unchanged by this patch; re-stated so the integration review has them in one
place.

- **N1 — `CupidPrimaryButton` CTA mismatch.** Design wants `height:54px`,
  `--grad-hot`, 16.5px/800, `--glow` (l.1490); the shared widget renders a solid
  `colorAccentPink` fill at `tapTarget` height with no glow. Correctly deferred:
  fixing it inside one screen story would fork or silently restyle the shared
  component. Still unowned at requirement level. Scrum Master action: raise one
  design-system story and do not let the REQ-002 integration review close with
  this unassigned.
- **N2 — `skyGradient` never painted.** App-shell scope, correctly deferred.
- **N3 — missing back header.** Verified as an intentional divergence: the
  design source excludes `register` from `NO_CHROME` (l.1951) and sets
  `BACK_TO.register = 'welcome'` (l.1853), but `STORY-003_auth/ux/uiux-spec.md`
  section 1 overrides it to chrome `none`. No AC dropped. Scrum Master action:
  record so Scope A does not "fix" it back and a later reviewer does not
  re-litigate it.

Round 1's non-gating interpretation notes also stand unchanged: focus-ring
colour semantics borrowed from the OTP screen, terms-link pink/w700 styling,
the check glyph resolving to `colorText`, `_termsAccepted` defaulting to `true`
(Product Owner question, not visual), and `_FieldCard` being a screen-private
duplicate of the pattern STORY-005 is reworking on its own branch.

## Acceptance Criteria

| AC | Status | Note |
| --- | --- | --- |
| AC1 layout/spacing/token/typography | MET | Round-1 P2 inset closed; card content measured back at the design's exact 16dp horizontal padding. N4 spacing trade-off recorded. |
| AC2 deviations fixed in app, not documented | MET | Unchanged by this patch |
| AC3 validation-state fidelity | MET | Unchanged by this patch |
| AC4 no new entry point | MET | Patch adds no route or navigation |

## Residual Risks

1. No golden/screenshot evidence for this screen; fidelity is verified by
   design-source-to-code reading plus property-level widget tests, and geometry
   assertions run against the Flutter test font rather than the shipped
   typeface. Real-font line counts — which is what decides whether N4's
   constraint binds on a real device — are not measurable in this setup.
2. Only dark theme + `vi` verified, per the story's Out of Scope (OQ5).
3. N1 remains unowned at requirement level.
4. N4 and N5 are accepted here but are not yet written into the story's
   visual-fidelity report.

## Verdict

P1, the only finding that gated round 1, is resolved and independently
verified. P2 is resolved and measured. P3 is materially improved and remains a
non-gating follow-up. N4 and N5 are new but non-gating: N4 is a consequence the
governing UX spec requires, and N5 is announcement verbosity. No regression —
57/57 tests pass, analyze clean.

Approved as DEFERRED_ONLY with N1, N2, N3, P3-remainder, N4 and N5 carried as
accepted deferrals. N4's documentation correction is a named required action
for the REQ-002 integration review, not a blocker on this story.

REVIEW_COMPLETE: DEFERRED_ONLY
