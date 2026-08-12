# Review Report: STORY-021 Privacy/Notifications Capability (RED-PATCH)

Mode: compact-story-review
BaseHead: c7caf9ff1a58ce7aeede8a654e5a9f3b030b15c8

## Scope Gate

- Touched files: exactly 8, all under `mobile/` — matches the handoff's
  declared list and `coding-plan/test-results.md` § Write scope. No file
  outside the declared write scope.
- OQ discipline (load-bearing item): `architecture/solution.md` § AC3
  Feasibility Finding verifies against current source that the backend has
  no notification module/field (16 modules enumerated, none notification;
  `User` entity's only writable behavior flag is `isGhostModeEnabled`,
  already claimed by AC1/privacy) and that A1 forbids creating one. AC2
  (this story's notification AC) is correctly closed as "mobile
  device-local settings, done correctly" with **zero code change** — no new
  backend module was invented, and the finding explicitly routes any future
  server-side notification requirement back through `req_master.md` §Open
  Question Triage rather than pre-deciding it. This matches the story's
  Open Item instruction exactly.
- In/Out of Scope respected: no edits under `mobile/lib/features/chat/`
  (confirmed zero diff), no edits to `notification_settings_screen.dart`/
  cubit/store or their three test files (confirmed zero diff), no new
  backend endpoint/field/module, no privacy field beyond
  `isGhostModeEnabled`, no "Export all my data" affordance added.

## Risk-Surface Gates (architecture/solution.md §4)

1. **Two client writers of `isGhostModeEnabled`** — CLEAR. The new toggle
   (`_GhostModeToggleRowState._handleTap`,
   `privacy_screen.dart`) calls only
   `widget.accountRepository.updateProfile(isGhostModeEnabled: newValue)`.
   `git diff --name-only` against BaseHead shows zero files under
   `mobile/lib/features/chat/`. `ghost_cubit.dart`/`ChatPartnerStore` are
   untouched and continue to re-read on their own lifecycle, as designed.
2. **AC2/device-local notification non-regression** — CLEAR.
   `notification_settings_screen_test.dart`,
   `notification_settings_cubit_test.dart`,
   `notification_preferences_store_test.dart` are absent from the changed-file
   list (unmodified) and `coding-plan/test-results.md` records them passing
   1/1, 17/17, 4/4 respectively as part of the same `flutter test
   test/features/account/` run (85/85 total, 0 failed).
3. **No admin/data-export affordance** — CLEAR.
   `privacy_screen_test.dart` retains/extends `find.textContaining('Export'),
   findsNothing` in the rewritten "renders no export button and shows the
   ghost-mode privacy control (DEC-5)" test; visual capture confirms no
   Export UI on screen.
4. **Static tier cards must not hide behind a spinner** — CLEAR. In
   `privacy_screen.dart`, `BlocBuilder<AccountCubit, AccountState>` is scoped
   only to `_GhostModeToggleRow` inside `_PrivacyControlsSection`; the
   section's own label `Text` and all three `_TierCard`s render outside any
   `BlocBuilder`. The `renders the three tier cards` widget test asserts
   tier-1/tier-2 text immediately after `pumpWidget` (before
   `pumpAndSettle`), i.e. while `AccountCubit` is still in its initial
   loading state — consistent with the spec.

## AC-by-AC Evidence

- **AC1 (privacy, STORY-016 AC2 label) — view and change `isGhostModeEnabled`
  via the existing `PATCH /users/me` contract.** `AccountRepository
  .updateProfile()` gained one passthrough `isGhostModeEnabled` parameter
  (`account_repository.dart`, +2 lines) forwarded to the already-existing
  `UpdateProfileDto.isGhostModeEnabled` field (generated client untouched,
  consistent with A1). Widget tests cover on/initial-load state, off state,
  load-error inert+caption state, optimistic flip + PATCH-success apply, and
  PATCH-failure rollback + snackbar — all match `ux/uiux-spec.md` §4 state
  machine exactly (inert-on-unknown-state fail-safe, no queued taps, silent
  success, rollback + `privacy_controls_update_error` on failure). Unit test
  confirms the repository sends `{'isGhostModeEnabled': false}` when passed
  and omits the key when a different call passes only `displayName` —
  correct passthrough semantics.
- **AC2 (notifications, STORY-016 AC3 label) — closes as device-local,
  ruled and verified above.** No code change; existing 7-row/3-group
  `NotificationSettingsCubit`/`NotificationPreferencesStore` flow left
  intact and non-regressed per gate 2 above.
- **AC3 (no admin/data-export regression) — CLEAR**, per gate 3 above.

## UX Fidelity

`ux/uiux-spec.md` §2 (placement between Level 1/Level 2), §3 (section label
"TÙY CHỈNH"/"CONTROLS", title/subtitle copy, `_TogglePill` shape reused, not
a Material `Switch`), §5 (state-aware `Semantics(button: true, label: ...)`
inside `ConstrainedBox(tapTarget)`) all match the shipped code and the
`implemented-privacy-emulator-5554.png` capture (viewed directly): the
"TÙY CHỈNH" card sits between LEVEL 1 and LEVEL 2, pill shown on, correct
Vietnamese copy, no Export affordance anywhere on screen. `main_preview.dart`
change (`_buildPrivacy` now injects `getIt<AccountRepository>()`) is the
minimal call-site fix required by the new constructor signature and matches
`architecture/solution.md` Key Discovery #2 (provider-scoping fix forced on
`me_screen.dart`/`main_preview.dart`).

## Test/Build Evidence

`coding-plan/test-results.md`: `flutter analyze` on the 6 changed source/test
files — no issues; `flutter test test/features/account/` — 85 passed, 0
failed, including the four unmodified AC2/regression files. No
`flutter build`/runtime-startup gate applies (no config/env change; per
handoff, mobile unit/widget + analyze evidence is the required tier for this
story).

## Visual Fidelity

`visual-fidelity-report.md`: `VISUAL_FIDELITY: PASS`, real authenticated
session (Firebase login + live `GET/PATCH /users/me`, not a mocked fixture).
The report's note about 8 additional unaccounted `implemented-privacy-*.png`
files (earlier timestamps, attributed to separate duplicate/parallel
mobile-dev activity this cycle) is accepted as surplus, non-authoritative
evidence per the handoff's framing — the report's own scoped claim covers
only `implemented-privacy-emulator-5554.png`, which was independently viewed
and matches the spec.

## Findings

None blocking. No deferred items.

## Recommendation

Approve. Story-scoped OQ ruling (AC2 backend-contract infeasibility) was
correctly respected with no unauthorized backend change; all four
architecture-declared risk-surface gates hold; regression, UX, and test
evidence are consistent and verified against source.

Outcome: CLEAN
