import 'package:cupid_mobile/features/activity_cards/presentation/formatters/vi_field_format.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rule 1 of `coding-plan/master-plan.md` §11.4: the pure formatter/parser,
/// all three fields, both directions, plus the edges — `null`, `0`, very
/// large, garbage — and the `parse(format(x)) == x` round trip.
void main() {
  group('giá (price_vnd)', () {
    test('formats with a dot thousands separator and the đ suffix', () {
      expect(formatPriceVnd(180000), '180.000đ');
      expect(formatPriceVnd(70000), '70.000đ');
      expect(formatPriceVnd(999), '999đ');
      expect(formatPriceVnd(1000), '1.000đ');
    });

    test('never prefixes the sample-text tilde from the canvas mock', () {
      expect(formatPriceVnd(70000), isNot(contains('~')));
    });

    test('the raw buffer carries neither separator nor unit', () {
      expect(rawPriceVnd(180000), '180000');
      expect(rawPriceVnd(0), '0');
      expect(rawPriceVnd(null), '');
    });

    test('null is blank and 0 is a real value', () {
      expect(formatPriceVnd(null), '');
      expect(formatPriceVnd(0), '0đ');
      expect(parsePriceVnd(''), isNull);
      expect(parsePriceVnd('   '), isNull);
      expect(parsePriceVnd('0'), 0);
    });

    test('a very large amount groups every three digits', () {
      expect(formatPriceVnd(1234567890), '1.234.567.890đ');
      expect(parsePriceVnd('1.234.567.890đ'), 1234567890);
    });

    test('parses the raw shape, the grouped shape and the full display '
        'string', () {
      expect(parsePriceVnd('180000'), 180000);
      expect(parsePriceVnd('180.000'), 180000);
      expect(parsePriceVnd('180.000đ'), 180000);
      expect(parsePriceVnd(' 180.000 đ '), 180000);
    });

    test('garbage returns null instead of a salvaged number', () {
      expect(parsePriceVnd('abc'), isNull);
      expect(parsePriceVnd('1a2'), isNull);
      expect(parsePriceVnd('1.80.0'), isNull);
      expect(parsePriceVnd('đ'), isNull);
      expect(parsePriceVnd('180,000'), isNull);
    });

    test('round trips through both the formatted and the raw shape', () {
      for (final int value in <int>[0, 1, 999, 1000, 70000, 1234567890]) {
        expect(parsePriceVnd(formatPriceVnd(value)), value);
        expect(parsePriceVnd(rawPriceVnd(value)), value);
      }
    });
  });

  group('khoảng cách (distance_km)', () {
    test('formats with a comma decimal and the km unit', () {
      expect(formatDistanceKm(1.8), '1,8 km');
      expect(formatDistanceKm(3.5), '3,5 km');
    });

    test('a whole number drops its decimal part', () {
      expect(formatDistanceKm(4), '4 km');
      expect(formatDistanceKm(0), '0 km');
    });

    test('the raw buffer keeps the dot decimal double.tryParse reads', () {
      expect(rawDistanceKm(1.8), '1.8');
      expect(rawDistanceKm(4), '4');
      expect(rawDistanceKm(null), '');
    });

    test('null is blank', () {
      expect(formatDistanceKm(null), '');
      expect(parseDistanceKm(''), isNull);
    });

    test('a hand-typed comma and a hand-typed dot both parse', () {
      expect(parseDistanceKm('1,8'), 1.8);
      expect(parseDistanceKm('1.8'), 1.8);
      expect(parseDistanceKm('1,8 km'), 1.8);
      expect(parseDistanceKm('1.8km'), 1.8);
    });

    test('a very large distance still round trips', () {
      expect(formatDistanceKm(98765.4), '98765,4 km');
      expect(parseDistanceKm('98765,4 km'), 98765.4);
    });

    test('garbage returns null', () {
      expect(parseDistanceKm('abc'), isNull);
      expect(parseDistanceKm('km'), isNull);
      expect(parseDistanceKm('1,8,9'), isNull);
      expect(parseDistanceKm('1 km 8'), isNull);
    });

    test('round trips through both the formatted and the raw shape', () {
      for (final double value in <double>[0, 0.5, 1.8, 4, 12.25, 98765.4]) {
        expect(parseDistanceKm(formatDistanceKm(value)), value);
        expect(parseDistanceKm(rawDistanceKm(value)), value);
      }
    });
  });

  group('thời lượng (duration_minutes)', () {
    test('under an hour shows minutes', () {
      expect(formatDurationMinutes(45), '45 phút');
      expect(formatDurationMinutes(59), '59 phút');
    });

    test('a whole number of hours shows hours alone', () {
      expect(formatDurationMinutes(60), '1 tiếng');
      expect(formatDurationMinutes(120), '2 tiếng');
    });

    test('anything in between shows both parts', () {
      expect(formatDurationMinutes(90), '1 tiếng 30 phút');
      expect(formatDurationMinutes(155), '2 tiếng 35 phút');
    });

    test('the raw buffer is minutes only', () {
      expect(rawDurationMinutes(90), '90');
      expect(rawDurationMinutes(null), '');
    });

    test('null is blank and 0 is a real value', () {
      expect(formatDurationMinutes(null), '');
      expect(formatDurationMinutes(0), '0 phút');
      expect(parseDurationMinutes(''), isNull);
      expect(parseDurationMinutes('0'), 0);
    });

    test('a very large duration keeps counting hours', () {
      expect(formatDurationMinutes(6000), '100 tiếng');
      expect(parseDurationMinutes('100 tiếng'), 6000);
    });

    test('parses the raw shape and every display shape', () {
      expect(parseDurationMinutes('90'), 90);
      expect(parseDurationMinutes('90 phút'), 90);
      expect(parseDurationMinutes('2 tiếng'), 120);
      expect(parseDurationMinutes('1 tiếng 30 phút'), 90);
      expect(parseDurationMinutes('1 Tiếng 30 Phút'), 90);
    });

    test('garbage returns null', () {
      expect(parseDurationMinutes('abc'), isNull);
      expect(parseDurationMinutes('tiếng'), isNull);
      expect(parseDurationMinutes('tiếng phút'), isNull);
      expect(parseDurationMinutes('30 phút 1 tiếng'), isNull);
    });

    test('round trips through both the formatted and the raw shape', () {
      for (final int value in <int>[0, 1, 45, 59, 60, 90, 155, 6000]) {
        expect(parseDurationMinutes(formatDurationMinutes(value)), value);
        expect(parseDurationMinutes(rawDurationMinutes(value)), value);
      }
    });
  });

  group('từ khoá (note_keywords)', () {
    test('trims each item, drops the blanks, and keeps the user order', () {
      expect(
        parseNoteKeywords('cà phê , , sách '),
        <String>['cà phê', 'sách'],
      );
      expect(formatNoteKeywords(parseNoteKeywords('cà phê , , sách ')),
          'cà phê,sách');
      expect(parseNoteKeywords('b,a,c'), <String>['b', 'a', 'c']);
    });

    test('an empty selection is null, never the empty string', () {
      expect(formatNoteKeywords(const <String>[]), isNull);
      expect(formatNoteKeywords(const <String>['  ', '']), isNull);
      expect(parseNoteKeywords(null), isEmpty);
      expect(parseNoteKeywords(''), isEmpty);
      expect(parseNoteKeywords(',,'), isEmpty);
    });

    test('the display separator is never the stored one', () {
      expect(kNoteKeywordSeparator, ',');
      expect(formatNoteKeywords(const <String>['cà phê', 'sách']),
          isNot(contains('·')));
    });

    test('round trips', () {
      const List<String> keywords = <String>['cà phê', 'sách cũ', 'gần nhà'];
      expect(parseNoteKeywords(formatNoteKeywords(keywords)), keywords);
    });
  });

  group('ngày ngắn (link_saved_at)', () {
    test('renders day/month only, unpadded, with no year', () {
      expect(
        formatShortViDate(DateTime(2025, 9, 10, 8, 30).millisecondsSinceEpoch),
        '10/9',
      );
      expect(
        formatShortViDate(DateTime(2026, 8, 28).millisecondsSinceEpoch),
        '28/8',
      );
      expect(
        formatShortViDate(DateTime(2026, 12, 1, 23, 59).millisecondsSinceEpoch),
        '1/12',
      );
    });

    test('null is blank, which is the caller\'s "draw no line" signal', () {
      expect(formatShortViDate(null), '');
    });
  });

  group('D-29 · ngày dài (scheduled_on)', () {
    test('renders weekday + day/month, unpadded, with no year', () {
      // Every pair here was checked against a calendar before being written:
      // 2026-08-15 really is a Saturday. The master plan's own `Thứ Bảy 16/8`
      // was a shape example, and 2026-08-16 is in fact a Sunday.
      expect(formatLongViDate('2026-08-15'), 'Thứ Bảy 15/8');
      expect(formatLongViDate('2026-10-01'), 'Thứ Năm 1/10');
      expect(formatLongViDate('2026-03-01'), 'Chủ Nhật 1/3');
      expect(formatLongViDate('2026-08-16'), 'Chủ Nhật 16/8');

      for (final String rendered in <String>[
        formatLongViDate('2026-03-01'),
        formatLongViDate('2026-08-15'),
      ]) {
        expect(rendered, isNot(contains('2026')));
        expect(rendered, isNot(contains('0')));
      }
    });

    test('an unparseable string comes back unchanged rather than throwing', () {
      // The value arrives from SQLite, so this is a system boundary: a blank
      // meta row loses the user's data on screen, an unprettified one does not.
      expect(formatLongViDate('hôm nào đó'), 'hôm nào đó');
      expect(formatLongViDate(''), '');
      expect(formatLongViDate('sang tuần'), 'sang tuần');
      expect(formatLongViDate('01/10/2026'), '01/10/2026');
    });
  });

  test('the conventions are product constants, not locale output', () {
    // A device switched to an English locale still sees the Vietnamese
    // separators, which is what rules `intl`/`NumberFormat` out here (§11.3).
    expect(kViThousandsSeparator, '.');
    expect(kViDecimalSeparator, ',');
  });
}
