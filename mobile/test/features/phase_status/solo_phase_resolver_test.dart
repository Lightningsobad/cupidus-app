import 'dart:io';
import 'dart:math';

import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/before_you_go/domain/before_you_go_resolver.dart';
import 'package:cupid_mobile/features/phase_status/domain/solo_phase.dart';
import 'package:cupid_mobile/features/phase_status/domain/solo_phase_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

/// 2026-09-15, the fixed "today" every case resolves against.
final DateTime _today = DateTime(2026, 9, 15);

ActivityCard _card({
  required String id,
  ActivityCardStatus status = ActivityCardStatus.idea,
  String? scheduledOn,
  bool invited = false,
  ActivityCardReplyState replyState = ActivityCardReplyState.notAnswered,
  DateTime? updatedAt,
}) {
  final DateTime stamp = updatedAt ?? DateTime(2026, 9, 1);
  return ActivityCard(
    id: id,
    ownerKey: 'owner-1',
    title: 'Thẻ $id',
    status: status,
    origin: ActivityCardOrigin.manual,
    scheduledOn: scheduledOn,
    invited: invited,
    replyState: replyState,
    createdAt: DateTime(2026, 8, 1),
    updatedAt: stamp,
  );
}

/// Dart source with string literals and `//` comments removed, so a scan sees
/// only code. Without this, a doc comment naming the thing it forbids would
/// fail its own check.
String _strippedDart(String path) {
  final String raw = File(path).readAsStringSync();
  final String withoutStrings = raw
      .replaceAll(RegExp(r"'(?:[^'\\\n]|\\.)*'"), "''")
      .replaceAll(RegExp(r'"(?:[^"\\\n]|\\.)*"'), '""');
  return withoutStrings.replaceAll(RegExp(r'//[^\n]*'), '');
}

const String _phasePath = 'lib/features/phase_status/domain/solo_phase.dart';
const String _resolverPath =
    'lib/features/phase_status/domain/solo_phase_resolver.dart';

void main() {
  group('SoloPhase', () {
    test('wire values are the four ASCII identifiers of contract §2', () {
      expect(
        SoloPhase.values.map((SoloPhase phase) => phase.wireValue).toList(),
        <String>['waiting', 'upcoming', 'date_day', 'quiet'],
      );
    });

    test('an unknown identifier resolves to null, never to a default', () {
      expect(SoloPhase.fromWireValue('date_day'), SoloPhase.dateDay);
      expect(SoloPhase.fromWireValue('DATE_DAY'), isNull);
      expect(SoloPhase.fromWireValue('đúng ngày hẹn'), isNull);
    });
  });

  group('resolveSoloPhase — the four phases', () {
    test('a card scheduled for today gives dateDay', () {
      final PhaseResolution resolution = resolveSoloPhase(
        cards: <ActivityCard>[
          _card(
            id: 'card-a',
            status: ActivityCardStatus.scheduled,
            scheduledOn: '2026-09-15',
          ),
        ],
        today: _today,
      );

      expect(resolution.phase, SoloPhase.dateDay);
      expect(resolution.cardId, 'card-a');
      expect(resolution.scheduledOn, '2026-09-15');
      expect(resolution.isBeforeYouGoDismissed, isFalse);
    });

    test('a future scheduled card gives upcoming, nearest date wins', () {
      final PhaseResolution resolution = resolveSoloPhase(
        cards: <ActivityCard>[
          _card(
            id: 'card-far',
            status: ActivityCardStatus.scheduled,
            scheduledOn: '2026-12-01',
          ),
          _card(
            id: 'card-near',
            status: ActivityCardStatus.scheduled,
            scheduledOn: '2026-09-18',
          ),
        ],
        today: _today,
      );

      expect(resolution.phase, SoloPhase.upcoming);
      expect(resolution.cardId, 'card-near');
      expect(resolution.scheduledOn, '2026-09-18');
    });

    test('an invited card still unanswered gives waiting', () {
      final PhaseResolution resolution = resolveSoloPhase(
        cards: <ActivityCard>[
          _card(id: 'card-a', invited: true),
        ],
        today: _today,
      );

      expect(resolution.phase, SoloPhase.waiting);
      expect(resolution.cardId, 'card-a');
    });

    test('waiting picks the newest updated_at', () {
      final PhaseResolution resolution = resolveSoloPhase(
        cards: <ActivityCard>[
          _card(
            id: 'card-old',
            invited: true,
            updatedAt: DateTime(2026, 9, 2),
          ),
          _card(
            id: 'card-new',
            invited: true,
            updatedAt: DateTime(2026, 9, 9),
          ),
        ],
        today: _today,
      );

      expect(resolution.cardId, 'card-new');
    });

    test('an answered invite no longer counts as waiting', () {
      final PhaseResolution resolution = resolveSoloPhase(
        cards: <ActivityCard>[
          _card(
            id: 'card-a',
            invited: true,
            replyState: ActivityCardReplyState.answered,
          ),
        ],
        today: _today,
      );

      expect(resolution.phase, SoloPhase.quiet);
    });

    test('no card at all is quiet, not an error state', () {
      final PhaseResolution resolution = resolveSoloPhase(
        cards: const <ActivityCard>[],
        today: _today,
      );

      expect(resolution.phase, SoloPhase.quiet);
      expect(resolution.cardId, isNull);
      expect(resolution.scheduledOn, isNull);
    });

    test('a scheduled card outranks an unanswered invite', () {
      final PhaseResolution resolution = resolveSoloPhase(
        cards: <ActivityCard>[
          _card(
            id: 'card-invite',
            invited: true,
            updatedAt: DateTime(2026, 9, 14),
          ),
          _card(
            id: 'card-date',
            status: ActivityCardStatus.scheduled,
            scheduledOn: '2026-09-20',
          ),
        ],
        today: _today,
      );

      expect(resolution.phase, SoloPhase.upcoming);
      expect(resolution.cardId, 'card-date');
    });
  });

  group('resolveSoloPhase — BeforeYouGoPhase enrichment', () {
    test('a null BeforeYouGoPhase still derives dateDay from the date (AC-2)',
        () {
      final PhaseResolution resolution = resolveSoloPhase(
        cards: <ActivityCard>[
          _card(
            id: 'card-a',
            status: ActivityCardStatus.scheduled,
            scheduledOn: '2026-09-15',
          ),
        ],
        today: _today,
        beforeYouGo: null,
      );

      expect(resolution.phase, SoloPhase.dateDay);
      expect(resolution.cardId, 'card-a');
      expect(resolution.isBeforeYouGoDismissed, isFalse);
    });

    test('a dismissed BeforeYouGoPhase carries its flag and card id', () {
      final PhaseResolution resolution = resolveSoloPhase(
        cards: <ActivityCard>[
          _card(
            id: 'card-a',
            status: ActivityCardStatus.scheduled,
            scheduledOn: '2026-09-15',
          ),
        ],
        today: _today,
        beforeYouGo: const BeforeYouGoPhase(
          cardId: 'card-a',
          dateIso: '2026-09-15',
          isActive: true,
          isDismissed: true,
        ),
      );

      expect(resolution.phase, SoloPhase.dateDay);
      expect(resolution.cardId, 'card-a');
      expect(resolution.isBeforeYouGoDismissed, isTrue);
    });

    test('BeforeYouGoPhase does not create a phase on its own', () {
      final PhaseResolution resolution = resolveSoloPhase(
        cards: <ActivityCard>[
          _card(id: 'card-a'),
        ],
        today: _today,
        beforeYouGo: const BeforeYouGoPhase(
          cardId: 'card-a',
          dateIso: '2026-09-15',
          isActive: true,
          isDismissed: false,
        ),
      );

      expect(resolution.phase, SoloPhase.quiet);
      expect(resolution.cardId, isNull);
    });

    test('BeforeYouGoPhase does not leak into upcoming or waiting', () {
      const BeforeYouGoPhase beforeYouGo = BeforeYouGoPhase(
        cardId: 'card-other',
        dateIso: '2026-09-15',
        isActive: true,
        isDismissed: true,
      );

      final PhaseResolution upcoming = resolveSoloPhase(
        cards: <ActivityCard>[
          _card(
            id: 'card-a',
            status: ActivityCardStatus.scheduled,
            scheduledOn: '2026-09-20',
          ),
        ],
        today: _today,
        beforeYouGo: beforeYouGo,
      );
      expect(upcoming.cardId, 'card-a');
      expect(upcoming.isBeforeYouGoDismissed, isFalse);

      final PhaseResolution waiting = resolveSoloPhase(
        cards: <ActivityCard>[_card(id: 'card-a', invited: true)],
        today: _today,
        beforeYouGo: beforeYouGo,
      );
      expect(waiting.cardId, 'card-a');
      expect(waiting.isBeforeYouGoDismissed, isFalse);
    });
  });

  group('resolveSoloPhase — determinism', () {
    test('same scheduled_on breaks the tie on ascending id', () {
      final PhaseResolution resolution = resolveSoloPhase(
        cards: <ActivityCard>[
          _card(
            id: 'card-z',
            status: ActivityCardStatus.scheduled,
            scheduledOn: '2026-09-20',
          ),
          _card(
            id: 'card-a',
            status: ActivityCardStatus.scheduled,
            scheduledOn: '2026-09-20',
          ),
        ],
        today: _today,
      );

      expect(resolution.cardId, 'card-a');
    });

    test('same updated_at breaks the tie on ascending id', () {
      final DateTime stamp = DateTime(2026, 9, 9);
      final PhaseResolution resolution = resolveSoloPhase(
        cards: <ActivityCard>[
          _card(id: 'card-z', invited: true, updatedAt: stamp),
          _card(id: 'card-a', invited: true, updatedAt: stamp),
        ],
        today: _today,
      );

      expect(resolution.cardId, 'card-a');
    });

    test('shuffling the card list never changes the answer', () {
      final List<ActivityCard> cards = <ActivityCard>[
        _card(id: 'card-01'),
        _card(
          id: 'card-02',
          status: ActivityCardStatus.scheduled,
          scheduledOn: '2026-09-19',
        ),
        _card(
          id: 'card-03',
          status: ActivityCardStatus.scheduled,
          scheduledOn: '2026-09-19',
        ),
        _card(
          id: 'card-04',
          status: ActivityCardStatus.scheduled,
          scheduledOn: '2026-11-02',
        ),
        _card(id: 'card-05', invited: true, updatedAt: DateTime(2026, 9, 14)),
        _card(
          id: 'card-06',
          status: ActivityCardStatus.done,
          scheduledOn: '2026-09-16',
        ),
      ];

      final PhaseResolution expected = resolveSoloPhase(
        cards: cards,
        today: _today,
      );
      expect(expected.phase, SoloPhase.upcoming);
      expect(expected.cardId, 'card-02');

      for (int seed = 0; seed < 20; seed++) {
        final List<ActivityCard> shuffled = List<ActivityCard>.of(cards)
          ..shuffle(Random(seed));
        expect(resolveSoloPhase(cards: shuffled, today: _today), expected);
      }
    });

    test('a done card scheduled for today does not become dateDay', () {
      final PhaseResolution resolution = resolveSoloPhase(
        cards: <ActivityCard>[
          _card(
            id: 'card-a',
            status: ActivityCardStatus.done,
            scheduledOn: '2026-09-15',
          ),
        ],
        today: _today,
      );

      expect(resolution.phase, SoloPhase.quiet);
    });

    test('the clock time of day does not change the phase', () {
      final List<ActivityCard> cards = <ActivityCard>[
        _card(
          id: 'card-a',
          status: ActivityCardStatus.scheduled,
          scheduledOn: '2026-09-15',
        ),
      ];

      expect(
        resolveSoloPhase(cards: cards, today: DateTime(2026, 9, 15)),
        resolveSoloPhase(
          cards: cards,
          today: DateTime(2026, 9, 15, 23, 59, 59),
        ),
      );
    });
  });

  group('resolveSoloPhase — forbidden outputs', () {
    test('a past scheduled date never pulls the phase to upcoming (AC-15)', () {
      final PhaseResolution resolution = resolveSoloPhase(
        cards: <ActivityCard>[
          _card(
            id: 'card-missed',
            status: ActivityCardStatus.scheduled,
            scheduledOn: '2026-09-01',
          ),
        ],
        today: _today,
      );

      expect(resolution.phase, SoloPhase.quiet);
      expect(resolution.cardId, isNull);
      expect(resolution.scheduledOn, isNull);
    });

    test('a past date loses to a future one rather than winning as nearest',
        () {
      final PhaseResolution resolution = resolveSoloPhase(
        cards: <ActivityCard>[
          _card(
            id: 'card-missed',
            status: ActivityCardStatus.scheduled,
            scheduledOn: '2026-09-14',
          ),
          _card(
            id: 'card-next',
            status: ActivityCardStatus.scheduled,
            scheduledOn: '2026-10-30',
          ),
        ],
        today: _today,
      );

      expect(resolution.cardId, 'card-next');
      expect(resolution.scheduledOn, '2026-10-30');
    });

    test('the waiting branch carries no date to count from (AC-7)', () {
      final PhaseResolution resolution = resolveSoloPhase(
        cards: <ActivityCard>[
          _card(
            id: 'card-a',
            invited: true,
            updatedAt: DateTime(2026, 7, 1),
          ),
        ],
        today: _today,
      );

      expect(resolution.phase, SoloPhase.waiting);
      expect(resolution.scheduledOn, isNull);
    });

    test('waiting is identical however long the invite has been out (AC-6)',
        () {
      PhaseResolution resolveAt(DateTime updatedAt) => resolveSoloPhase(
            cards: <ActivityCard>[
              _card(id: 'card-a', invited: true, updatedAt: updatedAt),
            ],
            today: _today,
          );

      expect(resolveAt(DateTime(2026, 9, 14)), resolveAt(DateTime(2026, 1, 2)));
    });

    test('the phase types expose no elapsed or remaining quantity', () {
      final String source = _strippedDart(_phasePath) +
          _strippedDart(_resolverPath);

      for (final String forbidden in <String>[
        'Duration',
        'inDays',
        'inHours',
        '.difference(',
        'daysUntil',
        'daysLeft',
        'elapsed',
      ]) {
        expect(
          source.contains(forbidden),
          isFalse,
          reason: 'phase resolution must not carry a countable quantity: '
              '$forbidden',
        );
      }
    });

    test('the resolver reads no clock of its own', () {
      expect(_strippedDart(_resolverPath).contains('DateTime.now('), isFalse);
    });

    test('the resolver reads no partner-behaviour quantity (BR-3)', () {
      final String source = _strippedDart(_resolverPath);

      for (final String forbidden in <String>[
        'partner_seen_at',
        'partnerSeenAt',
        'opened_count',
        'openedCount',
        'open_times',
        'openTimes',
        'reply_latency',
        'replyLatency',
        'response_rate',
        'responseRate',
        'last_seen',
        'lastSeen',
        'viewed_at',
        'viewedAt',
        'partner_activity',
        'partnerActivity',
      ]) {
        expect(
          source.contains(forbidden),
          isFalse,
          reason: 'forbidden partner-behaviour input: $forbidden',
        );
      }
    });

    test('the resolver holds no repository and no content package', () {
      final String source = _strippedDart(_resolverPath);

      expect(source.contains('Repository'), isFalse);
      expect(source.contains('ContentPackage'), isFalse);
      expect(source.contains('http'), isFalse);
    });
  });
}
