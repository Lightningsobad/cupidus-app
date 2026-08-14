# STORY-022 — Anti-Ghosting Settings Visual Fidelity Report

- Story: STORY-022 (`anti_ghosting_settings_design_fidelity`)
- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Lane: mobile
- Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-022`
- BaseHead: `bf808483223580df81b1fb951b141a6597cb82dd`
- Audit target: enabled dark theme, `vi` locale

## Scope And Sources

| Item | Path |
| --- | --- |
| Locked design source | `cupid-app-design-system/project/Cupid Screens.dc.html`, `isAnti` section (lines 537-591), `thresholdOpts` (lines 2252-2257) |
| Screen under audit | `mobile/lib/features/anti_ghosting/presentation/screens/anti_ghost_screen.dart` |
| Widgets re-checked (no change needed) | `mobile/lib/features/anti_ghosting/presentation/widgets/anti_ghost_entry_card.dart`, `.../widgets/ghost_state_row.dart` |
| Design tokens | `mobile/lib/design_system/tokens/` (`CupidColorTokens`, `CupidTypographyTokens`, `CupidSpacing`, `CupidPlatformTokens`) |

### Token-mapping rule used

The design source is raw CSS with an off-scale pixel ladder (14.5 / 13.5 / 12.5 /
11.5px type; 17 / 20px paddings; 13px stack gap). This repository already
resolves that mismatch in `features/chat/presentation/screens/ghost_settings_screen.dart`
by mapping *design roles* onto the shared token scale rather than transcribing
literals. This audit follows the same convention:

| Design source value | Mapped to |
| --- | --- |
| `padding:8px 16px 40px` (screen) | `EdgeInsets.fromLTRB(md, sm, md, xl)` |
| `padding:17px` (card) | `EdgeInsets.all(CupidSpacing.md)` |
| `padding:20px` (hero) | `EdgeInsets.all(CupidSpacing.lg)` |
| `gap:13px` (card stack) | `SizedBox(height: CupidSpacing.md)` |
| `font-size:14.5px;font-weight:800` (section heading) | `type.body` + `FontWeight.w800` |
| `font-size:14.5px;font-weight:700` (row title) | `type.body` + `FontWeight.w700` |
| `font-size:11.5px` / `13px` (hint, subtitle) | `type.caption` |
| `font-family:Nunito;font-weight:900;font-size:22px` (hero title) | `type.display` at `type.cardTitle.fontSize`, `height: 1.25` |
| `--surf` / `--surf2` / `--line` / `--tx` / `--tx2` / `--peach` / `--grad-hot` | `colorSurface` / `colorSurfaceAlt` / `colorLine` / `colorText` / `colorTextMuted` / `colorPeach` / `gradientHot` |
| `--r-card` / `999px` / `14px` tile radius | `platform.radiusCard` / `999` / `platform.radiusSmall` |
| `--shadow` | `platform.elevationShadow` |

Only genuinely un-tokenizable geometry was transcribed as a literal, each behind
a named constant with the source value in its doc comment: segment height `40`,
penalty tile `40`, penalty glyph `21`, and the 145deg hero gradient vectors.

## Findings And Corrections

All findings were corrected in app code (AC2), not documented only.

### F-01 — Screen padding did not match the design section box

- Before: `EdgeInsets.all(CupidSpacing.md)` on every state body — uniform 16 on all four edges.
- Design: `padding:8px 16px 40px` — tight top, generous bottom so the last card clears the CTA.
- After: shared `_screenPadding` (`fromLTRB(md, sm, md, xl)`) applied to all six state bodies.

### F-02 — Intro hero card was missing entirely

- Before: the propose form opened straight into the threshold card. The design source's headline block had no counterpart in the app.
- Design: `padding:20px;border-radius:var(--r-card);background:linear-gradient(145deg,rgba(183,140,245,.26),rgba(255,171,147,.18));border:1px solid var(--line)`, Nunito 900/22px title at `line-height:1.25`, `13px/1.55` muted subtitle at `margin-top:8px`.
- After: new `_IntroHeroCard`. The 145deg angle uses the same CSS-angle convention already encoded in `CupidColorTokens` (`begin = (-sin, cos)`, `end = (sin, -cos)`), so it composes with the existing gradient tokens instead of introducing a second convention. Copy binds to the existing `anti_ghost_intro_title` / `anti_ghost_intro_subtitle` keys, which already carry the design's exact `vi` strings.

### F-03 — Threshold picker was a Material chip row, not a segmented control

This is the AC3 "inactivity-threshold picker" deviation.

- Before: `_TimeoutChipRow` — a `Wrap` of Material `ChoiceChip`s carrying stock Material chip chrome (outline, check-mark affordance, chip fill).
- Design: a pill *track* — `display:flex;gap:8px;margin-top:14px;padding:4px;border-radius:999px;background:var(--surf2)`, with each segment `flex:1;height:40px;border-radius:999px;font-size:13.5px;font-weight:800`; selected = `--grad-hot` fill with white text; unselected = transparent with `--tx2` text.
- After: `_TimeoutSegmentedControl` + `_TimeoutSegment` reproduce the track and both segment states exactly. Each segment is `Expanded` (`flex:1`), separated by `CupidSpacing.sm` (8px), inside `CupidSpacing.xs` (4px) track padding.
- Accessibility preserved: the design's rendered segment is 40 tall, below the 48dp minimum. Rather than inflate the visual pill, each segment carries `CupidSpacing.xs` vertical padding *inside* its own `GestureDetector`, so the tap target is 4 + 40 + 4 = 48 while the painted pill stays at the design's 40.
- Semantics preserved: each segment is `Semantics(button: true, selected: …, enabled: …)`, which is what the new disabled-state test asserts against.

### F-04 — Cards had no surface treatment

- Before: state bodies used bare `Column`s or ad-hoc containers; several had no `--surf` fill and none carried the shared shadow.
- Design: every settings block is `border-radius:var(--r-card);background:var(--surf);box-shadow:var(--shadow)`.
- After: shared `_SettingsCard` (fill `colorSurface`, radius `platform.radiusCard`, `platform.elevationShadow`), used by every state body.

### F-05 — Radius derived from the spacing scale

- Before: `BorderRadius.circular(CupidSpacing.md)` in several places — a spacing token used as a radius, so the corners tracked the spacing scale rather than the radius scale.
- After: `platform.radiusCard` for cards, `platform.radiusSmall` for the penalty glyph tiles, literal `999` for the pill track and segments.

### F-06 — Penalty rows had no design chrome

This is the AC3 "penalty-type selector" deviation.

- Before: three plain `RadioListTile`s — no leading glyph tile, no row dividers, leading-edge control.
- Design: `padding:6px 17px` card; each row `gap:13px;padding:14px 0` with a `40x40;border-radius:14px` tinted tile holding a `21px` glyph, a `14.5px/700` title, and a `1px solid var(--line)` divider between rows. Emoji Storm's tile is `rgba(255,171,147,.2)` with a `var(--peach)` `cyclone` glyph; the sound row's tile is `var(--surf2)` with a `var(--tx2)` `volume_up` glyph.
- After: new `_PenaltyIconTile` reproduces both tile treatments (the app-only `none` row inherits the neutral `--surf2` treatment, matching the source's off-state language), `Divider(height: 1, thickness: 1, color: colorLine)` between rows, and `controlAffinity: ListTileControlAffinity.trailing` so the glyph tile leads and the selection control trails, as in the source.
- Deliberate divergence retained: the design source draws three independent toggles, but `ux/uiux-spec.md` §2.3 explicitly requires single-select radio-group semantics here. The rows keep `RadioGroup`/`RadioListTile` semantics and adopt only the source's *visual* row language. This was a pre-existing, documented UX decision and is not a new deviation.

### F-07 — Typography roles were misapplied

- Before: section headings used `type.cardTitle` (22px / w600) where the design has a 14.5px / 800 label; several hints and subtitles used `type.body` (17px) where the design has 11.5px.
- After: headings go through the shared `_sectionHeadingStyle` helper (`type.body` + w800); hints and subtitles use `type.caption`.

### F-08 — Pending badge stretched full width

- Before: `_PendingMineBody`'s badge pill sat directly under `crossAxisAlignment: CrossAxisAlignment.stretch`, so the pill spanned the whole screen instead of hugging its label.
- After: wrapped in `Align(alignment: AlignmentDirectional.centerStart, …)`.

### F-09 — Inconsistent inter-card gaps

- Before: mixed `sm` / `lg` gaps between blocks.
- After: uniform `SizedBox(height: CupidSpacing.md)`, matching the design's single 13px stack gap.

### F-10 — Ink surface regression found during verification

- Symptom: `RadioListTile` threw `ListTile background color or ink splashes may be invisible` once the rows moved inside `_SettingsCard`'s painted container.
- Cause: `_SettingsCard` inserts a colored `DecoratedBox` between the nearest `Material` ancestor and the tiles, so tap ink would have painted underneath the card fill.
- Fix: `_PenaltyRadioGroup` now wraps its rows in `Material(type: MaterialType.transparency)`. No visual change; the ink lands above the card fill.

## Deferred (out of this story's write scope)

These are real gaps against the design source, but each needs new l10n keys, and
`mobile/lib/l10n/arb/` is outside this story's `WriteScope`. Two of them would
also add screen state that the story's Out of Scope list excludes.

| Id | Design element | Blocker |
| --- | --- | --- |
| D-01 | "Bộ emoji để bắn" storm-emoji-set card | Needs new `vi`/`en` keys plus a new persisted setting and backend field. Also a new interaction, which the story excludes. |
| D-02 | Handshake consent callout | Needs new `vi`/`en` keys; l10n directory outside `WriteScope`. |
| D-03 | Per-row penalty subtitles (`11.5px` descriptions under each penalty title) | No l10n keys exist for the three descriptions; l10n directory outside `WriteScope`. `_PenaltyIconTile` and the row layout already leave room for them, so adding the keys is the only remaining work. |
| D-04 | Light theme and `en` locale visual QA | Explicitly out of scope for this story (OQ5). |

Note: the threshold picker renders a fourth "Tuỳ chỉnh" (custom) segment that the
design source does not have. That is pre-existing app behaviour backing the
documented 1-120 minute custom range, not a fidelity deviation introduced here;
it is called out in `_TimeoutSegmentedControl`'s doc comment.

## Acceptance Criteria Verification

### AC1 — Dark theme + `vi` layout, spacing, colour, and typography match

Verified by a new widget test that pumps the screen at `Brightness.dark` with
`Locale('vi')` and asserts against `const CupidColorTokens.dark()` /
`const CupidPlatformTokens.material()` directly:

- both settings cards paint `colorSurface` at `platform.radiusCard` with `platform.elevationShadow`;
- the segmented track paints `colorSurfaceAlt` at radius 999;
- exactly one segment paints `gradientHot` (the selected one);
- exactly one penalty tile paints `colorPeach` at alpha 0.2 (Emoji Storm);
- the `vi` strings render (`Bơ tin nhắn thì phải trả giá 🎀`, `Ngưỡng “bơ”`), not the `en` fallback.

Every colour on the screen now resolves through `context.cupidColors`; no literal
colour values were introduced, so the dark palette applies by construction.

Status: MET.

### AC2 — Deviations corrected in the rendered app, not just documented

F-01 through F-10 are all code changes in
`mobile/lib/features/anti_ghosting/presentation/screens/anti_ghost_screen.dart`
(467 insertions / 195 deletions against BaseHead). No finding was left as
report-only except the four `WriteScope`-blocked items in the Deferred table.

Status: MET.

### AC3 — Threshold picker and penalty selector match for every option and state in the design source

- Threshold picker (F-03): both segment states in the source — selected (`--grad-hot` fill, white text) and unselected (transparent, `--tx2`) — are reproduced, across all three source options (`5`, `10`, `15` phút) and in both enabled and disabled renderings.
- Penalty selector (F-06): both tile treatments in the source — Emoji Storm (peach tint + peach `cyclone`) and sound (`--surf2` + muted `volume_up`) — are reproduced, plus row dividers, trailing control affinity, and the 14.5px/700 title role.

Status: MET.

### AC4 — No new entry point

No routing, navigation, or entry-point code was touched.
`anti_ghost_entry_card.dart` and `ghost_state_row.dart` were re-audited and needed
no change. `git diff --stat` against BaseHead shows exactly two changed files,
neither of which is a router or shell.

Status: MET.

## Verification

All commands run from
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-022/mobile`
with `PATH="$HOME/flutter/bin:$PATH"`.

Setup note: the fresh worktree had no generated l10n, so `flutter gen-l10n` was
run once before analysis. Without it the analyzer reports 35 spurious
`Target of URI doesn't exist: 'package:cupid_mobile/l10n/generated/app_l10n.dart'`
errors across the feature.

| # | Command | Result |
| --- | --- | --- |
| 1 | `flutter gen-l10n` | Generated `lib/l10n/generated/app_l10n.dart` (prints an informational `l10n.yaml` notice). |
| 2 | `flutter analyze --no-fatal-infos lib/features/anti_ghosting test/features/anti_ghosting` | PASS — 7 issues, all pre-existing `prefer_initializing_formals` infos in `ghost_config_repository.dart`, `anti_ghost_cubit.dart`, and `ghost_storm_cubit.dart`. None are in a file this story touched; the count is identical to the BaseHead baseline. |
| 3 | `flutter test test/features/anti_ghosting/presentation/anti_ghost_screen_test.dart --reporter compact` | PASS — `+6: All tests passed!` |
| 4 | `flutter test test/features/anti_ghosting --reporter failures-only` | PASS — `+63: All tests passed!` (baseline was 62; +1 is the new dark + `vi` fidelity test) |
| 5 | `flutter test --reporter failures-only` | PASS — `+921: All tests passed!` (full mobile suite, no regressions outside the feature) |

`--no-fatal-infos` is used in command 2 only because `flutter analyze` treats
info-level lints as fatal by default; the run without the flag produces the
identical 7 findings, all pre-existing and all outside this story's diff.

## Files Changed

| Path | Change |
| --- | --- |
| `mobile/lib/features/anti_ghosting/presentation/screens/anti_ghost_screen.dart` | All fidelity corrections F-01 through F-10. |
| `mobile/test/features/anti_ghosting/presentation/anti_ghost_screen_test.dart` | Added the dark + `vi` token-fidelity test; parameterised the harness for brightness/locale; replaced the now-stale `ChoiceChip` disabled assertion with a segment-semantics assertion; scrolled the propose CTA into view before tapping (the added hero card pushes it past the 800x600 test viewport). |

No screenshots are attached: provisioning simulators/emulators is outside the
mobile lane's authority, so dark + `vi` fidelity is evidenced by the token-level
assertions in AC1 rather than by captured frames.
