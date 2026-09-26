import 'dart:io';

import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/phase_status/domain/wealth_counter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const WealthCounter counter = WealthCounter();

  group('value — cardinality of the kept set (AC-24/AC-25/BR-5)', () {
    test('counts the memory pane and nothing else', () {
      expect(
        counter.count(const <ActivityCardStatus, int>{
          ActivityCardStatus.idea: 7,
          ActivityCardStatus.scheduled: 3,
          ActivityCardStatus.done: 4,
          ActivityCardStatus.memory: 12,
        }),
        12,
      );
    });

    test('an absent memory status reads as zero, not as an error', () {
      expect(
        counter.count(const <ActivityCardStatus, int>{
          ActivityCardStatus.idea: 2,
        }),
        0,
      );
      expect(counter.count(const <ActivityCardStatus, int>{}), 0);
    });

    test('grows with the kept set (AC-24)', () {
      const Map<ActivityCardStatus, int> before = <ActivityCardStatus, int>{
        ActivityCardStatus.memory: 11,
      };
      const Map<ActivityCardStatus, int> after = <ActivityCardStatus, int>{
        ActivityCardStatus.memory: 12,
      };

      expect(counter.count(after), counter.count(before) + 1);
    });

    test('drops only because the set itself shrank (AC-29)', () {
      const Map<ActivityCardStatus, int> kept = <ActivityCardStatus, int>{
        ActivityCardStatus.memory: 12,
      };
      const Map<ActivityCardStatus, int> afterDelete =
          <ActivityCardStatus, int>{ActivityCardStatus.memory: 11};

      expect(counter.count(kept), 12);
      expect(counter.count(afterDelete), 11);
    });
  });

  group('COUNTER-STREAK — absence changes nothing (AC-26/BR-6)', () {
    test(
      'the same card set read sixty days apart gives the same value and '
      'produces no content',
      () {
        const Map<ActivityCardStatus, int> cards = <ActivityCardStatus, int>{
          ActivityCardStatus.memory: 12,
          ActivityCardStatus.idea: 5,
        };

        // Two separate "now"s, sixty days apart. Neither is passed in: the API
        // has nowhere to accept one, which is exactly what is being measured.
        final DateTime firstOpen = DateTime(2026, 7, 18);
        final DateTime sixtyDaysLater = DateTime(2026, 9, 16);
        expect(sixtyDaysLater.difference(firstOpen).inDays, 60);

        expect(counter.count(cards), 12);
        expect(counter.count(cards), 12);
      },
    );

    test('reading the counter many times never mutates it', () {
      const Map<ActivityCardStatus, int> cards = <ActivityCardStatus, int>{
        ActivityCardStatus.memory: 4,
      };

      final Set<int> seen = <int>{
        for (int read = 0; read < 60; read++) counter.count(cards),
      };

      expect(seen, <int>{4});
    });
  });

  group('COUNTER-STREAK — the source itself carries no clock (BR-5)', () {
    // The static check the risk table asks for. A reviewer reads one assertion
    // instead of re-deriving purity from every call site, and a later change
    // that smuggles a clock parameter in fails here rather than in production.
    late String source;

    setUpAll(() {
      final File file = File(
        'lib/features/phase_status/domain/wealth_counter.dart',
      );
      expect(file.existsSync(), isTrue, reason: 'source moved: ${file.path}');
      source = file.readAsStringSync();
    });

    test('wealth_counter.dart names no time type anywhere', () {
      expect(source.contains('DateTime'), isFalse);
      expect(source.contains('Duration'), isFalse);
      expect(source.contains('Stopwatch'), isFalse);
      expect(source.contains('inDays'), isFalse);
    });

    test('its whole public surface is one map in, one int out', () {
      expect(
        source.contains(
          'int count(Map<ActivityCardStatus, int> countsByStatus)',
        ),
        isTrue,
      );
      // Top-level declarations start at column 0, so a helper function that
      // took a clock would show up here even if it never reached the class.
      expect(
        RegExp(r'^[A-Za-z][^\n]*\(', multiLine: true).hasMatch(source),
        isFalse,
      );
    });
  });
}
