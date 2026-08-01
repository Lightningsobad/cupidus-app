// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_dao.dart';

// ignore_for_file: type=lint
mixin _$ExpenseDaoMixin on DatabaseAccessor<CupidDatabase> {
  $ExpensesTable get expenses => attachedDatabase.expenses;
  $ExpenseSyncMetadataTable get expenseSyncMetadata =>
      attachedDatabase.expenseSyncMetadata;
  ExpenseDaoManager get managers => ExpenseDaoManager(this);
}

class ExpenseDaoManager {
  final _$ExpenseDaoMixin _db;
  ExpenseDaoManager(this._db);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db.attachedDatabase, _db.expenses);
  $$ExpenseSyncMetadataTableTableManager get expenseSyncMetadata =>
      $$ExpenseSyncMetadataTableTableManager(
        _db.attachedDatabase,
        _db.expenseSyncMetadata,
      );
}
