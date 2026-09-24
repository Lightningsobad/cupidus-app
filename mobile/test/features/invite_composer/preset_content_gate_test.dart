import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/invite_composer/domain/invite_preset.dart';
import 'package:cupid_mobile/features/invite_composer/domain/preset_catalogue.dart';
import 'package:cupid_mobile/features/invite_composer/domain/preset_content_gate.dart';
import 'package:flutter_test/flutter_test.dart';

const String _presetDir = 'assets/data/req016';
final RegExp _presetFileName = RegExp(r'^presets\..+\.json$');

/// Every shipped preset pack, found by scanning the directory rather than by
/// listing files here. STORY-007 drops its category in and lands inside this
/// gate with no second branch to write (AC-29).
List<File> _shippedPresetFiles() => Directory(_presetDir)
    .listSync()
    .whereType<File>()
    .where((File file) => _presetFileName.hasMatch(file.uri.pathSegments.last))
    .toList(growable: false)
  ..sort((File a, File b) => a.path.compareTo(b.path));

ContentPackage<InvitePreset> _parse(String source, {String label = '<fixture>'}) =>
    ContentPackage.parse<InvitePreset>(
      source,
      expectedSchemaId: presetsSchemaId,
      itemParser: invitePresetFromJson,
      source: label,
    );

/// The category a shipped pack is loaded under, read off the asset file name
/// rather than off `package.id`: [presetAssetKey] is what decides the category,
/// and the gate deliberately refuses to take it from the pack's own fields.
String _categoryOf(File file) {
  final String name = file.uri.pathSegments.last;
  return name.substring('presets.'.length, name.length - '.v1.json'.length);
}

/// Fixtures run against the invite category, whose rules are the strict ones
/// these tests describe. A test about a different category says so explicitly.
List<PresetViolation> _gate(
  String source, {
  String categoryId = inviteCategoryId,
}) =>
    validatePresetPack(_parse(source), categoryId: categoryId);

Map<String, Object?> _clause(
  String text, {
  List<String> requires = const <String>[],
  String targets = 'neutral',
  String? role,
}) =>
    <String, Object?>{
      'text': text,
      'requires': requires,
      'targets': targets,
      'role': ?role,
    };

/// A minimal pack that passes every gate rule, so a test only has to describe
/// the one thing it breaks.
String _fixturePack({
  List<Map<String, Object?>>? clauses,
  Object? editorialReview = const <String, Object?>{
    'layer1': 'reviewer.a',
    'layer2': 'reviewer.b',
    'approved_at': '2026-09-10',
  },
  String frame = 'synthetic frame',
  String schemaId = presetsSchemaId,
}) =>
    jsonEncode(<String, Object?>{
      'id': 'presets.fixture',
      'version': '1.0.0',
      'schema_id': schemaId,
      'locale': 'vi',
      'items': <Map<String, Object?>>[
        <String, Object?>{
          'id': 'fixture.one.v1',
          'frame': frame,
          'clauses': clauses ??
              <Map<String, Object?>>[
                _clause('synthetic body {activity}',
                    requires: <String>['activity']),
                _clause('synthetic door', role: 'decline_door'),
              ],
          'editorial_review': ?editorialReview,
        },
      ],
    });

List<PresetGateRule> _rulesFrom(List<PresetViolation> violations) =>
    violations.map((PresetViolation v) => v.rule).toList(growable: false);

void main() {
  group('shipped packs pass the gate (AC-28/BR-16)', () {
    late List<File> files;

    setUp(() {
      files = _shippedPresetFiles();
    });

    test('the directory scan actually finds packs', () {
      expect(files, isNotEmpty);
    });

    test('every pack on disk loads and reports no violation', () {
      for (final File file in files) {
        final ContentPackage<InvitePreset> package = _parse(
          file.readAsStringSync(),
          label: file.path,
        );

        expect(
          validatePresetPack(package, categoryId: _categoryOf(file))
              .map((PresetViolation v) => v.toString()),
          isEmpty,
          reason: '${file.path} broke an invariant rule',
        );
      }
    });

    /// Scoped by category since the ruling of 2026-09-23 (`req_master.md`
    /// `## Design Ruling Log`): a pack whose presets carry an invitation owes
    /// every reader a way out, and a thank-you has nothing to decline. What no
    /// category may do is carry two doors, or gate the door it has behind a
    /// card field the reader's card might not have.
    test('decline doors on disk follow the category rule (AC-10/BR-5)', () {
      for (final File file in files) {
        final ContentPackage<InvitePreset> package = _parse(
          file.readAsStringSync(),
          label: file.path,
        );
        expect(package.items, isNotEmpty, reason: file.path);
        final bool owesDoor = _categoryOf(file) == inviteCategoryId;

        for (final InvitePreset preset in package.items) {
          final Iterable<PresetClause> doors = preset.clauses.where(
            (PresetClause clause) => clause.role == ClauseRole.declineDoor,
          );
          expect(
            doors,
            owesDoor ? hasLength(1) : hasLength(lessThan(2)),
            reason: '${file.path}/${preset.id}',
          );
          for (final PresetClause door in doors) {
            expect(door.requires, isEmpty, reason: '${file.path}/${preset.id}');
          }
        }
      }
    });

    // The one place a preset count is pinned. AC-22 is a story scope boundary,
    // which BR-15 names as the single exception to "N is a data property" —
    // a story moves the boundary by editing this list, and nothing else.
    // STORY-007 added `thank_you_after_date` here and nowhere else in Dart.
    test('the shipped categories are exactly the declared ones (AC-22)', () {
      expect(
        files.map((File file) => file.uri.pathSegments.last),
        <String>[
          'presets.invite.v1.json',
          'presets.thank_you_after_date.v1.json',
        ],
      );
    });

    test('no shipped invite wording is written into any Dart file (R-15a)', () {
      final List<String> authored = <String>[
        for (final File file in files)
          for (final InvitePreset preset
              in _parse(file.readAsStringSync(), label: file.path).items) ...[
            preset.frame,
            for (final PresetClause clause in preset.clauses) clause.text,
          ],
      ];
      final List<String> offenders = <String>[];

      for (final FileSystemEntity entity
          in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
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

  group('structural rules', () {
    test('a preset with no decline door is a violation', () {
      final List<PresetViolation> violations = _gate(
        _fixturePack(
          clauses: <Map<String, Object?>>[
            _clause('synthetic body {activity}',
                requires: <String>['activity']),
          ],
        ),
      );

      expect(_rulesFrom(violations), contains(PresetGateRule.declineDoorMissing));
    });

    /// The other half of the 2026-09-23 ruling. The two directions are asserted
    /// together on the same fixture so the rule can never be relaxed for the
    /// invite category by a change that only meant to admit a new one.
    test('the same pack under a non-invite category is not a violation', () {
      final String pack = _fixturePack(
        clauses: <Map<String, Object?>>[
          _clause('synthetic body {activity}', requires: <String>['activity']),
        ],
      );

      expect(
        _rulesFrom(_gate(pack)),
        contains(PresetGateRule.declineDoorMissing),
      );
      expect(_gate(pack, categoryId: 'thank_you_after_date'), isEmpty);
    });

    test('a preset with two decline doors is a violation', () {
      final List<PresetViolation> violations = _gate(
        _fixturePack(
          clauses: <Map<String, Object?>>[
            _clause('synthetic door a', role: 'decline_door'),
            _clause('synthetic door b', role: 'decline_door'),
          ],
        ),
      );

      expect(_rulesFrom(violations), contains(PresetGateRule.declineDoorMissing));
    });

    test('two decline doors stay a violation in a non-invite category', () {
      final List<PresetViolation> violations = _gate(
        _fixturePack(
          clauses: <Map<String, Object?>>[
            _clause('synthetic door a', role: 'decline_door'),
            _clause('synthetic door b', role: 'decline_door'),
          ],
        ),
        categoryId: 'thank_you_after_date',
      );

      expect(_rulesFrom(violations), contains(PresetGateRule.declineDoorMissing));
    });

    test('a decline door gated by a variable is a violation', () {
      final List<PresetViolation> violations = _gate(
        _fixturePack(
          clauses: <Map<String, Object?>>[
            _clause(
              'synthetic door {date}',
              requires: <String>['date'],
              role: 'decline_door',
            ),
          ],
        ),
      );

      expect(
        _rulesFrom(violations),
        contains(PresetGateRule.declineDoorConditional),
      );
    });

    test('a missing editorial_review is a violation (AC-23/BR-10)', () {
      final List<PresetViolation> violations = _gate(
        _fixturePack(editorialReview: null),
      );

      expect(
        _rulesFrom(violations),
        contains(PresetGateRule.editorialReviewIncomplete),
      );
    });

    test('a one-layer editorial_review is a violation', () {
      final List<PresetViolation> violations = _gate(
        _fixturePack(
          editorialReview: const <String, Object?>{'layer1': 'reviewer.a'},
        ),
      );

      expect(
        _rulesFrom(violations),
        contains(PresetGateRule.editorialReviewIncomplete),
      );
    });
  });

  group('lexical denylist rules', () {
    void expectRule(String text, PresetGateRule rule) {
      final List<PresetViolation> violations = _gate(
        _fixturePack(
          clauses: <Map<String, Object?>>[
            _clause(text),
            _clause('synthetic door', role: 'decline_door'),
          ],
        ),
      );

      expect(_rulesFrom(violations), contains(rule), reason: text);
    }

    test('flattery aimed at the reader', () {
      expectRule('Cậu xinh nên tớ mới rủ.', PresetGateRule.flattery);
    });

    test('a percentage figure', () {
      expectRule('Khả năng vui là 90%.', PresetGateRule.percentDisplay);
    });

    test('a streak or day chain', () {
      expectRule('Đây là buổi thứ ba liên tiếp.', PresetGateRule.streakDisplay);
    });

    test('a score or ratio', () {
      expectRule('Điểm số buổi trước khá cao.', PresetGateRule.scoreOrRatio);
    });

    test('a recipient-behaviour indicator', () {
      expectRule('Tớ thấy cậu đã xem tin rồi.',
          PresetGateRule.recipientBehaviour);
    });

    test('a manipulative tone', () {
      expectRule('Đây là chiêu quen thuộc của tớ.',
          PresetGateRule.manipulativeTone);
    });

    test('the frame label is scanned too, not only the clauses', () {
      final List<PresetViolation> violations = _gate(
        _fixturePack(frame: 'Thả thính'),
      );

      expect(
        _rulesFrom(violations),
        contains(PresetGateRule.manipulativeTone),
      );
    });

    test('terms match whole words, so "địa điểm" is not a score', () {
      final List<PresetViolation> violations = _gate(
        _fixturePack(
          clauses: <Map<String, Object?>>[
            _clause('Địa điểm đã chốt.'),
            _clause('synthetic door', role: 'decline_door'),
          ],
        ),
      );

      expect(violations, isEmpty);
    });
  });

  group('rules the parser enforces before the gate sees a package', () {
    test('a clause aimed at the recipient never becomes a package (R-1d)', () {
      expect(
        () => _parse(
          _fixturePack(
            clauses: <Map<String, Object?>>[
              _clause('synthetic body', targets: 'recipient'),
              _clause('synthetic door', role: 'decline_door'),
            ],
          ),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException error) => error.message,
            'message',
            contains('unsupported targets "recipient"'),
          ),
        ),
      );
    });

    test('a pack under another schema id is rejected at load (AC-29)', () {
      expect(
        () => _parse(_fixturePack(schemaId: 'req016.presets.thanks.v1')),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException error) => error.message,
            'message',
            contains('does not match the expected "req016.presets.v1"'),
          ),
        ),
      );
    });
  });
}
