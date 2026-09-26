import '../../../core/content/content_package.dart';

/// The `req016.zodiac_quiz.v1` / `req016.zodiac_outcomes.v1` package family
/// (`architecture/contract-summary.md` §1-§4). A new family, not a new category
/// of `req016.presets.v1`.
///
/// The package root key is `schema_id`, the one [ContentPackage.parse] reads:
/// §1 pins reuse of that parser verbatim, so the §1 sketch's camelCase spelling
/// cannot be the wire form. The *values* below are the §2 strings, matched as
/// strings.
const String zodiacQuizAssetKey = 'assets/data/req016/zodiac_quiz.v1.json';
const String zodiacQuizSchemaId = 'req016.zodiac_quiz.v1';
const String zodiacOutcomesAssetKey =
    'assets/data/req016/zodiac_outcomes.v1.json';
const String zodiacOutcomesSchemaId = 'req016.zodiac_outcomes.v1';

/// Joins the chosen `outcome_key`s in question order into a `mapping[].key`
/// (`contract-summary.md` §3 row 7).
const String zodiacOutcomeKeySeparator = '+';

/// Keys that would turn a shell into a daily ritual (AC-18/19/20,
/// `contract-summary.md` §6). Rejected anywhere in either package, at any
/// depth, including keys the parsers deliberately ignore.
const List<String> zodiacTimeGatingKeys = <String>[
  'daily',
  'valid_from',
  'unlocks_at',
  'streak',
  'play_count',
];

/// How a set is played (`contract-summary.md` §3 row 2).
enum ZodiacSetKind {
  quiz('quiz'),
  slice('slice');

  const ZodiacSetKind(this.wireValue);

  final String wireValue;

  static ZodiacSetKind? fromWireValue(String value) {
    for (final ZodiacSetKind kind in values) {
      if (kind.wireValue == value) {
        return kind;
      }
    }
    return null;
  }
}

/// Who a question is about (`contract-summary.md` §3 row 6a). `guessAboutOther`
/// obliges the UI to label the answer as the user's own guess (AC-12); it never
/// licenses asking the user to measure the other person (AC-34), which is the
/// gate's job.
enum ZodiacQuestionSubject {
  self('self'),
  guessAboutOther('guess_about_other');

  const ZodiacQuestionSubject(this.wireValue);

  final String wireValue;

  static ZodiacQuestionSubject? fromWireValue(String value) {
    for (final ZodiacQuestionSubject subject in values) {
      if (subject.wireValue == value) {
        return subject;
      }
    }
    return null;
  }
}

/// Two-layer editorial moderation trace (`contract-summary.md` §3 row 9;
/// SB-123/AC-29).
///
/// Every layer is optional here on purpose: completeness is a gate violation,
/// so a package that forgot a layer has to survive parsing far enough for the
/// gate to name which item broke the rule.
class ZodiacEditorialReview {
  const ZodiacEditorialReview({this.layer1, this.layer2, this.approvedAt});

  final String? layer1;
  final String? layer2;
  final String? approvedAt;

  bool get isComplete =>
      layer1 != null && layer2 != null && approvedAt != null;
}

/// One answer a reader can pick (`contract-summary.md` §3 row 6b).
class ZodiacOption {
  const ZodiacOption({
    required this.id,
    required this.label,
    required this.outcomeKey,
  });

  final String id;
  final String label;

  /// The token this option contributes to a `mapping[].key`.
  final String outcomeKey;
}

/// One asked question (`contract-summary.md` §3 row 6).
class ZodiacQuestion {
  const ZodiacQuestion({
    required this.id,
    required this.prompt,
    required this.subject,
    required this.options,
  });

  final String id;
  final String prompt;
  final ZodiacQuestionSubject subject;
  final List<ZodiacOption> options;
}

/// One `outcome_key` combination and the outcome it resolves to
/// (`contract-summary.md` §3 row 7).
class ZodiacOutcomeMapping {
  const ZodiacOutcomeMapping({required this.key, required this.outcomeId});

  final String key;
  final String outcomeId;
}

/// One playable set: a slice or a quiz (`contract-summary.md` §3).
class ZodiacQuizSet implements ContentItem {
  const ZodiacQuizSet({
    required this.id,
    required this.kind,
    required this.title,
    required this.blurb,
    required this.questionsPerRound,
    required this.questions,
    required this.mapping,
    required this.fallbackOutcomeId,
    required this.declaredKeys,
    this.editorialReview,
  });

  @override
  final String id;

  final ZodiacSetKind kind;
  final String title;

  /// One or two lines on the picker card; an empty string is valid.
  final String blurb;

  final int questionsPerRound;

  /// Length is a property of the data (R-15b/AC-31). Nothing reads a seed count.
  final List<ZodiacQuestion> questions;

  final List<ZodiacOutcomeMapping> mapping;

  /// Resolves a combination no `mapping` entry covers.
  final String fallbackOutcomeId;

  /// Every JSON key this item declared, at any depth. Unknown keys are ignored
  /// by design so an out-of-repo CMS can evolve its export (§3), which would
  /// also let a time-gating key ride along unnoticed — keeping the raw key
  /// surface is what lets the gate reject one.
  final Set<String> declaredKeys;

  final ZodiacEditorialReview? editorialReview;
}

/// One suggested real-world action (`contract-summary.md` §4 rows 5a-5c).
class ZodiacSuggestion {
  const ZodiacSuggestion({
    required this.id,
    required this.title,
    required this.note,
    required this.notebookTags,
  });

  final String id;
  final String title;
  final String? note;

  /// Matched against the notebook to pick three of the pool (AC-24/AC-25).
  /// Empty is valid.
  final List<String> notebookTags;
}

/// One result surface's content (`contract-summary.md` §4).
class ZodiacOutcome implements ContentItem {
  const ZodiacOutcome({
    required this.id,
    required this.insight,
    required this.aboutOther,
    required this.askLine,
    required this.suggestions,
    required this.declaredKeys,
    this.editorialReview,
  });

  @override
  final String id;

  final String insight;

  /// `true` turns on the "câu để hỏi" block and obliges [askLine] (AC-15).
  final bool aboutOther;

  final String? askLine;

  /// A pool of at least three; the app renders exactly three of them (BR-2).
  /// The three is a layout contract, not this package's N (BR-13).
  final List<ZodiacSuggestion> suggestions;

  /// See [ZodiacQuizSet.declaredKeys].
  final Set<String> declaredKeys;

  final ZodiacEditorialReview? editorialReview;
}

/// Collects every JSON key in [node] and everything nested under it.
Set<String> collectJsonKeys(Object? node) {
  final Set<String> keys = <String>{};
  if (node is Map<String, Object?>) {
    for (final MapEntry<String, Object?> entry in node.entries) {
      keys.add(entry.key);
      keys.addAll(collectJsonKeys(entry.value));
    }
  } else if (node is List) {
    for (final Object? entry in node) {
      keys.addAll(collectJsonKeys(entry));
    }
  }
  return keys;
}

/// [ContentItemParser] for the `req016.zodiac_quiz.v1` schema.
///
/// This layer rejects wire shapes with no valid reading at all: a missing
/// mandatory field, an unknown `kind` or `subject`, a set with no question, a
/// question with no option. Rules that read a *well-formed* item — the range of
/// `questions_per_round`, the wording of a prompt, whether a `mapping` target
/// exists — belong to the gate, so they also cover a package a future CMS
/// importer builds in memory without passing through this parser (R-15c).
ZodiacQuizSet zodiacQuizSetFromJson(Map<String, Object?> json, String source) {
  final String id = requireContentString(json, 'id', source);

  final String rawKind = requireContentString(json, 'kind', source);
  final ZodiacSetKind? kind = ZodiacSetKind.fromWireValue(rawKind);
  if (kind == null) {
    throw ContentPackageFormatException(
      source,
      'set "$id" declares unknown kind "$rawKind"',
    );
  }

  final List<Map<String, Object?>> rawQuestions = requireContentObjectList(
    json,
    'questions',
    source,
  );
  if (rawQuestions.isEmpty) {
    throw ContentPackageFormatException(
      source,
      'set "$id" must declare at least one question',
    );
  }

  return ZodiacQuizSet(
    id: id,
    kind: kind,
    title: requireContentString(json, 'title', source),
    blurb: _requireContentPossiblyEmptyString(json, 'blurb', source),
    questionsPerRound: _requireContentInt(json, 'questions_per_round', source),
    questions: List<ZodiacQuestion>.unmodifiable(<ZodiacQuestion>[
      for (final Map<String, Object?> rawQuestion in rawQuestions)
        _questionFromJson(rawQuestion, id, source),
    ]),
    mapping: List<ZodiacOutcomeMapping>.unmodifiable(<ZodiacOutcomeMapping>[
      for (final Map<String, Object?> rawEntry
          in requireContentObjectList(json, 'mapping', source))
        ZodiacOutcomeMapping(
          key: requireContentString(rawEntry, 'key', source),
          outcomeId: requireContentString(rawEntry, 'outcome_id', source),
        ),
    ]),
    fallbackOutcomeId:
        requireContentString(json, 'fallback_outcome_id', source),
    declaredKeys: Set<String>.unmodifiable(collectJsonKeys(json)),
    editorialReview: _editorialReviewFromJson(json, id, source),
  );
}

/// [ContentItemParser] for the `req016.zodiac_outcomes.v1` schema.
///
/// `ask_line` stays optional here even when `about_other` is `true`: that pair
/// is the AC-15 rule, and the gate has to be the one to name the outcome that
/// broke it.
ZodiacOutcome zodiacOutcomeFromJson(Map<String, Object?> json, String source) {
  final String id = requireContentString(json, 'id', source);

  return ZodiacOutcome(
    id: id,
    insight: requireContentString(json, 'insight', source),
    aboutOther: _requireContentBool(json, 'about_other', source),
    askLine: optionalContentString(json, 'ask_line', source),
    suggestions: List<ZodiacSuggestion>.unmodifiable(<ZodiacSuggestion>[
      for (final Map<String, Object?> rawSuggestion
          in requireContentObjectList(json, 'suggestions', source))
        ZodiacSuggestion(
          id: requireContentString(rawSuggestion, 'id', source),
          title: requireContentString(rawSuggestion, 'title', source),
          note: optionalContentString(rawSuggestion, 'note', source),
          notebookTags: List<String>.unmodifiable(
            requireContentStringList(rawSuggestion, 'notebook_tags', source),
          ),
        ),
    ]),
    declaredKeys: Set<String>.unmodifiable(collectJsonKeys(json)),
    editorialReview: _editorialReviewFromJson(json, id, source),
  );
}

ZodiacQuestion _questionFromJson(
  Map<String, Object?> json,
  String setId,
  String source,
) {
  final String id = requireContentString(json, 'id', source);

  final String rawSubject = requireContentString(json, 'subject', source);
  final ZodiacQuestionSubject? subject =
      ZodiacQuestionSubject.fromWireValue(rawSubject);
  if (subject == null) {
    throw ContentPackageFormatException(
      source,
      'set "$setId" question "$id" declares unknown subject "$rawSubject"',
    );
  }

  final List<Map<String, Object?>> rawOptions = requireContentObjectList(
    json,
    'options',
    source,
  );
  if (rawOptions.isEmpty) {
    throw ContentPackageFormatException(
      source,
      'set "$setId" question "$id" must declare at least one option',
    );
  }

  return ZodiacQuestion(
    id: id,
    prompt: requireContentString(json, 'prompt', source),
    subject: subject,
    options: List<ZodiacOption>.unmodifiable(<ZodiacOption>[
      for (final Map<String, Object?> rawOption in rawOptions)
        ZodiacOption(
          id: requireContentString(rawOption, 'id', source),
          label: requireContentString(rawOption, 'label', source),
          outcomeKey: requireContentString(rawOption, 'outcome_key', source),
        ),
    ]),
  );
}

ZodiacEditorialReview? _editorialReviewFromJson(
  Map<String, Object?> json,
  String itemId,
  String source,
) {
  final Object? raw = json['editorial_review'];
  if (raw == null) {
    return null;
  }
  if (raw is! Map<String, Object?>) {
    throw ContentPackageFormatException(
      source,
      'item "$itemId" declares "editorial_review" as something other than a '
      'JSON object',
    );
  }
  return ZodiacEditorialReview(
    layer1: optionalContentString(raw, 'layer1', source),
    layer2: optionalContentString(raw, 'layer2', source),
    approvedAt: optionalContentString(raw, 'approved_at', source),
  );
}

String _requireContentPossiblyEmptyString(
  Map<String, Object?> json,
  String key,
  String source,
) {
  final Object? value = json[key];
  if (value is! String) {
    throw ContentPackageFormatException(
      source,
      'field "$key" must be a string',
    );
  }
  return value;
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
