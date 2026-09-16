import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/activity_cards/domain/time_of_day_slot.dart';
import 'package:cupid_mobile/features/context_notebook/context_notebook_entry_point.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_dao.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_repository.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_notebook_models.dart'
    show ContextEntrySource;
import 'package:cupid_mobile/features/date_script/domain/date_script_content.dart';
import 'package:cupid_mobile/features/date_script/presentation/screens/date_script_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rendered evidence for the per-story visual fidelity gate. Screen (9) is
/// deliberately route-less (BR-1a), so no deep-link capture tool can reach it
/// on a device build — it is captured from the widget tree instead.
///
/// `flutter test test/features/date_script/date_script_screen_test.dart \
///   --dart-define=CAPTURE_VISUALS=true --plain-name="visual fidelity capture"`
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

/// Inside `mobile/` because this story's declared write scope is `mobile` plus
/// three coding-plan files; `data/requirements/.../visual-fidelity/` is not in
/// it. See the P3 deviations note in `coding-plan/test-results.md`.
const String _visualEvidenceDir = 'test/features/date_script/visual-fidelity';

/// The viewport the design canvas renders an iOS frame at, so a capture
/// compares without rescaling either side.
const Size _designFrame = Size(415, 900);

/// Taller than the 800x600 default: the content column plus the room P4's
/// sticky exit bar will take would otherwise push a segment off-screen and make
/// `tap` miss silently.
const Size _tallFrame = Size(415, 1400);

final GlobalKey _captureBoundaryKey = GlobalKey();

/// Reads the shipped assets straight off disk and counts every read.
///
/// Deliberately not a [CachingAssetBundle]: the cache would answer the second
/// `loadString` itself, and the AC-7 assertion below — that switching parts
/// never re-reads the pack — would pass no matter what the screen did.
class _CountingDiskBundle extends AssetBundle {
  int loads = 0;

  @override
  Future<ByteData> load(String key) async {
    loads++;
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

/// Serves one authored-in-test pack, so the "answering makes the script less
/// generic" assertion is about the screen and not about what the shipped copy
/// happens to say today.
class _FixtureBundle extends AssetBundle {
  _FixtureBundle(this._sources);

  final Map<String, String> _sources;

  @override
  Future<ByteData> load(String key) async {
    final String? source = _sources[key];
    if (source == null) {
      throw FlutterError('no fixture for asset "$key"');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(source)));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      utf8.decode((await load(key)).buffer.asUint8List());

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String value) parser,
  ) async => parser(await loadString(key));
}

const String _conditionalMarker = 'CAU-CAN-SO-THICH';

/// One generic preset whose "before" part holds an unconditional sentence and a
/// second sentence that only survives once an interest is written down.
String _fixturePackJson() => jsonEncode(<String, Object?>{
  'id': 'req016.date_script',
  'version': '1.0.0',
  'schema_id': dateScriptSchemaId,
  'locale': 'vi',
  'items': <Map<String, Object?>>[
    <String, Object?>{
      'id': 'fixture.generic.v1',
      'activityTypes': <String>[],
      'parts': <Map<String, Object?>>[
        <String, Object?>{
          'part': 'before',
          'sentences': <Map<String, Object?>>[
            <String, Object?>{
              'text': 'CAU-LUON-CO-TRUOC.',
              'requires': <String>[],
              'aboutPartner': false,
            },
            <String, Object?>{
              'text': '$_conditionalMarker {interest}.',
              'requires': <String>['interest'],
              'aboutPartner': false,
            },
          ],
        },
        <String, Object?>{
          'part': 'during',
          'sentences': <Map<String, Object?>>[
            <String, Object?>{
              'text': 'CAU-LUON-CO-TRONG.',
              'requires': <String>[],
              'aboutPartner': false,
            },
          ],
        },
        <String, Object?>{
          'part': 'after',
          'sentences': <Map<String, Object?>>[
            <String, Object?>{
              'text': 'CAU-LUON-CO-SAU.',
              'requires': <String>[],
              'aboutPartner': false,
            },
          ],
        },
      ],
    },
  ],
});

/// A notebook the test drives directly, and which records how many times the
/// screen read it.
class _FakeNotebook implements ContextNotebookReader {
  _FakeNotebook([this.rows = const <NotebookEntry>[]]);

  List<NotebookEntry> rows;
  int reads = 0;

  @override
  Future<List<NotebookEntry>> entries({NotebookKind? kind}) async {
    reads++;
    return <NotebookEntry>[
      for (final NotebookEntry entry in rows)
        if (kind == null || entry.kind == kind) entry,
    ];
  }

  @override
  Future<List<SkillEntry>> skills() async => const <SkillEntry>[];
}

NotebookEntry _interest(String value) => NotebookEntry(
  id: 'entry-1',
  ownerKey: 'owner-1',
  kind: NotebookKind.interest,
  value: value,
  source: ContextEntrySource.manual,
  createdAt: DateTime.utc(2026, 9, 1),
  updatedAt: DateTime.utc(2026, 9, 1),
);

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

    // The back chevron ships with the framework rather than under
    // `assets/fonts/` (`uses-material-design: true`). Without it the capture
    // shows a tofu box and proves nothing about the header.
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

String _paragraph(WidgetTester tester) =>
    tester
        .widget<Text>(find.byKey(const Key('date-script-paragraph')))
        .data ??
    '';

void main() {
  late _CountingDiskBundle bundle;
  late _FakeNotebook notebook;

  setUp(() {
    bundle = _CountingDiskBundle();
    notebook = _FakeNotebook();
  });

  void useFrame(WidgetTester tester, [Size size = _tallFrame]) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    AssetBundle? assets,
    ContextNotebookReader? reader,
    DateScriptAskSlotBuilder? askSlotBuilder,
  }) async {
    useFrame(tester);
    await tester.pumpWidget(
      _host(
        DateScriptScreen(
          card: _card(),
          contentLoader: ContentPackageLoader(bundle: assets ?? bundle),
          notebook: reader ?? notebook,
          askSlotBuilder: askSlotBuilder ?? _silentAskSlot,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapPart(WidgetTester tester, DateScriptPart part) async {
    await tester.tap(find.byKey(Key('date-script-part-${part.wireValue}')));
    await tester.pumpAndSettle();
  }

  group('the three parts', () {
    testWidgets('the screen opens on "Trước" with a rendered paragraph', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);

      expect(find.byKey(const Key('date-script-body')), findsOneWidget);
      expect(find.text('Kịch bản buổi hẹn'), findsOneWidget);
      expect(find.byKey(const Key('date-script-parts')), findsOneWidget);
      expect(_paragraph(tester), isNotEmpty);
    });

    testWidgets(
      'switching parts keeps the same script and never re-reads the pack '
      '(AC-7)',
      (WidgetTester tester) async {
        await pumpScreen(tester);

        final int loadsAfterOpen = bundle.loads;
        final String before = _paragraph(tester);
        expect(loadsAfterOpen, 1);

        await tapPart(tester, DateScriptPart.during);
        final String during = _paragraph(tester);
        await tapPart(tester, DateScriptPart.after);
        final String after = _paragraph(tester);
        await tapPart(tester, DateScriptPart.before);

        // Same pack read, same notebook read, same paragraph coming back: the
        // selector cannot have run a second time.
        expect(bundle.loads, loadsAfterOpen);
        expect(notebook.reads, 1);
        expect(_paragraph(tester), before);
        expect(during, isNotEmpty);
        expect(after, isNotEmpty);
        expect(during, isNot(before));
        expect(after, isNot(before));
      },
    );

    testWidgets('only "Trong" carries the J7 guard caption (BR-3)', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);
      expect(find.byKey(const Key('date-script-during-guard')), findsNothing);

      await tapPart(tester, DateScriptPart.during);
      expect(find.byKey(const Key('date-script-during-guard')), findsOneWidget);
      expect(
        find.text('Đọc trước khi đi — không phải nhắc trong lúc hẹn'),
        findsOneWidget,
      );

      await tapPart(tester, DateScriptPart.after);
      expect(find.byKey(const Key('date-script-during-guard')), findsNothing);
    });

    testWidgets('no part offers a timer, a countdown, or a "start" control '
        '(AC-13..AC-16)', (WidgetTester tester) async {
      await pumpScreen(tester);

      for (final DateScriptPart part in DateScriptPart.values) {
        await tapPart(tester, part);
        // `testWidgets` fails the test outright if a `Timer` outlives it, so
        // advancing the clock this far with no pending timer and no rebuilt
        // paragraph is the assertion, not the setup.
        final String settled = _paragraph(tester);
        await tester.pump(const Duration(minutes: 30));
        expect(_paragraph(tester), settled);
      }

      // No button of any kind on this phase's screen: the exit bar is P4's and
      // nothing stands in for it, least of all a "bắt đầu buổi hẹn" affordance.
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).bottomNavigationBar,
        isNull,
      );
    });
  });

  group('the inline ask', () {
    testWidgets('an empty notebook still renders a usable script (AC-5)', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);

      expect(notebook.rows, isEmpty);
      for (final DateScriptPart part in DateScriptPart.values) {
        await tapPart(tester, part);
        expect(_paragraph(tester), isNotEmpty);
      }
    });

    testWidgets('the slot is handed this screen\'s identity and its two '
        'notebook targets', (WidgetTester tester) async {
      String? seenEntryPoint;
      List<String>? seenFields;

      await pumpScreen(
        tester,
        askSlotBuilder:
            ({
              required String entryPointId,
              required List<String> neededFieldIds,
              required VoidCallback onContextChanged,
            }) {
              seenEntryPoint = entryPointId;
              seenFields = neededFieldIds;
              return const SizedBox.shrink();
            },
      );

      expect(seenEntryPoint, 'date_script');
      expect(seenFields, <String>['notebook.interest', 'notebook.event']);
    });

    testWidgets('an empty notebook shows exactly one question (AC-5/AC-25)', (
      WidgetTester tester,
    ) async {
      final CupidDatabase database = CupidDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final ContextNotebookRepository repository = ContextNotebookRepository(
        dao: ContextNotebookDao(database),
        ownerKeyStore: BackendUserIdStore()..updateUserId('user-1'),
      );

      await pumpScreen(
        tester,
        askSlotBuilder:
            ({
              required String entryPointId,
              required List<String> neededFieldIds,
              required VoidCallback onContextChanged,
            }) => AskOnTheSpotSlot(
              entryPointId: entryPointId,
              neededFieldIds: neededFieldIds,
              onContextChanged: onContextChanged,
              repository: repository,
              contentLoader: ContentPackageLoader(bundle: _CountingDiskBundle()),
            ),
      );

      for (int i = 0; i < 5; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pumpAndSettle();
      }

      expect(find.byKey(const Key('ask-on-the-spot-card')), findsOneWidget);
      expect(find.byKey(const Key('ask-on-the-spot-prompt')), findsOneWidget);
      expect(find.byKey(const Key('ask-skip')), findsOneWidget);
      expect(_paragraph(tester), isNotEmpty);
    });

    testWidgets('answering re-renders in place, without leaving the screen or '
        're-reading the pack (AC-24)', (WidgetTester tester) async {
      final _FixtureBundle fixture = _FixtureBundle(<String, String>{
        dateScriptAssetKey: _fixturePackJson(),
      });

      await pumpScreen(
        tester,
        assets: fixture,
        askSlotBuilder:
            ({
              required String entryPointId,
              required List<String> neededFieldIds,
              required VoidCallback onContextChanged,
            }) => TextButton(
              key: const Key('stub-ask-answer'),
              onPressed: onContextChanged,
              child: const Text('stub'),
            ),
      );

      expect(_paragraph(tester), isNot(contains(_conditionalMarker)));
      expect(notebook.reads, 1);

      notebook.rows = <NotebookEntry>[_interest('phim khoa học viễn tưởng')];
      await tester.tap(find.byKey(const Key('stub-ask-answer')));
      await tester.pumpAndSettle();

      expect(_paragraph(tester), contains(_conditionalMarker));
      expect(_paragraph(tester), contains('phim khoa học viễn tưởng'));
      expect(notebook.reads, 2);
      // Same screen, same route, same pack: answering never navigates and
      // never re-reads content.
      expect(find.byKey(const Key('date-script-body')), findsOneWidget);
      expect(find.text('Kịch bản buổi hẹn'), findsOneWidget);
    });
  });

  group('visual fidelity capture', () {
    testWidgets('captures the three states', (WidgetTester tester) async {
      await _capture(
        tester,
        'implemented-screen-9-kich-ban-buoi-hen-truoc.png',
        notebook: _FakeNotebook(<NotebookEntry>[_interest('phim tài liệu')]),
      );
      await _capture(
        tester,
        'implemented-screen-9-kich-ban-buoi-hen-trong.png',
        notebook: _FakeNotebook(<NotebookEntry>[_interest('phim tài liệu')]),
        part: DateScriptPart.during,
      );
      await _capture(
        tester,
        'implemented-screen-9-kich-ban-buoi-hen-so-tay-trong.png',
        notebook: _FakeNotebook(),
        withAsk: true,
      );
    }, skip: !kCaptureVisuals);
  });
}

/// A slot that renders nothing, which is the shape the real one takes once the
/// cadence policy is satisfied. Used wherever the assertion is about the script
/// rather than about the question.
Widget _silentAskSlot({
  required String entryPointId,
  required List<String> neededFieldIds,
  required VoidCallback onContextChanged,
}) => const SizedBox.shrink(key: Key('date-script-ask-slot'));

/// The Material band rather than the iOS one: `CupidHeader`'s iOS header is a
/// `BackdropFilter`, and an offscreen `RenderRepaintBoundary.toImage()` has no
/// backdrop to sample, so the title washes out of an iOS capture.
Future<void> _capture(
  WidgetTester tester,
  String fileName, {
  required _FakeNotebook notebook,
  DateScriptPart part = DateScriptPart.before,
  bool withAsk = false,
}) async {
  tester.view.physicalSize = _designFrame;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await _loadDesignFonts(tester);

  DateScriptAskSlotBuilder slot = _silentAskSlot;
  if (withAsk) {
    final CupidDatabase database = CupidDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final ContextNotebookRepository repository = ContextNotebookRepository(
      dao: ContextNotebookDao(database),
      ownerKeyStore: BackendUserIdStore()..updateUserId('user-1'),
    );
    slot =
        ({
          required String entryPointId,
          required List<String> neededFieldIds,
          required VoidCallback onContextChanged,
        }) => AskOnTheSpotSlot(
          entryPointId: entryPointId,
          neededFieldIds: neededFieldIds,
          onContextChanged: onContextChanged,
          repository: repository,
          contentLoader: ContentPackageLoader(bundle: _CountingDiskBundle()),
        );
  }

  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureBoundaryKey,
      child: _host(
        // The dark sky wash is mounted at the composition root, not by each
        // screen, so a capture without it reads as a light-mode regression.
        CupidAppBackground(
          enableEffectsOverride: false,
          child: DateScriptScreen(
            key: UniqueKey(),
            card: _card(),
            contentLoader: ContentPackageLoader(bundle: _CountingDiskBundle()),
            notebook: notebook,
            askSlotBuilder: slot,
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

  if (part != DateScriptPart.before) {
    await tester.tap(find.byKey(Key('date-script-part-${part.wireValue}')));
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
