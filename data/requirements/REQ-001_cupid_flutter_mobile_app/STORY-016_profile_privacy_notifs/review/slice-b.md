# STORY-016 Review — Slice B: account-presentation (P2/P4/P5-presentation/P6)

Reviewer: Iris-QC
RunId: RUN-REQ-001_cupid_flutter_mobile_app-STORY-016-reviewer-sliceB
BaseHead (declared): 47e7fe9a50c6693697e4fb9bb8b97b7cf0e22001
Worktree HEAD at review time: d5eee1feaa6e2b992ba9ce962399f9d03bc0496d

Note on baseline: the declared `BaseHead` is the commit that itself lands P5 +
P6 (`47e7fe9`), so `git diff 47e7fe9a50c6693697e4fb9bb8b97b7cf0e22001` shows no
implementation content (only `review/slice-a.md` and `story_master.md`
changes made after that commit). This slice's in-scope files were therefore
reviewed by reading their current, static content in the worktree rather than
from a diff — the phase history (`git log`) confirms all P2/P4/P5/P6 work
predates `BaseHead` and is not part of any later, unreviewed change.

Scope reviewed:
- `mobile/lib/features/account/presentation/account_cubit.dart`
- `mobile/lib/features/account/presentation/profile_edit_cubit.dart`
- `mobile/lib/features/account/presentation/screens/me_screen.dart`
- `mobile/lib/features/account/presentation/screens/profile_edit_screen.dart`
- `mobile/lib/core/navigation/app_shell.dart` (P2 entry-point wiring)
- `mobile/lib/features/account/presentation/screens/privacy_screen.dart` (P4)
- `mobile/lib/features/account/presentation/notification_settings_cubit.dart` (P5 presentation)
- `mobile/lib/features/account/presentation/screens/notification_settings_screen.dart` (P5 presentation)
- `mobile/lib/l10n/arb/app_en.arb`, `app_vi.arb` (content/copy check only — key-set parity already verified whole-file in slice-a)
- `mobile/test/features/account/presentation/**` (all cubit + widget tests for the above)
- `coding-plan/master-plan.md` §6.1/§6.2/§8 (P6 verification/audit evidence — no separate `test-results.md` exists; §8 Result Log is the evidence record)

Not re-reviewed (already PASS in `review/slice-a.md`): P1 domain/data files,
`notification_preferences_store.dart` (P5 data layer), DI registration lines
for those, and whole-file ARB key-set parity.

## 1. AC1 — profile view/edit reachability and behavior (P2)

**PASS**

- `AppShell` (`mobile/lib/core/navigation/app_shell.dart:20-26`) wires a
  single FAB entry point to `MeScreen`, matching DEC-4 ("wires exactly one
  entry point ... without building the 5-tab shell").
- `MeScreen` → `_ProfileSummaryCard.onTap` pushes `ProfileEditScreen` and
  applies the returned profile via `AccountCubit.applyUpdated` on pop
  (`me_screen.dart:52-64`), avoiding an extra `GET /users/me` round trip as
  documented.
- `ProfileEditCubit.submit()` correctly gates on `isDirty`, validates name
  non-empty / DOB required, and sends `birthday`+`zodiacSign` together or not
  at all (`profile_edit_cubit.dart:107-146`) — matches master-plan.md §6.2 P2
  and is exercised by `profile_edit_cubit_test.dart` (dirty-gating,
  validation, partial-PATCH coupling all present and passing by inspection).
- Avatar renders read-only from `photoUrl`, no camera-badge affordance is
  present (`profile_edit_screen.dart:129-144`) — consistent with DEC-1
  (avatar picker deferred to P3/off critical path).
- `SignOutAction` is placed unmodified, only when `authRepository != null`
  (`me_screen.dart:133-137`), matching the documented rationale that no
  concrete `AuthRepository` is constructed yet anywhere in production code.
- Widget tests (`me_screen_test.dart`, `profile_edit_screen_test.dart`) cover
  loading/loaded/failed states, field population, Save dirty-gating, and the
  inline name-required error — matching the P2 phase's declared test scope.

## 2. AC2 — privacy settings, view-only (P4)

**PASS on content; see Finding F-1 below on reachability**

- `PrivacyScreen` (`privacy_screen.dart`) renders exactly three static tier
  cards with no `Switch`, no PATCH call, no `isGhostModeEnabled` reference,
  and no export affordance. Verified directly in source (no interactive
  widgets besides the parent `Scaffold`/back action) and by
  `privacy_screen_test.dart`'s explicit `find.byType(Switch), findsNothing`
  and `find.textContaining('Export'), findsNothing` assertions — matches
  DEC-3 and DEC-5 exactly.
- Copy/tags in both ARB files match the design source per the Result Log
  (§8 P4) and contain no "Controls" or ghost-mode string.

## 3. AC3 — notification settings, device-local (P5 presentation layer)

**PASS on content; see Finding F-1 below on reachability**

- `NotificationSettingsCubit` (`notification_settings_cubit.dart`) only calls
  `_store.load()` / `_store.setEnabled()`; no `Dio`/`CupidApi`/network import
  anywhere in this file or in `notification_settings_screen.dart` — DEC-2
  ("no network call of any kind") holds.
- `notification_settings_screen.dart` renders 7 rows across exactly 3 groups
  (CRITICAL: Synced Alarm, Emoji Storm; ENGAGEMENT: Vibe Check, Bun needs you,
  Bae is typing; INFO: Dream Jar milestone, Love Timeline) — matches the
  Result Log's row list and `notifs_group_*`/`notifs_row_*` ARB keys.
- `_CapBanner` renders `l10n.notifs_cap_banner` only. Confirmed directly in
  both ARB files: `"notifs_cap_banner": "Max 15 pushes/day."` (en) /
  `"Tối đa 15 thông báo/ngày."` (vi) — no "Only Synced Alarm may break DND"
  clause present anywhere in either file. DEC-6 holds.
- `notification_settings_cubit_test.dart` and
  `notification_settings_screen_test.dart` cover loaded-defaults, `setEnabled`
  flip+persist, the 7-rows-in-3-groups render, the DND-bypass-clause-absent
  assertion, and tap-to-toggle — matching the P5 phase's declared test scope.

## 4. AC4 — exclusion audit (P6)

**PASS**

- Re-read `cupid_profile.dart` directly: the only `role`/`admin` occurrence is
  the P1 doc comment explaining the field is deliberately *not* mapped
  ("Deliberately excludes `role`: it is an admin-only field..."), not a
  functional surface — matches the P6 Result Log's own audit finding.
- `me_screen.dart` menu has exactly four rows (privacy, notifications, typing
  ghost, love contract); no Digital Divorce row. `privacy_screen.dart` has no
  export button. No admin surface in any reviewed screen.
- `coding-plan/master-plan.md` §8 Result Log records `flutter analyze` clean
  (17 pre-existing unrelated info lints only) and `flutter test` 194/194
  passing, including `arb_parity_test.dart` and `no_fork_guard_test.dart`, and
  a successful `flutter build apk --debug`.

### Tooling note

`flutter` is not available on this review host/worktree PATH (confirmed:
`which flutter` / `which dart` both fail), matching slice-a's finding on the
same host. This review is static/source-level only for this slice too; it
relies on `coding-plan/master-plan.md` §8's Result Log entries as the
independent record of `flutter analyze`/`flutter test`/`flutter build`
results, which were produced by Mobile Developer, not re-run here.

## Finding F-1 (blocking): AC2/AC3 screens are not reachable from any user-facing navigation path

**Severity: functional gap, PATCH_REQUIRED**

`PrivacyScreen` and `NotificationSettingsScreen` are fully implemented and
unit/widget-tested in isolation, but neither is wired into any navigation
route a real user could reach:

- `me_screen.dart`'s `_MenuRow` widget (`me_screen.dart:235-254`) has no
  `onTap` field or parameter at all — it is purely a label + trailing chevron
  `ListTile`. All four menu rows (privacy, notifications, typing ghost, love
  contract) render as visually identical, permanently inert forward links.
- For "Typing Ghost" and "Love Contract" this is correct and intentional —
  they are owned by other stories (STORY-008 etc.) and are documented as
  deliberately forward-link-only (`me_screen.dart:230-234`, `ux/uiux-spec.md`
  §6).
- For "Privacy" (AC2) and "Notifications" (AC3), however, this story *owns*
  both destination screens (P4, P5) and they are simply never connected. No
  other file in the reviewed diff (`app_shell.dart`, `service_locator.dart`,
  or any presentation file) constructs `PrivacyScreen()` or
  `NotificationSettingsScreen(store: ...)` outside of their own widget test
  harnesses.
- Each phase's own write scope explains why: P4's write scope is
  `privacy_screen.dart` + ARB + test only (not `me_screen.dart`); P5's write
  scope is the notification data/presentation files + ARB +
  `service_locator.dart` + test (also not `me_screen.dart`). No phase's write
  scope included wiring the `me_screen.dart` menu rows to these two
  destinations, so the wiring step was structurally never assigned to anyone.
- The master-plan.md §8 Result Log for P4 explicitly notes this ("not yet
  wired into me_screen.dart's ... menu row ... the row remains a forward link
  per P2's existing note") but does not flag it as an AC-impacting gap or
  route it to a future phase. P5's Result Log does not mention the equivalent
  gap for notifications at all. Neither `story_master.md`'s Role Completion
  section nor any Open Item records this as a known, accepted limitation —
  unlike the avatar gap (DEC-1), which *is* explicitly and prominently
  disclosed for the review gate.
- Consequence: AC2 ("A user can view their privacy settings") and AC3 ("A
  user can view and change notification preferences") read literally, are not
  actually satisfied end-to-end in the shipped app — a user has no way to
  reach either screen. Only the underlying screens/cubits exist and are
  demonstrable solely by a test harness constructing them directly.

**Recommended fix** (small, in scope of P2's original `me_screen.dart` write
scope, not a new phase): give `_MenuRow` an optional `onTap`, and pass
`() => Navigator.push(context, MaterialPageRoute(builder: (_) =>
const PrivacyScreen()))` for the privacy row and
`() => Navigator.push(context, MaterialPageRoute(builder: (_) =>
NotificationSettingsScreen(store: getIt<NotificationPreferencesStore>())))`
for the notifications row (mirroring the existing `getIt<...>()` pattern
already used in `app_shell.dart`). Leave Typing Ghost / Love Contract rows
inert, since those destinations genuinely do not exist yet in other stories.

## 5. Test coverage completeness cross-check (this slice's files only)

**PASS** — every public cubit method and every screen-level rendering/behavior
claim made in master-plan.md §6.1's "Test Scope" column and §8's Result Log
for P2/P4/P5-presentation is backed by an actual test in this slice's test
files (`account_cubit_test.dart`, `profile_edit_cubit_test.dart`,
`notification_settings_cubit_test.dart`, `me_screen_test.dart`,
`profile_edit_screen_test.dart`, `privacy_screen_test.dart`,
`notification_settings_screen_test.dart`). No orphaned or missing test claims
found. (Minor, non-blocking observation: `profile_edit_screen_test.dart` does
not exercise the submit-failure branch / `_submitFailureMessage` mapping at
the widget level, only at the cubit level in
`profile_edit_cubit_test.dart` — acceptable, not a gap worth blocking on.)

## Outcome

**Outcome: PATCH_REQUIRED**

All DEC-1..DEC-6 and OQ-A/OQ-B resolutions hold against the actual code, all
ARB/AC4-exclusion/DND-copy checks pass, and test coverage matches the plan.
The single blocking finding is F-1: AC2 and AC3 are implemented but not
reachable from any real navigation path in the shipped app, because no
phase's write scope assigned the `me_screen.dart` menu-row wiring step. This
requires a small patch to `me_screen.dart` (adding `onTap` to the privacy and
notifications rows) before this story can be marked `DONE`.

REVIEW_SLICE_COMPLETE: YES
