import 'checkin_capture_content.dart';
import 'context_notebook_models.dart';

/// Reads which of [cardIds] are still readable. Read-only and set-shaped on
/// purpose: a probe that returned cards could be used to render a card anywhere
/// the label appears, and the label is not a link (AC-15, BR-9).
typedef ReadableCardProbe = Future<Set<String>> Function(Set<String> cardIds);

/// Resolves the origin label for a whole screenful of notebook rows.
///
/// Lives in the domain rather than in the row widget so no surface can
/// hand-build the label out of a card title, and so the degrade in [labelsFor]
/// is the only path that exists (KD-2, AC-9).
class CheckinOriginResolver {
  const CheckinOriginResolver({required this.copy, required this.probe});

  final CheckinCaptureCopySet copy;
  final ReadableCardProbe probe;

  /// Label per entry id, for check-in entries only. Entries the user added
  /// themselves are absent from the result, which is what keeps every existing
  /// row unchanged (BR-11).
  ///
  /// The probe runs once for the whole list, never once per row. A probe that
  /// throws is read as "nothing is readable": an unreadable card degrades the
  /// label, and a read error must never reach the screen (KD-2).
  Future<Map<String, String>> labelsFor(List<NotebookEntry> entries) async {
    final Set<String> cardIds = <String>{
      for (final NotebookEntry entry in entries)
        if (entry.originCheckInRef != null && entry.originCardId != null)
          entry.originCardId!,
    };

    Set<String> readable = const <String>{};
    if (cardIds.isNotEmpty) {
      try {
        readable = await probe(cardIds);
      } catch (_) {
        readable = const <String>{};
      }
    }

    final Map<String, String> labels = <String, String>{};
    for (final NotebookEntry entry in entries) {
      if (entry.originCheckInRef == null) {
        continue;
      }
      final String? cardId = entry.originCardId;
      final bool stillThere = cardId != null && readable.contains(cardId);
      labels[entry.id] = copy.originLabel(
        cardTitle: stillThere ? entry.originCardTitle : null,
      );
    }
    return Map<String, String>.unmodifiable(labels);
  }
}
