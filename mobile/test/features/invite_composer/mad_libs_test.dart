import 'dart:io';

import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/time_of_day_slot.dart';
import 'package:cupid_mobile/features/invite_composer/domain/mad_libs.dart';
import 'package:flutter_test/flutter_test.dart';

ActivityCard _card({
  String title = 'Xem phim Dune',
  String? scheduledOn = '2026-08-15',
  TimeOfDaySlot? timeOfDaySlot = TimeOfDaySlot.evening,
  int? durationMinutes = 120,
}) => ActivityCard(
  id: 'card-1',
  ownerKey: 'owner-1',
  title: title,
  status: ActivityCardStatus.scheduled,
  origin: ActivityCardOrigin.manual,
  scheduledOn: scheduledOn,
  timeOfDaySlot: timeOfDaySlot,
  durationMinutes: durationMinutes,
  invited: false,
  replyState: ActivityCardReplyState.notAnswered,
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 1),
);

void main() {
  group('MadLibsVariable', () {
    test('is a closed set of exactly five variables', () {
      expect(
        MadLibsVariable.values.map((MadLibsVariable v) => v.wireValue),
        <String>['activity', 'date', 'time', 'place', 'duration'],
      );
    });

    test('rejects a name outside the set', () {
      expect(MadLibsVariable.fromWireValue('mood'), isNull);
      expect(MadLibsVariable.fromWireValue('Activity'), isNull);
    });
  });

  group('MadLibsValues', () {
    test('drops null, empty, and whitespace-only sources', () {
      final MadLibsValues values = MadLibsValues(<MadLibsVariable, String>{
        MadLibsVariable.activity: 'Xem phim',
        MadLibsVariable.date: '',
        MadLibsVariable.place: '   ',
      });

      expect(values.contains(MadLibsVariable.activity), isTrue);
      expect(values.contains(MadLibsVariable.date), isFalse);
      expect(values.contains(MadLibsVariable.place), isFalse);
      expect(values[MadLibsVariable.time], isNull);
    });

    test('trims a present value', () {
      final MadLibsValues values = MadLibsValues(<MadLibsVariable, String>{
        MadLibsVariable.activity: '  Xem phim  ',
      });

      expect(values[MadLibsVariable.activity], 'Xem phim');
    });

    test('exposes an unmodifiable map', () {
      final MadLibsValues values = MadLibsValues(<MadLibsVariable, String>{
        MadLibsVariable.activity: 'Xem phim',
      });

      expect(
        () => values.variables[MadLibsVariable.date] = 'hôm nay',
        throwsUnsupportedError,
      );
    });
  });

  group('MadLibsValues.fromCard', () {
    test('resolves the card-backed variables', () {
      final MadLibsValues values = MadLibsValues.fromCard(_card());

      expect(values[MadLibsVariable.activity], 'Xem phim Dune');
      expect(values[MadLibsVariable.date], 'Thứ Bảy 15/8');
      expect(values[MadLibsVariable.time], 'tối');
      expect(values[MadLibsVariable.duration], '2 tiếng');
    });

    test('is deterministic for the same card', () {
      final ActivityCard card = _card();

      expect(
        MadLibsValues.fromCard(card).variables,
        MadLibsValues.fromCard(card).variables,
      );
    });

    test('omits variables whose source field is null', () {
      final MadLibsValues values = MadLibsValues.fromCard(
        _card(scheduledOn: null, timeOfDaySlot: null, durationMinutes: null),
      );

      expect(values.contains(MadLibsVariable.activity), isTrue);
      expect(values.contains(MadLibsVariable.date), isFalse);
      expect(values.contains(MadLibsVariable.time), isFalse);
      expect(values.contains(MadLibsVariable.duration), isFalse);
    });

    test('omits an activity whose title is blank', () {
      expect(
        MadLibsValues.fromCard(_card(title: '   ')).contains(
          MadLibsVariable.activity,
        ),
        isFalse,
      );
    });

    test('renders every time-of-day slot in lower case', () {
      for (final TimeOfDaySlot slot in TimeOfDaySlot.values) {
        final String? word = MadLibsValues.fromCard(
          _card(timeOfDaySlot: slot),
        )[MadLibsVariable.time];

        expect(word, isNotNull);
        expect(word, word!.toLowerCase());
      }
    });
  });

  group('domain purity', () {
    test('no domain file reaches the network or a non-deterministic source', () {
      final Directory domain = Directory(
        'lib/features/invite_composer/domain',
      );
      final List<File> sources = domain
          .listSync()
          .whereType<File>()
          .where((File file) => file.path.endsWith('.dart'))
          .toList();

      expect(sources, isNotEmpty);

      for (final File file in sources) {
        final String source = file.readAsStringSync();
        for (final String banned in <String>[
          'package:dio',
          'cupid_api',
          'package:http',
          'package:flutter/material.dart',
          'DateTime.now(',
          'Random(',
        ]) {
          expect(
            source.contains(banned),
            isFalse,
            reason: '${file.path} must not reference "$banned"',
          );
        }
      }
    });
  });
}
