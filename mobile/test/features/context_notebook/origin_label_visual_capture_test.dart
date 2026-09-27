import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_dao.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_repository.dart';
import 'package:cupid_mobile/features/context_notebook/domain/checkin_capture_content.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_notebook_models.dart';
import 'package:cupid_mobile/features/context_notebook/presentation/screens/notebook_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// REQ-017 STORY-001 P4 rendered evidence for the notebook origin label.
///
/// Separate from `visual_capture_test.dart` on purpose: that file writes into
/// REQ-016 STORY-004's evidence directory, and a capture run must not rewrite
/// another story's PNGs. Same harness shape so the pair still compares against
/// the same 415x900 design render.
///
/// Off by default. Enable with:
/// `flutter test test/features/context_notebook/origin_label_visual_capture_test.dart \
///   --dart-define=CAPTURE_VISUALS=true`
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

const Size kIosReferenceViewport = Size(415, 900);

const String _outputDir =
    '../data/requirements/REQ-017_checkin_notebook_capture/'
    'STORY-001_checkin_notebook_capture/visual-fidelity';

final GlobalKey _captureBoundaryKey = GlobalKey();

final CheckinCaptureCopySet _shippedCopy = CheckinCaptureCopySet(
  ContentPackage.parse<CheckinCaptureCopy>(
    File(checkinCaptureAssetKey).readAsStringSync(),
    expectedSchemaId: checkinCaptureSchemaId,
    itemParser: checkinCaptureCopyFromJson,
    source: checkinCaptureAssetKey,
  ),
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

    // `Icons.more_horiz` ships with the framework, not under `assets/fonts/`.
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

/// [CupidPlatform.material] renders the same screen with the opaque header
/// band; the iOS band is a `BackdropFilter` with no backdrop to sample
/// offscreen, which washes the title out of the capture.
Future<void> _captureAtReferenceViewport(
  WidgetTester tester,
  Widget home,
  String fileName, {
  CupidPlatform platform = CupidPlatform.ios,
}) async {
  tester.view.physicalSize = kIosReferenceViewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await _loadDesignFonts(tester);
  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureBoundaryKey,
      child: MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        debugShowCheckedModeBanner: false,
        theme: buildCupidTheme(platform: platform, brightness: Brightness.dark),
        builder: (BuildContext context, Widget? child) => CupidAppBackground(
          enableEffectsOverride: false,
          child: child!,
        ),
        home: CupidPlatformOverride(platform: platform, child: home),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final RenderRepaintBoundary boundary =
      tester.renderObject(find.byKey(_captureBoundaryKey))
          as RenderRepaintBoundary;

  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 1);
    final ByteData? png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final File out = File('$_outputDir/$fileName');
    out.parent.createSync(recursive: true);
    out.writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  late CupidDatabase database;
  late ContextNotebookRepository repository;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    repository = ContextNotebookRepository(
      dao: ContextNotebookDao(database),
      ownerKeyStore: BackendUserIdStore()..updateUserId('user-1'),
    );
  });

  tearDown(() async {
    await database.close();
  });

  /// Both origin branches on one screen: the first interest row carries the
  /// card title, the second was written by a check-in whose card can no longer
  /// be read, and the rest are rows the user typed and must stay unlabelled.
  Future<void> seed() async {
    await repository.recordFromCheckIn(
      kind: NotebookKind.interest,
      value: 'Cà phê muối',
      originCheckInRef: 'checkin-2026-09-20',
      cardId: 'card-live',
      cardTitle: 'Đi cà phê tối',
    );
    await repository.recordFromCheckIn(
      kind: NotebookKind.interest,
      value: 'Phim kinh dị Hàn',
      originCheckInRef: 'checkin-2026-09-22',
      cardId: 'card-gone',
      cardTitle: 'Xem phim khuya',
    );
    await repository.addEntry(
      kind: NotebookKind.interest,
      value: 'Đi bộ ven hồ',
      source: ContextEntrySource.manual,
    );
    await repository.recordFromCheckIn(
      kind: NotebookKind.event,
      value: 'Kỷ niệm quen nhau',
      originCheckInRef: 'checkin-2026-09-24',
      cardId: 'card-live',
      cardTitle: 'Đi cà phê tối',
    );
    await repository.addEntry(
      kind: NotebookKind.event,
      value: 'Sinh nhật',
      detail: '15/05',
      source: ContextEntrySource.manual,
    );
  }

  Widget screen() => NotebookScreen(
    repository: repository,
    originCopy: _shippedCopy,
    cardProbe: (Set<String> ids) async =>
        ids.where((String id) => id != 'card-gone').toSet(),
  );

  testWidgets('captures 2-so-tay-nguoi-yeu with origin labels', (
    WidgetTester tester,
  ) async {
    await seed();

    await _captureAtReferenceViewport(
      tester,
      screen(),
      'implemented-2-so-tay-nguoi-yeu-origin-ios.png',
    );
    await _captureAtReferenceViewport(
      tester,
      screen(),
      'implemented-2-so-tay-nguoi-yeu-origin-md.png',
      platform: CupidPlatform.material,
    );
  }, skip: !kCaptureVisuals);
}
