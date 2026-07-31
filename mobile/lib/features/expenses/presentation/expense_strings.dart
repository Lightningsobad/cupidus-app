import 'package:flutter/widgets.dart';

import '../data/expense_category.dart';

/// vi/en copy transcribed verbatim from `ux/uiux-spec.md`, resolved from the
/// ambient [Locale] rather than the generated `AppL10n` ARB pipeline
/// (`mobile/lib/l10n/**` is outside this phase's write scope — same
/// precedent as `auth_strings.dart`/`chat_strings.dart`).
extension ExpenseLocaleText on BuildContext {
  bool get _isVi => Localizations.localeOf(this).languageCode == 'vi';

  String viEn(String vi, String en) => _isVi ? vi : en;
}

/// `expense` screen copy (`ux/uiux-spec.md` §4, §5, §7). The single copy
/// source for this feature (`coding-plan/phase-P3-history-screen.md` §3) —
/// no other file in this phase declares a user-facing string literal.
abstract final class ExpenseStrings {
  static String screenTitle(BuildContext context) =>
      context.viEn('Chi tiêu chung', 'Shared expenses');

  static String monthTotalLabel(BuildContext context) =>
      context.viEn('Tổng tháng này', 'This month');

  static String itemCount(BuildContext context, int count) =>
      context.viEn('$count khoản chi', '$count items');

  /// Positive [deltaVnd] is a spending increase vs. last month; negative is
  /// a decrease. Paired with an explicit "increase"/"decrease" word so the
  /// signal is never colour-only (`ux/uiux-spec.md` §7).
  static String monthDelta(BuildContext context, num deltaVnd) {
    final bool isIncrease = deltaVnd >= 0;
    return context.viEn(
      isIncrease ? 'Tăng so với tháng trước' : 'Giảm so với tháng trước',
      isIncrease ? 'Up from last month' : 'Down from last month',
    );
  }

  // -- Category chips (`ux/uiux-spec.md` §4) ----------------------------

  static String categoryAll(BuildContext context) =>
      context.viEn('Tất cả', 'All');

  /// Category chip / list-item label. Distinct from
  /// `ExpenseCategory.label`, which is an internal English-only fallback
  /// name, not user-facing copy (see that field's dartdoc).
  static String category(BuildContext context, ExpenseCategory category) {
    return switch (category) {
      ExpenseCategory.food => context.viEn('Ăn uống', 'Food'),
      ExpenseCategory.date => context.viEn('Hẹn hò', 'Date'),
      ExpenseCategory.travel => context.viEn('Du lịch', 'Travel'),
      ExpenseCategory.shopping => context.viEn('Mua sắm', 'Shopping'),
      ExpenseCategory.other => context.viEn('Khác', 'Other'),
    };
  }

  // -- `who` label (ADR-015.2) -------------------------------------------

  /// Own row. Never a literal display name — no partner-profile endpoint
  /// exists (ADR-015.2).
  static String whoYou(BuildContext context) => context.viEn('Bạn', 'You');

  /// Partner's row. Never a literal display name (ADR-015.2).
  static String whoPartner(BuildContext context) =>
      context.viEn('Người ấy', 'Partner');

  // -- Offline / sync states (`ux/uiux-spec.md` §5, ADR-007, ADR-015.5) --

  /// Shown only while the device is currently offline (`showFreshnessCaption`
  /// in `expense_history_cubit.dart`) — never a permanent provenance label.
  /// [syncedAt] is the local `lastSuccessfulSyncAt` timestamp.
  static String freshnessCaption(BuildContext context, DateTime syncedAt) {
    final Duration age = DateTime.now().difference(syncedAt);
    final String relative = _relativeAge(context, age);
    return context.viEn(
      'Cập nhật lần cuối $relative',
      'Last updated $relative',
    );
  }

  static String _relativeAge(BuildContext context, Duration age) {
    if (age.inMinutes < 1) {
      return context.viEn('vừa xong', 'just now');
    }
    if (age.inHours < 1) {
      final int minutes = age.inMinutes;
      return context.viEn('$minutes phút trước', '$minutes min ago');
    }
    if (age.inDays < 1) {
      final int hours = age.inHours;
      return context.viEn('$hours giờ trước', '$hours hr ago');
    }
    final int days = age.inDays;
    return context.viEn('$days ngày trước', '$days days ago');
  }

  /// Device has never completed a successful sync (`lastSuccessfulSyncAt ==
  /// null`, ADR-015.5) — distinct from [emptyZeroExpenses]. Verbatim from
  /// `ux/uiux-spec.md` §5.
  static String emptyNeverSynced(BuildContext context) => context.viEn(
    'Kết nối mạng để tải chi tiêu chung lần đầu',
    'Connect to load shared expenses for the first time',
  );

  /// Synced at least once, and the couple genuinely has zero expenses
  /// (`lastSuccessfulSyncAt != null`, `countAll() == 0`, ADR-015.5).
  /// Deliberately a different constant from [emptyNeverSynced] — the two
  /// must not share copy (`ux/uiux-spec.md` §5).
  static String emptyZeroExpenses(BuildContext context) =>
      context.viEn('Chưa có chi tiêu nào', 'No expenses yet');

  // -- 7-bar weekday chart (`ExpenseMonthSummary.weekdayTotalsVnd`) ------

  /// [weekday] is `DateTime.weekday` (1=Monday .. 7=Sunday).
  static String weekdayShortLabel(BuildContext context, int weekday) {
    const List<String> vi = <String>[
      'T2',
      'T3',
      'T4',
      'T5',
      'T6',
      'T7',
      'CN',
    ];
    const List<String> en = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return context.viEn(vi[weekday - 1], en[weekday - 1]);
  }
}
