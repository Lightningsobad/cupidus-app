import 'package:drift/drift.dart';

/// Local-only read-through cache of the frozen backend `Message` entity
/// (`architecture/solution.md` §2 Data model / migration contract).
///
/// Server-authoritative, schemaVersion 1, no migration. Deliberately has no
/// `localId`, `pending`, `queued`, `outbox`, `retryCount`, or `sendState`
/// column — their absence is the AC4/OQ4/ADR-007 gate: this app never models
/// an offline write queue.
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get senderId => text()();
  TextColumn get receiverId => text()();
  TextColumn get content => text()();
  TextColumn get type => text()();
  TextColumn get status => text()();
  DateTimeColumn get readAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
