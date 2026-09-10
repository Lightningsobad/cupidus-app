import 'dart:convert';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const String _schemaId = 'test.notes.v1';

class _Note implements ContentItem {
  const _Note({required this.id, required this.body, this.hint});

  @override
  final String id;
  final String body;
  final String? hint;
}

_Note _noteFromJson(Map<String, Object?> json, String source) => _Note(
  id: requireContentString(json, 'id', source),
  body: requireContentString(json, 'body', source),
  hint: optionalContentString(json, 'hint', source),
);

class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this._sources);

  final Map<String, String> _sources;

  @override
  Future<ByteData> load(String key) async {
    final source = _sources[key];
    if (source == null) {
      throw FlutterError('asset not registered in this test bundle: $key');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(source)));
  }
}

String _packageJson(List<Map<String, Object?>> items, {String? schemaId}) =>
    jsonEncode(<String, Object?>{
      'id': 'notes',
      'version': '1.0.0',
      'schema_id': schemaId ?? _schemaId,
      'items': items,
    });

List<Map<String, Object?>> _notes(int count) => List<Map<String, Object?>>.generate(
  count,
  (index) => <String, Object?>{
    'id': 'note_${(index * 7 + 3) % 101}',
    'body': 'body $index',
  },
  growable: false,
);

ContentPackage<_Note> _parse(String jsonSource) => ContentPackage.parse<_Note>(
  jsonSource,
  expectedSchemaId: _schemaId,
  itemParser: _noteFromJson,
);

void main() {
  group('gói hợp lệ', () {
    test('parse exposes id, version, schemaId and the parsed items', () {
      final package = _parse(
        _packageJson(<Map<String, Object?>>[
          <String, Object?>{'id': 'note_a', 'body': 'alpha', 'hint': 'h'},
          <String, Object?>{'id': 'note_b', 'body': 'beta'},
        ]),
      );

      expect(package.id, 'notes');
      expect(package.version, '1.0.0');
      expect(package.schemaId, _schemaId);
      expect(package.length, 2);
      expect(package.itemById('note_a')!.body, 'alpha');
      expect(package.itemById('note_a')!.hint, 'h');
      expect(package.itemById('note_b')!.hint, isNull);
      expect(package.itemById('note_missing'), isNull);
    });

    test('an empty items list parses instead of being assumed non-empty '
        '(R-15b)', () {
      final package = _parse(_packageJson(const <Map<String, Object?>>[]));

      expect(package.length, 0);
      expect(package.items, isEmpty);
    });
  });

  group('N là thuộc tính dữ liệu (R-15b)', () {
    for (final n in const <int>[1, 50]) {
      test('a package of $n items parses and reports N from the data', () {
        final package = _parse(_packageJson(_notes(n)));

        expect(package.length, n);
        expect(package.items.length, n);
        expect(package.itemById(package.items.last.id), isNotNull);
      });
    }
  });

  group('id mục là chuỗi bền, không phải chỉ số mảng (R-15a)', () {
    test('an item keeps its id when the package is reordered, and the id is '
        'not the array index', () {
      final ordered = <Map<String, Object?>>[
        <String, Object?>{'id': 'note_zulu', 'body': 'z'},
        <String, Object?>{'id': 'note_alpha', 'body': 'a'},
      ];
      final reordered = ordered.reversed.toList(growable: false);

      final first = _parse(_packageJson(ordered));
      final second = _parse(_packageJson(reordered));

      expect(first.items.first.id, 'note_zulu');
      expect(second.items.first.id, 'note_alpha');
      expect(first.itemById('note_alpha')!.body, 'a');
      expect(second.itemById('note_alpha')!.body, 'a');
      for (final item in first.items) {
        expect(int.tryParse(item.id), isNull);
      }
    });

    test('a duplicate item id is rejected rather than silently shadowed', () {
      expect(
        () => _parse(
          _packageJson(<Map<String, Object?>>[
            <String, Object?>{'id': 'note_a', 'body': 'first'},
            <String, Object?>{'id': 'note_a', 'body': 'second'},
          ]),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (error) => error.message,
            'message',
            contains('duplicate item id "note_a"'),
          ),
        ),
      );
    });
  });

  group('lỗi schema là lỗi rõ ràng lúc load, không nuốt', () {
    test('malformed JSON throws instead of yielding an empty package', () {
      expect(
        () => _parse('{not json'),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (error) => error.message,
            'message',
            startsWith('invalid JSON'),
          ),
        ),
      );
    });

    test('a non-object root is rejected', () {
      expect(() => _parse('[]'), throwsA(isA<ContentPackageFormatException>()));
    });

    test('a mismatched schema_id is rejected', () {
      expect(
        () => _parse(_packageJson(_notes(1), schemaId: 'test.notes.v2')),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (error) => error.message,
            'message',
            contains('does not match the expected "$_schemaId"'),
          ),
        ),
      );
    });

    test('a missing package version is rejected', () {
      final source = jsonEncode(<String, Object?>{
        'id': 'notes',
        'schema_id': _schemaId,
        'items': _notes(1),
      });

      expect(
        () => _parse(source),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (error) => error.message,
            'message',
            contains('field "version" must be a non-empty string'),
          ),
        ),
      );
    });

    test('items that is not a list is rejected', () {
      final source = jsonEncode(<String, Object?>{
        'id': 'notes',
        'version': '1.0.0',
        'schema_id': _schemaId,
        'items': <String, Object?>{'note_a': 'alpha'},
      });

      expect(
        () => _parse(source),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (error) => error.message,
            'message',
            contains('field "items" must be a list'),
          ),
        ),
      );
    });

    test('an item without a stable id is rejected', () {
      expect(
        () => _parse(
          _packageJson(<Map<String, Object?>>[
            <String, Object?>{'body': 'no id here'},
          ]),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (error) => error.message,
            'message',
            contains('field "id" must be a non-empty string'),
          ),
        ),
      );
    });

    test('a present-but-wrong-typed optional field is rejected', () {
      expect(
        () => _parse(
          _packageJson(<Map<String, Object?>>[
            <String, Object?>{'id': 'note_a', 'body': 'alpha', 'hint': 7},
          ]),
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (error) => error.message,
            'message',
            contains('optional field "hint"'),
          ),
        ),
      );
    });
  });

  group('ContentPackageLoader', () {
    const assetKey = 'assets/data/test/notes.v1.json';

    test('loads and parses a package from the asset bundle', () async {
      final loader = ContentPackageLoader(
        bundle: _FakeAssetBundle(<String, String>{
          assetKey: _packageJson(_notes(3)),
        }),
      );

      final package = await loader.load<_Note>(
        assetKey,
        expectedSchemaId: _schemaId,
        itemParser: _noteFromJson,
      );

      expect(package.length, 3);
    });

    test('a schema failure names the asset key it came from', () async {
      final loader = ContentPackageLoader(
        bundle: _FakeAssetBundle(<String, String>{assetKey: '{not json'}),
      );

      await expectLater(
        loader.load<_Note>(
          assetKey,
          expectedSchemaId: _schemaId,
          itemParser: _noteFromJson,
        ),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (error) => error.source,
            'source',
            assetKey,
          ),
        ),
      );
    });
  });
}
