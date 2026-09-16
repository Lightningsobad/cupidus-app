import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/activity_cards/data/activity_card_repository_impl.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/conversation_starters/data/calendar_event_state_repository.dart';
import 'package:cupid_mobile/features/conversation_starters/domain/calendar_event_service.dart';
import 'package:cupid_mobile/features/conversation_starters/domain/starter_content.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const String _ownerKey = 'user-1';
const String _today = '2026-09-12';

ContentPackage<CalendarEvent> _package(List<Map<String, Object?>> items) =>
    ContentPackage.parse<CalendarEvent>(
      jsonEncode(<String, Object?>{
        'id': 'calendar_events',
        'version': '1.0.0',
        'schema_id': calendarEventsSchemaId,
        'items': items,
      }),
      expectedSchemaId: calendarEventsSchemaId,
      itemParser: calendarEventFromJson,
    );

Map<String, Object?> _event({
  required String id,
  required List<String> dates,
  String calendar = 'solar',
  String? activityType = 'outing',
}) =>
    <String, Object?>{
      'id': id,
      'name': 'synthetic event $id',
      'calendar': calendar,
      'dates': dates,
      if (activityType != null) 'activity_type': activityType,
    };

Never _explodingHttpClient(SecurityContext? context) => throw StateError(
      'R-7/AC-16 violated: the calendar event path opened an HttpClient',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CupidDatabase database;
  late ActivityCardRepository cardRepository;
  late CalendarEventStateRepository stateRepository;

  CalendarEventService serviceFor(ContentPackage<CalendarEvent> package) =>
      CalendarEventService(
        cardRepository: cardRepository,
        stateRepository: stateRepository,
        package: package,
      );

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    cardRepository = ActivityCardRepositoryImpl(
      dao: database.activityCardDao,
      ownerKeyStore: BackendUserIdStore()..updateUserId(_ownerKey),
    );
    stateRepository = CalendarEventStateRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('lọc theo ngày (AC-13, R-1c/R-1d)', () {
    test('sự kiện đã qua ngày không xuất hiện và không có API nào nhắc lại nó',
        () async {
      final CalendarEventService service = serviceFor(
        _package(<Map<String, Object?>>[
          _event(id: 'ev_past', dates: <String>['2026-09-11']),
          _event(id: 'ev_future', dates: <String>['2026-12-24']),
        ]),
      );

      final List<VisibleCalendarEvent> visible = await service.visibleEvents(
        ownerKey: _ownerKey,
        today: _today,
      );

      expect(
        visible.map((VisibleCalendarEvent e) => e.id),
        <String>['ev_future'],
      );
    });

    test('sự kiện rơi đúng hôm nay vẫn còn được chào mời', () async {
      final CalendarEventService service = serviceFor(
        _package(<Map<String, Object?>>[
          _event(id: 'ev_today', dates: <String>[_today]),
        ]),
      );

      final List<VisibleCalendarEvent> visible = await service.visibleEvents(
        ownerKey: _ownerKey,
        today: _today,
      );

      expect(visible.single.date, _today);
    });

    test('mỗi mục mang ngày sắp tới gần nhất của chính nó', () async {
      final CalendarEventService service = serviceFor(
        _package(<Map<String, Object?>>[
          _event(
            id: 'ev_multi',
            dates: <String>['2025-01-01', '2027-02-02', '2026-10-05'],
          ),
        ]),
      );

      final List<VisibleCalendarEvent> visible = await service.visibleEvents(
        ownerKey: _ownerKey,
        today: _today,
      );

      expect(visible.single.date, '2026-10-05');
    });

    test('thứ tự là ngày gần nhất trước, hoà thì theo id — tất định (AC-17)',
        () async {
      final CalendarEventService service = serviceFor(
        _package(<Map<String, Object?>>[
          _event(id: 'ev_c', dates: <String>['2026-12-24']),
          _event(id: 'ev_a', dates: <String>['2026-12-24']),
          _event(id: 'ev_b', dates: <String>['2026-10-05']),
        ]),
      );

      final List<String> first = <String>[
        for (final VisibleCalendarEvent e
            in await service.visibleEvents(ownerKey: _ownerKey, today: _today))
          e.id,
      ];
      final List<String> second = <String>[
        for (final VisibleCalendarEvent e
            in await service.visibleEvents(ownerKey: _ownerKey, today: _today))
          e.id,
      ];

      expect(first, <String>['ev_b', 'ev_a', 'ev_c']);
      expect(second, first);
    });

    test('gói rỗng rơi vào danh sách rỗng, không lỗi (AC-30)', () async {
      final CalendarEventService service = serviceFor(
        _package(const <Map<String, Object?>>[]),
      );

      expect(
        await service.visibleEvents(ownerKey: _ownerKey, today: _today),
        isEmpty,
      );
    });
  });

  group('đổi sự kiện thành thẻ (AC-11, BR-3)', () {
    test('thẻ tạo ra là idea, nguồn sinh conversation_starter, mang sẵn ngày '
        'sự kiện', () async {
      final CalendarEventService service = serviceFor(
        _package(<Map<String, Object?>>[
          _event(id: 'ev_future', dates: <String>['2026-12-24']),
        ]),
      );
      final List<VisibleCalendarEvent> visible = await service.visibleEvents(
        ownerKey: _ownerKey,
        today: _today,
      );

      final ActivityCard? card = await service.addToStore(
        ownerKey: _ownerKey,
        event: visible.single,
      );

      expect(card, isNotNull);
      expect(card!.title, 'synthetic event ev_future');
      expect(card.status, ActivityCardStatus.idea);
      expect(card.origin, ActivityCardOrigin.conversationStarter);
      expect(card.scheduledOn, '2026-12-24');
      expect(card.activityType, ActivityType.outing);
    });

    test('một scheduled_on khác null không làm thẻ thành scheduled', () async {
      final CalendarEventService service = serviceFor(
        _package(<Map<String, Object?>>[
          _event(id: 'ev_future', dates: <String>['2026-12-24']),
        ]),
      );
      final List<VisibleCalendarEvent> visible = await service.visibleEvents(
        ownerKey: _ownerKey,
        today: _today,
      );

      await service.addToStore(ownerKey: _ownerKey, event: visible.single);

      final List<ActivityCard> scheduled = await cardRepository.cardsByStatus(
        status: ActivityCardStatus.scheduled,
        limit: 10,
      );
      final List<ActivityCard> ideas = await cardRepository.cardsByStatus(
        status: ActivityCardStatus.idea,
        limit: 10,
      );

      expect(scheduled, isEmpty);
      expect(ideas, hasLength(1));
    });

    test('sự kiện không khai activity_type vẫn tạo được thẻ', () async {
      final CalendarEventService service = serviceFor(
        _package(<Map<String, Object?>>[
          _event(
            id: 'ev_plain',
            dates: <String>['2026-12-24'],
            activityType: null,
          ),
        ]),
      );
      final List<VisibleCalendarEvent> visible = await service.visibleEvents(
        ownerKey: _ownerKey,
        today: _today,
      );

      final ActivityCard? card = await service.addToStore(
        ownerKey: _ownerKey,
        event: visible.single,
      );

      expect(card!.activityType, isNull);
    });

    test('bấm hai lần cho cùng event_id chỉ tạo một thẻ (AC-12)', () async {
      final CalendarEventService service = serviceFor(
        _package(<Map<String, Object?>>[
          _event(id: 'ev_future', dates: <String>['2026-12-24']),
        ]),
      );
      final List<VisibleCalendarEvent> visible = await service.visibleEvents(
        ownerKey: _ownerKey,
        today: _today,
      );

      final ActivityCard? first = await service.addToStore(
        ownerKey: _ownerKey,
        event: visible.single,
      );
      final ActivityCard? second = await service.addToStore(
        ownerKey: _ownerKey,
        event: visible.single,
      );

      expect(first, isNotNull);
      expect(second, isNull);
      expect(
        await cardRepository.cardsByStatus(
          status: ActivityCardStatus.idea,
          limit: 10,
        ),
        hasLength(1),
      );
    });

    test('sự kiện đã đổi thành thẻ biến khỏi danh sách; màn này không giữ bản '
        'sao riêng (AC-12, SC-1\')', () async {
      final CalendarEventService service = serviceFor(
        _package(<Map<String, Object?>>[
          _event(id: 'ev_one', dates: <String>['2026-12-24']),
          _event(id: 'ev_two', dates: <String>['2026-12-25']),
        ]),
      );
      final List<VisibleCalendarEvent> before = await service.visibleEvents(
        ownerKey: _ownerKey,
        today: _today,
      );

      await service.addToStore(ownerKey: _ownerKey, event: before.first);

      final List<VisibleCalendarEvent> after = await service.visibleEvents(
        ownerKey: _ownerKey,
        today: _today,
      );
      expect(after.map((VisibleCalendarEvent e) => e.id), <String>['ev_two']);

      final List<ActivityCard> ideas = await cardRepository.cardsByStatus(
        status: ActivityCardStatus.idea,
        limit: 10,
      );
      expect(ideas.single.title, 'synthetic event ev_one');
    });
  });

  group('bỏ qua một chạm (AC-14, BR-10)', () {
    test('dismiss không tạo thẻ nào và không hỏi lý do', () async {
      final CalendarEventService service = serviceFor(
        _package(<Map<String, Object?>>[
          _event(id: 'ev_future', dates: <String>['2026-12-24']),
        ]),
      );

      await service.dismiss(ownerKey: _ownerKey, eventId: 'ev_future');

      expect(
        await service.visibleEvents(ownerKey: _ownerKey, today: _today),
        isEmpty,
      );
      expect(
        await cardRepository.cardsByStatus(
          status: ActivityCardStatus.idea,
          limit: 10,
        ),
        isEmpty,
      );
    });

    test('bỏ qua rồi thì addToStore cũng không tạo thẻ nữa', () async {
      final CalendarEventService service = serviceFor(
        _package(<Map<String, Object?>>[
          _event(id: 'ev_future', dates: <String>['2026-12-24']),
        ]),
      );
      final VisibleCalendarEvent event = (await service.visibleEvents(
        ownerKey: _ownerKey,
        today: _today,
      ))
          .single;

      await service.dismiss(ownerKey: _ownerKey, eventId: event.id);
      final ActivityCard? card = await service.addToStore(
        ownerKey: _ownerKey,
        event: event,
      );

      expect(card, isNull);
    });

    test('trạng thái của người dùng khác không lọc danh sách của người này',
        () async {
      final CalendarEventService service = serviceFor(
        _package(<Map<String, Object?>>[
          _event(id: 'ev_future', dates: <String>['2026-12-24']),
        ]),
      );

      await service.dismiss(ownerKey: 'user-2', eventId: 'ev_future');

      expect(
        await service.visibleEvents(ownerKey: _ownerKey, today: _today),
        hasLength(1),
      );
    });
  });

  group('hợp đồng nguồn sinh append-only', () {
    test('fromWireValue vẫn đọc được cả bốn giá trị cũ sau khi thêm giá trị '
        'mới', () {
      expect(
        ActivityCardOrigin.fromWireValue('manual'),
        ActivityCardOrigin.manual,
      );
      expect(
        ActivityCardOrigin.fromWireValue('pasted_link'),
        ActivityCardOrigin.pastedLink,
      );
      expect(
        ActivityCardOrigin.fromWireValue('occasion_suggestion'),
        ActivityCardOrigin.occasionSuggestion,
      );
      expect(
        ActivityCardOrigin.fromWireValue('gift_suggestion'),
        ActivityCardOrigin.giftSuggestion,
      );
      expect(
        ActivityCardOrigin.fromWireValue('conversation_starter'),
        ActivityCardOrigin.conversationStarter,
      );
    });

    test('giá trị mới nằm cuối, không chen vào giữa', () {
      expect(
        ActivityCardOrigin.values.map((ActivityCardOrigin o) => o.wireValue),
        <String>[
          'manual',
          'pasted_link',
          'occasion_suggestion',
          'gift_suggestion',
          'conversation_starter',
        ],
      );
    });
  });

  group('không lời gọi mạng nào trên đường sự kiện (AC-15, AC-16, R-7)', () {
    test('lọc + tạo thẻ + bỏ qua chạy trọn dưới HttpClient ném lỗi nếu bị mở',
        () async {
      await HttpOverrides.runZoned(() async {
        final CalendarEventService service = serviceFor(
          _package(<Map<String, Object?>>[
            _event(id: 'ev_one', dates: <String>['2026-12-24']),
            _event(id: 'ev_two', dates: <String>['2026-12-25']),
          ]),
        );

        final List<VisibleCalendarEvent> visible = await service.visibleEvents(
          ownerKey: _ownerKey,
          today: _today,
        );
        final ActivityCard? card = await service.addToStore(
          ownerKey: _ownerKey,
          event: visible.first,
        );
        await service.dismiss(ownerKey: _ownerKey, eventId: visible.last.id);

        expect(card!.origin, ActivityCardOrigin.conversationStarter);
        expect(
          await service.visibleEvents(ownerKey: _ownerKey, today: _today),
          isEmpty,
        );
      }, createHttpClient: _explodingHttpClient);
    });
  });
}
