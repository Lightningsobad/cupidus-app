import '../../../core/content/content_package.dart';
import '../../../core/content/invariant_terms.dart';
import '../../activity_cards/domain/activity_type.dart';
import 'starter_content.dart';

/// What a conversation-starter pack can break. The first six pair by wire value
/// with [InvariantRule], so the rules every package family is measured against
/// stay in `core/content/invariant_terms.dart` and this enum only names them
/// (D-15). The rest are this family only.
enum StarterGateRule {
  flattery('flattery'),
  percentDisplay('percent_display'),
  streakDisplay('streak_display'),
  scoreOrRatio('score_or_ratio'),
  recipientBehaviour('recipient_behaviour'),
  manipulativeTone('manipulative_tone'),
  missingQuestionEnding('missing_question_ending'),
  contextSlotMismatch('context_slot_mismatch'),
  valueTokenMismatch('value_token_mismatch'),
  emptyEventDates('empty_event_dates'),
  malformedEventDate('malformed_event_date'),
  unknownActivityType('unknown_activity_type');

  const StarterGateRule(this.wireValue);

  final String wireValue;
}

class StarterViolation {
  const StarterViolation({
    required this.packageId,
    required this.itemId,
    required this.rule,
    required this.detail,
  });

  final String packageId;
  final String itemId;
  final StarterGateRule rule;
  final String detail;

  @override
  String toString() => '$packageId/$itemId [${rule.wireValue}]: $detail';
}

/// Runs every rule over the two starter packs and returns what they broke. An
/// empty list is the only shippable result: the test that calls this reads
/// `assets/data/req016/` from disk, so a violating pack turns the build red
/// rather than reaching a reader (AC-20/AC-22/AC-26/AC-29, BR-17).
List<StarterViolation> validateStarterPacks({
  required ContentPackage<StarterItem> starters,
  required ContentPackage<CalendarEvent> calendarEvents,
}) {
  final List<StarterViolation> violations = <StarterViolation>[];

  for (final StarterItem item in starters.items) {
    violations.addAll(_displayViolations(starters.id, item.id, item.text));
    violations.addAll(_structureViolations(starters.id, item));
  }

  for (final CalendarEvent event in calendarEvents.items) {
    violations.addAll(
      _displayViolations(calendarEvents.id, event.id, event.name),
    );
    violations.addAll(_eventViolations(calendarEvents.id, event));
  }

  return List<StarterViolation>.unmodifiable(violations);
}

Iterable<StarterViolation> _displayViolations(
  String packageId,
  String itemId,
  String text,
) sync* {
  for (final InvariantTermHit hit in invariantHitsIn(text)) {
    yield StarterViolation(
      packageId: packageId,
      itemId: itemId,
      rule: _starterRuleFor(hit.rule.wireValue),
      detail: hit.detail,
    );
  }
}

Iterable<StarterViolation> _structureViolations(
  String packageId,
  StarterItem item,
) sync* {
  for (final StarterStructureHit hit in starterStructureHitsIn(item.text)) {
    yield StarterViolation(
      packageId: packageId,
      itemId: item.id,
      rule: _starterRuleFor(hit.rule.wireValue),
      detail: hit.detail,
    );
  }

  final int tokenCount = starterValueToken.allMatches(item.text).length;

  switch (item.kind) {
    case StarterKind.contextual:
      if (item.contextSlot == null) {
        yield StarterViolation(
          packageId: packageId,
          itemId: item.id,
          rule: StarterGateRule.contextSlotMismatch,
          detail: 'a contextual starter must name the notebook slot that fills '
              'it',
        );
      }
      if (tokenCount != 1) {
        yield StarterViolation(
          packageId: packageId,
          itemId: item.id,
          rule: StarterGateRule.valueTokenMismatch,
          detail: 'a contextual starter must carry "$starterValueToken" exactly '
              'once, and this one carries it $tokenCount times',
        );
      }
    case StarterKind.generic:
      if (item.contextSlot != null) {
        yield StarterViolation(
          packageId: packageId,
          itemId: item.id,
          rule: StarterGateRule.contextSlotMismatch,
          detail: 'a generic starter must not name a notebook slot',
        );
      }
      if (tokenCount != 0) {
        yield StarterViolation(
          packageId: packageId,
          itemId: item.id,
          rule: StarterGateRule.valueTokenMismatch,
          detail: 'a generic starter must not carry "$starterValueToken", and '
              'this one carries it $tokenCount times',
        );
      }
  }
}

Iterable<StarterViolation> _eventViolations(
  String packageId,
  CalendarEvent event,
) sync* {
  if (event.dates.isEmpty) {
    yield StarterViolation(
      packageId: packageId,
      itemId: event.id,
      rule: StarterGateRule.emptyEventDates,
      detail: 'an event with no date can never be offered or turned into a '
          'card',
    );
  }

  for (final String date in event.dates) {
    if (!_isCivilDate(date)) {
      yield StarterViolation(
        packageId: packageId,
        itemId: event.id,
        rule: StarterGateRule.malformedEventDate,
        detail: 'date "$date" is not a civil YYYY-MM-DD date',
      );
    }
  }

  final String? rawType = event.activityTypeWireValue;
  if (rawType != null && activityTypeFromWireValue(rawType) == null) {
    yield StarterViolation(
      packageId: packageId,
      itemId: event.id,
      rule: StarterGateRule.unknownActivityType,
      detail: 'activity_type "$rawType" is not one of the shipped activity '
          'types',
    );
  }
}

final RegExp _civilDatePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

/// Shape *and* existence. `2027-02-30` matches the shape and would silently
/// roll forward a day through `DateTime`, so the round trip is what makes the
/// pinned date the author wrote the date the reader is offered.
bool _isCivilDate(String value) {
  final RegExpMatch? match = _civilDatePattern.firstMatch(value);
  if (match == null) {
    return false;
  }
  final int year = int.parse(match.group(1)!);
  final int month = int.parse(match.group(2)!);
  final int day = int.parse(match.group(3)!);
  if (month < DateTime.january || month > DateTime.december) {
    return false;
  }
  final DateTime parsed = DateTime(year, month, day);
  return parsed.year == year && parsed.month == month && parsed.day == day;
}

StarterGateRule _starterRuleFor(String wireValue) => StarterGateRule.values
    .firstWhere((StarterGateRule r) => r.wireValue == wireValue);
