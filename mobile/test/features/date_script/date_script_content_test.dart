import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/date_script/domain/date_script_content.dart';
import 'package:flutter_test/flutter_test.dart';

ContentPackage<DateScriptPreset> _parse(
  String source, {
  String label = '<fixture>',
}) =>
    ContentPackage.parse<DateScriptPreset>(
      source,
      expectedSchemaId: dateScriptSchemaId,
      itemParser: dateScriptPresetFromJson,
      source: label,
    );

ContentPackage<DateScriptPreset> _shippedPack() {
  final File file = File(dateScriptAssetKey);
  expect(file.existsSync(), isTrue, reason: '$dateScriptAssetKey is missing');
  return _parse(file.readAsStringSync(), label: dateScriptAssetKey);
}

Map<String, Object?> _sentenceJson(
  String text, {
  List<String> requires = const <String>[],
  bool aboutPartner = false,
}) =>
    <String, Object?>{
      'text': text,
      'requires': requires,
      'aboutPartner': aboutPartner,
    };

Map<String, Object?> _partJson(
  String part, {
  List<Map<String, Object?>>? sentences,
}) =>
    <String, Object?>{
      'part': part,
      'sentences': sentences ??
          <Map<String, Object?>>[_sentenceJson('Câu mẫu không điều kiện.')],
    };

List<Map<String, Object?>> _defaultParts() => <Map<String, Object?>>[
      _partJson('before'),
      _partJson('during'),
      _partJson('after'),
    ];

String _fixturePack({
  List<Map<String, Object?>>? parts,
  List<String> activityTypes = const <String>[],
  String schemaId = dateScriptSchemaId,
  Object? editorialReview = const <String, Object?>{
    'layer1': 'reviewer.a',
    'layer2': 'reviewer.b',
    'approved_at': '2026-09-11',
  },
}) =>
    jsonEncode(<String, Object?>{
      'id': 'date_script.fixture',
      'version': '1.0.0',
      'schema_id': schemaId,
      'locale': 'vi',
      'items': <Map<String, Object?>>[
        <String, Object?>{
          'id': 'fixture.one.v1',
          'activityTypes': activityTypes,
          'parts': parts ?? _defaultParts(),
          'editorial_review': ?editorialReview,
        },
      ],
    });

Iterable<DateScriptSentence> _sentencesOf(DateScriptPreset preset) sync* {
  for (final DateScriptPartContent part in preset.parts) {
    yield* part.sentences;
  }
}

void main() {
  group('the shipped pack (AC-33/BR-16)', () {
    late ContentPackage<DateScriptPreset> pack;

    setUp(() {
      pack = _shippedPack();
    });

    test('parses under its own schema id and is not empty', () {
      expect(pack.schemaId, dateScriptSchemaId);
      expect(pack.items, isNotEmpty);
    });

    test('every preset id is unique and printable ASCII', () {
      final Set<String> seen = <String>{};
      for (final DateScriptPreset preset in pack.items) {
        expect(seen.add(preset.id), isTrue, reason: preset.id);
        expect(RegExp(r'^[\x21-\x7E]+$').hasMatch(preset.id), isTrue,
            reason: preset.id);
      }
    });

    test('every preset carries the three parts in order (AC-7)', () {
      for (final DateScriptPreset preset in pack.items) {
        expect(
          preset.parts.map((DateScriptPartContent p) => p.part),
          DateScriptPart.values,
          reason: preset.id,
        );
      }
    });

    test('the pack ships at least one generic preset (AC-34)', () {
      expect(
        pack.items.where(
          (DateScriptPreset preset) => preset.activityTypes.isEmpty,
        ),
        isNotEmpty,
      );
    });

    test('the pack ships at least one activity-typed preset too', () {
      expect(
        pack.items.where(
          (DateScriptPreset preset) => preset.activityTypes.isNotEmpty,
        ),
        isNotEmpty,
      );
    });

    test('every part has an unconditional sentence (AC-10/AC-37)', () {
      for (final DateScriptPreset preset in pack.items) {
        for (final DateScriptPartContent part in preset.parts) {
          expect(
            part.sentences.where(
              (DateScriptSentence sentence) => sentence.requires.isEmpty,
            ),
            isNotEmpty,
            reason: '${preset.id}/${part.part.wireValue}',
          );
        }
      }
    });

    test('every sentence about the other person ends in a question (AC-26)',
        () {
      final List<DateScriptSentence> partnerSentences = <DateScriptSentence>[
        for (final DateScriptPreset preset in pack.items)
          ..._sentencesOf(preset).where(
            (DateScriptSentence sentence) => sentence.aboutPartner,
          ),
      ];

      expect(partnerSentences, isNotEmpty);
      for (final DateScriptSentence sentence in partnerSentences) {
        expect(sentence.text.trimRight(), endsWith('?'),
            reason: sentence.text);
      }
    });

    test('every placeholder is one of the seven variables and is declared', () {
      for (final DateScriptPreset preset in pack.items) {
        for (final DateScriptSentence sentence in _sentencesOf(preset)) {
          for (final RegExpMatch match
              in dateScriptPlaceholderPattern.allMatches(sentence.text)) {
            final DateScriptVariable? variable =
                DateScriptVariable.fromWireValue(match.group(1)!);
            expect(variable, isNotNull, reason: sentence.text);
            expect(sentence.requires, contains(variable),
                reason: sentence.text);
          }
        }
      }
    });

    test('the notebook-sourced variables are actually exercised', () {
      final Set<DateScriptVariable> used = <DateScriptVariable>{
        for (final DateScriptPreset preset in pack.items)
          for (final DateScriptSentence sentence in _sentencesOf(preset))
            ...sentence.requires,
      };

      expect(used, containsAll(<DateScriptVariable>[
        DateScriptVariable.interest,
        DateScriptVariable.event,
      ]));
    });
  });

  group('the closed vocabularies (contract-summary section 2)', () {
    test('there are exactly three parts, in the contractual order', () {
      expect(
        DateScriptPart.values.map((DateScriptPart part) => part.wireValue),
        <String>['before', 'during', 'after'],
      );
    });

    test('there are exactly seven mad-libs variables', () {
      expect(
        DateScriptVariable.values
            .map((DateScriptVariable variable) => variable.wireValue),
        <String>[
          'activity',
          'date',
          'time',
          'place',
          'duration',
          'interest',
          'event',
        ],
      );
    });

    test('the documented near-miss names are not members', () {
      for (final String nearMiss in <String>[
        'activityType',
        'place_name',
        'durationMinutes',
        'interests',
        'partner_interest',
      ]) {
        expect(DateScriptVariable.fromWireValue(nearMiss), isNull,
            reason: nearMiss);
      }
    });
  });

  group('the parser rejects a malformed pack at load', () {
    test('the fixture pack itself is valid', () {
      final ContentPackage<DateScriptPreset> pack = _parse(_fixturePack());
      expect(pack.items.single.parts, hasLength(3));
      expect(pack.items.single.activityTypes, isEmpty);
    });

    test('an unknown variable in "requires"', () {
      expect(
        () => _parse(
          _fixturePack(
            parts: <Map<String, Object?>>[
              _partJson('before', sentences: <Map<String, Object?>>[
                _sentenceJson('Câu mẫu {interests}.',
                    requires: <String>['interests']),
              ]),
              _partJson('during'),
              _partJson('after'),
            ],
          ),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException error) => error.message,
            'message',
            contains('unknown mad-libs variable "interests"'),
          ),
        ),
      );
    });

    test('an unknown placeholder in "text"', () {
      expect(
        () => _parse(
          _fixturePack(
            parts: <Map<String, Object?>>[
              _partJson('before', sentences: <Map<String, Object?>>[
                _sentenceJson('Câu mẫu {dia_diem}.'),
              ]),
              _partJson('during'),
              _partJson('after'),
            ],
          ),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException error) => error.message,
            'message',
            contains('unknown placeholder "{dia_diem}"'),
          ),
        ),
      );
    });

    test('an unknown part name', () {
      expect(
        () => _parse(
          _fixturePack(
            parts: <Map<String, Object?>>[
              _partJson('before'),
              _partJson('midway'),
              _partJson('after'),
            ],
          ),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException error) => error.message,
            'message',
            contains('unknown part "midway"'),
          ),
        ),
      );
    });

    test('a missing part', () {
      expect(
        () => _parse(
          _fixturePack(
            parts: <Map<String, Object?>>[
              _partJson('before'),
              _partJson('during'),
            ],
          ),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException error) => error.message,
            'message',
            contains('exactly 3 parts, found 2'),
          ),
        ),
      );
    });

    test('the three parts out of order', () {
      expect(
        () => _parse(
          _fixturePack(
            parts: <Map<String, Object?>>[
              _partJson('before'),
              _partJson('after'),
              _partJson('during'),
            ],
          ),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException error) => error.message,
            'message',
            contains('declares part "after" at position 1'),
          ),
        ),
      );
    });

    test('a part with no sentence', () {
      expect(
        () => _parse(
          _fixturePack(
            parts: <Map<String, Object?>>[
              _partJson('before', sentences: <Map<String, Object?>>[]),
              _partJson('during'),
              _partJson('after'),
            ],
          ),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException error) => error.message,
            'message',
            contains('must declare at least one sentence'),
          ),
        ),
      );
    });

    test('an unknown activity type', () {
      expect(
        () => _parse(_fixturePack(activityTypes: <String>['karaoke'])),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException error) => error.message,
            'message',
            contains('unknown activity type "karaoke"'),
          ),
        ),
      );
    });

    test('a non-boolean "aboutPartner"', () {
      expect(
        () => _parse(
          _fixturePack(
            parts: <Map<String, Object?>>[
              _partJson('before', sentences: <Map<String, Object?>>[
                <String, Object?>{
                  'text': 'Câu mẫu.',
                  'requires': <String>[],
                  'aboutPartner': 'true',
                },
              ]),
              _partJson('during'),
              _partJson('after'),
            ],
          ),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException error) => error.message,
            'message',
            contains('field "aboutPartner" must be a boolean'),
          ),
        ),
      );
    });

    test('a pack under another schema id (AC-33)', () {
      expect(
        () => _parse(_fixturePack(schemaId: 'req016.date_script.v2')),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException error) => error.message,
            'message',
            contains('does not match the expected "$dateScriptSchemaId"'),
          ),
        ),
      );
    });

    test('a known activity type still parses into the enum', () {
      final ContentPackage<DateScriptPreset> pack = _parse(
        _fixturePack(activityTypes: <String>['dining']),
      );

      expect(pack.items.single.activityTypes, <ActivityType>[
        ActivityType.dining,
      ]);
    });
  });
}
