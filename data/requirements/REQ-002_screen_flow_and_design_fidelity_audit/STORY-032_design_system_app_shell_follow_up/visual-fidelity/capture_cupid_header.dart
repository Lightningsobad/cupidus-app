// Capture harness for the AC3 `CupidHeader` render.
//
// Run from the `mobile/` package root:
//   flutter test ../data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-032_design_system_app_shell_follow_up/visual-fidelity/capture_cupid_header.dart
//
// It mirrors `CupidApp`'s composition root (CupidAppBackground builder, dark
// Material theme, `vi` locale) and rasterizes `VibeScreen`, which mounts an
// unmodified `CupidHeader` at `vibe_screen.dart:79`.

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/vibes/data/vibes_repository.dart';
import 'package:cupid_mobile/features/vibes/domain/vibe_entry.dart';
import 'package:cupid_mobile/features/vibes/presentation/vibe_cubit.dart';
import 'package:cupid_mobile/features/vibes/presentation/vibe_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const Key _captureKey = Key('story032_capture_root');

const String _outputDir =
    '../data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/'
    'STORY-032_design_system_app_shell_follow_up/visual-fidelity';

/// The three stars have 3400/4600/5200ms periods at 0/800/1600ms delays, so
/// they share no common peak; 2600ms is the instant all three sit well above
/// their 0.25 rest opacity.
const Duration _captureFrame = Duration(milliseconds: 2600);

/// 390x844 logical at devicePixelRatio 3, matching the committed AC4 captures.
const Size _logicalSize = Size(390, 844);
const double _pixelRatio = 3;

class _EmptyVibesRepository extends VibesRepository {
  _EmptyVibesRepository() : super(CupidApi(dio: Dio(), interceptors: const []));

  @override
  Future<VibeEntry?> fetchMyToday() async => null;

  @override
  Future<List<VibeEntry>> fetchMyHistory() async => const <VibeEntry>[];

  @override
  Future<List<VibeEntry>> fetchPartnerHistory() async => const <VibeEntry>[];
}

Future<void> _loadBundledFonts() async {
  const Map<String, String> families = <String, String>{
    'Nunito': 'assets/fonts/Nunito-Variable.ttf',
    'Roboto': 'assets/fonts/Roboto-Variable.ttf',
    'Roboto Mono': 'assets/fonts/RobotoMono-Variable.ttf',
    'Material Symbols Rounded':
        'assets/fonts/MaterialSymbolsRounded-Variable.ttf',
  };

  for (final MapEntry<String, String> family in families.entries) {
    final Uint8List bytes = await File(family.value).readAsBytes();
    await (FontLoader(family.key)
          ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes))))
        .load();
  }
}

void main() {
  setUpAll(_loadBundledFonts);

  testWidgets('capture: VibeScreen CupidHeader, dark + vi', (
    WidgetTester tester,
  ) async {
    tester.view
      ..devicePixelRatio = _pixelRatio
      ..physicalSize = _logicalSize * _pixelRatio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(
        key: _captureKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildCupidTheme(
            platform: CupidPlatform.material,
            brightness: Brightness.dark,
          ),
          locale: const Locale('vi'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          builder: (BuildContext context, Widget? child) =>
              CupidAppBackground(child: child!),
          home: VibeScreen(
            createCubit: () => VibeCubit(repository: _EmptyVibesRepository()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(_captureFrame);

    final RenderRepaintBoundary boundary = tester
        .renderObject<RenderRepaintBoundary>(find.byKey(_captureKey));

    // Rasterizing needs real async: the fake-async test zone never completes
    // the engine's toImage future.
    await tester.runAsync(() async {
      final ui.Image image = await boundary.toImage(pixelRatio: _pixelRatio);
      final ByteData png =
          (await image.toByteData(format: ui.ImageByteFormat.png))!;
      await File('$_outputDir/ac3-vibe-header-dark-vi.png')
          .writeAsBytes(png.buffer.asUint8List(), flush: true);
      debugPrint('captured ${image.width}x${image.height}');
    });
  });
}
