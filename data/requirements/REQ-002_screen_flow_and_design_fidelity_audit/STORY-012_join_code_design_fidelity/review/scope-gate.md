# Scope Gate — STORY-012 Join / Enter Pairing Code Design Fidelity

Phase: SCOPE_GATE
Reviewer: Iris-QC
Mode: compact-story-review
Scope: REQ-002 / STORY-012_join_code_design_fidelity
Worktree: /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-012
BaseHead: 8396273e6a5e6a2798557aa68864f0ef24cd939b
Implementation commit: f284985dad5a3028f0460e2ae2d48c01c88a9096

## Diff surface (git diff BaseHead, 4 files, +428/-9)

| File | Change |
| --- | --- |
| `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart` | +102 / -8 |
| `mobile/test/features/pairing/presentation/screens/joincode_screen_design_test.dart` | new, 126 lines |
| `data/requirements/REQ-002.../STORY-012_join_code_design_fidelity/visual-fidelity/visual-fidelity-report.md` | new, 199 lines |
| `data/requirements/REQ-002.../STORY-012_join_code_design_fidelity/story_master.md` | +1 / -1 (artifact checkbox) |

## Source and test files in review scope

- `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart` (changed — primary subject)
- `mobile/test/features/pairing/presentation/screens/joincode_screen_design_test.dart` (changed — new design assertions)

## Supporting files read for verification only (unchanged, not in scope for defect attribution)

Loaded because the changed file's correctness is defined by them:

- `mobile/lib/design_system/tokens/cupid_color_tokens.dart` — verify the report's design-var to token mapping
- `mobile/lib/design_system/tokens/cupid_platform_tokens.dart` — verify `radiusSmall` = 16 and `tapTarget` = 44/48
- `mobile/lib/design_system/tokens/cupid_typography_tokens.dart` — verify `display` / `caption` / `labelMono` roles
- `mobile/lib/design_system/tokens/cupid_spacing.dart` — verify `sm`/`md`/`lg`/`xl` = 8/16/24/32
- `mobile/lib/design_system/adaptive/cupid_primary_button.dart` — verify the CTA deferral claim and CTA tap target
- `mobile/lib/design_system/adaptive/cupid_header.dart` — verify back-affordance tap target, no regression
- `mobile/lib/design_system/icons/cupid_icons.dart` — verify the "no `link` glyph" deferral claim
- `mobile/lib/features/pairing/presentation/pairing_strings.dart` — resolve `viEn` locale semantics
- `mobile/lib/app/cupid_app.dart` — confirm the production locale is pinned `vi`
- `mobile/lib/main_preview.dart` — confirm a `joincode` render path exists for evidence capture

## Governing artifacts

- `data/requirements/REQ-002.../STORY-012_join_code_design_fidelity/story_master.md` — AC1-AC4, In/Out of Scope
- `data/requirements/REQ-002.../STORY-012_join_code_design_fidelity/visual-fidelity/visual-fidelity-report.md` — Mobile Dev's claims, to be verified not trusted
- `data/devops/system/design-fidelity-config.json` — locked design source pointer

## Design source ranges (locked, `screens_from: canvas`)

`cupid-app-design-system/project/Cupid Screens.dc.html`

| Range | What it settles |
| --- | --- |
| 1550-1570 | The `isJoinCode` screen body — every layout, spacing, colour and type value under audit |
| 1770, 1782 | `t_joincode` chrome title, vi and en |
| 1853 | `BACK_TO.joincode = 'invite'` |
| 1951 | `NO_CHROME` map — does joincode carry a header |
| 1952 | `NO_TABS` map |
| 1583 | Waiting-screen `CPD-8F2K` — corroborates the design's code length |
| CSS `:root` vars | `--bg --surf --surf2 --line --tx --tx2 --pink --purple --red --glow --r-btn` for both themes |

## Query keys

- `isJoinCode`, `joincode`, `t_joincode`, `BACK_TO`, `NO_CHROME`, `NO_TABS`
- `viEn`, `_isVi`, `Localizations.localeOf`, `Locale('vi')`
- `radiusSmall`, `tapTarget`, `labelMono`, `caption`, `display`
- `CupidIcons` / `static const IconData` (glyph inventory)

## Verification commands to run in this phase

- `git -C <Worktree> diff 8396273e...` (scoped per path)
- `flutter analyze lib/features/pairing test/features/pairing`
- `flutter test test/features/pairing/presentation/screens/joincode_screen_design_test.dart test/features/pairing/presentation/joincode_screen_test.dart`
- `flutter test test/design_system/no_fork_guard_test.dart`
- `dart format --output=none --set-exit-if-changed` on changed files **and** on
  `lib/features/pairing` + `lib/design_system` to establish the repo baseline

## Explicitly out of review scope

- Inter-screen navigation correctness (Scope A, STORY-001/STORY-002)
- Light theme and `en` locale user-facing visual QA (OQ5, story Out of Scope)
- Pairing business logic, code length/format, backend contracts
- Shared `design_system/` widgets as defect targets — untouched by this diff;
  read only to confirm deferral claims and check for regressions

## Review criteria applied

1. Every claim in the Mobile Dev visual-fidelity report re-derived from the
   design source or the token layer, not accepted as written.
2. Tap targets checked against `CupidPlatformTokens` (44pt iOS / 48dp Material).
3. Rendered-evidence completeness, not prose CSS-to-code transcription.
4. Shared-widget regression check across the diff.
5. AC1-AC4 verdicts stated individually with their basis.

SCOPE_GATE_COMPLETE: YES
