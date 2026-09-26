import '../../../core/content/content_package.dart';
import '../../../core/content/invariant_terms.dart';
import 'zodiac_shell_content.dart';

/// What a zodiac shell package pair can break
/// (`architecture/contract-summary.md` §3-§6, AC-33/AC-34).
///
/// The first block is structural and owned by this story. The rest pair by wire
/// value with [InvariantRule], [NotebookBoundaryRule], and
/// [StarterStructureRule], so the lexical layer stays a delegation to
/// `core/content/invariant_terms.dart` and this file never becomes a second
/// denylist (R-15c/D-15). Every member of those three enums is mirrored here:
/// the mapping is a `firstWhere` with no `orElse`, so a missing one would be a
/// runtime `StateError` rather than a missed violation.
enum ZodiacGateRule {
  timeGatingKey('time_gating_key'),
  questionsPerRoundOutOfRange('questions_per_round_out_of_range'),
  outcomeReferenceMissing('outcome_reference_missing'),
  askLineMissing('ask_line_missing'),
  askLineWithoutAboutOther('ask_line_without_about_other'),
  suggestionPoolTooSmall('suggestion_pool_too_small'),
  editorialReviewIncomplete('editorial_review_incomplete'),
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
  missingQuestionEnding('missing_question_ending');

  const ZodiacGateRule(this.wireValue);

  final String wireValue;
}

class ZodiacViolation {
  const ZodiacViolation({
    required this.packageId,
    required this.itemId,
    required this.rule,
    required this.detail,
  });

  final String packageId;

  /// `null` for a rule the whole package breaks rather than one item.
  final String? itemId;

  final ZodiacGateRule rule;
  final String detail;

  @override
  String toString() =>
      '$packageId/${itemId ?? '<package>'} [${rule.wireValue}]: $detail';
}

/// Thrown by [assertZodiacPacksClean]. A violating package must fail the build,
/// not the reader (`contract-summary.md` §5).
class ZodiacContentGateException implements Exception {
  const ZodiacContentGateException(this.violations);

  final List<ZodiacViolation> violations;

  @override
  String toString() =>
      'ZodiacContentGateException:\n${violations.join('\n')}';
}

/// The layout contract of the result surface (BR-2/AC-4): three suggestion
/// cards render, so an outcome has to offer at least three to choose from.
///
/// This is the one number the packages are measured against, and it is a
/// property of the *screen*, never of a package (BR-13). No item count is
/// written down anywhere: those all read [ContentPackage.length].
const int minimumSuggestionsPerOutcome = 3;

/// Runs every invariant rule over a loaded package pair and returns what they
/// broke. An empty list is the only shippable result.
List<ZodiacViolation> validateZodiacPacks({
  required ContentPackage<ZodiacQuizSet> quiz,
  required ContentPackage<ZodiacOutcome> outcomes,
}) {
  final List<ZodiacViolation> violations = <ZodiacViolation>[];
  final Set<String> outcomeIds = <String>{
    for (final ZodiacOutcome outcome in outcomes.items) outcome.id,
  };

  for (final ZodiacQuizSet set in quiz.items) {
    ZodiacViolation violation(ZodiacGateRule rule, String detail) =>
        ZodiacViolation(
          packageId: quiz.id,
          itemId: set.id,
          rule: rule,
          detail: detail,
        );

    violations.addAll(
      _timeGatingViolations(set.declaredKeys, violation),
    );

    if (set.questionsPerRound < 1 ||
        set.questionsPerRound > set.questions.length) {
      violations.add(
        violation(
          ZodiacGateRule.questionsPerRoundOutOfRange,
          '"questions_per_round" is ${set.questionsPerRound}, outside 1..'
          '${set.questions.length}',
        ),
      );
    }

    for (final ZodiacQuestion question in set.questions) {
      // A prompt is both a thing the reader sees and the one place a package
      // can turn the app into a tracker of the other person, so it is measured
      // against the display rules *and* the notebook boundary (AC-33/AC-34).
      for (final InvariantTermHit hit in invariantHitsIn(question.prompt)) {
        violations.add(
          violation(
            _displayRuleFor(hit.rule),
            'question "${question.id}": ${hit.detail}',
          ),
        );
      }
      for (final NotebookBoundaryHit hit
          in notebookBoundaryHitsIn(question.prompt)) {
        violations.add(
          violation(
            _notebookRuleFor(hit.rule),
            'question "${question.id}": ${hit.detail}',
          ),
        );
      }
    }

    for (final ZodiacOutcomeMapping entry in set.mapping) {
      if (!outcomeIds.contains(entry.outcomeId)) {
        violations.add(
          violation(
            ZodiacGateRule.outcomeReferenceMissing,
            'mapping key "${entry.key}" points at "${entry.outcomeId}", which '
            'the outcomes package does not declare',
          ),
        );
      }
    }
    if (!outcomeIds.contains(set.fallbackOutcomeId)) {
      violations.add(
        violation(
          ZodiacGateRule.outcomeReferenceMissing,
          '"fallback_outcome_id" is "${set.fallbackOutcomeId}", which the '
          'outcomes package does not declare',
        ),
      );
    }

    if (set.editorialReview?.isComplete != true) {
      violations.add(
        violation(
          ZodiacGateRule.editorialReviewIncomplete,
          'editorial_review must record layer1, layer2, and approved_at',
        ),
      );
    }
  }

  for (final ZodiacOutcome outcome in outcomes.items) {
    ZodiacViolation violation(ZodiacGateRule rule, String detail) =>
        ZodiacViolation(
          packageId: outcomes.id,
          itemId: outcome.id,
          rule: rule,
          detail: detail,
        );

    violations.addAll(
      _timeGatingViolations(outcome.declaredKeys, violation),
    );

    for (final InvariantTermHit hit in invariantHitsIn(outcome.insight)) {
      violations.add(
        violation(_displayRuleFor(hit.rule), 'insight: ${hit.detail}'),
      );
    }

    final String? askLine = outcome.askLine;
    if (askLine != null) {
      for (final InvariantTermHit hit in invariantHitsIn(askLine)) {
        violations.add(
          violation(_displayRuleFor(hit.rule), 'ask_line: ${hit.detail}'),
        );
      }
    }

    if (outcome.aboutOther) {
      if (askLine == null || askLine.trim().isEmpty) {
        violations.add(
          violation(
            ZodiacGateRule.askLineMissing,
            'the outcome speaks about the other person but offers no '
            '"ask_line", so it closes as a verdict',
          ),
        );
      } else {
        for (final StarterStructureHit hit in starterStructureHitsIn(askLine)) {
          violations.add(
            violation(
              _starterStructureRuleFor(hit.rule),
              'ask_line "$askLine": ${hit.detail}',
            ),
          );
        }
      }
    } else if (askLine != null) {
      violations.add(
        violation(
          ZodiacGateRule.askLineWithoutAboutOther,
          'the outcome declares "about_other": false yet carries an '
          '"ask_line", so the block it belongs to would never render',
        ),
      );
    }

    if (outcome.suggestions.length < minimumSuggestionsPerOutcome) {
      violations.add(
        violation(
          ZodiacGateRule.suggestionPoolTooSmall,
          'the outcome offers ${outcome.suggestions.length} suggestions; the '
          'result surface renders $minimumSuggestionsPerOutcome',
        ),
      );
    }

    for (final ZodiacSuggestion suggestion in outcome.suggestions) {
      for (final InvariantTermHit hit in invariantHitsIn(suggestion.title)) {
        violations.add(
          violation(
            _displayRuleFor(hit.rule),
            'suggestion "${suggestion.id}" title: ${hit.detail}',
          ),
        );
      }
      final String? note = suggestion.note;
      if (note != null) {
        for (final InvariantTermHit hit in invariantHitsIn(note)) {
          violations.add(
            violation(
              _displayRuleFor(hit.rule),
              'suggestion "${suggestion.id}" note: ${hit.detail}',
            ),
          );
        }
      }
    }

    if (outcome.editorialReview?.isComplete != true) {
      violations.add(
        violation(
          ZodiacGateRule.editorialReviewIncomplete,
          'editorial_review must record layer1, layer2, and approved_at',
        ),
      );
    }
  }

  return List<ZodiacViolation>.unmodifiable(violations);
}

/// [validateZodiacPacks], but loud. The asset test calls this, so a package
/// that breaks a rule turns the build red instead of reaching a reader.
void assertZodiacPacksClean({
  required ContentPackage<ZodiacQuizSet> quiz,
  required ContentPackage<ZodiacOutcome> outcomes,
}) {
  final List<ZodiacViolation> violations = validateZodiacPacks(
    quiz: quiz,
    outcomes: outcomes,
  );
  if (violations.isNotEmpty) {
    throw ZodiacContentGateException(violations);
  }
}

Iterable<ZodiacViolation> _timeGatingViolations(
  Set<String> declaredKeys,
  ZodiacViolation Function(ZodiacGateRule rule, String detail) violation,
) sync* {
  for (final String key in zodiacTimeGatingKeys) {
    if (declaredKeys.contains(key)) {
      yield violation(
        ZodiacGateRule.timeGatingKey,
        'the item declares "$key", which would gate the shell on the clock',
      );
    }
  }
}

ZodiacGateRule _displayRuleFor(InvariantRule rule) =>
    ZodiacGateRule.values.firstWhere(
      (ZodiacGateRule value) => value.wireValue == rule.wireValue,
    );

ZodiacGateRule _notebookRuleFor(NotebookBoundaryRule rule) =>
    ZodiacGateRule.values.firstWhere(
      (ZodiacGateRule value) => value.wireValue == rule.wireValue,
    );

ZodiacGateRule _starterStructureRuleFor(StarterStructureRule rule) =>
    ZodiacGateRule.values.firstWhere(
      (ZodiacGateRule value) => value.wireValue == rule.wireValue,
    );
