import 'package:drift/drift.dart';

import '../../../../core/database/cupid_database.dart';
import '../../../../core/database/tables/thank_you_activations_table.dart';

/// Row access for `thank_you_activations`.
///
/// A plain accessor rather than a generated drift one: the ledger is owned by
/// this sub-feature, and registering a DAO would put a `features/` symbol into
/// the database annotation that `core/` must stay free of (ADR-010).
class ThankYouActivationDao {
  const ThankYouActivationDao(this._database);

  final CupidDatabase _database;

  Future<ThankYouActivationRow?> rowFor(String cardId) {
    return (_database.select(_database.thankYouActivations)
          ..where((row) => row.cardId.equals(cardId)))
        .getSingleOrNull();
  }

  /// `INSERT OR IGNORE`, so "arm only when the card has no row yet" is decided
  /// by the primary key inside SQLite instead of by a read-then-write that two
  /// concurrent status changes could interleave.
  Future<void> insertArmed({
    required String cardId,
    required String armedOn,
  }) {
    return _database.into(_database.thankYouActivations).insert(
          ThankYouActivationsCompanion.insert(
            cardId: cardId,
            status: ThankYouActivationStatuses.armed,
            armedOn: armedOn,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Narrowed to rows still `armed`, which is what makes `consumed` and
  /// `cancelled` absorbing in SQL rather than by caller discipline. Returns the
  /// number of rows written.
  Future<int> settleArmed({
    required String cardId,
    required String status,
    DateTime? consumedAt,
  }) {
    return (_database.update(_database.thankYouActivations)
          ..where(
            (row) =>
                row.cardId.equals(cardId) &
                row.status.equals(ThankYouActivationStatuses.armed),
          ))
        .write(
      ThankYouActivationsCompanion(
        status: Value(status),
        consumedAt:
            consumedAt == null ? const Value.absent() : Value(consumedAt),
      ),
    );
  }
}
