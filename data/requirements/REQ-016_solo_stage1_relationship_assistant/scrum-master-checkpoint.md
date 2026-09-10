# Scrum Master Checkpoint: REQ-016 Solo Stage-1 relationship assistant

Updated: 2026-09-10 (session 798d014f — Iris-QC round-9 review returned
PATCH_REQUIRED (item 4q); F-6 closed direct (`986e753`); Tech Lead patched
plan for F-2/F-3/F-5/D-e (uncommitted in Worktree, disputed F-5 with
evidence); Alex-Mobile-Dev dispatched via SendMessage for P14 + F-1/F-4/F-5
evidence copy, awaiting result).
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
   `3`, no fix needed there.) STORY-001 has since bumped to schemaVersion 4
   (P11, B-1 columns) — the combined chain at merge is v2→v3(STORY-003 cols)
   →v4(B-1 cols), all additive `ALTER TABLE ADD COLUMN`.
2. **Constructor signature**: STORY-003's patch2 (`1c32341`, merged
   `69b3690`) added `BackupExclusion? excludeFromBackup` as a second
   positional `CupidDatabase` param. Reconcile against STORY-001's own edits
   (if any) and check `service_locator.dart` call sites on both sides.

Non-blocking: STORY-001 P5 and STORY-003 P5 both touch
`mobile/lib/l10n/app_vi.arb`/`app_en.arb` for different keys — don't collapse
their arb edits into one commit at merge.

## STORY-001 status (all round-by-round history superseded by artifacts — do not replay)

P1-P10 through round-8-slice review, the round-8 user decision gate
(A-1/A-2/A-3/A-4 = match design, B-1 = expand scope), the PO ac-patch, and
Tech Lead's P11/P12/P13 coding plan are all **DONE, COMMITTED, and fully
superseded by the current state below** — do not replay narrative; see
`review/review-report.md` for full history if ever needed.

**Do not trust a RunState `status` field without checking the actual
worktree diff first.** Wait for the real teammate mailbox/SubagentStop
notification, then verify `git status`/`git diff` matches WriteScope before
committing or trusting a completion marker.

## Next Step On Resume

1. STORY-003: DONE, merged. No further action.
2. STORY-001 P1-P10, S9, splash, A4-CTA-D18/D19, round-1/round-2/round-8
   final-syntheses, round-8-slice review (`BLOCKED: DESIGN_SPEC_CONFLICT`):
   all DONE, fully superseded. Key commits if ever cited: `880541d`,
   `dedd45b`, `3e840ae` (round-2 close, R-1/B-6/M-1/M-3/M-5/M-6 ruled
   DEFERRED), `61af307` (round-8-slice, raised A-1..A-4/B-1/R8-F-1/R8-F-2).
3. Round-8 user decision gate (3 `AskUserQuestion` rounds, answered,
   **do not re-ask, do not re-litigate**): A-1/A-2/A-3/A-4 = **match
   design**; B-1 = **expand scope** (5 new Drift columns + schemaVersion
   3→4). Recorded in `req_master.md` `## Design Ruling Log` (`2f41041` PO
   ac-patch on `main`, also patched `requirements.md`/`uiux-spec.md` — PO
   also ruled D-24/D-25 closable directly by SM under D-8's precedent, and
   flagged R8-F-2/D-20 as a SM expand-vs-accept-substitute scope call).
4. Tech Lead coding-plan phases for A-1..A-4/B-1 (`fb66046`): P11 (§10,
   B-1 5-col migration v3→v4), P12 (§11, A-2 display/buffer split), P13
   (§12, A-1+A-3+A-4 header/pill/block-order merge, bundling R8-F-1/R8-F-2).
   All three: **DONE**, see 4n/4o/4p below.
5. Deferred-to-post-merge, non-blocking (round-2 reviewer calls, do not
   re-open): R-1 (CTA acceptability under AC-11), B-6 durable-record half,
   M-1/M-3/M-5/M-6 (doc-sync/mis-citation gaps, incl. D-5). Folded into
   item 6's post-merge PO touchpoint below.

4m. **DONE** — D-24/D-25 closed direct (`req_master.md` `ce5ab42`, same
   D-8 no-field-without-consumption principle); R8-F-2/D-20 icon-scope
   decided expand-scope (rode with 4l's Tech Lead dispatch).
4n. **P11 DONE** (`86e66dd`) — B-1 5-col migration v3→v4, deliberate
   mutually-exclusive if/else-if (avoids Drift double-apply on v2
   devices). Verified myself: analyze 191/0, migration tests pass both
   paths.
4o. **P12 DONE** (`9107336`) — §11 A-2 display/buffer formatter
   (`vi_field_format.dart`). Bundled: missing duration stat cell added
   (1-row/3-col, viewport constraint); fixed `_withEdits` silently
   nulling all 5 B-1 cols on unrelated edits. Duration implemented as 3
   shapes (accepted §11.2 gap). Verified myself: analyze 191/0 (delta 0),
   +45 pass. Visual-fidelity recapture deferred to P13.
4p. **P13 DONE** (`59d8564`) — §12 A-1+A-3+A-4 merged: 3 trailing
   lifecycle rows moved into a 1-tier header overflow
   (`card_detail_overflow_menu.dart`, new); A8 pill right-align via
   conditional `Spacer()`; block order title→meta→note→chip→link→CTA,
   `_statGrid`→2x2 `_metaBlock`. Bundled R8-F-1 (accent color) + R8-F-2 (4
   cmap-confirmed D-20 icons: `event` 0xe878/`history` 0xe889/`image`
   0xe3f4/`delete` 0xe872). 12 files, 998(+)/132(-).
   3 accepted deviations, all measured not guessed: (a) `trash`→`delete`
   glyph (no cmap entry for `trash`); (b) ellipsis U+22EF→U+2026 (absent
   from both bundled fonts' cmaps, matches P4 tile's own overflow glyph);
   (c) 3rd overflow item opens the unmodified `_invitedBlock` sheet.
   Verified myself: analyze 191/0 (delta 0); full `activity_cards` folder
   175/2/0 — exact match to self-report. Every diff/new file read in full.
4q. **PATCH_REQUIRED** — Iris-QC round-9 scoped-slice (`review/review-
   report.md`), P11+P12+P13. D-8 confirmed CLOSED non-blocking
   (req_master.md:228); round-9 §11 mis-cited FAIL token's reason as
   D-8 — true reason is F-4, re-derive after F-2/F-3. 3 P13 deviations
   accepted. F-1 real-device v2→v4 smoke owed; F-2 noteKeywords/
   linkSourceLabel/linkSavedAt unrendered; F-3 no write path for
   `timeOfDaySlot` (B-1 field dead); F-4 token reason wrong, re-derive
   post-fix; F-5 event/history icons unwired at detail screen:1004
   (**disputed by Tech Lead, see below**); F-6 share icon closed direct
   by SM (`req_master.md` `986e753`, D-4/D-24/D-25, out of scope).
   Order: (a) F-6 [DONE] → (b) Tech Lead patches plan [DONE, uncommitted
   in Worktree] → (c) mobile-dev implements [DISPATCHED via SendMessage]
   → (d) final Reviewer pass on `visual-fidelity/`+`test-results.md`
   only [PENDING].
   **(b) DONE** — `Alan-Techlead@session-798d014f` added §13/P14 (lines
   1132-1346) to `coding-plan/master-plan.md`, uncommitted: F-3
   `editTimeOfDaySlot` spec mirroring `editDurationMinutes`; F-2
   `noteKeywords` chips + `linkSourceLabel`/`linkSavedAt` provenance row,
   both inside existing A-4 blocks; §13.4 `linkSavedAt` derivation rule;
   7 tests/7 files/prohibitions/closing conditions. §10.4 (D-e) wording
   patched, migration code confirmed correct, no code change. **F-5
   disputed with evidence (§13.5)**: line 1004 is the unrelated primary-
   CTA icon; all 4 P13 icons already correctly wired at their §12.5-
   assigned call sites — changing line 1004 would regress the D-18 CTA
   icon pair. Also flagged, not fixed: §10's "uiux-spec.md mục 8"
   citation for B-1 fields is wrong (real source: req_master.md Design
   Ruling Log + contract-summary.md:79-84).
   **(c) DISPATCHED** — `Alex-Mobile-Dev` via `SendMessage`
   (`msg_id 5370e892`): execute §13/P14 (F-2/F-3), copy F-5 evidence into
   `test-results.md` (no code change), correct F-4's token reason in
   `visual-fidelity-report.md` §11, run F-1/R-2 real-device startup
   smoke (§6 lines 161-186, 4 conditions) or return a named blocker.
   **NEXT STEP**: await Alex-Mobile-Dev's result; independently verify
   before commit (analyze/test + each §13.6 rule + R-2 evidence), then
   `git-story-boundary.sh commit` + `refresh-base`, update checkpoint,
   then dispatch Iris-QC for the final scoped-slice pass on
   `visual-fidelity/`+`test-results.md` only.
6. Deferred, after merge only: Tech Lead `foundation` pass for
   ADR-007/ADR-010 + `ContentPackage<T>` doc (S3-F-3); one PO touchpoint
   for R-1/B-6/M-1/M-3/M-5/M-6 doc-sync — none block merge.

## Do Not Re-read

- req_master.md, requirements/requirements.md, STORY-001/STORY-003
  story_master.md — already loaded/edited in full this session.
- `review/slice-1..7-*.md` — fully superseded by `review-report.md`.
- Full phase-by-phase P1-P13 history for either story — DONE, committed,
  captured by artifact pointers above, not restated here.
- `test-results.md` (89KB) — use `git diff`/`Read offset/limit`, never a
  full Read.
- `coding-plan/master-plan.md` §1-§12 — already implemented; only §13
  (P14) and §6 (lines 161-209, R-2 gate) are live this round.
