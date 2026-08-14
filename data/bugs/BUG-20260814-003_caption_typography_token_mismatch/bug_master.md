# Bug Master: BUG-20260814-003 Caption Typography Token Mismatch (Expected 13 / Actual 11.5)

Status: DONE
Severity: blocking (reconfirmed and broadened by REQ-002 requirement
integration review finding I-5; part of the RED `flutter test` suite that
must be fixed before DEFERRED_ONLY/CLEAN is possible per SKILL 12c — the
earlier "accepted baseline, not blocking" disposition was a per-story review
exception and does not survive requirement-level integration review)
— fixed, one shared root cause confirmed (not assumed): `caption.fontSize`
drifted `13`→`11.5` in STORY-033 (`bf01450`, "Delta 2"); the Love Pet
eyebrow's `letterSpacing` is derived from that same field
(`0.05 × fontSize`), so both drifts were one token. Token restored to `13`;
the 11.5px inline-helper role STORY-033 depended on now states its own size
at its 2 consumers instead of borrowing the shared token, preserving
STORY-033's AC3.

Report corrections (evidence-backed, do not change the fix):
1. The "muted-alpha 0.65→0.575" drift is not an alpha — it is derived
   `letterSpacing` (`0.05 × caption.fontSize`). No `0.575`/`0.65` literal
   exists anywhere in `mobile/lib`.
2. It was NOT uncovered — `pet_design_fidelity_test.dart:150` already
   asserted it and was RED. 4 RED assertions total, not 3 + 1 uncovered.
3. The waiting-screen anchor is at `waiting_screen_design_fidelity_test.dart:188`,
   not `:238` (shifted by BUG-20260815-002's merged patch).
Source: REQ-002 STORY-002 round-3 audit (originally accepted as pre-existing
baseline across multiple stories); blast radius widened and reconfirmed RED
by Iris-QC's REQ-002 requirement integration review (finding I-5)
Created: 2026-08-14
Linked Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Linked Story: cross-story (caption typography token, owner not yet confirmed)

## Report

Observed behavior:
Three design-fidelity tests each assert a caption font size of `13` but
observe `11.5` at the same shared root cause (caption typography token).
Finding I-5 (requirement integration review) confirms this same root cause
also covers the login caption and additionally surfaces a SECOND, previously
uncovered drift on the same shared token family: the muted-alpha value used
by the Love Pet eyebrow has drifted `0.65` → `0.575`. Both drifts trace to the
same shared token surface, `mobile/lib/design_system`, touched across 14
commits spanning 14 different REQ-002 stories — this is a widely shared
design-system regression, not an isolated per-screen issue.

Expected behavior:
Rendered caption text should match the expected typography token size (`13`)
on every screen that uses it (including login). The Love Pet eyebrow's muted
alpha should read `0.65`, not the drifted `0.575`.

Reproduction steps or command:
Not run by Scrum Master (intake only). Candidate:
```
cd mobile
flutter test test/features/auth/login_screen_test.dart
flutter test test/features/pairing/waiting_screen_design_fidelity_test.dart
flutter test test/features/pairing/joincode_screen_design_test.dart
```
(paths approximate; bug-fixer to confirm exact file locations via
query-first reading, and to locate the exact test(s) — if any — covering the
Love Pet eyebrow muted-alpha drift, which finding I-5 states was previously
uncovered by any assertion.)

Failure anchors:
- Stack trace: N/A (design-fidelity assertion mismatch)
- Failing test:
  - `login_screen_test.dart:91`
  - `waiting_screen_design_fidelity_test.dart:238`
  - `joincode_screen_design_test.dart:107`
- Uncovered (no assertion yet, per I-5): Love Pet eyebrow muted-alpha
  `0.65` → `0.575` drift
- Route/endpoint/component/job: caption typography token (shared);
  `mobile/lib/design_system` (shared token surface, 14 commits / 14 stories)
- Environment: mobile (Flutter)

## Artifacts

- [x] Diagnosis (Bug Fixer)
- [x] Fix Evidence (Bug Fixer)
- [x] Review (Reviewer)

## Bugfix Review Verdict (Iris-QC)

Outcome: DEFERRED_ONLY. Blocking findings: 0. Deferred findings: 4.
`review/review-report.md` (integration worktree). All 4 load-bearing fix
claims were independently re-derived from source/git history, not accepted on
trust, and all 4 CONFIRMED (shared root cause via `pet_reactions_card.dart:41`
`0.05 * caption.fontSize`; `pet_design_fidelity_test.dart:150` pre-existed the
break per `git blame` 2026-08-13 vs. break 2026-08-14; anchor `:188` confirmed;
STORY-033 AC3 confirmed preserved, new test non-tautological). Reviewer reran
Original Failure Recheck and Static Analysis gates itself (both matched
`fix-evidence.md` exactly) plus the 2 new regression tests; accepted Build /
Runtime Startup / full-suite Regression from recorded evidence under rule 18
(current, specific, uncontradicted, registry-backed), stated explicitly.

Deferred findings (non-blocking, for future triage — not creating new bug rows
now per standing policy of reserving that for live blocking defects):
- D-1: STORY-033's merged `visual-fidelity-report.md` AC3 PASS for
  `notifs`/`alarm` was certified at caption=11.5 and is now stale evidence
  (both screens consume the token, 2 and 5 sites); non-blocking because 13 is
  the long-shipped pre-2026-08-14 value, matches `uiux-spec.md` §4, and
  STORY-033's own call-site sweep found no layout keyed to 13px. Re-validate at
  the REQ-002 requirement integration `mobile-visual-audit.md`.
- D-2: confirms F-1/F-2/F-3 are correctly deferred (STORY-033's own flagged
  role-split follow-up); recommends one future bug covering the small-text
  scale as a whole, scoped to include D-1 and D-3.
- D-3: `pet_design_fidelity_test.dart:150`'s `0.65` transcribes the token, not
  the canvas (canvas eyebrow is 12px / 0.6); valid regression guard, not an
  independent design check — same follow-up bucket as D-2.
- D-4: runtime-registry launcher-class defect independently confirmed against
  `AndroidManifest.xml:13` (namespace vs. applicationId mismatch); correctly
  left unchanged (outside write scope); route to DevOps.

## Not-In-Scope Findings (for Scrum Master triage, not fixed here)

- F-1/F-2/F-3 (diagnosis.md): 3 pre-existing, non-RED design-source deltas on
  the same `caption` token (Love Pet eyebrow family 12px vs 13px, field
  labels 11px, avatar crop hint 12.5px) — this is STORY-033's own flagged
  small-text role-split follow-up. Reviewer independently confirmed these as
  correctly deferred (D-2/D-3) and recommends one future bug covering the
  small-text scale as a whole, scoped to also include D-1 (stale STORY-033
  visual-fidelity evidence); not created now (no live blocking defect).
- Runtime registry defect (fix-evidence.md, independently reconfirmed by
  Reviewer as D-4): `runtime-command-registry.json` `mobile-app` start command
  targets `com.snapsofts.cupid/.MainActivity`, which fails (`Error type 3`);
  the real launcher is `com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`.
  Outside bug-fixer's write scope; route to DevOps as a future fix, not
  created as a bug now (registry mismatch, not a blocking defect for this
  requirement).

## Routing Notes

- Current owner: scrum-master
- Next role: none — DONE
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md`
- Fix Evidence: `fix-evidence.md`
- Review Report: `review/review-report.md`
- Checkpoint: `scrum-master-checkpoint.md`
- Origin checkpoint: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/scrum-master-checkpoint.md` § Cross-Story / Infra Findings
- Note: all 3 failure instances were accepted as a pre-existing baseline during
  REQ-002 story review gates (not a regression). That per-story acceptance is
  superseded at requirement level: Iris-QC's requirement integration review
  (`Outcome: PATCH_REQUIRED`, finding I-5) treats the RED `flutter test` suite
  as the primary proof gate under SKILL 12c, so this bug is now blocking
  REQ-002 DONE, not a low-urgency follow-up.

## Blockers

- N/A
