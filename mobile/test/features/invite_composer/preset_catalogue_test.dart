import 'dart:convert';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/invite_composer/domain/invite_preset.dart';
import 'package:cupid_mobile/features/invite_composer/domain/preset_catalogue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deliberately not a [CachingAssetBundle]: that base class memoises
/// `loadString` itself, which would make the catalogue look like it caches even
/// if it re-parsed on every call.
class _CountingAssetBundle extends AssetBundle {
  _CountingAssetBundle(this._sources);

  final Map<String, String> _sources;
  final List<String> requestedKeys = <String>[];

  @override
  Future<ByteData> load(String key) async {
    requestedKeys.add(key);
    final String? source = _sources[key];
    if (source == null) {
      throw FlutterError('asset not registered in this test bundle: $key');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(source)));
  }

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String value) parser,
  ) async =>
      parser(await loadString(key));
}

String _packJson({
  String schemaId = presetsSchemaId,
  String packId = 'presets.invite',
  int presetCount = 3,
}) =>
    jsonEncode(<String, Object?>{
      'id': packId,
      'version': '1.0.0',
      'schema_id': schemaId,
      'locale': 'vi',
      'items': List<Map<String, Object?>>.generate(
        presetCount,
        (int index) => <String, Object?>{
          'id': 'synthetic.$index.v1',
          'frame': 'synthetic frame $index',
          'clauses': <Map<String, Object?>>[
            <String, Object?>{
              'text': 'synthetic body {activity}',
              'requires': <String>['activity'],
              'targets': 'neutral',
            },
            <String, Object?>{
              'text': 'synthetic door',
              'requires': <String>[],
              'targets': 'neutral',
              'role': 'decline_door',
            },
          ],
          'editorial_review': <String, Object?>{
            'layer1': 'reviewer.a',
            'layer2': 'reviewer.b',
            'approved_at': '2026-09-10',
          },
        },
        growable: false,
      ),
    });

void main() {
  group('category id resolves to an asset key by convention (AC-21/AC-29)', () {
    test('the shipped invite category maps to its own file', () {
      expect(
        presetAssetKey(inviteCategoryId),
        'assets/data/req016/presets.invite.v1.json',
      );
    });

    test('a category this story never ships still resolves, with no code '
        'change', () {
      expect(
        presetAssetKey('thanks'),
        'assets/data/req016/presets.thanks.v1.json',
      );
      expect(
        presetAssetKey('anything_at_all'),
        'assets/data/req016/presets.anything_at_all.v1.json',
      );
    });

    test('every category shares one schema id', () {
      expect(presetsSchemaId, 'req016.presets.v1');
    });
  });

  group('PresetCatalogue', () {
    test('loads the package behind the conventional key for the category',
        () async {
      final bundle = _CountingAssetBundle(<String, String>{
        presetAssetKey(inviteCategoryId): _packJson(),
      });
      final catalogue = PresetCatalogue(
        loader: ContentPackageLoader(bundle: bundle),
      );

      final ContentPackage<InvitePreset> package =
          await catalogue.load(inviteCategoryId);

      expect(bundle.requestedKeys, <String>[
        'assets/data/req016/presets.invite.v1.json',
      ]);
      expect(package.schemaId, presetsSchemaId);
      expect(package.items, isNotEmpty);
      expect(package.items.first, isA<InvitePreset>());
    });

    test('parses a category once and serves later calls from cache', () async {
      final bundle = _CountingAssetBundle(<String, String>{
        presetAssetKey(inviteCategoryId): _packJson(),
      });
      final catalogue = PresetCatalogue(
        loader: ContentPackageLoader(bundle: bundle),
      );

      final ContentPackage<InvitePreset> first =
          await catalogue.load(inviteCategoryId);
      final ContentPackage<InvitePreset> second =
          await catalogue.load(inviteCategoryId);

      expect(bundle.requestedKeys, hasLength(1));
      expect(identical(first, second), isTrue);
    });

    test('caches per category, so a second category reads its own file',
        () async {
      final bundle = _CountingAssetBundle(<String, String>{
        presetAssetKey(inviteCategoryId): _packJson(),
        presetAssetKey('thanks'): _packJson(packId: 'presets.thanks'),
      });
      final catalogue = PresetCatalogue(
        loader: ContentPackageLoader(bundle: bundle),
      );

      await catalogue.load(inviteCategoryId);
      final ContentPackage<InvitePreset> thanks =
          await catalogue.load('thanks');

      expect(thanks.id, 'presets.thanks');
      expect(bundle.requestedKeys, <String>[
        'assets/data/req016/presets.invite.v1.json',
        'assets/data/req016/presets.thanks.v1.json',
      ]);
    });

    test('a pack under a different schema id is rejected at load', () async {
      final bundle = _CountingAssetBundle(<String, String>{
        presetAssetKey(inviteCategoryId):
            _packJson(schemaId: 'req016.presets.thanks.v1'),
      });
      final catalogue = PresetCatalogue(
        loader: ContentPackageLoader(bundle: bundle),
      );

      await expectLater(
        catalogue.load(inviteCategoryId),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException error) => error.message,
            'message',
            contains('does not match the expected "req016.presets.v1"'),
          ),
        ),
      );
    });

    test('package size is read from the data, at any N (R-15b)', () async {
      for (final int n in const <int>[1, 2, 40]) {
        final bundle = _CountingAssetBundle(<String, String>{
          presetAssetKey(inviteCategoryId): _packJson(presetCount: n),
        });
        final catalogue = PresetCatalogue(
          loader: ContentPackageLoader(bundle: bundle),
        );

        final ContentPackage<InvitePreset> package =
            await catalogue.load(inviteCategoryId);

        expect(package.length, n);
      }
    });
  });
}
