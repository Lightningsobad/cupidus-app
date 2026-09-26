import '../../../../core/database/tables/thank_you_activations_table.dart';

/// The lifetime state of one card's single "cảm ơn + chốt việc kế tiếp" turn
/// (BR-2).
///
/// [consumed] and [cancelled] are absorbing: AC-4 forbids re-activating a card
/// that already spent its turn, and AC-5 makes a silently cancelled turn just
/// as final, so neither has an edge back to [armed].
enum ThankYouActivationStatus {
  armed(ThankYouActivationStatuses.armed),
  consumed(ThankYouActivationStatuses.consumed),
  cancelled(ThankYouActivationStatuses.cancelled);

  const ThankYouActivationStatus(this.wireValue);

  final String wireValue;

  static ThankYouActivationStatus fromWireValue(String value) =>
      values.firstWhere((status) => status.wireValue == value);
}

class ThankYouActivation {
  const ThankYouActivation({
    required this.cardId,
    required this.status,
    required this.armedOn,
    this.consumedAt,
  });

  final String cardId;
  final ThankYouActivationStatus status;

  /// Civil date `YYYY-MM-DD` in the device calendar, see
  /// [ThankYouActivations.armedOn].
  final String armedOn;

  final DateTime? consumedAt;
}

/// The device's own calendar day for [moment], formatted the way every civil
/// date in this codebase is stored (`activity_cards.scheduled_on`).
///
/// AC-1/AC-2 are a calendar-day question, so the comparison never goes through
/// a UTC instant or an "has 24h passed" duration: a card armed at 23:59 is
/// eligible two minutes later at 00:01, and one armed at 00:01 is not eligible
/// at 23:59 the same day.
String civilDateOf(DateTime moment) {
  final local = moment.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year.toString().padLeft(4, '0')}-$month-$day';
}
