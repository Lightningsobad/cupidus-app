# STORY-059: CupidHeader Action-Slot FAB Sizing Hardening

Status: DONE
Retro-Type: RED-PATCH
Fixes: STORY-028_shared_expenses_design_fidelity
Complexity: standard
Story-Class: standard
Implementation Lane: shared (ui-ux-designer sizing/treatment decision
[REVISED 2026-08-19, see below], then tech-lead component-contract decision,
then mobile-dev implementation touching BOTH
`mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart`
(screen-level call-site fix) and `cupid_header.dart` (design-system defensive
hardening) — no backend surface is involved)
Requirement: REQ-002
Scope: Retro-hardening (RWB-20260816-027)

## Gap (from rework-backlog.md RWB-20260816-027, do not re-derive)

STORY-055 grew `CupidAddAction`'s Material FAB from the default 56x56 to a
design-mandated 60x60 (AC1). At `dream_jar_list_screen.dart:75`, the same
component is placed inside `CupidHeader.actions`; `CupidHeader`'s Material
branch (`_MaterialHeader`) hands `actions` into a Material `AppBar` whose
toolbar band is a fixed `kToolbarHeight` (56), clamping the 60pt box to 56 —
the shipped FAB measures 60x56 at that call site, still carrying
`BorderRadius.circular(20)` (a radius chosen for a square). Mechanism and
measurement are pinned by an existing widget test in
`mobile/test/design_system/adaptive_widgets_test.dart` ("Material FAB is
clamped to 60x56 inside CupidHeader.actions", asserts `Size(60, 56)` and
`size.height == kToolbarHeight`). Every available fix touches
`cupid_header.dart` (raise the Material toolbar band, or let the action slot
pass loose constraints), which was out of STORY-055's write scope and is a
shared component consumed by many screens beyond that story.

Full detail, including the reviewer's original finding (F-2) and the
`gallery_empty_view.dart:78` unaffected-case analysis: see
`data/retro-audit/rework-backlog.md` `## RWB-20260816-027`.

## Remediation Needed (do not expand scope beyond this)

UI/UX Designer + Tech Lead decide the correct sizing/treatment for
`CupidAddAction` when placed inside `CupidHeader.actions` on the Material
silhouette: either raise `CupidHeader`'s Material toolbar band to
accommodate the full 60x60 FAB, or define a header-appropriate smaller
variant. Route the `cupid_header.dart` (and/or `cupid_add_action.dart`)
change to the mobile/design-system lane. The pinned widget test in
`adaptive_widgets_test.dart` must flip from asserting the 60x56 deviation to
asserting the newly agreed correct size once fixed. This hardening story
must carry an acceptance criterion asserting conformance to the design
reference for the affected screen ids (Dream Jar list, and any other
`CupidHeader.actions` call site the chosen fix touches) — restating
STORY-028/STORY-055's original capability criteria without a design
conformance AC reproduces the gap that caused this rework.

## Revised Gap / Remediation (UX finding, 2026-08-19 — supersedes "resize" framing above)

`ui-ux-designer` (`Pink-Designer-6`) opened the actual literal design source
(`cupid-app-design-system/project/Cupid Screens.dc.html`, previously
misidentified as absent from the repo — it exists under a different
top-level directory name than assumed) and found the diagnosis above was
solving the wrong problem:

- The shared header template (`showHeader`, design-source lines 49-64, used
  by every screen with chrome including `jarlist`) renders only an optional
  back chevron, the title, and an optional partner-presence chip. **No
  icon-action slot exists in the header at all** — not a smaller one, none.
- The `isJarList` canvas block (lines 889-930) shows the "create jar"
  affordance as a full-width 54px pill CTA in the scrollable body, after the
  jar cards (line 923) — not a header icon, not a FAB.
- `dream_jar_list_screen.dart` already implements this exact literal body
  CTA correctly and independently in both states that also render the
  header's `CupidAddAction`: `_JarListBody` (lines 228-234, pinned list-end
  `CupidPrimaryButton`) and `_EmptyJarsView` (lines 197-200, centered
  `CupidPrimaryButton`), both wired to the same `_openCreateSheet`. Verified
  directly by Scrum Master (Read), matches Pink-Designer-6's citations
  exactly.

**Corrected remediation — now two coordinated parts, both in this story's
write scope:**

1. **Primary (screen-level call-site fix, design-conformant, root-causes the
   clamp):** remove `CupidAddAction` from `CupidHeader.actions` at
   `dream_jar_list_screen.dart:70-81` (both switch arms — `DreamJarListEmpty`
   and `DreamJarListReady`), leaving `actions: const <Widget>[]`. This is the
   same call site the original Gap section already named in-scope; only the
   remedy changed (removal, not resize/redefine). The existing body CTAs are
   left untouched — they already match the design.
2. **Secondary (design-system defensive hardening, still needed
   regardless):** `CupidHeader`'s Material toolbar band should still be
   hardened to 60pt, conditional on `actions` requiring it, because AC2's
   pinned widget test constructs `CupidHeader(actions: [CupidAddAction(...)])`
   directly (independent of the real screen) and must assert a correct,
   non-clamped `Size` for that generic composition. Full spec:
   `ux/uiux-spec.md` "Secondary, complementary fix" section.

**AC1 needs a Product Owner pass**: as originally written it presupposes
`CupidAddAction` keeps rendering inside `CupidHeader.actions` on Dream Jar
List post-fix and just needs a corrected size. That premise no longer holds —
routing back to Product Owner for an AC1 rewrite (and any Scope wording
touch-up) before Tech Lead. AC2 (regression pin), AC3 (confirmed-unaffected
cases), AC4 (no unrelated CupidHeader regression) are unaffected by this
revision and stay as Product Owner already wrote them.

Full citations, line numbers, and the exact secondary-fix spec:
`ux/uiux-spec.md` (do not re-derive — already independently re-verified by
Scrum Master against the literal design source and the current
implementation).

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer)
- [x] Architecture (Tech Lead)
- [x] Implementation (Development)
- [x] Review (Reviewer) — `review/review-report.md` Outcome: DEFERRED_ONLY
  (re-verification pass, 2026-08-20; original pass PATCH_REQUIRED on BLK-1,
  closed by devops story-runtime-smoke evidence)
