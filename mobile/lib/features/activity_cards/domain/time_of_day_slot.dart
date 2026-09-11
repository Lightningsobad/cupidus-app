/// The closed vocabulary for `activity_cards.time_of_day_slot`
/// (`architecture/contract-summary.md` §3, ruling B-1). Wire values are ASCII,
/// stable, and append-only (R-15a).
///
/// The slot is only ever what the user picked. It must never be derived from
/// `scheduled_on`: a card in the *Mới nghĩ ra* pane has no date at all and
/// still has to be able to say "tối nay được".
enum TimeOfDaySlot {
  morning('sang'),
  noon('trua'),
  afternoon('chieu'),
  evening('toi');

  const TimeOfDaySlot(this.wireValue);

  final String wireValue;
}

/// Lenient read: an unrecognized string becomes `null` rather than throwing.
///
/// Every row written before schema v4 reads back through here, and so does any
/// value a future build stops recognizing. Case-sensitive on purpose — the wire
/// value is the exact ASCII identifier, not a display label.
TimeOfDaySlot? timeOfDaySlotFromWireValue(String? value) {
  if (value == null) {
    return null;
  }
  for (final TimeOfDaySlot slot in TimeOfDaySlot.values) {
    if (slot.wireValue == value) {
      return slot;
    }
  }
  return null;
}
