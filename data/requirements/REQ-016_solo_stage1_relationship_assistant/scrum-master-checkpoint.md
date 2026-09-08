# Scrum Master Checkpoint: REQ-016 Solo Stage-1 relationship assistant

Updated: 2026-09-08 (session 798d014f, continue parallel wave — mobile-dev
round-8 evidence patch DONE and committed `b65013d`: FS2-F-2 (A8 stale
screenshot) CLOSED; FS2-F-1 partially closed — token stays `FAIL` on
purpose, now for 3 named real deltas (D-28, D-20, unmatched round-6 set
D-14–D-27) instead of the stale D-8 excuse, and per design-fidelity-spec
these likely need a `BLOCKED: DESIGN_SPEC_CONFLICT` user-anchor ruling,
not more mobile-dev work; next: dispatch one scoped-slice reviewer on the
round-8 diff to confirm that routing before asking the user).
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
4j. **NOT YET DISPATCHED — next step**: one `Mode: scoped-slice` reviewer
   (Tier 3, not full final-synthesis — per round-2's own recommendation, all
   code findings already closed with reviewer-run evidence) scoped to just
   the round-8 diff (`35703ff..b65013d`, 2 files). Explicitly ask it to rule
   on whether D-28/D-20/the round-6 set now correctly route
   `Outcome: BLOCKED: DESIGN_SPEC_CONFLICT` (a **user decision gate** —
   anchor design vs. implementation per finding, same shape as the D-1/D-2/
   D-3 and D-18/D-19 precedents) rather than another patch round, since
   mobile-dev's own diagnosis says these are governance gaps, not code
   defects. If the reviewer confirms `BLOCKED: DESIGN_SPEC_CONFLICT`, Scrum
   Master's next step is to stop and present the specific per-finding anchor
   choices to the user — do not keep dispatching mobile-dev patches against
   a token that formal spec forbids clearing without a ruling. If instead
   `CLEAN`/`DEFERRED_ONLY` on the head `Outcome:` line -> mark STORY-001
   `DONE` **inside the integration worktree**
   (`.ai-team-worktrees/cupid-apps/integration-REQ-016_solo_stage1_relationship_assistant`,
   not the control checkout — evidence guard needs the merged
   visual-fidelity report there), run `git-story-boundary.sh complete`, then
   `git-story-boundary.sh merge`, resolving the KNOWN MERGE COLLISION above
   directly and re-running both stories' migration tests against the
   combined result.
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
