import 'dart:async';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/phase_status/data/home_widget_bridge.dart';
import 'package:cupid_mobile/features/phase_status/data/phase_content_repository.dart';
import 'package:cupid_mobile/features/phase_status/domain/phase_content.dart';
import 'package:cupid_mobile/features/phase_status/domain/solo_phase.dart';
import 'package:cupid_mobile/features/phase_status/domain/solo_phase_resolver.dart';
import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart'
    show ByteData, CachingAssetBundle, MethodCall, MethodChannel;
import 'package:flutter_test/flutter_test.dart';

/// The day every case here reads as "today", so the countdown asserts a fixed
/// number instead of one that moves with the wall clock.
final DateTime _today = DateTime(2026, 9, 16);

/// The shipped packs, read off disk: the payload under test is the copy an
/// author actually shipped, not a fixture that can drift away from it.
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final File file = File(key);
    if (!file.existsSync()) {
      throw FlutterError('no shipped asset at "$key"');
    }
    return ByteData.sublistView(file.readAsBytesSync());
  }
}

Future<ContentPackage<PhaseContentItem>> _shippedPack() async =>
    (await PhaseContentRepository(bundle: _DiskBundle()).catalogue())
        .phaseContent;

ContentPackage<PhaseContentItem> _pack(List<PhaseContentItem> items) =>
    ContentPackage<PhaseContentItem>(
      id: 'test',
      version: '1.0.0',
      schemaId: phaseContentSchemaId,
      items: items,
    );

/// A card whose every author-typed field is a distinctive nonsense token, so a
/// leak into the payload is a substring match rather than a judgement call.
ActivityCard _privateCard({
  required String id,
  required ActivityCardStatus status,
  String? scheduledOn,
  bool invited = false,
  ActivityCardReplyState replyState = ActivityCardReplyState.answered,
}) =>
    ActivityCard(
      id: id,
      ownerKey: 'owner',
      title: 'Zqxwv the secret plan',
      status: status,
      origin: ActivityCardOrigin.manual,
      scheduledOn: scheduledOn,
      note: 'Jkvbn private note body',
      noteKeywords: 'Pmtrl keyword',
      location: 'Hgdfs alley',
      invited: invited,
      replyState: replyState,
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    );

const List<String> _privateTokens = <String>[
  'Zqxwv',
  'Jkvbn',
  'Pmtrl',
  'Hgdfs',
];

class _FakeRepository implements ActivityCardRepository {
  _FakeRepository({Map<ActivityCardStatus, int>? counts, this.throws = false})
      : _counts = counts ?? const <ActivityCardStatus, int>{};

  final Map<ActivityCardStatus, int> _counts;
  final bool throws;

  @override
  Future<Map<ActivityCardStatus, int>> countsByStatus() async {
    if (throws) {
      throw StateError('store unavailable');
    }
    return _counts;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ContentPackage<PhaseContentItem> shipped;

  setUpAll(() async {
    shipped = await _shippedPack();
  });

  group('the key set is the contract, exactly (contract-summary 2)', () {
    test('the declared key list is the six contract names in order', () {
      expect(widgetPayloadKeys, <String>[
        'phase_id',
        'primary_line',
        'secondary_line',
        'eyebrow_line',
        'card_id',
        'computed_on',
      ]);
    });

    test('no phase can produce a key outside that list', () async {
      for (final SoloPhase phase in SoloPhase.values) {
        final Map<String, String> payload = buildWidgetPayload(
          resolution: PhaseResolution(
            phase: phase,
            cardId: phase == SoloPhase.quiet ? null : 'card-1',
            scheduledOn: phase == SoloPhase.upcoming ? '2026-09-19' : null,
          ),
          phaseContent: shipped,
          today: _today,
          memoryCount: 4,
        );
        expect(payload, isNotEmpty, reason: 'no widget line for $phase');
        expect(payload.keys, everyElement(isIn(widgetPayloadKeys)));
      }
    });

    test('phase_id is the ASCII wire value, never a Vietnamese label', () {
      for (final SoloPhase phase in SoloPhase.values) {
        final Map<String, String> payload = buildWidgetPayload(
          resolution: PhaseResolution(
            phase: phase,
            scheduledOn: phase == SoloPhase.upcoming ? '2026-09-19' : null,
          ),
          phaseContent: shipped,
          today: _today,
          memoryCount: 4,
        );
        expect(payload[widgetKeyPhaseId], phase.wireValue);
        expect(payload[widgetKeyPhaseId], matches(RegExp(r'^[a-z_]+$')));
      }
    });

    test('computed_on is the civil date of the pass that built it', () {
      final Map<String, String> payload = buildWidgetPayload(
        resolution: const PhaseResolution(phase: SoloPhase.waiting),
        phaseContent: shipped,
        today: _today,
      );
      expect(payload[widgetKeyComputedOn], '2026-09-16');
    });

    test('card_id rides along on the phases that have one, and quiet has none',
        () {
      final Map<String, String> waiting = buildWidgetPayload(
        resolution: const PhaseResolution(
          phase: SoloPhase.waiting,
          cardId: 'card-9',
        ),
        phaseContent: shipped,
        today: _today,
      );
      expect(waiting[widgetKeyCardId], 'card-9');

      final Map<String, String> quiet = buildWidgetPayload(
        resolution: const PhaseResolution(phase: SoloPhase.quiet),
        phaseContent: shipped,
        today: _today,
        memoryCount: 3,
      );
      expect(quiet.containsKey(widgetKeyCardId), isFalse);
    });

    test('every phase pushes an eyebrow_line, taken from the pack (D-10)', () {
      for (final SoloPhase phase in SoloPhase.values) {
        final Map<String, String> payload = buildWidgetPayload(
          resolution: PhaseResolution(
            phase: phase,
            scheduledOn: phase == SoloPhase.upcoming ? '2026-09-19' : null,
          ),
          phaseContent: shipped,
          today: _today,
          memoryCount: 4,
        );
        final String? eyebrow = payload[widgetKeyEyebrowLine];
        expect(eyebrow, isNotNull, reason: 'no eyebrow for $phase');
        expect(
          shipped.items.map((PhaseContentItem item) => item.eyebrow),
          contains(eyebrow),
          reason: '$phase',
        );
      }
    });

    test('the eyebrow never carries a count, only the phase name (AC-9)', () {
      Map<String, String> quietWith(int? memoryCount) => buildWidgetPayload(
            resolution: const PhaseResolution(phase: SoloPhase.quiet),
            phaseContent: shipped,
            today: _today,
            memoryCount: memoryCount,
          );

      expect(
        quietWith(7)[widgetKeyEyebrowLine],
        quietWith(41)[widgetKeyEyebrowLine],
      );
      for (final Map<String, String> payload in <Map<String, String>>[
        quietWith(7),
        quietWith(41),
      ]) {
        expect(
          payload[widgetKeyEyebrowLine],
          isNot(contains(phaseContentNumberPlaceholder)),
        );
      }
    });
  });

  group('the lines come from the pack and nowhere else (AC-37/BR-15)', () {
    test('every readable value appears in the pack once {n} is filled', () {
      for (final SoloPhase phase in SoloPhase.values) {
        final Map<String, String> payload = buildWidgetPayload(
          resolution: PhaseResolution(
            phase: phase,
            scheduledOn: phase == SoloPhase.upcoming ? '2026-09-19' : null,
          ),
          phaseContent: shipped,
          today: _today,
          memoryCount: 6,
        );
        final Iterable<String> packStrings = shipped.items
            .expand((PhaseContentItem item) => item.displayStrings)
            .map((String text) => text.replaceAll(
                  phaseContentNumberPlaceholder,
                  phase == SoloPhase.upcoming ? '3' : '6',
                ));
        for (final String key in <String>[
          widgetKeyPrimaryLine,
          widgetKeySecondaryLine,
          widgetKeyEyebrowLine,
        ]) {
          if (payload[key] case final String line) {
            expect(packStrings, contains(line));
          }
        }
      }
    });

    test('{n} is substituted, never shipped through to the widget', () {
      final Map<String, String> payload = buildWidgetPayload(
        resolution: const PhaseResolution(
          phase: SoloPhase.upcoming,
          cardId: 'card-1',
          scheduledOn: '2026-09-19',
        ),
        phaseContent: shipped,
        today: _today,
      );
      expect(payload[widgetKeyPrimaryLine], contains('3'));
      for (final String value in payload.values) {
        expect(value, isNot(contains(phaseContentNumberPlaceholder)));
      }
    });

    test('quiet counts memories, and falls to the neutral line without one',
        () {
      final Map<String, String> counted = buildWidgetPayload(
        resolution: const PhaseResolution(phase: SoloPhase.quiet),
        phaseContent: shipped,
        today: _today,
        memoryCount: 7,
      );
      expect(counted[widgetKeyPrimaryLine], contains('7'));

      final Map<String, String> neutral = buildWidgetPayload(
        resolution: const PhaseResolution(phase: SoloPhase.quiet),
        phaseContent: shipped,
        today: _today,
      );
      expect(
        neutral[widgetKeyPrimaryLine],
        isNot(equals(counted[widgetKeyPrimaryLine])),
      );
      expect(
        neutral[widgetKeyPrimaryLine],
        isNot(contains(phaseContentNumberPlaceholder)),
      );
    });

    test('an empty pack pushes a textless payload, not a default sentence', () {
      final Map<String, String> payload = buildWidgetPayload(
        resolution: const PhaseResolution(
          phase: SoloPhase.waiting,
          cardId: 'card-1',
        ),
        phaseContent: _pack(const <PhaseContentItem>[]),
        today: _today,
      );
      expect(payload, isEmpty);
    });

    test('a screen-only item is never picked up by the widget', () {
      final Map<String, String> payload = buildWidgetPayload(
        resolution: const PhaseResolution(phase: SoloPhase.waiting),
        phaseContent: _pack(const <PhaseContentItem>[
          PhaseContentItem(
            id: 'screen.only',
            phaseId: PhaseId.waiting,
            primary: 'screen only',
            secondary: null,
            eyebrow: 'screen eyebrow',
            surface: PhaseSurface.screen,
          ),
        ]),
        today: _today,
      );
      expect(payload, isEmpty);
    });
  });

  group('the public surface leaks nothing (WIDGET-LEAK, AC-11/AC-12/BR-11)',
      () {
    test('no field the user typed reaches a payload value, on any phase', () {
      final List<ActivityCard> cards = <ActivityCard>[
        _privateCard(
          id: '11111111-1111-4111-8111-111111111111',
          status: ActivityCardStatus.scheduled,
          scheduledOn: '2026-09-19',
        ),
        _privateCard(
          id: '22222222-2222-4222-8222-222222222222',
          status: ActivityCardStatus.idea,
          invited: true,
          replyState: ActivityCardReplyState.notAnswered,
        ),
      ];

      for (final DateTime day in <DateTime>[
        DateTime(2026, 9, 16),
        DateTime(2026, 9, 19),
        DateTime(2026, 10, 30),
      ]) {
        final PhaseResolution resolution =
            resolveSoloPhase(cards: cards, today: day);
        final Map<String, String> payload = buildWidgetPayload(
          resolution: resolution,
          phaseContent: shipped,
          today: day,
          memoryCount: 5,
        );
        for (final String value in payload.values) {
          for (final String token in _privateTokens) {
            expect(value, isNot(contains(token)), reason: 'on $day');
          }
        }
      }
    });

    test('the waiting payload carries no number at all (AC-6/AC-7)', () {
      final Map<String, String> payload = buildWidgetPayload(
        resolution: const PhaseResolution(
          phase: SoloPhase.waiting,
          cardId: 'card-1',
        ),
        phaseContent: shipped,
        today: _today,
        // Supplied on purpose: even handed a count, the waiting branch has
        // nowhere to put it, so an elapsed-days line is unrenderable rather
        // than merely unwritten.
        memoryCount: 42,
      );
      expect(payload[widgetKeyPrimaryLine], isNot(matches(RegExp(r'\d'))));
      expect(payload[widgetKeySecondaryLine] ?? '',
          isNot(matches(RegExp(r'\d'))));
    });

    test('a waiting item that needs {n} is skipped, not filled', () {
      final Map<String, String> payload = buildWidgetPayload(
        resolution: const PhaseResolution(phase: SoloPhase.waiting),
        phaseContent: _pack(const <PhaseContentItem>[
          PhaseContentItem(
            id: 'waiting.counting',
            phaseId: PhaseId.waiting,
            primary: 'da doi {n} ngay',
            secondary: null,
            eyebrow: 'pha 1',
            surface: PhaseSurface.widget,
          ),
        ]),
        today: _today,
        memoryCount: 12,
      );
      expect(payload, isEmpty);
    });

    test('waiting and quiet expose the same key shape, so neither is the '
        'more private one (BR-11)', () {
      final Set<String> waiting = buildWidgetPayload(
        resolution: const PhaseResolution(
          phase: SoloPhase.waiting,
          cardId: 'card-1',
        ),
        phaseContent: shipped,
        today: _today,
      ).keys.toSet();
      final Set<String> quiet = buildWidgetPayload(
        resolution: const PhaseResolution(phase: SoloPhase.quiet),
        phaseContent: shipped,
        today: _today,
        memoryCount: 5,
      ).keys.toSet();
      expect(
        waiting.difference(quiet),
        <String>{widgetKeyCardId},
        reason: 'the only extra key may be the deep-link target',
      );
      expect(quiet.difference(waiting), isEmpty);
    });
  });

  group('pushing is a single write with no schedule behind it (WIDGET-STALE)',
      () {
    test('every contract key is written, absent ones as null', () async {
      final List<MethodCall> calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('home_widget'),
              (MethodCall call) async {
        calls.add(call);
        return true;
      });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
                const MethodChannel('home_widget'), null);
      });

      await writeHomeWidgetPayload(<String, String>{
        widgetKeyPhaseId: 'quiet',
        widgetKeyPrimaryLine: 'line',
        widgetKeyComputedOn: '2026-09-16',
      });

      final Map<String, Object?> saved = <String, Object?>{
        for (final MethodCall call in calls)
          if (call.method == 'saveWidgetData')
            (call.arguments as Map<Object?, Object?>)['id'] as String:
                (call.arguments as Map<Object?, Object?>)['data'],
      };
      expect(saved.keys, unorderedEquals(widgetPayloadKeys));
      expect(saved[widgetKeySecondaryLine], isNull);
      expect(saved[widgetKeyCardId], isNull);
      expect(
        calls.map((MethodCall call) => call.method),
        contains('updateWidget'),
      );
    });

    test('the provider and widget kind are the contract identifiers', () async {
      final List<MethodCall> calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('home_widget'),
              (MethodCall call) async {
        calls.add(call);
        return true;
      });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
                const MethodChannel('home_widget'), null);
      });

      await writeHomeWidgetPayload(const <String, String>{});

      final MethodCall update =
          calls.firstWhere((MethodCall call) => call.method == 'updateWidget');
      final Map<Object?, Object?> args =
          update.arguments as Map<Object?, Object?>;
      expect(args['android'], 'CupidPhaseWidgetProvider');
      expect(args['ios'], 'CupidPhaseWidget');
      expect(widgetAppGroupId, 'group.com.snapsofts.cupid');
    });

    test('a missing platform is silent, so the app loses nothing (AC-13)',
        () async {
      await expectLater(
        writeHomeWidgetPayload(const <String, String>{
          widgetKeyPhaseId: 'quiet',
        }),
        completes,
      );
    });

    test('the publisher writes once per push and swallows a store failure',
        () async {
      final List<Map<String, String>> written = <Map<String, String>>[];
      final HomeWidgetPhasePublisher publisher = HomeWidgetPhasePublisher(
        _FakeRepository(
          counts: const <ActivityCardStatus, int>{ActivityCardStatus.memory: 8},
        ),
        content: PhaseContentRepository(bundle: _DiskBundle()),
        clock: () => _today,
        writer: (Map<String, String> payload) async => written.add(payload),
      );

      await publisher
          .pushWidgetPayload(const PhaseResolution(phase: SoloPhase.quiet));
      expect(written, hasLength(1));
      expect(written.single[widgetKeyPrimaryLine], contains('8'));

      final HomeWidgetPhasePublisher broken = HomeWidgetPhasePublisher(
        _FakeRepository(throws: true),
        content: PhaseContentRepository(bundle: _DiskBundle()),
        clock: () => _today,
        writer: (Map<String, String> payload) async => written.add(payload),
      );
      await broken
          .pushWidgetPayload(const PhaseResolution(phase: SoloPhase.quiet));
      expect(written, hasLength(1), reason: 'no write on a failed read');
    });

    test('a platform write that never answers still lets the push return',
        () async {
      // `PhaseStatusCubit.refresh` awaits the push before it emits the
      // sentence, so a push that waits for the home screen would take the
      // screen down with it (AC-13). A real MethodChannel under a test binding
      // is exactly such a write, which is how this was first caught.
      final HomeWidgetPhasePublisher publisher = HomeWidgetPhasePublisher(
        _FakeRepository(
          counts: const <ActivityCardStatus, int>{ActivityCardStatus.memory: 8},
        ),
        content: PhaseContentRepository(bundle: _DiskBundle()),
        clock: () => _today,
        writer: (Map<String, String> payload) => Completer<void>().future,
      );

      await expectLater(
        publisher
            .pushWidgetPayload(const PhaseResolution(phase: SoloPhase.quiet)),
        completes,
      );
    });

    test('the bridge names no timer, alarm, isolate or scheduler', () {
      final String source = File(
        'lib/features/phase_status/data/home_widget_bridge.dart',
      ).readAsStringSync();
      for (final String forbidden in <String>[
        'Timer',
        'Isolate',
        'compute(',
        'periodic',
        'scheduleWidgetUpdates',
        'registerBackgroundCallback',
        'listen(',
      ]) {
        expect(source.contains(forbidden), isFalse, reason: forbidden);
      }
    });
  });
}
