import 'package:intl/intl.dart';

/// VND is the only currency in v1 (`architecture/solution.md` §3: the
/// backend defaults `currency`; no multi-currency selector ships).
abstract final class DreamJarAmountFormat {
  static final NumberFormat _grouping = NumberFormat.decimalPattern('vi_VN');

  /// Grouped VND display, e.g. `50.000.000 ₫`.
  static String vnd(num amount) => '${_grouping.format(amount)} ₫';

  /// As-you-type grouping for a raw digit string, e.g. `"50000000"` ->
  /// `"50.000.000"`. Non-digit characters are stripped first so this is
  /// safe to call on the field's live text value.
  static String grouped(String digits) {
    final cleaned = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return '';
    return _grouping.format(int.parse(cleaned));
  }
}
