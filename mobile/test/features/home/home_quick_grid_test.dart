import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:cupid_mobile/features/reminders/data/reminder_local_prefs.dart';
import 'package:cupid_mobile/features/reminders/data/reminder_repository.dart';
import 'package:cupid_mobile/features/reminders/domain/synced_reminder.dart';
import 'package:cupid_mobile/features/reminders/presentation/reminder_schedule_bloc.dart';
import 'package:cupid_mobile/features/reminders/presentation/reminder_strings.dart';
import 'package:cupid_mobile/features/reminders/presentation/screens/reminder_schedule_screen.dart';
import 'package:cupid_mobile/features/zodiac/presentation/zodiac_cubit.dart';
import 'package:cupid_mobile/features/zodiac/presentation/zodiac_red_flag_screen.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../zodiac/presentation/zodiac_screen_fixtures.dart';

/// Mirrors `home_screen_test.dart`'s no-op repository: this suite asserts the
/// quick grid's layout and its two navigation edges, never Dream Jar loading.
class _NoOpDreamJarRepository extends DreamJarRepository {
  _NoOpDreamJarRepository() : super(CupidApiClient.create());

  @override
  Future<List<DreamJar>> fetchJars({int limit = 50, int offset = 0}) async =>
      <DreamJar>[];
}

class _EmptyRealtimeCoordinator implements RealtimeCoordinator {
  @override
  Stream<RealtimeEvent> events({Set<String>? names}) => const Stream.empty();

  @override
  Stream<RealtimeStatus> get status => const Stream.empty();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> emit(String name, Object? payload) async {}

  @override
  Future<void> resync() async {}
}

/// `ReminderScheduleScreen` resolves its bloc on build, and that bloc hydrates
/// immediately; stubbing both reads keeps the AC3 tap off the network.
class _FakeReminderRepository extends ReminderRepository {
  _FakeReminderRepository()
    : super(
        api: CupidApi(),
        realtime: _EmptyRealtimeCoordinator(),
        backendUserIdStore: BackendUserIdStore(),
      );

  @override
  Future<SyncedReminder?> load() async => null;

  @override
  Stream<RealtimeEvent> events() => const Stream.empty();
}

/// The design source compares Home in dark theme + `vi`; the story's AC1
/// comparison conditions say the same, so the harness pins both.
Widget _host(Widget home, {Locale locale = const Locale('vi')}) => MaterialApp(
  theme: buildCupidTheme(
    platform: CupidPlatform.material,
    brightness: Brightness.dark,
  ),
  locale: locale,
  localizationsDelegates: AppL10n.localizationsDelegates,
  supportedLocales: AppL10n.supportedLocales,
  // The same `routes:` entry `cupid_app.dart:68-71` registers. A bare
  // `HomeScreen` under a route-less `MaterialApp` throws "Could not find a
  // generator for route" the moment the zodiac tile is tapped.
  routes: <String, WidgetBuilder>{
    ZodiacRedFlagScreen.routeName: (BuildContext context) =>
        const ZodiacRedFlagScreen(),
  },
  home: CupidPlatformOverride(platform: CupidPlatform.material, child: home),
);

Widget _homeScreen({Future<CupidProfile> Function()? resolveProfile}) =>
    HomeScreen(
      resolvePairingStatus: () async => PairingStatus.unknown,
      resolveProfile: resolveProfile,
    );

/// Off by default so the ordinary scoped suite stays hermetic; mirrors
/// `test/features/reminders/visual_capture_support.dart`'s gate. Enable with
/// `flutter test test/features/home/home_quick_grid_test.dart
/// --dart-define=CAPTURE_VISUALS=true`.
const bool _kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

/// Android reference viewport, matching `[data-plat="md"]` in the design canvas.
const Size _kAndroidReferenceViewport = Size(412, 915);

const String _kCaptureDir =
    '../data/requirements/REQ-011_zodiac_red_flag_and_home_quick_grid_completion/'
    'STORY-002_home_quick_grid_zodiac_tile/coding-plan';

/// The same fixture `main_preview.dart`'s `PREVIEW_HOME_FIXTURE` serves, so the
/// capture and the preview harness describe one render rather than two.
Future<CupidProfile> _previewHomeProfile() async => CupidProfile(
  id: 'preview-home-user',
  email: 'preview.dev.a@cupid.test',
  language: 'vi',
  vowTaken: true,
  isGhostModeEnabled: false,
  displayName: 'Minh',
  relationshipStartDate: DateTime.now().subtract(const Duration(days: 247)),
  partnerId: 'preview-home-partner',
  coupleType: 'SAME_CITY',
);

/// Widget tests ship no asset bundle, so the bundled variable fonts are read
/// off disk; without this every glyph rasterizes as a fallback box and the
/// `auto_awesome` plate is unverifiable in the capture.
Future<void> _loadDesignFonts(WidgetTester tester) async {
  await tester.runAsync(() async {
    const Map<String, String> families = <String, String>{
      'Nunito': 'assets/fonts/Nunito-Variable.ttf',
      'Roboto': 'assets/fonts/Roboto-Variable.ttf',
      'Material Symbols Rounded':
          'assets/fonts/MaterialSymbolsRounded-Variable.ttf',
    };
    for (final MapEntry<String, String> entry in families.entries) {
      final Uint8List bytes = await File(entry.value).readAsBytes();
      await (FontLoader(entry.key)
            ..addFont(Future<ByteData>.value(ByteData.view(bytes.buffer))))
          .load();
    }
  });
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    getIt.registerLazySingleton<DreamJarRepository>(
      _NoOpDreamJarRepository.new,
    );
    getIt.registerLazySingleton<BackendUserIdStore>(BackendUserIdStore.new);
    getIt.registerFactory<ReminderScheduleBloc>(
      () => ReminderScheduleBloc(
        repository: _FakeReminderRepository(),
        localPrefs: ReminderLocalPrefs(),
        backendUserIdStore: BackendUserIdStore(),
      ),
    );
    getIt.registerFactory<ZodiacCubit>(
      () => ZodiacCubit(repository: FakeZodiacRepository.ready()),
    );
  });

  tearDown(() => getIt.reset());

  testWidgets(
    'AC1: both quick-grid tiles live in one Row as equal-width Expanded '
    'children, at the list position the Synced Alarm card held, with _cardGap '
    'above and below',
    (WidgetTester tester) async {
      await tester.pumpWidget(_host(_homeScreen()));
      await tester.pump();

      final Finder reminderTile = find.byKey(
        const Key('home_reminder_entry_card'),
      );
      final Finder zodiacTile = find.byKey(const Key('home_zodiac_entry_tile'));
      expect(reminderTile, findsOneWidget);
      expect(zodiacTile, findsOneWidget);

      // Exactly one Row holds both tiles, and it is their nearest common Row
      // ancestor -- not two stacked single-tile rows.
      final Finder sharedRow = find.ancestor(
        of: reminderTile,
        matching: find.byType(Row),
      );
      final Finder rowWithZodiac = find.descendant(
        of: sharedRow.first,
        matching: zodiacTile,
      );
      expect(rowWithZodiac, findsOneWidget);

      // Equal width: the two Expanded children split the card column evenly,
      // separated by the design source's 12px gap.
      final Rect reminderRect = tester.getRect(reminderTile);
      final Rect zodiacRect = tester.getRect(zodiacTile);
      expect(reminderRect.width, moreOrLessEquals(zodiacRect.width));
      expect(reminderRect.top, moreOrLessEquals(zodiacRect.top));
      expect(
        zodiacRect.left - reminderRect.right,
        moreOrLessEquals(12),
      );

      // Preserved list position: still between the Daily Vibe card above and
      // the Dream Jar card below, with the shared 13px _cardGap on each side.
      final Rect dreamJarRect = tester.getRect(
        find.byKey(const Key('home_dream_jar_entry_card')),
      );
      expect(dreamJarRect.top - reminderRect.bottom, moreOrLessEquals(13));

      final Rect readyColumnRect = tester.getRect(
        find.byKey(const Key('home_screen_ready_signal')),
      );
      expect(reminderRect.left, greaterThan(readyColumnRect.left - 1));
    },
  );

  testWidgets(
    'AC1: the zodiac tile carries the peach auto_awesome plate, the locale-'
    'invariant title and a single-line ellipsized subtitle',
    (WidgetTester tester) async {
      await tester.pumpWidget(_host(_homeScreen()));
      await tester.pump();

      final Finder zodiacTile = find.byKey(const Key('home_zodiac_entry_tile'));
      final CupidIcon glyph = tester.widget<CupidIcon>(
        find.descendant(of: zodiacTile, matching: find.byType(CupidIcon)),
      );
      expect(glyph.icon, CupidIcons.autoAwesome);
      expect(glyph.size, 22);

      expect(
        find.descendant(
          of: zodiacTile,
          matching: find.text('Zodiac Red Flag'),
        ),
        findsOneWidget,
      );

      final Text subtitle = tester.widget<Text>(
        find.descendant(
          of: zodiacTile,
          matching: find.text('Xem chỉ số xung đột hôm nay'),
        ),
      );
      expect(subtitle.maxLines, 1);
      expect(subtitle.overflow, TextOverflow.ellipsis);
    },
  );

  testWidgets('AC1: the title literal is identical in `en`', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(_homeScreen(), locale: const Locale('en')));
    await tester.pump();

    expect(
      find.descendant(
        of: find.byKey(const Key('home_zodiac_entry_tile')),
        matching: find.text('Zodiac Red Flag'),
      ),
      findsOneWidget,
    );
    expect(find.text("See today's conflict index"), findsOneWidget);
  });

  testWidgets(
    'AC2: tapping the zodiac tile resolves the named route to '
    'ZodiacRedFlagScreen',
    (WidgetTester tester) async {
      await tester.pumpWidget(_host(_homeScreen()));
      await tester.pump();

      expect(find.byType(ZodiacRedFlagScreen), findsNothing);

      await tester.tap(find.byKey(const Key('home_zodiac_entry_tile')));
      await tester.pumpAndSettle();

      expect(find.byType(ZodiacRedFlagScreen), findsOneWidget);
    },
  );

  testWidgets(
    'Regression: the reshaped Synced Alarm tile keeps its key, copy, glyph '
    'and ReminderScheduleScreen destination',
    (WidgetTester tester) async {
      await tester.pumpWidget(_host(_homeScreen()));
      await tester.pump();

      final Finder reminderTile = find.byKey(
        const Key('home_reminder_entry_card'),
      );
      final BuildContext context = tester.element(reminderTile);
      expect(
        find.descendant(
          of: reminderTile,
          matching: find.text(context.reminderNotificationsRowTitle),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: reminderTile,
          matching: find.text(context.reminderNotificationsRowSubtitle),
        ),
        findsOneWidget,
      );

      final CupidIcon glyph = tester.widget<CupidIcon>(
        find.descendant(of: reminderTile, matching: find.byType(CupidIcon)),
      );
      expect(glyph.icon, CupidIcons.notificationsActive);

      await tester.tap(reminderTile);
      await tester.pumpAndSettle();

      expect(find.byType(ReminderScheduleScreen), findsOneWidget);
    },
  );

  testWidgets('Accessibility: each tile is one button node labelled '
      '"<title>. <subtitle>" with a tap target no shorter than the platform '
      'minimum', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(_host(_homeScreen()));
    await tester.pump();

    final BuildContext context = tester.element(
      find.byKey(const Key('home_zodiac_entry_tile')),
    );
    expect(
      find.bySemanticsLabel(
        'Zodiac Red Flag. Xem chỉ số xung đột hôm nay',
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        '${context.reminderNotificationsRowTitle}. '
        '${context.reminderNotificationsRowSubtitle}',
      ),
      findsOneWidget,
    );

    final double tapTarget = context.cupidPlatform.tapTarget;
    expect(
      tester.getSize(find.byKey(const Key('home_zodiac_entry_tile'))).height,
      greaterThanOrEqualTo(tapTarget),
    );

    handle.dispose();
  });

  testWidgets(
    'AC1 visual evidence: writes the dark-theme + vi Home frame at the Android '
    'reference viewport',
    (WidgetTester tester) async {
      final GlobalKey boundaryKey = GlobalKey();

      tester.view.physicalSize = _kAndroidReferenceViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await _loadDesignFonts(tester);
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: _host(_homeScreen(resolveProfile: _previewHomeProfile)),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // Splash-frame trap (`phase-P1` §6): a capture taken before Home paints
      // silently invalidates the comparison. These three finders are the
      // mechanical proof the boundary below holds the real Home dashboard.
      expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
      expect(find.byKey(const Key('home_reminder_entry_card')), findsOneWidget);
      expect(find.byKey(const Key('home_zodiac_entry_tile')), findsOneWidget);

      final RenderRepaintBoundary boundary =
          tester.renderObject(find.byKey(boundaryKey))
              as RenderRepaintBoundary;

      await tester.runAsync(() async {
        final ui.Image image = await boundary.toImage(pixelRatio: 1);
        final ByteData? png = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        image.dispose();
        final File out = File('$_kCaptureDir/home-quick-grid-vi-dark.png');
        out.parent.createSync(recursive: true);
        out.writeAsBytesSync(png!.buffer.asUint8List());
      });
    },
    skip: !_kCaptureVisuals,
  );
}
