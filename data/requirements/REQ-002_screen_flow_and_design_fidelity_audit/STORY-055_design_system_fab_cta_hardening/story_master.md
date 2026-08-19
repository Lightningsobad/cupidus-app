# Story Master: STORY-055 Hardening - Design System FAB/CTA Shape and Sizing Fidelity

Status: PENDING
Complexity: trivial
Story-Class: standard
Implementation Lane: mobile
Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: STORY-028_shared_expenses_design_fidelity
Scope: Retro-hardening (RWB-20260816-021)
Screens: Expense History (`expense_history_screen.dart`) is the rendered-evidence
anchor for both D-1 (`CupidAddAction`, Material FAB) and D-2 (`CupidPrimaryButton`,
iOS full-width "add" CTA) — it is the only screen carrying both components in
the exact configuration STORY-043 already rendered
(`design-reference-expense-android.png`, `design-reference-expense-ios.png`,
Design-Screen: `expense`, already resolved and confirmed by that story; not
re-resolved here). The same two shared components are also consumed,
unmodified in this story beyond the widget-level fix, by Dream Jar List and
Gallery Empty View (`CupidAddAction`) and 19 further screens/sheets
(`CupidPrimaryButton`) — full call-site list in `requirements/requirements.md`
`## In Scope` item 3, verified directly by source grep, not by re-deriving the
registry's "Dream Jar, Gallery, and Home" paraphrase (Home is not a real
`CupidAddAction` consumer; grep-confirmed, see `## Background` note below).
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`). No new design-source render required — this story
reuses STORY-043's existing reference pair as-is.
Write scope: `mobile/lib/design_system/adaptive/cupid_add_action.dart` and
`mobile/lib/design_system/adaptive/cupid_primary_button.dart` only. No consumer
screen/sheet file is write scope — see `## Background`, M-1 disposition, for
why the one candidate exception (a screen-level scroll padding fix) is
explicitly excluded rather than silently absorbed into this anchor.

## Artifacts
- [x] Requirements (Product Owner) — `requirements/requirements.md`
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development) — `visual-fidelity/visual-fidelity-report.md`
- [ ] Review (Reviewer)

## Background (Rework Item)

`data/retro-audit/rework-backlog.md` item RWB-20260816-021 (source: round-2
rendered evidence from `STORY-043_shared_expenses_design_fidelity_hardening`,
Reviewer Iris-QC-8, finding D-c). Split from that review because the affected
widgets — `CupidAddAction` (Material FAB) and `CupidPrimaryButton` (iOS
full-width CTA) — live in shared `mobile/lib/design_system/adaptive/**`
components, same exclusion class as RWB-20260816-012/STORY-045.

**Verified call-site correction to the registry's own background paragraph:**
the registry text (and STORY-043's finding) describe the shared components as
consumed by "Dream Jar, Gallery, and Home." Direct `grep` against
`mobile/lib` (this story, 2026-08-19) confirms `CupidAddAction` has exactly 3
real call sites — `expense_history_screen.dart`, `dream_jar_list_screen.dart`,
`gallery_empty_view.dart` — and none in any `home_screen.dart`. This does not
change scope (the anchor is still the shared component file, not a specific
consumer count); it is recorded so the no-regression AC's call-site list is
exact, not paraphrased.

### D-1 (`CupidAddAction`, Material FAB) — corrected scope, wider than the
registry's one-line summary

The registry's remediation line reads: "the shipped `CupidAddAction` already
has the right size, gradient, and glow, but its `radiusButton` token resolves
to a full circle/pill." **This is not what the code or the primary source
review shows.** Direct read of
`mobile/lib/design_system/adaptive/cupid_add_action.dart` (current `main`,
lines 42-50) shows the Material branch uses `backgroundColor:
colors.colorAccentPink` (a **flat** fill, not `colors.gradientHot`), carries
**no** `boxShadow`/glow at all, uses the Material default `FloatingActionButton`
size (56x56, no explicit override — not a confirmed 60x60), and renders
`Icon(CupidIcons.add)` at the default icon size (not the design's 27px). This
matches, word for word, `STORY-043_shared_expenses_design_fidelity_hardening/visual-fidelity/visual-fidelity-report.md`
lines 194-205 (the actual origin document): "Rendered: a flat `colorAccentPink`
**circle** at the Material FAB default size, **no gradient, no glow**, smaller
glyph." The registry's "already has the right size, gradient, and glow"
framing is stale relative to both the code and its own cited source document.

**Corrected D-1 target (design source, per the same review-report lines
194-196):** `60x60` size, `border-radius:20px` (rounded square, not
pill/circle), `--grad-hot` gradient background (not flat `colorAccentPink`),
glow shadow matching the same treatment `CupidPrimaryButton` already applies
via `colors.glowShadow` (not the current no-shadow render), `27px` glyph (not
the current default icon size). See `requirements/requirements.md` AC1 for
the precise, testable form of this correction.

### D-2 (`CupidPrimaryButton`, iOS full-width CTA) — accurate as given, verified

Direct read of `mobile/lib/design_system/adaptive/cupid_primary_button.dart`
confirms the registry's D-2 framing is accurate: `gradientHot`, `glowShadow`,
pill radius (iOS branch), and `w800` weight are already correctly applied.
`_primaryCtaHeight = 54` (line 20) and the inline `fontSize: 16.5` (line 74)
apply identically on both platforms — the widget has no platform branch on
height or font size, only on corner radius. No leading-icon parameter exists
today. Target, per `STORY-043.../visual-fidelity/visual-fidelity-report.md`
line 211-212: height `52` (not `54`), font size `15.5` (not `16.5`), a leading
`add` glyph with an `8px` gap before the label — **verified against that
screen's canvas block only** (the Expense History "add action" CTA at
`expense_history_screen.dart:225-228`, label `ExpenseStrings.addActionLabel`).
No other screen's `CupidPrimaryButton` canvas block has been checked for a
leading-icon spec, so the glyph addition is scoped to that single call site,
not to every "add"-semantic `CupidPrimaryButton` in the app (e.g. Dream Jar
List's "New Dream Jar" buttons at `dream_jar_list_screen.dart:146,197,231` are
visually similar but unverified against their own design-source block — adding
an icon there would be scope invention, not a confirmed fix). Height/font-size
correction, being a shared non-platform-branched widget property, is a
component-level fix and therefore intentionally affects every consumer on both
platforms uniformly.

### M-1 (FAB overlap) — confirm/document only, per the handoff's own Non-Goal;
do not attempt a code fix here

`STORY-043.../visual-fidelity/visual-fidelity-report.md` lines 217-230 give the
root cause directly: the design keeps its add-action **inside the scrolling
content flow** (`position:sticky`, `margin-top:16px`, `padding-bottom:40px`),
while the implementation uses `Scaffold.floatingActionButton` — a pure
**overlay** — with the scroll view's bottom padding still fixed at the
design's in-flow value (40px, i.e. no extra reserve for the overlay). The
report's own verdict: "Per AC4 this is not remediated here; it routes with
D-1, upgraded from reasoned to observed." **This root cause is a screen-level
scroll-padding property on `expense_history_screen.dart`, not a property of
`CupidAddAction` itself** — it sits outside this story's
`design_system/adaptive/**` write scope. Growing the FAB from 56x56 to 60x60
per D-1 does not close this gap and, absent a bottom-padding increase, would
plausibly clip slightly more content, not less — so an AC asserting M-1
"clears" once D-1 lands (as the registry's remediation line suggests) would be
unverifiable and likely false. This matches the handoff's own Non-Goals
instruction ("do not touch the M-1 FAB-overlap finding beyond
confirming/documenting it's Material-only-already-known") — this story
re-confirms and documents M-1's unchanged, Material-only, out-of-anchor status
(AC4) and does not touch `expense_history_screen.dart` or any other screen
file to fix it. A future item against the Expense History screen's own
scroll-padding value, not this shared-component story, would be the correct
place to fix M-1 if the team wants it closed.

Exact remediation steps and verbatim finding text: see `rework-backlog.md`
`## RWB-20260816-021` and
`STORY-043_shared_expenses_design_fidelity_hardening/review/review-report.md`
finding D-c (source of this split; not re-derived beyond the corrections
recorded above, which are independently verified against the code and against
that story's own `visual-fidelity-report.md`, not merely re-stated from the
registry).
