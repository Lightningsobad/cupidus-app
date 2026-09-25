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
const String _cardTitle = 'Đi ăn lẩu ở Bà Triệu';

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
      // D-6: the surface carries its own `Scaffold`, so the host must not add a
      // second one — a page, not a sheet floated over a host page.
      home: CupidPlatformOverride(
        platform: CupidPlatform.material,
        child: child,
      ),
    );

Widget _sheet({
  String? cardTitle,
  EveningPhotoPicker? pickPhotos,
  EveningJournalRoute? openJournal,
}) =>
    _host(
      EveningCheckInSheet(
        title: _title,
        body: _body,
        cardId: _cardId,
        cardTitle: cardTitle,
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
          const EveningCheckInSheet(
            title: _title,
            body: _body,
            cardId: _cardId,
            cardTitle: _cardTitle,
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

    testWidgets('the photo step shows its three places before anything is '
        'picked', (WidgetTester tester) async {
      await tester.pumpWidget(_sheet());

      expect(find.byKey(eveningCheckInAttachKey), findsOneWidget);
      expect(find.byKey(const Key('evening_check_in_slot_1')), findsOneWidget);
      expect(find.byKey(const Key('evening_check_in_slot_2')), findsOneWidget);
      expect(find.byIcon(Icons.add_photo_alternate_outlined), findsNWidgets(3));
    });

    testWidgets('a picked photo fills a place and leaves the rest empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _sheet(pickPhotos: () async => <String>['/tmp/a.jpg']),
      );

      await tester.tap(find.byKey(eveningCheckInAttachKey));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_photo_alternate_outlined), findsNWidgets(2));
    });

    testWidgets('the sentence field is never disabled or greyed out (AC-18)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_sheet());

      final TextField field =
          tester.widget<TextField>(find.byKey(eveningCheckInFieldKey));
      expect(field.enabled, isTrue);
      // D-6: the full screen gives the sentence room to be several lines long.
      // What AC-18 asks is that nothing locks or bounds what may be written, so
      // what matters here is that no maximum length is imposed and the field
      // opens already large enough to write into.
      expect(field.maxLength, isNull);
      expect(field.readOnly, isFalse);
      expect(field.minLines, greaterThan(1));
      expect(field.maxLines, greaterThan(field.minLines!));
      expect(field.keyboardType, TextInputType.multiline);
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

    testWidgets('a build without the journal drops the whole sentence step at '
        'once (AC-18)', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const EveningCheckInSheet(
            title: _title,
            body: _body,
            cardId: _cardId,
            journalAvailable: false,
          ),
        ),
      );
      final AppL10n l10n = AppL10n.of(
        tester.element(find.byKey(eveningCheckInAttachKey)),
      );

      expect(find.byKey(eveningCheckInFieldKey), findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.text(l10n.evening_check_in_line_label), findsNothing);
      expect(find.text(l10n.evening_check_in_journal_chip), findsNothing);
      expect(find.text(l10n.evening_check_in_private_chip), findsNothing);
      expect(find.byKey(eveningCheckInAttachKey), findsOneWidget);
      expect(find.byKey(eveningCheckInReassuranceKey), findsOneWidget);
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
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });
  });

  group('the shape the design canvas asks for (D-6/D-8/D-9)', () {
    testWidgets('the surface is a full screen, not a low sheet',
        (WidgetTester tester) async {
      await tester.pumpWidget(_sheet());

      // Its own `Scaffold` over the brand background, sized to the whole
      // viewport rather than to its content.
      final Scaffold scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const CupidColorTokens.dark().colorBackground);
      expect(
        tester.getSize(find.byKey(eveningCheckInSheetKey)).height,
        tester.view.physicalSize.height / tester.view.devicePixelRatio,
      );
    });

    testWidgets('the screen names the evening it is asking about (D-8)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_sheet(cardTitle: _cardTitle));

      expect(find.byKey(eveningCheckInContextKey), findsOneWidget);
      expect(find.byKey(eveningCheckInCardTitleKey), findsOneWidget);
      expect(find.text(_cardTitle), findsOneWidget);
    });

    testWidgets('an unreadable card leaves the name out, not the screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(_sheet());

      expect(find.byKey(eveningCheckInContextKey), findsOneWidget);
      expect(find.byKey(eveningCheckInCardTitleKey), findsNothing);
      expect(find.byKey(eveningCheckInFieldKey), findsOneWidget);
      expect(find.byKey(eveningCheckInSaveKey), findsOneWidget);
    });

    testWidgets('the exit says in words that nothing is owed (D-9/AC-17)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_sheet());
      final AppL10n l10n = AppL10n.of(
        tester.element(find.byKey(eveningCheckInFieldKey)),
      );

      expect(find.byKey(eveningCheckInReassuranceKey), findsOneWidget);
      expect(find.text(l10n.evening_check_in_reassurance), findsOneWidget);
    });

    testWidgets('the two statements about a saved sentence are not controls',
        (WidgetTester tester) async {
      await tester.pumpWidget(_sheet());
      final AppL10n l10n = AppL10n.of(
        tester.element(find.byKey(eveningCheckInFieldKey)),
      );

      for (final String label in <String>[
        l10n.evening_check_in_journal_chip,
        l10n.evening_check_in_private_chip,
      ]) {
        expect(find.text(label), findsOneWidget);
        expect(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(InkWell),
          ),
          findsNothing,
        );
      }
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
