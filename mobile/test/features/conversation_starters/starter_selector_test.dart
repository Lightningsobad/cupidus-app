import 'dart:convert';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_notebook_models.dart';
import 'package:cupid_mobile/features/conversation_starters/domain/starter_content.dart';
import 'package:cupid_mobile/features/conversation_starters/domain/starter_selector.dart';
import 'package:flutter_test/flutter_test.dart';

const String _today = '2026-09-12';

/// [n] generic starters with ids that do not sort in insertion order, so a
/// test that accidentally asserts insertion order fails loudly.
ContentPackage<StarterItem> _genericPackage(int n) => _package(
      List<Map<String, Object?>>.generate(
        n,
        (int index) => <String, Object?>{
          'id': 'st_${(index * 7 + 3) % 1000}_$index',
          'kind': 'generic',
          'text': 'synthetic generic $index?',
        },
        growable: false,
      ),
    );

ContentPackage<StarterItem> _package(List<Map<String, Object?>> items) =>
    ContentPackage.parse<StarterItem>(
      jsonEncode(<String, Object?>{
        'id': 'starters',
        'version': '1.0.0',
        'schema_id': startersSchemaId,
        'items': items,
      }),
      expectedSchemaId: startersSchemaId,
      itemParser: starterItemFromJson,
    );

NotebookEntry _entry({
  required String id,
  required NotebookKind kind,
  required String value,
}) {
  final DateTime at = DateTime(2026, 9, 1);
  return NotebookEntry(
    id: id,
    ownerKey: 'user-1',
    kind: kind,
    value: value,
    source: ContextEntrySource.manual,
    createdAt: at,
    updatedAt: at,
  );
}

List<String> _ids(List<RenderedStarter> starters) =>
    starters.map((RenderedStarter starter) => starter.id).toList();

int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

void main() {
  group('tất định (AC-17)', () {
    test('hai lần gọi cùng đầu vào trả đúng cùng danh sách id', () {
      final ContentPackage<StarterItem> package = _genericPackage(20);

      final List<RenderedStarter> first = StarterSelector.select(
        package: package,
        notebook: const <NotebookEntry>[],
        today: _today,
        page: 2,
        perPage: 3,
      );
      final List<RenderedStarter> second = StarterSelector.select(
        package: package,
        notebook: const <NotebookEntry>[],
        today: _today,
        page: 2,
        perPage: 3,
      );

      expect(_ids(first), _ids(second));
      expect(
        first.map((RenderedStarter starter) => starter.text),
        second.map((RenderedStarter starter) => starter.text),
      );
    });

    test('đổi ngày thì đổi thứ tự, nhưng vẫn phủ đúng cùng tập id', () {
      final ContentPackage<StarterItem> package = _genericPackage(12);

      List<String> walk(String today) => <String>[
            for (int page = 0; page < 4; page++)
              ..._ids(
                StarterSelector.select(
                  package: package,
                  notebook: const <NotebookEntry>[],
                  today: today,
                  page: page,
                  perPage: 3,
                ),
              ),
          ];

      final List<String> onDayOne = walk('2026-09-12');
      final List<String> onDayTwo = walk('2026-09-13');

      expect(onDayOne.toSet(), onDayTwo.toSet());
      expect(onDayOne.toSet().length, 12);
    });
  });

  group('hết vòng thì quay lại đầu kho với mọi N (AC-27, AC-28, R-15b)', () {
    const int perPage = 3;

    for (final int n in const <int>[1, 2, 3, 4, 10, 137]) {
      test('N=$n: duyệt hết kho rồi lặp lại đúng bộ đầu tiên', () {
        final ContentPackage<StarterItem> package = _genericPackage(n);

        List<String> pageIds(int page) => _ids(
              StarterSelector.select(
                package: package,
                notebook: const <NotebookEntry>[],
                today: _today,
                page: page,
                perPage: perPage,
              ),
            );

        // Start offsets are multiples of perPage modulo N, so the walk repeats
        // after exactly this many pages — derived from N, never a constant.
        final int period = n ~/ _gcd(perPage, n);
        final Set<String> seen = <String>{};
        for (int page = 0; page < period; page++) {
          seen.addAll(pageIds(page));
        }

        expect(seen.length, n, reason: 'kho chưa được duyệt hết ở N=$n');
        expect(pageIds(period), pageIds(0));
        expect(pageIds(period + 1), pageIds(1));
      });

      test('N=$n: mỗi trang không rỗng và không có ô giữ chỗ', () {
        final ContentPackage<StarterItem> package = _genericPackage(n);

        for (int page = 0; page < 5; page++) {
          final List<RenderedStarter> starters = StarterSelector.select(
            package: package,
            notebook: const <NotebookEntry>[],
            today: _today,
            page: page,
            perPage: perPage,
          );

          expect(starters.length, n < perPage ? n : perPage);
          expect(_ids(starters).toSet().length, starters.length);
          for (final RenderedStarter starter in starters) {
            expect(starter.text, isNotEmpty);
          }
        }
      });
    }

    test('kho rỗng trả danh sách rỗng thay vì ném lỗi', () {
      expect(
        StarterSelector.select(
          package: _genericPackage(0),
          notebook: const <NotebookEntry>[],
          today: _today,
          page: 0,
          perPage: perPage,
        ),
        isEmpty,
      );
    });

    test('perPage không đặt ràng buộc nào lên N: perPage lớn hơn kho vẫn trả '
        'đúng N mục', () {
      final List<RenderedStarter> starters = StarterSelector.select(
        package: _genericPackage(2),
        notebook: const <NotebookEntry>[],
        today: _today,
        page: 0,
        perPage: 50,
      );

      expect(starters, hasLength(2));
    });
  });

  group('riêng-hoá bằng sổ tay (AC-5, AC-6, BR-5)', () {
    ContentPackage<StarterItem> mixedPackage() => _package(
          const <Map<String, Object?>>[
            <String, Object?>{
              'id': 'st_generic_a',
              'kind': 'generic',
              'text': 'generic a?',
            },
            <String, Object?>{
              'id': 'st_generic_b',
              'kind': 'generic',
              'text': 'generic b?',
            },
            <String, Object?>{
              'id': 'st_interest',
              'kind': 'contextual',
              'context_slot': 'interest',
              'text': 'contextual about {value}?',
            },
            <String, Object?>{
              'id': 'st_event',
              'kind': 'contextual',
              'context_slot': 'event',
              'text': 'contextual about {value} again?',
            },
          ],
        );

    test('mục contextual đủ tư cách xếp trước mục generic', () {
      final List<RenderedStarter> starters = StarterSelector.select(
        package: mixedPackage(),
        notebook: <NotebookEntry>[
          _entry(
            id: 'nb_1',
            kind: NotebookKind.interest,
            value: 'cầu lông',
          ),
          _entry(id: 'nb_2', kind: NotebookKind.event, value: 'sinh nhật mẹ'),
        ],
        today: _today,
        page: 0,
        perPage: 4,
      );

      expect(starters, hasLength(4));
      expect(
        starters.take(2).map((RenderedStarter s) => s.kind),
        everyElement(StarterKind.contextual),
      );
      expect(
        starters.skip(2).map((RenderedStarter s) => s.kind),
        everyElement(StarterKind.generic),
      );
    });

    test('câu contextual tham chiếu đúng giá trị đã ghi trong sổ tay', () {
      final List<RenderedStarter> starters = StarterSelector.select(
        package: mixedPackage(),
        notebook: <NotebookEntry>[
          _entry(id: 'nb_1', kind: NotebookKind.interest, value: 'cầu lông'),
        ],
        today: _today,
        page: 0,
        perPage: 4,
      );

      final RenderedStarter contextual = starters.firstWhere(
        (RenderedStarter starter) => starter.id == 'st_interest',
      );
      expect(contextual.text, contains('cầu lông'));
    });

    test('sổ tay rỗng vẫn ra câu dùng được từ mục generic', () {
      final List<RenderedStarter> starters = StarterSelector.select(
        package: mixedPackage(),
        notebook: const <NotebookEntry>[],
        today: _today,
        page: 0,
        perPage: 4,
      );

      expect(starters, hasLength(2));
      expect(
        starters.map((RenderedStarter s) => s.kind),
        everyElement(StarterKind.generic),
      );
    });

    test('mục contextual thiếu giá trị cho đúng slot của nó bị loại hẳn', () {
      final List<RenderedStarter> starters = StarterSelector.select(
        package: mixedPackage(),
        notebook: <NotebookEntry>[
          _entry(id: 'nb_1', kind: NotebookKind.interest, value: 'cầu lông'),
        ],
        today: _today,
        page: 0,
        perPage: 4,
      );

      expect(_ids(starters), isNot(contains('st_event')));
    });

    test('không câu nào trả ra còn sót token {value}', () {
      for (final List<NotebookEntry> notebook in <List<NotebookEntry>>[
        const <NotebookEntry>[],
        <NotebookEntry>[
          _entry(id: 'nb_1', kind: NotebookKind.interest, value: 'cầu lông'),
        ],
        <NotebookEntry>[
          _entry(id: 'nb_1', kind: NotebookKind.interest, value: 'cầu lông'),
          _entry(id: 'nb_2', kind: NotebookKind.event, value: 'sinh nhật mẹ'),
        ],
      ]) {
        for (int page = 0; page < 4; page++) {
          final List<RenderedStarter> starters = StarterSelector.select(
            package: mixedPackage(),
            notebook: notebook,
            today: _today,
            page: page,
            perPage: 3,
          );
          for (final RenderedStarter starter in starters) {
            expect(
              starter.text,
              isNot(contains(starterValueToken)),
              reason: '${starter.id} còn token chưa thay',
            );
          }
        }
      }
    });

    test('nhiều mục sổ tay cùng slot vẫn chọn tất định', () {
      final List<NotebookEntry> notebook = <NotebookEntry>[
        _entry(id: 'nb_1', kind: NotebookKind.interest, value: 'cầu lông'),
        _entry(id: 'nb_2', kind: NotebookKind.interest, value: 'cà phê'),
        _entry(id: 'nb_3', kind: NotebookKind.interest, value: 'leo núi'),
      ];

      String render() => StarterSelector.select(
            package: mixedPackage(),
            notebook: notebook,
            today: _today,
            page: 0,
            perPage: 4,
          )
              .firstWhere((RenderedStarter s) => s.id == 'st_interest')
              .text;

      expect(render(), render());
    });
  });

  group('không có trạng thái "đã hết" trong API', () {
    test('perPage <= 0 trả rỗng thay vì ném lỗi', () {
      expect(
        StarterSelector.select(
          package: _genericPackage(10),
          notebook: const <NotebookEntry>[],
          today: _today,
          page: 0,
          perPage: 0,
        ),
        isEmpty,
      );
    });

    test('page rất lớn vẫn trả đủ một bộ, không màn ngõ cụt', () {
      final List<RenderedStarter> starters = StarterSelector.select(
        package: _genericPackage(10),
        notebook: const <NotebookEntry>[],
        today: _today,
        page: 100000,
        perPage: 3,
      );

      expect(starters, hasLength(3));
    });
  });

  group('khoá thứ tự bền giữa hai lần chạy (AC-17)', () {
    test('stableContentKey không phụ thuộc String.hashCode', () {
      expect(stableContentKey('2026-09-12|st_1'), 2771981538);
      expect(stableContentKey(''), 0x811c9dc5);
    });
  });
}
