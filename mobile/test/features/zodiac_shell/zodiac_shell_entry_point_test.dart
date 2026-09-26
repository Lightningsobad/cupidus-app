import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/screens/activity_card_hub_view.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/widgets/minute_one_empty_state.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/widgets/quick_entry_strip.dart';
import 'package:cupid_mobile/features/zodiac_shell/presentation/screens/zodiac_shell_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory stand-in for the card store the hub lists from. The shell's own
/// "thêm vào kho của tôi" path is P3's and is not exercised here.
class _FakeCardStore implements ActivityCardRepository {
  _FakeCardStore([List<ActivityCard> cards = const <ActivityCard>[]])
      : _cards = <ActivityCard>[...cards];

  final List<ActivityCard> _cards;

  @override
  Future<List<ActivityCard>> cardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) async =>
      _cards
          .where((ActivityCard card) => card.status == status)
          .skip(offset)
          .take(limit)
          .toList(growable: false);

  @override
  Stream<List<ActivityCard>> watchCardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) async* {
    yield await cardsByStatus(status: status, limit: limit, offset: offset);
  }

  @override
  Future<Map<ActivityCardStatus, int>> countsByStatus() async {
    final Map<ActivityCardStatus, int> counts = <ActivityCardStatus, int>{};
    for (final ActivityCard card in _cards) {
      counts[card.status] = (counts[card.status] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Future<ActivityCard?> cardById(String id) async =>
      _cards.cast<ActivityCard?>().firstWhere(
            (ActivityCard? card) => card?.id == id,
            orElse: () => null,
          );

  @override
  Future<int> deleteCard(String id) async {
    final int before = _cards.length;
    _cards.removeWhere((ActivityCard card) => card.id == id);
    return before - _cards.length;
  }

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) async {
    final DateTime now = DateTime(2026, 9, 24);
    final ActivityCard created = ActivityCard(
      id: 'card-created-${_cards.length + 1}',
      ownerKey: 'owner-1',
      title: draft.title,
      status: ActivityCardStatus.idea,
      origin: draft.origin,
      activityType: draft.activityType,
      sourceLink: draft.sourceLink,
      invited: false,
      replyState: ActivityCardReplyState.notAnswered,
      createdAt: now,
      updatedAt: now,
    );
    _cards.add(created);
    return created;
  }

  @override
  Future<int> updateStatus(String cardId, ActivityCardStatus status) async => 1;

  @override
  Future<int> clearScheduledDate(String cardId) async => 1;

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) async => 1;
}

ActivityCard _card({
  required String id,
  required ActivityCardStatus status,
  String? title,
  String? scheduledOn,
}) {
  final DateTime now = DateTime(2026, 9, 24);
  return ActivityCard(
    id: id,
    ownerKey: 'owner-1',
    title: title ?? 'Thẻ $id',
    status: status,
    origin: ActivityCardOrigin.manual,
    scheduledOn: scheduledOn,
    invited: false,
    replyState: ActivityCardReplyState.notAnswered,
    createdAt: now,
    updatedAt: now,
  );
}

/// The third quick-entry cell. Read off the enum rather than written as `2`, so
/// the test still points at "Vỏ hoàng đạo" if the strip is ever reordered.
final int _zodiacSlot = QuickEntryCell.values.indexOf(QuickEntryCell.zodiacShell);

Key get _zodiacCell => Key('activity_quick_entry_slot_$_zodiacSlot');

const Key _comingSoon = Key('activity_quick_entry_coming_soon');

/// Tall enough that all three cells and the list below them are laid out in one
/// frame: in the default 800x600 frame the strip can sit outside the viewport
/// and `tap()` would miss rather than fail loudly.
const Size _tallViewport = Size(415, 2400);

/// Rendered evidence for the story-level visual-fidelity package, off unless
/// `--dart-define=CAPTURE_VISUALS=true` so the ordinary suite stays hermetic.
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

const String _visualOutputDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-011_zodiac_quiz_shell/visual-fidelity';

/// The frame of the Stage-1 canvas render of `man-goc-muon-lam`, so the two
/// images are compared at the same size rather than across a crop.
const Size _captureViewport = Size(415, 900);

const String _hubSource =
    'lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart';
const String _entryPointSource =
    'lib/features/zodiac_shell/zodiac_shell_entry_point.dart';

final GlobalKey _captureBoundaryKey = GlobalKey();

Widget _host(Widget child, {List<NavigatorObserver> observers = const []}) =>
    MaterialApp(
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      locale: const Locale('vi'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      navigatorObservers: observers,
      home: CupidPlatformOverride(
        platform: CupidPlatform.material,
        child: child,
      ),
    );

/// Records every push so the assertion is "a route was pushed", not merely
/// "something matching the screen is somewhere on the tree".
class _RecordingObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushed = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route);
  }
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

    // Framework glyphs ship outside `assets/fonts/`, so without this the
    // capture shows notdef boxes and proves nothing.
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

/// Captured on the Material platform, not iOS: the iOS header band is a
/// `BackdropFilter`, and an offscreen `RenderRepaintBoundary.toImage()` has no
/// backdrop to sample, so the title washes out of every iOS capture.
Future<void> _captureScreen(
  WidgetTester tester,
  Widget home,
  String fileName, {
  Size viewport = _captureViewport,
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await _loadDesignFonts(tester);
  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureBoundaryKey,
      child: MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        debugShowCheckedModeBanner: false,
        theme: buildCupidTheme(
          platform: CupidPlatform.material,
          brightness: Brightness.dark,
        ),
        builder: (BuildContext context, Widget? child) => CupidAppBackground(
          enableEffectsOverride: false,
          child: child!,
        ),
        home: CupidPlatformOverride(
          platform: CupidPlatform.material,
          child: home,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final RenderRepaintBoundary boundary =
      tester.renderObject(find.byKey(_captureBoundaryKey))
          as RenderRepaintBoundary;

  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 1);
    final ByteData? png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final File out = File('$_visualOutputDir/$fileName');
    out.parent.createSync(recursive: true);
    out.writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // The rotation cursor the pushed screen's cubit reads on its first round.
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('AC-1/AC-27: ô thứ ba của dải cửa vào nhanh mở màn (7)', () {
    testWidgets('chạm ô từ hub đã có thẻ đẩy ZodiacShellScreen thành route riêng',
        (WidgetTester tester) async {
      final _RecordingObserver observer = _RecordingObserver();
      tester.view.physicalSize = _tallViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(
          ActivityCardHubView(
            repository: _FakeCardStore(<ActivityCard>[
              _card(id: 'card-1', status: ActivityCardStatus.idea),
            ]),
          ),
          observers: <NavigatorObserver>[observer],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(QuickEntryStrip), findsOneWidget);

      await tester.tap(find.byKey(_zodiacCell));
      await tester.pumpAndSettle();

      expect(find.byType(ZodiacShellScreen), findsOneWidget);
      // Full-screen and on its own route, not a sheet laid over the hub.
      expect(observer.pushed.last, isA<MaterialPageRoute<void>>());
      expect(find.byType(ActivityCardHubView), findsNothing);
      expect(find.byKey(_comingSoon), findsNothing);
    });

    testWidgets('chạm ô từ màn Minute-1 (kho rỗng) cũng đẩy ZodiacShellScreen',
        (WidgetTester tester) async {
      final _RecordingObserver observer = _RecordingObserver();
      tester.view.physicalSize = _tallViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(
          ActivityCardHubView(repository: _FakeCardStore()),
          observers: <NavigatorObserver>[observer],
        ),
      );
      await tester.pumpAndSettle();
      // The first hub a new user ever sees carries its own copy of the strip,
      // so the cell has to lead somewhere from here too.
      expect(find.byType(MinuteOneEmptyState), findsOneWidget);

      await tester.tap(find.byKey(_zodiacCell));
      await tester.pumpAndSettle();

      expect(find.byType(ZodiacShellScreen), findsOneWidget);
      expect(observer.pushed.last, isA<MaterialPageRoute<void>>());
      expect(find.byKey(_comingSoon), findsNothing);
    });

    testWidgets('quay lại từ màn (7) trả người dùng về hub',
        (WidgetTester tester) async {
      tester.view.physicalSize = _tallViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(
          ActivityCardHubView(
            repository: _FakeCardStore(<ActivityCard>[
              _card(id: 'card-1', status: ActivityCardStatus.idea),
            ]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(_zodiacCell));
      await tester.pumpAndSettle();

      // The header grows a back control because the shell now sits on a route
      // that can pop — the hub's own route is what it goes back to.
      await tester.tap(find.byIcon(CupidIcons.arrowBack));
      await tester.pumpAndSettle();

      expect(find.byType(ZodiacShellScreen), findsNothing);
      expect(find.byType(ActivityCardHubView), findsOneWidget);
    });
  });

  group('AC-28/BR-10: không điều kiện mở khoá nào chắn trước ô', () {
    testWidgets('ô hiện nhãn "Vỏ hoàng đạo" và icon auto_awesome, không biến thể khoá',
        (WidgetTester tester) async {
      tester.view.physicalSize = _tallViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(
          ActivityCardHubView(
            repository: _FakeCardStore(<ActivityCard>[
              _card(id: 'card-1', status: ActivityCardStatus.idea),
            ]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder cell = find.byKey(_zodiacCell);
      expect(
        find.descendant(of: cell, matching: find.text('Vỏ hoàng đạo')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: cell,
          matching: find.byIcon(CupidIcons.autoAwesome),
        ),
        findsOneWidget,
      );
      // No padlock and no "sắp mở" twin: the strip draws one shape per cell.
      expect(
        find.descendant(of: cell, matching: find.byIcon(Icons.lock)),
        findsNothing,
      );
      expect(find.text('Sắp có'), findsNothing);
    });

    test('cửa vào không đọc địa điểm, gói trả phí hay tiến độ onboarding', () {
      final String source = File(_entryPointSource).readAsStringSync();
      // Doc comments name the gates they rule out, so the scan reads code only.
      final String code = source
          .split('\n')
          .where((String line) => !line.trimLeft().startsWith('//'))
          .join('\n');
      const List<String> gates = <String>[
        'Geolocator',
        'location',
        'Location',
        'premium',
        'Premium',
        'paywall',
        'Paywall',
        'subscription',
        'Subscription',
        'entitlement',
        'onboarding',
        'Onboarding',
        'locked',
        'isUnlocked',
      ];
      for (final String gate in gates) {
        expect(
          code.contains(gate),
          isFalse,
          reason: 'R-13/R-14 không áp dụng: cửa vào nhắc tới "$gate"',
        );
      }
      // No branch at all, so there is nothing an unlock condition could hide
      // behind: with only a BuildContext there is no account state to read.
      expect(code.contains('if ('), isFalse);
      expect(
        code.contains(
          'Future<void> openZodiacShellScreen(BuildContext context)',
        ),
        isTrue,
      );
    });
  });

  group('hợp đồng module: đúng một cửa vào', () {
    test('zodiac_shell_entry_point.dart phơi ra đúng một hàm top-level', () {
      final String source = File(_entryPointSource).readAsStringSync();
      final List<String> declared = RegExp(r'^[A-Za-z_][\w<>, ?]*\s+(\w+)\(',
              multiLine: true)
          .allMatches(source)
          .map((RegExpMatch match) => match.group(1)!)
          .toList();

      expect(declared, <String>['openZodiacShellScreen']);
      // No `export` either: re-exporting the screen or the cubit would give a
      // caller the same reach as a direct import.
      expect(source.contains('export '), isFalse);
      expect(source.contains('class '), isFalse);
    });

    test('hub không import trực tiếp màn hay cubit của shell', () {
      final String source = File(_hubSource).readAsStringSync();

      // Word-bounded: `openZodiacShellScreen` carries the screen's name as a
      // substring, and that call is exactly what is allowed here.
      expect(RegExp(r'\bZodiacShellScreen\b').hasMatch(source), isFalse);
      expect(source.contains('ZodiacShellCubit'), isFalse);
      expect(source.contains('zodiac_shell/presentation'), isFalse);
      expect(
        source.contains("import '../../../zodiac_shell/zodiac_shell_entry_point.dart';"),
        isTrue,
      );
    });

    test('hub không còn nhánh snackbar "sắp có" cho ô cung hoàng đạo', () {
      final String source = File(_hubSource).readAsStringSync();

      // Every cell leads somewhere now, so the hub's own placeholder branch is
      // gone entirely. The strip keeps its fallback for a caller that passes no
      // handler, which is not a hub state.
      expect(source.contains('activity_quick_entry_coming_soon'), isFalse);
      expect(source.contains('openZodiacShellScreen(context)'), isTrue);
    });
  });

  group('bằng chứng visual-fidelity', () {
    testWidgets('captures man-goc-muon-lam', (WidgetTester tester) async {
      await _captureScreen(
        tester,
        ActivityCardHubView(
          repository: _FakeCardStore(<ActivityCard>[
            _card(
              id: 'card-1',
              status: ActivityCardStatus.idea,
              title: 'Đi ăn quán Huế mới mở',
            ),
            _card(
              id: 'card-2',
              status: ActivityCardStatus.scheduled,
              title: 'Xem phim cuối tuần',
              scheduledOn: '2026-09-26',
            ),
          ]),
        ),
        'implemented-man-goc-muon-lam-md-quick-entry.png',
      );
    }, skip: !kCaptureVisuals);

    testWidgets('captures man-goc-muon-lam (Minute-1)',
        (WidgetTester tester) async {
      await _captureScreen(
        tester,
        ActivityCardHubView(repository: _FakeCardStore()),
        'implemented-phut-1-kho-trong-md-quick-entry.png',
      );
    }, skip: !kCaptureVisuals);
  });
}
