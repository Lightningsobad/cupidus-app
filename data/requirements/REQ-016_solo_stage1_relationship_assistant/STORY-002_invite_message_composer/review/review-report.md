# Review Report: STORY-002 Xuất lời mời — khung nhại + mad-libs

Outcome: PATCH_REQUIRED

- Review type: `full-story-review`, round 1
- Scope gate: `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-002_invite_message_composer/review/scope-gate.md`
- Reviewer: Iris-QC
- Date: 2026-09-10
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-002_invite_message_composer`
- Diff baseline used: `711274e3fde25788c91390a44572d53766bba778` (merge-base with
  `codex/REQ-016_solo_stage1_relationship_assistant-integration`), **not** the
  handoff's `BaseHead` — see N-1.
- Blocking findings: 5
- Deferred findings: 4
- Recommendation: story stays `IN_PROGRESS`, return to the mobile lane.

## 1. Scope Verified And Not Verified

The handoff requested one full review of all 6 phases. The measured diff is
**40 files / +8832 −1752** with **13 governing artifacts** named — roughly 3x the
`full-story-review` budget in SKILL rule 1c (12 files, 2 large artifacts). Rather
than return a bare `REVIEW_SCOPE_TOO_BROAD` with no verification value, this run
completed the gate checks and a bounded set of targeted checks that do not need
broad reading. They found enough to return the story now.

**Verified:** entry-point reachability in code; the `location` write path
(P6 + STORY-001 cubit interaction); the "Chuẩn bị" → composer wiring; the shipped
content-pack schema and its `decline_door` / `targets` fields; all 8
visual-fidelity PNGs; the retro-rework gate; the Design Ruling Log rows cited by
the handoff.

**NOT verified, and not claimed:** systematic AC-1..AC-29 verification; the
render engine (P1), content gate (P2), schema-v5 migration (P3), and SB-125
payload store (P4) source; all 17 test files. The re-review after rework must be
sliced — a 3-slice plan with exact files and ACs is in `scope-gate.md`
`## Phase 2 Approval`.

## 2. Blocking Findings

### F-1 — `## Entry Point Reachability` evidence section is absent (rule 12e1)

`coding-plan/test-results.md` contains only the six phase headings; there is no
`## Entry Point Reachability` section, no `Reachable: YES`, and no concrete path.
`story_master.md` declares `UI-facing story: YES`. Rule 12e1 makes this section
mandatory and non-waivable.

I independently verified the entry chain **does exist in code**, so this is a
documentation-only fix, not missing implementation:

- `activity_card_detail_screen.dart` → `ActivityCardPrimaryAction.prepare` branch
  now calls `await widget.prepareActions(context, stored)` (it previously showed a
  "Phần chuẩn bị nằm ở bước sau." SnackBar)
- default presenter is `showPrepareActionsSheet`
  (`prepare_actions_sheet.dart:69`), whose list carries the row "Xuất lời mời"
  (`:116`), opening `showInviteComposerSheet` (`:73`)
- `implemented-chi-tiet-the-da-hen-ngay-ios-cho-hen.png` shows the discoverable
  CTA "Chuẩn bị cho tươm tất" on a `ĐÃ HẸN NGÀY` card

Owner: `mobile-dev`. Add the section recording the path
hub → card → detail → primary CTA → "Chuẩn bị" sheet → "Xuất lời mời" → composer.

### F-2 — `## Story Runtime Startup Smoke` evidence is absent (rule 12g)

No `## Story Runtime Startup Smoke` section exists in `coding-plan/test-results.md`,
and `story_master.md` records no `Runtime-Smoke: WAIVED — <reason>`. The story is
`Complexity: complex` with `Implementation Lane: shared (backend + mobile)`, so
rule 12g applies: the app must be shown to LAUNCH on the provided
device/emulator and reach its first screen without a crash or error screen.

This is load-bearing here specifically because the story raises `schemaVersion`
to 5 with a new column and a new table. A migration that throws on open is
exactly the class of failure a widget-test suite does not catch and a launch
does. The visual-fidelity report notes a device was reachable (`emulator-5554`).

Owner: `mobile-dev` (or `devops`). The DONE gate enforces this independently.

### F-3 — `location` is silently erased by any unrelated edit (story-caused)

`ActivityCardDetailCubit._withEdits` (`activity_card_detail_cubit.dart:418-492`)
does not carry `location` forward. Its result is handed to `updateCardDetails` as
a **full snapshot** via `ActivityCardEdit.from(next)` (`:374-377`), and the file's
own comment at `:470-474` states the invariant this violates:

> `_persist` hands the result to `updateCardDetails` as a full snapshot, where a
> missing field is an instruction to clear the column. Dropping any of these
> would make every unrelated edit — one character typed into the note — silently
> erase them.

So: user types a place → `_commitLocation` writes it directly to the store → user
then edits the title, note, price, or any chip → `_persist` runs → `location`
goes back to `NULL`.

**This is not pre-existing.** The handoff carries it forward as
BUG-20260910-001, described as "STORY-001's `_withEdits` drops `location`". The
`location` column did not exist before this story — P3 adds it in schema v5 and
P6 adds its editor. STORY-001 could not drop a column that did not exist. The
defect was created here, by adding a column to a full-snapshot contract without
updating the single carry-forward site the file's own comment says must be
updated. Rule 7 defers pre-existing issues "unless the current story made them
worse"; this story created it outright, so rule 6 applies instead.

Impact on acceptance: story AC-1 requires the composer to fill blanks with the
card's real fields including **địa điểm**, and the shipped presets consume it as
the `{place}` mad-libs variable (`presets.invite.v1.json:15`, `:33`, `:105`,
`:123`). A place that vanishes on the next unrelated edit makes that fill
unreliable. `activity_card_detail_screen.dart` already works around the symptom
by re-reading the stored card before opening the composer, which narrows the
window but does not close it.

I am not re-litigating the decision to file a bug. The correction needed is the
classification and the blocking status: a one-line carry-forward
(`location: clearLocation ? null : location ?? card.location`) in a
STORY-001-owned file is a write-scope question Scrum Master can settle, and the
story is returning to the lane anyway.

Owner: `mobile-dev`, with Scrum Master to widen write scope or confirm the bug is
a blocking dependency of this story.

### F-4 — Remediation scope for open rulings (a)/(b) is understated

`visual-fidelity-report.md` §2 closes with:

> if PO rules for the canvas, the work is a re-layout of `frame_chip_strip.dart`
> and `invite_composer_sheet.dart`, not a change to the Cubit, the payload
> contract, or the content pack.

Reading `design-reference-11-dien-mad-libs-xem-truoc-ios.png` directly, that is
not correct. The canvas frame is a **rendered document parody**: a titled form
("ĐƠN XIN NGHỈ PHÉP") under a letterhead caption ("CỘNG HOÀ ĐỘC THÂN — CHUẨN BỊ
CHẤM DỨT"), with labelled fields ("Kính gửi:", "Tôi tên:", "Lý do:"), highlighted
fill-in slots, a checkbox approval row ("☐ Đồng ý · ☐ Không"), and a
place/date footer.

The delivered content schema cannot express any of that. `presets.invite.v1.json`
stores each preset as a flat `clauses` list of prose sentences with
`requires`/`targets`/`role`. There is no title, letterhead, field label, checkbox,
or footer construct. Rendering the canvas frame would require a **content-pack
schema change and a matching renderer change** — precisely what the report says
would not be needed.

Why this blocks rather than defers: this is a `shared-foundation` story, and
`story_master.md ## Open Question Impact` records that the schema it ships is the
**precedent for every later preset story** (AC-25, R-15a), with STORY-007 due to
add a second category onto this same renderer. PO is being asked to rule on
(a)/(b) using a cost estimate that omits the schema. If PO rules for the canvas
after this merges, the locked precedent breaks and STORY-007's basis goes with it.

Owner: `mobile-dev` to correct §2's closing paragraph; Scrum Master to re-surface
(a)/(b) to PO with the corrected blast radius. The ruling itself stays PO's.

### F-5 — `visual-fidelity-report.md` §3.3 asserts evidence its own capture contradicts

§3.3 states, as its proof of `ux/uiux-spec.md` §4:

> The card detail is visible behind the scrim, which is §4's requirement that
> dismissing the sheet lands back on the card.

`implemented-11-chuan-bi-chon-hanh-dong-ios.png` shows a uniform flat grey field
behind the scrim with no card content whatsoever — the same blank host background
as the P5 captures. The widget test rendered the sheet over an empty scaffold.

The implementation may well satisfy §4; the point is that this capture does not
show it, and the report cites it as though it does. Rule 12e3 makes the images the
authority over the verdict token, and here the images disagree with a stated
finding. Everything else in §3.3 that I could check against the image held (grab
handle, title "Chuẩn bị", one "Xuất lời mời" row with an `edit_note` glyph in
`colorAccentPink` and a trailing chevron, no count, no second CTA, correct
diacritics, no tofu).

Owner: `mobile-dev`. Either re-capture with the card detail actually mounted
behind the sheet, or withdraw the §4 claim and prove it another way.

## 3. Deferred Findings

- **D-1 — no `Design-Surface:` on a `shared` lane.** Rule 12e2 requires a
  `shared` lane story to carry `Design-Surface: <id>` so the canvas cannot be
  confused with another app's. `story_master.md` records none. The information
  does exist — `visual-fidelity-report.md` names surface `cupid-ch-ng-1` and three
  `Design-Screen:` ids, and I confirmed the references depict those screens — so
  this is a placement gap, not an unresolved surface. Record it on the story
  master when the lane is next touched.
- **D-2 — P5 captures use fixture content absent from the shipped pack.** The
  chips read "Rủ nhẹ nhàng" / "Kiểu nghiêm túc" / "Kiểu lầy lội"; `grep` finds
  none of these in `mobile/lib` or `mobile/assets`. The shipped frames are
  "Rạp phim", "Quán cà phê", "Đi bộ lòng vòng", "Ăn vặt", "Nhà thám hiểm",
  "Báo cáo công việc", "Thông báo dán tường", "Vào bếp", "Hiệu sách",
  "Kế hoạch chi tiết". The capture therefore proves the **layout**, which is what
  a fidelity check is for, but not that shipped content renders correctly. Worth a
  line in the report so a later reader does not mistake it for shipped output.
- **D-3 — two `VISUAL_FIDELITY:` lines in one file** (`:1` and `:117`, both
  `PASS`). Gates that expect a single verdict token per report may read this
  ambiguously, the same way a duplicated verdict line breaks the reviewer gate.
- **D-4 — the "Chuẩn bị" sheet capture is clipped at the frame bottom.** The
  single row sits flush against the 415x900 edge, so the image cannot show
  whether anything renders below it. Combined with F-5, this capture is the
  weakest of the eight.

## 4. What Passed

- **Retro-rework gate (rule 1a):** `data/retro-audit/rework-backlog.md` has 0
  `Status: PENDING` and 0 `Status: IN_PROGRESS`. Gate open, `Retro-Bypass: NO`
  correctly needed no bypass.
- **Test and static-analysis gates (rule 12e0):** accepted on the handoff's
  independently reproduced tallies — 330 passed / 0 failed / 2 pre-existing skips;
  `flutter analyze` 15 pre-existing `prefer_initializing_formals` info, 0 from
  story code. Not re-run (rule 18).
- **Design-source conflict typing (rule 12e2):** (c) "Gửi qua Zalo" + download
  icon and (d) "CÒN HAI CHỖ TRỐNG" banner are both visibly present in
  `design-reference-11-dien-mad-libs-xem-truoc-ios.png`, and both do violate
  accepted ACs (AC-16/§2.6 forbids per-channel icons; AC-26/AC-27/R-15b forbid any
  count or progress indicator). The `DESIGN_SPEC_CONFLICT` typing is correctly
  evidenced, not a label on an ordinary delta. Confirmed closed in
  `req_master.md ## Design Ruling Log`; not re-litigated.
- **Chip-strip vs card-list (conflict a):** `requirements.md:320-321` explicitly
  delegates "chi tiết trình bày bottom sheet (số lượng khung nhại hiển thị cùng
  lúc, cách đổi khung, layout xem trước)" to the UI/UX Designer within the story.
  The implementation following `uiux-spec.md` §2 over the canvas is within scope.
- **Image authenticity (rule 12e3):** all 8 PNGs open as real captures of this
  story's screens — no error frame, no spinner, no placeholder, no wrong screen.
  Vietnamese diacritics render correctly with no tofu in every one, including the
  `edit_note` glyph that the report says was re-captured after the
  `MaterialSymbolsRounded` font fix.
- **Place row (P6):** `implemented-chi-tiet-the-moi-nghi-ra-ios-cho-hen.png` shows
  "rạp CGV Vincom Đồng Khởi" in a `colorSurface` box between the chip row and the
  link-provenance block, matching the phase file's "cùng dạng với các trường tuỳ
  chọn đang có", with still exactly one primary CTA. Gap (f) — the canvas predates
  the column — is correctly recorded as needing no ruling.
- **Content-pack invariants (partial):** every preset I read carries a
  `role: decline_door` clause (story AC-3 / R-1c) and uses
  `targets: "sender"` for its joke clause, never `recipient` (R-1d). Per-preset
  `editorial_review` with `layer1`/`layer2`/`approved_at` under a stable id
  satisfies AC-23's traceability shape. The runnable gate itself
  (`preset_content_gate.dart`, AC-28) was **not** reviewed — Slice A.

## 5. Notes On The Handoff

- **N-1 — `BaseHead` equals HEAD.** The handoff declares
  `BaseHead: 838f5d268b4d62d99b47247aaf91f608d0f38b42`, which is the current
  worktree HEAD (the P6 commit), so `git diff <BaseHead>` is empty.
  `handoff-schema.md` requires that for `story-review` the `BaseHead` be the
  implementation diff baseline and "an ancestor of the current Worktree HEAD,
  never HEAD itself". The prose instruction to diff against the merge-base was
  correct and is what I used (`711274e3`); the control field was not. Worth fixing
  before the sliced re-review so each slice gets a usable baseline.

## 6. Traceability

| Input | Used for |
|---|---|
| `story_master.md` | complexity, lane, story-class, ACs 1-7, OQ-3/D-15 impact, absence of `Runtime-Smoke:`/`Design-Surface:` |
| `requirements/requirements.md` | AC-5, AC-16, AC-23..AC-29, the `:320-321` UX delegation |
| `../req_master.md` `## Design Ruling Log` | confirming (c)/(d) closed, STORY-001 rows out of region |
| `coding-plan/test-results.md` | F-1, F-2 (absent sections), phase inventory |
| `visual-fidelity/visual-fidelity-report.md` + 8 PNGs | rule 12e3 verification, F-4, F-5, D-2, D-3, D-4 |
| `activity_card_detail_screen.dart` (boundary diff) | F-1 entry chain, F-3 workaround |
| `activity_card_detail_cubit.dart:418-492` | F-3 carry-forward omission |
| `prepare_actions_sheet.dart` | F-1 entry chain |
| `presets.invite.v1.json` | F-3 `{place}`, F-4 schema shape, AC-23 traceability |
| `data/retro-audit/rework-backlog.md` | rule 1a gate |

## 7. Workflow Recommendation

- Uncheck `Implementation (Development)` in `story_master.md`
- Leave `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS`
- Route F-1, F-2, F-4, F-5 to `mobile-dev`; route F-3 to `mobile-dev` after Scrum
  Master settles the write-scope question on `activity_card_detail_cubit.dart`
- Fix `BaseHead` (N-1) before the next handoff
- Re-review as 3 `Reviewer: scoped-slice` passes + one `Reviewer: final-synthesis`,
  per `scope-gate.md ## Phase 2 Approval`
