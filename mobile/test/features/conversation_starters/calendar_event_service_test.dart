import 'dart:convert';
import 'dart:io';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/activity_cards/data/activity_card_repository_impl.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_notebook_models.dart';
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
  String? reasonTemplate,
  String? reasonContextSlot,
}) =>
    <String, Object?>{
      'id': id,
      'name': 'synthetic event $id',
      'calendar': calendar,
      'dates': dates,
      'activity_type': ?activityType,
      'reason_template': ?reasonTemplate,
      'reason_context_slot': ?reasonContextSlot,
    };

NotebookEntry _entry({
  required String id,
  required NotebookKind kind,
  required String value,
}) =>
    NotebookEntry(
      id: id,
      ownerKey: _ownerKey,
      kind: kind,
      value: value,
      source: ContextEntrySource.manual,
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    );

CalendarEvent _parsedEvent({
  required String id,
  String? reasonTemplate,
  String? reasonContextSlot,
}) =>
    _package(<Map<String, Object?>>[
      _event(
        id: id,
        dates: <String>['2026-12-24'],
        reasonTemplate: reasonTemplate,
        reasonContextSlot: reasonContextSlot,
      ),
    ]).items.single;

/// The notebook is a required input of the strip now that an event can carry a
/// reason line; the tests that are not about the reason pass an empty one.
Future<List<VisibleCalendarEvent>> _visible(
  CalendarEventService service, {
  List<NotebookEntry> notebook = const <NotebookEntry>[],
}) =>
    service.visibleEvents(
      ownerKey: _ownerKey,
      today: _today,
      notebook: notebook,
    );

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

      final List<VisibleCalendarEvent> visible = await _visible(service);

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

      final List<VisibleCalendarEvent> visible = await _visible(service);

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

      final List<VisibleCalendarEvent> visible = await _visible(service);

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
            in await _visible(service))
          e.id,
      ];
      final List<String> second = <String>[
        for (final VisibleCalendarEvent e
            in await _visible(service))
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
        await _visible(service),
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
      final List<VisibleCalendarEvent> visible = await _visible(service);

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
      final List<VisibleCalendarEvent> visible = await _visible(service);

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
      final List<VisibleCalendarEvent> visible = await _visible(service);

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
      final List<VisibleCalendarEvent> visible = await _visible(service);

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
      final List<VisibleCalendarEvent> before = await _visible(service);

      await service.addToStore(ownerKey: _ownerKey, event: before.first);

      final List<VisibleCalendarEvent> after = await _visible(service);
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
        await _visible(service),
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
      final VisibleCalendarEvent event = (await _visible(service))
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
        await _visible(service),
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
      // Đoạn đầu bị đóng băng chính là hợp đồng append-only: một câu chuyện sau
      // được phép nối thêm giá trị vào cuối, nhưng không được chen vào giữa
      // hay đổi chỗ `conversation_starter` (ghi vào Drift bằng wire value).
      const List<String> frozenPrefix = <String>[
        'manual',
        'pasted_link',
        'occasion_suggestion',
        'gift_suggestion',
        'conversation_starter',
      ];

      expect(
        ActivityCardOrigin.values
            .take(frozenPrefix.length)
            .map((ActivityCardOrigin o) => o.wireValue),
        frozenPrefix,
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

        final List<VisibleCalendarEvent> visible = await _visible(service);
        final ActivityCard? card = await service.addToStore(
          ownerKey: _ownerKey,
          event: visible.first,
        );
        await service.dismiss(ownerKey: _ownerKey, eventId: visible.last.id);

        expect(card!.origin, ActivityCardOrigin.conversationStarter);
        expect(
          await _visible(service),
          isEmpty,
        );
      }, createHttpClient: _explodingHttpClient);
    });
  });

  group('dòng lý do của sự kiện (ruling 2026-09-20 mục 7, AC-17)', () {
    test('sự kiện không khai template thì không có dòng lý do', () {
      expect(
        resolveEventReason(
          event: _parsedEvent(id: 'ev_no_reason'),
          notebook: <NotebookEntry>[
            _entry(
              id: 'nb_1',
              kind: NotebookKind.interest,
              value: 'Cà phê sáng',
            ),
          ],
          today: _today,
        ),
        isNull,
      );
    });

    test('có template nhưng sổ tay rỗng thì im lặng, không dựng câu rỗng', () {
      expect(
        resolveEventReason(
          event: _parsedEvent(
            id: 'ev_reason',
            reasonTemplate: 'Đúng dòng "{value}" trong sổ tay',
            reasonContextSlot: 'interest',
          ),
          notebook: const <NotebookEntry>[],
          today: _today,
        ),
        isNull,
      );
    });

    test('một mục khớp thì giá trị của mục đó thay vào chỗ {value}', () {
      expect(
        resolveEventReason(
          event: _parsedEvent(
            id: 'ev_reason',
            reasonTemplate: 'Đúng dòng "{value}" trong sổ tay',
            reasonContextSlot: 'interest',
          ),
          notebook: <NotebookEntry>[
            _entry(
              id: 'nb_1',
              kind: NotebookKind.interest,
              value: 'Cà phê sáng',
            ),
            _entry(
              id: 'nb_2',
              kind: NotebookKind.event,
              value: 'Sinh nhật mẹ',
            ),
          ],
          today: _today,
        ),
        'Đúng dòng "Cà phê sáng" trong sổ tay',
      );
    });

    test(
        'sổ tay nhiều mục: cùng ngày + cùng sự kiện luôn ra một mục, '
        'và thứ tự nhập vào không đổi kết quả', () {
      final CalendarEvent event = _parsedEvent(
        id: 'ev_reason',
        reasonTemplate: 'Đúng dòng "{value}" trong sổ tay',
        reasonContextSlot: 'interest',
      );
      final List<NotebookEntry> notebook = <NotebookEntry>[
        _entry(id: 'nb_1', kind: NotebookKind.interest, value: 'Cà phê sáng'),
        _entry(id: 'nb_2', kind: NotebookKind.interest, value: 'Leo núi'),
        _entry(id: 'nb_3', kind: NotebookKind.interest, value: 'Nấu ăn'),
        _entry(id: 'nb_4', kind: NotebookKind.interest, value: 'Xem phim'),
      ];

      final String? first = resolveEventReason(
        event: event,
        notebook: notebook,
        today: _today,
      );
      final String? shuffled = resolveEventReason(
        event: event,
        notebook: notebook.reversed.toList(growable: false),
        today: _today,
      );

      expect(first, isNotNull);
      expect(first, shuffled);
      expect(
        resolveEventReason(event: event, notebook: notebook, today: _today),
        first,
      );
    });

    test('sổ tay nhiều mục: hai sự kiện khác nhau không bị khoá vào một mục',
        () {
      final List<NotebookEntry> notebook = <NotebookEntry>[
        for (int index = 0; index < 8; index++)
          _entry(
            id: 'nb_$index',
            kind: NotebookKind.interest,
            value: 'Sở thích $index',
          ),
      ];
      final Set<String?> lines = <String?>{
        for (final String id in <String>['ev_a', 'ev_b', 'ev_c', 'ev_d'])
          resolveEventReason(
            event: _parsedEvent(
              id: id,
              reasonTemplate: 'Đúng dòng "{value}" trong sổ tay',
              reasonContextSlot: 'interest',
            ),
            notebook: notebook,
            today: _today,
          ),
      };

      expect(lines.length, greaterThan(1));
    });

    test('mục khớp có giá trị rỗng bị bỏ qua, không dựng dấu ngoặc trống', () {
      expect(
        resolveEventReason(
          event: _parsedEvent(
            id: 'ev_reason',
            reasonTemplate: 'Đúng dòng "{value}" trong sổ tay',
            reasonContextSlot: 'interest',
          ),
          notebook: <NotebookEntry>[
            _entry(id: 'nb_1', kind: NotebookKind.interest, value: ''),
          ],
          today: _today,
        ),
        isNull,
      );
    });

    test('dải sự kiện mang theo dòng lý do đã dựng sẵn', () async {
      final CalendarEventService service = serviceFor(
        _package(<Map<String, Object?>>[
          _event(
            id: 'ev_with_reason',
            dates: <String>['2026-12-24'],
            reasonTemplate: 'Đúng dòng "{value}" trong sổ tay',
            reasonContextSlot: 'interest',
          ),
          _event(id: 'ev_plain', dates: <String>['2026-12-25']),
        ]),
      );

      final List<VisibleCalendarEvent> visible = await _visible(
        service,
        notebook: <NotebookEntry>[
          _entry(
            id: 'nb_1',
            kind: NotebookKind.interest,
            value: 'Cà phê sáng',
          ),
        ],
      );

      expect(
        visible
            .map((VisibleCalendarEvent event) => event.reason)
            .toList(growable: false),
        <String?>['Đúng dòng "Cà phê sáng" trong sổ tay', null],
      );
    });

    test('không ô nào của dải còn sót chỗ giữ {value} khi sổ tay rỗng',
        () async {
      final CalendarEventService service = serviceFor(
        _package(<Map<String, Object?>>[
          _event(
            id: 'ev_with_reason',
            dates: <String>['2026-12-24'],
            reasonTemplate: 'Đúng dòng "{value}" trong sổ tay',
            reasonContextSlot: 'interest',
          ),
        ]),
      );

      final List<VisibleCalendarEvent> visible = await _visible(service);

      expect(visible.single.reason, isNull);
    });
  });
}
