import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/phase_status/presentation/evening_check_in_sheet.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart'
    show ByteData, FontLoader;
import 'package:flutter_test/flutter_test.dart';

/// Copy of the `evening_check_in` item of `nudges.v1.json`, passed in the way
/// production passes it: the sheet never reaches for the pack itself.
const String _title = 'Về tới nhà chưa?';
const String _body =
    'Nếu bạn muốn, cất lại một tấm ảnh và viết một câu cho hôm nay.';
const String _cardId = 'card-42';

class _Save {
  const _Save({
    required this.line,
    required this.photoPaths,
    required this.originRef,
  });

  final String? line;
  final List<String> photoPaths;
  final String originRef;
}

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
        child: Scaffold(body: child),
      ),
    );

Widget _sheet({
  EveningPhotoPicker? pickPhotos,
  EveningJournalRoute? openJournal,
}) =>
    _host(
      EveningCheckInSheet(
        title: _title,
        body: _body,
        cardId: _cardId,
        pickPhotos: pickPhotos,
        openJournal: openJournal,
      ),
    );

// ---------------------------------------------------------------------------
// Per-story rendered evidence (`solution.md` §4 `VISUAL-FIDELITY`).
//
// The sheet opens only from a tapped OS notification on the evening of a
// scheduled date, which no in-app route reaches, so it is rendered here at the
// Android reference viewport instead. Off by default; enable with
// `--dart-define=CAPTURE_VISUALS=true`.
// ---------------------------------------------------------------------------
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');
const Size _referenceViewport = Size(412, 915);
const String _captureDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-012_phase_status_and_widget/visual-fidelity';
final GlobalKey _captureKey = GlobalKey();

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

    // The attach control's icon ships with the framework rather than under
    // `assets/fonts/`, and without it the capture shows a tofu box where the
    // one photo affordance is.
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

Future<void> _capture(WidgetTester tester, String fileName) async {
  tester.view.physicalSize = _referenceViewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await _loadDesignFonts(tester);
  // Without an opaque layer under the sheet the PNG keeps the boundary's
  // alpha and every glyph edge reads as washed out in a viewer.
  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureKey,
      child: ColoredBox(
        color: const CupidColorTokens.dark().colorBackground,
        child: _host(
          Align(
            alignment: Alignment.bottomCenter,
            // The surface and the rounded top edge come from
            // `showModalBottomSheet` in production, so the capture has to
            // restate them or the sheet reads as a bare page.
            child: Builder(
              builder: (BuildContext context) => DecoratedBox(
                decoration: BoxDecoration(
                  color: context.cupidColors.colorSurface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(context.cupidPlatform.radiusSheet),
                  ),
                ),
                child: const EveningCheckInSheet(
                  title: _title,
                  body: _body,
                  cardId: _cardId,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final RenderRepaintBoundary boundary =
      tester.renderObject(find.byKey(_captureKey)) as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 1);
    final ByteData? png =
        await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final File out = File('$_captureDir/$fileName');
    out.parent.createSync(recursive: true);
    out.writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  group('two steps, neither of them required (AC-16/AC-18)', () {
    testWidgets('the sheet repeats the words the notification used',
        (WidgetTester tester) async {
      await tester.pumpWidget(_sheet());

      expect(find.text(_title), findsOneWidget);
      expect(find.text(_body), findsOneWidget);
    });

    testWidgets('exactly one attach control and one sentence field',
        (WidgetTester tester) async {
      await tester.pumpWidget(_sheet());

      expect(find.byKey(eveningCheckInAttachKey), findsOneWidget);
      expect(find.byKey(eveningCheckInFieldKey), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('the sentence field is never disabled or greyed out (AC-18)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_sheet());

      final TextField field =
          tester.widget<TextField>(find.byKey(eveningCheckInFieldKey));
      expect(field.enabled, isTrue);
      expect(field.maxLines, 1);
    });

    testWidgets('saving with nothing filled in is allowed',
        (WidgetTester tester) async {
      final List<_Save> saved = <_Save>[];
      await tester.pumpWidget(_sheet(openJournal: _recorder(saved)));

      await tester.tap(find.byKey(eveningCheckInSaveKey));
      await tester.pumpAndSettle();

      expect(saved, hasLength(1));
      expect(saved.single.line, isNull);
      expect(saved.single.photoPaths, isEmpty);
    });
  });

  group('what saving hands to the journal (AC-19/BR-14)', () {
    testWidgets('the sentence is trimmed and tagged with its origin',
        (WidgetTester tester) async {
      final List<_Save> saved = <_Save>[];
      await tester.pumpWidget(_sheet(openJournal: _recorder(saved)));

      await tester.enterText(
        find.byKey(eveningCheckInFieldKey),
        '  hôm nay đi ăn lẩu  ',
      );
      await tester.tap(find.byKey(eveningCheckInSaveKey));
      await tester.pumpAndSettle();

      expect(saved.single.line, 'hôm nay đi ăn lẩu');
      expect(saved.single.originRef, eveningCheckInOriginRef(_cardId));
      expect(saved.single.originRef, 'req016.evening_check_in.card-42');
    });

    testWidgets('a whitespace-only sentence counts as nothing written',
        (WidgetTester tester) async {
      final List<_Save> saved = <_Save>[];
      await tester.pumpWidget(_sheet(openJournal: _recorder(saved)));

      await tester.enterText(find.byKey(eveningCheckInFieldKey), '    ');
      await tester.tap(find.byKey(eveningCheckInSaveKey));
      await tester.pumpAndSettle();

      expect(saved.single.line, isNull);
    });

    testWidgets('attached photos travel with the entry',
        (WidgetTester tester) async {
      final List<_Save> saved = <_Save>[];
      await tester.pumpWidget(
        _sheet(
          pickPhotos: () async => <String>['/tmp/a.jpg', '/tmp/b.jpg'],
          openJournal: _recorder(saved),
        ),
      );

      await tester.tap(find.byKey(eveningCheckInAttachKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(eveningCheckInSaveKey));
      await tester.pumpAndSettle();

      expect(saved.single.photoPaths, <String>['/tmp/a.jpg', '/tmp/b.jpg']);
    });

    testWidgets('the attach control reports what was picked',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _sheet(pickPhotos: () async => <String>['/tmp/a.jpg']),
      );
      final AppL10n l10n = AppL10n.of(
        tester.element(find.byKey(eveningCheckInAttachKey)),
      );

      expect(find.text(l10n.evening_check_in_attach), findsOneWidget);

      await tester.tap(find.byKey(eveningCheckInAttachKey));
      await tester.pumpAndSettle();

      expect(find.text(l10n.evening_check_in_photos_attached(1)), findsOneWidget);
      expect(find.text(l10n.evening_check_in_attach), findsNothing);
    });

    testWidgets('a cancelled picker leaves the sheet as it was',
        (WidgetTester tester) async {
      final List<_Save> saved = <_Save>[];
      await tester.pumpWidget(
        _sheet(
          pickPhotos: () async => const <String>[],
          openJournal: _recorder(saved),
        ),
      );

      await tester.tap(find.byKey(eveningCheckInAttachKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(eveningCheckInSaveKey));
      await tester.pumpAndSettle();

      expect(saved.single.photoPaths, isEmpty);
    });
  });

  group('skipping is a finished interaction (AC-17)', () {
    testWidgets('the later exit writes nothing', (WidgetTester tester) async {
      final List<_Save> saved = <_Save>[];
      await tester.pumpWidget(_sheet(openJournal: _recorder(saved)));

      await tester.tap(find.byKey(eveningCheckInLaterKey));
      await tester.pumpAndSettle();

      expect(saved, isEmpty);
    });

    testWidgets('nothing on the sheet says a thing is still owed',
        (WidgetTester tester) async {
      await tester.pumpWidget(_sheet());

      expect(find.byType(Badge), findsNothing);
      expect(find.byType(Slider), findsNothing);
      expect(
        find.byWidgetPredicate((Widget widget) => widget is Radio),
        findsNothing,
      );
      expect(find.byType(Checkbox), findsNothing);
      expect(find.byIcon(Icons.star), findsNothing);
      expect(find.byIcon(Icons.star_border), findsNothing);
      expect(find.byIcon(Icons.local_fire_department), findsNothing);
    });

    testWidgets('there are exactly two ways out and both are one tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(_sheet());

      expect(find.byKey(eveningCheckInLaterKey), findsOneWidget);
      expect(find.byKey(eveningCheckInSaveKey), findsOneWidget);
      expect(find.byType(TextButton), findsNWidgets(2));
      expect(find.byType(FilledButton), findsOneWidget);
    });
  });

  testWidgets(
    'capture: evening-check-in sheet',
    (WidgetTester tester) async {
      await _capture(tester, 'implemented-evening-check-in-sheet.png');
    },
    skip: !kCaptureVisuals,
  );
}

EveningJournalRoute _recorder(List<_Save> saved) => (
      BuildContext context, {
      required String? line,
      required List<String> photoPaths,
      required String originRef,
    }) async {
      saved.add(
        _Save(line: line, photoPaths: photoPaths, originRef: originRef),
      );
    };
