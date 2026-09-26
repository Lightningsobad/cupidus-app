import '../../../core/content/content_package.dart';
import '../../activity_cards/domain/activity_type.dart';

/// The two conversation-starter package families
/// (`architecture/contract-summary.md` §1, §3, §4). Separate schema ids because
/// the item shapes have nothing in common — this is a new package family, not a
/// new category of the STORY-002 preset family.
const String startersSchemaId = 'req016.starters.v1';
const String calendarEventsSchemaId = 'req016.calendar_events.v1';

const String startersAssetKey = 'assets/data/req016/starters.v1.json';
const String calendarEventsAssetKey =
    'assets/data/req016/calendar_events.v1.json';

/// The one substitution token a `contextual` starter may carry. Exactly this
/// string, exactly once: no fuzzy match, no tokenizer, no model
/// (`architecture/contract-summary.md` §3).
const String starterValueToken = '{value}';

/// Whether a starter stands on its own or needs one recorded notebook value.
enum StarterKind {
  generic('generic'),
  contextual('contextual');

  const StarterKind(this.wireValue);

  final String wireValue;

  static StarterKind? fromWireValue(String value) {
    for (final StarterKind kind in values) {
      if (kind.wireValue == value) {
        return kind;
      }
    }
    return null;
  }
}

/// Which recorded notebook kind fills [starterValueToken]. Maps one-to-one onto
/// STORY-004's `NotebookKind`; a closed set of two, so an unknown value is a
/// parse error rather than a default.
enum StarterContextSlot {
  interest('interest'),
  event('event');

  const StarterContextSlot(this.wireValue);

  final String wireValue;

  static StarterContextSlot? fromWireValue(String value) {
    for (final StarterContextSlot slot in values) {
      if (slot.wireValue == value) {
        return slot;
      }
    }
    return null;
  }
}

/// Which calendar an event's dates were authored from. Provenance only: no file
/// in this repository converts between the two
/// (`architecture/contract-summary.md` §2, §4).
enum EventCalendar {
  solar('solar'),
  lunar('lunar');

  const EventCalendar(this.wireValue);

  final String wireValue;

  static EventCalendar? fromWireValue(String value) {
    for (final EventCalendar calendar in values) {
      if (calendar.wireValue == value) {
        return calendar;
      }
    }
    return null;
  }
}

/// One evergreen conversation starter.
///
/// There is deliberately no field that exempts an item from R-1g, and no field
/// carrying a predicted reaction: [text] always ends by asking, and the gate is
/// what enforces it (AC-20/AC-29, BR-8/BR-17).
class StarterItem implements ContentItem {
  const StarterItem({
    required this.id,
    required this.kind,
    required this.text,
    this.contextSlot,
  });

  @override
  final String id;

  final StarterKind kind;

  /// A complete line the reader can send as written.
  final String text;

  /// Present exactly when [kind] is [StarterKind.contextual].
  final StarterContextSlot? contextSlot;
}

/// One dated event worth turning into an activity card.
class CalendarEvent implements ContentItem {
  const CalendarEvent({
    required this.id,
    required this.name,
    required this.calendar,
    required this.dates,
    this.activityTypeWireValue,
    this.reasonTemplate,
    this.reasonContextSlot,
  });

  @override
  final String id;

  /// Display label. It is content, never an l10n key or a Dart constant
  /// (BR-15/BR-16).
  final String name;

  final EventCalendar calendar;

  /// Civil `YYYY-MM-DD` dates the content author pinned for each occurrence,
  /// following the `occasions.v1.json` convention STORY-001 shipped.
  final List<String> dates;

  /// Kept as the raw wire string so the gate can tell "the author typed a value
  /// this build does not know" from "the author left it out". Reading it
  /// leniently here would turn the first case into the second and let a typo
  /// ship as a card with no type.
  final String? activityTypeWireValue;

  /// The sentence drawn under the event name, carrying [starterValueToken]
  /// once. Optional, and paired with [reasonContextSlot]: an event with no
  /// natural reason ships neither key and draws no line at all.
  final String? reasonTemplate;

  /// Which recorded notebook kind fills [reasonTemplate]'s token.
  final StarterContextSlot? reasonContextSlot;

  ActivityType? get activityType =>
      activityTypeFromWireValue(activityTypeWireValue);
}

StarterItem starterItemFromJson(Map<String, Object?> json, String source) {
  final String id = requireContentString(json, 'id', source);
  final String rawKind = requireContentString(json, 'kind', source);
  final StarterKind? kind = StarterKind.fromWireValue(rawKind);
  if (kind == null) {
    throw ContentPackageFormatException(
      source,
      'starter "$id" declares unsupported kind "$rawKind"',
    );
  }

  final String? rawSlot = optionalContentString(json, 'context_slot', source);
  StarterContextSlot? contextSlot;
  if (rawSlot != null) {
    contextSlot = StarterContextSlot.fromWireValue(rawSlot);
    if (contextSlot == null) {
      throw ContentPackageFormatException(
        source,
        'starter "$id" declares unsupported context_slot "$rawSlot"',
      );
    }
  }

  return StarterItem(
    id: id,
    kind: kind,
    text: requireContentString(json, 'text', source),
    contextSlot: contextSlot,
  );
}

CalendarEvent calendarEventFromJson(Map<String, Object?> json, String source) {
  final String id = requireContentString(json, 'id', source);
  final String rawCalendar = requireContentString(json, 'calendar', source);
  final EventCalendar? calendar = EventCalendar.fromWireValue(rawCalendar);
  if (calendar == null) {
    throw ContentPackageFormatException(
      source,
      'event "$id" declares unsupported calendar "$rawCalendar"',
    );
  }

  final String? rawReasonSlot =
      optionalContentString(json, 'reason_context_slot', source);
  StarterContextSlot? reasonContextSlot;
  if (rawReasonSlot != null) {
    reasonContextSlot = StarterContextSlot.fromWireValue(rawReasonSlot);
    if (reasonContextSlot == null) {
      throw ContentPackageFormatException(
        source,
        'event "$id" declares unsupported reason_context_slot "$rawReasonSlot"',
      );
    }
  }

  return CalendarEvent(
    id: id,
    name: requireContentString(json, 'name', source),
    calendar: calendar,
    dates: List<String>.unmodifiable(
      requireContentStringList(json, 'dates', source),
    ),
    activityTypeWireValue:
        optionalContentString(json, 'activity_type', source),
    reasonTemplate: optionalContentString(json, 'reason_template', source),
    reasonContextSlot: reasonContextSlot,
  );
}
