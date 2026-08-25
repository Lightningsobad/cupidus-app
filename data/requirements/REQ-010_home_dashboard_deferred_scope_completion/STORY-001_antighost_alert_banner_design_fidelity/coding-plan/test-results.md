# Test Results — REQ-010 / STORY-001

Lane: mobile
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-010_home_dashboard_deferred_scope_completion-STORY-001`
Branch: `codex/REQ-010_home_dashboard_deferred_scope_completion-STORY-001`

Result: PASS

## Static analysis

Command:

```
cd <worktree>/mobile && flutter analyze lib/features/anti_ghosting lib/design_system/icons test/features/anti_ghosting
```

Output: `7 issues found.` — all `info • prefer_initializing_formals`, all in
files this story did not touch (`ghost_config_repository.dart`,
`anti_ghost_cubit.dart`, `ghost_storm_cubit.dart`). **Zero errors, zero warnings,
zero new issues.** Result: PASS.

Note: the generated l10n sources are not committed, so a fresh worktree fails
analysis with `Target of URI doesn't exist: package:cupid_mobile/l10n/generated/app_l10n.dart`.
Resolved by running `flutter gen-l10n` in `<worktree>/mobile` before analysis.

## Formatting

```
cd <worktree>/mobile && dart format lib/features/anti_ghosting/presentation/widgets/anti_ghost_entry_card.dart lib/design_system/icons/cupid_icons.dart test/features/anti_ghosting/presentation/anti_ghost_entry_card_test.dart
```

Output: `Formatted 3 files (1 changed)`. Analysis and tests re-run after
formatting; both still green. Result: PASS.

## Targeted tests

```
cd <worktree>/mobile && flutter test test/features/anti_ghosting/presentation/anti_ghost_entry_card_test.dart
```

Output: `00:01 +9: All tests passed!` Result: PASS.

Includes one new test added by this story —
`REQ-010 STORY-001: the banner wears the design source's amber alert chrome, and
no state paints a pending-only variant` — which pins D1/D2 (card fill + amber
border), D4/D5 (amber tile + `sentimentDissatisfied` glyph), D6/D8 (amber title,
muted subtitle in every state), D7 (no secondary timer badge), and D9 (trailing
chevron, scoped to this card's subtree because sibling Home cards carry their
own). A `matchesGoldenFile` golden was considered and rejected as
platform-fragile; the widget assertions pin the same deviations deterministically.

Also includes the untouched AC3 regressions
`tapping the card from HomeScreen pushes AntiGhostScreen` and
`a partner-proposed pending config routes to the review state (State C) on tap`.

## Regression sweep

```
cd <worktree>/mobile && flutter test test/features/anti_ghosting test/features/home test/features/chat/presentation/chat_screen_ghost_state_row_mount_test.dart test/design_system
```

Output: `00:06 +168: All tests passed!` Result: PASS.

## Visual fidelity

- Design-Screen: `home`
- Route / surface captured: Home dashboard (`HomeScreen`) — the
  `AntiGhostEntryCard` / `ghostAlert` banner
- Platform / theme / locale: android / dark / vi
- Device: Android emulator `emulator-5554` (leased via
  `capture-mobile-screen.sh --lease-exec`)
- Implemented screenshot:
  `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-001_antighost_alert_banner_design_fidelity/visual-fidelity/implemented-home-emulator-5554.png`
  (`MOBILE_CAPTURE: OK ... 405x900 171096`)
- Design reference:
  `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-001_antighost_alert_banner_design_fidelity/visual-fidelity/design-reference-home-android.png`
  (`DESIGN_CANVAS: OK ... 406x900`)
- Capture defines: `PREVIEW=home`, `PREVIEW_HOME_FIXTURE=true`,
  `PREVIEW_ANTIGHOST=state-b`

VISUAL_FIDELITY: PASS
Report:
`data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-001_antighost_alert_banner_design_fidelity/visual-fidelity/visual-fidelity-report.md`

## Acceptance criteria

- AC1 (rendered banner matches design in layout/spacing/colour/typography/copy):
  MET, with the three copy/tap-target/motion residuals explicitly dispositioned
  out of scope by `ux/uiux-spec.md` §1 and D10. See the fidelity report.
- AC2 (deviations corrected in the app and re-verified): MET — D1-D9 plus the
  implementation-found D11 corrected in `anti_ghost_entry_card.dart` and
  re-verified by both the widget test and the on-device capture.
- AC3 (tap behaviour unchanged, still reaches the existing anti-ghosting flow):
  MET — `onTap` still pushes `AntiGhostScreen`; the design source's `goChat`
  binding was deliberately not adopted (`ux/uiux-spec.md` §3). No new tap target
  or navigation destination added; detection/business logic untouched.

## Files changed

- `mobile/lib/features/anti_ghosting/presentation/widgets/anti_ghost_entry_card.dart`
- `mobile/lib/design_system/icons/cupid_icons.dart`
- `mobile/test/features/anti_ghosting/presentation/anti_ghost_entry_card_test.dart`
