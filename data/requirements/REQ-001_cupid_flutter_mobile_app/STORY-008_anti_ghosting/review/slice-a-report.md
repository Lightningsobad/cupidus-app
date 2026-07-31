# STORY-008 Review — Slice A (P0 contract/data layer + P1 lifecycle/settings screen)

Reviewer: Iris-QC (scoped-slice)
RunId: RUN-REQ-001_cupid_flutter_mobile_app-STORY-008-reviewer-slice-a
BaseHead: 0a467d03babf1ed4102c3fab09c61b2dec941a0b
Scope: this slice covers P0 + P1 only. Slice B (home entry card / chat
ghost-state row) is reviewed separately; no verdict on those files is given
here.

## Files reviewed

- `mobile/lib/features/anti_ghosting/data/ghost_config_models.dart`
- `mobile/lib/features/anti_ghosting/data/ghost_config_repository.dart`
- `mobile/lib/core/di/service_locator.dart`
- `mobile/test/features/anti_ghosting/data/ghost_config_repository_test.dart`
- `mobile/lib/features/anti_ghosting/presentation/anti_ghost_cubit.dart`
- `mobile/lib/features/anti_ghosting/presentation/screens/anti_ghost_screen.dart`
- `mobile/lib/design_system/icons/cupid_icons.dart`
- `mobile/lib/l10n/arb/app_en.arb`
- `mobile/lib/l10n/arb/app_vi.arb`
- `mobile/test/features/anti_ghosting/presentation/anti_ghost_cubit_test.dart`
- `mobile/test/features/anti_ghosting/presentation/anti_ghost_screen_test.dart`

## Risk-surface verification (master-plan.md §3A rows owned by P0/P1)

- **Frozen wire contract**: `ghost_config_models.dart` and
  `ghost_config_repository.dart` match
  `backend/src/modules/ghost-config/` exactly — every path/method
  (`GET /ghost-config`, `GET /ghost-config/pending`, `POST /ghost-config`,
  `PATCH /:id/approve`, `PATCH /:id/reject`,
  `GET /ghost-config/storm-status/:partnerId`), the `POST` body shape
  (`{"timeoutMinutes": <int>, "penalty": "<wire>"}`), and every `Penalty`/
  `ConfigStatus` wire string (`emoji_storm`/`noise`/`none`,
  `active`/`pending_approval`/`rejected`/`superseded`) are asserted by
  `ghost_config_repository_test.dart` (23 tests, all present and correctly
  asserting request path/method/body/enum + empty-state + 1-120 clamping
  with boundary values). PASS.
- **Pairing gate (AC3)**: `AntiGhostCubit.load()` maps a `400` on the
  initial fetch to `AntiGhostPairingRequired`, and `anti_ghost_screen_test.dart`
  asserts the guard renders with zero non-GET requests. Cubit test also
  covers the AC3 400 case directly. PASS.
- **Approval-role derivation**: `_lifecycleForPending` compares
  `config.proposedBy` to `BackendUserIdStore.backendUserId`, never a
  Firebase uid, with explicit mine/partner/unknown-id cubit tests (State B,
  State C, unknown-role). PASS.
- **Design-system no-fork guard**: no `Color(0x`, `Colors.`, `Platform.is`,
  or `defaultTargetPlatform` in any reviewed `lib/` file — confirmed by
  reading `no_fork_guard_test.dart`'s exact forbidden-pattern list and
  grep-equivalent inspection of the diffs. All colors route through
  `context.cupidColors`/`context.cupidType` tokens. PASS.
- **l10n parity**: every `anti_ghost_*` and `ghost_state_row_*` key added to
  `app_en.arb` has a matching key (with `@description` metadata) in
  `app_vi.arb`; "Anti-Ghosting" and "Emoji Storm" are correctly left
  untranslated in `vi` per UX §5. PASS.

## Additional spot checks

- `CupidIcons.cyclone` (0xebd5), `volumeUp` (0xe050), `notificationsOff`
  (0xe7f6), and `timer` (0xe425) were verified against the actual
  bundled `mobile/assets/fonts/MaterialSymbolsRounded-Variable.ttf` cmap via
  `fontTools` — all four codepoints resolve to the claimed glyph names
  (`cyclone`, `volume_up`, `notifications_off`, `timer`). Not invented
  values.
- `service_locator.dart`: `GhostConfigRepository` registration is strictly
  additive (new import + one appended `registerLazySingleton` block); no
  existing registration reordered or modified.
- AC1 (view/set config, timeout 1-120, exactly one penalty) and AC3
  (unpaired guard, zero mutating calls) are both covered by cubit and
  widget tests with concrete assertions, not just presence checks.
- Double-tap guard (`_mutate`'s `isSubmitting` check before the first
  `await`) is correctly exercised at both the cubit level (`Future.wait`
  on two synchronous `propose()` calls) and the widget level (two
  `tester.tap()` calls before a single `pumpAndSettle()`); both assert
  exactly one `POST`.
- Stale-400-during-mutation path reloads silently (`actionFailure` stays
  null) rather than surfacing an error, matching the phase doc's ADR-4/§7
  risk-table intent; a non-400 mutation failure correctly surfaces
  `actionFailure` and clears `isSubmitting`.
- `_mutate` and `load()` both guard `emit` with `isClosed` checks
  (`_emitIfNotClosed`), avoiding a use-after-close crash if the screen is
  popped mid-request.

## Non-blocking observation

`ux/uiux-spec.md` §2.3 State C specifies Accept should use a
`--mint`/trust-token treatment ("positive-action convention"), but the
implementation reuses the generic pink `CupidPrimaryButton` (same widget
used for Propose/Change) for Accept. This is a cosmetic UX-spec deviation,
not a functional AC1/AC3 gate failure — the design system currently has no
mint/trust-styled button variant, and introducing a one-off would fork the
design system rather than follow it. Flagging for UI/UX Designer or Scrum
Master to decide (add a semantic secondary/positive button variant to
`design_system/adaptive/`, or explicitly accept the shared pink CTA for
visual consistency); does not block this slice.

## Outcome

Outcome: CLEAN (slice-a scope only — P0 + P1)
