import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/widgets/status_change_picker.dart';
import 'package:cupid_mobile/features/chapter_closure/presentation/widgets/close_chapter_dialog.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phrases `ux/uiux-spec.md` §2 forbids in the closing surface: consolation,
/// second-guessing, a note to leave behind, a nudge to reach out again
/// (AC-2, AC-4, BR-9).
const List<String> _forbidden = <String>[
  'tiếc quá',
  'buồn',
  'nhớ',
  'chắc chắn không đổi ý',
  'để lại một lời nhắn',
  'thử nhắn lại',
  'vì sao',
  'lý do',
];

/// iOS reference viewport, matching the `--platform=ios` render of
/// `render-design-canvas.js` that produced the design frame this dialog is
/// compared against.
const Size _iosReferenceViewport = Size(415, 900);

/// Off by default so the ordinary scoped suite stays hermetic. Enable with
/// `flutter test test/features/chapter_closure --dart-define=CAPTURE_VISUALS=true`.
const bool _captureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

const String _visualDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-013_graceful_exit_and_return/visual-fidelity';

final GlobalKey _captureBoundaryKey = GlobalKey();

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

/// Mounts a single opener so the dialog is exercised through the same
/// `showCloseChapterDialog` entry the hub uses, and records what it returned.
Widget _opener(List<bool> results) => _host(
      Scaffold(
        body: Builder(
          builder: (BuildContext context) => Center(
            child: TextButton(
              key: const Key('open_close_chapter'),
              onPressed: () async =>
                  results.add(await showCloseChapterDialog(context)),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

Future<void> _openDialog(WidgetTester tester, List<bool> results) async {
  await tester.pumpWidget(_opener(results));
  await tester.tap(find.byKey(const Key('open_close_chapter')));
  await tester.pumpAndSettle();
}

List<String> _dialogStrings(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(
        of: find.byKey(const Key('close_chapter_dialog')),
        matching: find.byType(Text),
      ),
    )
    .map((Text text) => text.data ?? '')
    .toList(growable: false);

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
  });
}

void main() {
  testWidgets('states the impact facts and nothing else', (
    WidgetTester tester,
  ) async {
    final List<bool> results = <bool>[];
    await _openDialog(tester, results);

    expect(find.byKey(const Key('close_chapter_dialog')), findsOneWidget);
    expect(find.text('Đóng ngăn gọn gàng?'), findsOneWidget);
    for (int i = 0; i < closeChapterFacts.length; i++) {
      expect(
        find.byKey(Key('close_chapter_fact_$i')),
        findsOneWidget,
        reason: 'fact line $i is part of the stated impact',
      );
      expect(find.text(closeChapterFacts[i].first), findsOneWidget);
    }
  });

  testWidgets('offers exactly two equal choices, action verbs only', (
    WidgetTester tester,
  ) async {
    final List<bool> results = <bool>[];
    await _openDialog(tester, results);

    final List<ActivityDialogChoiceButton> buttons = tester
        .widgetList<ActivityDialogChoiceButton>(
          find.descendant(
            of: find.byKey(const Key('close_chapter_dialog')),
            matching: find.byType(ActivityDialogChoiceButton),
          ),
        )
        .toList(growable: false);

    expect(buttons, hasLength(2));
    expect(
      buttons.map((ActivityDialogChoiceButton b) => b.label),
      <String>['Huỷ', 'Đóng ngăn'],
    );
    // Same widget, same typography, same tap target: only the colour of the
    // primary action differs (`ux/uiux-spec.md` §2).
    expect(buttons.first.color == buttons.last.color, isFalse);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(Radio<Object>), findsNothing);
  });

  testWidgets('no consolation, no reason prompt, no reach-out nudge', (
    WidgetTester tester,
  ) async {
    final List<bool> results = <bool>[];
    await _openDialog(tester, results);

    for (final String rendered in _dialogStrings(tester)) {
      final String lower = rendered.toLowerCase();
      for (final String banned in _forbidden) {
        expect(
          lower.contains(banned),
          isFalse,
          reason: '"$banned" is forbidden copy, found in: $rendered',
        );
      }
    }
    expect(find.textContaining('?'), findsOneWidget);
  });

  testWidgets('confirm returns true, cancel returns false', (
    WidgetTester tester,
  ) async {
    final List<bool> results = <bool>[];
    await _openDialog(tester, results);

    await tester.tap(find.byKey(const Key('close_chapter_cancel')));
    await tester.pumpAndSettle();
    expect(results, <bool>[false]);
    expect(find.byKey(const Key('close_chapter_dialog')), findsNothing);

    await tester.tap(find.byKey(const Key('open_close_chapter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('close_chapter_confirm')));
    await tester.pumpAndSettle();
    expect(results, <bool>[false, true]);
    expect(find.byKey(const Key('close_chapter_dialog')), findsNothing);
  });

  testWidgets(
    'captures the implemented frame for visual fidelity',
    (WidgetTester tester) async {
      tester.view.physicalSize = _iosReferenceViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await _loadDesignFonts(tester);
      final List<bool> results = <bool>[];
      await tester.pumpWidget(
        RepaintBoundary(key: _captureBoundaryKey, child: _opener(results)),
      );
      await tester.tap(find.byKey(const Key('open_close_chapter')));
      await tester.pumpAndSettle();

      final RenderRepaintBoundary boundary =
          tester.renderObject(find.byKey(_captureBoundaryKey))
              as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final ui.Image image = await boundary.toImage(pixelRatio: 1);
        final ByteData? png =
            await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        final File out = File(
          '$_visualDir/implemented-j11-dong-ngan-gon-gang-ios.png',
        );
        out.parent.createSync(recursive: true);
        out.writeAsBytesSync(png!.buffer.asUint8List());
      });
    },
    skip: !_captureVisuals,
  );
}
