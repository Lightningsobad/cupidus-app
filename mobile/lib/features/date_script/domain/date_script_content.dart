import '../../../core/content/content_package.dart';
import '../../activity_cards/domain/activity_type.dart';

/// The `req016.date_script.v1` package family (`architecture/contract-summary.md`
/// §1). A new family, not a new category of `req016.presets.v1`.
const String dateScriptAssetKey = 'assets/data/req016/date_script.v1.json';
const String dateScriptSchemaId = 'req016.date_script.v1';

/// The three parts of a date script (`contract-summary.md` §2). A closed set of
/// exactly three, and declaration order here *is* the contractual order every
/// preset must follow.
enum DateScriptPart {
  before('before'),
  during('during'),
  after('after');

  const DateScriptPart(this.wireValue);

  final String wireValue;

  static DateScriptPart? fromWireValue(String value) {
    for (final DateScriptPart part in values) {
      if (part.wireValue == value) {
        return part;
      }
    }
    return null;
  }
}

/// The closed set of mad-libs variables for this family
/// (`contract-summary.md` §2). Exactly seven: five read off the card, plus
/// `interest` and `event` read from the notebook. Near-misses that authors
/// reach for — `activityType`, `place_name`, `durationMinutes`, `interests`,
/// `partner_interest` — are deliberately absent, so a pack using one fails at
/// load instead of rendering a literal brace (AC-10/AC-37).
enum DateScriptVariable {
  activity('activity'),
  date('date'),
  time('time'),
  place('place'),
  duration('duration'),
  interest('interest'),
  event('event');

  const DateScriptVariable(this.wireValue);

  final String wireValue;

  static DateScriptVariable? fromWireValue(String value) {
    for (final DateScriptVariable variable in values) {
      if (variable.wireValue == value) {
        return variable;
      }
    }
    return null;
  }
}

/// Any brace-delimited token, not just the seven known names.
final RegExp dateScriptPlaceholderPattern = RegExp(r'\{([^{}]*)\}');

/// One authored sentence (`contract-summary.md` §3, rows 5-7).
class DateScriptSentence {
  const DateScriptSentence({
    required this.text,
    required this.requires,
    required this.aboutPartner,
  });

  /// Verbatim authored text, placeholders included. The content side owns the
  /// wording and the punctuation; the engine only joins surviving sentences.
  final String text;

  /// Variables that must all be present, or the whole sentence is dropped
  /// (AC-10). An empty list makes the sentence unconditional.
  final List<DateScriptVariable> requires;

  /// Per sentence, never per part. `true` obliges the text to end in `?`
  /// (R-1g/AC-26), which the gate enforces.
  final bool aboutPartner;
}

/// One of the three segments of a script.
class DateScriptPartContent {
  const DateScriptPartContent({required this.part, required this.sentences});

  final DateScriptPart part;

  /// Declaration order is render order.
  final List<DateScriptSentence> sentences;
}

/// Two-layer editorial moderation trace (`contract-summary.md` §3 row 8;
/// SB-123/BR-13).
///
/// Every layer is optional *here* on purpose: completeness is a gate violation
/// (AC-31), so a pack that forgot a layer has to survive parsing far enough for
/// the gate to name which preset broke the rule.
class DateScriptEditorialReview {
  const DateScriptEditorialReview({this.layer1, this.layer2, this.approvedAt});

  final String? layer1;
  final String? layer2;
  final String? approvedAt;
}

/// One authored three-part script (`contract-summary.md` §3).
class DateScriptPreset implements ContentItem {
  const DateScriptPreset({
    required this.id,
    required this.activityTypes,
    required this.parts,
    this.editorialReview,
  });

  @override
  final String id;

  /// Empty means the preset is the generic fallback. A pack without at least
  /// one generic preset cannot serve a card whose type it does not cover, which
  /// is why the gate rejects it (AC-34).
  final List<ActivityType> activityTypes;

  final List<DateScriptPartContent> parts;

  final DateScriptEditorialReview? editorialReview;
}

/// [ContentItemParser] for the `req016.date_script.v1` schema.
///
/// This layer rejects wire shapes that have no valid reading at all: an unknown
/// variable name, an unknown part name, a missing part, parts out of order. It
/// deliberately does *not* check that every `{var}` appears in `requires` — that
/// rule reads a well-formed sentence and belongs to `validateDateScriptPack`,
/// so it also covers a package an out-of-repo CMS builds in memory rather than
/// through this parser (R-15c).
DateScriptPreset dateScriptPresetFromJson(
  Map<String, Object?> json,
  String source,
) {
  final String id = requireContentString(json, 'id', source);

  final List<ActivityType> activityTypes = <ActivityType>[];
  for (final String name in requireContentStringList(
    json,
    'activityTypes',
    source,
  )) {
    final ActivityType? type = activityTypeFromWireValue(name);
    if (type == null) {
      throw ContentPackageFormatException(
        source,
        'preset "$id" declares unknown activity type "$name"',
      );
    }
    activityTypes.add(type);
  }

  final List<Map<String, Object?>> rawParts = requireContentObjectList(
    json,
    'parts',
    source,
  );
  if (rawParts.length != DateScriptPart.values.length) {
    throw ContentPackageFormatException(
      source,
      'preset "$id" must declare exactly ${DateScriptPart.values.length} '
      'parts, found ${rawParts.length}',
    );
  }

  final List<DateScriptPartContent> parts = <DateScriptPartContent>[];
  for (int index = 0; index < rawParts.length; index++) {
    final Map<String, Object?> rawPart = rawParts[index];
    final String rawName = requireContentString(rawPart, 'part', source);
    final DateScriptPart? part = DateScriptPart.fromWireValue(rawName);
    if (part == null) {
      throw ContentPackageFormatException(
        source,
        'preset "$id" declares unknown part "$rawName"',
      );
    }
    if (part != DateScriptPart.values[index]) {
      throw ContentPackageFormatException(
        source,
        'preset "$id" declares part "$rawName" at position $index; the order is '
        'fixed to ${DateScriptPart.values.map((DateScriptPart value) => value.wireValue).join(', ')}',
      );
    }

    final List<Map<String, Object?>> rawSentences = requireContentObjectList(
      rawPart,
      'sentences',
      source,
    );
    if (rawSentences.isEmpty) {
      throw ContentPackageFormatException(
        source,
        'preset "$id" part "$rawName" must declare at least one sentence',
      );
    }

    parts.add(
      DateScriptPartContent(
        part: part,
        sentences: List<DateScriptSentence>.unmodifiable(<DateScriptSentence>[
          for (final Map<String, Object?> rawSentence in rawSentences)
            _sentenceFromJson(rawSentence, id, source),
        ]),
      ),
    );
  }

  return DateScriptPreset(
    id: id,
    activityTypes: List<ActivityType>.unmodifiable(activityTypes),
    parts: List<DateScriptPartContent>.unmodifiable(parts),
    editorialReview: _editorialReviewFromJson(json, id, source),
  );
}

DateScriptSentence _sentenceFromJson(
  Map<String, Object?> json,
  String presetId,
  String source,
) {
  final String text = requireContentString(json, 'text', source);

  final List<DateScriptVariable> requires = <DateScriptVariable>[];
  for (final String name in requireContentStringList(
    json,
    'requires',
    source,
  )) {
    final DateScriptVariable? variable = DateScriptVariable.fromWireValue(name);
    if (variable == null) {
      throw ContentPackageFormatException(
        source,
        'preset "$presetId" requires unknown mad-libs variable "$name"',
      );
    }
    requires.add(variable);
  }

  for (final RegExpMatch match
      in dateScriptPlaceholderPattern.allMatches(text)) {
    if (DateScriptVariable.fromWireValue(match.group(1)!) == null) {
      throw ContentPackageFormatException(
        source,
        'preset "$presetId" uses unknown placeholder "${match.group(0)}"',
      );
    }
  }

  return DateScriptSentence(
    text: text,
    requires: List<DateScriptVariable>.unmodifiable(requires),
    aboutPartner: _requireContentBool(json, 'aboutPartner', source),
  );
}

DateScriptEditorialReview? _editorialReviewFromJson(
  Map<String, Object?> json,
  String presetId,
  String source,
) {
  final Object? raw = json['editorial_review'];
  if (raw == null) {
    return null;
  }
  if (raw is! Map<String, Object?>) {
    throw ContentPackageFormatException(
      source,
      'preset "$presetId" declares "editorial_review" as something other than '
      'a JSON object',
    );
  }
  return DateScriptEditorialReview(
    layer1: optionalContentString(raw, 'layer1', source),
    layer2: optionalContentString(raw, 'layer2', source),
    approvedAt: optionalContentString(raw, 'approved_at', source),
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
