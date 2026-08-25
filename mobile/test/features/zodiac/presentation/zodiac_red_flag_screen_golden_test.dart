import 'dart:io';

import 'package:cupid_mobile/design_system/theme/cupid_app_background.dart';
import 'package:cupid_mobile/features/zodiac/presentation/zodiac_cubit.dart';
import 'package:cupid_mobile/features/zodiac/presentation/zodiac_red_flag_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'zodiac_screen_fixtures.dart';

/// Pins the render that `visual-fidelity/visual-fidelity-report.md` signed off,
/// using the same fixture the preview entrypoint serves to the device capture.
/// Refresh with `flutter test test/features/zodiac --update-goldens` only after
/// a new capture/compare pass, never to make a red test green.
const Size _androidReferenceViewport = Size(412, 915);

/// Widget tests ship no asset bundle, so the bundled variable fonts are read
/// straight off disk; without this every glyph rasterizes as a fallback box.
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

Future<void> _pumpAtReferenceViewport(
  WidgetTester tester,
  FakeZodiacRepository repository,
) async {
  tester.view.physicalSize = _androidReferenceViewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await _loadDesignFonts(tester);
  await tester.pumpWidget(
    zodiacHarness(
      ZodiacRedFlagScreen(
        createCubit: () => ZodiacCubit(repository: repository),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}

void main() {
  testWidgets('golden: ready state, dark theme, vi locale', (
    WidgetTester tester,
  ) async {
    await _pumpAtReferenceViewport(tester, FakeZodiacRepository.ready());

    await expectLater(
      // The backdrop sits above the navigator, so the screen's own subtree
      // would golden a transparent scaffold the device never shows.
      find.byType(CupidAppBackground),
      matchesGoldenFile('goldens/zodiac_red_flag_ready.png'),
    );
  });

  testWidgets('golden: incomplete-profile state, dark theme, vi locale', (
    WidgetTester tester,
  ) async {
    await _pumpAtReferenceViewport(tester, FakeZodiacRepository.incomplete());

    await expectLater(
      // The backdrop sits above the navigator, so the screen's own subtree
      // would golden a transparent scaffold the device never shows.
      find.byType(CupidAppBackground),
      matchesGoldenFile('goldens/zodiac_red_flag_incomplete.png'),
    );
  });
}
