# Scrum Master Checkpoint: REQ-016 Solo Stage-1 relationship assistant

## Current state (as of Round 19, 2026-09-24)

Ground truth = integration-worktree `story_master.md` copies +
`git-story-boundary.sh status`, not narrative history.

| Story | Depends On | Status |
|---|---|---|
| STORY-001 | NONE | DONE, merged |
| STORY-002 | STORY-001 | DONE, merged |
| STORY-003 | NONE | DONE, merged |
| STORY-004 | STORY-001 | DONE, merged |
| STORY-005 | STORY-001, STORY-004 | **DONE, merged.** Final-synthesis review (RunId `...-reviewer-finalsynth`, fresh agent, did not continue the slice reviewer's context) returned **`Outcome: CLEAN`** (`review/review-report.md`, 134 lines, committed `f3fecc50`, merged `91d6da49`) — B-1 independently re-verified via diff scope + PNG commit-history cross-check, no new findings, D-1..D-6 remain deferred/non-blocking. `story_master.md` updated to Status DONE, Implementation/Review checked, `DESIGN_ANCHOR_ADJUDICATION_REQUIRED` flipped YES→NO with the resolved item→commit mapping (committed `b954964d`, merged `518d2453`). Boundary sealed via `git-story-boundary.sh complete` (`MERGE_COMPLETE: true`). **Open note carried forward**: `BUG-20260923-002`'s 3 assertions are already green on this story's branch (fixed by P7) — re-verify on the requirement integration branch before dispatching a bug-fixer, do not assume still-red. |
| STORY-006 | STORY-001 | DONE, merged |
| STORY-007 | STORY-001, STORY-002, STORY-003, STORY-005 | **DONE, merged (Round 22).** All 5 phases (P1-P5) implemented; Tier 3 review = 5 scoped-slice reviews (P1-P5, each `Outcome: PARTIAL_SLICE_ONLY`, 0 blocking findings) + fresh final-synthesis (`review/review-report.md`, 258 lines, **`Outcome: DEFERRED_ONLY`**, 0 blocking findings across all slices). Final-synthesis kept `VISUAL_FIDELITY: PASS` alongside 6 recorded `DESIGN_SPEC_CONFLICT` items (canvas-vs-AC precedent from `req_master.md` Design Ruling Log 2026-09-17/STORY-010, applied not reopened); confirmed 2 pre-existing cross-story reds non-blocking (`stage1_wipe_registry_parity_test.dart`, `calendar_event_service_test.dart:390` = `BUG-20260923-002`); extended `scope-gate.md` to full 52/52 files. Stray additive-only STORY-013 visual-fidelity PNG found in the diff (`implemented-j13-man-quay-lai-ios.png`, commit `4a241d2f`) — Scrum-Master decision: **kept**, consistent with shared visual-fidelity harness incidentally generating other stories' evidence. Committed final-synthesis artifacts (`0459a4ae`), merged (`c6a4024c`); `story_master.md` updated directly by Scrum Master (Status→DONE, added `Design-Screen: sb-212-cam-on-chot-viec-ke-tiep`, ticked Review with outcome summary, fixed `R-15c`→`R-15b` citation), committed (`cc3b258f`), merged (`73cbdbfe`); boundary sealed via `git-story-boundary.sh complete` (`MERGE_COMPLETE: true`). **Fresh, unresolved PO question surfaced by review §4 — see Open user decisions item 3.** |
| STORY-008 | STORY-001, STORY-002, STORY-003, STORY-004 | COMPLETED but unsealed: `runtime_smoke: BLOCKED` (disk recovered to 28Gi free, not re-attempted) + review F-3 open |
| STORY-009 | STORY-004 | DONE, merged |
| STORY-010 | STORY-004 | DONE, merged |
| STORY-011 | STORY-001, STORY-004, STORY-005, STORY-008 | blocked on STORY-008 (unsealed) |
| STORY-012 | STORY-001 | blocked on D-10 (brainstormer-routing decision, not Scrum-Master's) |
| STORY-013 | STORY-001, STORY-004 | **DONE, merged (Round 16).** Review passed (`review/review-report.md` line 199: `Outcome: DEFERRED_ONLY`, F1 fixed+re-checked at `e80eb387`, F2/F3 explicitly non-blocking, both cited as backlog follow-ups). Two blockers resolved this round: (1) `guard-story-done-evidence.sh`'s `candidate_dirs()` had a one-level-vs-two-level sibling-worktree scan bug, patched under explicit user authorization (same exception style as `guard-parallel-spawn.sh`) — verified fixed via direct `visual_fidelity.py` CLI diagnostic; (2) `design-reference-kho-da-dong-ios.png`/`implemented-kho-da-dong-ios.png` used a descriptive filename instead of the canonical canvas slug `ngan-da-hen-ngay-dang-doi` that `story_master.md` and the Reviewer's own visual-fidelity table already mapped them to — renamed both files and updated `visual-fidelity-report.md` per explicit user decision ("Đổi tên 2 file ảnh sang slug chuẩn"). Committed in the story worktree (`f5d3a323`: `Status: DONE`, Artifacts checklist Implementation/Review flipped to `[x]`, evidence rename + report text fix), merged into `codex/REQ-016_solo_stage1_relationship_assistant-integration` (`ca811a29`) after resolving one additive add/add conflict in `visual-fidelity-report.md` (kept the renamed-filename version), boundary `complete` confirmed (`commit_sha: f5d3a323`, `merge_sha: ca811a29`, `MERGE_COMPLETE: true`). |

## Open user decisions

1. **RESOLVED (Round 16).** STORY-013 is `DONE` and merged. User chose "Đổi
   tên 2 file ảnh sang slug chuẩn" for the evidence-filename mismatch; both
   fixes (guard depth-bug patch + evidence rename) verified and landed. See
   the STORY-013 table row above for the full trail.

2. **RESOLVED before Round 17 (mechanism not visible in this session's own
   tool history — cleared during a compacted-away portion of the
   conversation).** The `full-story-review` spawn for STORY-005's P5-P7
   rework did complete: `review/review-report.md` now carries a current body
   dated 2026-09-24 with `Outcome: PATCH_REQUIRED`. See the STORY-005 table
   row above for the resulting B-1 patch/re-review trail. Original block
   text, kept for the record only —
   "story-review blocked; no completed implementation lane with durable
   completion marker found for
   REQ-016_solo_stage1_relationship_assistant/STORY-005_conversation_starters".
   Tried and ruled out: (a) correcting `story_master.md`'s Review bullet to
   accurately describe P5-P7 as unreviewed — no effect; (b) registering a
   distinct `--run-id ...-reviewer-rework1` to rule out run-id collision with
   the pre-existing 2026-09-17 P1-P4 reviewer run file — no effect; (c)
   `git-story-boundary.sh repair-boundary` — updates `commit_sha` to the true
   current branch HEAD but leaves the boundary's `status` field stuck at
   `"MERGED"` (and `merge_sha` unchanged) from the original P1-P4 merge, which
   is the most likely reason the guard's "completed implementation lane"
   check keeps failing for this story (by contrast STORY-007's healthy,
   still-in-progress boundary shows `status: "STARTED"` with no
   `MERGE_COMPLETE` field at all). No sanctioned CLI action was found that
   flips a story boundary's `status` away from `"MERGED"` after a later
   rework commit lands on the same branch.
   **Round 14: the user's chosen remediation ("Định tuyến Frank-Devops sửa
   guard") turned out to be structurally unexecutable** — confirmed via
   `.claude/hooks/handoff-build.sh spawn --target Frank-Devops --mode
   guard-logic-fix ...`, which failed (exit 2): `unsupported --mode
   'guard-logic-fix' for --target devops`, listing the 9 sanctioned devops
   modes (`system-foundation|devops-implementation|runnable-foundation-verify|
   story-runtime-smoke|runtime-registry-update|
   local-environment-scripts-update|shared-infra-adopt|
   requirement-deployment|vps-deployment`) — none covers repairing an
   orchestration guard script under `.claude/hooks/`. Reported to user this
   round as a fresh, narrower decision: patch the guard directly as Scrum
   Master (explicit-user-request exception in the operating rules allows
   reading/patching hook source when the user explicitly asks for that), or
   an alternate sanctioned CLI action to reopen this boundary's `status`.

3. **STORY-007 P3/P4 Design-Ruling-Log decisions — RESOLVED this round.**
   Recorded in `req_master.md` `## Design Ruling Log` (2026-09-23 rows):
   `CONTENT_GATE_CATEGORY_COUPLING` → user chose lối (A), scope `decline_door`
   per preset category in `domain/preset_content_gate.dart`; and
   `JOURNAL_SOURCE_CONTRACT_CLOSED` → user chose lối (A), extend
   `journal_entry_point.dart` with a read-only photo-path projection by
   `originRef` (still needs Tech Lead to identify/add the caller that writes
   `originRef = id thẻ` when a journal entry is created from a card — the
   projection returns nothing until that write path exists). P3/P4 are now
   unblocked for dispatch: P3 → mobile-dev implementation with the
   category-scoped gate rule; P4 → needs a Tech Lead phase-plan touch first
   for the `originRef` write path, then mobile-dev implementation.

4. **OPEN, chưa đưa lên user/PO (Round 22).** STORY-007 final-synthesis
   review (`review/review-report.md` mục 4) phát hiện một hành vi
   one-way/không thể khôi phục: `ThankYouBlockCubit.resolve()` gọi
   `ledger.consume(cardId)` **trước khi** `emit(isVisible: true)`, và
   `resolve()` chạy từ `initState` của màn chi tiết thẻ — nghĩa là lượt kích
   hoạt trọn-đời-một-lần bị tiêu thụ ngay lúc **màn hình dựng xong**, không
   phải lúc khối thật sự **lọt vào tầm mắt** người dùng. Một thẻ có ghi
   chú/ảnh dài có thể đẩy khối xuống dưới màn hình, âm thầm đốt mất lượt kích
   hoạt duy nhất trước khi người dùng kịp thấy nó — không có cách khôi phục
   (`consumed` là trạng thái đã hấp thụ ở tầng SQL, `dismiss()` không có API
   un-consume). Reviewer không tự quyết vì AC-1/AC-3 dùng từ "mở chi tiết
   thẻ" chứ không phải "khối hiện ra trong tầm mắt" — đây là khoảng hở trong
   cách viết AC, không phải sai lệch khỏi AC hiện có, nên **không chặn DONE**
   (đã ghi trực tiếp vào `story_master.md` dòng Review). Câu hỏi cần đưa cho
   PO: AC-3 có ý nghĩa là "consume lúc màn dựng" hay "consume lúc khối thật
   sự hiện ra"? **Cần đưa lên user/PO trước hoặc ngay sau khi ship.**

5. **OPEN, chưa đưa lên user/PO — mang từ P1 (Round 19), xác nhận lại ở
   final-synthesis Round 22.** `stage1_wipe_registry_parity_test.dart` có một
   dòng đỏ tồn tại từ trước, cần một quyết định PO/Tech Lead vì chạm tới bảng
   trạng thái của 3 story khác — final-synthesis xác nhận đây là 1 trong 2
   mục đỏ liên-story đã biết (mục còn lại là `calendar_event_service_test.dart:390`
   = `BUG-20260923-002`, không do STORY-007 gây ra), không chặn DONE của
   STORY-007 nhưng quyết định gốc vẫn chưa được đưa lên user.

## Still-open non-blocking items

- STORY-008: retry `runtime_smoke` now that host disk has 28Gi free; re-review
  F-3 in `STORY-008/review/review-report.md` before sealing.
- Open, non-blocking bugs (cite, do not re-run repo-wide/broad commands):
  `BUG-20260907-001` (repo-wide `flutter test` pre-existing failures),
  `BUG-20260908-001` (repo-wide `flutter analyze` pre-existing chat/dream_jar
  warnings), `BUG-20260923-001` (Drift `schemaVersion` migration test lag —
  11 reds in `test/core/database/`, cite instead of re-running that combined
  suite from any REQ-016 story worktree), `BUG-20260923-002`
  (`test/features/conversation_starters` 3 pre-existing enum/rule-list-length
  reds, surfaced by STORY-007 P5, root cause is STORY-005 P6/P7 rework — cite
  instead of re-running that suite from STORY-007), `BUG-20260924-001`
  (3 pre-existing `test/design_system/` reds — `no_fork_guard_test.dart`,
  `shared_backdrop_occlusion_guard_test.dart`,
  `shared_backdrop_occlusion_test.dart` — confirmed pre-existing at STORY-007
  P3's own BaseHead `5fa0e972`, cite instead of re-running full-repo
  `flutter test` from any REQ-016 story worktree). Closed: `BUG-20260907-002`,
  `BUG-20260910-001`.
- Integration branch re-verification owed: `sync-integration` (Round 9) pulled
  `main`'s STORY-005 Design Ruling Log commit + checkpoint compaction into
  `codex/REQ-016_solo_stage1_relationship_assistant-integration`
  (now at `a4386f76`). Its own warning: re-run integration build/runtime
  verification and record under
  `REQ-016_solo_stage1_relationship_assistant/integration-review/` BEFORE any
  future `land-integration` for this requirement — prior evidence no longer
  describes what will ship.

## 3-part verification protocol (use before sealing any specialist's reported-complete work)

(1) `ListAgents`/`list-releasable-agents.sh` shows the agent idle/gone; (2)
worktree `git diff`/`git status` matches the declared WriteScope; (3) the
specialist's own output file / `story_master.md` Status field reads
DONE/COMPLETE. After sealing: commit (Scrum Master only), then
`git-story-boundary.sh refresh-base` before the next spawn handoff.

## Do Not Re-read

- `req_master.md` body text, `requirements/requirements.md`, all DONE stories'
  `requirements.md`/`uiux-spec.md`/`architecture/*`/`coding-plan/master-plan.md`
  for STORY-001/002/003/004/006/009/010 — superseded by this checkpoint. (The
  new 2026-09-20 Design Ruling Log row IS relevant to STORY-005 rework — Tech
  Lead was pointed at it directly, do not re-summarize it here.)
- `test-results.md` files (can be 80KB+) — use `git diff`/`Read
  offset/limit`, never a full Read.
- Round 1-8 narrative in git history of this file — superseded by the table
  and open-decisions sections above.

## Next action (Round 20 — quiescent, dispatching STORY-007 Tier 3 review)

- **STORY-005 is fully DONE and sealed.** No further action.
- **STORY-007 P4 landed and committed/merged this round** (see table row).
  All 5 phases DONE. Terminal agents `Alan-Techlead`, `Alex-Mobile-Dev`,
  `Alex-Mobile-Dev-2`, `Iris-QC`, `Iris-QC-2` all released via `TaskStop`.
- **STORY-007 Tier 3 scoped-slice review plan (dispatch sequentially — same
  `story-state:STORY-007_thank_you_and_next_plan` LockScope serializes
  concurrent reviewer slices anyway):**
  1. Slice P1 (persistence/migration, highest risk) — files: `mobile/lib/core/database/cupid_database.dart`,
     `cupid_database.g.dart`, `mobile/lib/core/database/tables/thank_you_activations_table.dart`,
     `mobile/lib/core/di/service_locator.dart`,
     `mobile/lib/features/activity_cards/thank_you/data/thank_you_activation_dao.dart`,
     `.../thank_you_activation_repository_impl.dart`,
     `.../domain/thank_you_activation.dart`, `.../thank_you_activation_repository.dart`,
     `.../thank_you_activation_service.dart`, `.../thank_you_activation_card_status_listener.dart`,
     `.../thank_you_activation_card_status_repository.dart`,
     `mobile/lib/features/chapter_closure/data/stage1_wipe_registry.dart`,
     `mobile/lib/features/activity_cards/domain/activity_card.dart` (enum append),
     plus schemaVersion-bump migration-test ripple (`mobile/test/core/database/*_test.dart` —
     9 files, cite `BUG-20260923-001`-style pattern: expect literal version-number-only diffs,
     not logic changes) and `mobile/test/features/activity_cards/thank_you/thank_you_activation_*_test.dart`,
     `mobile/test/features/chapter_closure/stage1_wipe_*_test.dart`. Output:
     `<Worktree>/data/requirements/.../STORY-007_thank_you_and_next_plan/review/slice-p1-activation-ledger.md`.
  2. Slice P2 (block shell + entry point) — `activity_card_detail_screen.dart`,
     `thank_you_block_cubit.dart`, `thank_you_block.dart` (shell part),
     `mobile/test/features/activity_cards/activity_card_detail_screen_test.dart`,
     `.../card_lifecycle_ui_test.dart`, `.../activity_type_test.dart`. Surface the
     4 already-flagged `DESIGN_SPEC_CONFLICT` items (canvas standalone-screen vs
     nested-block AC-7) for Reviewer to note, not re-litigate.
  3. Slice P3 (preset category) — `preset_content_gate.dart`,
     `mobile/assets/data/req016/presets.thank_you_after_date.v1.json`,
     `preset_content_gate_test.dart`. Cite `BUG-20260924-001` (pre-existing
     `test/design_system/` reds) instead of re-running full-repo tests.
  4. Slice P4 (photo-attach, already summarized above) — `attachable_photos.dart`,
     `photo_attach_section.dart`, `photo_attach_test.dart`, `thank_you_block.dart`
     (photo part), `thanks_section.dart`, `journal_repository.dart`,
     `journal_entry_point.dart`, `thank_you_block_test.dart`,
     `thanks_section_test.dart`. Surface the 2 new `DESIGN_SPEC_CONFLICT` items.
  5. Slice P5 (next-plan suggestions) — `next_plan_suggestion_service.dart`,
     `next_plan_cubit.dart`, `next_plan_section.dart`, `next_plan_test.dart`.
     Cite `BUG-20260923-002` (pre-existing conversation_starters reds, root
     cause STORY-005 P6/P7, re-verify on integration branch not story branch).
  6. After all 5 slices return PASS/PARTIAL_SLICE_ONLY: fresh final-synthesis
     reviewer (new agent, not a slice continuation) writes
     `review/review-report.md` with one `Outcome:` line, reading only the 5
     slice reports + `story_master.md`.
  Each slice `BaseHead` must be the true pre-P1 base `bfe231aa` (not the
  boundary's current refreshed `base_head`), diffed to current HEAD
  `7be9a23c`, scoped with `-- <exact files above>` per slice.
- **Slice P1 DONE (Round 20).** `Iris-QC` returned `REVIEW_SLICE_COMPLETE: YES`,
  `review/slice-p1-activation-ledger.md` `Outcome: PARTIAL_SLICE_ONLY` (slice
  literal; content = clean pass, no blocking finding). Key results: schemaVersion
  9→10 single bump verified clean against integration branch (no
  DRIFT_SCHEMA_COLLISION with other stories' v10); single-fire semantics at SQL
  layer; no punishment/streak/percent surface; layering/ADR-010 clean;
  `stage1_wipe_registry_parity_test.dart` red confirmed PRE-EXISTING/cross-story
  (STORY-009/010 tables missing from registry — needs a PO/Tech-Lead decision,
  not STORY-007's fault). 6 advisory notes for final-synthesis (see the slice
  file). **Guard note**: `validate-reviewer-handoff.sh` `PHASE2_MISSING` forced
  the reviewer to also create `review/scope-gate.md` and a placeholder
  `review/review-report.md` (outside declared WriteScope, but necessary —
  same guard-vs-handoff conflict pattern as STORY-005's B-1 slice, this time
  resolved by writing a minimal pointer instead of leaving Stop blocked).
  `review-report.md` now holds a `## Slice Index` table + one standing
  `Outcome: PARTIAL_SLICE_ONLY` line — **every subsequent slice (P2-P5) must
  APPEND a row to that table, never overwrite the file or its Outcome line.**
  Committed `4c99d0f3`, merged `0d2fff89`. `Iris-QC` released via `TaskStop`.
- **Slice P2 DONE (Round 20).** `Iris-QC` returned `REVIEW_SLICE_COMPLETE: YES`,
  `review/slice-p2-block-shell-entry-point.md` `Outcome: PARTIAL_SLICE_ONLY`
  (slice literal; content = clean pass, no blocking finding). Key results:
  single attach point confirmed (`ThankYouSection` called exactly once, inside
  `activity_card_detail_screen.dart`'s scroll column, no route/`Navigator.push`
  — genuinely nested, not a standalone screen); AC-1/AC-2 date-gate correctly
  delegated to P1's `isEligible`; AC-3 single-lifetime-fire verified
  (`consume` before `emit`, `_settled` flag, no reopen path); AC-6 single
  card-level action preserved (`thank_you_close` only); 3 "unrelated"
  card-detail test edits confirmed registration-only (GetIt/`CupidDatabase`
  setUp/tearDown, no assertion changes); independent re-run
  `flutter test test/features/activity_cards` green, `git status` clean after
  (no other story's PNGs touched); visual fidelity PASS vs `sb-212` via
  `RepaintBoundary` fallback. 7 advisory notes for final-synthesis, most
  notable **A3**: the single lifetime activation is consumed at screen-build
  time, not when the block actually scrolls into view — if a card's notes/photo
  push the block below the fold, the user can lose the one-time slot without
  ever seeing it; flagged as needing PO confirmation, not resolved here. Also
  **A4**: `thank_you_block_test.dart` (16 tests, P2's own primary test
  evidence) and `before_you_go_block_test.dart` are in the story diff but
  unassigned to any slice's file list (neither P1's `scope-gate.md` nor P2's)
  — final-synthesis must assign them. Two declared deviations, both
  self-reported and accepted: (1) `review-report.md`'s `## Slice Index`
  already had an empty `P2` placeholder row from P1's own authoring, so
  Iris-QC filled that row in place rather than appending a second P2 row —
  P1 row and the `Outcome:` line untouched; (2) `scope-gate.md` was **not**
  touched (guard did not re-fire this run, and it was outside declared
  WriteScope anyway) — it still only covers P1's files, final-synthesis must
  extend it to the whole story. Committed `becaf80d`, merged `878fada2`
  (re-merge, branch had advanced past the prior recorded merge — normal).
  `Iris-QC` released via `TaskStop`.
- **Slice P3 DONE (Round 20).** `Iris-QC` returned `REVIEW_SLICE_COMPLETE: YES`,
  `review/slice-p3-preset-category.md` `Outcome: PARTIAL_SLICE_ONLY` (slice
  literal; content = clean PASS, no blocking finding). **Handoff file-path
  guess was wrong, reviewer self-corrected via the diff**: the real content
  gate is `mobile/lib/features/invite_composer/domain/preset_content_gate.dart`
  (STORY-002's own file, not under `activity_cards/thank_you/`), test
  `mobile/test/features/invite_composer/preset_content_gate_test.dart`, new
  asset `mobile/assets/data/req016/presets.thank_you_after_date.v1.json`. Key
  results: 10 new preset ids all prefixed `thank_you_after_date.*`, no
  collision with `invite.*` (that pack untouched in this diff); `decline_door`
  scoping is genuinely per-category via an allowlist
  `_declineDoorCategories = {inviteCategoryId}`, invite branch strictness
  unchanged (`doors.length != 1`), new category only relaxes the *missing*
  case, still blocks *extra* doors; all other gate rules
  (`declineDoorConditional`, `editorial_review`, vocabulary denylist) remain
  global, no bypass path; no second engine — `thanks_section.dart` reuses
  `showInviteComposerSheet`/`InviteComposerCubit` unchanged; same
  `req016.presets.v1` schema, no fork. Independent re-run of just this
  slice's test file: `+22` all pass. 5 advisory notes, most notable **A3
  (Scrum-Master action, not a code defect) — RESOLVED same round**: the
  `preset_content_gate.dart` code comment cites the `CONTENT_GATE_CATEGORY_COUPLING`
  Design Ruling Log row in `req_master.md`, but that row (plus the sibling
  `JOURNAL_SOURCE_CONTRACT_CLOSED` row and 2 pending bug-registry entries,
  `BUG-20260923-002`/`BUG-20260924-001`) turned out to be sitting as
  **uncommitted local edits on `main`** since an earlier, pre-compaction round
  — confirmed via `git status`/`git diff` on the control checkout, absent
  entirely from the story worktree. This was the sole authorization for P3
  touching a STORY-002 file outside its own write-scope, so committed it
  immediately: `dc05d105` on `main`. No further action needed. Other
  advisories (A1 allowlist-is-fail-open for future invite-semantics
  categories, A2 test-oracle independence, A4 `.v1.json`-suffix assumption,
  A5 BaseHead bookkeeping mismatch) are non-blocking, deferred to
  final-synthesis. Committed `26ca73ce`, merged `12460988` (re-merge, normal).
  `Iris-QC` released via `TaskStop`.
- **Slice P4 DONE (Round 20).** `Iris-QC` returned `REVIEW_SLICE_COMPLETE: YES`,
  `review/slice-p4-photo-attach.md` `Outcome: PARTIAL_SLICE_ONLY` (slice
  literal; content = clean PASS, 0 blocking findings). Confirmed: AC-14..AC-18
  + BR-8/BR-9 all satisfied (dedup+merge of card-photo + journal-photo
  sources, empty state truly removes the slot rather than rendering blank,
  attach is an explicit uncommitted-by-default tap-to-select action,
  photo-only projection with zero journal text/timestamp leak, no staged
  copy outside the journal's own delete authority); `JOURNAL_SOURCE_CONTRACT_CLOSED`
  ruling honored (exactly one new read-only projection fn, still only 4
  entry-point declarations total, no FK/reverse-dependency `journal`→
  `activity_cards`); no schema/migration touched in P4 (confirmed via
  `core/database/` diff showing only P1's 3 files); no second nav destination;
  broken photo source fails soft (empty list, block survives); independent
  re-run `flutter test test/features/activity_cards/thank_you/
  test/features/journal/` → `+169 ~6` all pass, `git status` clean after.
  Visual fidelity: opened and eyeballed all 3 PNGs directly (not just read
  the report line) — confirmed correct 3-thumbnail row, no tick marks, no
  text overlay, full Vietnamese diacritics, no tofu. 6 advisories, all
  DEFERRED/non-blocking except two flagged for **Scrum Master/final-synthesis
  attention (not code defects)**: (A1) my own P4 handoff cited the wrong ACs
  — I wrote "AC-4/AC-5" when the governing set is actually AC-14..AC-18 +
  BR-8/BR-9 (AC-4/AC-5 are P1's activation-trigger criteria); Iris-QC
  self-corrected and reviewed against the right ACs, but **future handoffs
  in this story must cite AC-14..AC-18/BR-8/BR-9 for photo-attach, not
  AC-4/AC-5**; (2) `visual-fidelity-report.md` line 1 says
  `VISUAL_FIDELITY: PASS` while the same report also carries a
  `DESIGN_SPEC_CONFLICT` entry for this phase — the visual-fidelity gate's
  own default posture wants `BLOCKED: DESIGN_SPEC_CONFLICT` for that
  combination, but this story's own precedent (P2, STORY-006 P2) already
  settled "follow AC/spec over canvas" for conflicts of this shape;
  final-synthesis must make one explicit, story-level call on how to record
  this PASS+CONFLICT pairing rather than let it stand ambiguous. Also closed
  Slice P2's advisory A4: `thank_you_block_test.dart` (16 tests) is now
  claimed as P4's own primary test evidence (photo slot + share-composer
  wiring), confirmed by content, not left unassigned. Both
  `DESIGN_SPEC_CONFLICT` items independently re-verified against the actual
  canvas PNG (not just trusted from the implementation-time note): confirmed
  real (canvas shows a journal-metadata caption line + a trailing chevron
  implying a second destination). Committed `8dbf2806`, merged `deab88bb`
  (re-merge, normal). `Iris-QC` released via `TaskStop`.
- **Slice P5 DONE (Round 21) — LAST scoped slice, all 5 complete.**
  `Iris-QC` returned `REVIEW_SLICE_COMPLETE: YES`,
  `review/slice-p5-next-plan-suggestions.md` `Outcome: PARTIAL_SLICE_ONLY`
  (slice literal; content = clean PASS, 0 blocking findings). File list
  verified via true diff before handoff (no guess-correction needed this
  time): `next_plan_suggestion_service.dart` (+132, suggestion source,
  accept/undo), `next_plan_cubit.dart` (+81, phase-3 state, no loading flag),
  `next_plan_section.dart` (+176, header+chip+undo snackbar),
  `next_plan_test.dart` (+422, 13 tests). AC text was read directly from
  `req_master.md` (not reused from memory) — full table for
  AC-19/AC-20/AC-21/AC-22/AC-23/AC-24/AC-25/AC-28/AC-29/AC-30/AC-35/AC-36 +
  BR-11/BR-16/BR-17 all PASS: deterministic suggestion source (static+sync,
  no AI/network), card creation goes through STORY-001's single
  `ActivityCardRepository.createCard` contract (no second card-creation
  path), tap-to-confirm with a 5s undo snackbar satisfies "select and
  confirm" without a blocking dialog (AC-23 forbids a second confirmation),
  origin enum is internal-only/never rendered as a metric, N=0 removes the
  phase-3 slot entirely from the widget tree (not an empty header), N=500
  still yields exactly 3 chips with no async/loading step. Both of my
  handoff's 2 open items were resolved correctly by the reviewer: (1)
  `before_you_go_block_test.dart` and `service_locator.dart` → **both belong
  to P1**, not P5 (P1's `ActivityCardRepository` wrapper via composition
  root required STORY-006's test to register a database; zero next-plan
  content in either diff); (2) `activity_card.dart`
  (+3/-1, the `nextPlanAfterDate` enum value) → **P5 correctly claims this as
  its own evidence** (direct AC-24 implementation, appended per the enum's
  own append-only rule, no migration needed since `origin` is a plain
  `text()` column with no CHECK constraint) — flagged as advisory A3 that
  this is a real, justified out-of-declared-WriteScope file touch for Scrum
  Master's record, not a defect. Pre-existing red
  `calendar_event_service_test.dart:390` (enum-count pinned assertion, now
  6→7 elements) independently re-verified against BaseHead itself (not
  reusing the implementer's count) and correctly matched to the existing
  `BUG-20260923-002` row rather than filing a new bug. 5 advisories, all
  DEFERRED/non-blocking or forwarding notes: (A1) `NextPlanCubit.load()`
  lacks the `try/catch` P4 used for its own asset-loading path — an
  asymmetry, not a defect, no test covers the failure case; (A2)
  `unawaited(_accept(...))` has no error surface if `createCard` throws —
  low probability, local SQLite write; (A3) the out-of-scope
  `activity_card.dart` touch, noted above; (A4) BR-14 (a phase-3 copy rule)
  isn't independently retested here since the chip text is a pass-through
  from STORY-005's own gated content, correctly treated as out of P5's
  re-verification scope; (A5) forwards P4's `VISUAL_FIDELITY: PASS` +
  `DESIGN_SPEC_CONFLICT` pairing question to final-synthesis without
  re-litigating it, and additionally flags that the "3 rows instead of 2"
  visual delta is itself a direct AC-35 consequence (layout is a parameter,
  not a fixed count) that final-synthesis should read together with P4's
  conflict rather than as a separate item. `review/review-report.md`'s
  `## Slice Index` P5 row filled in place, P1-P4 rows and the standing
  `Outcome:` header untouched. Verified independently: `git status
  --porcelain` matched WriteScope exactly; both artifacts read in full;
  `RUN-...-reviewer-p5slice.json` read directly to confirm the reviewer's
  self-reported `OutputPath` declaration fix (my handoff wrongly gave a
  short worktree-root-relative form; the reviewer corrected the run-state
  declaration to the same full repo-relative form P1-P4 used, documented via
  `output_path_correction_note`/`output_paths_as_handed_off`, with the
  artifact itself written exactly once at the canonical path — no other
  run-state fields touched). **Lesson for any future `handoff-build.sh spawn`
  reviewer calls in this story: `--output-path`/`--write-scope` must use the
  full form `data/requirements/<REQ>/<STORY>/review/<file>`, not a short
  form relative to the story's own `review/` dir.** Committed `32f20f0a`,
  merged `4c9c1ccd` (re-merge, normal). `Iris-QC` released via `TaskStop`.
- **About to dispatch now: fresh final-synthesis reviewer** (new `Iris-QC`
  spawn, NOT a continuation of any slice reviewer's context). This is the
  real story-level review pass — reads only the 5 slice reports
  (`slice-p1-activation-ledger.md` .. `slice-p5-next-plan-suggestions.md`)
  plus `story_master.md`, not raw source. Must explicitly resolve: (a) the
  `VISUAL_FIDELITY: PASS` + `DESIGN_SPEC_CONFLICT` pairing tension (P4,
  echoed by P5-A5) with one deliberate story-level decision, following this
  story's own "AC/spec over canvas" precedent rather than reopening it; (b)
  record the accumulated `DESIGN_SPEC_CONFLICT` items across P2 (4) and P4
  (2) for the story record; (c) surface P2's advisory A3 (one-time
  activation consumed at screen-build time vs. scroll-into-view) as an
  explicit open question for PO, not a reviewer-resolved item; (d) extend
  `scope-gate.md` from P1-only to the whole story; (e) confirm P4's AC
  citation self-correction (A1: AC-14..AC-18/BR-8/BR-9, not AC-4/AC-5) is
  reflected accurately; (f) note P5's advisory A3 (the justified
  out-of-WriteScope `activity_card.dart` touch) in the story record. Must
  write ONE true `Outcome:` line — `CLEAN`, `DEFERRED_ONLY`, or
  `PATCH_REQUIRED` (never `PARTIAL_SLICE_ONLY`, which does not satisfy the
  DONE gate) — overwriting the placeholder file per its own standing
  instructions at the top. Use `Mode: retro-audit`-adjacent but this is an
  ordinary story final review, not retro — use whatever mode
  `handoff-build.sh spawn` resolves for a full story-level Reviewer pass
  given the existing scope-gate/slice-index state; check the builder's
  guidance if it rejects `scoped-slice` for a synthesis call.
- After each slice returns: 3-part-verify, then dispatch the next slice
  immediately (dispatch discipline — same story, so sequential is correct
  here, not a capacity-fill violation).
- After STORY-007 seals: re-run `.claude/hooks/list-releasable-agents.sh` and
  `TaskStop` exactly what it prints.
- Remaining known blockers, unchanged this round: STORY-008 unsealed
  (`runtime_smoke` retry owed, disk now has 28Gi free — not yet re-attempted),
  STORY-011 blocked on STORY-008, STORY-012 blocked on D-10
  (brainstormer-routing decision, not Scrum-Master's). STORY-013 is DONE,
  merged, no action needed.
- New non-blocking note (from STORY-005's final-synthesis review): before
  dispatching a bug-fixer for `BUG-20260923-002`, re-verify it on the
  requirement integration branch first — its 3 assertions are already green
  on STORY-005's own branch (fixed by P7), so it may have already resolved
  once STORY-005 merged into integration.
- No standing user decision is currently open for REQ-016 (decision 1 and
  decision 2 above are both resolved).
