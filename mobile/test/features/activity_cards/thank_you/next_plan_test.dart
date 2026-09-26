import 'dart:convert';

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/data/activity_card_repository_impl.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/data/thank_you_activation_dao.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/data/thank_you_activation_repository_impl.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/domain/next_plan_suggestion_service.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/domain/thank_you_activation_service.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/presentation/widgets/thank_you_block.dart';
import 'package:cupid_mobile/features/conversation_starters/domain/starter_content.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const String _ownerKey = 'owner-1';
const String _today = '2026-09-21';

/// The day the card was marked *Đã đi rồi*, and the morning after — the only
/// state in which the block, and therefore phần 3, draws at all.
final DateTime _armedDay = DateTime(2026, 9, 20, 21, 30);
final DateTime _nextDay = DateTime(2026, 9, 21, 8, 15);

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
  String? name,
  String? activityType = 'outing',
}) =>
    <String, Object?>{
      'id': id,
      'name': name ?? 'Dịp $id',
      'calendar': 'lunar',
      'dates': dates,
      'activity_type': ?activityType,
    };

ActivityCard _doneCard() => ActivityCard(
      id: 'card-1',
      ownerKey: _ownerKey,
      title: 'Đi ăn lẩu ở Trúc Bạch',
      status: ActivityCardStatus.done,
      origin: ActivityCardOrigin.manual,
      activityType: ActivityType.dining,
      invited: true,
      replyState: ActivityCardReplyState.answered,
      createdAt: _armedDay,
      updatedAt: _armedDay,
    );

/// A real `Scaffold`, because the undo affordance of AC-20 is a snackbar and a
/// `ScaffoldMessenger` with no `Scaffold` under it registers one without ever
/// drawing it.
Widget _host(Widget child) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      locale: const Locale('vi'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: CupidPlatformOverride(
        platform: CupidPlatform.material,
        child: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('nguồn gợi ý — tất định, không gọi mạng (AC-19, AC-35)', () {
    test('cùng gói và cùng ngày thì trả về đúng một tập, đúng một thứ tự',
        () async {
      final ContentPackage<CalendarEvent> package = _package(
        <Map<String, Object?>>[
          _event(id: 'ev_xa', dates: <String>['2026-12-24']),
          _event(id: 'ev_gan', dates: <String>['2026-09-25']),
          _event(id: 'ev_giua', dates: <String>['2026-10-06']),
        ],
      );

      final List<String> first = NextPlanSuggestionService.suggest(
        package: package,
        today: _today,
      ).map((NextPlanSuggestion s) => '${s.id}@${s.date}').toList();
      final List<String> second = NextPlanSuggestionService.suggest(
        package: package,
        today: _today,
      ).map((NextPlanSuggestion s) => '${s.id}@${s.date}').toList();

      expect(first, second);
      expect(first, <String>[
        'ev_gan@2026-09-25',
        'ev_giua@2026-10-06',
        'ev_xa@2026-12-24',
      ]);
    });

    test('hai dịp trùng ngày vẫn có thứ tự cố định, không phụ thuộc thứ tự gói',
        () {
      List<String> idsOf(List<Map<String, Object?>> items) =>
          NextPlanSuggestionService.suggest(
            package: _package(items),
            today: _today,
          ).map((NextPlanSuggestion s) => s.id).toList();

      final List<Map<String, Object?>> a = <Map<String, Object?>>[
        _event(id: 'ev_b', dates: <String>['2026-09-25']),
        _event(id: 'ev_a', dates: <String>['2026-09-25']),
      ];

      expect(idsOf(a), <String>['ev_a', 'ev_b']);
      expect(idsOf(a.reversed.toList()), <String>['ev_a', 'ev_b']);
    });

    test('dịp đã qua bị bỏ, dịp rơi đúng hôm nay vẫn còn', () {
      final List<NextPlanSuggestion> suggestions =
          NextPlanSuggestionService.suggest(
        package: _package(<Map<String, Object?>>[
          _event(id: 'ev_qua', dates: <String>['2026-09-20']),
          _event(id: 'ev_hom_nay', dates: <String>[_today]),
        ]),
        today: _today,
      );

      expect(
        suggestions.map((NextPlanSuggestion s) => s.id),
        <String>['ev_hom_nay'],
      );
    });

    test('gói chỉ còn một dịp thì trả về đúng một, không có ô giữ chỗ nào', () {
      final List<NextPlanSuggestion> suggestions =
          NextPlanSuggestionService.suggest(
        package: _package(<Map<String, Object?>>[
          _event(id: 'ev_mot', dates: <String>['2026-09-25']),
          _event(id: 'ev_het_han', dates: <String>['2026-01-01']),
        ]),
        today: _today,
      );

      expect(suggestions, hasLength(1));
      expect(suggestions.single.id, 'ev_mot');
    });

    test('gói rỗng trả về danh sách rỗng chứ không phải lỗi', () {
      expect(
        NextPlanSuggestionService.suggest(
          package: _package(const <Map<String, Object?>>[]),
          today: _today,
        ),
        isEmpty,
      );
    });

    test('gói rất lớn không đổi kết quả và không thêm bước chờ nào', () {
      final List<Map<String, Object?>> many = <Map<String, Object?>>[
        for (int i = 0; i < 500; i++)
          _event(
            id: 'ev_${i.toString().padLeft(4, '0')}',
            dates: <String>[
              DateTime(2026, 9, 25)
                  .add(Duration(days: i))
                  .toIso8601String()
                  .substring(0, 10),
            ],
          ),
      ];

      // Synchronous by construction: a large pack has no awaited step that a
      // spinner or a "đang tải" row could hang off (AC-35).
      final List<NextPlanSuggestion> suggestions =
          NextPlanSuggestionService.suggest(
        package: _package(many),
        today: _today,
      );

      expect(suggestions, hasLength(maxNextPlanSuggestions));
      expect(
        suggestions.map((NextPlanSuggestion s) => s.id),
        <String>['ev_0000', 'ev_0001', 'ev_0002'],
      );
    });

    test('danh sách trả về không sửa được từ bên ngoài', () {
      final List<NextPlanSuggestion> suggestions =
          NextPlanSuggestionService.suggest(
        package: _package(<Map<String, Object?>>[
          _event(id: 'ev_mot', dates: <String>['2026-09-25']),
        ]),
        today: _today,
      );

      expect(() => suggestions.clear(), throwsUnsupportedError);
    });
  });

  group('phần 3 trong khối — tạo thẻ qua đúng một cửa (AC-20, AC-21)', () {
    late CupidDatabase database;
    late ActivityCardRepository repository;
    late DateTime clock;
    late ThankYouActivationService thankYou;

    Future<List<ActivityCard>> ideas() => repository.cardsByStatus(
          status: ActivityCardStatus.idea,
          limit: 50,
        );

    Future<void> pumpBlock(
      WidgetTester tester, {
      required ContentPackage<CalendarEvent> package,
    }) async {
      tester.view.physicalSize = const Size(415, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(
          ThankYouSection(
            card: _doneCard(),
            options: ThankYouOptions(
              service: thankYou,
              nextPlan: NextPlanOptions(
                today: _nextDay,
                package: package,
                repository: repository,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    setUp(() async {
      database = CupidDatabase(NativeDatabase.memory());
      repository = ActivityCardRepositoryImpl(
        dao: database.activityCardDao,
        ownerKeyStore: BackendUserIdStore()..updateUserId(_ownerKey),
      );
      clock = _armedDay;
      thankYou = ThankYouActivationService(
        ThankYouActivationRepositoryImpl(ThankYouActivationDao(database)),
        now: () => clock,
      );
      // The ledger row keys off a real card, so the host card has to exist
      // before the turn can be armed.
      await database.into(database.activityCards).insert(
            ActivityCardsCompanion.insert(
              id: 'card-1',
              ownerKey: _ownerKey,
              title: 'Đi ăn lẩu ở Trúc Bạch',
              origin: 'manual',
              status: const Value('done'),
              createdAt: DateTime.utc(2026, 9, 18),
              updatedAt: DateTime.utc(2026, 9, 18),
            ),
          );
      await thankYou.arm('card-1');
      clock = _nextDay;
    });

    tearDown(() async {
      await database.close();
    });

    testWidgets('chạm một chip tạo ngay thẻ *Mới nghĩ ra* trong kho chung',
        (WidgetTester tester) async {
      await pumpBlock(
        tester,
        package: _package(<Map<String, Object?>>[
          _event(
            id: 'ev_trung_thu',
            name: 'Tết Trung Thu',
            dates: <String>['2026-09-25'],
            activityType: 'walk',
          ),
        ]),
      );

      expect(find.byKey(const Key('next_plan_section')), findsOneWidget);
      await tester.tap(find.byKey(const Key('next_plan_chip_ev_trung_thu')));
      await tester.pumpAndSettle();

      final List<ActivityCard> created = await ideas();
      expect(created, hasLength(1));
      expect(created.single.title, 'Tết Trung Thu');
      expect(created.single.status, ActivityCardStatus.idea);
      expect(created.single.origin, ActivityCardOrigin.nextPlanAfterDate);
      expect(created.single.scheduledOn, '2026-09-25');
      expect(created.single.activityType, ActivityType.walk);

      await tester.pumpAndSettle(const Duration(seconds: 6));
    });

    testWidgets('ngày điền sẵn của thẻ vẫn sửa được như mọi thẻ khác (AC-21)',
        (WidgetTester tester) async {
      await pumpBlock(
        tester,
        package: _package(<Map<String, Object?>>[
          _event(id: 'ev_a', name: 'Tết Trung Thu', dates: <String>['2026-09-25']),
        ]),
      );

      await tester.tap(find.byKey(const Key('next_plan_chip_ev_a')));
      await tester.pumpAndSettle();

      final ActivityCard created = (await ideas()).single;
      await repository.updateCardDetails(
        created.id,
        ActivityCardEdit(
          title: created.title,
          activityType: created.activityType,
          scheduledOn: '2026-10-06',
          invited: created.invited,
          replyState: created.replyState,
        ),
      );

      expect((await ideas()).single.scheduledOn, '2026-10-06');

      await tester.pumpAndSettle(const Duration(seconds: 6));
    });

    testWidgets('chạm chip xong có snackbar hoàn tác, và hoàn tác xoá sạch thẻ',
        (WidgetTester tester) async {
      await pumpBlock(
        tester,
        package: _package(<Map<String, Object?>>[
          _event(id: 'ev_a', name: 'Tết Trung Thu', dates: <String>['2026-09-25']),
        ]),
      );

      await tester.tap(find.byKey(const Key('next_plan_chip_ev_a')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('next_plan_undo_snackbar')), findsOneWidget);
      expect(await ideas(), hasLength(1));

      await tester.tap(find.text('Hoàn tác'));
      await tester.pumpAndSettle();

      expect(await ideas(), isEmpty);
      // The card came in and went out through the same contract, so nothing
      // it owned is left behind as an orphan row.
      final rows = await database.select(database.activityCards).get();
      expect(rows.map((row) => row.id), <String>['card-1']);

      await tester.pumpAndSettle(const Duration(seconds: 6));
    });

    testWidgets('đóng khối mà không chọn chip nào thì không tạo gì (AC-22)',
        (WidgetTester tester) async {
      await pumpBlock(
        tester,
        package: _package(<Map<String, Object?>>[
          _event(id: 'ev_a', dates: <String>['2026-09-25']),
          _event(id: 'ev_b', dates: <String>['2026-10-06']),
        ]),
      );

      await tester.tap(find.byKey(const Key('thank_you_close')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('next_plan_section')), findsNothing);
      expect(await ideas(), isEmpty);
    });

    testWidgets('gói không còn dịp nào thì khe phần 3 vắng hẳn khỏi cây widget',
        (WidgetTester tester) async {
      await pumpBlock(
        tester,
        package: _package(<Map<String, Object?>>[
          _event(id: 'ev_qua', dates: <String>['2026-01-01']),
        ]),
      );

      expect(find.byKey(const Key('thank_you_block')), findsOneWidget);
      expect(find.byKey(const Key('thank_you_slot_next_plan')), findsNothing);
      expect(find.byKey(const Key('next_plan_section')), findsNothing);
    });

    testWidgets('nhiều dịp thì các chip cùng cỡ, không chip nào được nhấn mạnh',
        (WidgetTester tester) async {
      await pumpBlock(
        tester,
        package: _package(<Map<String, Object?>>[
          _event(id: 'ev_a', dates: <String>['2026-09-25']),
          _event(id: 'ev_b', dates: <String>['2026-10-06']),
          _event(id: 'ev_c', dates: <String>['2026-12-24']),
          _event(id: 'ev_d', dates: <String>['2027-01-01']),
        ]),
      );

      final Iterable<Size> sizes = <String>['ev_a', 'ev_b', 'ev_c'].map(
        (String id) => tester.getSize(find.byKey(Key('next_plan_chip_$id'))),
      );

      expect(sizes.toSet(), hasLength(1));
      expect(find.byKey(const Key('next_plan_chip_ev_d')), findsNothing);
    });
  });
}
