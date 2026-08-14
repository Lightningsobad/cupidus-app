import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/cupid_database.dart' show ExpenseCacheRow;
import '../../../../core/realtime/backend_user_id_store.dart';
import '../../../../design_system/design_system.dart';
import '../../data/expense_category.dart';
import '../expense_strings.dart';

/// Off-grid measurements transcribed verbatim from the locked design
/// source's expense row (`cupid-app-design-system/project/Cupid
/// Screens.dc.html`, `isExpense` block).
const double _rowPaddingY = 14;
const double _rowGap = 13;
const double _iconTileSize = 40;
const double _iconTileRadius = 14;
const double _iconSize = 21;
const double _iconTileTintOpacity = 0.18;
const double _titleSize = 14;
const double _subtitleSize = 11;
const double _subtitleGap = 2;
const double _amountSize = 13;

/// One row of the shared history list (`ux/uiux-spec.md` §4). Renders the
/// category, the `who` label (ADR-015.2 — derived, never a literal partner
/// display name), the date, and the VND amount.
class ExpenseListItem extends StatelessWidget {
  const ExpenseListItem({
    super.key,
    required this.row,
    required this.backendUserIdStore,
    this.showDivider = true,
  });

  final ExpenseCacheRow row;

  /// The design source draws a hairline under every row except the last one
  /// inside the list card.
  final bool showDivider;

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
  static IconData iconFor(ExpenseCategory category) {
    return switch (category) {
      ExpenseCategory.food => Icons.restaurant,
      ExpenseCategory.date => Icons.favorite,
      ExpenseCategory.travel => Icons.flight,
      ExpenseCategory.shopping => Icons.shopping_bag,
      ExpenseCategory.other => Icons.category,
    };
  }

  /// Per-category accent used for the row's icon tile. The design source
  /// tints each tile with one accent at 18% for the fill and the same accent
  /// at full strength for the glyph.
  static Color _accentFor(ExpenseCategory category, CupidColorTokens colors) {
    return switch (category) {
      ExpenseCategory.food => colors.colorAmber,
      ExpenseCategory.date => colors.colorAccentPink,
      ExpenseCategory.travel => colors.colorMint,
      ExpenseCategory.shopping => colors.colorAccentPurple,
      ExpenseCategory.other => colors.colorPeach,
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
    final Color accent = _accentFor(category, colors);
    final String who = isOwnRow(row, backendUserIdStore)
        ? ExpenseStrings.whoYou(context)
        : ExpenseStrings.whoPartner(context);
    final String subtitle = '$who · ${_dateLabel(row.date)}';
    final String title =
        (row.description != null && row.description!.trim().isNotEmpty)
        ? row.description!.trim()
        : ExpenseStrings.category(context, category);

    return Semantics(
      label:
          '${ExpenseStrings.category(context, category)}, $subtitle, '
          '${_vndFormat.format(row.amount)} ₫',
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: platformTokens.tapTarget),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: showDivider
                ? Border(bottom: BorderSide(color: colors.colorLine))
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: _rowPaddingY),
            child: Row(
              children: <Widget>[
                Container(
                  width: _iconTileSize,
                  height: _iconTileSize,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: _iconTileTintOpacity),
                    borderRadius: BorderRadius.circular(_iconTileRadius),
                  ),
                  child: Icon(
                    iconFor(category),
                    size: _iconSize,
                    color: accent,
                  ),
                ),
                const SizedBox(width: _rowGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: type.body.copyWith(
                          color: colors.colorText,
                          fontSize: _titleSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: _subtitleGap),
                      Text(
                        subtitle,
                        style: type.caption.copyWith(
                          color: colors.colorTextMuted,
                          fontSize: _subtitleSize,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: _rowGap),
                Text(
                  '${_vndFormat.format(row.amount)} ₫',
                  style: type.labelMono.copyWith(
                    color: colors.colorText,
                    fontSize: _amountSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
