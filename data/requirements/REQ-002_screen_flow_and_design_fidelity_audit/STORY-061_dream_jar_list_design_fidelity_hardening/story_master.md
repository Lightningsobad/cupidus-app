# STORY-061: Dream Jar List (`jarlist`) Design Fidelity Hardening

Status: DONE
Retro-Type: RED-PATCH
Fixes: STORY-028_shared_expenses_design_fidelity
Complexity: standard
Story-Class: standard
Implementation Lane: shared (product-owner scope/AC triage, then
ui-ux-designer design-fidelity spec, then tech-lead solution/coding-plan,
then mobile-dev implementation against
`mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart`
and any Dream Jar list sub-widgets the design reference requires)
Requirement: REQ-002
Scope: Retro-hardening (RWB-20260816-029)

## Gap (from rework-backlog.md RWB-20260816-029, do not re-derive)

Surfaced by `STORY-059_cupid_header_action_slot_sizing_hardening`'s reviewer
(`review/review-report.md`, DEF-2/DEF-3) while verifying AC1/AC4 against the
on-device visual-fidelity captures for the Dream Jar list screen (`jarlist`).
STORY-059's diff (one opt-in bool plus one `actions` removal) cannot have
caused any of the findings below, and no open story owns `jarlist`'s design
fidelity — it does not exist as its own story; `STORY-028_shared_expenses_
design_fidelity` is only the nearest tracking anchor.

**DEF-2 — 11 pre-existing `jarlist` design deviations**, itemized in
STORY-059's `visual-fidelity/visual-fidelity-report.md`:
1. missing summary pill
2. missing jar illustrations
3. missing deadline row
4. missing "Đang xem" badge
5. missing completed-jars row
6. title copy deviation
7. CTA copy deviation, including an English noun in a `vi` build
8. shell tab-bar shape deviation

(STORY-059's report groups some of these; Product Owner must re-derive the
exact enumerated list from `STORY-059_cupid_header_action_slot_sizing_hardening/
visual-fidelity/visual-fidelity-report.md` and `review/review-report.md`
DEF-2 before writing acceptance criteria — do not renumber or reword findings
without checking that source.)

**DEF-3 — no back chevron on the implemented header** where the design
shows one. Pre-existing and explained, not a defect: the screen is a shell
tab root at runtime, not a pushed route, so `CupidHeader` correctly has
nothing to pop.

Classification (from rework-backlog.md): not blocking, not introduced by
STORY-059, not a regression. Full detail:
`data/retro-audit/rework-backlog.md` `## RWB-20260816-029`.

## Remediation Needed (do not expand scope beyond this)

1. Product Owner scopes this hardening story from the DEF-2 list above (and
   STORY-059's underlying visual-fidelity report) into concrete, individually
   verifiable acceptance criteria — one AC per deviation family is acceptable
   if that keeps each AC independently testable. At least one AC must assert
   conformance to the `jarlist` design reference screen id, per the RED-PATCH
   rule that restating capability criteria alone reproduces the gap that
   caused this rework.
2. Product Owner also disposes DEF-3 as a documentation-only acceptance
   criterion: no code change, record that `jarlist` is a shell-tab-root
   screen (nothing to pop) as the accepted disposition, analogous to
   RWB-20260816-024's Chrome Rules precedent for shell-tab-root screens.
3. UI/UX Designer produces (or confirms/updates) the design-fidelity spec for
   `jarlist` covering the DEF-2 elements against the literal design source.
4. Tech Lead scopes the implementation (coding plan required — this is a
   `standard` story) and confirms which Dream Jar list widgets/files are in
   write scope.
5. Mobile Developer implements against the confirmed write scope and
   captures a fresh `implemented-jarlist-*` / `design-reference-jarlist-*`
   evidence pair.
6. Reviewer verifies AC-by-AC, including the design-conformance AC, before
   this story can be marked `DONE`.

Do not fold in any deviation not itemized above without a new Product
Owner-owned scope decision recorded in this file.

## Product Owner Scope Decisions (2026-08-20)

Recorded after Tech Lead architecture (`architecture/solution.md`) surfaced
two findings that change scope/wording. Both approved as proposed.

**Decision 1 — Gallery entry-point relocation (scope extension, APPROVED).**
The design's mandated 5-tab shell shape for AC8 (Nhà / Trò chuyện / Pet / Ví
chung / Tôi) has no Gallery slot, and `app_shell.dart` is `GalleryScreen`'s
only production entry point today. Deleting the current 3-tab-plus-FAB shape
to ship AC8 literally would orphan the shipped epic-4 Gallery feature with no
route left to it. Approved: Tech Lead/Mobile Developer add a Gallery entry
card to `HomeScreen`'s existing entry-card stack, in the same pattern as the
existing `DreamJarEntryCard`, landed in the same phase (P2) that removes the
Gallery tab. This is a small, itemized scope extension over the original
DEF-2 list, justified because a design-fidelity story must not ship a design
match that silently removes a shipped feature's only entry point. Rejected
alternative: keeping Gallery as a 6th tab — that fails AC8 outright, since
the design bar has exactly 5 destinations.

**Decision 2 — AC10 wording correction (APPROVED).**
AC10 as originally drafted asserted `jarlist` "is a shell-tab-root screen at
runtime... so CupidHeader correctly has nothing to pop." Tech Lead
architecture verified this premise is false against current code: `jarlist`
is pushed today via `MaterialPageRoute` from `HomeScreen`'s
`DreamJarEntryCard`, not shell-tab-rooted, and the header simply has no
`onBack` supplied at all. `requirements/requirements.md`'s AC10 is corrected
to state this accurate pre-AC8 / post-AC8 sequencing instead of the original
single-state premise, matching the disposition Tech Lead recorded in
`architecture/solution.md` §3.

**Amendment (2026-08-20, Reviewer finding B4a).** Post-P2, `jarlist` has two
concurrently reachable framings, not one: (1) the `Ví chung` shell-tab body,
where there is genuinely nothing to pop and the absent chevron is correct;
and (2) the pre-existing `MaterialPageRoute` push from `HomeScreen`'s
`DreamJarEntryCard` (`home_screen.dart:180-189`), which this story does not
remove and which still constructs `CupidHeader` with no `onBack` —
DEF-3's original condition, intact in that framing.
`coding-plan/test-results.md`'s `### AC10 disposition` section is corrected
to record both framings, not just the shell-tab framing, so the disposition
is not misread as fully resolved. Whether `DreamJarEntryCard` is removed or
kept with `onBack` added is a separate, still-open decision (Reviewer
finding B4b, routed to Tech Lead) that this AC10 text does not presuppose.

## Artifacts
- [x] Requirements (Product Owner) — `requirements/requirements.md`, AC1-AC10
  (AC1-AC8 per-deviation, AC9 design-conformance verification method, AC10
  DEF-3 documentation-only disposition). Reconciliation note: report row 8
  (progress amount/percent format+layout) is not itemized in this story's
  DEF-2 list and is left out of scope — no PO-owned scope decision extends
  it here.
- [x] UX Design (UI/UX Designer) — `ux/uiux-spec.md`. AC8 confirmed
  shell-level/shared (touches `app_shell.dart`, affects every AppShell
  screen); AC1/AC5 need a `DreamJarListCubit` active/completed list split;
  AC4 spec'd as a positional rule pending Tech Lead confirmation.
- [x] Architecture (Tech Lead) — `architecture/solution.md` plus
  `coding-plan/` (master-plan, P1, P2, coding-agent-guide). AC8 confirmed
  buildable (`PetScreen`/`MeScreen` already exist). Three findings change
  scope: AC8 also needs the preview shell mirror or AC9 cannot evidence it;
  AC10's stated runtime fact is wrong and is corrected in `solution.md` §3;
  AC8 displaces the Gallery tab, which is `GalleryScreen`'s only production
  entry point, so P2 adds a `HomeScreen` Gallery entry card.
- [x] Implementation (Development) — code is correct (P1+P2 both
  `MOBILE_COMPLETE: YES`, all gates green). Round 1 rework closed: B1
  `visual-fidelity/visual-fidelity-report.md` (`VISUAL_FIDELITY:
  PASS`, `Design-Screen: jarlist`), B2 `## Entry Point
  Reachability` in `test-results.md`, B3 `## Story Runtime Startup Smoke` in
  `test-results.md` (Frank-Devops), B4a AC10 amendment (Andy-PO-2), B4b
  Decision B4b "no change, tracked" (Alan-Techlead-2, `architecture/
  solution.md` §3). See `coding-plan/test-results.md`.
- [x] Review (Reviewer) — Round 1 `PATCH_REQUIRED` (B1-B4, all closed);
  Round 2 `PATCH_REQUIRED` (B5-B6, both closed); Round 3 `Outcome:
  DEFERRED_ONLY` (`review/review-report.md`, 2026-08-20) — 0 blocking
  findings, AC1-AC10 all PASS, story approvable. 5 deferred findings D1-D5
  carried forward unresolved as candidate follow-ups/repo-hygiene (D5 is
  Scrum-Master-owned, not this story); none gates DONE.
