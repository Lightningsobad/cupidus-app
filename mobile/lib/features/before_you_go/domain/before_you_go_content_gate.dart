import '../../../core/content/content_package.dart';
import '../../../core/content/invariant_terms.dart';
import 'before_you_go_content.dart';

/// What a "trước giờ đi" pack can break. The first seven pair by wire value
/// with [InvariantRule], so the rules every package family is measured against
/// stay in `core/content/invariant_terms.dart` and this enum only names them
/// (D-15). The rest are this family only: they judge a functional checklist
/// row, not every flow.
enum BeforeYouGoGateRule {
  flattery('flattery'),
  percentDisplay('percent_display'),
  streakDisplay('streak_display'),
  scoreOrRatio('score_or_ratio'),
  recipientBehaviour('recipient_behaviour'),
  manipulativeTone('manipulative_tone'),
  assertiveClaim('assertive_claim'),
  completionCount('completion_count'),
  partnerDirectedTone('partner_directed_tone'),
  invalidItemId('invalid_item_id'),
  duplicateItemId('duplicate_item_id'),
  emptyLabel('empty_label'),
  labelTooLong('label_too_long'),
  unknownIcon('unknown_icon'),
  emptyCondition('empty_condition'),
  invalidRegion('invalid_region'),
  duplicateRegionAlias('duplicate_region_alias');

  const BeforeYouGoGateRule(this.wireValue);

  final String wireValue;
}

class BeforeYouGoViolation {
  const BeforeYouGoViolation({
    required this.packageId,
    required this.itemId,
    required this.rule,
    required this.detail,
  });

  final String packageId;
  final String itemId;
  final BeforeYouGoGateRule rule;
  final String detail;

  @override
  String toString() => '$packageId/$itemId [${rule.wireValue}]: $detail';
}

/// The icons shipped with the app. An icon is data, but the glyph behind it is
/// code, so a pack naming an icon this build cannot draw fails here rather
/// than rendering a blank row. Append-only.
const Set<String> beforeYouGoAllowedIcons = <String>{
  'payments',
  'local_gas_station',
  'umbrella',
  'event_available',
  'share_location',
};

/// A functional checklist label is short enough to read in one glance
/// (`contract-summary.md` §3).
const int beforeYouGoMaxLabelLength = 60;

final RegExp _asciiItemId = RegExp(r'^[a-z0-9_]+$');

/// Runs every invariant rule over the shipped checklist pack and returns what
/// it broke. An empty list is the only shippable result: the test that calls
/// this reads `assets/data/req016/before_you_go.v1.json` from disk, so a row
/// that slides from a functional label into content with a tone about the
/// other person turns the build red instead of reaching a reader
/// (AC-31/BR-17).
List<BeforeYouGoViolation> validateBeforeYouGoPack({
  required ContentPackage<ChecklistHint> hints,
  required List<RegionEntry> regions,
}) {
  final List<BeforeYouGoViolation> violations = <BeforeYouGoViolation>[];
  final Set<String> seenIds = <String>{};

  for (final ChecklistHint hint in hints.items) {
    if (!_asciiItemId.hasMatch(hint.id)) {
      violations.add(
        BeforeYouGoViolation(
          packageId: hints.id,
          itemId: hint.id,
          rule: BeforeYouGoGateRule.invalidItemId,
          detail: 'row id must be ASCII [a-z0-9_]+ so it survives a CMS '
              're-export',
        ),
      );
    }
    if (!seenIds.add(hint.id)) {
      violations.add(
        BeforeYouGoViolation(
          packageId: hints.id,
          itemId: hint.id,
          rule: BeforeYouGoGateRule.duplicateItemId,
          detail: 'row id is declared more than once in this pack',
        ),
      );
    }

    if (hint.labelVi.trim().isEmpty) {
      violations.add(
        BeforeYouGoViolation(
          packageId: hints.id,
          itemId: hint.id,
          rule: BeforeYouGoGateRule.emptyLabel,
          detail: 'row carries no label to show',
        ),
      );
    } else if (hint.labelVi.length > beforeYouGoMaxLabelLength) {
      violations.add(
        BeforeYouGoViolation(
          packageId: hints.id,
          itemId: hint.id,
          rule: BeforeYouGoGateRule.labelTooLong,
          detail: 'row label runs ${hint.labelVi.length} characters, past the '
              '$beforeYouGoMaxLabelLength a one-glance row allows',
        ),
      );
    }

    if (!beforeYouGoAllowedIcons.contains(hint.icon)) {
      violations.add(
        BeforeYouGoViolation(
          packageId: hints.id,
          itemId: hint.id,
          rule: BeforeYouGoGateRule.unknownIcon,
          detail: 'icon "${hint.icon}" is not one this build ships',
        ),
      );
    }

    if (hint.when.isEmpty) {
      violations.add(
        BeforeYouGoViolation(
          packageId: hints.id,
          itemId: hint.id,
          rule: BeforeYouGoGateRule.emptyCondition,
          detail: 'row declares no condition, so it can never be a row that '
              'only shows when the card carries the field it needs',
        ),
      );
    }

    violations.addAll(_labelViolations(hints.id, hint.id, hint.labelVi));
  }

  final Map<String, String> aliasOwners = <String, String>{};
  for (final RegionEntry region in regions) {
    if (!_asciiItemId.hasMatch(region.id)) {
      violations.add(
        BeforeYouGoViolation(
          packageId: hints.id,
          itemId: region.id,
          rule: BeforeYouGoGateRule.invalidRegion,
          detail: 'region id must be ASCII [a-z0-9_]+',
        ),
      );
    }
    for (final int month in region.rainyMonths) {
      if (month < 1 || month > 12) {
        violations.add(
          BeforeYouGoViolation(
            packageId: hints.id,
            itemId: region.id,
            rule: BeforeYouGoGateRule.invalidRegion,
            detail: 'region declares month $month, which is not a month',
          ),
        );
      }
    }
    for (final String alias in region.aliases) {
      final String? owner = aliasOwners[alias];
      if (owner != null) {
        violations.add(
          BeforeYouGoViolation(
            packageId: hints.id,
            itemId: region.id,
            rule: BeforeYouGoGateRule.duplicateRegionAlias,
            detail: 'alias "$alias" already belongs to region "$owner", so a '
                'card in that place would resolve by declaration order rather '
                'than by data',
          ),
        );
      } else {
        aliasOwners[alias] = region.id;
      }
    }
  }

  return List<BeforeYouGoViolation>.unmodifiable(violations);
}

/// Checklist-flow terms. They live beside this pack, not in
/// `core/content/invariant_terms.dart`, because they measure one package family
/// against AC-27 and BR-14 rather than measuring every family against the
/// shared display invariants.
const List<String> _completionCountTerms = <String>[
  'số lần',
  'lần thứ',
  'huy hiệu',
  'tích điểm',
  'thành tích',
  'cột mốc',
];

/// A functional checklist label describes something the user does. The moment
/// it names or addresses the other person it has left BR-14 and become content
/// whose tone needs review.
const List<String> _partnerDirectedTerms = <String>[
  'người ấy',
  'người kia',
  'nàng',
  'chàng',
  'crush',
  'đối phương',
  'gây ấn tượng',
  'lấy lòng',
  'ghi điểm',
  'chinh phục',
];

final Map<String, RegExp> _termPatterns = <String, RegExp>{};

RegExp _wholeWordPattern(String term) => _termPatterns.putIfAbsent(
      term,
      () => RegExp(
        '(?<![\\p{L}\\p{N}])${RegExp.escape(term)}(?![\\p{L}\\p{N}])',
        unicode: true,
        caseSensitive: false,
      ),
    );

Iterable<BeforeYouGoViolation> _labelViolations(
  String packageId,
  String itemId,
  String text,
) sync* {
  for (final InvariantTermHit hit in invariantHitsIn(text)) {
    yield BeforeYouGoViolation(
      packageId: packageId,
      itemId: itemId,
      rule: _sharedRuleFor(hit.rule.wireValue),
      detail: hit.detail,
    );
  }

  final String haystack = text.toLowerCase();
  for (final String term in _completionCountTerms) {
    if (_wholeWordPattern(term).hasMatch(haystack)) {
      yield BeforeYouGoViolation(
        packageId: packageId,
        itemId: itemId,
        rule: BeforeYouGoGateRule.completionCount,
        detail: 'row counts checklist completion via "$term"',
      );
    }
  }
  for (final String term in _partnerDirectedTerms) {
    if (_wholeWordPattern(term).hasMatch(haystack)) {
      yield BeforeYouGoViolation(
        packageId: packageId,
        itemId: itemId,
        rule: BeforeYouGoGateRule.partnerDirectedTone,
        detail: 'row speaks about the other person via "$term"',
      );
    }
  }
}

BeforeYouGoGateRule _sharedRuleFor(String wireValue) =>
    BeforeYouGoGateRule.values.firstWhere(
      (BeforeYouGoGateRule rule) => rule.wireValue == wireValue,
    );
