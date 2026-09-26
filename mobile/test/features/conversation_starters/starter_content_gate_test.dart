import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/content/invariant_terms.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/conversation_starters/domain/starter_content.dart';
import 'package:cupid_mobile/features/conversation_starters/domain/starter_content_gate.dart';
import 'package:flutter_test/flutter_test.dart';

ContentPackage<StarterItem> _parseStarters(
  String source, {
  String label = '<fixture>',
}) =>
    ContentPackage.parse<StarterItem>(
      source,
      expectedSchemaId: startersSchemaId,
      itemParser: starterItemFromJson,
      source: label,
    );

ContentPackage<CalendarEvent> _parseEvents(
  String source, {
  String label = '<fixture>',
}) =>
    ContentPackage.parse<CalendarEvent>(
      source,
      expectedSchemaId: calendarEventsSchemaId,
      itemParser: calendarEventFromJson,
      source: label,
    );

String _startersPack({
  String genericText = 'Hôm nay có chuyện gì làm bạn bật cười không?',
  String contextualText = 'Bạn bắt đầu thích {value} từ lúc nào vậy?',
  String kind = 'contextual',
  Object? contextSlot = 'interest',
  String schemaId = startersSchemaId,
}) =>
    jsonEncode(<String, Object?>{
      'id': 'starters.fixture',
      'version': '1.0.0',
      'schema_id': schemaId,
      'locale': 'vi',
      'items': <Map<String, Object?>>[
        <String, Object?>{
          'id': 'starter.fixture.generic.v1',
          'kind': 'generic',
          'text': genericText,
        },
        <String, Object?>{
          'id': 'starter.fixture.contextual.v1',
          'kind': kind,
          'text': contextualText,
          'context_slot': ?contextSlot,
        },
      ],
    });

String _eventsPack({
  String name = 'Tết Trung Thu',
  String calendar = 'lunar',
  List<String> dates = const <String>['2027-09-15'],
  Object? activityType = 'walk',
  Object? reasonTemplate,
  Object? reasonContextSlot,
}) =>
    jsonEncode(<String, Object?>{
      'id': 'calendar_events.fixture',
      'version': '1.0.0',
      'schema_id': calendarEventsSchemaId,
      'locale': 'vi',
      'items': <Map<String, Object?>>[
        <String, Object?>{
          'id': 'calendar_event.fixture.v1',
          'name': name,
          'calendar': calendar,
          'dates': dates,
          'activity_type': ?activityType,
          'reason_template': ?reasonTemplate,
          'reason_context_slot': ?reasonContextSlot,
        },
      ],
    });

List<StarterViolation> _violations({
  String genericText = 'Hôm nay có chuyện gì làm bạn bật cười không?',
  String contextualText = 'Bạn bắt đầu thích {value} từ lúc nào vậy?',
  String kind = 'contextual',
  Object? contextSlot = 'interest',
  String eventName = 'Tết Trung Thu',
  List<String> dates = const <String>['2027-09-15'],
  Object? activityType = 'walk',
  Object? reasonTemplate,
  Object? reasonContextSlot,
}) =>
    validateStarterPacks(
      starters: _parseStarters(
        _startersPack(
          genericText: genericText,
          contextualText: contextualText,
          kind: kind,
          contextSlot: contextSlot,
        ),
      ),
      calendarEvents: _parseEvents(
        _eventsPack(
          name: eventName,
          dates: dates,
          activityType: activityType,
          reasonTemplate: reasonTemplate,
          reasonContextSlot: reasonContextSlot,
        ),
      ),
    );

List<StarterGateRule> _rulesFrom(List<StarterViolation> violations) =>
    violations.map((StarterViolation v) => v.rule).toList(growable: false);

void main() {
  group('the shipped packs pass the gate from disk (AC-26/AC-29)', () {
    late ContentPackage<StarterItem> starters;
    late ContentPackage<CalendarEvent> calendarEvents;

    setUp(() {
      starters = _parseStarters(
        File(startersAssetKey).readAsStringSync(),
        label: startersAssetKey,
      );
      calendarEvents = _parseEvents(
        File(calendarEventsAssetKey).readAsStringSync(),
        label: calendarEventsAssetKey,
      );
    });

    test('both packs exist on disk and are not empty', () {
      expect(File(startersAssetKey).existsSync(), isTrue);
      expect(File(calendarEventsAssetKey).existsSync(), isTrue);
      expect(starters.items, isNotEmpty);
      expect(calendarEvents.items, isNotEmpty);
    });

    test('the packs on disk report no violation', () {
      expect(
        validateStarterPacks(
          starters: starters,
          calendarEvents: calendarEvents,
        ).map((StarterViolation v) => v.toString()),
        isEmpty,
      );
    });

    test('both starter kinds ship, so neither branch is dead data', () {
      expect(
        starters.items.map((StarterItem i) => i.kind).toSet(),
        StarterKind.values.toSet(),
      );
      expect(
        starters.items
            .where((StarterItem i) => i.kind == StarterKind.contextual)
            .map((StarterItem i) => i.contextSlot)
            .toSet(),
        StarterContextSlot.values.toSet(),
      );
    });

    test('every shipped event resolves its own dates and type', () {
      for (final CalendarEvent event in calendarEvents.items) {
        expect(event.dates, isNotEmpty, reason: event.id);
        if (event.activityTypeWireValue != null) {
          expect(event.activityType, isNotNull, reason: event.id);
        }
      }
      expect(
        calendarEvents.items.map((CalendarEvent e) => e.calendar).toSet(),
        EventCalendar.values.toSet(),
      );
    });

    test('the shipped events carry reason content, and both slots are used',
        () {
      final List<CalendarEvent> withReason = calendarEvents.items
          .where((CalendarEvent e) => e.reasonTemplate != null)
          .toList(growable: false);

      expect(withReason, isNotEmpty);
      expect(
        withReason.map((CalendarEvent e) => e.reasonContextSlot).toSet(),
        StarterContextSlot.values.toSet(),
      );
      // An event with no natural reason ships neither key, so the optional
      // pair stays optional rather than becoming a required one by habit.
      expect(
        calendarEvents.items.any((CalendarEvent e) => e.reasonTemplate == null),
        isTrue,
      );
    });

    test('no starter or event wording is written into Dart or l10n (BR-15)',
        () {
      final List<String> authored = <String>[
        for (final StarterItem item in starters.items) item.text,
        for (final CalendarEvent event in calendarEvents.items) ...<String>[
          event.name,
          ?event.reasonTemplate,
        ],
      ];
      final List<String> offenders = <String>[];

      for (final FileSystemEntity entity
          in Directory('lib').listSync(recursive: true)) {
        if (entity is! File ||
            !(entity.path.endsWith('.dart') || entity.path.endsWith('.arb'))) {
          continue;
        }
        final String source = entity.readAsStringSync();
        for (final String text in authored) {
          if (source.contains(text)) {
            offenders.add('${entity.path} contains "$text"');
          }
        }
      }

      expect(authored, isNotEmpty);
      expect(offenders, isEmpty);
    });
  });

  group('parser rules run before the gate sees a package', () {
    test('the fixture baseline is clean, so every red below is the one break',
        () {
      expect(_violations(), isEmpty);
    });

    test('an unknown starter kind is a parse error, not a default', () {
      expect(
        () => _parseStarters(_startersPack(kind: 'about_partner')),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('unsupported kind "about_partner"'),
          ),
        ),
      );
    });

    test('an unknown context_slot is a parse error', () {
      expect(
        () => _parseStarters(_startersPack(contextSlot: 'partner_behaviour')),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('unsupported context_slot "partner_behaviour"'),
          ),
        ),
      );
    });

    test('an unknown reason_context_slot is a parse error', () {
      expect(
        () => _parseEvents(
          _eventsPack(
            reasonTemplate: 'Đúng dòng "{value}" trong sổ tay',
            reasonContextSlot: 'weather',
          ),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('unsupported reason_context_slot "weather"'),
          ),
        ),
      );
    });

    test('an unknown calendar is a parse error', () {
      expect(
        () => _parseEvents(_eventsPack(calendar: 'gregorian_plus')),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('unsupported calendar "gregorian_plus"'),
          ),
        ),
      );
    });

    test('a starter without text is rejected', () {
      expect(
        () => _parseStarters(_startersPack(contextualText: '')),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('field "text" must be a non-empty string'),
          ),
        ),
      );
    });

    test('a pack under another schema id is rejected at load', () {
      expect(
        () => _parseStarters(_startersPack(schemaId: 'req016.starters.v2')),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('does not match the expected "req016.starters.v1"'),
          ),
        ),
      );
    });
  });

  group('R-1g: a starter must end by asking (AC-20/BR-8)', () {
    test('a generic starter closing on a verdict', () {
      expect(
        _rulesFrom(
          _violations(genericText: 'Người ấy chắc chắn đang nghĩ về bạn.'),
        ),
        contains(StarterGateRule.missingQuestionEnding),
      );
    });

    test('a contextual starter closing on a verdict', () {
      expect(
        _rulesFrom(
          _violations(contextualText: 'Người ấy rất mê {value} rồi đó.'),
        ),
        contains(StarterGateRule.missingQuestionEnding),
      );
    });

    test('trailing whitespace does not smuggle a verdict past the rule', () {
      expect(
        _rulesFrom(_violations(genericText: 'Chắc là bạn mệt rồi.   ')),
        contains(StarterGateRule.missingQuestionEnding),
      );
      expect(
        _rulesFrom(_violations(genericText: 'Hôm nay bạn thế nào?   ')),
        isEmpty,
      );
    });

    test('the rule itself yields nothing for a question and one hit otherwise',
        () {
      expect(starterStructureHitsIn('Bạn ổn chứ?'), isEmpty);
      expect(
        starterStructureHitsIn('Bạn ổn.').map(
          (StarterStructureHit h) => h.rule,
        ),
        <StarterStructureRule>[StarterStructureRule.missingQuestionEnding],
      );
    });
  });

  group('the shared invariant rules fire on starter packs too (AC-22/AC-26)',
      () {
    test('flattery', () {
      expect(
        _rulesFrom(
          _violations(genericText: 'Bạn thật tuyệt vời, hôm nay sao rồi?'),
        ),
        contains(StarterGateRule.flattery),
      );
    });

    test('a percentage figure', () {
      expect(
        _rulesFrom(
          _violations(genericText: 'Hợp gu tới 80% đó, bạn thấy sao?'),
        ),
        contains(StarterGateRule.percentDisplay),
      );
    });

    test('a streak indicator', () {
      expect(
        _rulesFrom(
          _violations(genericText: 'Đã nhắn 5 ngày liên tiếp rồi, tiếp chứ?'),
        ),
        contains(StarterGateRule.streakDisplay),
      );
    });

    test('a score or ranking', () {
      expect(
        _rulesFrom(
          _violations(genericText: 'Xếp hạng câu nào hợp bạn nhất nhé?'),
        ),
        contains(StarterGateRule.scoreOrRatio),
      );
    });

    test('a recipient-behaviour indicator (R-1b)', () {
      expect(
        _rulesFrom(
          _violations(genericText: 'Bạn đã xem tin của mình chưa vậy?'),
        ),
        contains(StarterGateRule.recipientBehaviour),
      );
    });

    test('a manipulative tone (AC-22)', () {
      expect(
        _rulesFrom(_violations(genericText: 'Thả thính câu này xem sao?')),
        contains(StarterGateRule.manipulativeTone),
      );
    });

    test('an event name is scanned too, not only a starter', () {
      expect(
        _rulesFrom(_violations(eventName: 'Ngày hội tuyệt vời')),
        contains(StarterGateRule.flattery),
      );
    });
  });

  group('kind and the substitution token must agree (contract §3)', () {
    test('a contextual starter with no context_slot', () {
      expect(
        _rulesFrom(_violations(contextSlot: null)),
        contains(StarterGateRule.contextSlotMismatch),
      );
    });

    test('a generic starter carrying a context_slot', () {
      expect(
        _rulesFrom(
          _violations(
            kind: 'generic',
            contextualText: 'Hôm nay bạn thế nào?',
          ),
        ),
        contains(StarterGateRule.contextSlotMismatch),
      );
    });

    test('a contextual starter with no token', () {
      expect(
        _rulesFrom(_violations(contextualText: 'Bạn thích điều gì nhất?')),
        contains(StarterGateRule.valueTokenMismatch),
      );
    });

    test('a contextual starter with the token twice', () {
      expect(
        _rulesFrom(
          _violations(contextualText: 'Bạn thích {value} hay {value} hơn?'),
        ),
        contains(StarterGateRule.valueTokenMismatch),
      );
    });

    test('a generic starter carrying the token', () {
      expect(
        _rulesFrom(
          _violations(
            kind: 'generic',
            contextSlot: null,
            contextualText: 'Bạn thấy {value} thế nào?',
          ),
        ),
        contains(StarterGateRule.valueTokenMismatch),
      );
    });
  });

  group('an event must carry usable dates and a known type (AC-30)', () {
    test('an event with no date at all', () {
      expect(
        _rulesFrom(_violations(dates: const <String>[])),
        contains(StarterGateRule.emptyEventDates),
      );
    });

    test('a date in another format', () {
      expect(
        _rulesFrom(_violations(dates: const <String>['15/09/2027'])),
        contains(StarterGateRule.malformedEventDate),
      );
    });

    test('a date that matches the shape but does not exist', () {
      expect(
        _rulesFrom(_violations(dates: const <String>['2027-02-30'])),
        contains(StarterGateRule.malformedEventDate),
      );
    });

    test('an activity_type the build does not ship', () {
      expect(
        _rulesFrom(_violations(activityType: 'news_feed')),
        contains(StarterGateRule.unknownActivityType),
      );
    });

    test('a missing activity_type is legal, not an unknown one', () {
      expect(_rulesFrom(_violations(activityType: null)), isEmpty);
    });

    test('every shipped activity type is accepted by the gate', () {
      for (final ActivityType type in ActivityType.values) {
        expect(
          _rulesFrom(_violations(activityType: type.wireValue)),
          isEmpty,
          reason: type.wireValue,
        );
      }
    });
  });

  group('dòng lý do của gói sự kiện (ruling 2026-09-20 mục 7)', () {
    const String reason = 'Đúng dòng "{value}" trong sổ tay';

    test('a declared reason with both keys is clean', () {
      expect(
        _violations(
          reasonTemplate: reason,
          reasonContextSlot: 'interest',
        ),
        isEmpty,
      );
    });

    test('an event declaring neither key is clean — the line is optional', () {
      expect(_violations(), isEmpty);
    });

    test('a reason_template with no reason_context_slot', () {
      expect(
        _rulesFrom(_violations(reasonTemplate: reason)),
        contains(StarterGateRule.eventReasonSlotMismatch),
      );
    });

    test('a reason_context_slot with no reason_template', () {
      expect(
        _rulesFrom(_violations(reasonContextSlot: 'interest')),
        contains(StarterGateRule.eventReasonSlotMismatch),
      );
    });

    test('a reason_template carrying no token', () {
      expect(
        _rulesFrom(
          _violations(
            reasonTemplate: 'Đúng dòng bạn đã ghi trong sổ tay',
            reasonContextSlot: 'interest',
          ),
        ),
        contains(StarterGateRule.eventReasonTokenMismatch),
      );
    });

    test('a reason_template carrying the token twice', () {
      expect(
        _rulesFrom(
          _violations(
            reasonTemplate: 'Đúng dòng "{value}" và "{value}" trong sổ tay',
            reasonContextSlot: 'interest',
          ),
        ),
        contains(StarterGateRule.eventReasonTokenMismatch),
      );
    });

    test('a reason_template that ends by asking', () {
      expect(
        _rulesFrom(
          _violations(
            reasonTemplate: 'Bạn còn thích "{value}" chứ?',
            reasonContextSlot: 'interest',
          ),
        ),
        contains(StarterGateRule.eventReasonAsksQuestion),
      );
    });

    test('a reason_template is scanned by the shared display rules too', () {
      expect(
        _rulesFrom(
          _violations(
            reasonTemplate: 'Đúng dòng tuyệt vời "{value}" trong sổ tay',
            reasonContextSlot: 'interest',
          ),
        ),
        contains(StarterGateRule.flattery),
      );
    });
  });

  group('the R-1g rule is added beside InvariantRule, not inside it (§6)', () {
    test('InvariantRule still carries exactly its seven display rules', () {
      expect(
        InvariantRule.values.map((InvariantRule r) => r.wireValue),
        <String>[
          'flattery',
          'percent_display',
          'streak_display',
          'score_or_ratio',
          'recipient_behaviour',
          'manipulative_tone',
          'assertive_claim',
        ],
      );
    });

    test('invariantHitsIn never yields the new rule', () {
      const List<String> samples = <String>[
        'Bạn ổn chứ?',
        'Bạn ổn.',
        'Hôm nay trời đẹp',
      ];
      for (final String sample in samples) {
        for (final InvariantTermHit hit in invariantHitsIn(sample)) {
          expect(InvariantRule.values, contains(hit.rule), reason: sample);
        }
      }
    });

    test('the first seven gate rules pair by wire value with InvariantRule',
        () {
      expect(
        StarterGateRule.values
            .take(InvariantRule.values.length)
            .map((StarterGateRule r) => r.wireValue),
        InvariantRule.values.map((InvariantRule r) => r.wireValue),
      );
    });
  });

  group('no network and no lunar-conversion dependency (AC-15/AC-16)', () {
    test('the conversation starter feature imports no HTTP client', () {
      final List<String> offenders = <String>[];

      for (final FileSystemEntity entity
          in Directory('lib/features/conversation_starters')
              .listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }
        final String source = entity.readAsStringSync();
        for (final String forbidden in const <String>[
          'dart:io',
          'package:http/',
          'package:dio/',
          'HttpClient',
        ]) {
          if (source.contains(forbidden)) {
            offenders.add('${entity.path} references "$forbidden"');
          }
        }
      }

      expect(offenders, isEmpty);
    });

    test('pubspec declares no lunar calendar dependency', () {
      final String pubspec = File('pubspec.yaml').readAsStringSync();
      for (final String forbidden in const <String>[
        'lunar',
        'am_lich',
        'chinese_calendar',
      ]) {
        expect(pubspec.contains(forbidden), isFalse, reason: forbidden);
      }
    });
  });
}
