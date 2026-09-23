import 'dart:io';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/journal/journal_media_store.dart';
import 'package:cupid_mobile/features/chapter_closure/data/stage1_last_opened_store.dart';
import 'package:cupid_mobile/features/chapter_closure/data/stage1_wipe_registry.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The registry is only as good as its completeness: a REQ-016 table nobody
/// registered is data that silently survives "rời giai đoạn 1". This test is
/// the tripwire — it compares `Stage1WipeRegistry.tables` against the database's
/// own table list, so adding a table without registering it fails here rather
/// than on a user's device.
void main() {
  late CupidDatabase database;
  late Stage1WipeRegistry registry;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    registry = Stage1WipeRegistry(
      db: database,
      journalMediaStore: JournalMediaStore(
        baseDirectory: () async => Directory.systemTemp,
        ownerUserId: () => 'user-1',
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  /// Server-authoritative read-through caches from earlier requirements. They
  /// are refetchable, they are not stage-1 material, and they are cleared by
  /// sign-out rather than by leaving — so they are excluded by name, one
  /// deliberate decision per table, never by a pattern that could swallow a
  /// future REQ-016 table.
  Set<String> nonReq016Tables() => <TableInfo<Table, dynamic>>{
        database.messages,
        database.timelineEntries,
        database.timelineSyncState,
        database.expenses,
        database.expenseSyncMetadata,
      }.map((TableInfo<Table, dynamic> t) => t.actualTableName).toSet();

  Set<String> registeredTables() => registry.tables
      .map((Stage1WipeTable entry) => entry.tableName)
      .toSet();

  test('mọi bảng REQ-016 trong lược đồ đều có mặt trong registry', () {
    final Set<String> all = database.allTables
        .map((TableInfo<Table, dynamic> t) => t.actualTableName)
        .toSet();
    final Set<String> expected = all.difference(nonReq016Tables());

    expect(
      registeredTables(),
      expected,
      reason: 'bảng REQ-016 mới phải được đăng ký trong Stage1WipeRegistry '
          'hoặc được loại trừ có chủ ý trong nonReq016Tables()',
    );
    expect(expected, hasLength(14));
  });

  test('danh sách loại trừ chỉ gồm các bảng đệm của máy chủ', () {
    expect(nonReq016Tables(), hasLength(5));
    expect(
      database.allTables
          .map((TableInfo<Table, dynamic> t) => t.actualTableName)
          .toSet(),
      containsAll(nonReq016Tables()),
    );
  });

  test('phép so sánh này thực sự đỏ khi thiếu một bảng', () {
    // Nếu bỏ qua đúng một bảng đã đăng ký, phép so sánh ở test đầu phải thất
    // bại. Không có kiểm chứng này thì một so sánh luôn đúng vẫn "xanh".
    final Set<String> all = database.allTables
        .map((TableInfo<Table, dynamic> t) => t.actualTableName)
        .toSet();
    final Set<String> expected = all.difference(nonReq016Tables());
    final Set<String> missingOne = registeredTables()
      ..remove(registry.tables.first.tableName);

    expect(missingOne, isNot(expected));
  });

  test('mỗi vị từ chủ sở hữu chạy được trên lược đồ thật', () async {
    for (final Stage1WipeTable entry in registry.tables) {
      final QueryRow row = await database.customSelect(
        'SELECT COUNT(*) AS c FROM ${entry.tableName} WHERE ${entry.ownerWhere}',
        variables: <Variable<Object>>[const Variable<String>('user-1')],
      ).getSingle();
      expect(row.read<int>('c'), 0, reason: entry.deleteStatement);
    }
  });

  test('bảng con đứng trước bảng cha trong thứ tự xoá', () {
    final List<String> order = registry.tables
        .map((Stage1WipeTable entry) => entry.tableName)
        .toList();

    void childFirst(String child, String parent) {
      expect(
        order.indexOf(child) < order.indexOf(parent),
        isTrue,
        reason: '$child phải bị xoá trước $parent',
      );
    }

    childFirst(
      database.activityCardPhotos.actualTableName,
      database.activityCards.actualTableName,
    );
    childFirst(
      database.inviteMessages.actualTableName,
      database.activityCards.actualTableName,
    );
    childFirst(
      database.journalPhotos.actualTableName,
      database.journalEntries.actualTableName,
    );
    childFirst(
      database.chapterClosureItems.actualTableName,
      database.chapterClosures.actualTableName,
    );
  });

  test('gốc media và khoá tuỳ chọn được đăng ký đúng phần của REQ-016', () {
    expect(
      registry.mediaRoots
          .map((Stage1MediaRoot root) => root.name)
          .toList(growable: false),
      <String>[JournalMediaStore.mediaRootName],
    );
    expect(
      Stage1WipeRegistry.preferenceKeys,
      <String>[
        'before_you_go.dismissed_on.',
        Stage1LastOpenedStore.preferenceKey,
      ],
    );
  });
}
