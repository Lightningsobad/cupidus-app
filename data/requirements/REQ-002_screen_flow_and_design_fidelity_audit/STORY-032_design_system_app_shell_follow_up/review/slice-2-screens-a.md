# STORY-032 Review — Scoped Slice 2/4 (`phase2-screens-a`)

Review type: `scoped-slice` (Tier-3, slice 2 of 4)
Story: STORY-032 Design System — App-Shell Background, Button & Header Follow-Up
Requirement: REQ-002 (Scope B) · Lane: mobile · Complexity: standard
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-032`
Diff baseline: `079d4801831037e2540a813f66efe5e4258eaae4` → HEAD `2ebe3462cfdbde5d63e9e0a7a05b7df695562371`
Slice AC scope: AC1 (screen-side inheritance only), AC4 [Forgot Password], AC5 [anti-ghost screen/test]

## Slice Verdict

PATCH_REQUIRED — the code side of this slice is correct and its test evidence
reproduces, but the AC4 Forgot Password visual-fidelity package is missing the
design-reference half of the comparison, the resolved `Design-Screen: <id>`,
and the `VISUAL_FIDELITY:` verdict line that reviewer rule 12e3 requires for a
`mobile` lane story with a configured, locked design source
(`data/devops/system/design-fidelity-config.json`: `design_source.locked: true`,
`ui_surface: true`).

Note on HEAD: the handoff expected HEAD `d43d9f2`. The current HEAD is
`2ebe346`, whose only delta is the slice-1 review report commit. No
implementation drift; `d43d9f2` is an ancestor of HEAD.

## Files In Scope

| File | Change | Verdict |
| --- | --- | --- |
| `mobile/lib/features/account/presentation/screens/me_screen.dart` | `-1` removed `Scaffold(backgroundColor: colors.colorBackground)` | PASS |
| `mobile/lib/features/account/presentation/screens/notification_settings_screen.dart` | `-1` same | PASS |
| `mobile/lib/features/account/presentation/screens/privacy_screen.dart` | `-1` same | PASS |
| `mobile/lib/features/account/presentation/screens/profile_edit_screen.dart` | `-1` same | PASS |
| `mobile/lib/features/anti_ghosting/presentation/screens/anti_ghost_screen.dart` | `-2` removed override + now-unused `colors` local | PASS |
| `mobile/lib/features/auth/presentation/screens/forgot_screen.dart` | `-1` removed override | PASS |
| `mobile/lib/features/auth/presentation/screens/login_screen.dart` | `-1` same | PASS |
| `mobile/lib/features/auth/presentation/screens/register_screen.dart` | `-1` same | PASS |
| `mobile/test/features/anti_ghosting/presentation/anti_ghost_screen_test.dart` | `+16 -1` narrowed the `--grad-hot` segment assertion | PASS |

Verified directly, not from the diff summary:

- No `Scaffold(backgroundColor: ...)` remains in any of the 8 screens. The only
  surviving `backgroundColor:` occurrences are `CircleAvatar` fills
  (`me_screen.dart:207`, `profile_edit_screen.dart:131`, both
  `colors.colorSurfaceAlt`) — not shell fills, correctly untouched.
- No dangling locals: `colors` is still referenced in all 7 files that kept the
  binding; only `anti_ghost_screen.dart` had a binding that became unused and it
  was deleted (line 60 area) rather than suppressed.
- No intermediate wrapper reintroduces an opaque fill on the path to these
  screens: `mobile/lib/core/navigation/app_shell.dart:192` returns a `Scaffold`
  with no `backgroundColor` (the `colors.colorAccentPink` at line 201 is the
  account-hub `FloatingActionButton`), so the post-pairing account screens
  inherit the transparent scaffold too.

## AC Traceability

| AC | Slice-scoped claim | Evidence | Verdict |
| --- | --- | --- | --- |
| AC1 | Each of the 8 screens inherits the shared sky wash instead of a flat `colorBackground` fill | Per-screen override removed (above) + `cupid_theme.dart` `scaffoldBackgroundColor: Colors.transparent` + `cupid_app.dart` `MaterialApp.builder → CupidAppBackground` (layer itself verified in slice 1); rendered proof in `visual-fidelity/ac4-forgot-password-dark-vi.png` | PASS |
| AC4 [Forgot Password] | Re-rendered screen visibly shows the shared background wash and the restyled CTA | I opened `visual-fidelity/ac4-forgot-password-dark-vi.png`: it is a real render of the correct screen (headline "Quên mật khẩu là chuyện thường", EMAIL field, mint Private Gallery note). Purple/magenta radial wash reaches full bleed, 2 twinkle stars visible, and "Gửi link đặt lại" renders as the full-width gradient pill with the pink glow — not a flat fill | PASS (AC text) |
| AC4 [Forgot Password] | Design-fidelity evidence package per reviewer rule 12e3 | See F1 | FAIL |
| AC5 [anti-ghost] | The intentionally updated contract test is called out explicitly and still passes | `coding-plan/test-results.md` §"One intentional test update outside this story's files" + `story_master.md` Phase 3 both name it; assertion narrowing is behaviourally correct (see below); reran green | PASS |

AC4 header sub-clause: AC4 asks the two named screens to show the "restyled
CTA/header". `forgot_screen.dart:99` mounts a bare `Scaffold` with no `appBar`,
so this screen has no `CupidHeader` to restyle — the header half of AC4 is
inapplicable here rather than unmet. Recorded so synthesis does not read the
absent header as a miss. AC3/AC5 header coverage lives in
`mobile/test/design_system/adaptive_widgets_test.dart`, outside this slice.

AC5 assertion review: `decorations` still collects every `BoxDecoration` in the
tree; the new `ctaDecorations` set collects only `DecoratedBox` descendants of
`CupidPrimaryButton`, and the segment assertion excludes them before asserting
`hasLength(1)`. This preserves the original intent ("exactly one selected
segment paints `--grad-hot`") rather than weakening it to `isNotEmpty`. The
exclusion relies on `BoxDecoration` value equality, so a future decoration that
became value-equal to the CTA's would make the assertion fail loudly, not pass
silently — an acceptable failure mode, no finding.

## Test Evidence

Independently rerun (not taken from `test-results.md`):

```
cd <worktree>/mobile && export PATH="$HOME/flutter/bin:$PATH"
flutter test test/features/anti_ghosting/presentation/anti_ghost_screen_test.dart
→ 00:00 +6: All tests passed!
```

Includes `AC1/AC3 (dark + vi): settings cards, threshold track, and selected
segment paint the design-source tokens`, the test carrying the narrowed
assertion. Matches the `+6` recorded in `test-results.md` §Phase 3.

`git status --porcelain` after the run: clean (empty).

## Findings

### F1 — AC4 visual-fidelity package does not satisfy reviewer rule 12e3 (PATCH_REQUIRED, owner: mobile-dev)

`data/devops/system/design-fidelity-config.json` has `ui_surface: true` and a
locked `design_source` (`claude-design`, `cupid-app-design-system`,
`screens_from: canvas`), so neither 12e3 scope-out applies and the rendered
design-fidelity check is mandatory and non-waivable for this story. The
delivered package is
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-032_design_system_app_shell_follow_up/visual-fidelity/`
and contains only:

- `ac4-forgot-password-dark-vi.png`
- `ac4-waiting-for-pairing-dark-vi.png`
- `visual-fidelity-report.md`

Four specific gaps, all on the AC4 Forgot Password evidence I was asked to
verify:

1. No `design-reference-<screen>-<device>.png` exists — only the implemented
   side. `git ls-files` on the story directory confirms no reference asset. With
   nothing to compare against, no fidelity comparison has actually occurred; the
   report's own framing ("Purpose: … confirm the shared app-shell sky wash and
   the twinkle stars now reach both screens") is an inheritance check, not a
   design comparison.
2. No resolved `Design-Screen: <id>` is recorded anywhere in `story_master.md`
   or the visual-fidelity report. The design source exposes named canvas screens
   (`render-design-canvas.js --screen=<id>`), so the id is required and its
   absence means the choice cannot be re-checked by any later reader.
3. `visual-fidelity-report.md:11` records `Outcome: CONFIRMED AT RENDER`; there
   is no `VISUAL_FIDELITY: PASS` (or `FAIL`) line. The reviewer SubagentStop
   gate and the DONE gate both read that exact verdict token independently.
4. The implemented capture is a `flutter test` headless rasterization, and the
   report's §"Known Gap" states plainly that there is no on-device capture. The
   raster is legitimate proof of the widget tree and theme (and I accept it as
   the AC4-as-written evidence above), but it is not the device/emulator capture
   12e3 describes, and it cannot show `BackdropFilter` platform compositing.

Not a self-fix item for review: resolving `design_source` and producing the
reference render are ui-ux-designer/mobile-dev work, and
`guard-design-source-lock.sh` blocks reviewer edits to the config regardless.

Required to clear F1: capture `implemented-<screen>-<device>.png` and
`design-reference-<screen>-<device>.png` for the Forgot Password screen under
`visual-fidelity/`, record the resolved `Design-Screen: <id>`, and rewrite
`visual-fidelity-report.md` with a `VISUAL_FIDELITY: PASS|FAIL` line naming the
screen, device, and the AC states compared.

### F2 — Harness for the AC4 captures is not committed (DEFERRED, owner: mobile-dev)

`visual-fidelity-report.md:42-45` states the rasterization harness was not
committed because it falls outside the story's declared write scope, and
documents the parameters (FontLoader for the 4 bundled families, frame at
elapsed 2600 ms, `toImage(pixelRatio: 3)`) needed to rebuild it. The captures
are therefore not reproducible by re-running a committed command. The
documentation is genuinely sufficient to rebuild, and the write-scope reasoning
is sound, so this is deferred rather than blocking — but it means the AC4
evidence cannot be regression-checked automatically by any later story.

## Out Of Slice

Verified as not-mine and deliberately not re-reviewed:

- Slice 1 `phase1-foundation` (`cupid_sky_palette.dart`,
  `cupid_app_background.dart`, `cupid_theme.dart`, `cupid_app.dart`, barrel
  exports and their tests). I read only the two-line `cupid_theme.dart` /
  `cupid_app.dart` diff hunks needed to confirm the screen-side inheritance path
  for AC1; the layer's own correctness stands on slice 1's PASS.
- AC2 `CupidPrimaryButton` and AC3 `CupidHeader` restyle internals, and
  `mobile/test/design_system/adaptive_widgets_test.dart`.
- The other 13 Phase 2 screens (dream jar, love contract, pairing, pet,
  reminders, vibes, gallery gate).
- `ac4-waiting-for-pairing-dark-vi.png` and the AC4 Waiting-For-Pairing half.
- Story-level `review/review-report.md` and the `Outcome:` verdict — Final
  Synthesis owns these. F1 is a story-level gate item surfaced here because AC4
  evidence was this slice's explicit check; synthesis must carry it forward.

SLICE_VERDICT: PATCH_REQUIRED
