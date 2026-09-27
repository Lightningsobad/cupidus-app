import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/context_notebook/domain/checkin_capture_content.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_notebook_models.dart';
import 'package:cupid_mobile/features/context_notebook/presentation/widgets/context_inline_add_row.dart';
import 'package:cupid_mobile/features/phase_status/presentation/evening_check_in_sheet.dart';
import 'package:cupid_mobile/features/phase_status/presentation/widgets/checkin_capture_block.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show ByteData, FontLoader;
import 'package:flutter_test/flutter_test.dart';

const String _title = 'Về tới nhà chưa?';
const String _body =
    'Nếu bạn muốn, cất lại một tấm ảnh và viết một câu cho hôm nay.';
const String _cardId = 'card-42';
const String _cardTitle = 'Đi ăn lẩu ở Bà Triệu';

/// The check-in screen is a full screen, so the default 800x600 test surface
/// puts the new block under the fold and makes taps on it miss. Height is raised
/// and the 800 width kept: the test font is wider than the shipped one, so a
/// phone-width surface overflows the STORY-012 chip row for font reasons alone.
const Size _behaviourSurface = Size(800, 1600);

/// The Android reference viewport the design canvas is drawn for. Only the
/// capture uses it, where the real fonts are loaded.
const Size _referenceViewport = Size(412, 915);

/// The shipped package, read from disk rather than hand-written here: a test
/// that invents its own wording proves nothing about what the build renders.
final CheckinCaptureCopySet _copy = CheckinCaptureCopySet(
  ContentPackage.parse<CheckinCaptureCopy>(
    File(checkinCaptureAssetKey).readAsStringSync(),
    expectedSchemaId: checkinCaptureSchemaId,
    itemParser: checkinCaptureCopyFromJson,
    source: checkinCaptureAssetKey,
  ),
);

class _Write {
  const _Write({
    required this.kind,
    required this.value,
    required this.originCheckInRef,
    required this.cardId,
    required this.cardTitle,
  });

  final NotebookKind kind;
  final String value;
  final String originCheckInRef;
  final String? cardId;
  final String? cardTitle;
}

/// Counts what each half of saving was asked to do. The notebook half can be
/// told to fail a fixed number of times, which is the only way to reach the
/// retry state (AC-12).
class _Recorder {
  int journalCalls = 0;
  final List<_Write> writes = <_Write>[];
  int failuresLeft = 0;

  EveningJournalRoute get journal => (
        BuildContext context, {
        required String? line,
        required List<String> photoPaths,
        required String originRef,
      }) async {
        journalCalls++;
      };

  EveningCaptureWrite get write => ({
        required NotebookKind kind,
        required String value,
        required String originCheckInRef,
        String? cardId,
        String? cardTitle,
      }) async {
        if (failuresLeft > 0) {
          failuresLeft--;
          throw StateError('notebook write failed');
        }
        writes.add(
          _Write(
            kind: kind,
            value: value,
            originCheckInRef: originCheckInRef,
            cardId: cardId,
            cardTitle: cardTitle,
          ),
        );
      };
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
        child: child,
      ),
    );

const Key _launchKey = Key('launch_check_in');

/// Pushes the screen the way production does, so the conditional `pop()` of
/// `_save()` has a route to leave and the tests can tell "closed" from "stayed".
class _Launcher extends StatelessWidget {
  const _Launcher({required this.onLaunch});

  final Future<void> Function(BuildContext context) onLaunch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Builder(
          builder: (BuildContext inner) => GestureDetector(
            key: _launchKey,
            behavior: HitTestBehavior.opaque,
            onTap: () => onLaunch(inner),
            child: const SizedBox(width: 80, height: 40),
          ),
        ),
      ),
    );
  }
}

Future<void> _openSheet(
  WidgetTester tester, {
  CheckinCaptureCopySet? copy,
  _Recorder? recorder,
  String? cardTitle = _cardTitle,
}) async {
  tester.view.physicalSize = _behaviourSurface;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    _host(
      _Launcher(
        onLaunch: (BuildContext context) => EveningCheckInSheet.show(
          context,
          title: _title,
          body: _body,
          cardId: _cardId,
          cardTitle: cardTitle,
          openJournal: recorder?.journal,
          capture: copy,
          recordCapture: recorder?.write,
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(_launchKey));
  await tester.pumpAndSettle();
}

Future<void> _tapCaptureKind(WidgetTester tester, NotebookKind kind) async {
  final Finder option =
      find.byKey(Key('context-inline-add-option-${kind.wireValue}'));
  await tester.ensureVisible(option);
  await tester.pumpAndSettle();
  await tester.tap(option);
  await tester.pumpAndSettle();
}

Future<void> _enterCaptureLine(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.byKey(eveningCheckInCaptureFieldKey));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(eveningCheckInCaptureFieldKey), text);
  await tester.pumpAndSettle();
}

void main() {
  group('where the optional ask sits (AC-1, AC-7)', () {
    testWidgets('it follows the photos and the sentence and comes before the '
        'save button', (WidgetTester tester) async {
      await _openSheet(tester, copy: _copy, recorder: _Recorder());

      final double journalField =
          tester.getTopLeft(find.byKey(eveningCheckInFieldKey)).dy;
      final double capture =
          tester.getTopLeft(find.byKey(eveningCheckInCaptureKey)).dy;
      final double save =
          tester.getTopLeft(find.byKey(eveningCheckInSaveKey)).dy;

      expect(capture, greaterThan(journalField));
      expect(save, greaterThan(capture));
    });

    testWidgets('a divider separates it, not a surface of its own',
        (WidgetTester tester) async {
      await _openSheet(tester, copy: _copy, recorder: _Recorder());

      expect(
        find.descendant(
          of: find.byKey(eveningCheckInCaptureKey),
          matching: find.byType(Divider),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the question and its optional marker come from the package',
        (WidgetTester tester) async {
      await _openSheet(tester, copy: _copy, recorder: _Recorder());

      expect(find.text(_copy.text(checkinCaptureQuestionId)), findsOneWidget);
      expect(
        find.text(_copy.text(checkinCaptureOptionalLabelId)),
        findsOneWidget,
      );
    });

    testWidgets('the two STORY-012 chips keep their place and their meaning',
        (WidgetTester tester) async {
      await _openSheet(tester, copy: _copy, recorder: _Recorder());
      final AppL10n l10n = AppL10n.of(
        tester.element(find.byKey(eveningCheckInFieldKey)),
      );

      for (final String label in <String>[
        l10n.evening_check_in_journal_chip,
        l10n.evening_check_in_private_chip,
      ]) {
        expect(find.text(label), findsOneWidget);
        expect(
          tester.getTopLeft(find.text(label)).dy,
          lessThan(tester.getTopLeft(find.byKey(eveningCheckInCaptureKey)).dy),
        );
      }
    });

    testWidgets('a build with no shipped wording has no block at all',
        (WidgetTester tester) async {
      await _openSheet(tester, recorder: _Recorder());

      expect(find.byKey(eveningCheckInCaptureKey), findsNothing);
      expect(find.byKey(eveningCheckInCaptureFieldKey), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('one line and one group, nothing else (AC-3, AC-17, BR-4)', () {
    testWidgets('nothing is selected when the screen opens',
        (WidgetTester tester) async {
      await _openSheet(tester, copy: _copy, recorder: _Recorder());

      final ContextInlineSegmented segmented =
          tester.widget<ContextInlineSegmented>(
        find.byType(ContextInlineSegmented),
      );
      expect(segmented.selectedId, isNull);
      expect(segmented.options, hasLength(2));
    });

    testWidgets('typing never selects a group on the user\'s behalf',
        (WidgetTester tester) async {
      await _openSheet(tester, copy: _copy, recorder: _Recorder());

      await _enterCaptureLine(tester, 'thích cà phê muối');

      expect(
        tester
            .widget<ContextInlineSegmented>(
              find.byType(ContextInlineSegmented),
            )
            .selectedId,
        isNull,
      );
    });

    testWidgets('one single-line field, no date, detail or third choice',
        (WidgetTester tester) async {
      await _openSheet(tester, copy: _copy, recorder: _Recorder());

      // The sentence field and this one, and no others.
      expect(find.byType(TextField), findsNWidgets(2));
      final TextField field = tester.widget<TextField>(
        find.byKey(eveningCheckInCaptureFieldKey),
      );
      expect(field.maxLines, 1);
      expect(
        find.descendant(
          of: find.byKey(eveningCheckInCaptureKey),
          matching: find.byType(InkWell),
        ),
        findsNWidgets(2),
      );
    });

    testWidgets('the field never carries over what was written for the journal',
        (WidgetTester tester) async {
      await _openSheet(tester, copy: _copy, recorder: _Recorder());

      await tester.enterText(
        find.byKey(eveningCheckInFieldKey),
        'hôm nay đi ăn lẩu',
      );
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<TextField>(find.byKey(eveningCheckInCaptureFieldKey))
            .controller!
            .text,
        isEmpty,
      );
    });
  });

  group('leaving the block alone is silent (AC-2, AC-17)', () {
    testWidgets('an untouched block writes nothing and the screen closes',
        (WidgetTester tester) async {
      final _Recorder recorder = _Recorder();
      await _openSheet(tester, copy: _copy, recorder: recorder);

      await tester.tap(find.byKey(eveningCheckInSaveKey));
      await tester.pumpAndSettle();

      expect(recorder.writes, isEmpty);
      expect(recorder.journalCalls, 1);
      expect(find.byKey(eveningCheckInSheetKey), findsNothing);
    });

    testWidgets('a blank line counts as leaving it alone',
        (WidgetTester tester) async {
      final _Recorder recorder = _Recorder();
      await _openSheet(tester, copy: _copy, recorder: recorder);

      await _enterCaptureLine(tester, '    ');
      await tester.tap(find.byKey(eveningCheckInSaveKey));
      await tester.pumpAndSettle();

      expect(recorder.writes, isEmpty);
      expect(recorder.journalCalls, 1);
      expect(find.byKey(eveningCheckInSheetKey), findsNothing);
    });
  });

  group('typed with no group chosen (AC-16, BR-4, BR-10)', () {
    testWidgets('the line is not written, the sentence still is, and the '
        'screen stays', (WidgetTester tester) async {
      final _Recorder recorder = _Recorder();
      await _openSheet(tester, copy: _copy, recorder: recorder);

      await _enterCaptureLine(tester, 'thích cà phê muối');
      await tester.tap(find.byKey(eveningCheckInSaveKey));
      await tester.pumpAndSettle();

      expect(recorder.writes, isEmpty);
      expect(recorder.journalCalls, 1);
      expect(find.byKey(eveningCheckInSheetKey), findsOneWidget);
      expect(find.byKey(eveningCheckInCaptureHintKey), findsOneWidget);
      expect(
        tester
            .widget<ContextInlineSegmented>(
              find.byType(ContextInlineSegmented),
            )
            .selectedId,
        isNull,
      );
    });

    testWidgets('the message appears only once the save button was tapped',
        (WidgetTester tester) async {
      await _openSheet(tester, copy: _copy, recorder: _Recorder());

      await _enterCaptureLine(tester, 'thích cà phê muối');

      expect(find.byKey(eveningCheckInCaptureHintKey), findsNothing);
    });

    testWidgets('choosing a group then writes the line, with no second tap on '
        'save', (WidgetTester tester) async {
      final _Recorder recorder = _Recorder();
      await _openSheet(tester, copy: _copy, recorder: recorder);

      await _enterCaptureLine(tester, '  thích cà phê muối  ');
      await tester.tap(find.byKey(eveningCheckInSaveKey));
      await tester.pumpAndSettle();
      await _tapCaptureKind(tester, NotebookKind.interest);

      expect(recorder.writes, hasLength(1));
      expect(recorder.writes.single.kind, NotebookKind.interest);
      expect(recorder.writes.single.value, 'thích cà phê muối');
      expect(
        recorder.writes.single.originCheckInRef,
        eveningCheckInOriginRef(_cardId),
      );
      expect(recorder.writes.single.cardId, _cardId);
      expect(recorder.writes.single.cardTitle, _cardTitle);
      expect(recorder.journalCalls, 1);
      expect(find.byKey(eveningCheckInSheetKey), findsNothing);
    });

    testWidgets('clearing the line takes the message away',
        (WidgetTester tester) async {
      await _openSheet(tester, copy: _copy, recorder: _Recorder());

      await _enterCaptureLine(tester, 'thích cà phê muối');
      await tester.tap(find.byKey(eveningCheckInSaveKey));
      await tester.pumpAndSettle();
      expect(find.byKey(eveningCheckInCaptureHintKey), findsOneWidget);

      await _enterCaptureLine(tester, '');

      expect(find.byKey(eveningCheckInCaptureHintKey), findsNothing);
      expect(find.byKey(eveningCheckInSheetKey), findsOneWidget);
    });
  });

  group('the notebook half failing on its own (AC-12, BR-10)', () {
    testWidgets('the failure is reported inside the block and keeps what was '
        'typed', (WidgetTester tester) async {
      final _Recorder recorder = _Recorder()..failuresLeft = 1;
      await _openSheet(tester, copy: _copy, recorder: recorder);

      await _enterCaptureLine(tester, 'sinh nhật mẹ bạn ấy');
      await _tapCaptureKind(tester, NotebookKind.event);
      await tester.tap(find.byKey(eveningCheckInSaveKey));
      await tester.pumpAndSettle();

      expect(recorder.writes, isEmpty);
      expect(recorder.journalCalls, 1);
      expect(find.byKey(eveningCheckInSheetKey), findsOneWidget);
      expect(find.byKey(eveningCheckInCaptureErrorKey), findsOneWidget);
      expect(find.byKey(eveningCheckInCaptureRetryKey), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(eveningCheckInCaptureFieldKey))
            .controller!
            .text,
        'sinh nhật mẹ bạn ấy',
      );
      expect(
        tester
            .widget<ContextInlineSegmented>(
              find.byType(ContextInlineSegmented),
            )
            .selectedId,
        NotebookKind.event.wireValue,
      );
    });

    testWidgets('retrying writes the same check-in once and never touches the '
        'sentence again', (WidgetTester tester) async {
      final _Recorder recorder = _Recorder()..failuresLeft = 1;
      await _openSheet(tester, copy: _copy, recorder: recorder);

      await _enterCaptureLine(tester, 'sinh nhật mẹ bạn ấy');
      await _tapCaptureKind(tester, NotebookKind.event);
      await tester.tap(find.byKey(eveningCheckInSaveKey));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(eveningCheckInCaptureRetryKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(eveningCheckInCaptureRetryKey));
      await tester.pumpAndSettle();

      expect(recorder.writes, hasLength(1));
      expect(
        recorder.writes.single.originCheckInRef,
        eveningCheckInOriginRef(_cardId),
      );
      expect(recorder.journalCalls, 1);
      expect(find.byKey(eveningCheckInSheetKey), findsNothing);
    });
  });

  testWidgets('two taps in a row are one save (AC-8)',
      (WidgetTester tester) async {
    final _Recorder recorder = _Recorder();
    await _openSheet(tester, copy: _copy, recorder: recorder);

    await _enterCaptureLine(tester, 'thích cà phê muối');
    await _tapCaptureKind(tester, NotebookKind.interest);
    await tester.tap(find.byKey(eveningCheckInSaveKey));
    await tester.pump();
    await tester.tap(find.byKey(eveningCheckInSaveKey), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(recorder.writes, hasLength(1));
    expect(recorder.journalCalls, 1);
  });

  testWidgets('an unreadable card title still writes the line (AC-9)',
      (WidgetTester tester) async {
    final _Recorder recorder = _Recorder();
    await _openSheet(tester, copy: _copy, recorder: recorder, cardTitle: null);

    await _enterCaptureLine(tester, 'thích cà phê muối');
    await _tapCaptureKind(tester, NotebookKind.interest);
    await tester.tap(find.byKey(eveningCheckInSaveKey));
    await tester.pumpAndSettle();

    expect(recorder.writes, hasLength(1));
    expect(recorder.writes.single.cardTitle, isNull);
    expect(recorder.writes.single.cardId, _cardId);
  });

  testWidgets(
    'capture: 23h check-in screen with the optional notebook ask',
    (WidgetTester tester) async {
      await _capture(tester, 'implemented-23h-vua-ve-j8-capture-block.png');
    },
    skip: !kCaptureVisuals,
  );
}

// ---------------------------------------------------------------------------
// Per-story rendered evidence (`solution.md` §4 `VISUAL-FIDELITY`).
//
// The screen is reachable only from a tapped 23h notification, so no running-app
// route leads here; it is rendered from the widget tree instead. Off by default;
// enable with `--dart-define=CAPTURE_VISUALS=true`.
// ---------------------------------------------------------------------------
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');
const String _captureDir =
    '../data/requirements/REQ-017_checkin_notebook_capture/'
    'STORY-001_checkin_notebook_capture/visual-fidelity';
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

    // The photo slots use a framework icon rather than one under `assets/fonts`,
    // and without it the capture shows tofu where the photo step is.
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
  // Without an opaque layer under the screen the PNG keeps the boundary's alpha
  // and every glyph edge reads as washed out in a viewer.
  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureKey,
      child: ColoredBox(
        color: const CupidColorTokens.dark().colorBackground,
        child: _host(
          EveningCheckInSheet(
            title: _title,
            body: _body,
            cardId: _cardId,
            cardTitle: _cardTitle,
            capture: _copy,
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
