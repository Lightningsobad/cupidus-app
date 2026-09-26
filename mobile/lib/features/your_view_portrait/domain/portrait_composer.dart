import '../../../core/content/content_package.dart';
import '../../../core/content/invariant_terms.dart';
import 'portrait_content.dart';

/// One settled answer, in the shape the composer substitutes from.
///
/// A domain-side copy of the three stored fields rather than the row type of
/// `data/portrait_answer_repository.dart`: no `domain/` file in this codebase
/// imports `data/`, and the composer must stay a pure function over values.
/// The caller maps one to the other.
class PortraitSettledAnswer {
  const PortraitSettledAnswer({
    required this.skipped,
    this.answerValue,
    this.notebookEntryId,
  });

  /// A skip is a normal outcome, and it reads here exactly like a question
  /// never reached: the variable is simply absent (AC-27).
  final bool skipped;

  /// Set only for a `portrait.guess` answer.
  final String? answerValue;

  /// Set only for a `notebook.*` answer. The text itself is looked up in the
  /// notebook, so deleting the entry thins the portrait instead of leaving a
  /// stale second copy (contract-summary.md §4, AC-22).
  final String? notebookEntryId;
}

/// One section as it will be read: the clauses that survived, and the single
/// line to ask the other person that closes it.
///
/// Read-only and text-only. There is no field here a surface could turn into
/// progress: no counts, no "how complete", no ordering weight.
class ComposedSection {
  const ComposedSection({
    required this.sectionId,
    required this.heading,
    required this.clauses,
    required this.askId,
    required this.askText,
  });

  final String sectionId;
  final String heading;

  /// Surviving clause texts in the pack's declaration order. Empty is a valid
  /// section: it then renders as its heading and the ask line alone
  /// (AC-19/BR-9).
  final List<String> clauses;

  final String askId;
  final String askText;

  /// The clauses joined by exactly one space. The editorial side owns wording
  /// and punctuation: nothing here capitalises, trims a full stop, or adds one
  /// (contract-summary.md §4).
  String get paragraph => clauses.join(' ');
}

final RegExp _placeholderPattern = RegExp(r'\{([^{}]*)\}');

/// Turns answers into readable portrait sections.
///
/// Pure: no I/O, no clock, no randomness, no asset reads. The same
/// `(sections, asks, answers, notebookValues, askCursor)` always composes the
/// same strings, character for character (AC-29/AC-30).
///
/// [notebookValues] maps `notebook_entries.id` to the text the user wrote.
/// [askCursor] is held by the caller for one screen lifetime and is never
/// stored (contract-summary.md §5).
List<ComposedSection> composePortrait({
  required ContentPackage<PortraitSection> sections,
  required ContentPackage<PortraitAsk> asks,
  required Map<String, PortraitSettledAnswer> answers,
  required Map<String, String> notebookValues,
  required int askCursor,
}) {
  final List<ComposedSection> composed = <ComposedSection>[];

  for (final PortraitSection section in sections.items) {
    final Map<String, String> values = _boundValues(
      bindings: section.bindings,
      answers: answers,
      notebookValues: notebookValues,
    );

    // A clause is measured again *after* substitution, because the invariant
    // rules of a pack only cover what an editor wrote. The seam between an
    // authored clause and a user-typed answer can produce a denylisted string
    // that neither side contains on its own: an answer ending in a word for the
    // other person, dropped in front of an authored "is ...", reads back as an
    // assertive claim about them (R-1/AC-4). Free text makes this unfixable in
    // content, so the clause is dropped whole here — the engine still writes no
    // string of its own, and a thinner section is a valid result (AC-19/BR-9).
    final List<String> clauses = <String>[];
    for (final PortraitClause clause in section.clauses) {
      if (!clause.requires.every(values.containsKey)) {
        continue;
      }
      final String? rendered = _render(clause.text, values);
      if (rendered == null || invariantHitsIn(rendered).isNotEmpty) {
        continue;
      }
      clauses.add(rendered);
    }

    final String askId =
        section.askIds[askCursor % section.askIds.length];
    final PortraitAsk? ask = asks.itemById(askId);
    if (ask == null) {
      throw StateError(
        'section "${section.id}" ends with ask "$askId", which the ask store '
        'does not have',
      );
    }

    composed.add(
      ComposedSection(
        sectionId: section.id,
        heading: section.heading,
        clauses: List<String>.unmodifiable(clauses),
        askId: ask.id,
        askText: ask.text,
      ),
    );
  }

  return List<ComposedSection>.unmodifiable(composed);
}

/// Variable name -> the text to substitute. A variable is absent when the
/// question was skipped, never reached, or when the notebook entry it points at
/// is gone.
Map<String, String> _boundValues({
  required Map<String, String> bindings,
  required Map<String, PortraitSettledAnswer> answers,
  required Map<String, String> notebookValues,
}) {
  final Map<String, String> values = <String, String>{};
  for (final MapEntry<String, String> binding in bindings.entries) {
    final PortraitSettledAnswer? answer = answers[binding.value];
    if (answer == null || answer.skipped) {
      continue;
    }
    final String? entryId = answer.notebookEntryId;
    final String? value =
        entryId == null ? answer.answerValue : notebookValues[entryId];
    if (value == null || value.isEmpty) {
      continue;
    }
    values[binding.key] = value;
  }
  return values;
}

/// Substitutes every placeholder in one pass, or returns null when any of them
/// is unbound — a clause is dropped whole, never half-rendered and never left
/// with a visible `{variable}` (contract-summary.md §4).
///
/// One pass rather than a replace per variable, so a user-typed answer that
/// happens to contain braces cannot be substituted into again.
String? _render(String text, Map<String, String> values) {
  bool unbound = false;
  final String rendered = text.replaceAllMapped(_placeholderPattern, (match) {
    final String? value = values[match.group(1)];
    if (value == null) {
      unbound = true;
      return '';
    }
    return value;
  });
  return unbound ? null : rendered;
}
