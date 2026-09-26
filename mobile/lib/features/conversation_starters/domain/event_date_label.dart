/// Vietnamese weekday names indexed by `DateTime.weekday - 1`, so Monday is
/// first and Sunday last. Fixed here rather than read from `intl`: this
/// feature ships no locale data and the screen renders Vietnamese chrome only.
const List<String> _weekdayNames = <String>[
  'thứ Hai',
  'thứ Ba',
  'thứ Tư',
  'thứ Năm',
  'thứ Sáu',
  'thứ Bảy',
  'Chủ nhật',
];

/// `2026-08-16` read as `thứ Bảy 16/08`, the form the event row folds into the
/// event's own name (Design Ruling Log 2026-09-20, mục 6b).
///
/// Absolute on purpose. A relative form ("thứ Bảy này", "tuần sau") would have
/// to know today, and this label is a function of the pinned civil date the
/// pack ships and nothing else — so it cannot drift from the date the card
/// carries, and it needs no clock.
String eventDateLabel(String isoDate) {
  final DateTime date = DateTime.parse(isoDate);
  final String day = date.day.toString().padLeft(2, '0');
  final String month = date.month.toString().padLeft(2, '0');
  return '${_weekdayNames[date.weekday - 1]} $day/$month';
}
