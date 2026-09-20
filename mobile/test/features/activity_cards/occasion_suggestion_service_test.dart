import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/activity_cards/data/activity_card_repository_impl.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/activity_cards/domain/occasion_suggestion_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a package of [n] occasions whose dates run one per day from
/// 2030-01-01, so "nearest upcoming" has one unambiguous answer at any N.
ContentPackage<Occasion> _syntheticPackage(int n) {
  final items = List<Map<String, Object?>>.generate(n, (index) {
    final date = civilDate(DateTime(2030, 1, 1 + index));
    final suggestionCount = index % 3 + 1;
    return <String, Object?>{
      'id': 'occ_${index * 7 + 3}',
      'name': 'synthetic occasion $index',
      'calendar': index.isEven ? 'solar' : 'lunar',
      'dates': <String>[date],
      'suggestions': List<Map<String, Object?>>.generate(
        suggestionCount,
        (slot) => <String, Object?>{
          'id': 'occ_${index * 7 + 3}.s$slot',
          'title': 'synthetic title $index/$slot',
          'activity_type': 'outing',
        },
        growable: false,
      ),
    };
  }, growable: false);

  return ContentPackage.parse<Occasion>(
    jsonEncode(<String, Object?>{
      'id': 'occasions',
      'version': '1.0.0',
      'schema_id': occasionsSchemaId,
      'items': items,
    }),
    expectedSchemaId: occasionsSchemaId,
    itemParser: occasionFromJson,
  );
}

Never _explodingHttpClient(SecurityContext? context) => throw StateError(
  'R-7/BR-8 violated: the occasion suggestion path opened an HttpClient',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CupidDatabase database;
  late ActivityCardRepository repository;
  late OccasionSuggestionService service;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    repository = ActivityCardRepositoryImpl(
      dao: database.activityCardDao,
      ownerKeyStore: BackendUserIdStore()..updateUserId('user-1'),
    );
    service = OccasionSuggestionService(repository: repository);
  });

  tearDown(() async {
    await database.close();
  });

  group('hành vi đúng ở mọi N (R-15b)', () {
    for (final n in const <int>[1, 50]) {
      test('N=$n picks the nearest upcoming occasion and offers 1–2 '
          'suggestions', () {
        final package = _syntheticPackage(n);

        final prompt = OccasionSuggestionService.nearestOccasion(
          deviceDate: DateTime(2029, 12, 31),
          package: package,
        );

        expect(package.length, n);
        expect(prompt, isNotNull);
        expect(prompt!.occasionId, 'occ_3');
        expect(prompt.date, '2030-01-01');
        expect(prompt.suggestions, isNotEmpty);
        expect(
          prompt.suggestions.length,
          lessThanOrEqualTo(maxOccasionSuggestions),
        );
      });

      test('N=$n is deterministic: same device date and package give the same '
          'prompt', () {
        final package = _syntheticPackage(n);
        final deviceDate = DateTime(2030, 1, 1, 23, 59);

        final first = OccasionSuggestionService.nearestOccasion(
          deviceDate: deviceDate,
          package: package,
        );
        final second = OccasionSuggestionService.nearestOccasion(
          deviceDate: deviceDate,
          package: package,
        );

        expect(first!.occasionId, second!.occasionId);
        expect(first.date, second.date);
        expect(
          first.suggestions.map((suggestion) => suggestion.id).toList(),
          second.suggestions.map((suggestion) => suggestion.id).toList(),
        );
      });

      test('N=$n with no date on or after the device date yields no prompt '
          'rather than throwing', () {
        final prompt = OccasionSuggestionService.nearestOccasion(
          deviceDate: DateTime(2031, 6, 1),
          package: _syntheticPackage(n),
        );

        expect(prompt, isNull);
      });
    }

    test('an empty package yields no prompt', () {
      final prompt = OccasionSuggestionService.nearestOccasion(
        deviceDate: DateTime(2030, 1, 1),
        package: _syntheticPackage(0),
      );

      expect(prompt, isNull);
    });

    test('an occasion falling on the device date itself still counts as '
        'upcoming', () {
      final prompt = OccasionSuggestionService.nearestOccasion(
        deviceDate: DateTime(2030, 1, 1),
        package: _syntheticPackage(5),
      );

      expect(prompt!.date, '2030-01-01');
    });

    test('an occasion with more suggestions than AC-3 offers is capped at '
        'two', () {
      final prompt = OccasionSuggestionService.nearestOccasion(
        deviceDate: DateTime(2030, 1, 3),
        package: _syntheticPackage(5),
      );

      expect(prompt!.occasionId, 'occ_17');
      expect(prompt.suggestions.length, 2);
      expect(prompt.suggestions.first.id, 'occ_17.s0');
      expect(prompt.suggestions.last.id, 'occ_17.s1');
    });
  });

  group('gói ship sẵn `occasions.v1.json`', () {
    late ContentPackage<Occasion> shipped;

    setUp(() async {
      shipped = await loadOccasionPackage();
    });

    test('loads from the registered asset with a stable id per occasion and '
        'per suggestion (R-15a)', () {
      expect(shipped.id, 'occasions');
      expect(shipped.schemaId, occasionsSchemaId);
      expect(shipped.items, isNotEmpty);

      final suggestionIds = <String>{};
      for (final occasion in shipped.items) {
        expect(int.tryParse(occasion.id), isNull);
        expect(occasion.name, isNotEmpty);
        expect(occasion.calendar, anyOf('solar', 'lunar'));
        expect(occasion.dates, isNotEmpty);
        expect(occasion.suggestions, isNotEmpty);
        for (final date in occasion.dates) {
          expect(date, matches(r'^\d{4}-\d{2}-\d{2}$'));
        }
        for (final suggestion in occasion.suggestions) {
          expect(int.tryParse(suggestion.id), isNull);
          expect(
            suggestionIds.add(suggestion.id),
            isTrue,
            reason: 'duplicate suggestion id ${suggestion.id}',
          );
        }
      }
    });

    test('the nearest upcoming occasion for a fixed device date is 1–2 '
        'suggestions', () {
      final prompt = OccasionSuggestionService.nearestOccasion(
        deviceDate: DateTime(2026, 2, 15),
        package: shipped,
      );

      expect(prompt!.occasionId, 'tet_nguyen_dan');
      expect(prompt.date, '2026-02-17');
      expect(prompt.suggestions.length, 2);
    });

    test('the prompt carries the display name and calendar provenance the '
        'screen renders, so neither is derived in Dart', () {
      final prompt = OccasionSuggestionService.nearestOccasion(
        deviceDate: DateTime(2026, 9, 1),
        package: shipped,
      );

      expect(prompt!.occasion.name, 'Rằm tháng Tám');
      expect(prompt.occasion.calendar, 'lunar');
      expect(prompt.date, '2026-09-25');
    });

    test('an occasion without a display name is rejected at load', () {
      expect(
        () => ContentPackage.parse<Occasion>(
          jsonEncode(<String, Object?>{
            'id': 'occasions',
            'version': '1.0.0',
            'schema_id': occasionsSchemaId,
            'items': <Map<String, Object?>>[
              <String, Object?>{
                'id': 'occ_nameless',
                'calendar': 'solar',
                'dates': <String>['2030-01-01'],
                'suggestions': <Map<String, Object?>>[
                  <String, Object?>{'id': 'occ_nameless.s0', 'title': 't'},
                ],
              },
            ],
          }),
          expectedSchemaId: occasionsSchemaId,
          itemParser: occasionFromJson,
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (error) => error.message,
            'message',
            contains('field "name" must be a non-empty string'),
          ),
        ),
      );
    });

    test('no occasion content string is written into any Dart file '
        '(R-15a)', () {
      final titles = <String>[
        for (final occasion in shipped.items) ...<String>[
          occasion.name,
          for (final suggestion in occasion.suggestions) suggestion.title,
        ],
      ];
      final offenders = <String>[];

      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }
        final source = entity.readAsStringSync();
        for (final title in titles) {
          if (source.contains(title)) {
            offenders.add('${entity.path} contains "$title"');
          }
        }
      }

      expect(titles, isNotEmpty);
      expect(offenders, isEmpty);
    });
  });

  group('chọn gợi ý tạo thẻ ngay (AC-3)', () {
    test('accepting a suggestion creates one idea card with origin '
        'occasion_suggestion and asks for no further field', () async {
      final prompt = OccasionSuggestionService.nearestOccasion(
        deviceDate: DateTime(2029, 12, 31),
        package: _syntheticPackage(50),
      );

      final card = await service.acceptSuggestion(prompt!.suggestions.first);

      expect(card.title, 'synthetic title 0/0');
      expect(card.status, ActivityCardStatus.idea);
      expect(card.origin, ActivityCardOrigin.occasionSuggestion);
      expect(card.activityType, ActivityType.outing);
      expect(card.scheduledOn, isNull);
      expect(card.note, isNull);
      expect(card.priceVnd, isNull);

      final panel = await repository.cardsByStatus(
        status: ActivityCardStatus.idea,
        limit: 10,
      );
      expect(panel.map((saved) => saved.id), contains(card.id));
    });
  });

  group('không lời gọi mạng nào trên đường gợi ý (R-7, BR-8, AC-5)', () {
    test('load + suggest + create runs to completion under an HttpClient that '
        'throws if it is ever opened', () async {
      await HttpOverrides.runZoned(() async {
        final package = await loadOccasionPackage();

        final prompt = OccasionSuggestionService.nearestOccasion(
          deviceDate: DateTime(2026, 2, 15),
          package: package,
        );

        expect(prompt, isNotNull);
        expect(prompt!.suggestions.length, inInclusiveRange(1, 2));

        final card = await service.acceptSuggestion(prompt.suggestions.first);
        expect(card.origin, ActivityCardOrigin.occasionSuggestion);
      }, createHttpClient: _explodingHttpClient);
    });

    test('the control: opening an HttpClient inside the same zone does '
        'throw', () {
      HttpOverrides.runZoned(() {
        expect(HttpClient.new, throwsStateError);
      }, createHttpClient: _explodingHttpClient);
    });
  });
}
