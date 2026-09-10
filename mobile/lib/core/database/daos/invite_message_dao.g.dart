// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_message_dao.dart';

// ignore_for_file: type=lint
mixin _$InviteMessageDaoMixin on DatabaseAccessor<CupidDatabase> {
  $ActivityCardsTable get activityCards => attachedDatabase.activityCards;
  $InviteMessagesTable get inviteMessages => attachedDatabase.inviteMessages;
  InviteMessageDaoManager get managers => InviteMessageDaoManager(this);
}

class InviteMessageDaoManager {
  final _$InviteMessageDaoMixin _db;
  InviteMessageDaoManager(this._db);
  $$ActivityCardsTableTableManager get activityCards =>
      $$ActivityCardsTableTableManager(_db.attachedDatabase, _db.activityCards);
  $$InviteMessagesTableTableManager get inviteMessages =>
      $$InviteMessagesTableTableManager(
        _db.attachedDatabase,
        _db.inviteMessages,
      );
}
