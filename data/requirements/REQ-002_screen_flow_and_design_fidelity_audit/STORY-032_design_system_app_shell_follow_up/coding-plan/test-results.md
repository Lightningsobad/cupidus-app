# STORY-032 — Test Results

Worktree:
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-032`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-032`
Toolchain: Flutter 3.44.1 / Dart 3.12.1

All commands below were run from `<worktree>/mobile` with the SDK on `PATH`
(`export PATH="$HOME/flutter/bin:$PATH"`); the Flutter SDK is not on the default
`PATH` on this machine.

## Phase 1 — shared app-shell background layer (AC1)

Verified in its own dispatch. Its unit coverage
(`mobile/test/design_system/cupid_app_background_test.dart`) is included in
every full-suite run recorded below.

## Phase 2 — remove the 21 per-screen `Scaffold` `backgroundColor` overrides (AC1, AC4)

`flutter analyze --no-pub <the 21 Phase 2 paths>`

- 6 issues, all `info` / `prefer_initializing_formals`, on constructor
  parameters this story never touched (`invite_screen.dart:73,74,94`,
  `joincode_screen.dart:25`, `waiting_screen.dart:25`, `vibe_screen.dart:27`).
  No errors, no warnings.
- First pass reported 8 `unused_local_variable` warnings: deleting the
  `Scaffold` override left `final CupidColorTokens colors = context.cupidColors;`
  unreferenced in 8 of the 21 files. Those locals were removed (and, in
  `invite_screen.dart`, the comment that documented the local). No `ignore`
  comment was added anywhere.

`flutter test`

- `+1004: All tests passed!`

AC4 evidence: see `../visual-fidelity/visual-fidelity-report.md` and the two
PNGs beside it. Forgot Password was recaptured after Phase 3 so the restyled
CTA is in frame.

## Phase 3 — `CupidPrimaryButton` and `CupidHeader` restyle (AC2, AC3, AC5)

`flutter analyze --no-pub lib/design_system/adaptive/cupid_primary_button.dart lib/design_system/adaptive/cupid_header.dart test/design_system/adaptive_widgets_test.dart test/features/anti_ghosting/presentation/anti_ghost_screen_test.dart`

- `No issues found!`

`flutter test test/design_system/adaptive_widgets_test.dart`

- `+11: All tests passed!` (8 pre-existing, 3 added by this phase: Material
  header transparency over the backdrop blur, iOS header blur replacing the
  opaque band, and the CTA's gradient / glow / 54pt band / 16.5-w800 label on
  both platforms.)

`flutter test test/features/anti_ghosting/presentation/anti_ghost_screen_test.dart`

- `+6: All tests passed!`

`flutter test`

- `+1007: All tests passed!`

### Full-project analyzer baseline

`flutter analyze --no-pub lib test` — `77 issues found.`, every one an `info`
(`prefer_initializing_formals`, one `use_null_aware_elements`, one
`deprecated_member_use` on `SemanticsService.announce`). No errors and no
warnings. None of the 77 sit on a line this story wrote; the four files Phase 3
touched analyze clean on their own, as recorded above.

### One intentional test update outside this story's files

`mobile/test/features/anti_ghosting/presentation/anti_ghost_screen_test.dart`
asserted that exactly one `BoxDecoration` in the Anti-Ghosting tree paints
`--grad-hot`, which was true while the selected threshold segment was the only
gradient in the screen. Phase 3 gives `CupidPrimaryButton` that same gradient,
so the tree-wide count became 2 and the assertion failed at line 279.

The assertion was narrowed to exclude decorations that descend from
`CupidPrimaryButton`, which restores the original intent — "the selected segment
is `--grad-hot`" — without weakening it to `isNotEmpty`. No other assertion in
that file was changed. This is the AC5 case of a token consumer being updated
deliberately rather than silently.
