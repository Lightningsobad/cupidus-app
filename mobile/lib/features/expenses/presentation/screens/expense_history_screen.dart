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
import '../widgets/expense_list_item.dart';

/// Shared expense history screen (`ux/uiux-spec.md` §4/§5, AC2/AC3). Does
/// not wire its own route/nav entry, an "add expense" affordance, or the
/// pairing gate — those are later phases' write scope
/// (`coding-plan/phase-P3-history-screen.md` §1B: P4 adds the add-expense
/// entry, P5 adds the pairing gate).
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
        backendUserIdStore: backendUserIdStore,
        onBack: onBack,
      ),
    );
  }
}

class _ExpenseHistoryView extends StatefulWidget {
  const _ExpenseHistoryView({
    required this.backendUserIdStore,
    required this.onBack,
  });

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

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Scaffold(
      appBar: CupidHeader(
        title: ExpenseStrings.screenTitle(context),
        onBack: widget.onBack,
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
          return Column(
            children: <Widget>[
              if (state.summary != null)
                _MonthSummaryCard(colors: colors, summary: state.summary!),
              if (state.showFreshnessCaption)
                _FreshnessCaption(
                  colors: colors,
                  syncedAt: state.lastSuccessfulSyncAt!,
                ),
              _CategoryChips(
                selected: state.selectedCategory,
                onChanged: context
                    .read<ExpenseHistoryCubit>()
                    .categorySelected,
              ),
              const SizedBox(height: CupidSpacing.xs),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    vertical: CupidSpacing.sm,
                  ),
                  itemCount: filtered.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= filtered.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: CupidSpacing.md,
                        ),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return ExpenseListItem(
                      row: filtered[index],
                      backendUserIdStore: widget.backendUserIdStore,
                    );
                  },
                ),
              ),
            ],
          );
        },
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
      margin: const EdgeInsets.all(CupidSpacing.md),
      padding: const EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            ExpenseStrings.monthTotalLabel(context),
            style: type.caption.copyWith(color: colors.colorTextMuted),
          ),
          const SizedBox(height: CupidSpacing.xs),
          Text(
            '${_vndFormat.format(summary.totalVnd)} ₫',
            style: type.cardTitle.copyWith(
              color: colors.colorText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: CupidSpacing.xs),
          Text(
            ExpenseStrings.itemCount(context, summary.itemCount),
            style: type.caption.copyWith(color: colors.colorTextMuted),
          ),
          // A positive delta is a spending increase vs. last month, so it
          // is paired with the warmer/red accent; the word pairing in
          // `ExpenseStrings.monthDelta` keeps the signal from being
          // colour-only (`ux/uiux-spec.md` §7).
          if (delta != null) ...<Widget>[
            const SizedBox(height: CupidSpacing.xs),
            Text(
              '${delta >= 0 ? '+' : '-'}'
              '${_vndFormat.format(delta.abs())} ₫ · '
              '${ExpenseStrings.monthDelta(context, delta)}',
              style: type.caption.copyWith(
                color: delta >= 0 ? colors.colorRed : colors.colorGreen,
              ),
            ),
          ],
          const SizedBox(height: CupidSpacing.md),
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

  static const double _maxBarHeight = 40;
  static const double _minBarHeight = 2;

  @override
  Widget build(BuildContext context) {
    final CupidTypographyTokens type = context.cupidType;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        for (int i = 0; i < 7; i++)
          Semantics(
            label:
                '${ExpenseStrings.weekdayShortLabel(context, i + 1)}: '
                '${weekdayTotalsVnd[i]}',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 12,
                  height: maxValueVnd <= 0
                      ? _minBarHeight
                      : (_maxBarHeight * (weekdayTotalsVnd[i] / maxValueVnd))
                            .clamp(_minBarHeight, _maxBarHeight)
                            .toDouble(),
                  decoration: BoxDecoration(
                    color: colors.colorAccentPink,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: CupidSpacing.xs),
                Text(
                  ExpenseStrings.weekdayShortLabel(context, i + 1),
                  style: type.caption.copyWith(
                    color: colors.colorTextMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: CupidSpacing.md,
        vertical: CupidSpacing.xs,
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: CupidSpacing.md),
      child: Wrap(
        spacing: CupidSpacing.xs,
        runSpacing: CupidSpacing.xs,
        children: <Widget>[
          _CategoryChip(
            label: ExpenseStrings.categoryAll(context),
            isSelected: selected == null,
            onTap: () => onChanged(null),
          ),
          for (final ExpenseCategory category in ExpenseCategory.values)
            _CategoryChip(
              label: ExpenseStrings.category(context, category),
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
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: platformTokens.tapTarget),
        child: Material(
          color: isSelected ? colors.colorAccentPink : colors.colorSurfaceAlt,
          borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CupidSpacing.sm,
                vertical: CupidSpacing.xs,
              ),
              child: Center(
                child: Text(
                  label,
                  style: type.caption.copyWith(
                    color: isSelected
                        ? colors.colorBackground
                        : colors.colorText,
                    fontWeight: FontWeight.w600,
                  ),
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
