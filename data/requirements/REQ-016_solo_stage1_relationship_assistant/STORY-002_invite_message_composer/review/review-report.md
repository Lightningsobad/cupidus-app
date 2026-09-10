# Review Report: STORY-002 Xuất lời mời — khung nhại + mad-libs

- Review type: `final-synthesis` over 3 `scoped-slice` passes, round 2
- Reviewer: Iris-QC
- Date: 2026-09-10
- Scope gate: `review/scope-gate.md` (`## Phase 2 Approval` 3-slice plan)
- Slice records: `review/slice-A-review.md`, `review/slice-B-review.md`,
  `review/slice-C-review.md`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-002_invite_message_composer`
- Diff baseline: `711274e3fde25788c91390a44572d53766bba778` (merge-base with the
  integration branch), the same baseline all three slices used
- Blocking findings: 0
- Deferred findings: 16 (11 from the slices, 4 carried from round 1, 1 new here)

This record supersedes round 1's `PATCH_REQUIRED` and is the canonical story
review report.

## 1. Per-Slice Verdicts

| Slice | Coverage | AC checks | Blocking | Deferred | Slice verdict token |
|---|---|---|---|---|---|
| A — render engine + content pack (P1/P2) | 10 files | 10/10 PASS | 0 | 4 | `PARTIAL_SLICE_ONLY` (slice-level: deferred only) |
| B — schema v5 + payload store (P3/P4) | 10 files | 5/5 PASS | 0 | 2 | `DEFERRED_ONLY` |
| C — composer sheet + entry surface (P5/P6) | 12 files | 8/8 PASS | 0 | 5 | `PARTIAL_SLICE_ONLY` (slice-level: deferred only) |

Combined: **23/23 sliced AC checks PASS, 0 blocking findings in any slice.**
Slices A and C carry the `PARTIAL_SLICE_ONLY` token because the scoped-slice
stop gate requires it; both state a slice-level deferred-only verdict in their
own body. No slice recorded a verdict that conflicts with its evidence.

## 2. AC Coverage — No Gap

The three slices reproduce the `scope-gate.md ## Phase 2 Approval` plan exactly,
AC for AC, with no slice dropping or silently widening its assigned list:

- Story AC-1..AC-7: all 7 covered (AC-2/AC-3 in A, AC-5 in B, AC-1/AC-4/AC-6/AC-7 in C).
- Requirement AC-1, AC-3, AC-4, AC-5, AC-9, AC-16..AC-19, AC-23, AC-25..AC-29:
  all 15 covered. AC-16 is covered twice (data layer in B, UI layer in C), which
  is deliberate, not double-counting a gap.

23 slice rows = 22 unique checks + the intentional AC-16 overlap. One requirement
AC in the story's scope was **not** on any slice list — see D-S1, resolved here.

## 3. Round-1 Blocking Findings — All Five Closed

Round 1 returned 5 blocking findings. All five are closed, each verified in this
pass rather than accepted on report:

- **F-1 — `## Entry Point Reachability` absent. CLOSED.**
  `coding-plan/test-results.md:791` now carries the section with
  `Reachable: YES` and a 6-link chain (login → "Muốn làm" tab → hub → card →
  single primary CTA → "Chuẩn bị" sheet → "Xuất lời mời" → composer), each link
  naming a code pin and a holding test. It also records honestly that link 5 may
  be legitimately absent when the pack does not resolve (AC-27) — the one
  intentional break in the chain.
- **F-2 — `## Story Runtime Startup Smoke` absent. CLOSED.**
  `test-results.md:818` records a real run on `emulator-5554`, `PASS`, with the
  evidence that actually matters for this story: `PRAGMA user_version` = 5,
  `invite_messages` present in `.tables`, and `22|location|TEXT` present on
  `activity_cards` — the v4→v5 migration proven on a real device DB file, not
  only in-memory. The run notes its own seeded-session and `adb reverse` setup
  and labels the seed as test priming, not product behaviour, so the result is
  readable rather than overclaimed.
- **F-3 — `location` erased by unrelated edits (BUG-20260910-001). CLOSED.**
  Verified in Slice C with direct source evidence:
  `activity_card_detail_cubit.dart:496` now reads
  `location: clearLocation ? null : location ?? card.location`, matching the
  carry-forward shape of every sibling nullable column, with `editLocation`
  mapping an emptied field to `clearLocation: true` rather than `''`. Four
  reachable paths have regression tests.
- **F-4 — remediation scope for rulings (a)/(b) understated. CLOSED.**
  `visual-fidelity-report.md:110-131` rewrites §2's closing paragraph, splits
  (a) from (b), and states that (b) is a content-pack schema change plus a new
  structured renderer — not a re-layout — with the `shared-foundation` /
  STORY-007 precedent cost spelled out for PO.
- **F-5 — §3.3 asserted evidence its own capture contradicted. CLOSED.**
  Verified at both levels. Slice C confirmed the enabling code change (the
  `"Phần chuẩn bị nằm ở bước sau."` SnackBar stub replaced by
  `widget.prepareActions(context, cubit.state.card)`, handing over the *emitted*
  card). I additionally opened the re-captured
  `implemented-11-chuan-bi-chon-hanh-dong-ios.png` myself, because this is the
  exact claim that failed round 1: the frame now shows the whole card detail
  above the sheet — *ĐÃ HẸN NGÀY* pill, "Cà phê sách Hào Nam", four meta cells,
  note block, chip row, the place row "rạp CGV Vincom Đồng Khởi", link block, and
  the "Chuẩn bị cho tươm tất" CTA — under a scrim, with the "Chuẩn bị" sheet and
  its one "Xuất lời mời" row at the bottom. Diacritics correct, `edit_note` glyph
  renders in pink with no tofu. The capture now supports the §4 claim made from it.

## 4. Deferred Findings

Carried forward, not re-opened. None of these blocks the merge.

**From Slice A (render engine + content pack)**
- **D-A1** — `approved_at` is parsed into `EditorialReview` but never validated by the gate; a pack can ship both reviewer identities with no approval date. AC-23's mandatory content still holds.
- **D-A2** — `validatePresetPack` has zero call sites in `lib/`; enforcement is build-time only. No gap today, but the AC-28 guarantee would lapse silently the day a non-asset content source lands. Record the wiring point for the first CMS-backed/downloaded-pack story.
- **D-A3** — the domain purity scan uses `listSync()` without `recursive: true`, so a future `domain/<subdir>/` would escape the AC-9/AC-3 determinism ban. The directory is flat today.
- **D-A4** — `req016` is hard-coded into both `presetAssetKey` and the gate test's `_presetDir`. Correct for every consumer AC-29 covers; a later requirement adding a category needs a path change.

**From Slice B (schema v5 + payload store)**
- **D-B1** — `migration_v5_test.dart` parametrises `from` over `[3, 4]`, not `[1, 2]`. The v1/v2 path was traced by hand and is correct; extending the loop would make that structural guarantee enforced rather than reasoned.
- **D-B2** — `savePayload` does not validate `filledValues` keys at write time; a wrong key is dropped later at render and surfaces only as a quietly shorter sentence. Deliberate forward compatibility, noted because this is the shared-foundation write surface.

**From Slice C (composer sheet + entry surface)**
- **D-C1** — `InviteComposerCubit` writes a full snapshot built from a card captured at construction. Nothing can mutate the card mid-sheet today (modal over the detail screen). Same hazard class as F-3, one layer up; re-check when a non-modal or long-lived composer appears.
- **D-C2** — `_invitedEdit` is a second hand-maintained copy of the 17-column list beside `_withEdits`. Mitigated: a per-field test against `ActivityCardEdit.from(card)` fails on a forgotten column rather than corrupting a row.
- **D-C3** — AC-16's "không tích hợp API nhắn tin" is verified at source-scan and visible-text level over this story's new files, never at the dependency-manifest level. **Ruling (Scrum Master): correctly OUT OF SCOPE for STORY-002.** A manifest-level assertion, if wanted, belongs to a requirement-level or project-level gate, not this story's evidence. Carried forward as a note, not a patch requirement.
- **D-C4** — AC-3's route ban is proven for the card → sheet → composer flow this story touches, via a `_RouteRecorder` walk of the real path. **Ruling (Scrum Master): correct as built.** This story's AC-3 evidence is explicitly scoped to its own flow and is **not** a claim of global AC-3 enforcement; the app shell, main menu, and tab bar are outside this story's write scope, and responsibility for AC-3 there sits with whichever story owns app-shell navigation.
- **D-C5** — three surfaces each carry a file-local bilingual helper (`_composerText`, `_prepareText`, `activityHubText`) because `mobile/lib/l10n/` is outside this story's write scope. Scope-correct; three places to update at l10n consolidation.

**Carried from round 1, still open**
- **D-1** — `story_master.md` records no `Design-Surface:` for a `shared` lane (rule 12e2). The surface id `cupid-ch-ng-1` and three `Design-Screen:` ids do exist in `visual-fidelity-report.md`, so this is a placement gap, not an unresolved surface.
- **D-2** — the P5 captures render fixture chips ("Rủ nhẹ nhàng" / "Kiểu nghiêm túc" / "Kiểu lầy lội") that appear nowhere in the shipped pack. They prove the layout, which is what a fidelity check is for, but not that shipped content renders. Still unannotated in the report.
- **D-3** — two `VISUAL_FIDELITY:` lines in one file (`:1` and `:135`, both `PASS`). Flagging this one above the others because it is the only deferred item with a mechanical downstream risk: gates that expect a single verdict token per report can read it ambiguously.
- **D-4** — round 1's clipped "Chuẩn bị" capture. Effectively resolved as a side effect of the F-5 re-capture: the sheet now sits in a full card frame with visible empty space below its single row.

**New at synthesis**
- **D-S1 — AC-24 was on the scope gate's Query Keys but on no slice's AC list.** `scope-gate.md:138` lists AC-24 among the story's AC ids; the `## Phase 2 Approval` 3-slice plan then assigns AC-23 and AC-25 but never AC-24, so no slice reported it. Resolved here rather than re-opened, because AC-24 has no independent implementation surface: `requirements.md:174-177` defines the ship condition as exactly "qua được cổng nhập (AC-28) và có kiểm duyệt biên tập theo AC-23", both of which Slice A verified PASS, and its remaining content is the record that OQ-3 closed on 2026-09-06 via D-15. AC-24 is therefore discharged transitively, not unverified. Recorded so the coverage arithmetic in §2 is honest about where the 23 checks stop.

## 5. Consolidated Verdict

Every AC in the story's scope is verified PASS or transitively discharged; all
five round-1 blocking findings are closed against evidence checked in this pass;
no slice returned a blocking finding; and the residual roster is 16 accepted
deferred items, none of which changes an accepted acceptance criterion or
requires a code change to merge.

## 6. Workflow Recommendation

- Check `Implementation (Development)` and `Review (Reviewer)` in `story_master.md`
- Story is eligible to be marked `DONE` by Scrum Master (`Status: TODO` today)
- Record `Design-Surface: cupid-ch-ng-1` on the story master when the lane is next touched (D-1)
- Fix the duplicate `VISUAL_FIDELITY:` token (D-3) before the DONE gate reads the report
- Carry D-A2, D-B2, D-C1 into STORY-007/008 planning — all three are shared-foundation surfaces those stories inherit
- D-C3 and D-C4 are closed as scoped, per the rulings recorded above; neither returns to this story

Outcome: DEFERRED_ONLY

REVIEW_COMPLETE: YES
