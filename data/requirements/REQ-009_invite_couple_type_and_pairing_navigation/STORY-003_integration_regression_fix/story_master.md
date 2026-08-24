# STORY-003 Integration Regression Fix

> **Pipeline deviation, recorded deliberately.** This story did not go through
> the normal `product-owner -> ui-ux-designer -> tech-lead -> dev` pipeline. It
> is a Scrum-Master-identified integration regression fix, not new product
> scope: a full `flutter test --no-pub` run on the REQ-009 integration branch
> (after STORY-001 and STORY-002 were both merged) surfaced exactly one
> cross-story failure that neither story's own scoped verification could have
> caught. It is filed as a story only so the fix is traceable in the backlog
> like any other change. There are no acceptance criteria, UX spec, or coding
> plan for it.

- **Requirement:** REQ-009_invite_couple_type_and_pairing_navigation
- **Status:** IMPLEMENTED — awaiting requirement integration review
- **Role:** mobile-dev (implementation), scrum-master (Git orchestration)
- **Land path:** implemented and committed on a dedicated story branch off
  `main` (`codex/REQ-009_invite_couple_type_and_pairing_navigation-STORY-003_integration_regression_fix`),
  merged to `main`, then carried onto
  `codex/REQ-009_invite_couple_type_and_pairing_navigation-integration` via
  `git-story-boundary.sh sync-integration`. This detour (rather than a direct
  commit on the integration branch) was required because raw commits on
  `codex/*` ephemeral branches are guard-blocked
  (`guard-orphan-commit.sh [EPHEMERAL_BRANCH_COMMIT]`); all story commits must
  route through `git-story-boundary.sh`, whose `start` verb requires a clean
  target worktree and (for a brand-new story id) defaults to a fresh
  worktree/branch off `main` rather than reusing the integration worktree in
  place.
- **Date:** 2026-08-24

## Scope

Restore the single cross-story test regression introduced when STORY-001's
couple-type picker met STORY-002's pairing navigation on the integration
branch — one test, one test file, no production change.

## The fix

STORY-001 gave `InviteScreen._defaultInviteCubit` a GetIt-resolved
`AccountRepository` dependency for the couple-type fetch/save. The pre-existing
`mobile/test/features/expenses/pairing_gate_test.dart` reaches `InviteScreen`
through `PairingRequiredGate`'s CTA (which pushes `const InviteScreen()`, so it
cannot bypass the composition root) and registered only `PairingRepository` in
its GetIt fixture, so the screen threw
`Bad state: GetIt: Object/factory with type AccountRepository is not registered`.

`setupServiceLocator()` already registers `AccountRepository`
(`mobile/lib/core/di/service_locator.dart:122-124`), so the production eager
resolve is correct and the gap was purely in the test fixture. Fixed by
registering a `_NeverReadyAccountRepository` in that group's `setUp`, mirroring
the same file's existing `_NeverReadyPairingRepository` precedent.

Files changed:

- `mobile/test/features/expenses/pairing_gate_test.dart`

`mobile/lib/features/pairing/presentation/screens/invite_screen.dart` was in
write scope but intentionally left unchanged.

## Verification

Implemented and verified by Alex-Mobile-Dev-3 in the integration worktree
(`.ai-team-worktrees/cupid-apps/integration-REQ-009_invite_couple_type_and_pairing_navigation/mobile`);
independently re-verified by Scrum Master with the same commands after
re-applying the identical diff onto this story worktree (based on `main`,
where the same regression does not yet manifest because STORY-001/STORY-002
have not landed there, so this run is a clean-apply/analyze check, not a
regression reproduction):

| Command | Result |
| --- | --- |
| `flutter test --no-pub test/features/expenses/pairing_gate_test.dart` | PASS (5/5) |
| `flutter test --no-pub test/core/navigation test/features/pairing` | PASS (193/193) |
| `flutter test --no-pub test/features/expenses` | PASS (59/59) |
| `flutter analyze test/features/expenses/pairing_gate_test.dart` | No issues found |

Full unfiltered output and the diagnosis trail are in
`data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/integration-review/mobile-fix-notes.md`.
