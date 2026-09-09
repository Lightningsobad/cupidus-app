# Scrum Master Checkpoint: REQ-016 Solo Stage-1 relationship assistant

Updated: 2026-09-09 (session 798d014f, continue parallel wave — P11
(B-1 schema/migration) implemented by `Alex-Mobile-Dev`, independently
verified incl. running flutter analyze/test myself, and committed `86e66dd`
(item 4n); next: dispatch/continue `Alex-Mobile-Dev` for P12).
Requirement Status: IN_PROGRESS.

**STORY-003 is DONE and merged** (`69b3690` into
`codex/REQ-016_solo_stage1_relationship_assistant-integration`, review
`Outcome: DEFERRED_ONLY`). STORY-001 is the only story in flight; all others
wait on it (shared-foundation).

Open, non-blocking bugs (cite, do not re-run repo-wide commands):
`BUG-20260907-001` (repo-wide `flutter test` pre-existing failures),
`BUG-20260908-001` (repo-wide `flutter analyze` pre-existing chat/dream_jar
warnings). Closed: `BUG-20260907-002`.

## Story Graph (from `requirements/requirements.md`)

| Story | Depends On | Story-Class |
|---|---|---|
| STORY-001 | NONE | shared-foundation |
| STORY-002 | STORY-001 | standard |
| STORY-003 | NONE | standard (DONE, merged) |
| STORY-004 | STORY-001 | standard |
| STORY-005 | STORY-001, STORY-004 | standard |
| STORY-006 | STORY-001 | standard |
| STORY-007 | STORY-001, STORY-002, STORY-003, STORY-005 | standard |
| STORY-008 | STORY-001, STORY-002, STORY-003, STORY-004 | standard |
| STORY-009 | STORY-004 | standard |
| STORY-010 | STORY-004 | standard |
| STORY-011 | STORY-001, STORY-004, STORY-005, STORY-008 | standard |
| STORY-012 | STORY-001 | standard |
| STORY-013 | STORY-001, STORY-004 | standard |

## KNOWN MERGE COLLISION (resolve at STORY-001 merge; Scrum-Master Git orchestration, do not delegate)

Both in `mobile/lib/core/database/cupid_database.dart`:
1. **Migration branch**: STORY-001 P1 and STORY-003 P1 each bump
   `schemaVersion` 2->3 with their own `onUpgrade` branch. Combine into one
   `if (from < 3)` branch, keep schemaVersion 3, re-run both migration tests.
   (STORY-003's literal fix already in `fcc5066`; STORY-001 already asserts
   `3`, no fix needed there.)
2. **Constructor signature**: STORY-003's patch2 (`1c32341`, merged
   `69b3690`) added `BackupExclusion? excludeFromBackup` as a second
   positional `CupidDatabase` param. Reconcile against STORY-001's own edits
   (if any) and check `service_locator.dart` call sites on both sides.

Non-blocking: STORY-001 P5 and STORY-003 P5 both touch
`mobile/lib/l10n/app_vi.arb`/`app_en.arb` for different keys — don't collapse
their arb edits into one commit at merge.

## STORY-001 status (all prior round-by-round history superseded by artifacts — do not replay)

P1-P10 implementation, S9 patch round (S9-F-1..F-6), Tech Lead splash-screen
ruling, D-18/D-19 A4 CTA rebuild (PO ac-patch `26427f2` on `main`, mobile-dev
rebuild `dedd45b`), and round-1 `final-synthesis` (`Outcome: BLOCKED` on
`REVIEW_EVIDENCE_GAP_UNREVIEWED_PATCH_ROUND`) are all **DONE, COMMITTED, and
superseded by round-2 final-synthesis below (item 4h)** — do not replay; see
`review/review-report.md` for full history if ever needed. Key artifact
commits if a citation is needed: `880541d`, `b7202e0`, `b8c4bef`, `8f44d3c`,
`812c83d`, `dedd45b`, `f5e69b2`.

**Do not trust a RunState `status` field without checking the actual
worktree diff first.** Wait for the real teammate mailbox/SubagentStop
notification, then verify `git status`/`git diff` matches WriteScope before
committing or trusting a completion marker.

## Next Step On Resume

1. STORY-003: DONE, merged. No further action.
2. STORY-001 P1-P10/S9/Tech-Lead-splash/A4-CTA-D18-D19/round-1-final-synthesis:
   all DONE, superseded — see item 4h below for the current gating verdict.
4. Outstanding before the next `final-synthesis` (all Scrum-Master-dispatched,
   none auto-chains):
   a. **DONE** — `Mode: scoped-slice` review of diff `4940e26..c92fd1b` (20
      files, +1391/-298), slice name `P2-PATCH-ROUND-2`, review-report.md
      append committed as `24839af` (via `git-story-boundary.sh commit`).
      Result: `PARTIAL_SLICE_ONLY`, does not itself change the head
      `Outcome:` line. Independently re-ran 5 test commands + `flutter
      analyze` in the worktree (all green/pre-existing-only per the report).
      **CLOSED with evidence**: B-1 (Minute-1 empty-state now really mounts,
      not a placeholder), B-2 (both code half via new `Future<int>` write
      contract AND the 2 rewritten AC-15 tests — confirmed tightened, not
      weakened), B-3 (both landed in `c92fd1b`), B-4 (3 `app_shell_test.dart`
      tests, in-memory DB harness, assertions tightened not dodged), B-6 code
      half (occasion-package snackbar branch actually removed, not just
      hidden). B-6's durable-record half stays open (item 4c, non-code).
      New findings, none blocking: P2-F-1 (deferred — no serialization on
      concurrent-edit snapshot writes, narrow window, pre-existing gap not a
      regression), **P2-F-2 (flagged "needs a patch round", NOT just
      deferred — see new item 4g below)**, P2-F-3 (process note, see below),
      P2-F-4/F-5 (deferred, minor `updated_at` staleness semantics), P2-F-6
      (already closed elsewhere, not reopened).
      **Process note from P2-F-3**: this slice's own dispatch wrongly listed
      `activity_card_detail_screen.dart`/`..._test.dart` under `Do Not
      Re-read`, claiming they were "unaffected by this diff scope" — they
      were actually in the `4940e26..c92fd1b` diff (+94/-29, +9/-6) and carry
      half of B-2's evidence. The reviewer read them anyway and caught it,
      but future scoped-slice dispatches on this story must build `Do Not
      Re-read` from `git diff --name-only` of the **exact slice being
      dispatched**, never copied from a different slice's already-reviewed
      file list.
   b. **DONE (A4 half only)** — mobile-dev recaptured A4's 2 screenshots and
      added `visual-fidelity-report.md` `## 9. Round 7`, committed `637269a`
      (verified via `git status --porcelain`/`git diff --stat`: exactly the
      3 WriteScope files, +92/-2 on the report). **D-18 and D-19 closed** in
      the visual-fidelity report (§8.3 lines now say "Closed in round 7").
      New cosmetic deltas, both non-blocking, both explicitly left as-is:
      D-28 (canvas colors part of the D-19 secondary line in accent pink;
      implementation keeps it uniformly muted — correct per D-19's own
      "must not read as tappable" ruling, so NOT matching the canvas here is
      the right call) and a D-20 re-confirmation (pre-existing icon
      substitution, `cupid_icons.dart` out of scope). Head token stays
      `VISUAL_FIDELITY: FAIL` — still open for D-8 (Product-Owner-owned,
      untouched by this round) — round 7 narrows FAIL's scope, doesn't clear
      it.
      **NEW follow-up (not yet dispatched, small, fold into item 4c/later
      housekeeping rather than blocking final-synthesis)**: capturing A4
      wrote all 3 of that test file's frames in one pass, so
      `implemented-the-da-thanh-ky-niem-ios.png` (screen A8) got overwritten
      then correctly `git checkout`-restored by mobile-dev (out of that run's
      WriteScope, verified clean in the commit diff). A8's in-region content
      is unaffected (§8.1: its CTA sits below the 900px fold, untouched by
      D-18/D-19's changes), but its frame is now stale *below* the fold
      (CTA text/secondary-line changed). Needs a future dispatch with
      WriteScope including that one file — does not block STORY-001 merge,
      since A8 is a different story/screen's concern than what's tracked
      here as B-5/D-8.
      Current story worktree HEAD: **`637269a7e7cf61f04bd452561979b683af6856bf`**.
   c. **CORRECTED, role-map conflict found**: B-6's durable-record half
      (content-owner/refresh-date record before 2027-12-25) needs a
      Product-Owner-level business call (who owns occasion-pack content,
      when it's refreshed) — the "or verified test coverage" alternative
      is already satisfied (item 4a's P2-PATCH-ROUND-2 slice independently
      confirmed the dead-CTA-hiding branch is real and tested). Scrum
      Master cannot dispatch `product-owner` directly mid-delivery — only
      `brainstormer` spawns PO, before a requirement enters delivery
      (`.agent-contract/role-map.md`). Since the code-coverage alternative
      is already closed, this item does **not** need further dispatch:
      hand the remaining durable-record gap to the next final-synthesis
      reviewer as a DEFERRED classification call, same treatment as R-1
      below.
   d. R-1 CTA-acceptability-under-AC-11 — **CORRECTED, same role-map
      conflict**: this needs a Product-Owner ruling, which Scrum Master
      cannot dispatch mid-delivery (only `brainstormer` spawns PO). This
      was already correctly flagged as a role-boundary constraint earlier
      in this file (see "R-1 ... stays OPEN/deferred" above) — the
      `Mode: ac-patch` framing recorded here previously was wrong and must
      not be acted on. Do not dispatch PO for this. Instead, the next
      final-synthesis reviewer must independently decide whether R-1
      (and B-6's durable-record half) are DEFERRED (non-blocking,
      `Outcome: DEFERRED_ONLY` eligible) or BLOCKING, since Scrum Master
      has no further escalation path for either inside ordinary delivery.
   e. **DONE** — scoped-slice review of the A4 CTA rebuild, 0 blocking
      findings (see above). review-report.md append committed as `ea9c8e5`
      (via `git-story-boundary.sh commit`, NOT raw `git commit` — the
      worktree's ephemeral-branch guard blocks a raw commit here once a
      story-review has run; use the `commit` subcommand for any further
      story-worktree commit this story). Current story worktree HEAD:
      **`ea9c8e5ecc673c1cc979f205d560a520d568d863`**.
   f. **NEW, from A4-F-1**: when dispatching the next `final-synthesis`,
      explicitly instruct it to read AC-11/AC-13 from the control checkout
      (`main`), not the story worktree, since `26427f2` isn't merged into the
      story branch yet and won't be until STORY-001 itself merges.
   g. **DONE** — P2-F-2 widget-test coverage patch. Alex-Mobile-Dev added 6
      tests / 2 groups to `activity_card_detail_screen_test.dart` (+253
      lines, committed `3e840ae`, verified via `git status --porcelain`/
      `git diff --stat`: exactly the 1 WriteScope file). No `lib/` change
      needed — all 5 fields already wire `_commitOnBlur` correctly and the
      empty-title revert already worked; the gap was test coverage only.
      Covers: blur-commit for all 5 fields (title/note/sourceLink/
      priceVnd/distanceKm), `onSubmitted`-commit for the 4 submittable
      fields, an unedited-field-still-commits-unchanged-snapshot guard, and
      3 AC-6/S6-F-6 empty-title-revert tests (revert-to-stored, revert-to-
      last-saved-not-original, submit-empties-reverts-and-never-writes-
      blank). Independently re-ran
      `flutter test test/features/activity_cards/activity_card_detail_screen_test.dart`
      in the worktree myself: **13 passed, 1 skipped (unchanged visual-
      fidelity capture skip), 0 failed** — matches the specialist's report
      exactly. `flutter analyze` on the touched file: 0 issues (baseline).
      Non-blocking behavioral observation recorded by mobile-dev (not
      fixed, correctly out of "smallest necessary fix" scope): `done`
      submit triggers `_commitTitle` twice (submit then blur-from-
      focus-loss), so an unedited field's blur/submit produces a second
      no-op snapshot write that still bumps `updated_at` — same family as
      the already-deferred P2-F-4/P2-F-5 `updated_at` staleness findings,
      not a new item.
      Current story worktree HEAD: **`3e840ae20fcc1ff1bdc280af42cd9233c742643d`**.
   a/b/e/g are done; c/d were corrected above and then actually ruled on by
   the round-2 final-synthesis reviewer below (h).
   **h. DONE — final-synthesis round 2** (`Iris-QC-2@session-798d014f`,
   BaseHead `9207f729` = merge-base with the integration branch, HEAD
   `3e840ae`, `review-report.md` `## Final synthesis vòng 2` append
   committed as `35703ff` via `git-story-boundary.sh commit`, +193/-7).
   Independently read the full diff before trusting the mailbox self-report
   (which was truncated). New head-line verdict **`Outcome: PATCH_REQUIRED`**
   (line 3 of the file) explicitly supersedes both S8's `PATCH_REQUIRED`
   (`e3a504f`) and round-1's `BLOCKED` (`f5e69b2`) — old bodies kept as
   history, not deleted.
   Ruled, per the reviewer's own authority (no further Scrum-Master dispatch
   needed for any of these):
   - **P2-F-2: CLOSED** (independently re-verified the `3e840ae` diff itself,
     1 file/+253/-0, re-ran the test file: 13/1/0, matches).
   - **R-1: DEFERRED, not an AC violation.** *Đã hẹn ngày*'s `prepare` CTA
     shows a snackbar (not dead), and AC-11 only constrains CTA count/label/
     overflow — not outcome. AC-13's no-dead-end guarantee is independently
     satisfied via the "Chuyển trạng thái" (AC-14) and "Xoá thẻ" (AC-16)
     rows. STORY-002 owning "prepare" is a PO story split, not a scope cut.
     Non-blocking note **FS2-D-1**: this snackbar is the same
     invite-then-refuse shape B-6 just *removed* from `_revealSuggestions` —
     one product, two answers to the same situation now; flag for
     ui-ux-designer/STORY-002 to pick one standard, not blocking.
   - **B-6 durable-record half: DEFERRED** (`DEFERRED_ONLY`-compatible). The
     user-visible behavior already ships and is tested (P2-PATCH-ROUND-2);
     the open piece (who owns occasion-pack content, refresh cadence before
     2027-12-25) is a content-ops record, not an AC/field/behavior — doesn't
     trip `triage-and-outcomes.md`'s DEFERRED exclusions. Owner: Product
     Owner, same next-user/PO touchpoint as R-1, not a story blocker.
   - **M-1, M-5: DEFERRED** (mislabeled AC-range in `scope-gate.md` Query
     Keys, and a missing `## ... P2` heading in `test-results.md` — evidence
     for both already exists under other headings, doc-only gaps).
   - **M-6: DEFERRED, 1 case confirmed.** `visual-fidelity-report.md` D-16/
     D-22 cite "AC-6" for detail-screen field editability; that's actually
     AC-8 (AC-6 is new-card title-only creation). Behavior is correct, just
     mis-cited.
   - **M-3: DEFERRED, half-closed.** D-8 half is now closed (see FS2-F-1
     below). D-5 half still contradicts: `req_master.md:169-173` says D-5 is
     open/assigned to Tech Lead, while `visual-fidelity-report.md` §3c says
     D-5 "closed this round". Behavior already shipped at P7 (`ActivityType`
     enum) — this is a doc-sync gap, not a code gap. Owner: Product
     Owner/Tech Lead, fold into the same PO touchpoint as R-1/B-6.
   **Two new BLOCKING findings — real gate, need one more mobile-dev patch**:
   - **FS2-F-1**: `visual-fidelity/visual-fidelity-report.md:1` head token
     is still `VISUAL_FIDELITY: FAIL`, citing D-8 as the reason (§9.3). But
     `req_master.md` `## Design Ruling Log` on **`main`** (commit `9c36bff`,
     NOT yet in the story branch cut at `9207f72`) already rules D-8
     **`ĐÓNG` / `KHÔNG chặn`** (closed, non-blocking; explicitly no new
     field/column/enum/patch-phase needed). The token is stale evidence, not
     a code defect.
   - **FS2-F-2**: `implemented-the-da-thanh-ky-niem-ios.png` (screen A8, one
     of the report's 4 declared `Design-Screen:` captures) is confirmed
     stale below the fold — same gap flagged in item 4b's follow-up note
     (CTA text/secondary-line changed by the A4 rebuild, A8's frame wasn't
     recaptured). §9.4 already says this needs a dispatch whose WriteScope
     includes that file.
   Reviewer's own recommendation (do not re-review code): **one** mobile-dev
   dispatch covering both, WriteScope = the whole `visual-fidelity/`
   directory (report + the one stale screenshot), explicitly instructed to
   read D-8's ruling from the **control checkout/`main`**, not the story
   worktree (worktree is still pre-`9c36bff`, same family as A4-F-1/FS2-D-2:
   `req_master.md`/`requirements.md` on the story branch lag `main`'s PO
   patches until STORY-001 itself merges). After that patch: re-evaluate the
   head token; if any FAIL reason survives beyond D-8, name it explicitly —
   if what's left is only `DESIGN_SPEC_CONFLICT`/`CONTRACT_GAP` territory,
   the *next* review routes `BLOCKED: DESIGN_SPEC_CONFLICT` for a user
   anchor call, not another patch round. Then only a **`Mode: scoped-slice`**
   review of that one round-8 visual-fidelity patch is needed — not a third
   full final-synthesis; all B-*/R-*/P2-F-2 code findings are already closed
   with reviewer-run evidence.
   Story stays **`IN_PROGRESS`**; not merge-eligible yet.
4i. **DONE** — mobile-dev round-8 evidence patch (`Alex-Mobile-Dev-3`,
   RunId `...-mobiledev-fs2patch`, `MOBILE_PATCH_COMPLETE: YES`, committed
   `b65013d` via `git-story-boundary.sh commit`, verified via
   `git status --porcelain`/`git diff --stat` before AND after my own
   independent re-run — exactly the 2 WriteScope files, +82/-4 on the report,
   PNG binary diff only). Independently re-ran
   `flutter test test/features/activity_cards/activity_card_detail_screen_test.dart
   --dart-define=CAPTURE_VISUALS=true`: **+14 pass, 0 fail**, matches exactly.
   FS2-F-2 (A8 stale screenshot): **CLOSED**, recaptured, A4 frames came back
   byte-identical (proves determinism, only A8 had drifted).
   FS2-F-1 (stale token): **partially closed, token stays `FAIL` on purpose,
   for real reasons now named instead of the stale D-8 excuse**. §9.3
   rewritten: D-8 recorded closed/non-blocking per `main`'s ruling, but
   `.agent-contract/design-fidelity-spec.md` makes the token binary (no
   per-story prose waiver), and 3 *other* already-known deltas still hold it
   red: **D-28** (deliberate muted-vs-accent-pink mismatch, D-19-compliant on
   purpose), **D-20** (CTA glyph clock-vs-calendar, `cupid_icons.dart` outside
   every phase this story owns), and **the unmatched round-6 set** (D-14–D-17,
   D-21–D-27 — recorded `DESIGN_SPEC_CONFLICT`/`CONTRACT_GAP`/icon
   substitution, no Design Ruling Log entry for any of them). Mobile-dev's own
   conclusion: this needs governance (a Design Ruling Log decision per finding,
   same D-18/D-19 precedent), not more mobile-dev work — it flagged residue
   in §1/§3/§8's preamble still saying "FAIL because D-8" in prose, super-
   seded by §9.3's banner but not physically rewritten (cosmetic, out of its
   instructed scope).
   Current story worktree HEAD: **`b65013d83433acc9f317b26f0b26aaa648b71d5b`**.
4j. **DONE** — round-8-slice reviewer (`Iris-QC-3`, `Mode: scoped-slice`,
   BaseHead `35703ff` (ancestor) · HEAD `b65013d`, review-report.md append
   committed as `61af307` via raw `git commit` in the worktree — boundary
   `commit_sha` still shows `b65013d` because `git-story-boundary.sh commit`
   found no pending diff after the manual commit; harmless, story stays
   `COMMITTED` not `DONE`). Independently read the full 202-line diff
   (mailbox report was truncated) before acting. New head `Outcome: BLOCKED`,
   code `DESIGN_SPEC_CONFLICT`, explicitly supersedes round-2's
   `PATCH_REQUIRED`. Applied rule 12e2 to split the 12 FAIL-holding reasons
   into 3 groups instead of one blanket verdict: **Group A** (4 genuine
   design-vs-AC conflicts, user anchor needed): A-1 (D-14+D-27, header
   overflow vs AC-14/16/17 explicit rows), A-2 (D-16, grouped-thousands
   display vs AC-6 edit-in-place), A-3 (D-23 half, pill position vs AC-13
   shared header), A-4 (D-21+D-26 half, block order). **Group B** (`B-1`,
   bundled `CONTRACT_GAP`, same shape as D-8: D-15/D-17/D-22/D-26-meta need
   new Drift columns; D-24 + D-25's insight strip are Scrum-Master-closable
   directly under D-8's own "card body text is sample content" principle,
   no user question needed). **Group C** (not governance gaps): R8-F-1 D-28
   is a plain in-scope patch (mobile-dev's §9.2 citation of D-19 doesn't
   hold — D-19 only forbids the line reading as a 2nd primary CTA, doesn't
   forbid accent color); R8-F-2 D-20 is a Scrum-Master scope/backlog call
   (`cupid_icons.dart` genuinely lacks an `event` token — question is
   expand-scope-vs-accept-substitute, not a design anchor). Also R8-D-1
   (non-blocking): D-8's ruling is under `req_master.md` `## Open Questions`
   (line 197), not `## Design Ruling Log` (lines 151-158) as both round-8
   mobile-dev and round-2 final-synthesis had mis-cited.
   **User decision gate presented and answered this session** (3
   `AskUserQuestion` rounds, verbatim choices, not paraphrased):
   - A-1: **Match design** (collapse status-change/delete/invited into the
     header overflow menu — needs AC-14/16/17 reworded).
   - A-2: **Match design** (add a display-formatting layer separate from the
     AC-6 edit buffer — new phase).
   - A-3: **Match design** (right-align the status pill on A8).
   - A-4: **Match design** (reorder A8 blocks to canvas order
     title→meta→note→chips→link→CTA).
   - B-1: **Expand scope** (add Drift columns for duration + time-of-day
     slot, migration, schemaVersion bump, patch locked `ux/uiux-spec.md`
     §8 — NOT deferred, unlike D-8's precedent).
   - Process gate (this checkpoint's own item c/d flagged Scrum Master as
     not supposed to dispatch `product-owner` mid-delivery, only
     `brainstormer` may, before delivery — a rule the D-1/D-2/D-3 and
     D-18/D-19 rulings already broke earlier in this same story): user
     explicitly chose **"repeat the precedent"** — dispatch Andy-PO
     mid-delivery again, same as those two prior rulings, as an explicit
     user-authorized bypass of the documented role-map restriction for
     this story.
4k. **DONE** — `Andy-PO` (spawned `Andy-PO-2`), `Mode: ac-patch`, on the
   **control checkout** (`main`), commit `2f41021` (125 insertions, 9
   deletions across 3 files). Independently verified via `git diff`
   extraction to `/tmp/po-diff-{reqmaster,ac,uiux}.txt` before trust — all
   three diffs read in full, match the self-report in substance. An
   unrelated pre-existing `.mcp.json` change (not PO's scope) was found via
   `git status --porcelain` alongside the 3 real files and deliberately
   excluded from the commit; it remains uncommitted on disk.
   - `req_master.md`: 5 new `## Design Ruling Log` rows (A-1..A-4, B-1,
     dated 2026-09-09), an evidence-source paragraph (3 reading warnings +
     explicit D-24/D-25 exclusion), and an updated D-8 `## Open Questions`
     row noting B-1 flips D-8's HOÃN half for `time_of_day_slot`.
   - `requirements.md`: AC-8 gains the 5 new optional B-1 fields
     (`duration`, `time_of_day_slot`, `note_keywords`, `link_source_label`,
     `link_saved_at`) plus the A-2 display-vs-edit-buffer rule (AC-6
     explicitly unchanged — split applies only to detail-screen display,
     not quick-create). AC-14, AC-16, AC-17, and BR-6 each gain an A-1 note
     moving that action into the header overflow "⋯" menu, with the
     one-tap-past-the-overflow invariant restated as BR-6's real gate.
     **Citation corrections from PO's own re-check** (recorded so no
     downstream reader re-litigates): A-1 anchors to UX §5 + BR-6, not
     AC-16 as originally framed; A-2 anchors to AC-8, not AC-6; A-3 found
     no existing shared-header text in either `requirements.md` or
     `uiux-spec.md` to anchor to (was mis-cited at AC-13 in item 4j above),
     so A-3 lives only in `uiux-spec.md` §5 — **AC-6 and AC-13 are
     unchanged**, confirmed by direct diff read.
   - `uiux-spec.md`: §2 documents the 5 new fields; §5 header reworked to
     icon + overflow "⋯" only (A-1), a closed alignment exception for A8's
     centered pill (A-3), and the A8 block reorder title→meta→note→chip→
     link→CTA (A-4); §8 grows a 5-field name/type/note table for Tech Lead
     (`duration_minutes` INTEGER NULL, `time_of_day_slot` TEXT NULL enum
     sáng/trưa/chiều/tối, `note_keywords` TEXT NULL, `link_source_label`
     TEXT NULL, `link_saved_at` INTEGER NULL), flagging schemaVersion bump
     + migration as required; non-blocking for STORY-002/004/006/007/008
     which already read the prior (smaller) contract.
   - PO's own story-organization call (`.claude/skills/product-owner/
     references/story-organization.md` L31-43, not yet independently
     re-verified by Scrum Master): **do not split into a new story — add
     phases to STORY-001's existing `coding-plan/master-plan.md`** instead,
     since this is one outcome ("card detail supports its full field set
     and safe transitions") delivered in more phases, not a second outcome.
   - Sequencing constraint PO flagged: the B-1 schema/migration phase must
     land **before** the A-4 reorder phase, since A-4's meta row renders
     `duration`/`time_of_day_slot`.
   - A-1 and A-4 must ship together (A-4's block reorder assumes A-1's
     header collapse already removed the lifecycle rows from the body).
4l. **DONE** — `Alan-Techlead`, story worktree, `Mode: coding-plan` (amend).
   Fixed the `GIT_BOUNDARY_STALE` double-check (persisted `base_head` vs
   actual worktree HEAD disagreed after an earlier raw commit) via
   `git-story-boundary.sh refresh-base --req
   REQ-016_solo_stage1_relationship_assistant --story STORY-001`, then
   dispatched with the refreshed `BaseHead: 61af307...`. Independently
   verified both returned diffs in full via `git diff -- <file> >
   /tmp/... && Read` before trusting/committing — matched the self-report
   exactly, no discrepancies. Committed `fb66046` (2 files, 364 insertions):
   - `coding-plan/master-plan.md` §10 **P11** (depends P8, 8 files): B-1's 5
     columns (`duration_minutes`, `time_of_day_slot`, `note_keywords`,
     `link_source_label`, `link_saved_at`), `TimeOfDaySlot` enum on the
     `ActivityType`/P7 pattern (ASCII wire values, lenient read),
     `schemaVersion` 3→4, additive-only `ALTER TABLE ADD COLUMN` migration
     (`deleteTable`/`createAll` forbidden), v2→v3→v4 chain must preserve
     existing rows.
   - §11 **P12** (depends P11, 5 files): A-2 display-formatted-vs-raw-edit
     -buffer split for price/distance/duration in a pure formatter/parser
     file; format only on focus-loss, never per-keystroke; AC-6/quick-
     capture unchanged.
   - §12 **P13** (depends P11+P12, 6 files): A-1 (header overflow "⋯" menu:
     status-change + delete + reply-flag moved off body, one tier, no
     nested menus), A-3 (memory-status pill right-align exception, A8
     only), A-4 (block reorder title→meta→note→chip→link→CTA) merged into
     one phase (same `_header`/body functions in one file). §12.2 records a
     known gap: uiux-spec §5 mentions a share icon but no share behavior
     exists anywhere in the codebase and invite-export is STORY-002 scope —
     P13 builds the overflow menu only, does not invent share behavior;
     flagged as a Scrum-Master/PO scope call if a later visual-fidelity
     pass flags the missing icon, not a mobile-dev decision. §12.5 folds in
     R8-F-1 (D-28 accent-color, in-file, not a phase) and R8-F-2 (D-20: 4
     real icon codepoints for `event`/`history`/`image`/`trash`, must be
     read from the shared font's cmap, never invented — stop-and-report if
     a codepoint can't be found, since `VISUAL_FIDELITY` is a binary gate).
   - `architecture/contract-summary.md` §3/§5 also patched (18 insertions):
     5 B-1 column rows + schemaVersion 3→4 migration note. This was outside
     the handoff's named output (`master-plan.md` only) but **accepted as
     in-scope**: independently spot-checked
     `mobile/test/core/database/activity_card_dao_test.dart:67`, confirmed
     it asserts the exact column allowlist by name against this file
     (`group('activity_cards schema (contract-summary.md §3 allowlist)')`),
     making P11 unimplementable as specified without the update — a
     genuine blocking dependency, not scope creep.
   - Execution order fixed: **P11 → P12 → P13**, all `Alex-Mobile-Dev`
     (single Flutter lane, no parallelism available for this story).
4n. **P11 DONE** — `Alex-Mobile-Dev` implemented §10 (schema/migration, 12
   code+test files + 2 evidence docs, commit `86e66dd`). Independently
   verified (diff-read every file, not just trusted the report):
   - 5 new nullable `activity_cards` columns (`duration_minutes`,
     `time_of_day_slot`+`TimeOfDaySlotConverter`, `note_keywords`,
     `link_source_label`, `link_saved_at`), schemaVersion 3→4, 22-column
     allowlist matches `contract-summary.md` §3 exactly.
   - **Deviation from §10.4 literal wording — ACCEPTED**: migration uses
     `if (from < 3) { createTable(...) } else if (from < 4) { addColumn(...)
     }` (mutually exclusive), not two independent `if`s. Reason: Drift's
     `Migrator.createTable()` always emits the table's CURRENT Dart-class
     schema, not a historical snapshot — so a v2-origin device taking
     `from < 3` already gets all 5 new columns via `createTable`; a
     separate unconditional `if (from < 4) { addColumn(...) }` would then
     throw "duplicate column name" for v2-origin devices (while working
     for genuine v3-origin devices). `else if` is the correct fix, not
     scope creep. Confirmed by re-running the new `v3 -> v4` and
     restructured `v2 -> v4` migration test groups myself — both pass.
   - Ran `flutter analyze lib test` myself (not just trusted the self-
     report): 191 issues, full-file scan confirmed zero `error •` severity
     lines — 0 new issues vs pre-P11 baseline (S9-F-6).
   - Ran `flutter test` myself on the 3 touched test files (+37 pass) and
     `activity_card_repository_test.dart` alone (+14 pass, all 4 new B-1
     tests included).
   - 3 collateral schemaVersion 3→4 assertion fixes in unrelated test
     files (`expense_dao_test.dart`, `timeline_dao_test.dart`,
     `activity_type_test.dart`) — required by the version bump, correct.
   **NEXT STEP**: refresh `Git-Boundary` via `git-story-boundary.sh
   refresh-base` (HEAD moved to `86e66dd`), then dispatch/continue
   `Alex-Mobile-Dev` for **P12** (§11 of master-plan.md, A-2
   formatter/parser phase, 5 files, depends only on P11 — now satisfied).
   D-20's icon-codepoint stop-rule applies to P13, not P11/P12. After P12's
   own analyze+test pass, dispatch P13 (§12, 6 files, depends P11+P12).
   Do not parallelize (single Flutter/mobile lane). After P13, route one
   final `Mode: scoped-slice` Reviewer pass on the full round-9 diff
   (round-8-slice reviewer's own recommendation).
4m. **DONE** — Scrum-Master-owned closures, `req_master.md` commit `ce5ab42`
   (2 new `## Design Ruling Log` rows, same format as D-1..D-19/A-1..A-4/
   B-1): D-24 (image-frame caption) + D-25 (cross-card derived count
   string + insight strip) closed directly under D-8's "card body text is
   sample content, not a field contract" principle — no new column/field/
   migration, not folded into B-1 (B-1 covers only the 5 fields with a
   real REQ-016 consumption mechanism). R8-F-2/D-20 icon-scope call
   decided **expand scope**: a small phase to look up the real
   `event`/`history`/`image`/`trash` codepoints from the shared icon
   font's cmap for `cupid_icons.dart`, instead of accepting a wrong
   substitute glyph (VISUAL_FIDELITY is binary — a wrong glyph would
   permanently red-flag the token). This phase rides along with the
   Tech Lead dispatch in item 4l below as an implementation action item,
   not a separate coding-plan phase of its own weight.
5. Deferred/non-blocking, after STORY-001 merges: a `foundation`-mode Tech
   Lead pass to amend `system_architecture_memory.md` for ADR-007/ADR-010,
   and document `ContentPackage<T>` in `contract-summary.md` §2 (S3-F-3).
   Also after merge: one PO touchpoint bundling R-1 (CTA acceptability),
   B-6 durable-record ownership, and M-3's D-5 doc-sync gap — all DEFERRED,
   none block merge, per round-2 final-synthesis.

## Do Not Re-read

- req_master.md, requirements/requirements.md, STORY-001/STORY-003
  story_master.md — already loaded/edited in full this session.
- `review/slice-1..7-*.md` — fully superseded by `review-report.md`.
- Full phase-by-phase P1-P10 history for either story — DONE, committed,
  captured by artifact pointers above, not restated here.
- `test-results.md` (89KB) — use `git diff`/`Read offset/limit`, never a
  full Read.
