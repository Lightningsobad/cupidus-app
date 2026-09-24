import '../../../core/content/content_package.dart';
import '../../activity_cards/domain/activity_card.dart';
import '../../activity_cards/domain/activity_card_repository.dart';
import '../../context_notebook/context_notebook_entry_point.dart';
import '../data/calendar_event_state_repository.dart';
import 'starter_content.dart';
import 'starter_selector.dart';

/// A calendar event that is still worth offering, carrying the one date it
/// will be offered for.
class VisibleCalendarEvent {
  const VisibleCalendarEvent({
    required this.event,
    required this.date,
    this.reason,
  });

  /// Carried whole so the screen reads `name` and `calendar` off the package
  /// rather than re-deriving either in Dart (R-15a).
  final CalendarEvent event;

  /// Civil `YYYY-MM-DD`: this event's own nearest occurrence on or after the
  /// injected `today`.
  final String date;

  /// The filled reason line, or `null` when this event declares none or the
  /// notebook holds nothing to fill it with. Never a half-filled string.
  final String? reason;

  String get id => event.id;
}

/// Filters the shipped event package down to what the reader may still act on,
/// and turns one chosen event into a card through STORY-001's write gate
/// (AC-11, AC-12, AC-13, BR-3).
class CalendarEventService {
  const CalendarEventService({
    required ActivityCardRepository cardRepository,
    required CalendarEventStateRepository stateRepository,
    required ContentPackage<CalendarEvent> package,
  })  : _cardRepository = cardRepository,
        _stateRepository = stateRepository,
        _package = package;

  final ActivityCardRepository _cardRepository;
  final CalendarEventStateRepository _stateRepository;
  final ContentPackage<CalendarEvent> _package;

  /// Events with an occurrence on or after [today] that the reader has not
  /// already converted or dismissed.
  ///
  /// A past event simply is not in the returned list, and no other method
  /// reports it either: there is no "you missed this" door anywhere on this
  /// path (AC-13, R-1c/R-1d). [today] is injected for the same reason the
  /// selector's is — this file reads no clock (AC-17).
  Future<List<VisibleCalendarEvent>> visibleEvents({
    required String ownerKey,
    required String today,
    required List<NotebookEntry> notebook,
  }) async {
    final Set<String> handled = await _stateRepository.handledEventIds(
      ownerKey,
    );

    final List<VisibleCalendarEvent> visible = <VisibleCalendarEvent>[];
    for (final CalendarEvent event in _package.items) {
      if (handled.contains(event.id)) {
        continue;
      }
      final String? date = nearestUpcomingDate(event.dates, today);
      if (date == null) {
        continue;
      }
      visible.add(
        VisibleCalendarEvent(
          event: event,
          date: date,
          reason: resolveEventReason(
            event: event,
            notebook: notebook,
            today: today,
          ),
        ),
      );
    }

    visible.sort((VisibleCalendarEvent a, VisibleCalendarEvent b) {
      final int byDate = a.date.compareTo(b.date);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
    return List<VisibleCalendarEvent>.unmodifiable(visible);
  }

  /// Creates the `idea` card for [event] and records the event as converted.
  ///
  /// Returns `null` when this event was already handled, so a second tap adds
  /// no second card (AC-12). The card's status is not passed in: `createCard`
  /// always writes `idea`, so a non-null `scheduledOn` cannot promote the card
  /// to `scheduled` (BR-3).
  Future<ActivityCard?> addToStore({
    required String ownerKey,
    required VisibleCalendarEvent event,
  }) async {
    final Set<String> handled = await _stateRepository.handledEventIds(
      ownerKey,
    );
    if (handled.contains(event.id)) {
      return null;
    }

    final ActivityCard card = await _cardRepository.createCard(
      NewActivityCard(
        title: event.event.name,
        origin: ActivityCardOrigin.conversationStarter,
        scheduledOn: event.date,
        activityType: event.event.activityType,
      ),
    );
    await _stateRepository.markHandled(
      ownerKey: ownerKey,
      eventId: event.id,
      state: CalendarEventHandledState.converted,
    );
    return card;
  }

  /// One tap, no reason asked, nothing created (AC-14, BR-10).
  Future<void> dismiss({
    required String ownerKey,
    required String eventId,
  }) =>
      _stateRepository.markHandled(
        ownerKey: ownerKey,
        eventId: eventId,
        state: CalendarEventHandledState.dismissed,
      );
}

/// The reason line drawn under [event]'s name, or `null` when the event
/// declares none and when nothing the reader wrote can fill the one it declares
/// (AC-15/AC-16: the sentence comes from the pack, the value from the
/// notebook — never from a keyword guess, a model, or the network).
///
/// Pure over (event, notebook, today), and it picks the notebook entry with
/// exactly the key [StarterSelector] uses for a contextual starter, so the same
/// day renders the same reason twice running (AC-17).
String? resolveEventReason({
  required CalendarEvent event,
  required List<NotebookEntry> notebook,
  required String today,
}) {
  final String? template = event.reasonTemplate;
  final StarterContextSlot? slot = event.reasonContextSlot;
  if (template == null || slot == null) {
    return null;
  }

  final List<NotebookEntry> matches = notebook
      .where(
        (NotebookEntry entry) =>
            entry.kind.wireValue == slot.wireValue && entry.value.isNotEmpty,
      )
      .toList(growable: false)
    ..sort((NotebookEntry a, NotebookEntry b) => a.id.compareTo(b.id));
  if (matches.isEmpty) {
    return null;
  }

  final int key = stableContentKey('$today|${event.id}');
  return template.replaceAll(
    starterValueToken,
    matches[key % matches.length].value,
  );
}

/// The smallest date in [dates] that is not before [today], or `null` when
/// every occurrence has passed. Civil `YYYY-MM-DD` strings sort
/// chronologically, so this is a string comparison by design — no instant, no
/// timezone (`contract-summary.md` §3).
String? nearestUpcomingDate(List<String> dates, String today) {
  String? nearest;
  for (final String date in dates) {
    if (date.compareTo(today) < 0) {
      continue;
    }
    if (nearest == null || date.compareTo(nearest) < 0) {
      nearest = date;
    }
  }
  return nearest;
}
