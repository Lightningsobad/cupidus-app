import '../../../core/content/content_package.dart';
import 'invite_preset.dart';
import 'mad_libs.dart';

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
  manipulativeTone('manipulative_tone');

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

/// Denylisted tokens, in Dart and only in Dart. Putting them in the package
/// would let an out-of-repo CMS relax the rules it is being measured against
/// (R-15c) — the whole point of D-15 is that the gate does not travel with the
/// content it judges.
///
/// Terms are matched as whole words, so `điểm số` never fires on `địa điểm`.
const Map<PresetGateRule, List<String>> _deniedTerms =
    <PresetGateRule, List<String>>{
  PresetGateRule.flattery: <String>[
    'xinh',
    'đẹp trai',
    'dễ thương',
    'quyến rũ',
    'hoàn hảo',
    'tuyệt vời',
    'số một',
  ],
  PresetGateRule.percentDisplay: <String>['phần trăm'],
  PresetGateRule.streakDisplay: <String>[
    'streak',
    'chuỗi ngày',
    'liên tiếp',
  ],
  PresetGateRule.scoreOrRatio: <String>[
    'điểm số',
    'chấm điểm',
    'xếp hạng',
    'thứ hạng',
    'tỉ lệ',
    'tỷ lệ',
    'score',
    'rank',
  ],
  PresetGateRule.recipientBehaviour: <String>[
    'đã xem',
    'đã đọc',
    'seen',
    'online',
    'hoạt động lần cuối',
    'truy cập lần cuối',
  ],
  PresetGateRule.manipulativeTone: <String>[
    'chiêu',
    'cưa',
    'thả thính',
    'tán tỉnh',
    'thao túng',
  ],
};

const String _percentSymbol = '%';

final Map<String, RegExp> _termPatterns = <String, RegExp>{};

RegExp _patternFor(String term) => _termPatterns.putIfAbsent(
      term,
      () => RegExp(
        '(?<![\\p{L}\\p{N}])${RegExp.escape(term)}(?![\\p{L}\\p{N}])',
        unicode: true,
        caseSensitive: false,
      ),
    );

/// Runs every invariant rule over a loaded pack and returns what it broke. An
/// empty list is the only shippable result: the test that calls this scans the
/// asset directory from disk, so a violating pack turns the build red rather
/// than reaching a reader (AC-28).
///
/// `clauses[].targets` is deliberately absent from these rules. `recipient` is
/// not a member of [ClauseTarget], so a pack declaring it dies in
/// [invitePresetFromJson] before a [ContentPackage] exists to hand here — the
/// rule is enforced one layer earlier, not skipped (R-1d).
List<PresetViolation> validatePresetPack(ContentPackage<InvitePreset> package) {
  final List<PresetViolation> violations = <PresetViolation>[];

  for (final InvitePreset preset in package.items) {
    final List<PresetClause> doors = preset.clauses
        .where((PresetClause clause) => clause.role == ClauseRole.declineDoor)
        .toList(growable: false);

    if (doors.length != 1) {
      violations.add(
        PresetViolation(
          packageId: package.id,
          presetId: preset.id,
          rule: PresetGateRule.declineDoorMissing,
          detail: 'expected exactly one decline_door clause, found '
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
  final String haystack = text.toLowerCase();

  if (haystack.contains(_percentSymbol)) {
    yield PresetViolation(
      packageId: packageId,
      presetId: presetId,
      rule: PresetGateRule.percentDisplay,
      detail: 'text shows a "$_percentSymbol" figure',
    );
  }

  for (final MapEntry<PresetGateRule, List<String>> entry
      in _deniedTerms.entries) {
    for (final String term in entry.value) {
      if (_patternFor(term).hasMatch(haystack)) {
        yield PresetViolation(
          packageId: packageId,
          presetId: presetId,
          rule: entry.key,
          detail: 'text uses the denylisted term "$term"',
        );
      }
    }
  }
}
