import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/cupid_database.dart' show ExpenseCacheRow;
import '../../../../core/realtime/backend_user_id_store.dart';
import '../../../../design_system/design_system.dart';
import '../../data/expense_category.dart';
import '../expense_strings.dart';

/// One row of the shared history list (`ux/uiux-spec.md` §4). Renders the
/// category, the `who` label (ADR-015.2 — derived, never a literal partner
/// display name), the date, and the VND amount.
class ExpenseListItem extends StatelessWidget {
  const ExpenseListItem({
    super.key,
    required this.row,
    required this.backendUserIdStore,
  });

  final ExpenseCacheRow row;

  /// Own-user id source for the `who` derivation (ADR-015.2): `row.userId
  /// == backendUserIdStore.backendUserId` means "You", anything else means
  /// "Partner" — there is no partner-profile endpoint to render a literal
  /// name from.
  final BackendUserIdStore backendUserIdStore;

  static final NumberFormat _vndFormat = NumberFormat.decimalPattern(
    'vi_VN',
  );

  /// `CupidIcons` (design_system/adaptive/) does not yet carry verified cmap
  /// codepoints for these category glyphs — adding them is out of this
  /// phase's write scope. Uses Flutter's bundled Material Icons font
  /// directly rather than guessing an unverified codepoint on the app's
  /// custom icon font (same precedent as `chat_screen.dart`'s lock icon).
  static IconData _iconFor(ExpenseCategory category) {
    return switch (category) {
      ExpenseCategory.food => Icons.restaurant,
      ExpenseCategory.date => Icons.favorite,
      ExpenseCategory.travel => Icons.flight,
      ExpenseCategory.shopping => Icons.shopping_bag,
      ExpenseCategory.other => Icons.category,
    };
  }

  /// `d/M`, the VN date convention. Deliberately not `intl`'s locale-aware
  /// `DateFormat` (month-name variants need `initializeDateFormatting`,
  /// which nothing in this app currently calls) — a numeric day/month is
  /// unambiguous in both vi and en for this list's density.
  static String _dateLabel(DateTime date) => '${date.day}/${date.month}';

  /// ADR-015.2's `who` derivation, extracted as a pure static so it is
  /// unit-testable without a widget pump (`expense_history_cubit_test.dart`
  /// — this phase's write scope has no dedicated widget-test file).
  static bool isOwnRow(ExpenseCacheRow row, BackendUserIdStore store) =>
      row.userId == store.backendUserId;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    final ExpenseCategory category = ExpenseCategory.fromWire(row.category);
    final String who = isOwnRow(row, backendUserIdStore)
        ? ExpenseStrings.whoYou(context)
        : ExpenseStrings.whoPartner(context);
    final String subtitle = '$who · ${_dateLabel(row.date)}';

    return Semantics(
      label:
          '${ExpenseStrings.category(context, category)}, $subtitle, '
          '${_vndFormat.format(row.amount)} ₫',
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: platformTokens.tapTarget),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: CupidSpacing.sm,
            horizontal: CupidSpacing.md,
          ),
          child: Row(
            children: <Widget>[
              Icon(_iconFor(category), color: colors.colorAccentPurple),
              const SizedBox(width: CupidSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      ExpenseStrings.category(context, category),
                      style: type.body.copyWith(color: colors.colorText),
                    ),
                    Text(
                      subtitle,
                      style: type.caption.copyWith(
                        color: colors.colorTextMuted,
                      ),
                    ),
                    if (row.description != null &&
                        row.description!.trim().isNotEmpty)
                      Text(
                        row.description!,
                        style: type.caption.copyWith(
                          color: colors.colorTextMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: CupidSpacing.sm),
              Text(
                '${_vndFormat.format(row.amount)} ₫',
                style: type.labelMono.copyWith(
                  color: colors.colorText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
