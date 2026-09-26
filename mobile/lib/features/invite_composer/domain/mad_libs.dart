import '../../activity_cards/domain/activity_card.dart';
import '../../activity_cards/domain/time_of_day_slot.dart';
// Pure-Dart, widget-free and `intl`-free by construction (see its own library
// doc). Reused rather than re-derived so a date or duration reads identically
// on the card and inside an invite.
import '../../activity_cards/presentation/formatters/vi_field_format.dart';

/// The closed set of mad-libs variables (`architecture/contract-summary.md`
/// §2). Exactly five, and adding a sixth is a contract change rather than new
/// data. Wire values are the placeholder names preset authors write inside
/// `{...}`.
enum MadLibsVariable {
  activity('activity'),
  date('date'),
  time('time'),
  place('place'),
  duration('duration');

  const MadLibsVariable(this.wireValue);

  final String wireValue;

  static MadLibsVariable? fromWireValue(String value) {
    for (final MadLibsVariable variable in values) {
      if (variable.wireValue == value) {
        return variable;
      }
    }
    return null;
  }
}

/// Any brace-delimited token, not just the five known names: a preset writing
/// `{địa_điểm}` has to fail the parser loudly rather than slip through
/// unmatched and reach the reader as literal braces (AC-6).
final RegExp madLibsPlaceholderPattern = RegExp(r'\{([^{}]*)\}');

/// The values a single [ActivityCard] supplies to the renderer. A variable is
/// either present with a non-empty value or absent — there is no empty-string
/// state, because an empty value would render as a hole in the sentence
/// instead of dropping the clause that needs it (AC-6).
class MadLibsValues {
  MadLibsValues(Map<MadLibsVariable, String> sources)
      : variables = Map<MadLibsVariable, String>.unmodifiable(<MadLibsVariable,
            String>{
          for (final MapEntry<MadLibsVariable, String> entry in sources.entries)
            if (entry.value.trim().isNotEmpty) entry.key: entry.value.trim(),
        });

  /// Resolves the five variables from one card. Deterministic and total: the
  /// same card always yields the same map (AC-9).
  ///
  /// `place` is the raw `location` text the user typed — never geocoded and
  /// never reformatted. A card without one takes the AC-6 branch, exactly like
  /// the other four variables, because the constructor drops empty values.
  factory MadLibsValues.fromCard(ActivityCard card) =>
      MadLibsValues(<MadLibsVariable, String>{
        MadLibsVariable.activity: card.title,
        MadLibsVariable.date: formatLongViDate(card.scheduledOn),
        MadLibsVariable.time: _timeOfDayWord(card.timeOfDaySlot),
        MadLibsVariable.place: card.location ?? '',
        MadLibsVariable.duration: formatDurationMinutes(card.durationMinutes),
      });

  final Map<MadLibsVariable, String> variables;

  String? operator [](MadLibsVariable variable) => variables[variable];

  bool contains(MadLibsVariable variable) => variables.containsKey(variable);
}

/// Lower-case on purpose: the engine never changes case, so a slot word has to
/// arrive in the shape a preset author expects mid-sentence. These are field
/// value renderings of a closed enum, not invite prose — invite sentences stay
/// in the asset package (R-15a).
String _timeOfDayWord(TimeOfDaySlot? slot) {
  switch (slot) {
    case null:
      return '';
    case TimeOfDaySlot.morning:
      return 'sáng';
    case TimeOfDaySlot.noon:
      return 'trưa';
    case TimeOfDaySlot.afternoon:
      return 'chiều';
    case TimeOfDaySlot.evening:
      return 'tối';
  }
}
