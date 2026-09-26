import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/features/conversation_starters/data/calendar_event_state_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CupidDatabase database;
  late CalendarEventStateRepository repository;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    repository = CalendarEventStateRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('chưa ghi gì thì không có sự kiện nào được coi là đã xử lý', () async {
    expect(await repository.handledEventIds('user-1'), isEmpty);
  });

  test('ghi rồi đọc lại được id sự kiện', () async {
    await repository.markHandled(
      ownerKey: 'user-1',
      eventId: 'req016.event.tet',
      state: CalendarEventHandledState.converted,
    );

    expect(
      await repository.handledEventIds('user-1'),
      <String>{'req016.event.tet'},
    );
  });

  test('ghi lại cùng event_id là cập nhật tại chỗ, không sinh dòng thứ hai',
      () async {
    await repository.markHandled(
      ownerKey: 'user-1',
      eventId: 'req016.event.tet',
      state: CalendarEventHandledState.dismissed,
      updatedAt: DateTime.utc(2026, 9, 10),
    );
    await repository.markHandled(
      ownerKey: 'user-1',
      eventId: 'req016.event.tet',
      state: CalendarEventHandledState.converted,
      updatedAt: DateTime.utc(2026, 9, 11),
    );

    final rows = await database.select(database.calendarEventState).get();

    expect(rows, hasLength(1));
    expect(rows.single.state, 'converted');
    expect(rows.single.updatedAt.toUtc(), DateTime.utc(2026, 9, 11));
  });

  test('trạng thái của người dùng này không rò sang người dùng khác', () async {
    await repository.markHandled(
      ownerKey: 'user-1',
      eventId: 'req016.event.tet',
      state: CalendarEventHandledState.converted,
    );
    await repository.markHandled(
      ownerKey: 'user-2',
      eventId: 'req016.event.trung_thu',
      state: CalendarEventHandledState.dismissed,
    );

    expect(
      await repository.handledEventIds('user-1'),
      <String>{'req016.event.tet'},
    );
    expect(
      await repository.handledEventIds('user-2'),
      <String>{'req016.event.trung_thu'},
    );
  });

  test('cùng event_id dưới hai owner_key là hai dòng độc lập', () async {
    await repository.markHandled(
      ownerKey: 'user-1',
      eventId: 'req016.event.tet',
      state: CalendarEventHandledState.converted,
    );
    await repository.markHandled(
      ownerKey: 'user-2',
      eventId: 'req016.event.tet',
      state: CalendarEventHandledState.dismissed,
    );

    final rows = await database.select(database.calendarEventState).get();

    expect(rows, hasLength(2));
  });

  test('giá trị wire của trạng thái là hợp đồng với gói nội dung', () {
    expect(
      CalendarEventHandledState.values.map((state) => state.wireValue),
      <String>['converted', 'dismissed'],
    );
    expect(
      CalendarEventHandledState.fromWireValue('dismissed'),
      CalendarEventHandledState.dismissed,
    );
    expect(CalendarEventHandledState.fromWireValue('unknown'), isNull);
  });
}
