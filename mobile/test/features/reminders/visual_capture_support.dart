import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// STORY-021 F-1 rendered-evidence capture.
///
/// The reminder screens cannot be reached in the `main_preview.dart` harness
/// without a live backend: `alarm` resolves to the DI-backed
/// `ReminderScheduleScreen`, and the firing overlay only mounts when
/// `ReminderFiringCubit` receives a server `triggerAlarm` event. Rendering the
/// same widgets here reaches both AC-bearing states deterministically, at the
/// exact viewport the design reference was rendered at.
///
/// Off by default so the ordinary scoped suite stays hermetic. Enable with:
/// `flutter test test/features/reminders --dart-define=CAPTURE_VISUALS=true`
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

/// Android reference viewport, matching `[data-plat="md"]` in the design
/// canvas and the `--platform=android` render of `render-design-canvas.js`.
const Size kAndroidReferenceViewport = Size(412, 915);

const String _outputDir =
    '../data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/'
    'STORY-021_synced_reminder_design_fidelity/visual-fidelity';

final GlobalKey captureBoundaryKey = GlobalKey();

/// Widget tests ship no asset bundle, so the bundled variable fonts are read
/// straight off disk. Without this every glyph rasterizes as a fallback box
/// and the capture is worthless for typography comparison.
Future<void> loadDesignFonts(WidgetTester tester) async {
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

/// Renders [app] at the Android reference viewport and writes the result to
/// `<visual-fidelity>/<fileName>` as a 412x915 PNG.
///
/// Not `pumpAndSettle`: the firing overlay's shake controller repeats forever.
Future<void> captureAtReferenceViewport(
  WidgetTester tester,
  Widget app,
  String fileName,
) async {
  tester.view.physicalSize = kAndroidReferenceViewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await loadDesignFonts(tester);
  await tester.pumpWidget(
    RepaintBoundary(key: captureBoundaryKey, child: app),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));

  final RenderRepaintBoundary boundary =
      tester.renderObject(find.byKey(captureBoundaryKey))
          as RenderRepaintBoundary;

  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 1);
    final ByteData? png = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();
    final File out = File('$_outputDir/$fileName');
    out.parent.createSync(recursive: true);
    out.writeAsBytesSync(png!.buffer.asUint8List());
  });
}
