/// The four readable phase labels of the solo stage (`ux/uiux-spec.md` §1).
/// A closed set of discrete labels, never a position on a continuous axis:
/// nothing here answers "how far to the next phase", which is exactly what the
/// spec's acceptance question forbids.
///
/// Wire values are the storage/native identifiers copied verbatim from
/// `architecture/contract-summary.md` §2 — ASCII, stable, append-only. The
/// Vietnamese label shown to the user comes from the content packages
/// (`phase_content.v1.json`), never from this enum.
enum SoloPhase {
  waiting('waiting'),
  upcoming('upcoming'),
  dateDay('date_day'),
  quiet('quiet');

  const SoloPhase(this.wireValue);

  final String wireValue;

  /// `null` for an unknown identifier rather than a default member, so a typo
  /// on the native boundary surfaces instead of silently becoming `quiet`.
  static SoloPhase? fromWireValue(String value) {
    for (final SoloPhase phase in values) {
      if (phase.wireValue == value) {
        return phase;
      }
    }
    return null;
  }
}

/// What the single phase resolver answers: which phase, and which card the
/// phase hangs on.
///
/// Deliberately carries no elapsed/remaining quantity of any kind. The
/// `waiting` branch must not be able to say how long the wait has been
/// (AC-6/AC-7), and the cheapest way to guarantee that is for the type itself
/// to have nowhere to put such a number. Surfaces that legitimately count down
/// (P4/P7, the `upcoming` line) derive it from [scheduledOn], which is `null`
/// on every branch where counting is forbidden.
class PhaseResolution {
  const PhaseResolution({
    required this.phase,
    this.cardId,
    this.scheduledOn,
    this.isBeforeYouGoDismissed = false,
  });

  final SoloPhase phase;

  /// The card the phase line attaches to, and the widget deep-link target.
  /// `null` only for [SoloPhase.quiet].
  final String? cardId;

  /// Civil date `YYYY-MM-DD` of the anchor card, present only for
  /// [SoloPhase.upcoming] and [SoloPhase.dateDay].
  final String? scheduledOn;

  /// Mirrors `BeforeYouGoPhase.isDismissed` when STORY-006 supplied one.
  /// `false` when it did not, which is the same state as "not dismissed" —
  /// there is no third "unknown" case to draw (AC-2).
  final bool isBeforeYouGoDismissed;

  @override
  bool operator ==(Object other) =>
      other is PhaseResolution &&
      other.phase == phase &&
      other.cardId == cardId &&
      other.scheduledOn == scheduledOn &&
      other.isBeforeYouGoDismissed == isBeforeYouGoDismissed;

  @override
  int get hashCode =>
      Object.hash(phase, cardId, scheduledOn, isBeforeYouGoDismissed);

  @override
  String toString() => 'PhaseResolution(${phase.wireValue}, card: $cardId, '
      'on: $scheduledOn, dismissed: $isBeforeYouGoDismissed)';
}
