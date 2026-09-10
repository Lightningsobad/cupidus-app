import 'package:drift/drift.dart';

/// The relationship notebook's three client-owned tables
/// (`architecture/contract-summary.md` §4). Like `activity_cards` these rows
/// exist on no server, so every later migration touching them must be additive
/// (`architecture/solution.md` §1 Key Discovery).
///
/// Multi-user isolation on a shared device comes from [ownerKey] filtering in
/// `ContextNotebookRepository`, never from wiping the tables on sign-out.
///
/// The column sets below are closed allowlists enforced by
/// `test/core/database/context_notebook_migration_test.dart`. Any column that
/// grades a skill (level, star, score, rank, proficiency) is forbidden by
/// R-1b/AC-12, and any column that measures the partner's behavior
/// (`partner_*`, `seen_*`, `reply_*`, `frequency_*`) is forbidden by AC-25.
@DataClassName('NotebookEntryRow')
class NotebookEntries extends Table {
  /// Client-generated UUID v4, permanently stable (R-15a) — never a
  /// rowid/autoincrement, because later phases reference entries by this id.
  TextColumn get id => text()();

  /// Backend `User.id`; every query filters on this column.
  TextColumn get ownerKey => text()();

  /// `interest` | `event` — a closed enum (R-1f, §2). There is deliberately no
  /// third "nhận xét về người ấy" kind (AC-6).
  TextColumn get kind => text()();

  /// What the user wrote, verbatim after trimming.
  TextColumn get value => text()();

  /// A note *inside* this same entry, not a third category (AC-6).
  TextColumn get detail => text().nullable()();

  /// Civil date `YYYY-MM-DD`, meaningful only when [kind] is `event`.
  /// Deliberately not a DateTime so it never shifts with the host's UTC offset.
  TextColumn get eventOn => text().nullable()();

  /// `ask_on_the_spot` | `manual` (§2). Internal provenance, never rendered as
  /// a metric.
  TextColumn get source => text()();

  /// Stable id of the question that produced this entry, so the answer reads
  /// back attached to its question (AC-4). NULL for a manually typed entry.
  TextColumn get questionId => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One soft skill the user claims. There is no proficiency dimension of any
/// kind here, by design (AC-12): the profile is a list, not a scorecard.
@DataClassName('SkillProfileEntryRow')
class SkillProfileEntries extends Table {
  TextColumn get id => text()();

  TextColumn get ownerKey => text()();

  /// Display label as the user chose or typed it.
  TextColumn get label => text()();

  /// Stable `items[].id` of the seed chip this came from; NULL means the user
  /// typed it themselves.
  TextColumn get seedId => text().nullable()();

  /// `ask_on_the_spot` | `manual` (§2).
  TextColumn get source => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Whether one ask-on-the-spot question has already been answered or skipped,
/// so it is not asked again (AC-2/BR-2).
///
/// There is no counter column: "how many times we asked" is exactly the kind of
/// nudging pressure R-1b rules out, and the cheapest way to keep that true is
/// for the column to not exist.
@DataClassName('AskPromptStateRow')
class AskPromptState extends Table {
  TextColumn get ownerKey => text()();

  /// Stable question id from `req016.ask_questions.v1`.
  TextColumn get questionId => text()();

  /// `answered` | `skipped`.
  TextColumn get state => text()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {ownerKey, questionId};
}
