import '../../../core/content/content_package.dart';

/// The two context-notebook package families
/// (`architecture/contract-summary.md` §1, §2). Separate schema ids because the
/// item shapes have nothing in common — this is a new package family, not a new
/// category of `req016.presets.v1`.
const String askQuestionsSchemaId = 'req016.ask_questions.v1';
const String skillSeedsSchemaId = 'req016.skill_seeds.v1';

const String askQuestionsAssetKey = 'assets/data/req016/ask_questions.v1.json';
const String skillSeedsAssetKey = 'assets/data/req016/skill_seeds.v1.json';

/// The everyday soft skills the seed set must offer before the user has to type
/// anything (AC-11/BR-5). These are stable ids, not labels: the wording lives in
/// the package, the requirement lives here.
const List<String> requiredSkillSeedIds = <String>[
  'skill.nho_dai.v1',
  'skill.biet_cho_an_ngon.v1',
  'skill.goi_qua_dep.v1',
  'skill.chon_nhac_hop_canh.v1',
];

/// Where a question's answer is written (`contract-summary.md` §2). A closed
/// set of three: an unknown value is a parse error, never a default, so a CMS
/// cannot invent a fourth destination for notebook data.
enum AskTarget {
  notebookInterest('notebook.interest'),
  notebookEvent('notebook.event'),
  skill('skill');

  const AskTarget(this.wireValue);

  final String wireValue;

  static AskTarget? fromWireValue(String value) {
    for (final AskTarget target in values) {
      if (target.wireValue == value) {
        return target;
      }
    }
    return null;
  }
}

/// Two-layer editorial moderation trace (SB-123/BR-14). Editorial review covers
/// tone and usability; the invariant rules are enforced by the runnable gate,
/// not by this record.
class ContextEditorialReview {
  const ContextEditorialReview({this.layer1, this.layer2, this.approvedAt});

  final String? layer1;
  final String? layer2;
  final String? approvedAt;
}

/// One ask-on-the-spot question.
class AskQuestion implements ContentItem {
  const AskQuestion({
    required this.id,
    required this.prompt,
    required this.target,
    required this.chips,
    required this.allowFreeText,
    this.editorialReview,
  });

  @override
  final String id;

  /// Authored wording. Content, never l10n and never a Dart constant (BR-16).
  final String prompt;

  final AskTarget target;

  /// Tap-to-pick seeds, in declaration order. Never empty: a question with no
  /// seeds is the blank "your skills are?" box AC-10 forbids.
  final List<String> chips;

  final bool allowFreeText;

  final ContextEditorialReview? editorialReview;
}

/// One skill seed chip.
///
/// There is deliberately no group, tier, level, or proficiency field. Display
/// order is declaration order, so no consumer can render a dimmed "lesser"
/// sub-group of skills (AC-11/AC-12/BR-5).
class SkillSeed implements ContentItem {
  const SkillSeed({
    required this.id,
    required this.label,
    this.editorialReview,
  });

  @override
  final String id;

  final String label;

  final ContextEditorialReview? editorialReview;
}

AskQuestion askQuestionFromJson(Map<String, Object?> json, String source) {
  final String id = requireContentString(json, 'id', source);
  final String rawTarget = requireContentString(json, 'target', source);
  final AskTarget? target = AskTarget.fromWireValue(rawTarget);
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

  return AskQuestion(
    id: id,
    prompt: requireContentString(json, 'prompt', source),
    target: target,
    chips: List<String>.unmodifiable(chips),
    allowFreeText: _requireContentBool(json, 'allow_free_text', source),
    editorialReview: _editorialReviewFromJson(json, id, source),
  );
}

SkillSeed skillSeedFromJson(Map<String, Object?> json, String source) {
  final String id = requireContentString(json, 'id', source);

  return SkillSeed(
    id: id,
    label: requireContentString(json, 'label', source),
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

ContextEditorialReview? _editorialReviewFromJson(
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
  return ContextEditorialReview(
    layer1: optionalContentString(raw, 'layer1', source),
    layer2: optionalContentString(raw, 'layer2', source),
    approvedAt: optionalContentString(raw, 'approved_at', source),
  );
}
