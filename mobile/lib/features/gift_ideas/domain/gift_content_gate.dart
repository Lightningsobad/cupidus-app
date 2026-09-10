import '../../../core/content/content_package.dart';
import '../../../core/content/invariant_terms.dart';
import 'gift_content.dart';

/// What a gift pack can break. The first six pair by wire value with
/// [InvariantRule], so the rules every package family is measured against stay
/// in `core/content/invariant_terms.dart` and this enum only names them (D-15).
/// The rest are this family only: they judge the gift flow, not every flow.
enum GiftGateRule {
  flattery('flattery'),
  percentDisplay('percent_display'),
  streakDisplay('streak_display'),
  scoreOrRatio('score_or_ratio'),
  recipientBehaviour('recipient_behaviour'),
  manipulativeTone('manipulative_tone'),
  priceOrCommerce('price_or_commerce'),
  unknownTaxonomyId('unknown_taxonomy_id'),
  danglingGiftId('dangling_gift_id'),
  missingRequiredBranch('missing_required_branch'),
  branchWithoutIdea('branch_without_idea');

  const GiftGateRule(this.wireValue);

  final String wireValue;
}

class GiftViolation {
  const GiftViolation({
    required this.packageId,
    required this.itemId,
    required this.rule,
    required this.detail,
  });

  final String packageId;
  final String itemId;
  final GiftGateRule rule;
  final String detail;

  @override
  String toString() => '$packageId/$itemId [${rule.wireValue}]: $detail';
}

/// Runs every rule over the three gift packs and returns what they broke. An
/// empty list is the only shippable result: the test that calls this scans
/// `assets/data/req016/` from disk, so a violating pack turns the build red
/// rather than reaching a reader (AC-14/AC-15/AC-26/AC-34, BR-11).
List<GiftViolation> validateGiftPacks({
  required ContentPackage<GiftIdea> gifts,
  required ContentPackage<GiftIndexRow> giftIndex,
  required ContentPackage<GiftTaxonomyItem> taxonomy,
}) {
  final List<GiftViolation> violations = <GiftViolation>[];

  final Set<String> branchIds = <String>{};
  final Set<String> effortTierIds = <String>{};
  for (final GiftTaxonomyItem item in taxonomy.items) {
    switch (item.kind) {
      case GiftTaxonomyKind.branch:
        branchIds.add(item.id);
      case GiftTaxonomyKind.effortTier:
        effortTierIds.add(item.id);
    }
    violations.addAll(_displayViolations(taxonomy.id, item.id, item.label));
  }

  final Set<String> branchIdsInUse = <String>{};
  for (final GiftIdea idea in gifts.items) {
    for (final String text in <String>[idea.title, idea.description]) {
      violations.addAll(_displayViolations(gifts.id, idea.id, text));
    }

    if (branchIds.contains(idea.branchId)) {
      branchIdsInUse.add(idea.branchId);
    } else {
      violations.add(
        GiftViolation(
          packageId: gifts.id,
          itemId: idea.id,
          rule: GiftGateRule.unknownTaxonomyId,
          detail: 'branch_id "${idea.branchId}" is not a branch the shipped '
              'taxonomy declares',
        ),
      );
    }

    if (!effortTierIds.contains(idea.effortTierId)) {
      violations.add(
        GiftViolation(
          packageId: gifts.id,
          itemId: idea.id,
          rule: GiftGateRule.unknownTaxonomyId,
          detail: 'effort_tier_id "${idea.effortTierId}" is not an effort tier '
              'the shipped taxonomy declares',
        ),
      );
    }
  }

  for (final GiftIndexRow row in giftIndex.items) {
    violations.addAll(_displayViolations(giftIndex.id, row.id, row.value));

    for (final String giftId in row.giftIds) {
      if (gifts.itemById(giftId) == null) {
        violations.add(
          GiftViolation(
            packageId: giftIndex.id,
            itemId: row.id,
            rule: GiftGateRule.danglingGiftId,
            detail: 'points at gift id "$giftId", which the idea pack does not '
                'ship',
          ),
        );
      }
    }
  }

  for (final String requiredId in requiredGiftBranchIds) {
    if (!branchIds.contains(requiredId)) {
      violations.add(
        GiftViolation(
          packageId: taxonomy.id,
          itemId: requiredId,
          rule: GiftGateRule.missingRequiredBranch,
          detail: 'the taxonomy must offer this branch before the gift flow can '
              'show it as a way in',
        ),
      );
    } else if (!branchIdsInUse.contains(requiredId)) {
      violations.add(
        GiftViolation(
          packageId: gifts.id,
          itemId: requiredId,
          rule: GiftGateRule.branchWithoutIdea,
          detail: 'no shipped idea points at this branch, so opening it would '
              'dead-end on an empty screen',
        ),
      );
    }
  }

  return List<GiftViolation>.unmodifiable(violations);
}

/// Gift-flow commerce terms. They live beside the gift packs, not in
/// `core/content/invariant_terms.dart`, because they measure one package family
/// against R-11 rather than measuring every family against the shared display
/// invariants.
const List<String> _commerceTerms = <String>[
  'vnđ',
  'vnd',
  'giá',
  'rẻ',
  'đắt',
  'tiết kiệm',
  'ngân sách',
  'chi phí',
  'khuyến mãi',
  'voucher',
  'sale',
  'deal',
  'freeship',
  'mua trên',
  'mua tại',
  'mua ở',
  'đặt mua',
  'đặt hàng',
  'cửa hàng',
  'shop',
  'gian hàng',
  'shopee',
  'lazada',
  'tiki',
  'sendo',
  'amazon',
  'taobao',
];

final RegExp _currencySymbol = RegExp(r'₫');

/// A figure carrying a money unit, so a bare hour count stays legal while
/// anything wearing a currency tail does not.
final RegExp _amountWithMoneyUnit = RegExp(
  r'\d\s*(₫|đ|k|tr|nghìn|ngàn|triệu|đồng)(?![\p{L}\p{N}])',
  unicode: true,
  caseSensitive: false,
);

/// Thousands-grouped digits, which is how a price range is written even when
/// the author drops the unit.
final RegExp _groupedAmount = RegExp(r'\d{1,3}([.,]\d{3})+');

final RegExp _webAddress = RegExp(
  r'https?://|www\.|(?<![\p{L}\p{N}])[\p{L}\p{N}-]+\.(com|vn|net|org|shop|store)(?![\p{L}\p{N}])',
  unicode: true,
  caseSensitive: false,
);

final Map<String, RegExp> _termPatterns = <String, RegExp>{};

RegExp _wholeWordPattern(String term) => _termPatterns.putIfAbsent(
      term,
      () => RegExp(
        '(?<![\\p{L}\\p{N}])${RegExp.escape(term)}(?![\\p{L}\\p{N}])',
        unicode: true,
        caseSensitive: false,
      ),
    );

Iterable<GiftViolation> _displayViolations(
  String packageId,
  String itemId,
  String text,
) sync* {
  for (final InvariantTermHit hit in invariantHitsIn(text)) {
    yield GiftViolation(
      packageId: packageId,
      itemId: itemId,
      rule: _giftRuleFor(hit.rule.wireValue),
      detail: hit.detail,
    );
  }

  for (final String detail in _commerceDetails(text)) {
    yield GiftViolation(
      packageId: packageId,
      itemId: itemId,
      rule: GiftGateRule.priceOrCommerce,
      detail: detail,
    );
  }
}

Iterable<String> _commerceDetails(String text) sync* {
  if (_currencySymbol.hasMatch(text) || _amountWithMoneyUnit.hasMatch(text)) {
    yield 'text shows an amount of money';
  }
  if (_groupedAmount.hasMatch(text)) {
    yield 'text shows a price-shaped figure';
  }
  if (_webAddress.hasMatch(text)) {
    yield 'text carries a web address, which is a commercial path out of the '
        'flow';
  }

  final String haystack = text.toLowerCase();
  for (final String term in _commerceTerms) {
    if (_wholeWordPattern(term).hasMatch(haystack)) {
      yield 'text uses the commerce term "$term"';
    }
  }
}

GiftGateRule _giftRuleFor(String wireValue) =>
    GiftGateRule.values.firstWhere((GiftGateRule r) => r.wireValue == wireValue);
