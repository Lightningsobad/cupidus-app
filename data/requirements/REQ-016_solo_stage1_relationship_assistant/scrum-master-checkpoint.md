# Scrum Master Checkpoint: REQ-016 Solo Stage-1 relationship assistant

Updated: 2026-09-10 (session 798d014f — P15 committed (`68a6713`). Iris-QC
round-12 scoped-slice (`Outcome: PATCH_REQUIRED`) re-confirmed the whole
round-10 red set CLOSED but raised two new findings: G-2 (mobile-dev-owned:
`visual-fidelity-report.md`'s own head token/§13 prose were stale) and G-3
(Scrum-Master-owned: a third, previously-unaddressed A8 meta-*shape*
mismatch — canvas inline line vs. build's date-row + 2x2 grid). Scrum Master
closed G-3 with a new `req_master.md` Design Ruling Log row ("G-3 — hình dạng
khối meta trên A8", last row in the table), then dispatched a doc-only
mobile-dev P16 phase to fix G-2. **P16 DONE, independently verified, and
COMMITTED** (`f295444`, BaseHead refreshed from `68a6713`) —
`visual-fidelity-report.md` head token is now `VISUAL_FIDELITY: PASS`, both
D-1 mis-citations corrected, §13.3/§13.3a/§13.4/§13.5 rewritten, no code
changed, no recapture. **A repaired-boundary note**: at the start of this
segment `git-story-boundary.sh status` reported no boundary state for
STORY-001 (the JSON under `.git/ai-team-story-boundaries/` was missing/stale);
running `start` defaulted to an inline/control-checkout boundary, which was
WRONG for this story — the real work lives on the dedicated worktree/branch
`codex/REQ-016_solo_stage1_relationship_assistant-STORY-001`
(`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-001`),
confirmed by `git worktree list` and by `git show main:...vi_field_format.dart`
missing `formatLongViDate` entirely. Fixed via `repair-boundary --branch
codex/REQ-016_solo_stage1_relationship_assistant-STORY-001 --worktree
<path above> --merge-target codex/REQ-016_solo_stage1_relationship_assistant-integration
--story-class shared-foundation --depends-on NONE`. **If boundary `status`
ever again reports missing state for this story, use `repair-boundary` with
those exact flags — do NOT use `start --inline`, main has never held this
story's code.**
Next: dispatch Iris-QC round-13 scoped-slice on `visual-fidelity/` only (per
the round-12 reviewer's own §6 routing) to close the story `Outcome:`.
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
   **(c) DONE** — `Alex-Mobile-Dev` executed §13/P14, committed
   `6e41a35` (BaseHead now `6e41a35`, was `59d8564`). `editTimeOfDaySlot`
   + `TimeOfDaySlotPicker` (F-3); `noteKeywords` chip strip + input in
   `_noteBlock`, `linkSourceLabel`+`linkSavedAt` two-line provenance row
   in `_sourceLinkRow` (F-2), `linkSavedAt` derived single-write per
   §13.4. F-1: story-level R-2 run 4, real device, full v2→v3→v4
   migration observed (DB byte diff), unpaired→hub→detail, logcat 267
   lines/0 exception (`coding-plan/evidence/rule-12g-r2-run4/`). F-4:
   `visual-fidelity-report.md` §12.3 corrected token reason off closed
   D-8 onto the real open set (D-28/D-20/D-21/D-23/D-26 + new D-29). F-5:
   confirmed non-finding, no code touched.
   Independently verified by Scrum Master before commit (not just
   trusted): `flutter analyze lib test` 191/0 (delta 0 vs BaseHead,
   detached-worktree cross-check); `flutter test test/features/
   activity_cards` +192/~2/0 fail; exact 7-file WriteScope match
   (`git diff --stat`); full cubit+screen diff read against
   master-plan.md §13.2-§13.4 (editTimeOfDaySlot shape, §13.4 single-
   write linkSavedAt derivation, no touch of the disputed F-5 line);
   `test-results.md`/`review-report.md`/`visual-fidelity-report.md`
   diffs read in full and cross-checked against req_master.md's R9-F-6
   ruling (control checkout, line 205) and D-8 ruling (line 229); R-2
   evidence dir + logcat confirmed. No discrepancies found.
   BUG-20260908-001 widened same round: full baseline is 191 issues/0
   errors across ~15 directories (chat+dream_jar's original 39 is a
   confirmed subset); P14 adds 0 new issues (1 line shifted only).
   **(d) DONE** — Iris-QC-2 round-10 scoped-slice
   (`review/review-report.md` `## Slice ROUND-10-P14`, uncommitted in
   worktree, `Outcome: PATCH_REQUIRED`). F-1..F-5 all confirmed CLOSED
   permanently via reviewer's own independent `git grep`/direct-read
   verification (not self-report trust); F-6 confirmed already closed by
   R9-F-6. Only blocker: `VISUAL_FIDELITY` token red on G-1
   (D-28/D-20/D-21/D-23/D-26/D-29), with D-20+D-29 fixable-now and D-28 +
   A8-layout scope reserved for Scrum Master. **Do not re-review P11-P14
   code — closed permanently, round-10 said so explicitly.**

   Scrum Master ruled both reserved decisions in `req_master.md`
   `## Design Ruling Log` (control checkout, two new 2026-09-10 rows right
   after R9-F-6): **D-28 closed, build wins** (D-19's no-fake-affordance
   principle applies directly, no code change, no `DESIGN_SPEC_CONFLICT`
   label needed); **A8-layout (D-21/D-23/D-26) scheduled inside STORY-001**
   as a new phase, plus "design wins" for the previously-unruled
   title-vs-photo order half.

   **P15 Tech Lead plan: DONE** (`Alan-Techlead`, uncommitted, added §14 to
   `coding-plan/master-plan.md`, lines ~1348-1557). Found and corrected 3
   premises in my handoff, all evidenced: (a) A-3 (pill align) and A-4
   (block order) were **already implemented** at `6e41a35`
   (`screen:441/482`, `screen:372-391`) — only the photo-vs-title order was
   genuinely open, so P15's only A8-layout work is that one swap; (b) old
   §13.8's prohibition on touching CTA icon line 1208 rested on a
   misreading of D-18 (D-18 is about the CTA **label**, not icon) — replaced
   narrowly for P15/line-1208 only; (c) `formatShortViDate` takes `int?`
   epoch millis but `scheduledOn` is `String? YYYY-MM-DD` — spec'd a sibling
   `formatLongViDate(String?)` instead, and caught that the handoff's own
   example date (`2026-08-16`) is actually a Sunday, not Saturday. Also
   correctly declined to move the 2x2 meta grid (round-10's §3 suggestion) since
   that would silently reopen closed D-24/D-25/A-4 rulings — flagged as a
   pending-Scrum-Master-ruling item only if a future round still measures it
   as a deviation, not resolved now.

   **P15 mobile-dev implementation: DONE, verified, committed.**
   `Alex-Mobile-Dev` returned `MOBILE_COMPLETE: YES`; Scrum Master
   independently verified before trusting it: `git diff --stat 6e41a35 --
   mobile` = exactly 4 files/+189/-5 as reported; full `mobile/lib` and
   `mobile/test` diffs read in full and matched line-for-line against
   `master-plan.md` §14.2-§14.6 (D-20 icon swap at `:1208`, `formatLongViDate`
   sibling formatter, photo-before-title swap only inside `isReviewing`, all
   8 §14.6 test rules present); all 4 disputed calendar dates
   (2026-08-15=Sat, 2026-08-16=Sun, 2026-10-01=Thu, 2026-03-01=Sun)
   independently recomputed and confirmed the master-plan's own example date
   was wrong, matching both Tech Lead's and mobile-dev's correction; `flutter
   analyze` 191/0 (delta 0), `flutter test` +7 net pass, 14 pre-existing
   whole-tree failures re-measured unchanged (BaseHead-vs-P15 override
   diff), read `test-results.md`'s full P15 section (lines 2005-2108) with no
   discrepancy. Read `visual-fidelity-report.md` §13 (round 11, lines
   871-997) in full and eyeballed all 3 recaptured frames directly
   (`implemented-chi-tiet-the-moi-nghi-ra-ios.png`,
   `...-ghi-lai.png`, `implemented-the-da-thanh-ky-niem-ios.png`): confirmed
   photo->title->meta->2x2 grid->note->chips->link order on A8, `Thứ Năm
   1/10` date rendering with no ISO string, calendar CTA icon, correct pill
   placement, no tofu/clipped glyphs.

   **Found and fixed a citation error the report itself carried (§13.2):**
   its own claim "the label is the shared four-status vocabulary D-1 froze"
   is wrong — `req_master.md` Design Ruling Log's real D-1 (2026-09-07 row)
   is about the 5-filter-tab count, not any status label. Ruled anyway on the
   merits (build wins, real reason is the four canonical AC-14/AC-16 status
   names already used verbatim on the filter tabs) rather than block on the
   mis-citation.

   **Closed both remaining Scrum-Master-reserved residuals** (new
   `req_master.md` Design Ruling Log rows, both 2026-09-10, after the
   A8-layout-scope row): (1) **D-23 label** — build wins, "ĐÃ THÀNH KỶ NIỆM"
   stays, D-23 now fully closed both halves; (2) **D-26 meta-grid position**
   (§13.3/§14.5) — ruled NOT a real deviation: canvas's post-note "2 thẻ số"
   are the D-24/D-25-closed illustrative counters, a different UI element
   than the build's real pre-note 2x2 duration/time/distance/price grid that
   A-4 defines as "meta" and places before the note; A-4 stands unchanged, no
   code, no reopen.

   **COMMITTED**: `.claude/hooks/git-story-boundary.sh commit` ->
   `68a671310006032d1dad8c716b30207d122dd61e` (12 files, +962/-16, includes
   the new `phase-P15-d20-d29-a8-layout.md`). `refresh-base` ->
   BaseHead is now `68a6713...` (was `6e41a35`).

   **round-12 DONE** — Iris-QC round-12 scoped-slice
   (`review/review-report.md` `## Slice ROUND-12-P15`, `Outcome:
   PATCH_REQUIRED`). All six round-10 red-set items independently
   re-verified CLOSED. Two new findings: **G-2** [mobile-dev,
   artifact-staleness] — `visual-fidelity-report.md` head token/§13 prose
   stale relative to rulings already on record; **G-3** [scrum-master, new
   independent finding] — a third A8 meta comparison (canvas single inline
   line vs. build's date-row + 2x2 grid) never closed by any prior ruling.

   **G-3 CLOSED** — new `req_master.md` Design Ruling Log row "G-3 — hình
   dạng khối meta trên A8" (2026-09-10, last row in the table): the 2x2 grid
   form was already chosen by B-1 as the standard structured display for
   those four fields (sourced from canvas A4), A-4 places that cluster
   before the note on both A4/A8, and D-8 already rejected the `trời hanh`
   weather component (needs external API, against R-7) — so the grid form
   already standard on A4 supersedes A8's canvas inline line; not a new
   deviation, just the missing closing sentence.

   **G-2 CLOSED — P16 doc-only mobile-dev phase DONE, verified, committed.**
   `Alex-Mobile-Dev` corrected both D-1 mis-citations (§8.3, §13.2), rewrote
   §13.3 (D-26 residual) and added §13.3a (G-3), rewrote the §13.4 closure
   table and §13.5 verdict, and re-derived the head token FAIL->PASS. No code
   touched, no recapture (3 existing P15 frames remain valid HEAD evidence).
   Independently verified by Scrum Master before commit: read the new head
   token (line 1, `PASS`), §8.3 lines 425-443, and §13.2-§13.5/§13.3a lines
   900-1039 in full against the exact `req_master.md` ruling rows cited — no
   discrepancy. `git status --short`/`diff --stat` confirmed only
   `visual-fidelity-report.md` + the already-modified `review/review-
   report.md` (round-12, untouched by this phase) changed.
   **COMMITTED**: `.claude/hooks/git-story-boundary.sh commit` ->
   `f295444d108f3f69d2efd0e894a4908e01355777` (2 files, +272/-80).
   `refresh-base` -> BaseHead is now `f295444...` (was `68a6713`).

   **NEXT STEP: dispatch Iris-QC round-13 scoped-slice review**, scope
   limited to `visual-fidelity/` only (the round-12 reviewer's own §6
   routing step 3), to confirm the token reads PASS honestly and close the
   story `Outcome:` (expected `CLEAN` or `DEFERRED_ONLY`, since F-1..F-6
   stay closed as round-10 already confirmed permanently). Do not re-review
   P1-P15 code or F-1..F-6. BaseHead for the review diff is `f295444`.
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
