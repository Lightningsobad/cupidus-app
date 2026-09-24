import '../../../core/content/content_package.dart';
import '../../../core/content/invariant_terms.dart';
import 'invite_preset.dart';
import 'mad_libs.dart';
import 'preset_catalogue.dart';

/// The invariant rules a preset pack has to satisfy before it can reach a
/// reader (`architecture/contract-summary.md` §5, AC-28/BR-16).
enum PresetGateRule {
  declineDoorMissing('decline_door_missing'),
  declineDoorConditional('decline_door_conditional'),
  editorialReviewIncomplete('editorial_review_incomplete'),
  flattery('flattery'),
  percentDisplay('percent_display'),
  streakDisplay('streak_display'),
  scoreOrRatio('score_or_ratio'),
  recipientBehaviour('recipient_behaviour'),
  manipulativeTone('manipulative_tone'),
  assertiveClaim('assertive_claim');

  const PresetGateRule(this.wireValue);

  final String wireValue;
}

class PresetViolation {
  const PresetViolation({
    required this.packageId,
    required this.presetId,
    required this.rule,
    required this.detail,
  });

  final String packageId;
  final String presetId;
  final PresetGateRule rule;
  final String detail;

  @override
  String toString() => '$packageId/$presetId [${rule.wireValue}]: $detail';
}

/// The denylist itself lives in `core/content/invariant_terms.dart`. The two
/// enums pair by [InvariantRule.wireValue], so this gate cannot drift from the
/// shared rule layer without failing to resolve (D-15).
PresetGateRule _presetRuleFor(InvariantRule rule) => PresetGateRule.values
    .firstWhere((PresetGateRule value) => value.wireValue == rule.wireValue);

/// Categories whose presets carry invitation semantics, and therefore owe the
/// reader a one-tap way out (R-1c/AC-10).
///
/// The rule is scoped by category rather than applied to every pack because a
/// thank-you has nothing to decline; the `req_master.md` `## Design Ruling Log`
/// row dated 2026-09-23 records the ruling. Listing the categories that *owe* a
/// door keeps a new category from being named here at all, which is what AC-36
/// forbids — and leaves the invite category exactly as strict as before.
const Set<String> _declineDoorCategories = <String>{inviteCategoryId};

/// Runs every invariant rule over a loaded pack and returns what it broke. An
/// empty list is the only shippable result: the test that calls this scans the
/// asset directory from disk, so a violating pack turns the build red rather
/// than reaching a reader (AC-28).
///
/// [categoryId] comes from the caller, never from `package.id`: the asset key
/// convention in [presetAssetKey] is what decides which category a pack is, and
/// a pack that could name its own category could opt itself out of the decline
/// door rule by mislabelling one field.
///
/// `clauses[].targets` is deliberately absent from these rules. `recipient` is
/// not a member of [ClauseTarget], so a pack declaring it dies in
/// [invitePresetFromJson] before a [ContentPackage] exists to hand here — the
/// rule is enforced one layer earlier, not skipped (R-1d).
List<PresetViolation> validatePresetPack(
  ContentPackage<InvitePreset> package, {
  required String categoryId,
}) {
  final List<PresetViolation> violations = <PresetViolation>[];
  final bool declineDoorRequired = _declineDoorCategories.contains(categoryId);

  for (final InvitePreset preset in package.items) {
    final List<PresetClause> doors = preset.clauses
        .where((PresetClause clause) => clause.role == ClauseRole.declineDoor)
        .toList(growable: false);

    // A category that owes a door owes exactly one. A category that does not
    // may still carry one — an embedded invitation makes a preset an invite
    // whatever its category (BR-6) — but never two.
    if (declineDoorRequired ? doors.length != 1 : doors.length > 1) {
      violations.add(
        PresetViolation(
          packageId: package.id,
          presetId: preset.id,
          rule: PresetGateRule.declineDoorMissing,
          detail: declineDoorRequired
              ? 'expected exactly one decline_door clause, found '
                  '${doors.length}'
              : 'expected at most one decline_door clause, found '
                  '${doors.length}',
        ),
      );
    }
    for (final PresetClause door in doors) {
      if (door.requires.isNotEmpty) {
        violations.add(
          PresetViolation(
            packageId: package.id,
            presetId: preset.id,
            rule: PresetGateRule.declineDoorConditional,
            detail: 'the decline door is gated by '
                '${door.requires.map((MadLibsVariable v) => v.wireValue).join(', ')}, '
                'so a card missing those fields would render an invite with no '
                'way out',
          ),
        );
      }
    }

    final EditorialReview? review = preset.editorialReview;
    if (review == null || review.layer1 == null || review.layer2 == null) {
      violations.add(
        PresetViolation(
          packageId: package.id,
          presetId: preset.id,
          rule: PresetGateRule.editorialReviewIncomplete,
          detail: 'editorial_review must record both layer1 and layer2',
        ),
      );
    }

    for (final String text in <String>[
      preset.frame,
      for (final PresetClause clause in preset.clauses) clause.text,
    ]) {
      violations.addAll(_lexicalViolations(package.id, preset.id, text));
    }
  }

  return List<PresetViolation>.unmodifiable(violations);
}

Iterable<PresetViolation> _lexicalViolations(
  String packageId,
  String presetId,
  String text,
) sync* {
  for (final InvariantTermHit hit in invariantHitsIn(text)) {
    yield PresetViolation(
      packageId: packageId,
      presetId: presetId,
      rule: _presetRuleFor(hit.rule),
      detail: hit.detail,
    );
  }
}
