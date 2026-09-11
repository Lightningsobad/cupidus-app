import '../../activity_cards/domain/activity_card.dart';
import '../../activity_cards/domain/time_of_day_slot.dart';
// Pure-Dart, widget-free and `intl`-free. Reused rather than re-derived so a
// date or a duration reads identically on the card and inside a script.
import '../../activity_cards/presentation/formatters/vi_field_format.dart';
import '../../context_notebook/context_notebook_entry_point.dart';
import 'date_script_content.dart';

/// The values one card plus the notebook supply to [renderPart].
///
/// Deterministic and total: the same card and the same notebook always yield
/// the same map (AC-8). A variable is either present with a non-empty value or
/// absent — there is no empty-string state, because an empty value renders as a
/// hole in the sentence instead of dropping the sentence that needs it (AC-10).
///
/// No clock: everything date-dependent arrives through [card].
Map<DateScriptVariable, String> bindVariables(
  ActivityCard card,
  List<NotebookEntry> notebook,
) {
  final Map<DateScriptVariable, String> sources = <DateScriptVariable, String>{
    DateScriptVariable.activity: card.title,
    DateScriptVariable.date: formatLongViDate(card.scheduledOn),
    DateScriptVariable.time: _timeOfDayWord(card.timeOfDaySlot),
    DateScriptVariable.place: card.location ?? '',
    DateScriptVariable.duration: formatDurationMinutes(card.durationMinutes),
    DateScriptVariable.interest:
        _firstWritten(notebook, NotebookKind.interest) ?? '',
    DateScriptVariable.event: _firstWritten(notebook, NotebookKind.event) ?? '',
  };

  return Map<DateScriptVariable, String>.unmodifiable(
    <DateScriptVariable, String>{
      for (final MapEntry<DateScriptVariable, String> entry in sources.entries)
        if (entry.value.trim().isNotEmpty) entry.key: entry.value.trim(),
    },
  );
}

/// The surviving sentences of [part], in the order the author declared them.
///
/// A sentence whose `requires` is not fully satisfied is dropped whole rather
/// than patched, so what is left is exactly as its author wrote it and no
/// punctuation repair heuristic ever runs — the STORY-002 renderer convention
/// (`architecture/contract-summary.md` §3). Because every part ships at least
/// one sentence with `requires: []`, no combination of missing card fields can
/// empty a part (AC-23/AC-34).
List<String> renderPart(
  DateScriptPreset preset,
  DateScriptPart part,
  Map<DateScriptVariable, String> values,
) {
  final List<String> rendered = <String>[];
  for (final DateScriptPartContent content in preset.parts) {
    if (content.part != part) {
      continue;
    }
    for (final DateScriptSentence sentence in content.sentences) {
      if (sentence.requires.any(
        (DateScriptVariable variable) => !values.containsKey(variable),
      )) {
        continue;
      }
      final String filled = _fill(sentence.text, values).trim();
      if (filled.isNotEmpty) {
        rendered.add(filled);
      }
    }
  }
  return List<String>.unmodifiable(rendered);
}

/// One paragraph per part, which is the shape the screen reads (P3).
///
/// The engine only joins, with a single space: it does not capitalize, add or
/// remove full stops, or otherwise edit grammar — wording and punctuation
/// belong to the content side (`architecture/contract-summary.md` §3).
Map<DateScriptPart, String> renderScript(
  DateScriptPreset preset,
  Map<DateScriptVariable, String> values,
) {
  return Map<DateScriptPart, String>.unmodifiable(
    <DateScriptPart, String>{
      for (final DateScriptPart part in DateScriptPart.values)
        part: renderPart(preset, part, values).join(' '),
    },
  );
}

/// A placeholder is only substituted when its variable is present, and
/// [renderPart] has already dropped every sentence that names a missing one, so
/// no `{` or `}` can reach the reader (AC-10/AC-37).
String _fill(String text, Map<DateScriptVariable, String> values) =>
    text.replaceAllMapped(dateScriptPlaceholderPattern, (Match match) {
      final DateScriptVariable? variable = DateScriptVariable.fromWireValue(
        match.group(1)!,
      );
      final String? value = variable == null ? null : values[variable];
      return value ?? match.group(0)!;
    });

/// The entry the user wrote down for [kind], picked by lowest [NotebookEntry.id]
/// so the result does not depend on the order the caller happened to pass.
///
/// Deliberately not "most relevant" and not "most recent": ranking the notebook
/// by relevance, or preferring what was written last, is a measurement of the
/// other person's behaviour (R-1b/BR-12). Lowest id is an arbitrary but stable
/// rule, which is the only property AC-8 asks for.
String? _firstWritten(List<NotebookEntry> notebook, NotebookKind kind) {
  NotebookEntry? earliest;
  for (final NotebookEntry entry in notebook) {
    if (entry.kind != kind) {
      continue;
    }
    if (earliest == null || entry.id.compareTo(earliest.id) < 0) {
      earliest = entry;
    }
  }
  return earliest?.value;
}

/// Lower-case on purpose: the engine never changes case, so a slot word has to
/// arrive in the shape a preset author expects mid-sentence.
///
/// A field-value rendering of a closed enum, not script prose — script
/// sentences stay in the asset package (R-15a). Its twin in `invite_composer`
/// is private to that feature, and §5 keeps this feature out of another
/// feature's internals, so the four words live here too rather than behind a
/// shared import that would couple the two families.
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
