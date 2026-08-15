# Review Report: STORY-028 Design Fidelity — Shared Expenses

Reviewer: Iris-QC
Mode: compact-story-review
Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Story: STORY-028 (`shared_expenses_design_fidelity`)
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-028`
BaseHead: `8396273e6a5e6a2798557aa68864f0ef24cd939b`
Reviewed commit: `6d869b0debba1e07d22d0d02f61a85fa4cd06e2d`

## Outcome

Outcome: DEFERRED_ONLY

All four acceptance criteria are satisfied by the delivered code. Two visible
design-source details remain unmet because they live inside shared
`mobile/lib/design_system/adaptive/**` components that were outside this
story's WriteScope; both are correctly documented as deferrals. No
patch-required defect was found.

## Scope reviewed

Diff `git -C <worktree> diff 8396273 HEAD`, 5 files, +801 / -177:

- `mobile/lib/features/expenses/presentation/screens/expense_history_screen.dart`
- `mobile/lib/features/expenses/presentation/widgets/expense_list_item.dart`
- `mobile/test/features/expenses/presentation/expense_history_screen_fidelity_test.dart` (new)
- `.../STORY-028_shared_expenses_design_fidelity/visual-fidelity/visual-fidelity-report.md` (new)
- `.../STORY-028_shared_expenses_design_fidelity/story_master.md` (artifact checkbox)

Every changed path falls inside the mobile-dev run's declared WriteScope
(`data/runtime/parallel-runs/RUN-REQ-002_screen_flow_and_design_fidelity_audit-STORY-028-mobile-dev.json`).
No out-of-scope write occurred; in particular `mobile/lib/design_system/**` is
untouched, which is the basis for the two deferrals below.

## Design-source cross-check

Authoritative source re-read independently by the reviewer:
`cupid-app-design-system/project/Cupid Screens.dc.html` lines 835-879
(`sc-if value="{{ isExpense }}"`).

Spot-checked and confirmed accurate against the source, not merely against the
implementer's own report:

| Area | Design source | Implementation | Verdict |
|---|---|---|---|
| Screen padding | `padding:8px 16px 40px` (L836) | `_screenPadding = EdgeInsets.fromLTRB(16, 8, 16, 40)` | match |
| Summary card | `padding:20px`, `r-card`, `surf`, `box-shadow:var(--shadow)` (L837) | `_cardPadding = 20`, `radiusCard`, `colorSurface`, `elevationShadow` | match |
| Card header | `display:flex;align-items:flex-end;justify-content:space-between` (L838) | `Row(crossAxisAlignment: end)` + `Expanded` left / end-aligned right column | match |
| Total | Nunito `w900`, `31px`, `line-height:1.15`; `₫` at `16px` `var(--tx2)` (L839) | `type.display` at `fontSize: 31`, `height: 1.15`; `Text.rich` `₫` span at 16 / `colorTextMuted` | match |
| Delta | caption `11px` `tx2`; value `14px` `w800` `var(--peach)` (L840) | `_deltaCaptionSize = 11`, `_deltaValueSize = 14`, `w800`, `colors.colorPeach` | match |
| Chart plot | `gap:4px;margin-top:18px;height:76px;align-items:flex-end`, bars `flex:1` (L842-849) | `_chartBarGap/_chartTopGap/_chartHeight`, `Expanded` bars, `CrossAxisAlignment.end` | match |
| Bar radius / fills | `6px 6px 0 0`; peak `var(--grad-hot)`, rest `rgba(255,127,182,.35)` | `BorderRadius.vertical(top: 6)`; `gradientHot` on max bucket, else `colorAccentPink @ 0.35` | match — `colorAccentPink = 0xFFFF7FB6` = `rgb(255,127,182)` exactly |
| Weekday labels | separate `space-between` row, `margin-top:8px`, Roboto Mono `9.5px`, `tx2` (L851) | split-out `Row`, `SizedBox(height: 8)`, `type.labelMono` at 9.5, `colorTextMuted` | match |
| Chips | `gap:9px;margin-top:13px`; `padding:9px 15px`; `border-radius:999px`; selected `grad-hot`/`#fff`/`12.5px w800`; unselected `surf`/`tx2`/`w700`; icon `16px` with `gap:6px`; "All" label-only (L854-859) | `_chipGap/_sectionGap/_chipPaddingX/Y/_chipLabelSize/_chipIconSize/_chipIconGap`, `radiusButton`, `gradientHot`, `colorSurface`, `colorText`/`colorTextMuted`, `icon` nullable for "All" | match |
| List card | `margin-top:13px;padding:4px 17px;r-card;surf;box-shadow` (L861) | `SliverPadding(top: 13)` → `DecoratedSliver` → `SliverPadding(v:4, h:17)` | match |
| Row | `gap:13px;padding:14px 0;border-bottom:1px solid var(--line)` (L863) | `_rowGap = 13`, `EdgeInsets.symmetric(vertical: 14)`, `Border(bottom: BorderSide(colorLine))` | match |
| Icon tile | `40x40;border-radius:14px`, glyph `21px`, per-row accent fill | `_iconTileSize/_iconTileRadius/_iconSize`, `accent.withValues(alpha: 0.18)` | match |
| Row text | title `14px w700` ellipsis; `who · date` `11px` `tx2` `margin-top:2px` (L865) | `_titleSize/_subtitleSize/_subtitleGap`, `maxLines: 1`, `TextOverflow.ellipsis` | match |
| Amount | Roboto Mono `13px w500` (L866) | `type.labelMono` at `fontSize: 13`, `w500` | match |
| AC3 platform split | `sc-if isMD` → sticky bottom-right FAB (L872-874); `sc-if isIOS` → full-width CTA (L875-877) | `Scaffold.floatingActionButton` on Material; `CupidPrimaryButton` at end of content on iOS | match (placement) |

Color tokens verified directly in
`mobile/lib/design_system/tokens/cupid_color_tokens.dart` (dark theme):
`colorSurface = 0xFF241B42` (`--surf`), `colorTextMuted = 0xFFB4A6CE` (`--tx2`),
`colorPeach = 0xFFFFAB93` (`--peach`), `colorAccentPink = 0xFFFF7FB6`,
`colorLine = rgba(247,238,251,0.11)` (`--line`), `gradientHot` present. No raw
colour literal was introduced anywhere in the diff.

The implementer's note on the §3 "Thêm mới" table vs. the screen mock is
correct and was independently confirmed: the screen mock overrides the generic
iOS "nav-bar `+`" rule with a full-width CTA, and the story's own AC3 states the
"FAB vs. full-width CTA" pair explicitly. Treating the screen mock as
authoritative for this screen is the right call.

## Acceptance criteria

| AC | Verdict | Evidence |
|---|---|---|
| AC1 — layout / spacing / colour-token / typography match in dark + `vi` | MET with deferrals D-1, D-2 | Cross-check table above; every measurement traced back to `Cupid Screens.dc.html` L835-879 |
| AC2 — deviations corrected in the app, not merely documented | MET | 25 deviations landed as code in `expense_history_screen.dart` and `expense_list_item.dart`; the visual-fidelity report is evidence, not the deliverable |
| AC3 — per-platform add action preserved, not unified | MET | Platform branch uses `CupidPlatform.of(context)` (not `Platform.is*` / `defaultTargetPlatform`, so `no_fork_guard_test.dart` stays valid); Material → `Scaffold.floatingActionButton`, iOS → `CupidPrimaryButton` in content; `CupidHeader.actions` empty on both, so exactly one affordance per platform. Both branches pinned by widget tests |
| AC4 — no change to how the screen is reached | MET | No routing/entry-point file appears in the diff; `expenses_route.dart` and `ExpensesEntryPoint` untouched |

## Verification reproduced by the reviewer

Independently re-run, not taken on the implementer's word:

| Command | Reviewer result | Report claim | Match |
|---|---|---|---|
| `flutter analyze lib/features/expenses test/features/expenses` | `No issues found!` | No issues found | yes |
| `flutter test test/design_system test/features/expenses` | `+92: All tests passed!` | +92 / -0 | yes |

The design-system suite included in that run covers `no_fork_guard_test.dart`,
`contrast_test.dart`, `theme_matrix_test.dart` and `adaptive_widgets_test.dart`,
so the platform-fork guard and the contrast floor are confirmed still green
after the chip foreground/background token swap (E7) and the peach delta (C8).

The new `expense_history_screen_fidelity_test.dart` assertions are substantive
rather than tautological: they pin the Scaffold FAB slot and the absence of the
CTA on Material, the inverse pair plus the `vi` label "Ghi một khoản" on iOS,
the description-as-title rule, the 18% category-accent tile fill, and the
last-row divider suppression.

## Deferred items (out of WriteScope, carried forward)

Both require an in-place change to an existing shared component under
`mobile/lib/design_system/adaptive/**`, which the mobile-dev run's WriteScope
excludes entirely. Deferring them was correct; forking a local copy would have
been worse.

| Id | Gap | Design source | Current shared component | Follow-up owner |
|---|---|---|---|---|
| D-1 | Material FAB visual detail | `60x60`, `border-radius:20px`, `background:var(--grad-hot)`, `box-shadow:0 8px 24px rgba(255,127,182,.45)`, glyph `27px` (L873) | `CupidAddAction` renders a 56x56 `FloatingActionButton`, `radiusButton` (999), flat `colorAccentPink` | design-system-scoped story on `cupid_add_action.dart` |
| D-2 | iOS full-width CTA visual detail | `height:52px`, `background:var(--grad-hot)`, `box-shadow:var(--glow)`, label `15.5px w800`, leading `add` glyph `21px` with `8px` gap (L876) | `CupidPrimaryButton` renders `height: tapTarget` (44 on iOS), flat `colorAccentPink`, no glow, no leading icon, `type.body` (17px w400) | design-system-scoped story on `cupid_primary_button.dart` |

Both widgets are shared with Dream Jar, Gallery and Home, so a single
shared-component story is the right vehicle. AC1's "match exactly" is therefore
not literally satisfied on the two add-action affordances; this is the sole
reason the outcome is DEFERRED_ONLY rather than CLEAN.

## Minor findings (non-blocking)

None of these block an acceptance criterion. Recommend folding M-1 into the
same shared-component follow-up as D-1, since the two interact.

- **M-1 — the Material FAB reserves no flow space.** The mock's FAB is
  `position:sticky;bottom:16px` inside the content flow with `margin-top:16px`,
  followed by the container's `padding-bottom:40px`, so no row is ever behind
  it. The implementation uses `Scaffold.floatingActionButton`, a pure overlay,
  while the scroll view's bottom padding stays at the mock's 40. At the current
  56x56 FAB the overlap is marginal (FAB occupies y=16..72 from the viewport
  bottom; the last row's amount sits at roughly y=71..84), but once D-1 raises
  the FAB to 60x60 the FAB top moves to y=76 and it will visibly cover the last
  row's amount. Fix the Material-only bottom padding at the same time as D-1.
- **M-2 — empty filtered result now renders a bare card strip.** The new
  `DecoratedSliver` list-card decoration (F1) is unconditional, so selecting a
  category chip that matches no loaded row draws an ~8px-tall `colorSurface`
  strip with the card shadow instead of nothing. Reachable by a single chip tap;
  cosmetic only. The mock has no filtered-empty state to copy.
- **M-3 — inaccurate justification in the visual-fidelity report (docs only).**
  Line 109 states the last row omits its hairline "as in the mock". The mock
  actually keeps `border-bottom` on *every* `sc-for` row because the
  "Xem tất cả 18 khoản" footer (L869) follows. Suppressing the trailing hairline
  is nevertheless the correct call here, precisely because that footer is
  correctly excluded as out of scope — a trailing hairline with nothing beneath
  it would itself be a deviation. Only the stated reason is wrong, not the code.
- **M-4 — 1px gap.** The total block sits at `CupidSpacing.xs` (4) below the
  period caption where the mock specifies `margin-top:5px` (L839). Below the
  threshold of visible deviation.

## Judgement calls checked and upheld

- Chip and row `minHeight` held at `platformTokens.tapTarget` (44pt/48dp) even
  though the mock's chip box computes to ~33px. The same design source mandates
  the tap-target minimum in its own §3 platform-adaptation table, so the
  accessibility rule correctly wins over the pixel box.
- Copy left untouched (period label, delta as absolute VND rather than "+12%",
  item count retained). AC1 enumerates layout, spacing, colour/token usage and
  typography — not copy — and `mobile/lib/l10n/**` plus
  `presentation/expense_month_summary.dart` are outside WriteScope. Keeping the
  `ExpenseStrings.monthDelta` word pairing also preserves the `ux/uiux-spec.md`
  §7 non-colour-only signal requirement alongside the new peach/green pair.
- The mock's "Xem tất cả 18 khoản" footer link correctly not added — this screen
  is already the full paginated history, so the footer is the collapsed-preview
  affordance and adding it would be a new interaction, explicitly Out of Scope.
- Off-grid constants declared file-private at their single consumer rather than
  promoted to shared tokens, following the existing `_materialPrimaryCtaRadius`
  precedent. No shared token was invented for one screen's use.
- Per-bar `Semantics` retained after the weekday label row was split out, and
  the category name kept in the row `Semantics` label after the visible title
  became the description. No assistive-tech information was lost.
- Pagination stayed lazy: `SliverList.builder` inside the card, and the
  `_scrollController` moved intact to the `CustomScrollView`, so infinite scroll
  is unchanged. Loading, never-synced and genuinely-empty states are all still
  returned ahead of the scroll view.

## Residual risks

- No on-device or emulator capture backs this review; the fidelity evidence is
  source-to-source plus widget tests. M-1's overlap geometry is reasoned from
  Flutter's default `FloatingActionButtonLocation.endFloat` metrics rather than
  observed, so it should be confirmed visually when D-1 is implemented.
- Light theme and `en` locale received no dedicated visual pass, consistent with
  the story's Out of Scope and OQ5. Token-level changes are shared across all
  four combinations and `theme_matrix_test.dart` / `contrast_test.dart` are
  green, so the risk is low but not zero.

REVIEW_COMPLETE: YES
