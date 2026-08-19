import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/cupid_database.dart' show ExpenseCacheRow;
import '../../../../core/database/daos/expense_dao.dart';
import '../../../../core/realtime/backend_user_id_store.dart';
import '../../../../design_system/design_system.dart';
import '../../data/expense_category.dart';
import '../../data/expenses_repository.dart';
import '../expense_history_cubit.dart';
import '../expense_month_summary.dart';
import '../expense_strings.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/expense_list_item.dart';

/// Off-grid measurements transcribed verbatim from the locked design source
/// (`cupid-app-design-system/project/Cupid Screens.dc.html`, `isExpense`
/// block). They sit between `CupidSpacing` steps, so they are file-private
/// constants at the single consumer rather than invented token values (same
/// precedent as `_materialPrimaryCtaRadius` in `cupid_primary_button.dart`).
const EdgeInsets _screenPadding = EdgeInsets.fromLTRB(16, 8, 16, 40);
const double _cardPadding = 20;
const double _sectionGap = 13;
const double _periodCaptionSize = 12;
const double _totalSize = 31;
const double _totalHeight = 1.15;
const double _currencySymbolSize = 16;
const double _deltaCaptionSize = 11;
const double _deltaValueSize = 14;
const double _chartTopGap = 18;
const double _chartHeight = 76;
const double _chartBarGap = 4;
const double _chartBarRadius = 6;
const double _chartLabelGap = 8;
const double _chartLabelSize = 9.5;
const double _chipGap = 9;
const double _chipPaddingY = 9;
const double _chipPaddingX = 15;
const double _chipLabelSize = 12.5;
const double _chipIconSize = 16;
const double _chipIconGap = 6;
const double _listCardPaddingY = 4;
const double _listCardPaddingX = 17;
const double _addActionTopGap = 14;
const double _inactiveBarOpacity = 0.35;

/// Shared expense history screen. Layout, spacing, colour/token usage and
/// typography follow the locked design source's `isExpense` screen; the
/// add-expense action is platform-adaptive by design (Material anchors a
/// FAB bottom-right, iOS uses a full-width CTA at the end of the content),
/// so the two treatments are deliberately not unified.
class ExpenseHistoryScreen extends StatelessWidget {
  const ExpenseHistoryScreen({
    super.key,
    required this.repository,
    required this.dao,
    required this.backendUserIdStore,
    this.onBack,
  });

  final ExpensesRepository repository;
  final ExpenseDao dao;
  final BackendUserIdStore backendUserIdStore;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExpenseHistoryCubit>(
      create: (_) => ExpenseHistoryCubit(repository: repository, dao: dao),
      child: _ExpenseHistoryView(
        repository: repository,
        backendUserIdStore: backendUserIdStore,
        onBack: onBack,
      ),
    );
  }
}

class _ExpenseHistoryView extends StatefulWidget {
  const _ExpenseHistoryView({
    required this.repository,
    required this.backendUserIdStore,
    required this.onBack,
  });

  final ExpensesRepository repository;
  final BackendUserIdStore backendUserIdStore;
  final VoidCallback? onBack;

  @override
  State<_ExpenseHistoryView> createState() => _ExpenseHistoryViewState();
}

class _ExpenseHistoryViewState extends State<_ExpenseHistoryView> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final ScrollPosition position = _scrollController.position;
    if (!_isLoadingMore &&
        position.pixels >= position.maxScrollExtent - 200) {
      unawaited(_loadMore());
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    await context.read<ExpenseHistoryCubit>().loadMore();
    if (mounted) setState(() => _isLoadingMore = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Single entry point into the Add-Expense sheet (`ux/uiux-spec.md` §3):
  /// one add affordance, no second separately-styled one.
  /// [ExpenseHistoryCubit.refresh] runs on success so the list/summary pick
  /// up the new row; `AddExpenseCubit` itself never touches Drift.
  Future<void> _openAddSheet(BuildContext context) async {
    final ExpenseHistoryCubit cubit = context.read<ExpenseHistoryCubit>();
    await AddExpenseSheet.show(
      context,
      repository: widget.repository,
      isOffline: () => cubit.state.isOffline,
      onSaved: cubit.refresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final bool isIos = CupidPlatform.of(context) == CupidPlatform.ios;

    return Scaffold(
      appBar: CupidHeader(
        title: ExpenseStrings.screenTitle(context),
        onBack: widget.onBack,
      ),
      // AC3: Material anchors the add action as a bottom-right FAB; iOS
      // renders it as a full-width CTA inside the scrolling content below.
      floatingActionButton: isIos
          ? null
          : Semantics(
              button: true,
              label: ExpenseStrings.addActionLabel(context),
              child: CupidAddAction(onPressed: () => _openAddSheet(context)),
            ),
      body: BlocBuilder<ExpenseHistoryCubit, ExpenseHistoryState>(
        builder: (context, state) {
          // Nothing durably cached yet and the first read-through attempt
          // has not settled — distinct from [ExpenseHistoryState
          // .isNeverSynced], which requires the attempt to have completed.
          if (!state.hasCompletedInitialFetch && state.rows.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isNeverSynced) {
            return _EmptyState(
              colors: colors,
              message: ExpenseStrings.emptyNeverSynced(context),
              icon: Icons.cloud_off,
            );
          }
          if (state.isGenuinelyEmpty) {
            return _EmptyState(
              colors: colors,
              message: ExpenseStrings.emptyZeroExpenses(context),
              icon: Icons.receipt_long,
            );
          }

          final List<ExpenseCacheRow> filtered = state.filteredRows;
          return CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverPadding(
                padding: _screenPadding,
                sliver: SliverMainAxisGroup(
                  slivers: <Widget>[
                    if (state.summary != null)
                      SliverToBoxAdapter(
                        child: _MonthSummaryCard(
                          colors: colors,
                          summary: state.summary!,
                        ),
                      ),
                    if (state.showFreshnessCaption)
                      SliverToBoxAdapter(
                        child: _FreshnessCaption(
                          colors: colors,
                          syncedAt: state.lastSuccessfulSyncAt!,
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: _CategoryChips(
                        selected: state.selectedCategory,
                        onChanged: context
                            .read<ExpenseHistoryCubit>()
                            .categorySelected,
                      ),
                    ),
                    _ExpenseListCard(
                      rows: filtered,
                      backendUserIdStore: widget.backendUserIdStore,
                      isLoadingMore: _isLoadingMore,
                    ),
                    if (isIos)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: _addActionTopGap,
                          ),
                          child: CupidPrimaryButton(
                            label: ExpenseStrings.addActionLabel(context),
                            leadingIcon: CupidIcons.add,
                            onPressed: () => _openAddSheet(context),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The design source stacks the rows inside one surface card with a shared
/// horizontal inset, so the card decoration wraps the lazily-built
/// [SliverList] rather than each row.
class _ExpenseListCard extends StatelessWidget {
  const _ExpenseListCard({
    required this.rows,
    required this.backendUserIdStore,
    required this.isLoadingMore,
  });

  final List<ExpenseCacheRow> rows;
  final BackendUserIdStore backendUserIdStore;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return SliverPadding(
      padding: const EdgeInsets.only(top: _sectionGap),
      sliver: DecoratedSliver(
        decoration: BoxDecoration(
          color: colors.colorSurface,
          borderRadius: BorderRadius.circular(platformTokens.radiusCard),
          boxShadow: platformTokens.elevationShadow,
        ),
        sliver: SliverPadding(
          padding: const EdgeInsets.symmetric(
            vertical: _listCardPaddingY,
            horizontal: _listCardPaddingX,
          ),
          sliver: SliverList.builder(
            itemCount: rows.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= rows.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: CupidSpacing.md),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ExpenseListItem(
                row: rows[index],
                backendUserIdStore: backendUserIdStore,
                // The design source draws a hairline under every row except
                // the last one in the card.
                showDivider: index < rows.length - 1,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MonthSummaryCard extends StatelessWidget {
  const _MonthSummaryCard({required this.colors, required this.summary});

  final CupidColorTokens colors;
  final ExpenseMonthSummary summary;

  static final NumberFormat _vndFormat = NumberFormat.decimalPattern(
    'vi_VN',
  );

  @override
  Widget build(BuildContext context) {
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final num? delta = summary.deltaVnd;
    final num maxWeekdayVnd = summary.weekdayTotalsVnd.fold<num>(
      0,
      (num max, num value) => value > max ? value : max,
    );

    return Container(
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      ExpenseStrings.monthTotalLabel(context),
                      style: type.caption.copyWith(
                        color: colors.colorTextMuted,
                        fontSize: _periodCaptionSize,
                      ),
                    ),
                    const SizedBox(height: CupidSpacing.xs),
                    Text.rich(
                      TextSpan(
                        text: _vndFormat.format(summary.totalVnd),
                        children: <InlineSpan>[
                          TextSpan(
                            text: '₫',
                            style: TextStyle(
                              fontSize: _currencySymbolSize,
                              color: colors.colorTextMuted,
                            ),
                          ),
                        ],
                      ),
                      style: type.display.copyWith(
                        color: colors.colorText,
                        fontSize: _totalSize,
                        height: _totalHeight,
                      ),
                    ),
                    Text(
                      ExpenseStrings.itemCount(context, summary.itemCount),
                      style: type.caption.copyWith(
                        color: colors.colorTextMuted,
                        fontSize: _deltaCaptionSize,
                      ),
                    ),
                  ],
                ),
              ),
              // A positive delta is a spending increase vs. last month, so it
              // is paired with the warmer/peach accent; the word pairing in
              // `ExpenseStrings.monthDelta` keeps the signal from being
              // colour-only (`ux/uiux-spec.md` §7).
              if (delta != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      ExpenseStrings.monthDelta(context, delta),
                      textAlign: TextAlign.end,
                      style: type.caption.copyWith(
                        color: colors.colorTextMuted,
                        fontSize: _deltaCaptionSize,
                      ),
                    ),
                    const SizedBox(height: CupidSpacing.xs),
                    Text(
                      '${delta >= 0 ? '+' : '-'}'
                      '${_vndFormat.format(delta.abs())} ₫',
                      style: type.caption.copyWith(
                        color: delta >= 0
                            ? colors.colorPeach
                            : colors.colorGreen,
                        fontSize: _deltaValueSize,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: _chartTopGap),
          _WeekdayBarChart(
            weekdayTotalsVnd: summary.weekdayTotalsVnd,
            maxValueVnd: maxWeekdayVnd,
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _WeekdayBarChart extends StatelessWidget {
  const _WeekdayBarChart({
    required this.weekdayTotalsVnd,
    required this.maxValueVnd,
    required this.colors,
  });

  /// 7 buckets, `[0]` = Monday .. `[6]` = Sunday
  /// (`ExpenseMonthSummary.weekdayTotalsVnd`).
  final List<num> weekdayTotalsVnd;
  final num maxValueVnd;
  final CupidColorTokens colors;

  /// The design source's shortest bar is ~30% of the plot height; a bucket
  /// with no spend still needs a visible baseline sliver.
  static const double _minBarFraction = 0.02;

  @override
  Widget build(BuildContext context) {
    final CupidTypographyTokens type = context.cupidType;
    final BorderRadius barRadius = const BorderRadius.vertical(
      top: Radius.circular(_chartBarRadius),
    );

    return Column(
      children: <Widget>[
        SizedBox(
          height: _chartHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              for (int i = 0; i < 7; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: _chartBarGap),
                Expanded(
                  child: Semantics(
                    label:
                        '${ExpenseStrings.weekdayShortLabel(context, i + 1)}: '
                        '${weekdayTotalsVnd[i]}',
                    child: FractionallySizedBox(
                      heightFactor: maxValueVnd <= 0
                          ? _minBarFraction
                          : (weekdayTotalsVnd[i] / maxValueVnd)
                                .clamp(_minBarFraction, 1.0)
                                .toDouble(),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          // The tallest bucket is the design source's
                          // highlighted bar (hot gradient); the rest are the
                          // same accent at reduced opacity.
                          color:
                              maxValueVnd > 0 &&
                                  weekdayTotalsVnd[i] == maxValueVnd
                              ? null
                              : colors.colorAccentPink.withValues(
                                  alpha: _inactiveBarOpacity,
                                ),
                          gradient:
                              maxValueVnd > 0 &&
                                  weekdayTotalsVnd[i] == maxValueVnd
                              ? colors.gradientHot
                              : null,
                          borderRadius: barRadius,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: _chartLabelGap),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            for (int i = 0; i < 7; i++)
              Text(
                ExpenseStrings.weekdayShortLabel(context, i + 1),
                style: type.labelMono.copyWith(
                  color: colors.colorTextMuted,
                  fontSize: _chartLabelSize,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _FreshnessCaption extends StatelessWidget {
  const _FreshnessCaption({required this.colors, required this.syncedAt});

  final CupidColorTokens colors;
  final DateTime syncedAt;

  @override
  Widget build(BuildContext context) {
    final CupidTypographyTokens type = context.cupidType;
    return Padding(
      padding: const EdgeInsets.only(top: CupidSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // `CupidIcons` has no verified codepoint for an offline/cloud
          // glyph — same precedent as `chat_screen.dart`'s lock icon and
          // `ExpenseListItem`'s category icons.
          Icon(Icons.cloud_off, size: 14, color: colors.colorTextMuted),
          const SizedBox(width: CupidSpacing.xs),
          Text(
            ExpenseStrings.freshnessCaption(context, syncedAt),
            style: type.caption.copyWith(color: colors.colorTextMuted),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onChanged});

  /// `null` = "All" selected (`ux/uiux-spec.md` §4).
  final ExpenseCategory? selected;
  final ValueChanged<ExpenseCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: _sectionGap),
      child: Wrap(
        spacing: _chipGap,
        runSpacing: _chipGap,
        children: <Widget>[
          _CategoryChip(
            label: ExpenseStrings.categoryAll(context),
            isSelected: selected == null,
            onTap: () => onChanged(null),
          ),
          for (final ExpenseCategory category in ExpenseCategory.values)
            _CategoryChip(
              label: ExpenseStrings.category(context, category),
              icon: ExpenseListItem.iconFor(category),
              isSelected: selected == category,
              onTap: () => onChanged(category),
            ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;

  /// `null` for the "All" chip, which the design source draws label-only.
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    final BorderRadius radius = BorderRadius.circular(
      platformTokens.radiusButton,
    );
    final Color foreground = isSelected
        ? colors.colorText
        : colors.colorTextMuted;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: ConstrainedBox(
        // The design source's chip box is shorter than the platform minimum
        // hit target (§3 platform-adaptation table: 44pt/48dp), which wins.
        constraints: BoxConstraints(minHeight: platformTokens.tapTarget),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isSelected ? null : colors.colorSurface,
            gradient: isSelected ? colors.gradientHot : null,
            borderRadius: radius,
          ),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: radius,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _chipPaddingX,
                  vertical: _chipPaddingY,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (icon != null) ...<Widget>[
                      Icon(icon, size: _chipIconSize, color: foreground),
                      const SizedBox(width: _chipIconGap),
                    ],
                    Text(
                      label,
                      style: type.caption.copyWith(
                        color: foreground,
                        fontSize: _chipLabelSize,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.colors,
    required this.message,
    required this.icon,
  });

  final CupidColorTokens colors;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final CupidTypographyTokens type = context.cupidType;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CupidSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Paired with [message] below — never colour/icon-only
            // (`ux/uiux-spec.md` §7).
            Icon(icon, size: 40, color: colors.colorTextMuted),
            const SizedBox(height: CupidSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: type.body.copyWith(color: colors.colorTextMuted),
            ),
          ],
        ),
      ),
    );
  }
}
