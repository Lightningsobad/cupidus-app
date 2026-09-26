import '../../../core/content/content_package.dart';

/// The three portrait package families (`architecture/contract-summary.md` §1,
/// §2). Three schema ids because the item shapes have nothing in common — a new
/// package family, not a new category of an existing pack.
const String portraitQuestionsSchemaId = 'req016.portrait_questions.v1';
const String portraitSectionsSchemaId = 'req016.portrait_sections.v1';
const String portraitAsksSchemaId = 'req016.portrait_asks.v1';

const String portraitQuestionsAssetKey =
    'assets/data/req016/portrait_questions.v1.json';
const String portraitSectionsAssetKey =
    'assets/data/req016/portrait_sections.v1.json';
const String portraitAsksAssetKey = 'assets/data/req016/portrait_asks.v1.json';

/// Where a portrait answer is written (`contract-summary.md` §2). Deliberately
/// not `AskTarget` of the context notebook: `skill` is invalid here and
/// `portrait.guess` is invalid there, and merging the two enums would open a
/// fourth destination for notebook data.
enum PortraitAnswerTarget {
  notebookInterest('notebook.interest'),
  notebookEvent('notebook.event'),
  portraitGuess('portrait.guess');

  const PortraitAnswerTarget(this.wireValue);

  final String wireValue;

  bool get writesToNotebook =>
      this == PortraitAnswerTarget.notebookInterest ||
      this == PortraitAnswerTarget.notebookEvent;

  static PortraitAnswerTarget? fromWireValue(String value) {
    for (final PortraitAnswerTarget target in values) {
      if (target.wireValue == value) {
        return target;
      }
    }
    return null;
  }
}

/// Two-layer editorial moderation trace (SB-123/BR-14/AC-31). Editorial review
/// covers tone and usability; the invariant rules are enforced by the runnable
/// gate, not by this record.
class PortraitEditorialReview {
  const PortraitEditorialReview({this.layer1, this.layer2, this.approvedAt});

  final String? layer1;
  final String? layer2;
  final String? approvedAt;
}

/// One question of the portrait questionnaire.
class PortraitQuestion implements ContentItem {
  const PortraitQuestion({
    required this.id,
    required this.prompt,
    required this.target,
    required this.chips,
    required this.allowFreeText,
    this.editorialReview,
  });

  @override
  final String id;

  /// Authored wording. Content, never l10n and never a Dart constant (BR-15).
  final String prompt;

  final PortraitAnswerTarget target;

  /// Tap-to-pick seeds, in declaration order. Never empty.
  final List<String> chips;

  final bool allowFreeText;

  final PortraitEditorialReview? editorialReview;
}

/// One clause of a portrait section. A clause whose `requires` are not all
/// bound is dropped whole (`contract-summary.md` §4), so each clause must read
/// as a complete sentence on its own.
class PortraitClause {
  const PortraitClause({required this.text, required this.requires});

  /// Authored sentence containing `{variable}` placeholders.
  final String text;

  /// Binding variable names this clause needs before it may be rendered.
  final List<String> requires;
}

/// One portrait section: a heading, the clauses it may render, and the
/// ask-the-other-person lines it ends with.
class PortraitSection implements ContentItem {
  const PortraitSection({
    required this.id,
    required this.heading,
    required this.bindings,
    required this.clauses,
    required this.askIds,
    this.editorialReview,
  });

  @override
  final String id;

  final String heading;

  /// Variable name -> question id. Clause placeholders resolve through this.
  final Map<String, String> bindings;

  final List<PortraitClause> clauses;

  /// Ids into the ask store. Never empty: every section ends with a line to
  /// ask the other person (R-1g/AC-19).
  final List<String> askIds;

  final PortraitEditorialReview? editorialReview;
}

/// One line to ask the other person, drawn from the revolving store.
class PortraitAsk implements ContentItem {
  const PortraitAsk({
    required this.id,
    required this.text,
    this.editorialReview,
  });

  @override
  final String id;

  final String text;

  final PortraitEditorialReview? editorialReview;
}

PortraitQuestion portraitQuestionFromJson(
  Map<String, Object?> json,
  String source,
) {
  final String id = requireContentString(json, 'id', source);
  final String rawTarget = requireContentString(json, 'target', source);
  final PortraitAnswerTarget? target =
      PortraitAnswerTarget.fromWireValue(rawTarget);
  if (target == null) {
    throw ContentPackageFormatException(
      source,
      'question "$id" declares unsupported target "$rawTarget"',
    );
  }

  final List<String> chips = requireContentStringList(json, 'chips', source);
  if (chips.isEmpty) {
    throw ContentPackageFormatException(
      source,
      'question "$id" must offer at least one seed chip',
    );
  }

  return PortraitQuestion(
    id: id,
    prompt: requireContentString(json, 'prompt', source),
    target: target,
    chips: List<String>.unmodifiable(chips),
    allowFreeText: _requireContentBool(json, 'allow_free_text', source),
    editorialReview: _editorialReviewFromJson(json, id, source),
  );
}

PortraitSection portraitSectionFromJson(
  Map<String, Object?> json,
  String source,
) {
  final String id = requireContentString(json, 'id', source);

  final List<PortraitClause> clauses = <PortraitClause>[
    for (final Map<String, Object?> raw
        in requireContentObjectList(json, 'clauses', source))
      PortraitClause(
        text: requireContentString(raw, 'text', source),
        requires: List<String>.unmodifiable(
          requireContentStringList(raw, 'requires', source),
        ),
      ),
  ];

  final List<String> askIds =
      requireContentStringList(json, 'ask_ids', source);
  if (askIds.isEmpty) {
    throw ContentPackageFormatException(
      source,
      'section "$id" must end with at least one line to ask',
    );
  }

  return PortraitSection(
    id: id,
    heading: requireContentString(json, 'heading', source),
    bindings: _requireContentStringMap(json, 'bindings', source),
    clauses: List<PortraitClause>.unmodifiable(clauses),
    askIds: List<String>.unmodifiable(askIds),
    editorialReview: _editorialReviewFromJson(json, id, source),
  );
}

PortraitAsk portraitAskFromJson(Map<String, Object?> json, String source) {
  final String id = requireContentString(json, 'id', source);

  return PortraitAsk(
    id: id,
    text: requireContentString(json, 'text', source),
    editorialReview: _editorialReviewFromJson(json, id, source),
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

Map<String, String> _requireContentStringMap(
  Map<String, Object?> json,
  String key,
  String source,
) {
  final Object? value = json[key];
  if (value is! Map<String, Object?>) {
    throw ContentPackageFormatException(
      source,
      'field "$key" must be a JSON object',
    );
  }
  final Map<String, String> entries = <String, String>{};
  for (final MapEntry<String, Object?> entry in value.entries) {
    final Object? target = entry.value;
    if (target is! String || target.isEmpty) {
      throw ContentPackageFormatException(
        source,
        'binding "${entry.key}" in "$key" must name a non-empty question id',
      );
    }
    entries[entry.key] = target;
  }
  return Map<String, String>.unmodifiable(entries);
}

PortraitEditorialReview? _editorialReviewFromJson(
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
  return PortraitEditorialReview(
    layer1: optionalContentString(raw, 'layer1', source),
    layer2: optionalContentString(raw, 'layer2', source),
    approvedAt: optionalContentString(raw, 'approved_at', source),
  );
}
