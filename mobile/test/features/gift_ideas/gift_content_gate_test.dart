import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/gift_ideas/domain/gift_content.dart';
import 'package:cupid_mobile/features/gift_ideas/domain/gift_content_gate.dart';
import 'package:flutter_test/flutter_test.dart';

const String _fixtureEffortTierId = 'effort.fixture.v1';

ContentPackage<GiftIdea> _parseGifts(String source,
        {String label = '<fixture>'}) =>
    ContentPackage.parse<GiftIdea>(
      source,
      expectedSchemaId: giftsSchemaId,
      itemParser: giftIdeaFromJson,
      source: label,
    );

ContentPackage<GiftIndexRow> _parseIndex(String source,
        {String label = '<fixture>'}) =>
    ContentPackage.parse<GiftIndexRow>(
      source,
      expectedSchemaId: giftIndexSchemaId,
      itemParser: giftIndexRowFromJson,
      source: label,
    );

ContentPackage<GiftTaxonomyItem> _parseTaxonomy(String source,
        {String label = '<fixture>'}) =>
    ContentPackage.parse<GiftTaxonomyItem>(
      source,
      expectedSchemaId: giftTaxonomySchemaId,
      itemParser: giftTaxonomyItemFromJson,
      source: label,
    );

/// An idea pack that always covers every required branch, so a test only has to
/// describe the one thing it breaks.
String _giftsPack({
  String title = 'Thư tay cho một buổi cụ thể',
  String description = 'Viết tay một trang rồi gấp vào phong bì bạn tự gấp.',
  List<String>? branchIds,
  String effortTierId = _fixtureEffortTierId,
  Object? isHandmade = true,
  String schemaId = giftsSchemaId,
}) =>
    jsonEncode(<String, Object?>{
      'id': 'gifts.fixture',
      'version': '1.0.0',
      'schema_id': schemaId,
      'locale': 'vi',
      'items': <Map<String, Object?>>[
        for (final String branchId in branchIds ?? requiredGiftBranchIds)
          <String, Object?>{
            'id': 'gift.fixture.$branchId.v1',
            'title': title,
            'description': description,
            'branch_id': branchId,
            'effort_tier_id': effortTierId,
            'is_handmade': isHandmade,
          },
      ],
    });

String _taxonomyPack({
  List<String>? branchIds,
  List<String> effortTierIds = const <String>[_fixtureEffortTierId],
  String branchLabel = 'Theo dịp',
  String effortLabel = 'Trong một giờ',
  Object? branchMaxMinutes,
  Object? effortMaxMinutes = 60,
  String kind = 'branch',
}) =>
    jsonEncode(<String, Object?>{
      'id': 'gift_taxonomy.fixture',
      'version': '1.0.0',
      'schema_id': giftTaxonomySchemaId,
      'locale': 'vi',
      'items': <Map<String, Object?>>[
        for (final String branchId in branchIds ?? requiredGiftBranchIds)
          <String, Object?>{
            'id': branchId,
            'kind': kind,
            'label': branchLabel,
            'max_minutes': ?branchMaxMinutes,
          },
        for (final String tierId in effortTierIds)
          <String, Object?>{
            'id': tierId,
            'kind': 'effort_tier',
            'label': effortLabel,
            'max_minutes': ?effortMaxMinutes,
          },
      ],
    });

String _indexPack({
  String contextKind = 'interest',
  String value = 'nấu ăn',
  List<String> giftIds = const <String>['gift.fixture.by_occasion.v1'],
}) =>
    jsonEncode(<String, Object?>{
      'id': 'gift_index.fixture',
      'version': '1.0.0',
      'schema_id': giftIndexSchemaId,
      'locale': 'vi',
      'items': <Map<String, Object?>>[
        <String, Object?>{
          'id': 'gift_index.fixture.v1',
          'context_kind': contextKind,
          'value': value,
          'gift_ids': giftIds,
        },
      ],
    });

List<GiftViolation> _violations({
  String title = 'Thư tay cho một buổi cụ thể',
  String description = 'Viết tay một trang rồi gấp vào phong bì bạn tự gấp.',
  List<String>? giftBranchIds,
  String effortTierId = _fixtureEffortTierId,
  List<String>? taxonomyBranchIds,
  String branchLabel = 'Theo dịp',
  String effortLabel = 'Trong một giờ',
  String indexValue = 'nấu ăn',
  List<String> indexGiftIds = const <String>['gift.fixture.by_occasion.v1'],
}) =>
    validateGiftPacks(
      gifts: _parseGifts(
        _giftsPack(
          title: title,
          description: description,
          branchIds: giftBranchIds,
          effortTierId: effortTierId,
        ),
      ),
      giftIndex: _parseIndex(
        _indexPack(value: indexValue, giftIds: indexGiftIds),
      ),
      taxonomy: _parseTaxonomy(
        _taxonomyPack(
          branchIds: taxonomyBranchIds,
          branchLabel: branchLabel,
          effortLabel: effortLabel,
        ),
      ),
    );

List<GiftGateRule> _rulesFrom(List<GiftViolation> violations) =>
    violations.map((GiftViolation v) => v.rule).toList(growable: false);

final RegExp _singleQuoted = RegExp(r"'[^']*'");
final RegExp _doubleQuoted = RegExp(r'"[^"]*"');
final RegExp _integerLiteral = RegExp(r'(?<![\w.])\d+');

/// Removes string literals first, then line comments, so a rule that has to
/// name a currency symbol or a digit pattern inside a pattern string is not
/// mistaken for a hardcoded count.
String _strippedDart(String source) => source
    .replaceAll(_singleQuoted, '')
    .replaceAll(_doubleQuoted, '')
    .split('\n')
    .map((String line) {
      final int marker = line.indexOf('//');
      return marker < 0 ? line : line.substring(0, marker);
    })
    .join('\n');

List<File> _giftFeatureDartFiles() =>
    Directory('lib/features/gift_ideas').listSync(recursive: true).whereType<File>().where((File f) => f.path.endsWith('.dart')).toList(growable: false);

void main() {
  group('the shipped packs pass the gate from disk (AC-14/AC-15/AC-26)', () {
    late ContentPackage<GiftIdea> gifts;
    late ContentPackage<GiftIndexRow> giftIndex;
    late ContentPackage<GiftTaxonomyItem> taxonomy;

    setUp(() {
      gifts = _parseGifts(
        File(giftsAssetKey).readAsStringSync(),
        label: giftsAssetKey,
      );
      giftIndex = _parseIndex(
        File(giftIndexAssetKey).readAsStringSync(),
        label: giftIndexAssetKey,
      );
      taxonomy = _parseTaxonomy(
        File(giftTaxonomyAssetKey).readAsStringSync(),
        label: giftTaxonomyAssetKey,
      );
    });

    test('all three packs exist on disk and are not empty', () {
      expect(File(giftsAssetKey).existsSync(), isTrue);
      expect(File(giftIndexAssetKey).existsSync(), isTrue);
      expect(File(giftTaxonomyAssetKey).existsSync(), isTrue);
      expect(gifts.items, isNotEmpty);
      expect(giftIndex.items, isNotEmpty);
      expect(taxonomy.items, isNotEmpty);
    });

    test('the packs on disk report no violation', () {
      expect(
        validateGiftPacks(
          gifts: gifts,
          giftIndex: giftIndex,
          taxonomy: taxonomy,
        ).map((GiftViolation v) => v.toString()),
        isEmpty,
      );
    });

    test('every required branch ships with at least one idea (BR-11)', () {
      final Set<String> shippedBranchIds = taxonomy.items
          .where((GiftTaxonomyItem i) => i.kind == GiftTaxonomyKind.branch)
          .map((GiftTaxonomyItem i) => i.id)
          .toSet();
      final Set<String> branchIdsInUse =
          gifts.items.map((GiftIdea i) => i.branchId).toSet();

      for (final String branchId in requiredGiftBranchIds) {
        expect(shippedBranchIds, contains(branchId));
        expect(branchIdsInUse, contains(branchId), reason: branchId);
      }
    });

    test('the effort scale is hours, and every tier carries its own bound', () {
      final List<GiftTaxonomyItem> tiers = taxonomy.items
          .where((GiftTaxonomyItem i) => i.kind == GiftTaxonomyKind.effortTier)
          .toList(growable: false);

      expect(tiers, isNotEmpty);
      for (final GiftTaxonomyItem tier in tiers) {
        expect(tier.maxMinutes, isNotNull, reason: tier.id);
      }
      expect(
        gifts.items.map((GiftIdea i) => i.effortTierId).toSet(),
        tiers.map((GiftTaxonomyItem t) => t.id).toSet(),
      );
    });

    test('every index row resolves to a shipped idea (R-15a)', () {
      for (final GiftIndexRow row in giftIndex.items) {
        for (final String giftId in row.giftIds) {
          expect(gifts.itemById(giftId), isNotNull, reason: '${row.id}/$giftId');
        }
      }
      expect(
        giftIndex.items.map((GiftIndexRow r) => r.contextKind).toSet(),
        GiftContextKind.values.toSet(),
      );
    });

    test('no gift wording is written into any Dart or l10n file (BR-16)', () {
      final List<String> authored = <String>[
        for (final GiftIdea idea in gifts.items) ...<String>[
          idea.title,
          idea.description,
        ],
        for (final GiftTaxonomyItem item in taxonomy.items) item.label,
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

  group('the gift flow carries no count constant and no money (AC-33/BR-17)',
      () {
    test('the literal scan itself can tell a count from a pattern string', () {
      expect(
        _integerLiteral.hasMatch(_strippedDart('final int ideaCount = 9;')),
        isTrue,
      );
      expect(
        _integerLiteral.hasMatch(_strippedDart("const String p = 'a9'; // 9")),
        isFalse,
      );
    });

    test('no Dart file in the gift flow hardcodes a count', () {
      final List<File> files = _giftFeatureDartFiles();
      final List<String> offenders = <String>[];

      for (final File file in files) {
        final String stripped = _strippedDart(file.readAsStringSync());
        for (final RegExpMatch match
            in _integerLiteral.allMatches(stripped).cast<RegExpMatch>()) {
          offenders.add('${file.path} hardcodes "${match.group(0)}"');
        }
      }

      expect(files, isNotEmpty);
      expect(offenders, isEmpty);
    });

    test('the pack sizes the flow can quote are data, not literals', () {
      final ContentPackage<GiftIdea> gifts = _parseGifts(
        File(giftsAssetKey).readAsStringSync(),
        label: giftsAssetKey,
      );
      final ContentPackage<GiftTaxonomyItem> taxonomy = _parseTaxonomy(
        File(giftTaxonomyAssetKey).readAsStringSync(),
        label: giftTaxonomyAssetKey,
      );

      expect(gifts.length, gifts.items.length);
      expect(taxonomy.length, taxonomy.items.length);
    });

    test('only the gate names a currency token (R-15c)', () {
      const List<String> currencyTokens = <String>['₫', 'vnđ', 'vnd', 'đồng'];
      final List<String> offenders = <String>[];

      for (final File file in _giftFeatureDartFiles()) {
        final String normalised = file.path.replaceAll(r'\', '/');
        if (normalised.endsWith('domain/gift_content_gate.dart')) {
          continue;
        }
        final String source = file.readAsStringSync().toLowerCase();
        for (final String token in currencyTokens) {
          if (source.contains(token)) {
            offenders.add('${file.path} names "$token"');
          }
        }
      }

      expect(offenders, isEmpty);
    });
  });

  group('parser rules run before the gate sees a package', () {
    test('the fixture baseline is clean, so every red below is the one break',
        () {
      expect(_violations(), isEmpty);
    });

    test('an unknown context_kind is a parse error, not a default', () {
      expect(
        () => _parseIndex(_indexPack(contextKind: 'partner_behaviour')),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('unsupported context_kind "partner_behaviour"'),
          ),
        ),
      );
    });

    test('an unknown taxonomy kind is a parse error', () {
      expect(
        () => _parseTaxonomy(_taxonomyPack(kind: 'price_tier')),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('unsupported kind "price_tier"'),
          ),
        ),
      );
    });

    test('an index row pointing at nothing is rejected', () {
      expect(
        () => _parseIndex(_indexPack(giftIds: const <String>[])),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('must point at least one gift idea'),
          ),
        ),
      );
    });

    test('a non-boolean is_handmade is rejected', () {
      expect(
        () => _parseGifts(_giftsPack(isHandmade: 'yes')),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('"is_handmade" must be a boolean'),
          ),
        ),
      );
    });

    test('a branch carrying an effort bound is rejected', () {
      expect(
        () => _parseTaxonomy(_taxonomyPack(branchMaxMinutes: 30)),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('must not carry an effort bound'),
          ),
        ),
      );
    });

    test('an effort tier without its bound is rejected', () {
      expect(
        () => _parseTaxonomy(_taxonomyPack(effortMaxMinutes: null)),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('must declare "max_minutes"'),
          ),
        ),
      );
    });

    test('a pack under another schema id is rejected at load', () {
      expect(
        () => _parseGifts(_giftsPack(schemaId: 'req016.gifts.v2')),
        throwsA(
          isA<ContentPackageFormatException>().having(
            (ContentPackageFormatException e) => e.message,
            'message',
            contains('does not match the expected "req016.gifts.v1"'),
          ),
        ),
      );
    });
  });

  group('money and commerce cannot reach the gift flow (AC-14/AC-15/AC-26)',
      () {
    test('a currency amount in a title', () {
      expect(
        _rulesFrom(_violations(title: 'Bó hoa 250.000₫ cho dịp này')),
        contains(GiftGateRule.priceOrCommerce),
      );
    });

    test('a shorthand amount in a description', () {
      expect(
        _rulesFrom(
          _violations(description: 'Chọn một món khoảng 200k rồi gói lại.'),
        ),
        contains(GiftGateRule.priceOrCommerce),
      );
    });

    test('a cheap-or-dear label', () {
      expect(
        _rulesFrom(_violations(title: 'Quà rẻ mà vẫn có tình')),
        contains(GiftGateRule.priceOrCommerce),
      );
    });

    test('a store name', () {
      expect(
        _rulesFrom(
          _violations(description: 'Mua trên Shopee một hộp bánh nhỏ.'),
        ),
        contains(GiftGateRule.priceOrCommerce),
      );
    });

    test('a store link', () {
      expect(
        _rulesFrom(
          _violations(description: 'Xem ở https://shopee.vn/qua-tang rồi chọn.'),
        ),
        contains(GiftGateRule.priceOrCommerce),
      );
    });

    test('a bare grouped figure with the unit dropped', () {
      expect(
        _rulesFrom(_violations(title: 'Món quà tầm 300.000 trở lại')),
        contains(GiftGateRule.priceOrCommerce),
      );
    });

    test('a taxonomy label is scanned too, not only an idea', () {
      expect(
        _rulesFrom(_violations(branchLabel: 'Nhánh quà rẻ')),
        contains(GiftGateRule.priceOrCommerce),
      );
    });

    test('an index row value is scanned too', () {
      expect(
        _rulesFrom(_violations(indexValue: 'đặt hàng quà sinh nhật')),
        contains(GiftGateRule.priceOrCommerce),
      );
    });

    test('an hours-only effort label stays clean', () {
      expect(_rulesFrom(_violations(effortLabel: 'Trong 30 phút')), isEmpty);
      expect(_rulesFrom(_violations(effortLabel: 'Một tới hai giờ')), isEmpty);
    });

    test('the no-cost branch may still say the word for money', () {
      expect(_rulesFrom(_violations(branchLabel: 'Không tốn tiền')), isEmpty);
    });
  });

  group('the shared invariant rules fire on gift packs too (AC-26)', () {
    test('flattery', () {
      expect(
        _rulesFrom(_violations(title: 'Món quà tuyệt vời cho người ấy')),
        contains(GiftGateRule.flattery),
      );
    });

    test('a percentage figure', () {
      expect(
        _rulesFrom(_violations(description: 'Hợp gu tới 80% nên tặng món này.')),
        contains(GiftGateRule.percentDisplay),
      );
    });

    test('a score or ranking', () {
      expect(
        _rulesFrom(_violations(title: 'Xếp hạng quà đáng tặng nhất')),
        contains(GiftGateRule.scoreOrRatio),
      );
    });

    test('a recipient-behaviour indicator', () {
      expect(
        _rulesFrom(
          _violations(description: 'Gửi khi người ấy đã xem tin nhắn của bạn.'),
        ),
        contains(GiftGateRule.recipientBehaviour),
      );
    });
  });

  group('cross-pack ids must resolve (AC-34/R-15a)', () {
    test('a branch_id the taxonomy does not declare', () {
      final List<GiftViolation> violations = _violations(
        giftBranchIds: <String>[...requiredGiftBranchIds, 'by_price_range'],
      );

      expect(_rulesFrom(violations), contains(GiftGateRule.unknownTaxonomyId));
      expect(
        violations
            .where((GiftViolation v) => v.rule == GiftGateRule.unknownTaxonomyId)
            .map((GiftViolation v) => v.detail)
            .join(),
        contains('branch_id "by_price_range"'),
      );
    });

    test('an effort_tier_id the taxonomy does not declare', () {
      final List<GiftViolation> violations =
          _violations(effortTierId: 'effort.duoi_200k.v1');

      expect(_rulesFrom(violations), contains(GiftGateRule.unknownTaxonomyId));
      expect(
        violations
            .where((GiftViolation v) => v.rule == GiftGateRule.unknownTaxonomyId)
            .map((GiftViolation v) => v.detail)
            .join(),
        contains('effort_tier_id "effort.duoi_200k.v1"'),
      );
    });

    test('an index row pointing at a gift id that was never shipped', () {
      final List<GiftViolation> violations = _violations(
        indexGiftIds: const <String>['gift.khong_ton_tai.v1'],
      );

      expect(_rulesFrom(violations), contains(GiftGateRule.danglingGiftId));
      expect(
        violations
            .where((GiftViolation v) => v.rule == GiftGateRule.danglingGiftId)
            .map((GiftViolation v) => v.itemId),
        <String>['gift_index.fixture.v1'],
      );
    });
  });

  group('every required branch must be reachable (BR-11)', () {
    test('a taxonomy missing a required branch is a violation', () {
      final List<String> withoutHandmade = requiredGiftBranchIds
          .where((String id) => id != 'handmade')
          .toList(growable: false);

      final List<GiftViolation> violations = _violations(
        giftBranchIds: withoutHandmade,
        taxonomyBranchIds: withoutHandmade,
      );

      expect(
        _rulesFrom(violations),
        contains(GiftGateRule.missingRequiredBranch),
      );
      expect(
        violations.map((GiftViolation v) => v.itemId),
        <String>['handmade'],
      );
    });

    test('a required branch no idea points at is a violation', () {
      final List<GiftViolation> violations = _violations(
        giftBranchIds: requiredGiftBranchIds
            .where((String id) => id != 'handmade')
            .toList(growable: false),
      );

      expect(_rulesFrom(violations), contains(GiftGateRule.branchWithoutIdea));
      expect(
        violations.map((GiftViolation v) => v.itemId),
        <String>['handmade'],
      );
    });
  });
}
