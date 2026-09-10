/// Vietnamese display formatting and parsing for the three numeric card
/// fields (`coding-plan/master-plan.md` §11.2, ruling A-2 → AC-8).
///
/// Deliberately widget-free and `intl`-free. The conventions below are fixed
/// product constants, not locale-derived output: a device set to `en_US` still
/// sees `180.000đ` and `1,8 km`. Using `NumberFormat` here would make the
/// rendered string depend on the device locale, which is exactly what A-2
/// rules out.
///
/// Every field has three functions, and they are three different jobs:
///
/// * `format*` — the string an **unfocused** field shows. It carries its own
///   unit, so the caller must not also draw a suffix beside it.
/// * `raw*` — the string a **focused** field is edited in. No separators, no
///   unit; this is the shape `int.tryParse`/`double.tryParse` read.
/// * `parse*` — text back to a number for the write path. Accepts both the
///   raw shape and the formatted shape, so a value that was never re-focused
///   still parses. Returns `null` for blank or unrecognised input, and `null`
///   is the caller's instruction to clear the column.
///
/// `parse*(format*(x)) == x` and `parse*(raw*(x)) == x` hold for every
/// non-null `x` these fields can hold.
library;

/// Thousands separator for prices. A dot, not the comma English uses.
const String kViThousandsSeparator = '.';

/// Decimal separator in **display** strings. The raw edit buffer keeps the
/// dot, because that is what `double.tryParse` reads (§11.2).
const String kViDecimalSeparator = ',';

const String _kDongSuffix = 'đ';
const String _kKmSuffix = ' km';
const String _kHourWord = 'tiếng';
const String _kMinuteWord = 'phút';

/// `180000` → `180.000đ`. Null renders blank so an unset field shows its hint.
///
/// No `~` prefix, ever: the `~70.000đ` on the canvas mock is sample card body
/// text (D-8), not a format contract (§11.2).
String formatPriceVnd(int? value) {
  if (value == null) {
    return '';
  }
  return '${_groupThousands(value)}$_kDongSuffix';
}

/// `180000` → `180000`. The edit buffer never carries separators or a unit.
String rawPriceVnd(int? value) => value?.toString() ?? '';

/// Accepts `180000`, `180.000` and `180.000đ`. Anything else is `null`.
int? parsePriceVnd(String text) {
  final String trimmed = _stripUnit(text, _kDongSuffix);
  if (trimmed.isEmpty) {
    return null;
  }
  final RegExpMatch? match = _priceShape.firstMatch(trimmed);
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(0)!.replaceAll(kViThousandsSeparator, ''));
}

/// `1.8` → `1,8 km`, `4.0` → `4 km`. A whole number loses its `.0` so the
/// field reads `4 km` rather than `4,0 km`.
String formatDistanceKm(double? value) {
  if (value == null || !value.isFinite) {
    return '';
  }
  return '${rawDistanceKm(value).replaceAll('.', kViDecimalSeparator)}'
      '$_kKmSuffix';
}

/// `1.8` → `1.8`. Dot decimal on purpose — this is the buffer the write path
/// reads back with `double.tryParse`.
String rawDistanceKm(double? value) {
  if (value == null || !value.isFinite) {
    return '';
  }
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();
}

/// Accepts `1.8`, `1,8`, `1,8 km` and `1.8km`. Both separators are read
/// because a user typing by hand may use either (§11.2).
double? parseDistanceKm(String text) {
  final String trimmed = _stripUnit(text, 'km');
  if (trimmed.isEmpty) {
    return null;
  }
  if (!_distanceShape.hasMatch(trimmed)) {
    return null;
  }
  return double.tryParse(trimmed.replaceAll(kViDecimalSeparator, '.'));
}

/// `120` → `2 tiếng`, `45` → `45 phút`, `90` → `1 tiếng 30 phút`.
///
/// §11.2 lists the three shapes rather than pinning one output per input; the
/// rule that produces all three, and only these three, is: under an hour show
/// minutes, a whole number of hours shows hours alone, anything else shows
/// both parts. `0` is a real duration the user typed, so it renders `0 phút`
/// rather than blank — only `null` is blank.
String formatDurationMinutes(int? value) {
  if (value == null) {
    return '';
  }
  if (value < 60) {
    return '$value $_kMinuteWord';
  }
  final int hours = value ~/ 60;
  final int minutes = value % 60;
  if (minutes == 0) {
    return '$hours $_kHourWord';
  }
  return '$hours $_kHourWord $minutes $_kMinuteWord';
}

/// `90` → `90`. Minutes only, which is what `duration_minutes` stores (B-1).
String rawDurationMinutes(int? value) => value?.toString() ?? '';

/// Accepts `90`, `90 phút`, `2 tiếng` and `1 tiếng 30 phút`.
int? parseDurationMinutes(String text) {
  final String trimmed = text.trim().toLowerCase();
  if (trimmed.isEmpty) {
    return null;
  }
  final int? plain = int.tryParse(trimmed);
  if (plain != null) {
    return plain;
  }
  final RegExpMatch? match = _durationShape.firstMatch(trimmed);
  if (match == null) {
    return null;
  }
  final String? hours = match.group(1);
  final String? minutes = match.group(2);
  if (hours == null && minutes == null) {
    return null;
  }
  final int hourPart = int.tryParse(hours ?? '0') ?? 0;
  final int minutePart = int.tryParse(minutes ?? '0') ?? 0;
  return hourPart * 60 + minutePart;
}

/// `note_keywords` is one column, so it stores one string: the keywords joined
/// by this separator (§13.3a). The `·` seen between chips on the canvas is a
/// drawing decision made by the chip strip, never a stored character.
const String kNoteKeywordSeparator = ',';

/// Stored string → the chips to draw, in the order the user added them.
///
/// Blank items are dropped rather than rendered as an empty chip, so a value
/// hand-written as `cà phê,,sách` still reads as two keywords. `null` and `''`
/// both mean "no keywords" and both give an empty list — the strip then draws
/// nothing at all rather than an empty row.
List<String> parseNoteKeywords(String? stored) {
  if (stored == null) {
    return const <String>[];
  }
  return <String>[
    for (final String part in stored.split(kNoteKeywordSeparator))
      if (part.trim().isNotEmpty) part.trim(),
  ];
}

/// Chips → the string to store. Returns `null`, never `''`, for an empty list:
/// clearing the last keyword has to clear the column, and an empty string would
/// leave a row that reads as "has keywords" to anything counting non-nulls.
String? formatNoteKeywords(List<String> keywords) {
  final List<String> cleaned = <String>[
    for (final String keyword in keywords)
      if (keyword.trim().isNotEmpty) keyword.trim(),
  ];
  if (cleaned.isEmpty) {
    return null;
  }
  return cleaned.join(kNoteKeywordSeparator);
}

/// `link_saved_at` epoch millis → `28/8`, the short date D-22 puts in the
/// provenance line (*"Từ cái link bạn dán ngày 28/8"*).
///
/// Day and month only, unpadded, and no year: the line is a reminder of when
/// the user saved something, not a timestamp. Rendered from the local date so
/// it matches the day the user actually pasted the link. `null` is blank, which
/// is the caller's signal to draw no provenance line.
String formatShortViDate(int? epochMillis) {
  if (epochMillis == null) {
    return '';
  }
  final DateTime local =
      DateTime.fromMillisecondsSinceEpoch(epochMillis).toLocal();
  return '${local.day}/${local.month}';
}

/// Either an already-grouped number (`180.000`) or a plain run of digits
/// (`180000`). Written as one alternation so `1.80.0` is rejected rather than
/// silently read as `1800`.
final RegExp _priceShape =
    RegExp(r'^-?(?:\d{1,3}(?:\.\d{3})+|\d+)$');

final RegExp _distanceShape = RegExp(r'^-?\d+(?:[.,]\d+)?$');

/// Both parts optional individually, but the caller rejects the all-empty
/// match — `tiếng phút` with no numbers is not a duration.
final RegExp _durationShape = RegExp(
  '^(?:(\\d+)\\s*$_kHourWord)?\\s*(?:(\\d+)\\s*$_kMinuteWord)?\$',
);

String _stripUnit(String text, String unit) {
  final String trimmed = text.trim();
  if (!trimmed.toLowerCase().endsWith(unit.toLowerCase())) {
    return trimmed;
  }
  return trimmed.substring(0, trimmed.length - unit.length).trim();
}

String _groupThousands(int value) {
  final bool negative = value < 0;
  final String digits = value.abs().toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(kViThousandsSeparator);
    }
    buffer.write(digits[i]);
  }
  return negative ? '-$buffer' : buffer.toString();
}
