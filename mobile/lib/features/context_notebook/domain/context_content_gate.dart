import '../../../core/content/content_package.dart';
import '../../../core/content/invariant_terms.dart';
import 'checkin_capture_content.dart';
import 'context_content.dart';

/// What a context-notebook pack can break. The first seven pair by wire value
/// with [InvariantRule] and the next three with [NotebookBoundaryRule], so the
/// rules themselves stay in `core/content/invariant_terms.dart` and this enum
/// only names them (D-15).
enum ContextGateRule {
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
  missingRequiredSkillSeed('missing_required_skill_seed');

  const ContextGateRule(this.wireValue);

  final String wireValue;
}

class ContextViolation {
  const ContextViolation({
    required this.packageId,
    required this.itemId,
    required this.rule,
    required this.detail,
  });

  final String packageId;
  final String itemId;
  final ContextGateRule rule;
  final String detail;

  @override
  String toString() => '$packageId/$itemId [${rule.wireValue}]: $detail';
}

/// Runs every invariant rule over all three context packs and returns what they
/// broke. An empty list is the only shippable result: the test that calls this
/// scans `assets/data/req016/` and `assets/data/req017/` from disk, so a
/// violating pack turns the build red rather than reaching a reader
/// (AC-35/AC-36/BR-18, REQ-017 AC-14).
List<ContextViolation> validateContextPacks({
  required ContentPackage<AskQuestion> askQuestions,
  required ContentPackage<SkillSeed> skillSeeds,
  required ContentPackage<CheckinCaptureCopy> checkinCapture,
}) {
  final List<ContextViolation> violations = <ContextViolation>[];

  for (final AskQuestion question in askQuestions.items) {
    for (final String text in <String>[question.prompt, ...question.chips]) {
      violations.addAll(
        _invariantViolations(askQuestions.id, question.id, text),
      );
      for (final NotebookBoundaryHit hit in notebookBoundaryHitsIn(text)) {
        violations.add(
          ContextViolation(
            packageId: askQuestions.id,
            itemId: question.id,
            rule: _contextRuleFor(hit.rule.wireValue),
            detail: hit.detail,
          ),
        );
      }
    }
  }

  for (final SkillSeed seed in skillSeeds.items) {
    violations.addAll(
      _invariantViolations(skillSeeds.id, seed.id, seed.label),
    );
  }

  for (final CheckinCaptureCopy copy in checkinCapture.items) {
    violations.addAll(
      _invariantViolations(checkinCapture.id, copy.id, copy.text),
    );
    for (final NotebookBoundaryHit hit in notebookBoundaryHitsIn(copy.text)) {
      violations.add(
        ContextViolation(
          packageId: checkinCapture.id,
          itemId: copy.id,
          rule: _contextRuleFor(hit.rule.wireValue),
          detail: hit.detail,
        ),
      );
    }
  }

  for (final String requiredId in requiredSkillSeedIds) {
    if (skillSeeds.itemById(requiredId) == null) {
      violations.add(
        ContextViolation(
          packageId: skillSeeds.id,
          itemId: requiredId,
          rule: ContextGateRule.missingRequiredSkillSeed,
          detail: 'the seed set must offer this everyday soft skill before the '
              'user has to type anything',
        ),
      );
    }
  }

  return List<ContextViolation>.unmodifiable(violations);
}

Iterable<ContextViolation> _invariantViolations(
  String packageId,
  String itemId,
  String text,
) sync* {
  for (final InvariantTermHit hit in invariantHitsIn(text)) {
    yield ContextViolation(
      packageId: packageId,
      itemId: itemId,
      rule: _contextRuleFor(hit.rule.wireValue),
      detail: hit.detail,
    );
  }
}

ContextGateRule _contextRuleFor(String wireValue) => ContextGateRule.values
    .firstWhere((ContextGateRule rule) => rule.wireValue == wireValue);
