import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/gift_ideas/domain/gift_content.dart';
import 'package:cupid_mobile/features/gift_ideas/domain/gift_selector.dart';
import 'package:flutter_test/flutter_test.dart';

const String _branchByOccasion = 'by_occasion';
const String _branchNoCost = 'no_cost';
const String _branchHandmade = 'handmade';

const String _tier30 = 'effort.30_phut.v1';
const String _tier120 = 'effort.1_2_gio.v1';
const String _tier240 = 'effort.mot_buoi.v1';

const List<GiftTaxonomyItem> _taxonomyItems = <GiftTaxonomyItem>[
  GiftTaxonomyItem(
    id: _branchByOccasion,
    kind: GiftTaxonomyKind.branch,
    label: 'Theo dịp',
  ),
  GiftTaxonomyItem(
    id: _branchNoCost,
    kind: GiftTaxonomyKind.branch,
    label: 'Không tốn tiền',
  ),
  GiftTaxonomyItem(
    id: _branchHandmade,
    kind: GiftTaxonomyKind.branch,
    label: 'Tự tay làm',
  ),
  GiftTaxonomyItem(
    id: _tier30,
    kind: GiftTaxonomyKind.effortTier,
    label: 'Trong 30 phút',
    maxMinutes: 30,
  ),
  GiftTaxonomyItem(
    id: _tier120,
    kind: GiftTaxonomyKind.effortTier,
    label: 'Một tới hai giờ',
    maxMinutes: 120,
  ),
  GiftTaxonomyItem(
    id: _tier240,
    kind: GiftTaxonomyKind.effortTier,
    label: 'Trọn một buổi',
    maxMinutes: 240,
  ),
];

/// Six ideas whose ids sort in a known order, so a tie broken on id is visible
/// in the assertion instead of being inferred.
const List<GiftIdea> _ideas = <GiftIdea>[
  GiftIdea(
    id: 'gift.a.v1',
    title: 'Thư tay kể lại một buổi',
    description: 'Viết tay một trang rồi gấp vào phong bì bạn tự gấp.',
    branchId: _branchHandmade,
    effortTierId: _tier30,
    isHandmade: true,
  ),
  GiftIdea(
    id: 'gift.b.v1',
    title: 'Cuốn album ảnh tự dán',
    description: 'Dán ảnh vào sổ rồi viết chú thích dưới từng tấm.',
    branchId: _branchHandmade,
    effortTierId: _tier120,
    isHandmade: true,
  ),
  GiftIdea(
    id: 'gift.c.v1',
    title: 'Danh sách nhạc cho một buổi',
    description: 'Sắp thứ tự các bài rồi gửi kèm một dòng lý do.',
    branchId: _branchNoCost,
    effortTierId: _tier30,
    isHandmade: false,
  ),
  GiftIdea(
    id: 'gift.d.v1',
    title: 'Làm giúp một việc người ấy đang ngại',
    description: 'Nhận làm trọn một việc, xong rồi mới nói cho họ biết.',
    branchId: _branchNoCost,
    effortTierId: _tier240,
    isHandmade: false,
  ),
  GiftIdea(
    id: 'gift.e.v1',
    title: 'Bó hoa gắn với dịp',
    description: 'Chọn loại hoa hợp dịp, kèm mẩu thiệp viết tay.',
    branchId: _branchByOccasion,
    effortTierId: _tier120,
    isHandmade: false,
  ),
  GiftIdea(
    id: 'gift.f.v1',
    title: 'Một buổi hẹn dựng quanh dịp đang tới',
    description: 'Chốt giờ và chỗ gặp trước một hôm.',
    branchId: _branchByOccasion,
    effortTierId: _tier240,
    isHandmade: false,
  ),
];

const List<GiftIndexRow> _indexRows = <GiftIndexRow>[
  GiftIndexRow(
    id: 'gift_index.interest.nau_an.v1',
    contextKind: GiftContextKind.interest,
    value: 'nấu ăn',
    giftIds: <String>['gift.b.v1', 'gift.c.v1'],
  ),
  GiftIndexRow(
    id: 'gift_index.event.sinh_nhat.v1',
    contextKind: GiftContextKind.event,
    value: 'sinh nhật',
    giftIds: <String>['gift.e.v1', 'gift.f.v1'],
  ),
  GiftIndexRow(
    id: 'gift_index.skill.goi_qua_dep.v1',
    contextKind: GiftContextKind.skill,
    value: 'skill.goi_qua_dep.v1',
    giftIds: <String>['gift.b.v1'],
  ),
];

/// Deliberately mixed case and padded, so a passing match proves the selector
/// normalises rather than that the fixture was pre-cleaned.
const GiftContextSnapshot _fullContext = GiftContextSnapshot(
  values: <GiftContextValue>[
    GiftContextValue(
      kind: GiftContextKind.interest,
      key: '  Nấu Ăn ',
      label: 'Nấu ăn',
    ),
    GiftContextValue(
      kind: GiftContextKind.event,
      key: 'Sinh nhật',
      label: 'Sinh nhật',
    ),
    GiftContextValue(
      kind: GiftContextKind.skill,
      key: 'skill.goi_qua_dep.v1',
      label: 'gói quà đẹp',
    ),
  ],
);

/// The order the shipped rules produce for [_fullContext]. Written out rather
/// than computed: a golden literal is the only assertion that can fail when a
/// *later process* ranks the same input differently (AC-28).
const List<String> _goldenOrder = <String>[
  'gift.b.v1',
  'gift.c.v1',
  'gift.e.v1',
  'gift.f.v1',
  'gift.a.v1',
  'gift.d.v1',
];

ContentPackage<T> _pack<T extends ContentItem>(
  String id,
  String schemaId,
  List<T> items,
) =>
    ContentPackage<T>(
      id: id,
      version: '1.0.0',
      schemaId: schemaId,
      items: items,
    );

GiftCatalogue _catalogue({
  List<GiftIdea>? ideas,
  List<GiftIndexRow>? indexRows,
  List<GiftTaxonomyItem>? taxonomy,
}) =>
    GiftCatalogue(
      gifts: _pack<GiftIdea>('gifts.fixture', giftsSchemaId, ideas ?? _ideas),
      giftIndex: _pack<GiftIndexRow>(
        'gift_index.fixture',
        giftIndexSchemaId,
        indexRows ?? _indexRows,
      ),
      taxonomy: _pack<GiftTaxonomyItem>(
        'gift_taxonomy.fixture',
        giftTaxonomySchemaId,
        taxonomy ?? _taxonomyItems,
      ),
    );

List<String> _idsOf(List<GiftSuggestion> suggestions) =>
    suggestions.map((GiftSuggestion s) => s.idea.id).toList(growable: false);

/// [count] ideas spread across every branch and every tier, so a large pack
/// exercises the same filters a small one does.
List<GiftIdea> _generatedIdeas(int count) {
  const List<String> branches = <String>[
    _branchByOccasion,
    _branchNoCost,
    _branchHandmade,
  ];
  const List<String> tiers = <String>[_tier30, _tier120, _tier240];

  return <GiftIdea>[
    for (int i = 0; i < count; i++)
      GiftIdea(
        id: 'gift.${i.toString().padLeft(4, '0')}.v1',
        title: 'Ý tưởng số $i',
        description: 'Một việc bạn tự làm cho người ấy, số $i.',
        branchId: branches[i % branches.length],
        effortTierId: tiers[i % tiers.length],
        isHandmade: branches[i % branches.length] == _branchHandmade,
      ),
  ];
}

void main() {
  const GiftSelector selector = GiftSelector();

  group('xếp hạng tất định (AC-28)', () {
    test('recorded context produces the golden order, id breaking every tie',
        () {
      final List<GiftSuggestion> ranked = selector.suggest(
        catalogue: _catalogue(),
        context: _fullContext,
      );

      expect(_idsOf(ranked), _goldenOrder);
      // gift.c/gift.e/gift.f each match exactly one recorded thing; they come
      // out in id order, so the sort never leans on whichever the pack
      // happened to list first.
      expect(
        ranked.map((GiftSuggestion s) => s.score),
        <int>[2, 1, 1, 1, 0, 0],
      );
    });

    test('two runs in one process agree, and agree with the golden order', () {
      final List<String> first =
          _idsOf(selector.suggest(catalogue: _catalogue(), context: _fullContext));
      final List<String> second =
          _idsOf(selector.suggest(catalogue: _catalogue(), context: _fullContext));

      expect(first, second);
      expect(first, _goldenOrder);
    });

    test('reversing pack order and context order leaves the ranking alone', () {
      final List<String> ranked = _idsOf(
        selector.suggest(
          catalogue: _catalogue(
            ideas: _ideas.reversed.toList(growable: false),
            indexRows: _indexRows.reversed.toList(growable: false),
            taxonomy: _taxonomyItems.reversed.toList(growable: false),
          ),
          context: GiftContextSnapshot(
            values: _fullContext.values.reversed.toList(growable: false),
          ),
        ),
      );

      expect(ranked, _goldenOrder);
    });
  });

  group('ngữ cảnh rỗng vẫn dùng được (AC-15)', () {
    test('an empty notebook still yields every idea, in id order', () {
      final List<GiftSuggestion> ranked = selector.suggest(
        catalogue: _catalogue(),
        context: GiftContextSnapshot.empty,
      );

      expect(ranked, isNotEmpty);
      expect(_idsOf(ranked), <String>[
        'gift.a.v1',
        'gift.b.v1',
        'gift.c.v1',
        'gift.d.v1',
        'gift.e.v1',
        'gift.f.v1',
      ]);
      expect(ranked.every((GiftSuggestion s) => s.score == 0), isTrue);
      expect(ranked.every((GiftSuggestion s) => s.matches.isEmpty), isTrue);
    });
  });

  group('nhánh tự làm và hồ sơ kỹ năng (AC-13, AC-20)', () {
    test('an empty skill profile still returns every handmade idea', () {
      final List<GiftSuggestion> ranked = selector.suggest(
        catalogue: _catalogue(),
        context: GiftContextSnapshot.empty,
        filter: const GiftFilter(branchId: _branchHandmade),
      );

      expect(_idsOf(ranked), <String>['gift.a.v1', 'gift.b.v1']);
      expect(ranked.every((GiftSuggestion s) => s.idea.isHandmade), isTrue);
    });

    test('a listed skill lifts the ideas tied to it and names itself', () {
      final List<GiftSuggestion> ranked = selector.suggest(
        catalogue: _catalogue(),
        context: const GiftContextSnapshot(
          values: <GiftContextValue>[
            GiftContextValue(
              kind: GiftContextKind.skill,
              key: 'skill.goi_qua_dep.v1',
              label: 'gói quà đẹp',
            ),
          ],
        ),
        filter: const GiftFilter(branchId: _branchHandmade),
      );

      expect(_idsOf(ranked), <String>['gift.b.v1', 'gift.a.v1']);
      expect(ranked.first.matches.single.context.label, 'gói quà đẹp');
      expect(ranked.last.matches, isEmpty);
    });

    test('a skill the packs do not key on changes nothing and breaks nothing',
        () {
      final List<GiftSuggestion> ranked = selector.suggest(
        catalogue: _catalogue(),
        context: const GiftContextSnapshot(
          values: <GiftContextValue>[
            GiftContextValue(
              kind: GiftContextKind.skill,
              key: 'skill.khong_co_trong_goi.v1',
              label: 'biết sửa xe',
            ),
          ],
        ),
        filter: const GiftFilter(branchId: _branchHandmade),
      );

      expect(_idsOf(ranked), <String>['gift.a.v1', 'gift.b.v1']);
    });
  });

  group('bộ lọc nhánh và mức công sức (AC-17, AC-18)', () {
    test('a two-hour ceiling keeps only ideas inside that bound', () {
      final List<GiftSuggestion> ranked = selector.suggest(
        catalogue: _catalogue(),
        context: _fullContext,
        filter: const GiftFilter(effortTierId: _tier120),
      );

      expect(_idsOf(ranked)..sort(), <String>[
        'gift.a.v1',
        'gift.b.v1',
        'gift.c.v1',
        'gift.e.v1',
      ]);
      expect(
        ranked.every((GiftSuggestion s) => (s.effortMinutes ?? 0) <= 120),
        isTrue,
      );
    });

    test('the no-cost branch is its own filter and comes back non-empty', () {
      final List<GiftSuggestion> ranked = selector.suggest(
        catalogue: _catalogue(),
        context: _fullContext,
        filter: const GiftFilter(branchId: _branchNoCost),
      );

      expect(ranked, isNotEmpty);
      expect(
        ranked.every((GiftSuggestion s) => s.idea.branchId == _branchNoCost),
        isTrue,
      );
    });

    test('branch and ceiling combine', () {
      final List<GiftSuggestion> ranked = selector.suggest(
        catalogue: _catalogue(),
        context: _fullContext,
        filter: const GiftFilter(
          branchId: _branchNoCost,
          effortTierId: _tier30,
        ),
      );

      expect(_idsOf(ranked), <String>['gift.c.v1']);
    });

    test('a branch with nothing in it is a quiet empty result, not an error',
        () {
      final List<GiftSuggestion> ranked = selector.suggest(
        catalogue: _catalogue(),
        context: _fullContext,
        filter: const GiftFilter(branchId: 'branch.khong_ai_tro_toi.v1'),
      );

      expect(ranked, isEmpty);
      expect(selector.nextBatch(ranked, cursor: 7, size: 3), isEmpty);
    });
  });

  group('quay vòng khi hết tập (AC-33)', () {
    test('the cursor wraps past the end instead of running out', () {
      final List<GiftSuggestion> ranked = selector.suggest(
        catalogue: _catalogue(),
        context: _fullContext,
      );

      expect(
        _idsOf(selector.nextBatch(ranked, cursor: 4, size: 4)),
        <String>['gift.a.v1', 'gift.d.v1', 'gift.b.v1', 'gift.c.v1'],
      );
      expect(
        _idsOf(selector.nextBatch(ranked, cursor: 100, size: 2)),
        _idsOf(selector.nextBatch(ranked, cursor: 4, size: 2)),
      );
    });

    test('a batch never repeats an idea, even when asked for more than exist',
        () {
      final List<GiftSuggestion> ranked = selector.suggest(
        catalogue: _catalogue(),
        context: _fullContext,
      );
      final List<String> batch =
          _idsOf(selector.nextBatch(ranked, cursor: 3, size: 50));

      expect(batch, hasLength(ranked.length));
      expect(batch.toSet(), hasLength(ranked.length));
    });

    test('twenty consecutive batches all come back non-empty', () {
      final List<GiftSuggestion> ranked = selector.suggest(
        catalogue: _catalogue(),
        context: _fullContext,
      );

      for (int cursor = 0; cursor < 20; cursor++) {
        expect(
          selector.nextBatch(ranked, cursor: cursor, size: 3),
          hasLength(3),
          reason: 'cursor $cursor must still hand back a full batch',
        );
      }
    });
  });

  group('kích cỡ gói là dữ liệu (AC-33, R-15b)', () {
    for (final int packSize in <int>[1, 200]) {
      group('N=$packSize', () {
        final GiftCatalogue catalogue = _catalogue(
          ideas: _generatedIdeas(packSize),
          indexRows: const <GiftIndexRow>[],
        );

        test('every idea survives an unfiltered pass', () {
          expect(
            selector.suggest(
              catalogue: catalogue,
              context: GiftContextSnapshot.empty,
            ),
            hasLength(packSize),
          );
        });

        test('rotation past the end never overflows and never empties', () {
          final List<GiftSuggestion> ranked = selector.suggest(
            catalogue: catalogue,
            context: GiftContextSnapshot.empty,
          );

          for (final int cursor in <int>[0, packSize - 1, packSize, 1000]) {
            final List<GiftSuggestion> batch =
                selector.nextBatch(ranked, cursor: cursor, size: 5);
            expect(batch, isNotEmpty, reason: 'cursor $cursor went empty');
            expect(
              batch,
              hasLength(packSize < 5 ? packSize : 5),
              reason: 'cursor $cursor changed the batch size',
            );
          }
        });

        test('the handmade branch stays non-empty and inside its branch', () {
          final List<GiftSuggestion> ranked = selector.suggest(
            catalogue: catalogue,
            context: GiftContextSnapshot.empty,
            filter: const GiftFilter(branchId: _branchHandmade),
          );

          // N=1 ships a single by_occasion idea, so an empty handmade branch is
          // the defined state there; what must never happen is an error.
          expect(
            ranked.every(
              (GiftSuggestion s) => s.idea.branchId == _branchHandmade,
            ),
            isTrue,
          );
          if (packSize > 2) {
            expect(ranked, isNotEmpty);
          }
        });

        test('the two-hour ceiling holds at this size', () {
          final List<GiftSuggestion> ranked = selector.suggest(
            catalogue: catalogue,
            context: GiftContextSnapshot.empty,
            filter: const GiftFilter(effortTierId: _tier120),
          );

          expect(
            ranked.every((GiftSuggestion s) => (s.effortMinutes ?? 0) <= 120),
            isTrue,
          );
        });

        test('the order repeats exactly on a second pass', () {
          final List<String> first = _idsOf(
            selector.suggest(
              catalogue: catalogue,
              context: GiftContextSnapshot.empty,
            ),
          );
          final List<String> second = _idsOf(
            selector.suggest(
              catalogue: _catalogue(
                ideas: _generatedIdeas(packSize),
                indexRows: const <GiftIndexRow>[],
              ),
              context: GiftContextSnapshot.empty,
            ),
          );

          expect(first, second);
        });
      });
    }
  });
}
