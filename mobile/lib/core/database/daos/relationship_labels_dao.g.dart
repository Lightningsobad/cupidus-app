// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship_labels_dao.dart';

// ignore_for_file: type=lint
mixin _$RelationshipLabelsDaoMixin on DatabaseAccessor<CupidDatabase> {
  $RelationshipLabelsTable get relationshipLabels =>
      attachedDatabase.relationshipLabels;
  RelationshipLabelsDaoManager get managers =>
      RelationshipLabelsDaoManager(this);
}

class RelationshipLabelsDaoManager {
  final _$RelationshipLabelsDaoMixin _db;
  RelationshipLabelsDaoManager(this._db);
  $$RelationshipLabelsTableTableManager get relationshipLabels =>
      $$RelationshipLabelsTableTableManager(
        _db.attachedDatabase,
        _db.relationshipLabels,
      );
}
