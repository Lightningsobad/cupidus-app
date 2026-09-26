import 'dart:convert';

import '../../../core/content/content_package.dart';

/// The "trước giờ đi" checklist package (`architecture/contract-summary.md`
/// §1-§3). Row wording, row icons, row conditions, and the distance threshold
/// are all data: swapping the source for an out-of-repo CMS must not cost a
/// code change (AC-29/BR-15).
const String beforeYouGoSchemaId = 'req016.before_you_go.v1';

const String beforeYouGoAssetKey = 'assets/data/req016/before_you_go.v1.json';

/// The CLOSED set of facts a row may be conditioned on. A field outside this
/// set is a schema error at load, never an extension point — content that can
/// name new facts is content that carries behaviour (`solution.md` §4).
enum HintFact {
  always('always'),
  priceVnd('priceVnd'),
  distanceKm('distanceKm'),
  needsBooking('needsBooking'),
  indoorOutdoor('indoorOutdoor'),
  rainySeason('rainySeason');

  const HintFact(this.wireValue);

  final String wireValue;

  static HintFact? fromWireValue(String value) {
    for (final HintFact fact in values) {
      if (fact.wireValue == value) {
        return fact;
      }
    }
    return null;
  }
}

/// The CLOSED set of comparisons a clause may use.
enum HintOp {
  isTrue('isTrue'),
  isPresent('isPresent'),
  eq('eq'),
  gt('gt'),
  gte('gte');

  const HintOp(this.wireValue);

  final String wireValue;

  /// `isTrue` and `isPresent` are unary; the others need an operand. Declaring
  /// this here is what lets the resolver stay total without guessing.
  bool get takesValue => this != HintOp.isTrue && this != HintOp.isPresent;

  static HintOp? fromWireValue(String value) {
    for (final HintOp op in values) {
      if (op.wireValue == value) {
        return op;
      }
    }
    return null;
  }
}

/// The CLOSED set of trailing actions a row may carry. A row without one is a
/// non-interactive row.
enum HintAction {
  shareLocation('share_location');

  const HintAction(this.wireValue);

  final String wireValue;

  static HintAction? fromWireValue(String value) {
    for (final HintAction action in values) {
      if (action.wireValue == value) {
        return action;
      }
    }
    return null;
  }
}

class HintClause {
  const HintClause({required this.field, required this.op, this.value});

  final HintFact field;
  final HintOp op;

  /// `null` for the unary operators; a `String` or a `num` otherwise.
  final Object? value;
}

class ChecklistHint implements ContentItem {
  const ChecklistHint({
    required this.id,
    required this.order,
    required this.labelVi,
    required this.icon,
    required this.when,
    this.action,
  });

  @override
  final String id;

  final int order;
  final String labelVi;
  final String icon;
  final HintAction? action;

  /// Never empty. A row shows when EVERY clause holds.
  final List<HintClause> when;
}

/// One region of the shipped alias table. Aliases arrive already normalised by
/// [normalizeRegionText], so the resolver never re-normalises the table.
class RegionEntry {
  const RegionEntry({
    required this.id,
    required this.aliases,
    required this.rainyMonths,
  });

  final String id;
  final List<String> aliases;
  final List<int> rainyMonths;
}

/// The two halves of the shipped asset: the schema-checked item package and the
/// region table that lives beside it under a root key `ContentPackage` ignores.
class BeforeYouGoPack {
  const BeforeYouGoPack({required this.hints, required this.regions});

  final ContentPackage<ChecklistHint> hints;
  final List<RegionEntry> regions;
}

BeforeYouGoPack parseBeforeYouGoPack(
  String jsonSource, {
  String source = '<memory>',
}) =>
    BeforeYouGoPack(
      hints: ContentPackage.parse<ChecklistHint>(
        jsonSource,
        expectedSchemaId: beforeYouGoSchemaId,
        itemParser: checklistHintFromJson,
        source: source,
      ),
      regions: parseBeforeYouGoRegions(jsonSource, source: source),
    );

const Set<String> _itemKeys = <String>{
  'id',
  'order',
  'labelVi',
  'icon',
  'action',
  'when',
};

const Set<String> _clauseKeys = <String>{'field', 'op', 'value'};

const Set<String> _regionKeys = <String>{'id', 'aliases', 'rainyMonths'};

ChecklistHint checklistHintFromJson(Map<String, Object?> json, String source) {
  final String id = requireContentString(json, 'id', source);
  _rejectUnknownKeys(json, _itemKeys, 'item "$id"', source);

  final List<Map<String, Object?>> rawClauses =
      requireContentObjectList(json, 'when', source);
  if (rawClauses.isEmpty) {
    throw ContentPackageFormatException(
      source,
      'item "$id" must declare at least one clause in "when"',
    );
  }

  final String? rawAction = optionalContentString(json, 'action', source);
  final HintAction? action =
      rawAction == null ? null : HintAction.fromWireValue(rawAction);
  if (rawAction != null && action == null) {
    throw ContentPackageFormatException(
      source,
      'item "$id" declares unsupported action "$rawAction"',
    );
  }

  return ChecklistHint(
    id: id,
    order: _requireContentInt(json, 'order', source),
    labelVi: requireContentString(json, 'labelVi', source),
    icon: requireContentString(json, 'icon', source),
    action: action,
    when: List<HintClause>.unmodifiable(
      <HintClause>[
        for (final Map<String, Object?> rawClause in rawClauses)
          _clauseFromJson(rawClause, id, source),
      ],
    ),
  );
}

HintClause _clauseFromJson(
  Map<String, Object?> json,
  String itemId,
  String source,
) {
  _rejectUnknownKeys(json, _clauseKeys, 'a clause of item "$itemId"', source);

  final String rawField = requireContentString(json, 'field', source);
  final HintFact? field = HintFact.fromWireValue(rawField);
  if (field == null) {
    throw ContentPackageFormatException(
      source,
      'item "$itemId" conditions on unsupported fact "$rawField"',
    );
  }

  final String rawOp = requireContentString(json, 'op', source);
  final HintOp? op = HintOp.fromWireValue(rawOp);
  if (op == null) {
    throw ContentPackageFormatException(
      source,
      'item "$itemId" uses unsupported operator "$rawOp"',
    );
  }

  final Object? value = json['value'];
  if (!op.takesValue) {
    if (json.containsKey('value')) {
      throw ContentPackageFormatException(
        source,
        'item "$itemId" gives operator "$rawOp" a value, but it takes none',
      );
    }
    return HintClause(field: field, op: op);
  }

  if (op == HintOp.eq) {
    if (value is! String && value is! num) {
      throw ContentPackageFormatException(
        source,
        'item "$itemId" must give operator "eq" a string or number value',
      );
    }
  } else if (value is! num) {
    throw ContentPackageFormatException(
      source,
      'item "$itemId" must give operator "$rawOp" a number value',
    );
  }

  return HintClause(field: field, op: op, value: value);
}

List<RegionEntry> parseBeforeYouGoRegions(
  String jsonSource, {
  String source = '<memory>',
}) {
  final Object? decoded;
  try {
    decoded = jsonDecode(jsonSource);
  } on FormatException catch (error) {
    throw ContentPackageFormatException(
      source,
      'invalid JSON: ${error.message}',
    );
  }
  if (decoded is! Map<String, Object?>) {
    throw ContentPackageFormatException(
      source,
      'expected a JSON object at the package root',
    );
  }

  final List<Map<String, Object?>> rawRegions =
      requireContentObjectList(decoded, 'regions', source);

  return List<RegionEntry>.unmodifiable(
    <RegionEntry>[
      for (final Map<String, Object?> rawRegion in rawRegions)
        _regionFromJson(rawRegion, source),
    ],
  );
}

RegionEntry _regionFromJson(Map<String, Object?> json, String source) {
  final String id = requireContentString(json, 'id', source);
  _rejectUnknownKeys(json, _regionKeys, 'region "$id"', source);

  final List<String> aliases = <String>[];
  for (final String rawAlias in requireContentStringList(
    json,
    'aliases',
    source,
  )) {
    final String alias = normalizeRegionText(rawAlias);
    if (alias.isEmpty) {
      throw ContentPackageFormatException(
        source,
        'region "$id" declares alias "$rawAlias", which normalises to nothing',
      );
    }
    aliases.add(alias);
  }
  if (aliases.isEmpty) {
    throw ContentPackageFormatException(
      source,
      'region "$id" must declare at least one alias',
    );
  }

  final Object? rawMonths = json['rainyMonths'];
  if (rawMonths is! List) {
    throw ContentPackageFormatException(
      source,
      'region "$id" must declare "rainyMonths" as a list',
    );
  }
  final List<int> rainyMonths = <int>[];
  for (final Object? rawMonth in rawMonths) {
    if (rawMonth is! int) {
      throw ContentPackageFormatException(
        source,
        'region "$id" must declare every entry of "rainyMonths" as an integer',
      );
    }
    rainyMonths.add(rawMonth);
  }

  return RegionEntry(
    id: id,
    aliases: List<String>.unmodifiable(aliases),
    rainyMonths: List<int>.unmodifiable(rainyMonths),
  );
}

int _requireContentInt(
  Map<String, Object?> json,
  String key,
  String source,
) {
  final Object? value = json[key];
  if (value is! int) {
    throw ContentPackageFormatException(
      source,
      'field "$key" must be an integer',
    );
  }
  return value;
}

void _rejectUnknownKeys(
  Map<String, Object?> json,
  Set<String> allowed,
  String subject,
  String source,
) {
  for (final String key in json.keys) {
    if (!allowed.contains(key)) {
      throw ContentPackageFormatException(
        source,
        '$subject declares unknown key "$key"',
      );
    }
  }
}

/// Folds Vietnamese text to lowercase ASCII word tokens so a free-text
/// `location` can be compared with the shipped alias table by exact token run
/// (`solution.md` §1 Key Discovery 3). Nothing here geocodes: it is string
/// folding, and a miss means the region stays unknown.
String normalizeRegionText(String raw) {
  final StringBuffer buffer = StringBuffer();
  for (final int rune in raw.toLowerCase().runes) {
    if (rune >= 0x0300 && rune <= 0x036F) {
      continue;
    }
    final String character = String.fromCharCode(rune);
    final String folded = _foldedCharacters[character] ?? character;
    if (_asciiWordCharacter.hasMatch(folded)) {
      buffer.write(folded);
    } else {
      buffer.write(' ');
    }
  }
  return buffer
      .toString()
      .split(_whitespaceRun)
      .where((String token) => token.isNotEmpty)
      .join(' ');
}

final RegExp _asciiWordCharacter = RegExp(r'^[a-z0-9]$');
final RegExp _whitespaceRun = RegExp(r'\s+');

const Map<String, String> _diacriticGroups = <String, String>{
  'a': 'àáảãạăằắẳẵặâầấẩẫậ',
  'd': 'đ',
  'e': 'èéẻẽẹêềếểễệ',
  'i': 'ìíỉĩị',
  'o': 'òóỏõọôồốổỗộơờớởỡợ',
  'u': 'ùúủũụưừứửữự',
  'y': 'ỳýỷỹỵ',
};

final Map<String, String> _foldedCharacters = <String, String>{
  for (final MapEntry<String, String> group in _diacriticGroups.entries)
    for (final int rune in group.value.runes)
      String.fromCharCode(rune): group.key,
};
