import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/activity_cards/domain/time_of_day_slot.dart';
import 'package:cupid_mobile/features/context_notebook/context_notebook_entry_point.dart';
import 'package:cupid_mobile/features/date_script/domain/date_script_content.dart';
import 'package:cupid_mobile/features/date_script/presentation/screens/date_script_screen.dart';
import 'package:cupid_mobile/features/date_script/presentation/widgets/date_script_exit_bar.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// `flutter test test/features/date_script/date_script_exits_test.dart \
///   --dart-define=CAPTURE_VISUALS=true --plain-name="visual fidelity capture"`
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

const String _visualEvidenceDir = 'test/features/date_script/visual-fidelity';

/// The viewport the design canvas renders an iOS frame at.
const Size _designFrame = Size(415, 900);

/// Taller than the 800x600 default on purpose: the sticky bar sits below the
/// scrolling column, and in the default frame a `tap` on it lands on nothing
/// and passes silently.
const Size _tallFrame = Size(415, 1400);

final GlobalKey _captureBoundaryKey = GlobalKey();

class _DiskBundle extends AssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final File file = File(key);
    if (!file.existsSync()) {
      throw FlutterError('no shipped asset at "$key"');
    }
    return ByteData.sublistView(file.readAsBytesSync());
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final ByteData data = await load(key);
    return utf8.decode(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String value) parser,
  ) async => parser(await loadString(key));
}

class _EmptyNotebook implements ContextNotebookReader {
  @override
  Future<List<NotebookEntry>> entries({NotebookKind? kind}) async =>
      const <NotebookEntry>[];

  @override
  Future<List<SkillEntry>> skills() async => const <SkillEntry>[];
}

ActivityCard _card() => ActivityCard(
  id: 'card-1',
  ownerKey: 'owner-1',
  title: 'xem phim Dune',
  status: ActivityCardStatus.scheduled,
  origin: ActivityCardOrigin.manual,
  activityType: ActivityType.outing,
  scheduledOn: '2026-09-20',
  timeOfDaySlot: TimeOfDaySlot.evening,
  durationMinutes: 120,
  location: 'rạp CGV Vincom Đồng Khởi',
  invited: true,
  replyState: ActivityCardReplyState.answered,
  createdAt: DateTime.utc(2026, 9, 1),
  updatedAt: DateTime.utc(2026, 9, 1),
);

Widget _host(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: buildCupidTheme(
    platform: CupidPlatform.material,
    brightness: Brightness.dark,
  ),
  locale: const Locale('vi'),
  localizationsDelegates: AppL10n.localizationsDelegates,
  supportedLocales: AppL10n.supportedLocales,
  home: CupidPlatformOverride(platform: CupidPlatform.material, child: child),
);

Widget _silentAskSlot({
  required String entryPointId,
  required List<String> neededFieldIds,
  required VoidCallback onContextChanged,
}) => const SizedBox.shrink(key: Key('date-script-ask-slot'));

/// A card whose "Chuẩn bị" area pushed screen (9), so closing the script lands
/// the user back where they came from rather than on a blank navigator.
class _SourceContext extends StatelessWidget {
  const _SourceContext({required this.screen});

  final Widget screen;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Builder(
      builder: (BuildContext context) => GestureDetector(
        key: const Key('open-date-script'),
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(builder: (BuildContext _) => screen),
        ),
        child: const Center(child: Text('Chuẩn bị')),
      ),
    ),
  );
}

String _paragraph(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('date-script-paragraph'))).data ??
    '';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    InviteExit? inviteExit,
    NewCardExit? newCardExit,
    JournalExit? journalExit,
    Size frame = _tallFrame,
  }) async {
    tester.view.physicalSize = frame;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _host(
        _SourceContext(
          screen: DateScriptScreen(
            card: _card(),
            contentLoader: ContentPackageLoader(bundle: _DiskBundle()),
            notebook: _EmptyNotebook(),
            askSlotBuilder: _silentAskSlot,
            inviteExit: inviteExit,
            newCardExit: newCardExit,
            journalExit: journalExit,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-date-script')));
    await tester.pumpAndSettle();
  }

  group('the three exits are present and reachable', () {
    testWidgets('all three are rendered, readable and announced as buttons '
        '(AC-3/SC-2)', (WidgetTester tester) async {
      await pumpScreen(tester);

      expect(find.byKey(const Key('date-script-exit-bar')), findsOneWidget);
      // The bar is a strip along the bottom, not a second page: it must leave
      // the script the rest of the screen.
      final double barHeight = tester
          .getSize(find.byKey(const Key('date-script-exit-bar')))
          .height;
      expect(barHeight, lessThan(200));
      expect(
        tester.getSize(find.byKey(const Key('date-script-body'))).height,
        greaterThan(barHeight),
      );

      expect(find.text('Xuất lời mời'), findsOneWidget);
      expect(find.text('Tạo thẻ mới'), findsOneWidget);
      expect(find.text('Ghi vào nhật ký'), findsOneWidget);

      for (final String key in <String>[
        'date-script-exit-invite',
        'date-script-exit-new-card',
        'date-script-exit-journal',
      ]) {
        final Finder button = find.byKey(Key(key));
        expect(button, findsOneWidget);
        // Big enough to hit, and not clipped out of the frame.
        expect(tester.getSize(button).height, greaterThanOrEqualTo(44));
        expect(
          tester.getRect(button).bottom,
          lessThanOrEqualTo(tester.view.physicalSize.height),
        );
      }
    });

    testWidgets('none of the three is a filled primary action (AC-6/SC-4)', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);

      // The card keeps exactly one primary action, and it is not on this
      // screen: an outline pill here, a gradient-filled button never.
      expect(
        find.descendant(
          of: find.byKey(const Key('date-script-exit-bar')),
          matching: find.byType(CupidPrimaryButton),
        ),
        findsNothing,
      );
    });

    testWidgets('they stack instead of squeezing on a narrow frame', (
      WidgetTester tester,
    ) async {
      // 360dp: the width most Android phones actually report.
      await pumpScreen(tester, frame: const Size(360, 1400));

      final Rect invite = tester.getRect(
        find.byKey(const Key('date-script-exit-invite')),
      );
      final Rect journal = tester.getRect(
        find.byKey(const Key('date-script-exit-journal')),
      );
      expect(journal.top, greaterThan(invite.bottom - 1));
    });
  });

  group('each exit reuses the flow that already owns it', () {
    testWidgets('"Xuất lời mời" hands the source card to STORY-002\'s '
        'composer', (WidgetTester tester) async {
      final List<ActivityCard> opened = <ActivityCard>[];
      await pumpScreen(
        tester,
        inviteExit: (BuildContext context, ActivityCard card) async {
          opened.add(card);
          return true;
        },
      );

      await tester.tap(find.byKey(const Key('date-script-exit-invite')));
      await tester.pumpAndSettle();

      expect(opened, hasLength(1));
      expect(opened.single.id, 'card-1');
      expect(opened.single.title, 'xem phim Dune');
    });

    testWidgets('"Tạo thẻ mới" goes through STORY-001\'s capture form', (
      WidgetTester tester,
    ) async {
      int calls = 0;
      await pumpScreen(
        tester,
        newCardExit: (BuildContext context) async {
          calls++;
          return _card();
        },
      );

      await tester.tap(find.byKey(const Key('date-script-exit-new-card')));
      await tester.pumpAndSettle();

      expect(calls, 1);
    });

    testWidgets('"Ghi vào nhật ký" seeds STORY-003\'s composer with the card '
        '(AC-4)', (WidgetTester tester) async {
      final List<ActivityCard> seeded = <ActivityCard>[];
      await pumpScreen(
        tester,
        journalExit: (BuildContext context, ActivityCard card) async {
          seeded.add(card);
          return 'entry-1';
        },
      );

      await tester.tap(find.byKey(const Key('date-script-exit-journal')));
      await tester.pumpAndSettle();

      expect(seeded, hasLength(1));
      expect(seeded.single.id, 'card-1');
      // The provenance tag the journal stores verbatim: it names the source
      // card, and nothing about it needs parsing to be useful.
      expect(dateScriptOriginRef(seeded.single), 'date_script:card-1');
    });

    testWidgets('one tap runs one exit and no other', (
      WidgetTester tester,
    ) async {
      int invites = 0;
      int cards = 0;
      int journals = 0;
      await pumpScreen(
        tester,
        inviteExit: (BuildContext context, ActivityCard card) async {
          invites++;
          return false;
        },
        newCardExit: (BuildContext context) async {
          cards++;
          return null;
        },
        journalExit: (BuildContext context, ActivityCard card) async {
          journals++;
          return null;
        },
      );

      await tester.tap(find.byKey(const Key('date-script-exit-journal')));
      await tester.pumpAndSettle();

      expect(journals, 1);
      expect(invites, 0);
      expect(cards, 0);
    });
  });

  group('a finished exit closes screen (9), a cancelled one does not (BR-6)', () {
    testWidgets('the invite exit closes the script behind it', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        inviteExit: (BuildContext context, ActivityCard card) async => true,
      );
      expect(find.byKey(const Key('date-script-body')), findsOneWidget);

      await tester.tap(find.byKey(const Key('date-script-exit-invite')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('date-script-body')), findsNothing);
      expect(find.text('Chuẩn bị'), findsOneWidget);
    });

    testWidgets('a created card closes the script and confirms in place', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        newCardExit: (BuildContext context) async => _card(),
      );

      await tester.tap(find.byKey(const Key('date-script-exit-new-card')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('date-script-body')), findsNothing);
      expect(find.text('Đã tạo thẻ mới trong kho hoạt động'), findsOneWidget);
    });

    testWidgets('a saved journal entry closes the script', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        journalExit: (BuildContext context, ActivityCard card) async =>
            'entry-1',
      );

      await tester.tap(find.byKey(const Key('date-script-exit-journal')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('date-script-body')), findsNothing);
    });

    testWidgets('a cancelled exit leaves the reader on the part they were '
        'reading', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        inviteExit: (BuildContext context, ActivityCard card) async => false,
        newCardExit: (BuildContext context) async => null,
        journalExit: (BuildContext context, ActivityCard card) async => null,
      );

      await tester.tap(
        find.byKey(Key('date-script-part-${DateScriptPart.during.wireValue}')),
      );
      await tester.pumpAndSettle();
      final String during = _paragraph(tester);
      expect(during, isNotEmpty);
      expect(find.byKey(const Key('date-script-during-guard')), findsOneWidget);

      for (final String key in <String>[
        'date-script-exit-invite',
        'date-script-exit-new-card',
        'date-script-exit-journal',
      ]) {
        await tester.tap(find.byKey(Key(key)));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('date-script-body')), findsOneWidget);
        expect(_paragraph(tester), during);
        expect(
          find.byKey(const Key('date-script-during-guard')),
          findsOneWidget,
        );
      }

      // No confirmation dialog stands between the reader and leaving, either.
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('what the exits must not be', () {
    test('screen (9) carries no share, copy-link or clipboard path', () {
      final List<String> offenders = <String>[];
      for (final FileSystemEntity entity
          in Directory('lib/features/date_script').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }
        final String source = entity.readAsStringSync();
        for (final String forbidden in <String>[
          'Clipboard',
          'Share.share',
          'SharePlus',
          'share_plus',
          'copyLink',
          'Timer(',
        ]) {
          if (source.contains(forbidden)) {
            offenders.add('${entity.path}: $forbidden');
          }
        }
      }

      expect(offenders, isEmpty);
    });

    test('the scan would actually catch one', () {
      // Anti-vacuity: the same predicate over a string that does contain the
      // forbidden token must fail, otherwise the scan above proves nothing.
      expect('Clipboard.setData(const ClipboardData(text: x));'
          .contains('Clipboard'), isTrue);
    });

    testWidgets('no exit schedules anything', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        newCardExit: (BuildContext context) async => _card(),
      );

      await tester.tap(find.byKey(const Key('date-script-exit-new-card')));
      await tester.pumpAndSettle();

      // A pending timer here would be a reminder the J7 line forbids
      // (AC-13…AC-16/BR-3); the framework fails the test if one is left behind,
      // and the created card carries no date of its own.
      expect(tester.binding.transientCallbackCount, 0);
    });
  });

  group('visual fidelity capture', () {
    testWidgets('captures screen (9) with the sticky exit bar', (
      WidgetTester tester,
    ) async {
      await _capture(tester, 'implemented-screen-9-ba-cua-ra.png');
    }, skip: !kCaptureVisuals);
  });
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

    final String? flutterRoot = Platform.environment['FLUTTER_ROOT'];
    if (flutterRoot == null) {
      return;
    }
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
  });
}

/// The Material band rather than the iOS one: `CupidHeader`'s iOS header is a
/// `BackdropFilter`, which an offscreen `toImage()` has nothing to sample.
Future<void> _capture(WidgetTester tester, String fileName) async {
  tester.view.physicalSize = _designFrame;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await _loadDesignFonts(tester);

  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureBoundaryKey,
      child: _host(
        CupidAppBackground(
          enableEffectsOverride: false,
          child: DateScriptScreen(
            key: UniqueKey(),
            card: _card(),
            contentLoader: ContentPackageLoader(bundle: _DiskBundle()),
            notebook: _EmptyNotebook(),
            askSlotBuilder: _silentAskSlot,
            inviteExit: (BuildContext context, ActivityCard card) async => false,
            newCardExit: (BuildContext context) async => null,
            journalExit: (BuildContext context, ActivityCard card) async => null,
          ),
        ),
      ),
    ),
  );
  for (int i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pumpAndSettle();
  }

  final RenderRepaintBoundary boundary =
      tester.renderObject(find.byKey(_captureBoundaryKey))
          as RenderRepaintBoundary;

  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 1);
    final ByteData? png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final File out = File('$_visualEvidenceDir/$fileName');
    out.parent.createSync(recursive: true);
    out.writeAsBytesSync(png!.buffer.asUint8List());
  });
}
