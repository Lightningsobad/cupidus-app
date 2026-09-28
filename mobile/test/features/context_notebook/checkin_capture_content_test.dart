import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/context_notebook/domain/checkin_capture_content.dart';
import 'package:flutter_test/flutter_test.dart';

ContentPackage<CheckinCaptureCopy> _parse(String source,
        {String label = '<fixture>'}) =>
    ContentPackage.parse<CheckinCaptureCopy>(
      source,
      expectedSchemaId: checkinCaptureSchemaId,
      itemParser: checkinCaptureCopyFromJson,
      source: label,
    );

/// Copy ids whose wording is generic app vocabulary this story did not invent —
/// "Tuỳ chọn", the two kind labels and the retry action already ship from
/// `lib/l10n/arb/` and a dozen unrelated screens. Scanning them would report
/// collisions REQ-017 never caused, so AC-14 covers the wording it does author:
/// the capture question, the kind-required hint, the save error and both origin
/// labels.
const Set<String> _genericAppVocabularyIds = <String>{
  checkinCaptureOptionalLabelId,
  checkinCaptureInterestKindId,
  checkinCaptureEventKindId,
  checkinCaptureRetryId,
};

String _pack(List<Map<String, Object?>> items) => jsonEncode(<String, Object?>{
      'id': 'req017.checkin_capture.fixture',
      'version': '1.0.0',
      'schema_id': checkinCaptureSchemaId,
      'locale': 'vi',
      'items': items,
    });

void main() {
  group('the shipped pack on disk (AC-14)', () {
    late ContentPackage<CheckinCaptureCopy> shipped;

    setUp(() {
      shipped = _parse(
        File(checkinCaptureAssetKey).readAsStringSync(),
        label: checkinCaptureAssetKey,
      );
    });

    test('exists and carries every copy id UX Part D names', () {
      expect(File(checkinCaptureAssetKey).existsSync(), isTrue);
      for (final String id in requiredCheckinCaptureCopyIds) {
        expect(shipped.itemById(id), isNotNull, reason: id);
      }
    });

    test('only the named-card origin label declares a parameter', () {
      for (final CheckinCaptureCopy copy in shipped.items) {
        if (copy.id == notebookOriginWithCardId) {
          expect(copy.params, <String>[checkinCaptureCardParam]);
        } else {
          expect(copy.params, isEmpty, reason: copy.id);
        }
      }
    });

    test('the wording this story authors is in no Dart or l10n file', () {
      final List<CheckinCaptureCopy> authored = shipped.items
          .where(
            (CheckinCaptureCopy copy) =>
                !_genericAppVocabularyIds.contains(copy.id),
          )
          .toList(growable: false);
      final List<String> offenders = <String>[];

      for (final FileSystemEntity entity
          in Directory('lib').listSync(recursive: true)) {
        if (entity is! File ||
            !(entity.path.endsWith('.dart') || entity.path.endsWith('.arb'))) {
          continue;
        }
        final String source = entity.readAsStringSync();
        for (final CheckinCaptureCopy copy in authored) {
          if (source.contains(copy.text)) {
            offenders.add('${entity.path} contains ${copy.id}');
          }
        }
      }

      expect(authored, isNotEmpty);
      expect(offenders, isEmpty);
    });
  });

  group('resolution never happens in the UI', () {
    late CheckinCaptureCopySet copy;

    setUp(() {
      copy = CheckinCaptureCopySet(
        _parse(
          File(checkinCaptureAssetKey).readAsStringSync(),
          label: checkinCaptureAssetKey,
        ),
      );
    });

    test('a readable card title resolves {card}', () {
      final String label = copy.originLabel(cardTitle: 'Cà phê chiều');
      expect(label, contains('Cà phê chiều'));
      expect(label, isNot(contains('{')));
    });

    test('a null card title degrades to the parameterless line (AC-9)', () {
      expect(
        copy.originLabel(),
        copy.text(notebookOriginFallbackId),
      );
    });

    test('a blank card title degrades the same way (BR-6)', () {
      expect(
        copy.originLabel(cardTitle: '   '),
        copy.text(notebookOriginFallbackId),
      );
    });

    test('the degraded line carries no placeholder', () {
      expect(copy.text(notebookOriginFallbackId), isNot(contains('{')));
    });

    test('an unknown copy id is an error, not an empty string', () {
      expect(
        () => copy.text('checkin.capture.nope.v1'),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });
  });

  group('the parser rejects a malformed pack instead of skipping it', () {
    test('a duplicate item id', () {
      expect(
        () => _parse(
          _pack(<Map<String, Object?>>[
            <String, Object?>{'id': checkinCaptureRetryId, 'text': 'Thử lại'},
            <String, Object?>{'id': checkinCaptureRetryId, 'text': 'Lần nữa'},
          ]),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('duplicate item id'),
          ),
        ),
      );
    });

    test('a missing id', () {
      expect(
        () => _parse(
          _pack(<Map<String, Object?>>[
            <String, Object?>{'text': 'Thử lại'},
          ]),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('field "id" must be a non-empty string'),
          ),
        ),
      );
    });

    test('a missing text', () {
      expect(
        () => _parse(
          _pack(<Map<String, Object?>>[
            <String, Object?>{'id': checkinCaptureRetryId},
          ]),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('field "text" must be a non-empty string'),
          ),
        ),
      );
    });

    test('a parameter the item does not support', () {
      expect(
        () => _parse(
          _pack(<Map<String, Object?>>[
            <String, Object?>{
              'id': checkinCaptureRetryId,
              'text': 'Thử lại {card}',
              'params': <String>['card'],
            },
          ]),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('declares unsupported parameter "card"'),
          ),
        ),
      );
    });

    test('a parameter name nothing supports', () {
      expect(
        () => _parse(
          _pack(<Map<String, Object?>>[
            <String, Object?>{
              'id': notebookOriginWithCardId,
              'text': 'từ buổi hẹn {score}',
              'params': <String>['score'],
            },
          ]),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('declares unsupported parameter "score"'),
          ),
        ),
      );
    });

    test('a placeholder in the text that was never declared', () {
      expect(
        () => _parse(
          _pack(<Map<String, Object?>>[
            <String, Object?>{
              'id': notebookOriginWithCardId,
              'text': 'từ buổi hẹn {card}',
            },
          ]),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('uses undeclared parameter "{card}"'),
          ),
        ),
      );
    });

    test('a declared parameter the text never uses', () {
      expect(
        () => _parse(
          _pack(<Map<String, Object?>>[
            <String, Object?>{
              'id': notebookOriginWithCardId,
              'text': 'từ buổi hẹn',
              'params': <String>['card'],
            },
          ]),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('never uses it'),
          ),
        ),
      );
    });

    test('a pack under another schema id', () {
      expect(
        () => ContentPackage.parse<CheckinCaptureCopy>(
          _pack(<Map<String, Object?>>[
            <String, Object?>{'id': checkinCaptureRetryId, 'text': 'Thử lại'},
          ]),
          expectedSchemaId: 'req017.checkin_capture.v2',
          itemParser: checkinCaptureCopyFromJson,
        ),
        throwsA(isA<ContentPackageFormatException>()),
      );
    });
  });
}
