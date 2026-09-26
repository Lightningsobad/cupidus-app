import 'package:drift/drift.dart';

/// The zodiac/MBTI labels the user declares for themselves and for the other
/// person (`architecture/contract-summary.md` §4).
///
/// These rows are device-authoritative and exist on no server, so every later
/// migration touching this table must be additive.
///
/// This table is deliberately NOT part of the relationship notebook.
/// `notebook_entries.kind` is a closed `interest | event` enum owned by
/// STORY-004, and widening it here would rewrite another story's contract
/// (BR-10). BR-5 permits *storing* a label; it does not dictate *where*
/// (`architecture/solution.md` §1 Key Discovery 5).
///
/// The column set below is a closed allowlist enforced by
/// `test/features/compatibility_lookup/relationship_label_repository_test.dart`.
/// Permanently forbidden here: any column holding a lookup result — a band id,
/// cell text, a personality judgement, or a score/rank (AC-31); any column
/// measuring the other person's behaviour (`partner_*`, `seen_*`, `reply_*`,
/// `frequency_*`) (AC-30); and any lookup-count column (AC-33). A user who
/// declares a label is not thereby generating a metric about anybody.
@DataClassName('RelationshipLabelRow')
class RelationshipLabels extends Table {
  /// Client-generated UUID v4, permanently stable — never a rowid/autoincrement.
  TextColumn get id => text()();

  /// Backend `User.id`; every query filters on this column, which is what keeps
  /// two users sharing one device from reading each other's labels.
  TextColumn get ownerKey => text()();

  /// `self` | `partner`. Stored as text with Dart constants rather than an enum
  /// index, because an index silently changes meaning the day someone inserts a
  /// value into the middle of the enum.
  TextColumn get subject => text()();

  /// `zodiac` | `mbti`.
  TextColumn get system => text()();

  /// An `axis_value.id` from the matching `req016.compat_*` pack.
  TextColumn get value => text()();

  /// `known` | `guess`. A guess stays visibly the *user's* guess wherever it is
  /// rendered; the app never promotes it to a fact it confirms (AC-8).
  TextColumn get certainty => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  /// One person holds exactly one zodiac label for themselves and one for the
  /// other person — a business rule, not an optimisation. Writes upsert on this
  /// natural key instead of appending a new row per edit (AC-9).
  @override
  List<Set<Column>> get uniqueKeys => [
        {ownerKey, subject, system},
      ];
}
