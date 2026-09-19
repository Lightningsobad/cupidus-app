import 'package:drift/drift.dart';

import '../cupid_database.dart';
import '../tables/relationship_labels_table.dart';

part 'relationship_labels_dao.g.dart';

/// Row access for [RelationshipLabels].
///
/// Every method takes `ownerKey` explicitly and there is no unfiltered read on
/// purpose: a query that forgot the filter would show one user on a shared
/// device the labels the previous user declared.
///
/// There is deliberately no `countForOwner` and no aggregate query. AC-33
/// forbids lookup counters and streaks, and the cheapest way to keep that true
/// is for the query to not exist at this layer either.
@DriftAccessor(tables: [RelationshipLabels])
class RelationshipLabelsDao extends DatabaseAccessor<CupidDatabase>
    with _$RelationshipLabelsDaoMixin {
  RelationshipLabelsDao(super.db);

  Future<List<RelationshipLabelRow>> rowsForOwner(String ownerKey) =>
      (select(relationshipLabels)
            ..where((t) => t.ownerKey.equals(ownerKey))
            ..orderBy([
              (t) => OrderingTerm.asc(t.subject),
              (t) => OrderingTerm.asc(t.system),
            ]))
          .get();

  Future<RelationshipLabelRow?> rowByNaturalKey({
    required String ownerKey,
    required String subject,
    required String system,
  }) =>
      (select(relationshipLabels)
            ..where(
              (t) =>
                  t.ownerKey.equals(ownerKey) &
                  t.subject.equals(subject) &
                  t.system.equals(system),
            ))
          .getSingleOrNull();

  /// Writes on the natural key `(owner_key, subject, system)`. The conflict
  /// target is the table's UNIQUE constraint, so a second declaration updates
  /// the existing row in place and keeps its `id` and `created_at` — an edit is
  /// an edit, not a second label plus history nobody asked for.
  Future<void> upsertRow(RelationshipLabelsCompanion row) =>
      into(relationshipLabels).insert(
        row,
        onConflict: DoUpdate(
          (_) => RelationshipLabelsCompanion(
            value: row.value,
            certainty: row.certainty,
            updatedAt: row.updatedAt,
          ),
          target: [
            relationshipLabels.ownerKey,
            relationshipLabels.subject,
            relationshipLabels.system,
          ],
        ),
      );

  Future<int> deleteByNaturalKey({
    required String ownerKey,
    required String subject,
    required String system,
  }) =>
      (delete(relationshipLabels)
            ..where(
              (t) =>
                  t.ownerKey.equals(ownerKey) &
                  t.subject.equals(subject) &
                  t.system.equals(system),
            ))
          .go();
}
