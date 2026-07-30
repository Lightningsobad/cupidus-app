/// The 5 frozen backend `Mood` values (`architecture/solution.md` §4
/// D-010-2; backend `Mood` enum,
/// `backend/src/modules/vibes/entities/vibe.entity.ts:4-10`). This is the
/// only file in the vibes feature allowed to contain a mood string literal;
/// every other file goes through [wireValue]/[fromWire].
enum VibeMood {
  happy('happy', 'happy'),
  sad('sad', 'sad'),
  angry('angry', 'angry'),
  horny('horny', 'spicy'),
  tired('tired', 'tired');

  const VibeMood(this.wireValue, this.displayId);

  /// The backend `Mood` enum value sent/received on the wire.
  final String wireValue;

  /// The UI-facing id; `horny` displays as `spicy` (D-010-2).
  final String displayId;

  /// Returns `null` for any value not frozen here (R-010-5), so an
  /// unexpected future server value is skipped rather than crashing the app.
  static VibeMood? fromWire(String value) {
    for (final mood in VibeMood.values) {
      if (mood.wireValue == value) {
        return mood;
      }
    }
    return null;
  }
}
