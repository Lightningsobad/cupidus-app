/// Domain vocabulary of the relationship notebook
/// (`architecture/contract-summary.md` §2, §4).
///
/// Every wire value here is a stable identifier: it is persisted in a column
/// and referenced by content packs, so it is append-only and never renamed.
library;

/// The closed set of notebook entry kinds (R-1f). A third "đánh giá người ấy"
/// kind is permanently excluded by AC-6.
enum NotebookKind {
  interest('interest'),
  event('event');

  const NotebookKind(this.wireValue);

  final String wireValue;

  static NotebookKind fromWireValue(String value) => NotebookKind.values
      .firstWhere((kind) => kind.wireValue == value, orElse: _unknownKind);

  static Never _unknownKind() =>
      throw ArgumentError('Unknown NotebookKind wire value');
}

/// How an entry got written. Internal provenance only — never rendered as a
/// metric or a quality signal.
enum ContextEntrySource {
  askOnTheSpot('ask_on_the_spot'),
  manual('manual');

  const ContextEntrySource(this.wireValue);

  final String wireValue;

  static ContextEntrySource fromWireValue(String value) =>
      ContextEntrySource.values.firstWhere(
        (source) => source.wireValue == value,
        orElse: _unknownSource,
      );

  static Never _unknownSource() =>
      throw ArgumentError('Unknown ContextEntrySource wire value');
}

/// Terminal state of one ask-on-the-spot question. `skipped` is a first-class
/// outcome that keeps the flow going, not a failure (AC-3/BR-3).
enum AskPromptStatus {
  answered('answered'),
  skipped('skipped');

  const AskPromptStatus(this.wireValue);

  final String wireValue;

  static AskPromptStatus fromWireValue(String value) =>
      AskPromptStatus.values.firstWhere(
        (state) => state.wireValue == value,
        orElse: _unknownStatus,
      );

  static Never _unknownStatus() =>
      throw ArgumentError('Unknown AskPromptStatus wire value');
}

/// One row of the notebook, as the user wrote it.
class NotebookEntry {
  const NotebookEntry({
    required this.id,
    required this.ownerKey,
    required this.kind,
    required this.value,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.detail,
    this.eventOn,
    this.questionId,
    this.originCheckInRef,
    this.originCardId,
    this.originCardTitle,
  });

  final String id;
  final String ownerKey;
  final NotebookKind kind;
  final String value;

  /// A note inside this same entry (AC-6), not a separate category.
  final String? detail;

  /// Civil date `YYYY-MM-DD`; always `null` when [kind] is
  /// [NotebookKind.interest].
  final String? eventOn;

  final ContextEntrySource source;

  /// Stable id of the question that produced this entry (AC-4), or `null` when
  /// the user added it manually.
  final String? questionId;

  /// Which check-in wrote this entry, `null` for every other entry. This — not
  /// [source] — is what "came from a check-in" means, so no existing `switch`
  /// on [ContextEntrySource] changes meaning (BR-11).
  final String? originCheckInRef;

  /// The card the check-in was about; the existence probe behind the AC-9
  /// label degrade.
  final String? originCardId;

  /// Card title as it read when the entry was written, so a later rename does
  /// not move the label (AC-5). `null` when it was unreadable then (AC-9).
  final String? originCardTitle;

  final DateTime createdAt;
  final DateTime updatedAt;
}

/// One soft skill in the profile. There is deliberately no level, star, score,
/// rank, or proficiency field (AC-12) — adding one is a contract violation, not
/// a feature.
class SkillEntry {
  const SkillEntry({
    required this.id,
    required this.ownerKey,
    required this.label,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.seedId,
  });

  final String id;
  final String ownerKey;
  final String label;

  /// Stable id of the seed chip this came from; `null` means the user typed it.
  final String? seedId;

  final ContextEntrySource source;
  final DateTime createdAt;
  final DateTime updatedAt;
}
