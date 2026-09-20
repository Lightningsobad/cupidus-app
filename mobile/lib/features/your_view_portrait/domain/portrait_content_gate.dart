import '../../../core/content/content_package.dart';
import '../../../core/content/invariant_terms.dart';
import 'portrait_content.dart';

/// The only sentence openings a portrait clause may use (AC-13/BR-4). These
/// live in Dart and never in a pack: the voice of the portrait is a rule, not
/// content, so an out-of-repo CMS cannot relax the voice it is measured against
/// (R-15c).
const List<String> portraitLegalOpeningFrames = <String>[
  'Theo cách bạn kể',
  'Bạn đang thấy',
  'Bạn kể rằng',
  'Theo cách bạn nhìn',
];

/// The `version` every shipped portrait pack must declare.
final RegExp _packVersionPattern = RegExp(r'^\d+\.\d+\.\d+$');

/// What a portrait pack can break. The first seven pair by wire value with
/// [InvariantRule] and the next three with [NotebookBoundaryRule], so the rules
/// themselves stay in `core/content/invariant_terms.dart` and this enum only
/// names them (D-15). The rest are this family only.
enum PortraitGateRule {
  flattery('flattery'),
  percentDisplay('percent_display'),
  streakDisplay('streak_display'),
  scoreOrRatio('score_or_ratio'),
  recipientBehaviour('recipient_behaviour'),
  manipulativeTone('manipulative_tone'),
  assertiveClaim('assertive_claim'),
  frequencyProbe('frequency_probe'),
  behaviourProbe('behaviour_probe'),
  judgementProbe('judgement_probe'),
  missingChip('missing_chip'),
  sectionWithoutAsk('section_without_ask'),
  unknownAskId('unknown_ask_id'),
  unknownBindingQuestion('unknown_binding_question'),
  unboundRequiresVariable('unbound_requires_variable'),
  askNotAQuestion('ask_not_a_question'),
  illegalOpeningFrame('illegal_opening_frame'),
  duplicateItemId('duplicate_item_id'),
  unexpectedSchemaId('unexpected_schema_id'),
  malformedVersion('malformed_version');

  const PortraitGateRule(this.wireValue);

  final String wireValue;
}

class PortraitViolation {
  const PortraitViolation({
    required this.packageId,
    required this.itemId,
    required this.rule,
    required this.detail,
  });

  final String packageId;
  final String itemId;
  final PortraitGateRule rule;
  final String detail;

  @override
  String toString() => '$packageId/$itemId [${rule.wireValue}]: $detail';
}

/// Runs every invariant rule over the three portrait packs and returns what
/// they broke. An empty list is the only shippable result: the test that calls
/// this scans `assets/data/req016/` from disk, so a violating pack turns the
/// build red rather than reaching a reader (AC-36/AC-37/BR-17).
List<PortraitViolation> validatePortraitPacks({
  required ContentPackage<PortraitQuestion> questions,
  required ContentPackage<PortraitSection> sections,
  required ContentPackage<PortraitAsk> asks,
}) {
  final List<PortraitViolation> violations = <PortraitViolation>[];

  violations.addAll(
    _envelopeViolations(
      questions.id,
      questions.schemaId,
      questions.version,
      portraitQuestionsSchemaId,
      questions.items.map((PortraitQuestion q) => q.id),
    ),
  );
  violations.addAll(
    _envelopeViolations(
      sections.id,
      sections.schemaId,
      sections.version,
      portraitSectionsSchemaId,
      sections.items.map((PortraitSection s) => s.id),
    ),
  );
  violations.addAll(
    _envelopeViolations(
      asks.id,
      asks.schemaId,
      asks.version,
      portraitAsksSchemaId,
      asks.items.map((PortraitAsk a) => a.id),
    ),
  );

  for (final PortraitQuestion question in questions.items) {
    for (final String text in <String>[question.prompt, ...question.chips]) {
      violations.addAll(
        _invariantViolations(questions.id, question.id, text),
      );
      if (!question.target.writesToNotebook) {
        continue;
      }
      for (final NotebookBoundaryHit hit in notebookBoundaryHitsIn(text)) {
        violations.add(
          PortraitViolation(
            packageId: questions.id,
            itemId: question.id,
            rule: _portraitRuleFor(hit.rule.wireValue),
            detail: hit.detail,
          ),
        );
      }
    }

    if (question.chips.isEmpty) {
      violations.add(
        PortraitViolation(
          packageId: questions.id,
          itemId: question.id,
          rule: PortraitGateRule.missingChip,
          detail: 'every question must offer at least one seed chip',
        ),
      );
    }
  }

  for (final PortraitAsk ask in asks.items) {
    violations.addAll(_invariantViolations(asks.id, ask.id, ask.text));
    if (!ask.text.trimRight().endsWith('?')) {
      violations.add(
        PortraitViolation(
          packageId: asks.id,
          itemId: ask.id,
          rule: PortraitGateRule.askNotAQuestion,
          detail: 'a line to ask must end with "?"',
        ),
      );
    }
  }

  for (final PortraitSection section in sections.items) {
    violations.addAll(
      _invariantViolations(sections.id, section.id, section.heading),
    );

    for (final PortraitClause clause in section.clauses) {
      violations.addAll(
        _invariantViolations(sections.id, section.id, clause.text),
      );

      // Every clause, not only the declared first one: a clause whose bindings
      // are unmet is dropped whole, so any clause can end up opening the
      // section at render time.
      if (!portraitLegalOpeningFrames
          .any((String frame) => clause.text.startsWith(frame))) {
        violations.add(
          PortraitViolation(
            packageId: sections.id,
            itemId: section.id,
            rule: PortraitGateRule.illegalOpeningFrame,
            detail: 'clause "${clause.text}" does not open with one of the '
                'legal frames',
          ),
        );
      }

      for (final String variable in clause.requires) {
        if (!section.bindings.containsKey(variable)) {
          violations.add(
            PortraitViolation(
              packageId: sections.id,
              itemId: section.id,
              rule: PortraitGateRule.unboundRequiresVariable,
              detail: 'clause requires "$variable", which no binding declares',
            ),
          );
        }
      }
    }

    for (final MapEntry<String, String> binding in section.bindings.entries) {
      if (questions.itemById(binding.value) == null) {
        violations.add(
          PortraitViolation(
            packageId: sections.id,
            itemId: section.id,
            rule: PortraitGateRule.unknownBindingQuestion,
            detail: 'binding "${binding.key}" points at unknown question '
                '"${binding.value}"',
          ),
        );
      }
    }

    if (section.askIds.isEmpty) {
      violations.add(
        PortraitViolation(
          packageId: sections.id,
          itemId: section.id,
          rule: PortraitGateRule.sectionWithoutAsk,
          detail: 'every section must end with a line to ask (R-1g/AC-19)',
        ),
      );
    }

    for (final String askId in section.askIds) {
      if (asks.itemById(askId) == null) {
        violations.add(
          PortraitViolation(
            packageId: sections.id,
            itemId: section.id,
            rule: PortraitGateRule.unknownAskId,
            detail: 'ask_id "$askId" is not in the ask store',
          ),
        );
      }
    }
  }

  return List<PortraitViolation>.unmodifiable(violations);
}

Iterable<PortraitViolation> _envelopeViolations(
  String packageId,
  String schemaId,
  String version,
  String expectedSchemaId,
  Iterable<String> itemIds,
) sync* {
  if (schemaId != expectedSchemaId) {
    yield PortraitViolation(
      packageId: packageId,
      itemId: packageId,
      rule: PortraitGateRule.unexpectedSchemaId,
      detail: 'schema_id "$schemaId" is not "$expectedSchemaId"',
    );
  }
  if (!_packVersionPattern.hasMatch(version)) {
    yield PortraitViolation(
      packageId: packageId,
      itemId: packageId,
      rule: PortraitGateRule.malformedVersion,
      detail: 'version "$version" is not a three-part version',
    );
  }

  final Set<String> seen = <String>{};
  for (final String id in itemIds) {
    if (!seen.add(id)) {
      yield PortraitViolation(
        packageId: packageId,
        itemId: id,
        rule: PortraitGateRule.duplicateItemId,
        detail: 'item id "$id" appears more than once',
      );
    }
  }
}

Iterable<PortraitViolation> _invariantViolations(
  String packageId,
  String itemId,
  String text,
) sync* {
  for (final InvariantTermHit hit in invariantHitsIn(text)) {
    yield PortraitViolation(
      packageId: packageId,
      itemId: itemId,
      rule: _portraitRuleFor(hit.rule.wireValue),
      detail: hit.detail,
    );
  }
}

PortraitGateRule _portraitRuleFor(String wireValue) => PortraitGateRule.values
    .firstWhere((PortraitGateRule rule) => rule.wireValue == wireValue);
