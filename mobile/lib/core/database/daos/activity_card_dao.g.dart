// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_card_dao.dart';

// ignore_for_file: type=lint
mixin _$ActivityCardDaoMixin on DatabaseAccessor<CupidDatabase> {
  $ActivityCardsTable get activityCards => attachedDatabase.activityCards;
  $ActivityCardPhotosTable get activityCardPhotos =>
      attachedDatabase.activityCardPhotos;
  ActivityCardDaoManager get managers => ActivityCardDaoManager(this);
}

class ActivityCardDaoManager {
  final _$ActivityCardDaoMixin _db;
  ActivityCardDaoManager(this._db);
  $$ActivityCardsTableTableManager get activityCards =>
      $$ActivityCardsTableTableManager(_db.attachedDatabase, _db.activityCards);
  $$ActivityCardPhotosTableTableManager get activityCardPhotos =>
      $$ActivityCardPhotosTableTableManager(
        _db.attachedDatabase,
        _db.activityCardPhotos,
      );
}
