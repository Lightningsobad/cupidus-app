import 'package:drift/drift.dart';

/// Private journal rows — the first device-authoritative domain in
/// `CupidDatabase` (`architecture/solution.md` §1 Key Discovery 1). Unlike
/// messages/timeline/expenses, a lost row here cannot be refetched from the
/// server, so no code path may drop or recreate this table.
///
/// The absence of `deletedAt`, streak, goal, counter, and share-state columns
/// is itself a requirement (BR-2, BR-4) — do not add them.
class JournalEntries extends Table {
  /// Client-generated UUID v4, stable for the entry's whole life: editing
  /// rewrites this row instead of creating a new one (AC-3).
  TextColumn get id => text()();

  /// Backend `User.id`. Every read, write, and delete must filter on this
  /// column — it is the only multi-account isolation on a shared device,
  /// because [JournalDao] deliberately does not clear on sign-out.
  TextColumn get ownerUserId => text()();

  /// May be empty when the entry carries only photos.
  TextColumn get bodyText => text()();

  /// Epoch milliseconds UTC. Descending sort key of the entry list.
  IntColumn get createdAt => integer()();

  /// Epoch milliseconds UTC.
  IntColumn get updatedAt => integer()();

  /// `manual` | `external` — where the entry came from.
  TextColumn get origin => text().withDefault(const Constant('manual'))();

  /// Opaque provenance tag set by the calling story. Never rendered, never a
  /// link.
  TextColumn get originRef => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
