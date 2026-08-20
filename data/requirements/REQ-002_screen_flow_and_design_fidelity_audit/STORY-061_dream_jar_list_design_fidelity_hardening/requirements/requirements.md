# Requirements: STORY-061 Dream Jar List (`jarlist`) Design Fidelity Hardening

## Reconciliation note

`story_master.md`'s DEF-2 list groups the source deviations into 8 items.
Re-deriving from `STORY-059_cupid_header_action_slot_sizing_hardening/
visual-fidelity/visual-fidelity-report.md`'s 11-row "Out-of-scope deviations
observed" table:

| Report row(s) | story_master.md DEF-2 item | AC |
|---|---|---|
| 1 (title copy) | 6. title copy deviation | AC6 |
| 2 (back chevron) | — (DEF-3, disposed separately) | AC10 |
| 3 (summary pill) | 1. missing summary pill | AC1 |
| 4 (jar illustration thumbnail) + 5 (per-jar leading glyph) | 2. missing jar illustrations | AC2 |
| 6 (deadline date) | 3. missing deadline row | AC3 |
| 7 ("Đang xem" badge) | 4. missing "Đang xem" badge | AC4 |
| 8 (progress amount/percent format+layout) | **not itemized in story_master.md** | out of scope — see below |
| 9 (CTA copy + glyph, English noun in `vi`) | 7. CTA copy deviation | AC7 |
| 10 (completed-jars row) | 5. missing completed-jars row | AC5 |
| 11 (shell tab-bar shape) | 8. shell tab-bar shape deviation | AC8 |

Row 8 of the visual-fidelity report ("3.900.000₫ / 5.000.000₫", percent on its
own row vs. the implemented "3.900.000₫ trên 5.000.000₫ · 78%" — format and
layout differ) is visible in the report but is **not** one of the 8 items
`story_master.md` itemizes for this story, and `story_master.md` is explicit
that "Do not fold in any deviation not itemized above without a new Product
Owner-owned scope decision recorded in this file." No such scope decision is
recorded here, so row 8 is left out of this story's acceptance criteria. It
remains an open, unowned deviation for a future scoping pass alongside any
other REQ-002-class finding.

All other 8 story_master.md items map onto the report 1:1 or 2:1 as shown
above and are covered by AC1-AC8 below, using the report's exact wording for
each deviation's design-vs-implemented text.

## Acceptance Criteria

**AC1 — Summary pill.** The Dream Jar list header area renders a summary pill
matching the `jarlist` design reference: total saved amount and jar count in
the design's format (e.g. "Tổng cả nhà đang để dành 7.150.000₫ trong 3 cái
hũ"), sourced from the existing jar data already available to the screen.
Currently absent — whole element unimplemented.

**AC2 — Jar illustrations.** Each jar card renders a jar illustration
thumbnail and a per-jar leading glyph next to the jar name, matching the
`jarlist` design reference. Both are currently absent.

**AC3 — Deadline row.** Each jar card renders a deadline date row (e.g.
"30/09/2026"), matching the `jarlist` design reference. Data already exists
in the jar model; only the rendering is missing.

**AC4 — "Đang xem" badge.** The active/currently-viewed jar card renders an
"Đang xem" badge with the design's pink border/tint treatment on that card,
matching the `jarlist` design reference. Currently absent.

**AC5 — Completed-jars row.** The Dream Jar list renders a "Hũ đã hoàn thành"
(completed jars) row/section, matching the `jarlist` design reference.
Currently absent — whole element unimplemented.

**AC6 — Title copy.** The screen title reads exactly "Các hũ ước mơ",
replacing the current "Hũ Ước Mơ", matching the `jarlist` design reference.

**AC7 — CTA copy.** The create-jar CTA reads exactly "+ Tạo hũ mới" with its
leading plus glyph, replacing the current "Tạo Dream Jar mới" (which contains
an English noun, "Dream Jar", in a `vi`-locale build), matching the `jarlist`
design reference.

**AC8 — Shell tab-bar shape.** The bottom tab bar matches the design's 5-tab
shape (Nhà / Trò chuyện / Pet / Ví chung / Tôi) with "Ví chung" active,
replacing the current 3-tab-plus-separate-account-FAB shape, matching the
`jarlist` design reference. This is shell-level and shared with the
deviation already recorded in STORY-055's report; Tech Lead confirms in
solutioning whether the change lands in the shared `AppShell` tab-bar
component or is otherwise scoped so it does not regress other shell tabs.

**AC9 — Design-reference conformance (required verification method for
AC1-AC8).** Verification of AC1-AC8 must be performed against the literal
`jarlist` design reference screen, not by restating capability criteria.
Concretely: `jarlist` is resolved via
`node .ai-team-bundle/runtime/tools/render-design-canvas.js
--list-screens` against the configured design entry, and the resulting
render is visually confirmed to depict the Dream Jar list (jar collection,
create-jar CTA, "Ví chung" tab) rather than accepted on id match alone — the
same discipline `visual-fidelity-report.md` already applied for this screen.
Mobile Developer captures a fresh `implemented-jarlist-*` /
`design-reference-jarlist-*` evidence pair covering the states relevant to
AC1-AC8, and Reviewer verifies AC-by-AC against those images. An AC1-AC8
verdict without this evidence pair does not satisfy this story.

**AC10 — DEF-3 disposition (documentation-only, no code change).** Record in
this story's artifacts the verified, accurate pre-AC8/post-AC8 sequencing for
the missing back chevron — not the story's original single-state premise,
which Tech Lead architecture (`architecture/solution.md` §3, Key Discovery
item 2) found false against current code:

- Today, `jarlist` is *not* a shell-tab-root screen. It is pushed via
  `MaterialPageRoute` from `HomeScreen`'s `DreamJarEntryCard`. The absent
  back chevron today is because `dream_jar_list_screen.dart` constructs
  `CupidHeader` with no `onBack` supplied at all, not because there is
  nothing to pop.
- Only once AC8 lands (P2) does `jarlist` become the "Ví chung" shell-tab
  body. At that point — and not before — the "shell-tab-root, nothing to
  pop" disposition becomes true, analogous to RWB-20260816-024's Chrome
  Rules precedent for shell-tab-root screens.
- Record both the pre-AC8 and post-AC8 states in story artifacts so this
  disposition is never asserted as true before AC8/P2 has actually landed.
  No implementation change follows from this AC in either state.
