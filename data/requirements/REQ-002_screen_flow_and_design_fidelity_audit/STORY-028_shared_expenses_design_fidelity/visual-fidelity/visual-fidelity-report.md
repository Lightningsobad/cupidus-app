# Visual Fidelity Report: STORY-028 Shared Expenses

Story: STORY-028 Design Fidelity — Shared Expenses
Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Lane: mobile
Configuration audited: dark theme + `vi` locale, both platform silhouettes
(`CupidPlatform.ios` and `CupidPlatform.material`)

## Design source

Locked source: `cupid-app-design-system` (confirmed by `detect_design_source.py`).

Authoritative sections read for this screen:

- `cupid-app-design-system/project/Cupid Screens.dc.html` lines 835-879 —
  the `sc-if value="{{ isExpense }}"` block, which is the Shared Expenses
  screen mock (summary card, weekday chart, category chips, expense list
  card, and both platform variants of the add-expense action).
- `cupid-app-design-system/project/Cupid App.dc.html` lines 150-163 — the §3
  "Platform adaptation" table (tap target 44pt/48dp; "Thêm mới" row).

### Note on the §3 table vs. the screen mock

The generic §3 table's "Thêm mới" row reads *iOS = "Nút + trên nav bar",
Android = "FAB góc dưới phải"*. The Shared Expenses screen mock overrides the
iOS half of that generic rule: `sc-if isIOS` renders a **full-width CTA at the
end of the content** ("Ghi một khoản", 52px, pill radius, hot gradient, glow),
not a nav-bar `+`. `sc-if isMD` keeps the **bottom-right FAB**.

The story's own AC3 states the pair explicitly as "FAB vs. full-width CTA", so
the screen mock is treated as authoritative for this screen and the generic
table remains authoritative for tap targets. The per-platform difference is
preserved, not unified.

## Files changed

- `mobile/lib/features/expenses/presentation/screens/expense_history_screen.dart`
- `mobile/lib/features/expenses/presentation/widgets/expense_list_item.dart`
- `mobile/test/features/expenses/presentation/expense_history_screen_fidelity_test.dart` (new)

No file under `mobile/lib/design_system/**` was modified. No new design token
was required, so the STORY-003/006 additive-token precedent was not invoked.

## Deviations found and fixed

### AC3 — platform-adaptive add-expense action

| # | Deviation | Design source | Was | Now |
|---|---|---|---|---|
| A1 | Add action placed in the header on **both** platforms | `isMD` → sticky bottom-right FAB; `isIOS` → full-width CTA in content | `CupidHeader.actions: [CupidAddAction(...)]` — on Material this rendered a `FloatingActionButton` inside an app-bar actions slot | Material: `Scaffold.floatingActionButton: CupidAddAction(...)`, anchored bottom-right by `Scaffold`'s default `FloatingActionButtonLocation`. iOS: `CupidPrimaryButton` with `ExpenseStrings.addActionLabel` at the end of the scrolling content, 14px above the content end. Header `actions` is now empty on both platforms, so there is still exactly one add affordance per platform. |

The platform branch uses `CupidPlatform.of(context)`, matching the existing
`login_screen.dart` / `welcome_screen.dart` / `gallery_viewer_screen.dart`
precedent, and is not a `Platform.is*` / `defaultTargetPlatform` fork (the
`no_fork_guard_test.dart` patterns still pass).

### AC1 — screen shell

| # | Deviation | Design source | Was | Now |
|---|---|---|---|---|
| B1 | Summary card + chips were pinned while only the list scrolled | The whole `isExpense` block is one scrolling column (`padding:8px 16px 40px`) | `Column` with a pinned header block and an `Expanded(ListView)` | `CustomScrollView` + `SliverMainAxisGroup`; summary card, freshness caption, chips, list card and the iOS CTA all scroll together. Pagination stays lazy (`SliverList.builder`), so the infinite-scroll behaviour is unchanged. |
| B2 | Screen padding | `padding:8px 16px 40px` | ad-hoc per-section margins (card `EdgeInsets.all(16)`, chips `horizontal: 16`, list `vertical: 8`) | one `SliverPadding` of `EdgeInsets.fromLTRB(16, 8, 16, 40)` |
| B3 | Section gap between summary card → chips → list card | `margin-top:13px` | `SizedBox(height: CupidSpacing.xs)` (4) / none | uniform `13` top gap on the chips row and the list card |

### AC1 — month summary card

| # | Deviation | Design source | Was | Now |
|---|---|---|---|---|
| C1 | Card had no elevation | `box-shadow:var(--shadow)` | flat `colorSurface` container | `boxShadow: platformTokens.elevationShadow` |
| C2 | Card padding | `padding:20px` | `CupidSpacing.md` (16) | `20` |
| C3 | Header was a single left column | two-column `flex-end` row: left = period caption + total, right = right-aligned "vs last month" caption + delta value | vertical `Column` of 4 stacked lines | `Row(crossAxisAlignment: end)` with an `Expanded` left column and a right-aligned delta column |
| C4 | Total typography | Nunito, `font-weight:900`, `font-size:31px`, `line-height:1.15` | `type.cardTitle` (platform UI font, 22px, w600→w800 override) | `type.display` (Nunito w900) at `fontSize: 31`, `height: 1.15` |
| C5 | Currency symbol treatment | `₫` inline at `font-size:16px; color:var(--tx2)` | `' ₫'` appended at the same size/colour as the number | `Text.rich` with a `₫` span at 16px / `colorTextMuted` |
| C6 | Period caption size | `font-size:12px` | `type.caption` (13) | `type.caption` at `fontSize: 12` |
| C7 | Delta caption/value sizes | caption `11px`; value `14px`, `font-weight:800` | both `type.caption` (13, w400) | caption 11, value 14 w800 |
| C8 | Delta increase colour | `var(--peach)` | `colors.colorRed` | `colors.colorPeach` (decrease keeps `colorGreen`; the design mock only shows the increase case) |
| C9 | Chart top gap | `margin-top:18px` | `CupidSpacing.md` (16) | `18` |

### AC1 — weekday bar chart

| # | Deviation | Design source | Was | Now |
|---|---|---|---|---|
| D1 | Bar sizing | bars are `flex:1` with `gap:4px` inside a `height:76px` plot | fixed `width: 12` bars in a `spaceBetween` row, max height `40` | `Expanded` bars separated by 4px gaps inside a `SizedBox(height: 76)`, `FractionallySizedBox` heights, bottom-aligned |
| D2 | Bar corner radius | `border-radius:6px 6px 0 0` (top only) | `BorderRadius.circular(4)` (all corners) | `BorderRadius.vertical(top: Radius.circular(6))` |
| D3 | Bar fills | non-peak bars `rgba(255,127,182,.35)`; the peak bar `var(--grad-hot)` | every bar flat `colorAccentPink` | non-peak `colors.colorAccentPink.withValues(alpha: 0.35)`; the tallest bucket uses `colors.gradientHot` |
| D4 | Weekday labels | own `space-between` row `8px` below the plot, `'Roboto Mono'`, `9.5px`, `var(--tx2)` | one label per bar inside each bar's column, `type.caption` at `fontSize: 10` | separate `spaceBetween` row, `SizedBox(height: 8)` above, `type.labelMono` at `fontSize: 9.5`, `colorTextMuted` |

Per-bar `Semantics` labels are retained on the bars, so the chart stays
screen-reader legible after the label row was split out.

### AC1 — category chips

| # | Deviation | Design source | Was | Now |
|---|---|---|---|---|
| E1 | Chip shape | `border-radius:999px` (pill) | `platformTokens.radiusSmall` (16) | `platformTokens.radiusButton` (999 on both platforms) |
| E2 | Selected chip fill | `background:var(--grad-hot)` | flat `colors.colorAccentPink` | `gradient: colors.gradientHot` |
| E3 | Unselected chip fill | `background:var(--surf)` | `colors.colorSurfaceAlt` | `colors.colorSurface` |
| E4 | Chip padding | `padding:9px 15px` | `horizontal: 8, vertical: 4` | `horizontal: 15, vertical: 9` |
| E5 | Chip gap | `gap:9px` | `CupidSpacing.xs` (4) | `9` for both `spacing` and `runSpacing` |
| E6 | Chip label typography | `12.5px`; selected `w800`, unselected `w700` | `type.caption` (13) at `w600` for both | `fontSize: 12.5`; `w800` selected / `w700` unselected |
| E7 | Chip label colour | selected `#fff`; unselected `var(--tx2)` | selected `colorBackground`; unselected `colorText` | selected `colorText` (the nearest token to `#fff`; a raw literal is forbidden by `no_fork_guard_test.dart`); unselected `colorTextMuted` |
| E8 | Category chips had no icon | each non-"All" chip carries its category glyph at `font-size:16px` with a `6px` gap | label-only chips | leading `Icon` at 16 with a 6px gap, reusing `ExpenseListItem.iconFor` (renamed from the previously private `_iconFor`) so the chip and the list row cannot drift apart. The "All" chip stays label-only, matching the mock. |

### AC1 — expense list

| # | Deviation | Design source | Was | Now |
|---|---|---|---|---|
| F1 | List had no card container | rows sit inside `border-radius:var(--r-card); background:var(--surf); box-shadow:var(--shadow); padding:4px 17px` | rows rendered directly on the scaffold background | `DecoratedSliver` with `colorSurface`, `platformTokens.radiusCard` and `platformTokens.elevationShadow`, wrapping a `SliverPadding` of `vertical: 4, horizontal: 17` around the lazy `SliverList` |
| F2 | No row separator | `border-bottom:1px solid var(--line)` | none | `Border(bottom: BorderSide(color: colors.colorLine))` via a new `ExpenseListItem.showDivider` flag; the last row in the card omits it, because the mock's trailing hairline exists only to separate the last row from the out-of-scope "Xem tất cả 18 khoản" footer (correction recorded by STORY-043's round-1 review, RWB-20260816-011 D-b: the mock in fact puts `border-bottom` on every row per `Cupid Screens.dc.html` L871) |
| F3 | Row padding | `padding:14px 0` (horizontal inset comes from the card) | `vertical: 8, horizontal: 16` on every row | `vertical: 14` only |
| F4 | Category glyph had no tile | `40x40`, `border-radius:14px`, background = accent at 18%, glyph at `21px` in the accent colour | a bare `Icon` at the default size, always `colorAccentPurple` | 40x40 `Container` at radius 14, `accent.withValues(alpha: 0.18)` fill, `Icon` at 21 in the accent. Accent is per-category (`food`→`colorAmber`, `date`→`colorAccentPink`, `travel`→`colorMint`, `shopping`→`colorAccentPurple`, `other`→`colorPeach`), matching the mock's one-accent-per-row tinting. |
| F5 | Row gap | `gap:13px` | `CupidSpacing.sm` (8) | `13` |
| F6 | Row was three lines | two lines: title (`14px`, `w700`, ellipsis) then `who · date` (`11px`, `var(--tx2)`, `margin-top:2px`) | category name (`type.body`, 17px w400), `who · date` (13), and a third description line | title is the expense description with the category name as fallback when the description is empty, at `fontSize: 14, w700, maxLines: 1, ellipsis`; subtitle `who · date` at `fontSize: 11` with a 2px gap. The category name remains in the row's `Semantics` label, so nothing is lost to assistive tech. |
| F7 | Amount typography | `'Roboto Mono'`, `13px`, `font-weight:500` | `type.labelMono` w500 with no size (inherits the ambient 14) | `type.labelMono` at `fontSize: 13`, `w500` |

## Deliberately not changed

| Item | Reason |
|---|---|
| Chip and row minimum height stays `platformTokens.tapTarget` (44pt / 48dp) | The mock's chip box (9+9+~15 ≈ 33px) is below the platform minimum hit target that the same design source mandates in its §3 platform-adaptation table. The accessibility rule wins; the existing `ConstrainedBox(minHeight: tapTarget)` + `Center` treatment is kept. |
| Copy is unchanged (`ExpenseStrings`) | AC1 enumerates layout, spacing, colour/token usage and typography. Copy is governed by `ux/uiux-spec.md`, from which `expense_strings.dart` was transcribed verbatim, and `mobile/lib/l10n/**` is outside this story's WriteScope. |
| Month-total label stays "Tổng tháng này" rather than the mock's literal period ("Tháng 7/2026") | Copy, per the row above. Rendering a live period label would also need a new `month` field on `ExpenseMonthSummary` (`presentation/expense_month_summary.dart` + `expense_history_cubit.dart`), both outside WriteScope. |
| Delta value stays an absolute VND figure rather than the mock's "+12%" | Copy/number-format, per the row above. A percentage is also undefined when `previousMonthTotalVnd` is 0, which the mock has no state for. `ExpenseStrings.monthDelta` keeps the increase/decrease word pairing that `ux/uiux-spec.md` §7 requires so the delta is never colour-only. |
| Item-count caption is kept in the summary card's left column | The mock's card carries no item count (it appears on the home dashboard entry row instead). Removing it would drop user-visible information, which is outside a fidelity fix; it is rendered as an 11px muted caption inside the left column so it does not disturb the two-column header geometry. |
| The mock's "Xem tất cả 18 khoản" footer link is not added | This screen already *is* the full paginated history with infinite scroll; the footer link in the mock is the collapsed-preview affordance. Adding it would be a new interaction, explicitly listed in the story's Out of Scope. |

## Deferred — out of WriteScope

Both items below would require modifying an existing shared component in
`mobile/lib/design_system/adaptive/**` in place. The story's Forbidden clause
permits only *additive* tokens there and never an in-place change to an
existing shared component, so the placement was corrected (see A1) while the
component-internal pixel values were left alone.

| Item | Design source | Current shared component | Owner |
|---|---|---|---|
| Material FAB visual detail | `60x60`, `border-radius:20px`, `background:var(--grad-hot)`, `box-shadow:0 8px 24px rgba(255,127,182,.45)` (≈ `colors.glowShadow`), glyph `27px` | `CupidAddAction` renders a default 56x56 `FloatingActionButton` with `radiusButton` (999) and a flat `colorAccentPink` fill | `design_system/adaptive/cupid_add_action.dart` — needs a design-system-scoped story |
| iOS full-width CTA visual detail | `height:52px`, `background:var(--grad-hot)`, `box-shadow:var(--glow)`, label `15.5px w800`, leading `add` glyph at `21px` with an `8px` gap | `CupidPrimaryButton` renders `height: tapTarget` (44 on iOS), a flat `colorAccentPink` fill, no glow, no leading icon, and `type.body` (17px w400) | `design_system/adaptive/cupid_primary_button.dart` — needs a design-system-scoped story |

Both deferrals are consistent across every screen that consumes those two
widgets (Dream Jar, Gallery, Home), so fixing them belongs in one shared-component
story rather than being forked here.

## Off-grid constants

The design source uses several measurements that fall between `CupidSpacing`
steps (8/13/14/17/20 and the type sizes 9.5/11/12/12.5/14/15.5/31). They are
declared as file-private constants at their single consumer, transcribed
verbatim from the mock, following the existing `_materialPrimaryCtaRadius`
precedent in `cupid_primary_button.dart`. No new shared token was added and no
raw colour literal was introduced.

## Verification

All commands run from
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-028/mobile`
with `PATH=/Users/alantravala/flutter/bin:$PATH` (Flutter 3.44.1 stable, Dart 3.12.1).

| Command | Result |
|---|---|
| `flutter gen-l10n` | OK (regenerated `lib/l10n/generated/`, which is generated output and was absent in a fresh worktree) |
| `flutter analyze lib/features/expenses test/features/expenses` | **No issues found** (0 errors, 0 warnings, 0 infos) |
| `flutter analyze lib test` | 77 issues, all `info`, all pre-existing in untouched files (`pair_gate_shell.dart`, `dream_jar/**`, `gallery/**`, `home/**`, `pairing/**`, `reminders/**`, `vibes/**`). **0 new** |
| `flutter test test/features/expenses/presentation/expense_history_screen_fidelity_test.dart` | **+4 / -0** — All tests passed |
| `flutter test test/design_system test/features/expenses` | **+92 / -0** — All tests passed (includes `no_fork_guard_test.dart`, `contrast_test.dart`, `theme_matrix_test.dart`, `adaptive_widgets_test.dart`) |
| `flutter test` (full suite) | **+924 / -0** — All tests passed |

### New test coverage

`mobile/test/features/expenses/presentation/expense_history_screen_fidelity_test.dart`,
pumped in dark theme + `vi` locale via `CupidPlatformOverride`:

- AC3 / Material: `CupidAddAction` is present, is wired into
  `Scaffold.floatingActionButton`, `CupidPrimaryButton` is absent, and
  `CupidHeader.actions` is empty.
- AC3 / iOS: `CupidPrimaryButton` is present with the `vi` label
  "Ghi một khoản", `CupidAddAction` is absent, and
  `Scaffold.floatingActionButton` is null.
- AC1: the row title renders the expense description and the icon tile is
  filled with the category accent at 18% alpha.
- AC1: every row but the last carries the hairline divider.

## Acceptance criteria status

| AC | Status | Evidence |
|---|---|---|
| AC1 — layout / spacing / colour-token / typography match in dark + `vi` | MET, with the documented shared-component deferrals | Sections B–F above; `expense_history_screen_fidelity_test.dart`; `no_fork_guard_test.dart` and `contrast_test.dart` still green |
| AC2 — deviations corrected in the app, not merely documented | MET | 25 deviations fixed in `expense_history_screen.dart` and `expense_list_item.dart` |
| AC3 — per-platform add action preserved, not unified | MET | Deviation A1; both platform assertions in the new test |
| AC4 — no change to how the screen is reached | MET | `expenses_route.dart` / `ExpensesEntryPoint` untouched; `expenses_entry_point_test.dart` still green |
