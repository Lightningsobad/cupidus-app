# Story Master: STORY-023 Design Fidelity — Zodiac Red Flag

Status: DEFERRED — screen has no shipped implementation to fix; building it
from scratch needs product/content decisions outside a design-fidelity
story's remit (see Deferral Decision below).
Complexity: N/A — deferred, not scheduled for delivery under this requirement
Story-Class: N/A — deferred
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit)
Screen: Zodiac Red Flag, Epic 3 (Daily engagement)
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner) — deferral decision recorded
- [x] UX Design (UI/UX Designer) — N/A: deferred before UX scope
- [x] Architecture (Tech Lead) — N/A: deferred before architecture scope
- [ ] Implementation (Development) — N/A: deferred
- [ ] Review (Reviewer) — N/A: deferred

## Deferral Decision

mobile-dev attempted implementation and returned blocker
`STORY_PREMISE_INVALID` (see this story's
`visual-fidelity/visual-fidelity-report.md`). That report confirmed the
premise of this story — a design-fidelity fix to an *existing* screen — is
false: the `zodiac` canvas has no shipped screen anywhere in the app. It is
registered in `mobile/lib/main_preview.dart`'s `_notImplementedCanvasIds`
(verified at BaseHead `e3fb5389`), there is no
`mobile/lib/features/zodiac/` directory, and the only zodiac code in the app
is a 26-line pure sign-lookup function
(`mobile/lib/features/account/domain/zodiac.dart`) with no UI, widget, or
route.

This session already hit the identical situation for STORY-009
(Permissions) and STORY-010 (Onboarding Profile) and resolved both by
promoting them to standard "build the screen" stories. That is **not** the
right call here, because the two situations differ on data semantics:

- STORY-009's permissions screen maps 1:1 onto real OS permission-grant
  state — no content had to be invented, only real system state wired to a
  new UI.
- STORY-023's Zodiac Red Flag canvas
  (`cupid-app-design-system/project/Cupid Screens.dc.html` lines 593-627) is
  entirely bespoke authored narrative content: a date-stamped "Red flag ·
  29/07" header, a headline specific to one sign ("Pisces is in a delicate
  phase"), a numeric "conflict index" (`7/10`) with no stated formula, and 3
  highly specific behavioural tips (video call before 9pm, avoid money/exes,
  milk tea peace treaty) for one specific fixture couple/sign-pair
  (Minh/Linh, Cancer × Pisces). The closing disclaimer ("This is for fun.
  Cupid takes no responsibility if you actually believe it") confirms this
  is meant as rotating/personalized editorial content, not a fixed screen.

Building this as a real feature — not just replaying the design's fixture
values as if they applied to every couple — requires answering: how a
"conflict index" is computed or authored per sign-pair (144 combinations),
where the daily tip copy comes from (static per-pair library vs. generated
content vs. an authored rotation), and whether the card personalizes to the
couple's real zodiac signs (computable via the existing `zodiacSignFor` in
`mobile/lib/features/account/domain/zodiac.dart`) or ships generic. None of
that is a mobile-lane design-fidelity decision, and none of it is answerable
inside this story's current trivial/standard mobile-only shape. Shipping the
design's literal fixture values (fixed date, fixed names, fixed sign pair)
as production content would misrepresent every real couple's actual
pairing — acceptable for a design mockup, not for a shipped feature.

**Decision: defer**, matching mobile-dev's own Option 2 recommendation and
REQ-002 Part B's remit (fidelity of screens that already ship, not
new-feature construction). This does not reduce Scope B's screen-inventory
coverage claim — it narrows it to screens where "fidelity fix" is a
coherent unit of work.

### Canonical list of still-genuinely-unimplemented canvases (this decision)
Per `mobile/lib/main_preview.dart`'s `_notImplementedCanvasIds` at BaseHead
`e3fb5389`: `otp`, `shareapprove`, `shareedit`, `shareok`, `sharepick`,
`themedetail`, `themes`, `vow`, `zodiac`. `permissions` is no longer on this
list — STORY-009 built it this session — do not cite it as unimplemented in
future stories.

### Recommendation for a future requirement
If Zodiac Red Flag is picked up later as a new-feature build (not a REQ-002
fidelity fix), that future Product Owner scoping pass must resolve the
content-source and personalization questions above before Tech Lead
architecture, and should reuse the token/spec extraction already captured in
this story's `visual-fidelity/visual-fidelity-report.md` (full token
mapping, layout spec, and `Zodiac Icon` `CustomPainter` spec) so that work is
not repeated.

## Original Story Scope (superseded by the Deferral Decision above — kept
for traceability only; do not implement against this section)

## Depends On
- NONE. Independent of every other Scope A/Scope B story; runs as part of
  the story-level-parallel wave for REQ-002 Scope B.

## User Story
As a paired user viewing our zodiac compatibility read, I want the screen to
match the locked design source exactly, so the custom zodiac iconography
renders correctly and on-brand.

## In Scope
1. Re-audit the current Zodiac Red Flag screen against
   `cupid-app-design-system` for the enabled dark theme + `vi` locale
   configuration: the custom-drawn 12-sign zodiac icon set (not Unicode
   glyphs, per §2), element color-coding (Fire = peach/orange, Earth =
   mint, Air = lilac, Water = pink), spacing, color/design-token usage, and
   typography.
2. Correct every deviation found directly in the app code so the rendered
   screen matches the design source exactly — this is a fix, not an audit
   report.

## Out of Scope
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Acceptance Criteria
1. Given the Zodiac Red Flag screen rendered in the enabled dark theme +
   `vi` locale, when compared against `cupid-app-design-system`'s
   corresponding screen, then layout, spacing, color/token usage, and
   typography match exactly with no visible deviation.
2. Given any deviation was found during this story's audit, when the story
   is delivered, then the deviation is corrected in the rendered app (not
   merely documented) and re-verified against the design source.
3. Given each zodiac sign's icon on this screen, when rendered, then it
   uses the custom-drawn `dc-import name="Zodiac Icon"` set exactly (never
   a Unicode glyph substitute), color-coded by element per the design
   source (Fire = peach/orange, Earth = mint, Air = lilac, Water = pink).
4. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current Zodiac Red Flag screen,
  already reachable in the shipped app.
- Direct URL only acceptable: N/A — existing reachable screen, not new.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed.

## Open Question Impact
OQ5 (light theme / `en` locale) is moot for this story: the story is
deferred before reaching implementation, so it never reaches OQ5's
out-of-scope theme/locale carve-out.

### Scope Items BLOCKED in this story
- All acceptance criteria (1-4) BLOCKED: no shipped screen exists to
  correct, and building one from scratch is a new-feature build outside a
  design-fidelity story's remit (see Deferral Decision above).

### Scope Items NOT BLOCKED in this story
- None.
