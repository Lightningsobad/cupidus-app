import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/screens/activity_card_detail_screen.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/data/attachable_photos.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/data/thank_you_activation_dao.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/data/thank_you_activation_repository_impl.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/domain/thank_you_activation.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/domain/thank_you_activation_service.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/presentation/thank_you_block_cubit.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/presentation/widgets/thank_you_block.dart';
import 'package:cupid_mobile/features/activity_cards/thank_you/presentation/widgets/thanks_section.dart';
import 'package:cupid_mobile/features/conversation_starters/domain/starter_content.dart';
import 'package:cupid_mobile/features/invite_composer/domain/preset_catalogue.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rendered evidence for the per-story visual fidelity gate, produced the same
/// way STORY-006's block is: the surface needs a card that entered *Đã đi rồi*
/// on an earlier calendar day and still holds an unspent turn, which no
/// navigation path can arrange on demand.
///
/// `flutter test test/features/activity_cards/thank_you/thank_you_block_test.dart \
///   --dart-define=CAPTURE_VISUALS=true`
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

/// The viewport `render-design-canvas.js --platform=ios` renders
/// `sb-212-cam-on-chot-viec-ke-tiep` at, so the pair compares without
/// rescaling either side.
const Size _iosReferenceViewport = Size(415, 900);

const String _visualEvidenceDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-007_thank_you_and_next_plan/visual-fidelity';

final GlobalKey _captureBoundaryKey = GlobalKey();

/// The day the card was marked *Đã đi rồi*; every "sáng hôm sau" assertion
/// reads one calendar day later.
final DateTime _armedDay = DateTime(2026, 9, 20, 21, 30);
final DateTime _nextDay = DateTime(2026, 9, 21, 8, 15);

class _StubRepository implements ActivityCardRepository {
  @override
  Future<int> updateStatus(String cardId, ActivityCardStatus status) async => 1;

  @override
  Future<int> clearScheduledDate(String cardId) async => 1;

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) async => 1;

  @override
  Future<int> deleteCard(String id) async => 1;

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) =>
      throw UnimplementedError('detail screen never creates');

  @override
  Future<List<ActivityCard>> cardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) => throw UnimplementedError('detail screen never lists');

  @override
  Stream<List<ActivityCard>> watchCardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) => throw UnimplementedError('detail screen never lists');

  @override
  Future<ActivityCard?> cardById(String id) =>
      throw UnimplementedError('the card is handed in, not fetched');

  @override
  Future<Map<ActivityCardStatus, int>> countsByStatus() =>
      throw UnimplementedError('detail screen never counts');
}

ActivityCard _card({
  ActivityCardStatus status = ActivityCardStatus.done,
}) {
  final DateTime now = DateTime(2026, 9, 18);
  return ActivityCard(
    id: 'card-1',
    ownerKey: 'owner-1',
    title: 'Đi ăn lẩu ở Trúc Bạch',
    status: status,
    origin: ActivityCardOrigin.manual,
    activityType: ActivityType.dining,
    scheduledOn: '2026-09-20',
    note: 'Quán nhỏ, ngồi ngoài hiên nhìn ra hồ.',
    location: 'Hà Nội',
    invited: true,
    replyState: ActivityCardReplyState.answered,
    createdAt: now,
    updatedAt: now,
  );
}

ContentPackage<CalendarEvent> _occasions(List<Map<String, Object?>> items) =>
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

/// Phần 3 resolved against a pack with nothing upcoming, which is what keeps
/// these P2 frame assertions about the frame: the slot stays empty unless a
/// test asks for occasions. Behaviour of the section itself lives in
/// `next_plan_test.dart`.
NextPlanOptions _emptyNextPlan() => NextPlanOptions(
      today: _nextDay,
      package: _occasions(const <Map<String, Object?>>[]),
      repository: _StubRepository(),
    );

/// Phần 2 against a card with nothing to attach, which is the default here for
/// the same reason [_emptyNextPlan] is: these are frame assertions, and the
/// real loader would need both photo stores in the locator. Behaviour of the
/// section itself lives in `photo_attach_test.dart`.
PhotoAttachOptions _noPhotos() => PhotoAttachOptions(
      loader: (String cardId) async => const <AttachablePhoto>[],
    );

PhotoAttachOptions _photosFrom(List<String> paths) => PhotoAttachOptions(
      loader: (String cardId) async => <AttachablePhoto>[
        for (final String path in paths) AttachablePhoto(path),
      ],
    );

/// The shipped pack read off disk rather than through `rootBundle`, so the
/// capture shows the wording and the dates the app actually ships, pinned to
/// [_nextDay] so the same three chips render on any run day.
NextPlanOptions _shippedNextPlan() => NextPlanOptions(
      today: _nextDay,
      package: ContentPackage.parse<CalendarEvent>(
        File('assets/data/req016/calendar_events.v1.json').readAsStringSync(),
        expectedSchemaId: calendarEventsSchemaId,
        itemParser: calendarEventFromJson,
      ),
      repository: _StubRepository(),
    );

/// Serves the shipped thank-you pack off disk instead of `rootBundle`, so phần
/// 1 resolves the same content the app ships without a composition root.
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final File file = File(key);
    if (!file.existsSync()) {
      throw FlutterError('no asset on disk under "$key"');
    }
    return ByteData.view(file.readAsBytesSync().buffer);
  }
}

class _MissingBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      throw FlutterError('no asset bundled under "$key"');
}

/// Phần 1 wired to the shipped pack, with the composer replaced by a no-op: the
/// sheet itself belongs to STORY-002 and has its own tests.
ThanksOptions _shippedThanks() => ThanksOptions(
      catalogue: PresetCatalogue(
        loader: ContentPackageLoader(bundle: _DiskBundle()),
      ),
      openComposer: (
        BuildContext context,
        ActivityCard card,
        String categoryId,
        List<String> attachmentPaths,
      ) async =>
          true,
    );

Widget _host(
  Widget child, {
  CupidPlatform platform = CupidPlatform.material,
}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildCupidTheme(platform: platform, brightness: Brightness.dark),
      locale: const Locale('vi'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: CupidPlatformOverride(platform: platform, child: child),
    );

/// The whole detail screen at once, so the block and the card-level CTA are
/// both hit-testable without a scroll step inside an assertion.
void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(415, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> _loadDesignFonts(WidgetTester tester) async {
  await tester.runAsync(() async {
    const Map<String, String> families = <String, String>{
      'Nunito': 'assets/fonts/Nunito-Variable.ttf',
      'Roboto': 'assets/fonts/Roboto-Variable.ttf',
      'Roboto Mono': 'assets/fonts/RobotoMono-Variable.ttf',
      'Material Symbols Rounded':
          'assets/fonts/MaterialSymbolsRounded-Variable.ttf',
    };
    for (final MapEntry<String, String> entry in families.entries) {
      final Uint8List bytes = await File(entry.value).readAsBytes();
      await (FontLoader(entry.key)
            ..addFont(Future<ByteData>.value(ByteData.view(bytes.buffer))))
          .load();
    }

    // A handful of glyphs on this screen ship with the framework rather than
    // under `assets/fonts/` (`uses-material-design: true`). Without them the
    // capture shows tofu boxes and proves nothing about the icon set.
    final String? flutterRoot = Platform.environment['FLUTTER_ROOT'];
    if (flutterRoot != null) {
      final File materialIcons = File(
        '$flutterRoot/bin/cache/artifacts/material_fonts/'
        'MaterialIcons-Regular.otf',
      );
      if (materialIcons.existsSync()) {
        final Uint8List bytes = await materialIcons.readAsBytes();
        await (FontLoader('MaterialIcons')
              ..addFont(Future<ByteData>.value(ByteData.view(bytes.buffer))))
            .load();
      }
    }
  });
}

void main() {
  late CupidDatabase database;
  late DateTime clock;
  late ThankYouActivationService service;

  Future<void> seedCard(String id) async {
    await database.into(database.activityCards).insert(
          ActivityCardsCompanion.insert(
            id: id,
            ownerKey: 'owner-1',
            title: 'Đi ăn lẩu ở Trúc Bạch',
            origin: 'manual',
            status: const Value('done'),
            createdAt: DateTime.utc(2026, 9, 18),
            updatedAt: DateTime.utc(2026, 9, 18),
          ),
        );
  }

  Future<ThankYouActivation?> activation(String cardId) {
    return ThankYouActivationRepositoryImpl(ThankYouActivationDao(database))
        .activationFor(cardId);
  }

  Future<int> ledgerRowCount() async {
    final rows = await database.select(database.thankYouActivations).get();
    return rows.length;
  }

  /// Marks the card *Đã đi rồi* on [_armedDay] and moves the clock to the next
  /// morning, which is the only state in which the block draws at all.
  Future<void> armYesterday() async {
    clock = _armedDay;
    await service.arm('card-1');
    clock = _nextDay;
  }

  Future<void> pumpDetail(
    WidgetTester tester, {
    ActivityCard? card,
    ThankYouSlots slots = const ThankYouSlots(),
    NextPlanOptions? nextPlan,
    ThanksOptions? thanks,
    PhotoAttachOptions? photos,
  }) async {
    await tester.pumpWidget(
      _host(
        ActivityCardDetailScreen(
          key: UniqueKey(),
          card: card ?? _card(),
          repository: _StubRepository(),
          thankYou: ThankYouOptions(
            service: service,
            slots: slots,
            thanks: thanks,
            photos: photos ?? _noPhotos(),
            nextPlan: nextPlan ?? _emptyNextPlan(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() async {
    database = CupidDatabase(NativeDatabase.memory());
    clock = _nextDay;
    service = ThankYouActivationService(
      ThankYouActivationRepositoryImpl(ThankYouActivationDao(database)),
      now: () => clock,
    );
    await seedCard('card-1');
  });

  tearDown(() async {
    await database.close();
  });

  group('cubit — trình bày một lần và tiêu thụ ngay (AC-1, AC-3)', () {
    test('thẻ đủ điều kiện thì khối hiện và lượt bị tiêu thụ ngay', () async {
      await armYesterday();
      final ThankYouBlockCubit cubit = ThankYouBlockCubit(
        cardId: 'card-1',
        isRecording: true,
        service: () => service,
      );
      addTearDown(cubit.close);

      await cubit.resolve();

      expect(cubit.state.isVisible, isTrue);
      expect(
        (await activation('card-1'))!.status,
        ThankYouActivationStatus.consumed,
        reason: 'AC-3 đếm theo lần hiện, không đợi người dùng thao tác',
      );
      expect(await service.isEligible('card-1'), isFalse);
    });

    test('thẻ chưa đủ điều kiện thì khối không hiện và lượt còn nguyên',
        () async {
      clock = _armedDay;
      await service.arm('card-1');

      final ThankYouBlockCubit cubit = ThankYouBlockCubit(
        cardId: 'card-1',
        isRecording: true,
        service: () => service,
      );
      addTearDown(cubit.close);

      await cubit.resolve();

      expect(cubit.state.isVisible, isFalse);
      expect(
        (await activation('card-1'))!.status,
        ThankYouActivationStatus.armed,
        reason: 'AC-2: hiện hụt trong ngày arm cũng không được tiêu thụ lượt',
      );
    });

    test('thẻ ngoài luồng "ghi lại" không chạm vào sổ lượt (AC-7)', () async {
      await armYesterday();
      final ThankYouBlockCubit cubit = ThankYouBlockCubit(
        cardId: 'card-1',
        isRecording: false,
        service: () => service,
      );
      addTearDown(cubit.close);

      await cubit.resolve();

      expect(cubit.state.isVisible, isFalse);
      expect(
        (await activation('card-1'))!.status,
        ThankYouActivationStatus.armed,
      );
    });

    test('resolve lần hai sau khi đóng không gọi khối trở lại (AC-3)',
        () async {
      await armYesterday();
      final ThankYouBlockCubit cubit = ThankYouBlockCubit(
        cardId: 'card-1',
        isRecording: true,
        service: () => service,
      );
      addTearDown(cubit.close);

      await cubit.resolve();
      cubit.dismiss();
      await cubit.resolve();

      expect(cubit.state.isVisible, isFalse);
    });
  });

  group('màn chi tiết thẻ — khối tự hiện trong luồng "ghi lại"', () {
    testWidgets('mở chi tiết thẻ lần đầu sang ngày mới thì khối tự hiện ra',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await armYesterday();

      await pumpDetail(tester);

      expect(find.byKey(const Key('thank_you_block')), findsOneWidget);
      expect(find.text('Cảm ơn + chốt việc kế tiếp'), findsOneWidget);
      expect(find.byKey(const Key('thank_you_close')), findsOneWidget);
    });

    testWidgets('mở hai lần liên tiếp: lần đầu có khối, lần sau không (AC-3)',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await armYesterday();

      await pumpDetail(tester);
      expect(find.byKey(const Key('thank_you_block')), findsOneWidget);

      await pumpDetail(tester);
      expect(find.byKey(const Key('thank_you_block')), findsNothing);
      expect(find.byType(ThankYouBlock), findsNothing);
    });

    testWidgets('bấm icon close rồi mở lại thì không có khối',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await armYesterday();

      await pumpDetail(tester);
      await tester.tap(find.byKey(const Key('thank_you_close')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('thank_you_block')), findsNothing);

      await pumpDetail(tester);
      expect(find.byKey(const Key('thank_you_block')), findsNothing);
    });

    testWidgets('thẻ chuyển *Đã đi rồi* hôm nay thì không có khối (AC-2)',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      clock = _armedDay;
      await service.arm('card-1');

      await pumpDetail(tester);

      expect(find.byKey(const Key('thank_you_block')), findsNothing);
    });

    testWidgets('thẻ chưa từng vào *Đã đi rồi* thì không có khối',
        (WidgetTester tester) async {
      _useTallViewport(tester);

      await pumpDetail(
        tester,
        card: _card(status: ActivityCardStatus.scheduled),
      );

      expect(find.byKey(const Key('thank_you_block')), findsNothing);
    });

    testWidgets('khối không thêm hành động chính cấp thẻ thứ hai (AC-6, BR-1)',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await armYesterday();

      await pumpDetail(tester);

      expect(find.byKey(const Key('thank_you_block')), findsOneWidget);
      expect(
        find.byKey(const Key('card_detail_primary_action')),
        findsOneWidget,
        reason: 'AC-6: chi tiết thẻ vẫn chỉ có đúng một CTA cấp thẻ',
      );
    });
  });

  group('khung khối — ba khe cắm cho P3/P4/P5', () {
    testWidgets('khe rỗng không để lại ô giữ chỗ nào trong cây widget',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await armYesterday();

      await pumpDetail(tester);

      for (final String slot in <String>['thanks', 'photo', 'next_plan']) {
        expect(find.byKey(Key('thank_you_slot_$slot')), findsNothing);
      }
    });

    testWidgets('khe đã cắm hiện đúng thứ tự phần 1 → 2 → 3',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await armYesterday();

      await pumpDetail(
        tester,
        slots: const ThankYouSlots(
          thanks: Text('phần 1'),
          photo: Text('phần 2'),
          nextPlan: Text('phần 3'),
        ),
      );

      double dy(String slot) =>
          tester.getTopLeft(find.byKey(Key('thank_you_slot_$slot'))).dy;

      expect(dy('thanks'), lessThan(dy('photo')));
      expect(dy('photo'), lessThan(dy('next_plan')));
    });

    testWidgets('một khe được cắm không kéo theo hai khe kia',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await armYesterday();

      await pumpDetail(
        tester,
        slots: const ThankYouSlots(nextPlan: Text('phần 3')),
      );

      expect(find.byKey(const Key('thank_you_slot_next_plan')), findsOneWidget);
      expect(find.byKey(const Key('thank_you_slot_thanks')), findsNothing);
      expect(find.byKey(const Key('thank_you_slot_photo')), findsNothing);
    });
  });

  group('phần 1 nối vào khung (P3)', () {
    testWidgets('bộ nội dung cảm ơn có preset thì khe phần 1 hiện chip',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await armYesterday();

      await pumpDetail(tester, thanks: _shippedThanks());

      expect(find.byKey(const Key('thank_you_slot_thanks')), findsOneWidget);
      expect(find.byKey(const Key('thanks_compose_chip')), findsOneWidget);
      expect(find.text('Soạn lời cảm ơn'), findsOneWidget);
    });

    testWidgets('không nạp được bộ nội dung thì khối bỏ hẳn khe phần 1',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await armYesterday();

      await pumpDetail(
        tester,
        thanks: ThanksOptions(
          catalogue: PresetCatalogue(
            loader: ContentPackageLoader(bundle: _MissingBundle()),
          ),
        ),
      );

      expect(find.byKey(const Key('thank_you_block')), findsOneWidget);
      expect(find.byKey(const Key('thank_you_slot_thanks')), findsNothing);
      expect(find.byKey(const Key('thanks_compose_chip')), findsNothing);
    });

    testWidgets('phần 1 không kéo theo CTA cấp thẻ thứ hai (AC-6, BR-1)',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await armYesterday();

      await pumpDetail(tester, thanks: _shippedThanks());

      expect(
        find.byKey(const Key('card_detail_primary_action')),
        findsOneWidget,
      );
    });
  });

  group('phần 2 nối vào khung (P4)', () {
    late Directory photoDir;

    setUp(() {
      photoDir = Directory.systemTemp.createTempSync('thank_you_block_photos');
      addTearDown(() {
        if (photoDir.existsSync()) {
          photoDir.deleteSync(recursive: true);
        }
      });
    });

    List<String> photoPaths(int count) => <String>[
          for (int i = 0; i < count; i++)
            (File('${photoDir.path}/photo-$i.png')
                  ..writeAsBytesSync(
                    base64Decode(
                      'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91Jpz'
                      'AAAAF0lEQVR42mN4UblyWsI+hoqAVS+m7QMAM5sHbVdD'
                      'd/4AAAAASUVORK5CYII=',
                    ),
                  ))
                .path,
        ];

    testWidgets('thẻ không có ảnh nào thì khe phần 2 vắng hẳn (AC-15, BR-9)',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await armYesterday();

      await pumpDetail(tester);

      expect(find.byKey(const Key('thank_you_slot_photo')), findsNothing);
      expect(find.byKey(const Key('photo_attach_section')), findsNothing);
      expect(find.byKey(const Key('photo_attach_row')), findsNothing);
    });

    testWidgets('có ảnh thì khe phần 2 hiện đủ số ô, chưa ô nào được chọn',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await armYesterday();

      await pumpDetail(tester, photos: _photosFrom(photoPaths(2)));

      expect(find.byKey(const Key('thank_you_slot_photo')), findsOneWidget);
      expect(find.byKey(const Key('photo_attach_thumb_0')), findsOneWidget);
      expect(find.byKey(const Key('photo_attach_thumb_1')), findsOneWidget);
      expect(find.byKey(const Key('photo_attach_tick_0')), findsNothing);
      expect(find.byKey(const Key('photo_attach_tick_1')), findsNothing);
    });

    testWidgets('chưa chạm ô nào thì lời cảm ơn đi một mình (AC-16)',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await armYesterday();
      List<String>? handed;

      await pumpDetail(
        tester,
        photos: _photosFrom(photoPaths(2)),
        thanks: ThanksOptions(
          catalogue: PresetCatalogue(
            loader: ContentPackageLoader(bundle: _DiskBundle()),
          ),
          openComposer: (
            BuildContext context,
            ActivityCard card,
            String categoryId,
            List<String> attachmentPaths,
          ) async {
            handed = attachmentPaths;
            return true;
          },
        ),
      );

      await tester.tap(find.byKey(const Key('thanks_compose_chip')));
      await tester.pumpAndSettle();

      expect(handed, isEmpty);
    });

    testWidgets('ô đã chạm đi cùng lời cảm ơn trong một vật phẩm (AC-14)',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await armYesterday();
      final List<String> paths = photoPaths(2);
      List<String>? handed;

      await pumpDetail(
        tester,
        photos: _photosFrom(paths),
        thanks: ThanksOptions(
          catalogue: PresetCatalogue(
            loader: ContentPackageLoader(bundle: _DiskBundle()),
          ),
          openComposer: (
            BuildContext context,
            ActivityCard card,
            String categoryId,
            List<String> attachmentPaths,
          ) async {
            handed = attachmentPaths;
            return true;
          },
        ),
      );

      await tester.tap(find.byKey(const Key('photo_attach_thumb_1')));
      await tester.pump();
      expect(find.byKey(const Key('photo_attach_tick_1')), findsOneWidget);

      await tester.tap(find.byKey(const Key('thanks_compose_chip')));
      await tester.pumpAndSettle();

      expect(handed, <String>[paths[1]]);
    });

    testWidgets('kho ảnh hỏng thì mất khe phần 2, không mất cả khối (AC-25)',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await armYesterday();

      await pumpDetail(
        tester,
        photos: PhotoAttachOptions(
          loader: (String cardId) async => throw StateError('kho ảnh hỏng'),
        ),
      );

      expect(find.byKey(const Key('thank_you_block')), findsOneWidget);
      expect(find.byKey(const Key('thank_you_slot_photo')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('không phạt im lặng (AC-25, AC-28)', () {
    testWidgets('đóng khối chỉ để lại đúng một hàng CONSUMED, không gì khác',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await armYesterday();

      await pumpDetail(tester);
      await tester.tap(find.byKey(const Key('thank_you_close')));
      await tester.pumpAndSettle();
      await pumpDetail(tester);

      expect(await ledgerRowCount(), 1);
      expect(
        (await activation('card-1'))!.status,
        ThankYouActivationStatus.consumed,
      );
    });

    testWidgets('sau khi đóng, màn chi tiết không hiện dấu hiệu bỏ lỡ nào',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await armYesterday();

      await pumpDetail(tester);
      await tester.tap(find.byKey(const Key('thank_you_close')));
      await tester.pumpAndSettle();
      await pumpDetail(tester);

      for (final String banned in <String>[
        'Bỏ lỡ',
        'Chưa hoàn thành',
        'Chưa gửi',
        'streak',
        'Streak',
      ]) {
        expect(
          find.textContaining(banned),
          findsNothing,
          reason: 'AC-25/AC-28 cấm mọi dấu chưa-hoàn-thành sau khi bỏ qua',
        );
      }
    });
  });

  group('visual fidelity capture', () {
    Future<void> capture(
      WidgetTester tester, {
      required PhotoAttachOptions photos,
      required List<File> preload,
      required String fileName,
    }) async {
      await armYesterday();

      tester.view.physicalSize = _iosReferenceViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await _loadDesignFonts(tester);
      await _warmImageCache(tester, preload);
      await tester.pumpWidget(
        RepaintBoundary(
          key: _captureBoundaryKey,
          child: _host(
            // The dark sky wash is mounted at the composition root, not by
            // each screen, so a capture without it reads as a light-mode
            // regression.
            CupidAppBackground(
              enableEffectsOverride: false,
              child: ActivityCardDetailScreen(
                key: UniqueKey(),
                card: _card(),
                repository: _StubRepository(),
                thankYou: ThankYouOptions(
                  service: service,
                  thanks: _shippedThanks(),
                  photos: photos,
                  nextPlan: _shippedNextPlan(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('thank_you_block')));
      await tester.pumpAndSettle();

      final RenderRepaintBoundary boundary =
          tester.renderObject(find.byKey(_captureBoundaryKey))
              as RenderRepaintBoundary;

      await tester.runAsync(() async {
        final ui.Image image = await boundary.toImage(pixelRatio: 1);
        final ByteData? png =
            await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        final File out = File('$_visualEvidenceDir/$fileName');
        out.parent.createSync(recursive: true);
        out.writeAsBytesSync(png!.buffer.asUint8List());
      });
    }

    testWidgets('sb-212-cam-on-chot-viec-ke-tiep', (WidgetTester tester) async {
      final Directory dir =
          Directory.systemTemp.createTempSync('thank_you_capture');
      addTearDown(() => dir.deleteSync(recursive: true));

      final List<File> shots = <File>[];
      await tester.runAsync(() async {
        shots.addAll(<File>[
          await _solidPng(dir, 'shot-0.png', const Color(0xFF6E5A8C)),
          await _solidPng(dir, 'shot-1.png', const Color(0xFF3F6C7A)),
          await _solidPng(dir, 'shot-2.png', const Color(0xFF8C5A62)),
        ]);
      });

      await capture(
        tester,
        photos: _photosFrom(<String>[for (final File shot in shots) shot.path]),
        preload: shots,
        fileName: 'implemented-sb-212-cam-on-chot-viec-ke-tiep-ios.png',
      );
    });

    testWidgets('sb-212 — thẻ không có ảnh nào', (WidgetTester tester) async {
      await capture(
        tester,
        photos: _noPhotos(),
        preload: const <File>[],
        fileName: 'state-khong-anh-sb-212-cam-on-chot-viec-ke-tiep-ios.png',
      );
    });
  }, skip: !kCaptureVisuals);
}

/// Decodes [files] into the image cache before anything asks for them.
///
/// `Image.file` reads from disk, and a read started inside the fake clock never
/// finishes — not even once a later `runAsync` opens the real one, so waiting on
/// it afterwards hangs the run rather than filling the thumbnails. Decoding
/// first leaves `FileImage` a cache hit, which resolves on the first frame.
Future<void> _warmImageCache(WidgetTester tester, List<File> files) async {
  if (files.isEmpty) {
    return;
  }
  await tester.runAsync(() async {
    for (final File file in files) {
      final ImageStream stream =
          FileImage(file).resolve(ImageConfiguration.empty);
      final Completer<void> decoded = Completer<void>();
      late final ImageStreamListener listener;
      listener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          if (!decoded.isCompleted) {
            decoded.complete();
          }
        },
        onError: (Object error, StackTrace? stack) {
          if (!decoded.isCompleted) {
            decoded.completeError(error);
          }
        },
      );
      stream.addListener(listener);
      await decoded.future;
      stream.removeListener(listener);
    }
  });
}

/// A flat colour square standing in for a user photo.
///
/// The row's job in the capture is its geometry — 72pt squares, `xs` gutters,
/// no caption — so a real photograph would only add noise the design canvas
/// cannot be compared against.
Future<File> _solidPng(Directory dir, String name, Color color) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    const Rect.fromLTWH(0, 0, 144, 144),
    Paint()..color = color,
  );
  final ui.Image image = await recorder.endRecording().toImage(144, 144);
  final ByteData? png = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return File('${dir.path}/$name')
    ..writeAsBytesSync(png!.buffer.asUint8List());
}
