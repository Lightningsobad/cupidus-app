import 'package:intl/intl.dart';

/// VND is the only currency in v1 (`architecture/solution.md` §3: the
/// backend defaults `currency`; no multi-currency selector ships).
abstract final class DreamJarAmountFormat {
  static final NumberFormat _grouping = NumberFormat.decimalPattern('vi_VN');

  /// Grouped VND display, e.g. `50.000.000₫`. The design source's `fmt()`
  /// is `n.toLocaleString('vi-VN') + '₫'` — no space before the symbol.
  static String vnd(num amount) => '${_grouping.format(amount)}₫';

  /// The design source's compact comparison form: `2,18tr` for millions,
  /// `460k` below that. Used where a full grouped amount would not fit, e.g.
  /// the per-partner comparison bars and the quick-add tiles.
  static String compact(num amount) {
    if (amount.abs() >= 1000000) {
      return '${_millions.format(amount / 1000000)}tr';
    }
    return '${(amount / 1000).round()}k';
  }

  static final NumberFormat _millions = NumberFormat('#,##0.##', 'vi_VN');

  /// As-you-type grouping for a raw digit string, e.g. `"50000000"` ->
  /// `"50.000.000"`. Non-digit characters are stripped first so this is
  /// safe to call on the field's live text value.
  static String grouped(String digits) {
    final cleaned = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return '';
    return _grouping.format(int.parse(cleaned));
  }
}
