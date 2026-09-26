import '../../../../core/content/content_package.dart';
import '../../../conversation_starters/domain/calendar_event_service.dart';
import '../../../conversation_starters/domain/starter_content.dart';
import '../../domain/activity_card.dart';
import '../../domain/activity_card_repository.dart';
import '../../domain/activity_type.dart';

/// How many chips phần 3 lays out (`ux/uiux-spec.md` mục 3: "2-3 chip").
///
/// A layout parameter, never a claim about the pack: a pack holding fewer dated
/// occasions renders exactly what it has, and a pack holding hundreds renders
/// the same first [maxNextPlanSuggestions] with no extra step (AC-35, R-15b).
const int maxNextPlanSuggestions = 3;

/// One offered "việc kế tiếp", already carrying the date it is anchored to.
class NextPlanSuggestion {
  const NextPlanSuggestion({
    required this.id,
    required this.title,
    required this.date,
    this.activityType,
  });

  /// The occasion's own stable package id (R-15a), never a list index.
  final String id;

  /// Read verbatim off the pack; this file writes no display text of its own
  /// (BR-15/BR-16).
  final String title;

  /// Civil `YYYY-MM-DD`, the occasion's nearest occurrence on or after the
  /// injected `today`.
  final String date;

  final ActivityType? activityType;
}

/// Phần 3's suggestion source and its one write.
///
/// Reads STORY-005's shipped `calendar_events.v1.json` pack and resolves each
/// occasion's date with STORY-005's own on-device function
/// ([nearestUpcomingDate]) rather than recomputing a calendar here — the lunar
/// dates in that pack were pinned by the content author and nothing in this
/// repository converts between calendars (AC-21, STORY-005 AC-18,
/// `architecture/contract-summary.md` mục 4).
///
/// STORY-005's other pack, the starter lines, is deliberately *not* read: its
/// entry point ships a written boundary against any headless reader that
/// surfaces a starter line outside screen (6)
/// (`conversation_starters_entry_point.dart`). AC-19 offers the occasion source
/// as an alternative ("kho mồi của STORY-005 **hoặc** dịp lịch âm gần nhất"),
/// and an occasion is what AC-21 needs anyway: a starter line is a sentence to
/// send, not a plan with a date.
class NextPlanSuggestionService {
  const NextPlanSuggestionService({required ActivityCardRepository repository})
      : _repository = repository;

  final ActivityCardRepository _repository;

  /// The occasions still ahead of [today], nearest first, capped at [slots].
  ///
  /// Pure over (package, today, slots) and synchronous: calling it twice with
  /// the same inputs returns the same suggestions in the same order (AC-19),
  /// and there is no cursor, no paging and no awaited step that a large pack
  /// could turn into a loading state (AC-35).
  static List<NextPlanSuggestion> suggest({
    required ContentPackage<CalendarEvent> package,
    required String today,
    int slots = maxNextPlanSuggestions,
  }) {
    final List<NextPlanSuggestion> upcoming = <NextPlanSuggestion>[];
    for (final CalendarEvent event in package.items) {
      final String? date = nearestUpcomingDate(event.dates, today);
      if (date == null) {
        continue;
      }
      upcoming.add(
        NextPlanSuggestion(
          id: event.id,
          title: event.name,
          date: date,
          activityType: event.activityType,
        ),
      );
    }

    upcoming.sort((NextPlanSuggestion a, NextPlanSuggestion b) {
      final int byDate = a.date.compareTo(b.date);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });

    return List<NextPlanSuggestion>.unmodifiable(
      upcoming.length <= slots ? upcoming : upcoming.sublist(0, slots),
    );
  }

  /// Creates the card for a chosen chip through STORY-001's single write gate
  /// (AC-20, BR-11). The status is not passed in: `createCard` always writes
  /// *Mới nghĩ ra*, so the pre-filled [NextPlanSuggestion.date] cannot promote
  /// the card to *Đã hẹn ngày*.
  Future<ActivityCard> accept(NextPlanSuggestion suggestion) =>
      _repository.createCard(
        NewActivityCard(
          title: suggestion.title,
          origin: ActivityCardOrigin.nextPlanAfterDate,
          scheduledOn: suggestion.date,
          activityType: suggestion.activityType,
        ),
      );

  /// The snackbar's "Hoàn tác". Goes back out through the same contract, so the
  /// card's photo rows cascade with it and nothing is left orphaned.
  Future<void> undo(ActivityCard card) => _repository.deleteCard(card.id);

  /// Loads the shipped occasion pack. Asset-only by construction — the loader
  /// has no HTTP client and no model call on this path (AC-30, R-7).
  static Future<ContentPackage<CalendarEvent>> loadPackage([
    ContentPackageLoader loader = const ContentPackageLoader(),
  ]) =>
      loader.load<CalendarEvent>(
        calendarEventsAssetKey,
        expectedSchemaId: calendarEventsSchemaId,
        itemParser: calendarEventFromJson,
      );
}

/// Whole days from [today] to [date], both civil `YYYY-MM-DD`. Parsed as UTC so
/// the subtraction never crosses a DST boundary and turns 9 days into 8.
int daysUntil({required String today, required String date}) =>
    DateTime.parse('${date}T00:00:00Z')
        .difference(DateTime.parse('${today}T00:00:00Z'))
        .inDays;
