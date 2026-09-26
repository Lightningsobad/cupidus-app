import '../../../core/content/content_package.dart';
import '../../../core/content/invariant_terms.dart';
import 'compat_content.dart';

/// What a compatibility pack can break. The first six pair by wire value with
/// [InvariantRule], so the rules every package family is measured against stay
/// in `core/content/invariant_terms.dart` and this enum only names them
/// (R-15c/D-15). The rest are structural, and structural is the point: AC-37
/// (a), (c), and (d) already have a denylist, while (b) and (e) can only be
/// enforced by the shape of the data.
enum CompatGateRule {
  flattery('flattery'),
  percentDisplay('percent_display'),
  streakDisplay('streak_display'),
  scoreOrRatio('score_or_ratio'),
  recipientBehaviour('recipient_behaviour'),
  manipulativeTone('manipulative_tone'),
  frequencyProbe('frequency_probe'),
  numberInContent('number_in_content'),
  missingQuartetField('missing_quartet_field'),
  questionWithoutAsk('question_without_ask'),
  unknownBandId('unknown_band_id'),
  coverageGap('coverage_gap'),
  cellIdMismatch('cell_id_mismatch');

  const CompatGateRule(this.wireValue);

  final String wireValue;
}

class CompatViolation {
  const CompatViolation({
    required this.packageId,
    required this.itemId,
    required this.rule,
    required this.detail,
  });

  final String packageId;
  final String itemId;
  final CompatGateRule rule;
  final String detail;

  @override
  String toString() => '$packageId/$itemId [${rule.wireValue}]: $detail';
}

/// Runs every rule over the three compatibility packs and returns what they
/// broke. An empty list is the only shippable result: the test that calls this
/// reads `assets/data/req016/compat_*.v1.json` from disk, so a violating pack
/// turns the build red instead of reaching a reader (AC-37/AC-38).
///
/// Coverage is checked as `n * n` with `n` counted from the pack's own
/// `axis_value` items (AC-36). That is what lets the axis widen from a small
/// seed to the full set without a red tree in between, and it is why no axis
/// count may be written into this file.
List<CompatViolation> validateCompatPacks({
  required ContentPackage<CompatBand> bands,
  required ContentPackage<CompatItem> zodiac,
  required ContentPackage<CompatItem> mbti,
}) {
  final List<CompatViolation> violations = <CompatViolation>[];

  final Set<String> bandIds = <String>{};
  for (final CompatBand band in bands.items) {
    bandIds.add(band.id);
    violations.addAll(_numberViolations(bands.id, band.id, band.rawJson));
    violations.addAll(_displayViolations(bands.id, band.id, band.label));
  }

  for (final ContentPackage<CompatItem> pack in <ContentPackage<CompatItem>>[
    zodiac,
    mbti,
  ]) {
    _validateLookupPack(violations, pack, bandIds);
  }

  return List<CompatViolation>.unmodifiable(violations);
}

void _validateLookupPack(
  List<CompatViolation> violations,
  ContentPackage<CompatItem> pack,
  Set<String> bandIds,
) {
  final Set<String> axisValueIds = <String>{};
  final List<CompatCell> cells = <CompatCell>[];

  for (final CompatItem item in pack.items) {
    violations.addAll(_numberViolations(pack.id, item.id, item.rawJson));
    switch (item) {
      case CompatAxisValue(:final String label):
        axisValueIds.add(item.id);
        violations.addAll(_displayViolations(pack.id, item.id, label));
      case CompatCell():
        cells.add(item);
    }
  }

  final Set<String> coveredPairs = <String>{};
  for (final CompatCell cell in cells) {
    violations.addAll(_cellViolations(pack.id, cell, bandIds));

    final String pairId = compatCellId(cell.selfId, cell.partnerId);
    if (!coveredPairs.add(pairId)) {
      violations.add(
        CompatViolation(
          packageId: pack.id,
          itemId: cell.id,
          rule: CompatGateRule.coverageGap,
          detail: 'a second cell claims the ordered pair "$pairId"; a lookup '
              'must resolve to exactly one cell',
        ),
      );
    }

    if (!axisValueIds.contains(cell.selfId) ||
        !axisValueIds.contains(cell.partnerId)) {
      violations.add(
        CompatViolation(
          packageId: pack.id,
          itemId: cell.id,
          rule: CompatGateRule.coverageGap,
          detail: 'points at an axis value this pack does not declare, so it '
              'can never be reached',
        ),
      );
    }
  }

  for (final String selfId in axisValueIds) {
    for (final String partnerId in axisValueIds) {
      final String pairId = compatCellId(selfId, partnerId);
      if (!coveredPairs.contains(pairId)) {
        violations.add(
          CompatViolation(
            packageId: pack.id,
            itemId: pairId,
            rule: CompatGateRule.coverageGap,
            detail: 'the pack declares both axis values but ships no cell for '
                'this ordered pair; a lookup table with a hole breaks at the '
                'exact pair the reader just chose (AC-38)',
          ),
        );
      }
    }
  }

  final int expectedCellCount = axisValueIds.length * axisValueIds.length;
  if (cells.length != expectedCellCount) {
    violations.add(
      CompatViolation(
        packageId: pack.id,
        itemId: pack.id,
        rule: CompatGateRule.coverageGap,
        detail: 'ships ${cells.length} cells for ${axisValueIds.length} axis '
            'values; full coverage is every ordered pair, so $expectedCellCount '
            'are required',
      ),
    );
  }
}

Iterable<CompatViolation> _cellViolations(
  String packageId,
  CompatCell cell,
  Set<String> bandIds,
) sync* {
  for (final String text in cell.quartet) {
    yield* _displayViolations(packageId, cell.id, text);
  }

  final Map<String, String> quartetByField = <String, String>{
    'fit': cell.fit,
    'friction': cell.friction,
    'activity': cell.activity,
    'question': cell.question,
  };
  for (final MapEntry<String, String> field in quartetByField.entries) {
    if (field.value.trim().isEmpty) {
      yield CompatViolation(
        packageId: packageId,
        itemId: cell.id,
        rule: CompatGateRule.missingQuartetField,
        detail: 'field "${field.key}" is blank; the four are what a reader is '
            'promised, and "friction" in particular is what keeps a cell from '
            'being all praise (AC-12/AC-37b)',
      );
    }
  }

  if (!cell.question.trim().endsWith('?')) {
    yield CompatViolation(
      packageId: packageId,
      itemId: cell.id,
      rule: CompatGateRule.questionWithoutAsk,
      detail: 'the closing line is a statement, not something to ask a real '
          'person (AC-37e)',
    );
  }

  if (!bandIds.contains(cell.bandId)) {
    yield CompatViolation(
      packageId: packageId,
      itemId: cell.id,
      rule: CompatGateRule.unknownBandId,
      detail: 'band_id "${cell.bandId}" is not a label the shipped band pack '
          'declares',
    );
  }

  final String derivedId = compatCellId(cell.selfId, cell.partnerId);
  if (cell.id != derivedId) {
    yield CompatViolation(
      packageId: packageId,
      itemId: cell.id,
      rule: CompatGateRule.cellIdMismatch,
      detail: 'the ordered pair it carries derives the id "$derivedId"',
    );
  }
}

/// Walks every JSON value the item shipped and rejects every number.
///
/// This is the hard half of AC-37(c). A denylist can only catch a number that
/// was spelled out in prose; a `weight`, `order`, or `score` key is invisible
/// to it and is exactly what a later change turns back into a percentage on
/// screen.
Iterable<CompatViolation> _numberViolations(
  String packageId,
  String itemId,
  Object? node, [
  String path = '',
]) sync* {
  switch (node) {
    case num():
      yield CompatViolation(
        packageId: packageId,
        itemId: itemId,
        rule: CompatGateRule.numberInContent,
        detail: 'carries a JSON number at "$path"; a number at the data layer '
            'becomes a score on screen at the next change (AC-37c)',
      );
    case final Map<Object?, Object?> map:
      for (final MapEntry<Object?, Object?> entry in map.entries) {
        final String key = '${entry.key}';
        yield* _numberViolations(
          packageId,
          itemId,
          entry.value,
          path.isEmpty ? key : '$path.$key',
        );
      }
    case final List<Object?> list:
      for (final (int index, Object? entry) in list.indexed) {
        yield* _numberViolations(packageId, itemId, entry, '$path[$index]');
      }
  }
}

final Map<String, RegExp> _termPatterns = <String, RegExp>{};

RegExp _wholeWordPattern(String term) => _termPatterns.putIfAbsent(
      term,
      () => RegExp(
        '(?<![\\p{L}\\p{N}])${RegExp.escape(term)}(?![\\p{L}\\p{N}])',
        unicode: true,
        caseSensitive: false,
      ),
    );

Iterable<CompatViolation> _displayViolations(
  String packageId,
  String itemId,
  String text,
) sync* {
  for (final InvariantTermHit hit in invariantHitsIn(text)) {
    yield CompatViolation(
      packageId: packageId,
      itemId: itemId,
      rule: _compatRuleFor(hit.rule.wireValue),
      detail: hit.detail,
    );
  }

  // Only `frequencyProbe`. `notebookBoundaryHitsIn` also carries
  // `judgementProbe`, whose terms (`tính cách`, `điểm mạnh`, `điểm yếu`) are
  // the legitimate subject of a compatibility cell — wiring the whole helper
  // here makes the gate impossible to pass rather than strict.
  final String haystack = text.toLowerCase();
  for (final String term
      in notebookBoundaryTerms[NotebookBoundaryRule.frequencyProbe]!) {
    if (_wholeWordPattern(term).hasMatch(haystack)) {
      yield CompatViolation(
        packageId: packageId,
        itemId: itemId,
        rule: CompatGateRule.frequencyProbe,
        detail: 'text describes the other person in terms of how often, via '
            '"$term" (AC-37a)',
      );
    }
  }
}

CompatGateRule _compatRuleFor(String wireValue) => CompatGateRule.values
    .firstWhere((CompatGateRule rule) => rule.wireValue == wireValue);
