# STORY-059 Requirements: CupidHeader Action-Slot FAB Sizing Hardening

Retro-Type: RED-PATCH — Fixes STORY-028_shared_expenses_design_fidelity
Source: `data/retro-audit/rework-backlog.md` `## RWB-20260816-027`

## Complexity / Lane Confirmation

- Complexity: standard — confirmed. The fix is bounded to one shared
  component (`cupid_header.dart`) and its consumer(s), with a pinned
  regression test already in place, but it requires a cross-role sizing/
  treatment decision (UI/UX Designer) followed by a component-contract
  decision (Tech Lead) before implementation — not a trivial single-file
  edit.
- Implementation Lane: shared — confirmed. `CupidHeader` is a shared
  design-system component; no story-specific screen file alone resolves
  this gap.

## Scope

In scope — exactly the gap recorded in `story_master.md`'s `## Gap` and
`## Revised Gap / Remediation (UX finding, 2026-08-19)` sections:

- `CupidAddAction` (60x60 Material FAB, per STORY-055 AC1) is
  height-clamped to 60x56 when placed inside `CupidHeader.actions` on the
  Material silhouette, because `CupidHeader`'s `_MaterialHeader` branch
  hands `actions` into a Material `AppBar` whose toolbar band is a fixed
  `kToolbarHeight` (56).
- Confirmed call site where `CupidAddAction` currently sits inside
  `CupidHeader.actions` and is therefore subject to this clamp:
  - `mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart:75`
    (screen id: Dream Jar list)
- **Primary in-scope fix (design-conformant, root-causes the clamp):**
  remove `CupidAddAction` from `CupidHeader.actions` at
  `mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart:70-81`
  (both switch arms — `DreamJarListEmpty` and `DreamJarListReady`), per the
  literal design source's shared header template (`showHeader`), which has
  no icon-action slot at all. The existing `CupidPrimaryButton` create-jar
  CTAs already implemented in `_EmptyJarsView` (lines 197-200) and
  `_JarListBody` (lines 228-234) are the design-conformant entry point and
  stay untouched.
- **Secondary in-scope fix (design-system defensive hardening):**
  `CupidHeader`'s Material toolbar band in `cupid_header.dart` is hardened
  to accommodate a 60pt action, conditional on `actions` requiring it, so
  the pinned widget test (AC2) — which constructs `CupidHeader(actions:
  [CupidAddAction(...)])` directly and independently of the real screen —
  can assert a correct, non-clamped `Size` for that generic composition.
- Confirmed **unaffected** call sites (not inside `CupidHeader.actions`)
  that stay out of scope, per the story_master.md gap analysis:
  - `mobile/lib/features/gallery/presentation/widgets/gallery_empty_view.dart:78`
    — not inside a `CupidHeader` at all.
  - `mobile/lib/features/expenses/presentation/screens/expense_history_screen.dart:159`
    — the `CupidHeader(...)` on this screen carries no `actions:`
    parameter; `CupidAddAction` is wired to `Scaffold.floatingActionButton`
    instead, an unconstrained overlay outside the toolbar band. This
    matches the original RWB-20260816-027 finding, which already
    documented this call site as rendering correctly.
- The pinned regression test at
  `mobile/test/design_system/adaptive_widgets_test.dart` ("Material FAB is
  clamped to 60x56 inside CupidHeader.actions", line 619) must flip from
  asserting the 60x56 deviation to asserting the newly agreed correct size.

Out of scope:

- The actual sizing/treatment decision (raise `CupidHeader`'s Material
  toolbar band vs. define a header-appropriate smaller FAB variant) —
  UI/UX Designer + Tech Lead decision, not pre-decided here.
- Any `CupidHeader` change unrelated to the `CupidAddAction` action-slot
  clamp.
- Any new screen or capability beyond the single confirmed call site above.

## Acceptance Criteria

- **AC1 (design conformance — Dream Jar list):** `CupidAddAction` no
  longer renders inside `CupidHeader.actions` on the Dream Jar list screen,
  in either the empty or ready state; the existing `CupidPrimaryButton`
  create-jar CTAs in `_EmptyJarsView` (lines 197-200) and `_JarListBody`
  (lines 228-234) remain unmodified and are the sole create-jar entry
  point on this screen; the header renders only the back chevron and
  title, matching the design source's literal `showHeader` template (which
  has no icon-action slot).
- **AC2 (regression pin flips, does not just get deleted):** The pinned
  widget test in `mobile/test/design_system/adaptive_widgets_test.dart`
  ("Material FAB is clamped to 60x56 inside CupidHeader.actions") is
  updated to assert the newly agreed correct rendered size for
  `CupidAddAction` inside `CupidHeader.actions`, replacing the 60x56
  deviation assertion. The test must keep asserting an explicit `Size`,
  not merely assert absence of clamping.
- **AC3 (no new unaffected-case regression):** `CupidAddAction` usage
  outside `CupidHeader.actions` continues to render at the full 60x60
  size after the fix — the `CupidHeader`-scoped change must not alter
  `CupidAddAction`'s own intrinsic size contract. Confirmed unaffected
  cases that must stay unaffected:
  - `mobile/lib/features/gallery/presentation/widgets/gallery_empty_view.dart:78`
    (not inside a `CupidHeader`)
  - `mobile/lib/features/expenses/presentation/screens/expense_history_screen.dart:159`
    (wired to `Scaffold.floatingActionButton`, not `CupidHeader.actions`)
- **AC4 (no unrelated CupidHeader regression):** Other consumers of
  `CupidHeader.actions` that do not place a `CupidAddAction` (or any other
  action whose intrinsic size exceeds `kToolbarHeight`) render unchanged
  after the fix — the remediation must not alter toolbar band behavior for
  action content that already fit within 56pt.

## Open Question Impact

- **OQ Registry Reviewed:**
  `data/intake/bootstrap/conflicts_open_questions.md` — full "Open
  Questions (unresolved, blocking-relevant scope only)", "Assumptions
  Currently Carrying The Flow", and "Decisions Still Needed From The User"
  sections.
- **Impact on STORY-059:** None relevant. The one unresolved OQ (OQ5 —
  light theme & EN locale enablement scope) concerns theme/locale coverage,
  not component sizing, and does not affect this story. The registry's
  standing assumption that `cupid-mobile-design/` is authoritative and
  read-only, and that deviations require a UX decision rather than a
  silent implementation choice, is why this story routes the sizing/
  treatment decision to UI/UX Designer + Tech Lead instead of deciding it
  at the requirements level — consistent with the `## Remediation Needed`
  constraint already recorded in `story_master.md`.
