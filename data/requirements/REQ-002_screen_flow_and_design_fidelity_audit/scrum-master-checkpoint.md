# Scrum Master Checkpoint: REQ-002 Screen Flow Correction & Design Fidelity Audit

Updated: 2026-08-16T05:00Z
Mode: continue parallel (round-2 rework in progress — requirement integration
review Round 2 returned PATCH_REQUIRED: 2 blocking findings on `welcome`
filed as `BUG-20260816-001`, now unblocked (bug-fixer cap free) and next to
dispatch. Pre-existing bug `BUG-20260814-001` is DONE (`DEFERRED_ONLY`).
E-1/E-2 business decisions RESOLVED by the user and filed as new PENDING
requirements REQ-003/REQ-004, no longer blocking)
Wave scheduler: `data/runtime/parallel-scheduler.json`

## Ground Truth
Query `.claude/hooks/git-story-boundary.sh status --req <REQ_DIR> --story <STORY>`
before assuming story state; ground truth for story status is `req_master.md`.
Integration worktree:
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`,
branch `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`.

## Verified Story Status — 33/33 resolved, no open evidence gaps
- DONE (32): STORY-001 through STORY-022, STORY-024 through STORY-033.
- DEFERRED (1): STORY-023 (zodiac canvas not implemented; PO deferred).
- STORY-005 reached DONE this cycle (Reviewer round 4, `Outcome:
  DEFERRED_ONLY`), merged (`req_master.md` reflects DONE, matches
  `story_master.md`). No story-level gap remains; all further Round 2 work is
  integration-scope (bug queue), not story rework.

## Requirement Integration Review — Round 1: PATCH_REQUIRED (Iris-QC) — CLOSED
All Round 1 findings I-1..I-8 confirmed CLOSED by Round 2's own re-verification
(not by rereading Round 1 in isolation — Round 2 re-ran `flutter analyze`/
`flutter test` itself and got green/0-warnings, and confirmed the missing I-8
artifact now exists). Full I-1..I-8 disposition table is in
`integration-review/review-report.md` under "Round 1 Finding Disposition".
Do not re-litigate; treat as closed.

## Requirement Integration Review — Round 2: PATCH_REQUIRED (Iris-QC)
Committed in the integration worktree: `integration-review/review-report.md`
(commit `83d456f`, prepended `# Round 2` section, Round 1 preserved below as
superseded). `BaseHead` for Round 2 was `24d2673c`, HEAD reviewed `7b4f131`.
Scrum Master has read this report directly in full (not from teammate-summary
only).

Static/unit gates Round 2 re-ran itself (build/runtime NOT re-run — accepted
from DevOps's separate evidence, see below):
- `flutter analyze lib test`: PASS, 0 errors, 0 warnings (80 info-only).
- `flutter test`: PASS, `+1247 ~2`, 0 failures (Round 1 had 9 failures).

### Blocking findings — both `welcome` screen, mobile lane, one patch round
- **R2-1 (HIGH)**: `welcome_screen.dart:150-158` paints the backdrop with
  `colors.gradientHot.colors.reversed` — the two-stop *button* gradient, not
  the locked design's three-stop brand backdrop. Contrast failure on the
  app's first post-splash screen; upholds/confirms mobile-visual-audit's IF-1.
  STORY-004's WriteScope-based deferral (D13) expired once STORY-032/033
  merged `lib/design_system/`.
- **R2-2 (MEDIUM, new this round)**: `welcome_screen.dart:300-313` Google CTA
  (`_FilledCta`) has no leading-icon param, so no Google brand mark renders —
  same defect class STORY-005 BF-04 already fixed on `login`.
- **Filed as `BUG-20260816-001_welcome_screen_backdrop_and_google_cta_brand_mark`**
  (REPORTED, queued behind `BUG-20260814-001` — bug-fixer role cap is 1
  globally). Fix directly in the integration worktree, do not reopen
  STORY-004's gate (same pattern as Round 1's I-1..I-5 bugs). After fix:
  re-capture `implemented-welcome-*.png` only (not the full 31-screen audit)
  and compare against the design reference.

### Decisions required — raised to the user, NOT Reviewer's or Scrum Master's
to silently resolve (see `integration-review/review-report.md` "Decisions
Required — Not Mine To Make" for full detail):
- **E-1**: `app_shell.dart` ships ≤3 tab destinations vs. the locked design's
  5 (Nhà/Trò chuyện/Pet/Ví chung/Tôi), plus a pink circular FAB absent from
  the design canvas. One coupled decision (FAB is the sole account-hub entry;
  design's 5th tab "Tôi" is the same destination) — accept as intended
  divergence (record in `req_master.md` Deferred Follow-Up Items) or open a
  new app-shell/navigation story. No REQ-002 story owns this; `expenses_route.dart:14-19`
  already documents the 5-tab shell as a recognised, unlanded item.
- **E-2**: Design's `notifs` banner carries a "Do Not Disturb" sentence that
  `reminder_copy_guard_test.dart:18-22` (STORY-021's ADR-002 gate) explicitly
  bans as a literal, with a "do not delete this test to unblock a copy
  change" comment. Design and an approved ADR conflict — needs a PO/UX
  ruling on which source wins, not a wording that slips past the guard regex.
- **RESOLVED 2026-08-16** via `AskUserQuestion` (same pattern used for
  STORY-005's BF-01 biometric-login decision). E-1 → "Open a new
  app-shell/navigation story", now tracked as
  `REQ-003_app_shell_five_tab_navigation_and_fab_consolidation` (PENDING).
  E-2 → "Route to PO/UX for a copy ruling", now tracked as
  `REQ-004_notifications_dnd_banner_copy_reconciliation` (PENDING). Both
  recorded in `req_master.md` Deferred Follow-Up Items and in
  `master_requirements_list.md`. Neither blocks REQ-002 DONE — they are new,
  separately tracked requirements, not REQ-002 rework.

### Deferred findings (11) — already folded into `req_master.md`
`## Deferred Follow-Up Items` now carries IF-2..IF-8 plus the carried Tech
Lead P1-F2 item (Round 1 D-6). D-1 (analyzer info-only) and D-2/D-3/D-4
(per-story evidence-gap findings) need no action — non-blocking, out of scope
for this review. D-5 (this checkpoint being stale) is resolved by this very
update.

## Bug Registry — 7 REQ-002-linked bugs total
- `BUG-20260815-001` — DONE (`DEFERRED_ONLY`). Resolves Round 1 I-1.
- `BUG-20260815-002` — DONE (`DEFERRED_ONLY`). Resolves Round 1 I-3.
- `BUG-20260814-002` — DONE (`DEFERRED_ONLY`). Resolves Round 1 I-4.
- `BUG-20260814-003` — DONE (`DEFERRED_ONLY`). Resolves Round 1 I-5.
- `BUG-20260814-004` — DONE (`DEFERRED_ONLY`). Resolves Round 1 I-2 family.
- `BUG-20260814-001_chrome_header_breach_...` — **DONE** (`DEFERRED_ONLY`,
  0 blocking / 3 deferred findings D1-D3, non-blocking). Pre-existing, not one
  of Round 1's I-1..I-8 or Round 2's R2-1/R2-2. Fix commit `f726e8c`, review
  commit `10c05c3`, both in the integration worktree.
- `BUG-20260816-001_welcome_screen_backdrop_and_google_cta_brand_mark` —
  **REPORTED**, now unblocked (bug-fixer cap = 1 slot free). Covers Round 2's
  R2-1 + R2-2. **Must reach DONE before REQ-002 can be marked DONE.**

Per SKILL 12c: the requirement's `flutter test`/`flutter analyze` suite is
currently GREEN (Round 2 confirmed this itself) — the two remaining open
bugs are new/pre-existing defects, not suite regressions, but both still
block DONE per the artifact contract (a bug can be marked DONE only after
bugfix review CLEAN/DEFERRED_ONLY).

## Git state
- Integration branch synced to `main` this cycle (`sync-integration`,
  no conflicts) at `db4e796`.
- Round 2 evidence chain, all committed in the integration worktree in order:
  `b79f828` (DevOps integration-build-verification.md) →
  `7b4f131` (Mobile-Dev mobile-visual-audit.md + 31 screenshots) →
  `83d456f` (Iris-QC Round 2 review-report.md + scope-gate.md).
- Current integration worktree HEAD: `83d456f90a9d5fe34851b6b8efa194f58945040c`.
- **Do not attempt `land-integration` yet.** Two bugs still open + two user
  decisions still pending + a Round 3 (scoped) reviewer pass is required
  after the welcome-screen fix lands.

## Next Valid Step
1. DONE — `BUG-20260814-001` fixed (`f726e8c`) and reviewed `DEFERRED_ONLY`
   (`10c05c3`), marked DONE across all registry locations.
2. Dispatch `Justin-BugFixer` for `BUG-20260816-001` (welcome backdrop + Google CTA),
   same worktree, then its own compact bugfix review. Include the
   re-capture-and-compare step (Round 2 review "Required To Clear" item 3) as
   part of this bug's Fix Evidence, or as an immediate follow-up
   `Alex-Mobile-Dev` single-screen capture if the bug-fixer template does not
   cover visual re-capture itself.
3. DONE — E-1/E-2 answers collected and recorded (see above); new
   requirements REQ-003/REQ-004 filed as PENDING. No longer a REQ-002
   blocker.
4. After both bugs reach DONE/DEFERRED_ONLY and E-1/E-2 are recorded: dispatch
   a **Round 3** `Iris-QC` `requirement-integration-review`, scoped per Round
   2's own note — "Round 3 can be scoped to the welcome screen plus a re-run
   of the static gates; the rest of this round's evidence stays valid unless
   the branch moves materially." `BaseHead` for Round 3 must be Round 2's own
   review commit (`83d456f`), confirmed an ancestor of the new HEAD.
5. Only after Round 3 records exactly one `Outcome: CLEAN` or
   `Outcome: DEFERRED_ONLY` line (Integration Build & Runtime and mobile
   visual audit evidence already satisfied, no fresh DevOps/Mobile-Dev pass
   needed unless the branch moved materially beyond the welcome-screen fix):
   tear down story worktrees
   (`git-story-boundary.sh cleanup-requirement --req REQ-002_screen_flow_and_design_fidelity_audit`),
   `sync-integration` again if `main` moved further (re-verify build/runtime
   if it did), `land-integration`, THEN mark REQ-002 `DONE` in
   `data/requirements/master_requirements_list.md` and `req_master.md`, then
   re-run scheduler reconciliation + `.claude/hooks/list-releasable-agents.sh`
   before the final wave JSON.
6. Unresolved/deferred: stray worktree
   `story-REQ-002_screen_flow_and_design_fidelity_audit-SCOPE-B-RESCOPE`
   flagged by a prior `git-story-boundary.sh reconcile` as "kept (worktree not
   reclaimable)" — not referenced by any scheduler run; investigate at
   requirement worktree teardown (step 5) if `cleanup-requirement` refuses on
   it.

## Do Not Re-read
- The 33-story merge-SHA table (all DONE/merged, no longer relevant to
  routing).
- STORY-001 through STORY-033's individual `story_master.md`/review files —
  none has an open gap; Round 2 findings are all integration-scope, tracked
  in the bug registry instead.
- Round 1 integration-review narrative (I-1..I-8) — fully superseded, table
  above is the source of truth.
- Prior chat narrative about the Stop-hook `SCOPE_GATE_MISSING` retry Iris-QC
  hit while producing Round 2 — its RunState shows `status: COMPLETED` and
  the report/scope-gate are both present and valid; not a live blocker.
