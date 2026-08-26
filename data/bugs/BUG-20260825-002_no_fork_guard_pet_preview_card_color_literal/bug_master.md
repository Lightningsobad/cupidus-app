# Bug Master: BUG-20260825-002 No-Fork Guard Red — pet_preview_card.dart Color Literal

Status: PENDING
Severity: non-blocking to REQ-012/STORY-001 (pre-existing, confirmed identical
at BaseHead, out of that story's write scope); blocking to the shared
`no_fork_guard_test.dart` repo-wide gate whenever it is run
Source: Alex-Mobile-Dev (mobile-dev), REQ-012/STORY-001 `Mode:
mobile-implementation` run, reported as `BLOCKER: PREEXISTING_TEST_FAILURE`
Created: 2026-08-25
Linked Requirement: REQ-010_home_dashboard_deferred_scope_completion (origin
commit); surfaced during REQ-012_pairing_flow_qr_code_and_couple_types_screen
Linked Story: REQ-010/STORY-003 (origin, commit `11190e8`); surfaced by
REQ-012/STORY-001 and REQ-012/STORY-002 (same file/lines, confirmed
pre-existing at each story's own BaseHead independently)

## Report

Observed behavior:
`flutter test test/design_system/no_fork_guard_test.dart` is RED with 2
forbidden-pattern hits, both in a file untouched by the surfacing story:

- `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart:229`:
  forbidden pattern `"Colors."`
- `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart:230`:
  forbidden pattern `"Colors."`

Expected behavior:
`pet_preview_card.dart` resolves its glow/highlight color through the shared
`CupidColorTokens` design-token system, not a raw `Colors.*` literal, and the
no-fork guard test passes with 0 violations.

Reproduction steps or command:
```
cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter test test/design_system/no_fork_guard_test.dart --reporter compact
```

Failure anchors:
- Stack trace: N/A (guard assertion, not a crash)
- Failing test: `test/design_system/no_fork_guard_test.dart`, assertion "AC 4
  no-fork guard: features/app/core never fork on a raw color literal or
  Platform.is*/defaultTargetPlatform"
- Route/endpoint/component/job:
  `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart:229,230`
- Environment: mobile (Flutter)

Proof this is pre-existing, not introduced by the surfacing story:
- Confirmed at REQ-012/STORY-001 `BaseHead`
  `f329100d1ba5574f0ea969f8b812cad984a3ed8f`: `git diff --name-only` against
  that BaseHead lists exactly 4 changed files, none of which is
  `pet_preview_card.dart`; the file is byte-identical to BaseHead, so the
  guard fails identically there.
- `git log -1` on the file resolves to commit `11190e8` (`feat(REQ-010_home_
  dashboard_deferred_scope_completion/STORY-003)`), unrelated to REQ-012.
- The guard scans all of `lib/features`, `lib/app`, `lib/core`, so any branch
  that touches the mobile app and runs this guard will surface the same
  pre-existing red, regardless of that branch's own scope.

Why not fixed inline by the reporting agent:
No pure-white/no-fork-safe token exists in `CupidColorTokens` for this glow —
`colorOnAccent` and `colorText` both resolve to `#F7EEFB` in the dark theme,
so substituting either token would change the pet card's rendered pixels.
That is a design-system token decision on the REQ-010 pet surface, outside
REQ-012/STORY-001's declared write scope (4 files under
`pairing_choice_screen.dart` + design-system icons).

## Artifacts

- [ ] Diagnosis (Bug Fixer)
- [ ] Fix Evidence (Bug Fixer)
- [ ] Review (Reviewer)

## Routing Notes

- Current owner: scrum-master
- Next role: none required for STORY-001's branch (fixed in-scope); bug stays
  open only to track STORY-002's branch until it inherits the fix via
  integration merge
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md` (not created; not needed — see Resolution below)
- Fix Evidence: `fix-evidence.md` (not created; see STORY-001 commit instead)
- Review Report: `review/review-report.md` (not yet created; will be covered
  by STORY-001's own story review gate)
- Checkpoint: `scrum-master-checkpoint.md` (not yet created; tracked in
  `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/scrum-master-checkpoint.md`
  instead)
- Origin: REQ-012_pairing_flow_qr_code_and_couple_types_screen/STORY-001
  mobile-dev run
  (`data/runtime/parallel-runs/RUN-REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-001_pairing_method_choice_screen_redesign-mobile-dev.json`,
  status `COMPLETED`)
- Needs a design-system decision (which token, or a new additive token, covers
  this glow color without changing the pet card's rendered pixels) before a
  bug-fixer patch, not a mechanical token swap.
- Non-blocking to REQ-012/STORY-001 or REQ-012/STORY-002: each story's own
  review gate should treat this as a confirmed pre-existing, out-of-scope item.
  STORY-002 independently confirmed the same 2 violations RED at its own
  BaseHead `94600f32` (`Colors.white.withAlpha`), zero violations in STORY-002's
  own files, and continues to defer it (not fixed on that branch).

## Resolution (mixed disposition — one branch fixed, sibling branch still pre-fix)

- **STORY-001 branch: FIXED**, not deferred. Alex-Mobile-Dev's implementation
  commit `8c203dba543bae1b678338bfbab896df4203a9d2` adds an additive
  `CupidColorTokens.colorGlowCore = Color(0xFFFFFFFF)` token (both dark and
  light theme constructors, plus field/copyWith/lerp) and points
  `pet_preview_card.dart:229,230` at it instead of the raw `Colors.*` literal.
  The value is pixel-identical to the prior literal in every theme (127
  passing `test/features/pet/` tests, including the design-fidelity suite,
  confirm no rendered-pixel change). `no_fork_guard_test.dart` is GREEN on this
  branch.
- **STORY-002 branch: still PENDING/deferred.** Commit
  `76b25fdaa8aa100e740ca54d4ae419a52b604334` does not touch
  `pet_preview_card.dart` or `cupid_color_tokens.dart`; the guard is still RED
  on this branch at its own current head, tracked as a known, non-blocking,
  pre-existing deferred item in `deferred_items` of its run state.
- **Why `Status` stays `PENDING` rather than `DONE`:** the fix exists only on
  the STORY-001 story branch so far. It has not yet merged into
  `codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-integration` (or
  `main`). Once STORY-001 merges into the integration branch, STORY-002's own
  merge (or its own subsequent rebase) will inherit the fix, and STORY-002's
  branch-local deferral becomes moot without further mobile-dev work. Re-check
  `no_fork_guard_test.dart` on the integration branch after both stories merge;
  if green, close this bug as `DONE` (fixed-by-STORY-001, absorbed via merge)
  instead of routing it through the bug-fixer queue.
- No `bug-fixer` dispatch is required for this bug. The fix already exists;
  the remaining step is purely a Git merge-order consequence, tracked here so
  the review/merge gates do not mistake STORY-002's still-red guard run for a
  new regression.

## Blockers

- N/A
