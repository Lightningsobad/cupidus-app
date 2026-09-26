import '../../../core/content/content_package.dart';
import '../../../core/content/invariant_terms.dart';
import 'phase_content.dart';

/// One shipped line that broke an invariant rule.
///
/// The rule is [InvariantRule] itself, not a family-local copy of it. This
/// package family adds no rule of its own — everything AC-39 names (talk about
/// the recipient, flattery, a `%` figure, a streak) is already a shared display
/// invariant, and a parallel enum here would be the second rule set that
/// `core/content/invariant_terms.dart` exists to prevent (R-15c/D-15).
class PhaseContentViolation {
  const PhaseContentViolation({
    required this.packageId,
    required this.itemId,
    required this.rule,
    required this.detail,
  });

  final String packageId;
  final String itemId;
  final InvariantRule rule;
  final String detail;

  @override
  String toString() => '$packageId/$itemId [${rule.wireValue}]: $detail';
}

/// Measures every display string of the three shipped packs against the
/// invariant rules and returns what they broke.
///
/// An empty list is the only shippable result: the test that calls this reads
/// `assets/data/req016/` from disk, so a violating line turns the build red
/// instead of reaching a reader (AC-39/BR-17). That is the whole point of
/// D-15 — the editorial boundary of BR-14 becomes a rule that runs, and stays
/// enforced for content authors who never read BR-14.
List<PhaseContentViolation> validatePhaseContentPackages({
  required ContentPackage<PhaseContentItem> phaseContent,
  required ContentPackage<DripItem> drip,
  required ContentPackage<NudgeItem> nudges,
}) {
  final List<PhaseContentViolation> violations = <PhaseContentViolation>[];

  for (final PhaseContentItem item in phaseContent.items) {
    violations.addAll(
      _violationsIn(phaseContent.id, item.id, item.displayStrings),
    );
  }
  for (final DripItem item in drip.items) {
    violations.addAll(_violationsIn(drip.id, item.id, item.displayStrings));
  }
  for (final NudgeItem item in nudges.items) {
    violations.addAll(_violationsIn(nudges.id, item.id, item.displayStrings));
  }

  return List<PhaseContentViolation>.unmodifiable(violations);
}

Iterable<PhaseContentViolation> _violationsIn(
  String packageId,
  String itemId,
  Iterable<String> texts,
) sync* {
  for (final String text in texts) {
    for (final InvariantTermHit hit in invariantHitsIn(text)) {
      yield PhaseContentViolation(
        packageId: packageId,
        itemId: itemId,
        rule: hit.rule,
        detail: hit.detail,
      );
    }
  }
}
