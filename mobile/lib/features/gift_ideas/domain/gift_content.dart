import '../../../core/content/content_package.dart';

/// The three gift package families (`architecture/contract-summary.md` §1, §2).
/// Separate schema ids because the item shapes have nothing in common — this is
/// a new package family, not a new category of an existing one.
const String giftsSchemaId = 'req016.gifts.v1';
const String giftIndexSchemaId = 'req016.gift_index.v1';
const String giftTaxonomySchemaId = 'req016.gift_taxonomy.v1';

const String giftsAssetKey = 'assets/data/req016/gifts.v1.json';
const String giftIndexAssetKey = 'assets/data/req016/gift_index.v1.json';
const String giftTaxonomyAssetKey = 'assets/data/req016/gift_taxonomy.v1.json';

/// The branches the shipped taxonomy must offer, each with at least one idea
/// pointing at it (BR-11). Stable ids, not labels: the wording lives in the
/// package, the requirement lives here.
const List<String> requiredGiftBranchIds = <String>[
  'by_occasion',
  'no_cost',
  'handmade',
];

/// What a taxonomy item classifies. Branches and effort tiers are themselves
/// data items, so this closed set names the two *kinds* of item and never their
/// values — a switch over a hardcoded branch list is the AC-34 violation.
enum GiftTaxonomyKind {
  branch('branch'),
  effortTier('effort_tier');

  const GiftTaxonomyKind(this.wireValue);

  final String wireValue;

  static GiftTaxonomyKind? fromWireValue(String value) {
    for (final GiftTaxonomyKind kind in values) {
      if (kind.wireValue == value) {
        return kind;
      }
    }
    return null;
  }
}

/// Which recorded context an index row is keyed by
/// (`architecture/contract-summary.md` §2, §4). A closed set of three: an
/// unknown value is a parse error, never a default.
enum GiftContextKind {
  interest('interest'),
  event('event'),
  skill('skill');

  const GiftContextKind(this.wireValue);

  final String wireValue;

  static GiftContextKind? fromWireValue(String value) {
    for (final GiftContextKind kind in values) {
      if (kind.wireValue == value) {
        return kind;
      }
    }
    return null;
  }
}

/// One gift idea.
///
/// There is deliberately no price, price range, budget, currency, vendor, or
/// link field. The effort a reader is asked to weigh is hours, and only hours
/// (AC-14/AC-15/AC-26, R-11).
class GiftIdea implements ContentItem {
  const GiftIdea({
    required this.id,
    required this.title,
    required this.description,
    required this.branchId,
    required this.effortTierId,
    required this.isHandmade,
  });

  @override
  final String id;

  final String title;

  /// Says what to do, never where to get it.
  final String description;

  /// Resolves against a [GiftTaxonomyKind.branch] item id. The gate rejects a
  /// value the shipped taxonomy does not declare (AC-34).
  final String branchId;

  /// Resolves against a [GiftTaxonomyKind.effortTier] item id.
  final String effortTierId;

  final bool isHandmade;
}

/// One row of the context-to-gift lookup.
///
/// This package is the only home of the knowledge of which recorded context
/// suits which idea. Re-deriving that mapping in Dart would put editorial
/// judgement back in code, where the out-of-repo CMS cannot reach it (R-15a).
class GiftIndexRow implements ContentItem {
  const GiftIndexRow({
    required this.id,
    required this.contextKind,
    required this.value,
    required this.giftIds,
  });

  @override
  final String id;

  final GiftContextKind contextKind;

  /// For [GiftContextKind.skill] this is the durable seed id held in
  /// `skill_profile_entries.seed_id`; for the two notebook kinds it is the
  /// recorded `notebook_entries.value` text.
  final String value;

  /// Never empty: a row that resolves to nothing is dead editorial data.
  final List<String> giftIds;
}

/// One branch or one effort tier.
class GiftTaxonomyItem implements ContentItem {
  const GiftTaxonomyItem({
    required this.id,
    required this.kind,
    required this.label,
    this.maxMinutes,
  });

  @override
  final String id;

  final GiftTaxonomyKind kind;

  final String label;

  /// Upper bound of an effort tier, in minutes, so a filter such as two hours
  /// tonight (AC-17) compares data instead of hardcoding the tier list. Present
  /// only on [GiftTaxonomyKind.effortTier] items, and it is an hours scale: no
  /// price scale, no currency unit.
  final int? maxMinutes;
}

GiftIdea giftIdeaFromJson(Map<String, Object?> json, String source) {
  final String id = requireContentString(json, 'id', source);

  return GiftIdea(
    id: id,
    title: requireContentString(json, 'title', source),
    description: requireContentString(json, 'description', source),
    branchId: requireContentString(json, 'branch_id', source),
    effortTierId: requireContentString(json, 'effort_tier_id', source),
    isHandmade: _requireContentBool(json, 'is_handmade', source),
  );
}

GiftIndexRow giftIndexRowFromJson(Map<String, Object?> json, String source) {
  final String id = requireContentString(json, 'id', source);
  final String rawKind = requireContentString(json, 'context_kind', source);
  final GiftContextKind? contextKind = GiftContextKind.fromWireValue(rawKind);
  if (contextKind == null) {
    throw ContentPackageFormatException(
      source,
      'index row "$id" declares unsupported context_kind "$rawKind"',
    );
  }

  final List<String> giftIds = requireContentStringList(
    json,
    'gift_ids',
    source,
  );
  if (giftIds.isEmpty) {
    throw ContentPackageFormatException(
      source,
      'index row "$id" must point at least one gift idea',
    );
  }

  return GiftIndexRow(
    id: id,
    contextKind: contextKind,
    value: requireContentString(json, 'value', source),
    giftIds: List<String>.unmodifiable(giftIds),
  );
}

GiftTaxonomyItem giftTaxonomyItemFromJson(
  Map<String, Object?> json,
  String source,
) {
  final String id = requireContentString(json, 'id', source);
  final String rawKind = requireContentString(json, 'kind', source);
  final GiftTaxonomyKind? kind = GiftTaxonomyKind.fromWireValue(rawKind);
  if (kind == null) {
    throw ContentPackageFormatException(
      source,
      'taxonomy item "$id" declares unsupported kind "$rawKind"',
    );
  }

  final Object? rawMaxMinutes = json['max_minutes'];
  switch (kind) {
    case GiftTaxonomyKind.branch:
      if (rawMaxMinutes != null) {
        throw ContentPackageFormatException(
          source,
          'branch "$id" must not carry an effort bound',
        );
      }
    case GiftTaxonomyKind.effortTier:
      if (rawMaxMinutes is! int) {
        throw ContentPackageFormatException(
          source,
          'effort tier "$id" must declare "max_minutes" as a whole number of '
          'minutes',
        );
      }
  }

  return GiftTaxonomyItem(
    id: id,
    kind: kind,
    label: requireContentString(json, 'label', source),
    maxMinutes: rawMaxMinutes is int ? rawMaxMinutes : null,
  );
}

bool _requireContentBool(
  Map<String, Object?> json,
  String key,
  String source,
) {
  final Object? value = json[key];
  if (value is! bool) {
    throw ContentPackageFormatException(
      source,
      'field "$key" must be a boolean',
    );
  }
  return value;
}
