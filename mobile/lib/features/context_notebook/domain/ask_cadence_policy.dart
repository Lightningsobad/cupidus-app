import '../../../core/content/content_package.dart';
import 'context_content.dart';
import 'context_notebook_models.dart';

/// Questions the user waved away, for as long as this app process lives.
///
/// The scope is the session and not a clock on purpose: AC-3 forbids re-asking
/// a skipped question "ngay lập tức" and BR-2 makes the next question wait for
/// the next time the app actually needs one. A wall-clock cooldown would turn
/// that into a timer the user cannot see or reason about.
class AskSessionSkips {
  /// The one instance the app runs on. Tests build their own so a skip in one
  /// test cannot silence a question in the next.
  static final AskSessionSkips shared = AskSessionSkips();

  final Set<String> _skipped = <String>{};

  bool contains(String questionId) => _skipped.contains(questionId);

  void add(String questionId) => _skipped.add(questionId);

  void clear() => _skipped.clear();
}

/// Picks the single question an entry point may ask right now (BR-2).
///
/// There is deliberately no "ask the next one too" entry here: the caller gets
/// one question or none, so stacking two asks into a disguised form (AC-2) is
/// not expressible against this API.
class AskCadencePolicy {
  const AskCadencePolicy();

  /// Returns the question to ask, or `null` when this entry point has nothing
  /// left to ask.
  ///
  /// [neededFieldIds] are `contract-summary.md` §2 target ids in priority
  /// order. Within one target, package declaration order decides.
  ///
  /// A question already `answered` never comes back. A question skipped in
  /// this session is out for the rest of it. A question skipped in an earlier
  /// session drops behind every question that has never been asked, so the
  /// user meets something new before meeting a repeat.
  AskQuestion? nextQuestion({
    required ContentPackage<AskQuestion> questions,
    required List<String> neededFieldIds,
    required Map<String, AskPromptStatus> settled,
    required AskSessionSkips sessionSkips,
  }) {
    final List<AskQuestion> unasked = <AskQuestion>[];
    final List<AskQuestion> skippedBefore = <AskQuestion>[];

    for (final String fieldId in neededFieldIds) {
      final AskTarget? target = AskTarget.fromWireValue(fieldId);
      if (target == null) {
        throw ArgumentError.value(
          fieldId,
          'neededFieldIds',
          'not a contract-summary.md §2 ask target id',
        );
      }
      for (final AskQuestion question in questions.items) {
        if (question.target != target) {
          continue;
        }
        if (sessionSkips.contains(question.id)) {
          continue;
        }
        switch (settled[question.id]) {
          case AskPromptStatus.answered:
            continue;
          case AskPromptStatus.skipped:
            skippedBefore.add(question);
          case null:
            unasked.add(question);
        }
      }
    }

    if (unasked.isNotEmpty) {
      return unasked.first;
    }
    return skippedBefore.isEmpty ? null : skippedBefore.first;
  }
}
