// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_closure_dao.dart';

// ignore_for_file: type=lint
mixin _$ChapterClosureDaoMixin on DatabaseAccessor<CupidDatabase> {
  $ChapterClosuresTable get chapterClosures => attachedDatabase.chapterClosures;
  $ChapterClosureItemsTable get chapterClosureItems =>
      attachedDatabase.chapterClosureItems;
  ChapterClosureDaoManager get managers => ChapterClosureDaoManager(this);
}

class ChapterClosureDaoManager {
  final _$ChapterClosureDaoMixin _db;
  ChapterClosureDaoManager(this._db);
  $$ChapterClosuresTableTableManager get chapterClosures =>
      $$ChapterClosuresTableTableManager(
        _db.attachedDatabase,
        _db.chapterClosures,
      );
  $$ChapterClosureItemsTableTableManager get chapterClosureItems =>
      $$ChapterClosureItemsTableTableManager(
        _db.attachedDatabase,
        _db.chapterClosureItems,
      );
}
