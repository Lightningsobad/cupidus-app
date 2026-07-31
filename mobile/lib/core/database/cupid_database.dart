import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'daos/message_dao.dart';
import 'tables/messages_table.dart';

part 'cupid_database.g.dart';

/// The app's single Drift owner (`architecture/solution.md` §4 Boundaries And
/// Ownership). Later long-history domains (timeline, expenses per ADR-007)
/// add their tables and DAOs here, not in their own feature directories,
/// because Drift's single-database annotation forces one owner and `core/`
/// must never import `features/`.
@DriftDatabase(tables: [Messages], daos: [MessageDao])
class CupidDatabase extends _$CupidDatabase {
  CupidDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final file = File('${documentsDir.path}${Platform.pathSeparator}cupid.sqlite');
    return NativeDatabase.createInBackground(file);
  });
}
