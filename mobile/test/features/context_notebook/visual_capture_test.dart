import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_dao.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_repository.dart';
import 'package:cupid_mobile/features/context_notebook/domain/ask_cadence_policy.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_notebook_models.dart';
import 'package:cupid_mobile/features/context_notebook/presentation/screens/notebook_screen.dart';
import 'package:cupid_mobile/features/context_notebook/presentation/screens/skill_profile_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// STORY-004 P4 rendered-evidence capture for the two screens this phase adds.
///
/// Both are pushed from the Me tab and hold only locally written rows, so a
/// device run would have to be driven through several taps to reach a
/// non-empty state. Rendering them here instead pins them to the exact
/// viewport `design-reference-*-ios.png` was rendered at (415x900), so the
/// pair compares without rescaling either image.
///
/// Off by default so the ordinary scoped suite stays hermetic. Enable with:
/// `flutter test test/features/context_notebook/visual_capture_test.dart \
///   --dart-define=CAPTURE_VISUALS=true`
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

/// iOS reference viewport, matching the `--platform=ios` render of the design
/// canvas that produced both `design-reference-*-ios.png` files.
const Size kIosReferenceViewport = Size(415, 900);

const String _outputDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-004_relationship_notebook_and_gift_ideas/visual-fidelity';

final GlobalKey _captureBoundaryKey = GlobalKey();

/// Widget tests ship no asset bundle, so both the bundled variable fonts and
/// the shipped content packs are read straight off disk. Without the fonts
/// every glyph rasterizes as a fallback box and the capture proves nothing
/// about typography; without the real packs the seed chips would show test
/// copy rather than what the user sees.
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final File file = File(key);
    if (!file.existsSync()) {
      throw FlutterError('no shipped asset at "$key"');
    }
    return ByteData.sublistView(file.readAsBytesSync());
  }
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

    // `Icons.more_horiz` ships with the framework rather than with this app
    // (`uses-material-design: true`), so it is not under `assets/fonts/`.
    // Without it the row menu glyph rasterizes as a notdef box and the
    // capture cannot be read as evidence.
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

/// `CupidHeader`'s iOS band is a `BackdropFilter`, and an offscreen
/// `RenderRepaintBoundary.toImage()` has no backdrop to sample, so the title
/// washes out of every `CupidPlatform.ios` capture. Passing
/// [CupidPlatform.material] re-renders the same screen with the opaque
/// Material band, which is how the title band is evidenced.
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
        theme: buildCupidTheme(
          platform: platform,
          brightness: Brightness.dark,
        ),
        // The dark sky wash is mounted once at the composition root, not by
        // each screen, so a screen captured without it renders on the bare
        // scaffold fill and reads as a light-mode regression that is not one.
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

  testWidgets('captures 2-so-tay-nguoi-yeu', (WidgetTester tester) async {
    for (final List<String> row in <List<String>>[
      <String>['Cà phê sữa đá', 'Không đường, uống buổi sáng'],
      <String>['Đi bộ ven hồ', ''],
      <String>['Phim kinh dị Hàn', ''],
    ]) {
      await repository.addEntry(
        kind: NotebookKind.interest,
        value: row[0],
        detail: row[1].isEmpty ? null : row[1],
        source: ContextEntrySource.manual,
      );
    }
    for (final List<String> row in <List<String>>[
      <String>['Sinh nhật', '15/05'],
      <String>['Ngày quen nhau', '02/09'],
    ]) {
      await repository.addEntry(
        kind: NotebookKind.event,
        value: row[0],
        detail: row[1],
        source: ContextEntrySource.manual,
      );
    }

    await _captureAtReferenceViewport(
      tester,
      NotebookScreen(repository: repository),
      'implemented-2-so-tay-nguoi-yeu-ios.png',
    );
    await _captureAtReferenceViewport(
      tester,
      NotebookScreen(repository: repository),
      'implemented-2-so-tay-nguoi-yeu-md.png',
      platform: CupidPlatform.material,
    );
  }, skip: !kCaptureVisuals);

  testWidgets('captures 2-so-tay-nguoi-yeu empty', (WidgetTester tester) async {
    await _captureAtReferenceViewport(
      tester,
      NotebookScreen(repository: repository),
      'implemented-2-so-tay-nguoi-yeu-ios-empty.png',
    );
  }, skip: !kCaptureVisuals);

  testWidgets('captures 3-ho-so-ky-nang-phien-ban-toi', (
    WidgetTester tester,
  ) async {
    for (final String label in <String>[
      'Nhớ dai',
      'Gói quà đẹp',
      'Chọn nhạc hợp cảnh',
      'Nấu bữa sáng',
    ]) {
      await repository.addSkill(
        label: label,
        source: ContextEntrySource.manual,
      );
    }

    await _captureAtReferenceViewport(
      tester,
      SkillProfileScreen(
        repository: repository,
        contentLoader: ContentPackageLoader(bundle: _DiskBundle()),
        sessionSkips: AskSessionSkips(),
      ),
      'implemented-3-ho-so-ky-nang-phien-ban-toi-ios.png',
    );
    await _captureAtReferenceViewport(
      tester,
      SkillProfileScreen(
        repository: repository,
        contentLoader: ContentPackageLoader(bundle: _DiskBundle()),
        sessionSkips: AskSessionSkips(),
      ),
      'implemented-3-ho-so-ky-nang-phien-ban-toi-md.png',
      platform: CupidPlatform.material,
    );
  }, skip: !kCaptureVisuals);

  testWidgets('captures 3-ho-so-ky-nang-phien-ban-toi empty', (
    WidgetTester tester,
  ) async {
    await _captureAtReferenceViewport(
      tester,
      SkillProfileScreen(
        repository: repository,
        contentLoader: ContentPackageLoader(bundle: _DiskBundle()),
        sessionSkips: AskSessionSkips(),
      ),
      'implemented-3-ho-so-ky-nang-phien-ban-toi-ios-empty.png',
    );
  }, skip: !kCaptureVisuals);
}
