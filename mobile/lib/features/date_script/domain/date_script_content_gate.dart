import '../../../core/content/content_package.dart';
import '../../../core/content/invariant_terms.dart';
import 'date_script_content.dart';

/// What a date-script pack can break (`architecture/contract-summary.md` §5,
/// AC-36/BR-18).
///
/// The first block is *structural* and owned by this story. The second and
/// third pair by wire value with [InvariantRule] and [NotebookBoundaryRule], so
/// the lexical layer stays a delegation to `core/content/invariant_terms.dart`
/// and this file never becomes a second denylist (R-15c/D-15).
enum DateScriptGateRule {
  partsShape('parts_shape'),
  genericPresetMissing('generic_preset_missing'),
  unconditionalSentenceMissing('unconditional_sentence_missing'),
  undeclaredPlaceholder('undeclared_placeholder'),
  partnerSentenceNotQuestion('partner_sentence_not_question'),
  duplicatePresetId('duplicate_preset_id'),
  nonAsciiPresetId('non_ascii_preset_id'),
  editorialReviewIncomplete('editorial_review_incomplete'),
  flattery('flattery'),
  percentDisplay('percent_display'),
  streakDisplay('streak_display'),
  scoreOrRatio('score_or_ratio'),
  recipientBehaviour('recipient_behaviour'),
  manipulativeTone('manipulative_tone'),
  frequencyProbe('frequency_probe'),
  behaviourProbe('behaviour_probe'),
  judgementProbe('judgement_probe');

  const DateScriptGateRule(this.wireValue);

  final String wireValue;
}

class DateScriptViolation {
  const DateScriptViolation({
    required this.packageId,
    required this.presetId,
    required this.rule,
    required this.detail,
  });

  final String packageId;

  /// `null` for a rule the whole pack breaks rather than one preset.
  final String? presetId;

  final DateScriptGateRule rule;
  final String detail;

  @override
  String toString() =>
      '$packageId/${presetId ?? '<pack>'} [${rule.wireValue}]: $detail';
}

/// Printable ASCII with no spaces: ids travel through an out-of-repo CMS, file
/// names, and moderation trace keys unchanged (AC-31/R-15a).
final RegExp _asciiPresetId = RegExp(r'^[\x21-\x7E]+$');

/// Runs every invariant rule over a loaded pack and returns what it broke. An
/// empty list is the only shippable result: the test that calls this reads the
/// pack from disk, so a violating pack turns the build red rather than reaching
/// a reader (AC-36/BR-18).
///
/// Some structural rules are also unreachable through
/// [dateScriptPresetFromJson], which rejects a missing or reordered part at
/// load. They are still checked here because the gate must judge any
/// [ContentPackage], including one a future CMS importer builds in memory
/// without going through this repository's parser.
List<DateScriptViolation> validateDateScriptPack(
  ContentPackage<DateScriptPreset> package,
) {
  final List<DateScriptViolation> violations = <DateScriptViolation>[];

  if (!package.items.any(
    (DateScriptPreset preset) => preset.activityTypes.isEmpty,
  )) {
    violations.add(
      DateScriptViolation(
        packageId: package.id,
        presetId: null,
        rule: DateScriptGateRule.genericPresetMissing,
        detail: 'the pack declares no preset with an empty "activityTypes", so '
            'a card whose type no preset covers would have no script at all',
      ),
    );
  }

  final Set<String> seenIds = <String>{};
  for (final DateScriptPreset preset in package.items) {
    DateScriptViolation violation(DateScriptGateRule rule, String detail) =>
        DateScriptViolation(
          packageId: package.id,
          presetId: preset.id,
          rule: rule,
          detail: detail,
        );

    if (!seenIds.add(preset.id)) {
      violations.add(
        violation(
          DateScriptGateRule.duplicatePresetId,
          'id "${preset.id}" is declared more than once, so the moderation '
          'trace cannot name one preset',
        ),
      );
    }
    if (!_asciiPresetId.hasMatch(preset.id)) {
      violations.add(
        violation(
          DateScriptGateRule.nonAsciiPresetId,
          'id "${preset.id}" is not printable ASCII',
        ),
      );
    }

    if (!_partsInFixedOrder(preset.parts)) {
      violations.add(
        violation(
          DateScriptGateRule.partsShape,
          'expected exactly '
          '${DateScriptPart.values.map((DateScriptPart part) => part.wireValue).join(', ')}, '
          'found '
          '${preset.parts.map((DateScriptPartContent part) => part.part.wireValue).join(', ')}',
        ),
      );
    }

    for (final DateScriptPartContent part in preset.parts) {
      if (!part.sentences.any(
        (DateScriptSentence sentence) => sentence.requires.isEmpty,
      )) {
        violations.add(
          violation(
            DateScriptGateRule.unconditionalSentenceMissing,
            'part "${part.part.wireValue}" has no sentence with an empty '
            '"requires", so a card missing those fields would render an empty '
            'part',
          ),
        );
      }

      for (final DateScriptSentence sentence in part.sentences) {
        for (final RegExpMatch match
            in dateScriptPlaceholderPattern.allMatches(sentence.text)) {
          final String name = match.group(1)!;
          final DateScriptVariable? variable =
              DateScriptVariable.fromWireValue(name);
          if (variable == null || !sentence.requires.contains(variable)) {
            violations.add(
              violation(
                DateScriptGateRule.undeclaredPlaceholder,
                'sentence "${sentence.text}" uses "${match.group(0)}" without '
                'listing "$name" in "requires"',
              ),
            );
          }
        }

        if (sentence.aboutPartner && !sentence.text.trimRight().endsWith('?')) {
          violations.add(
            violation(
              DateScriptGateRule.partnerSentenceNotQuestion,
              'sentence "${sentence.text}" is about the other person but ends '
              'on a verdict instead of a question',
            ),
          );
        }

        for (final InvariantTermHit hit in invariantHitsIn(sentence.text)) {
          violations.add(violation(_displayRuleFor(hit.rule), hit.detail));
        }
        for (final NotebookBoundaryHit hit
            in notebookBoundaryHitsIn(sentence.text)) {
          violations.add(violation(_notebookRuleFor(hit.rule), hit.detail));
        }
      }
    }

    final DateScriptEditorialReview? review = preset.editorialReview;
    if (review == null ||
        review.layer1 == null ||
        review.layer2 == null ||
        review.approvedAt == null) {
      violations.add(
        violation(
          DateScriptGateRule.editorialReviewIncomplete,
          'editorial_review must record layer1, layer2, and approved_at',
        ),
      );
    }
  }

  return List<DateScriptViolation>.unmodifiable(violations);
}

bool _partsInFixedOrder(List<DateScriptPartContent> parts) {
  if (parts.length != DateScriptPart.values.length) {
    return false;
  }
  for (int index = 0; index < parts.length; index++) {
    if (parts[index].part != DateScriptPart.values[index]) {
      return false;
    }
  }
  return true;
}

DateScriptGateRule _displayRuleFor(InvariantRule rule) =>
    DateScriptGateRule.values.firstWhere(
      (DateScriptGateRule value) => value.wireValue == rule.wireValue,
    );

DateScriptGateRule _notebookRuleFor(NotebookBoundaryRule rule) =>
    DateScriptGateRule.values.firstWhere(
      (DateScriptGateRule value) => value.wireValue == rule.wireValue,
    );
