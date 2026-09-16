import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/database/daos/activity_card_dao.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/data/activity_card_repository_impl.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/compatibility_lookup/compatibility_lookup_entry_point.dart';
import 'package:cupid_mobile/features/compatibility_lookup/data/relationship_label_repository.dart';
import 'package:cupid_mobile/features/compatibility_lookup/domain/compat_content.dart';
import 'package:cupid_mobile/features/compatibility_lookup/presentation/cubit/compatibility_lookup_cubit.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_dao.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_repository.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_notebook_models.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The shipped packs, read off disk: the assertions below are about the cells
/// an author actually shipped, not about fixture copy that could drift away
/// from them.
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final File file = File(key);
    if (!file.existsSync()) {
      throw FlutterError('no shipped asset at "$key"');
    }
    return ByteData.sublistView(file.readAsBytesSync());
  }

  /// Decoded in-process. Above 50 KB the inherited `loadString` hands the
  /// decode to `compute()`, and an isolate never finishes inside the fake async
  /// zone of a widget test, so the screen would sit in its loading state.
  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      utf8.decode((await load(key)).buffer.asUint8List());
}

/// Tall enough that every capture card and every result block is mounted at
/// once. The screen is a `ListView`, so in a short frame an absence assertion
/// could pass by never having built the widget it is looking for.
const Size _tallViewport = Size(415, 4000);

/// Rendered evidence for the story-level visual-fidelity package, off unless
/// `--dart-define=CAPTURE_VISUALS=true` so the ordinary suite stays hermetic.
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

const String _visualOutputDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-010_compatibility_lookup/visual-fidelity';

/// Reference width of the Stage-1 iOS renders, tall enough that the whole
/// screen fits in one unclipped frame.
const Size _captureViewport = Size(415, 1900);

final GlobalKey _captureBoundaryKey = GlobalKey();

Widget _host(Widget child) => MaterialApp(
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

    // The back chevron and the switch thumb ship with the framework rather
    // than under `assets/fonts/`, so without this the capture shows notdef
    // boxes and proves nothing.
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

/// Captured on the Material platform, not iOS: `CupidHeader`'s iOS band is a
/// `BackdropFilter`, and an offscreen `RenderRepaintBoundary.toImage()` has no
/// backdrop to sample, so the title washes out of every iOS capture.
Future<void> _captureScreen(
  WidgetTester tester,
  Widget home,
  String fileName,
) async {
  tester.view.physicalSize = _captureViewport;
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
          platform: CupidPlatform.material,
          brightness: Brightness.dark,
        ),
        builder: (BuildContext context, Widget? child) => CupidAppBackground(
          enableEffectsOverride: false,
          child: child!,
        ),
        home: CupidPlatformOverride(
          platform: CupidPlatform.material,
          child: home,
        ),
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
    final File out = File('$_visualOutputDir/$fileName');
    out.parent.createSync(recursive: true);
    out.writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  late CupidDatabase database;
  late RelationshipLabelRepository labels;
  late ActivityCardRepository cards;
  late ContextNotebookRepository notebook;
  late ContentPackageLoader diskLoader;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    final BackendUserIdStore owner = BackendUserIdStore()
      ..updateUserId('user-1');
    labels = RelationshipLabelRepository(
      dao: database.relationshipLabelsDao,
      ownerKeyStore: owner,
    );
    cards = ActivityCardRepositoryImpl(
      dao: ActivityCardDao(database),
      ownerKeyStore: owner,
    );
    notebook = ContextNotebookRepository(
      dao: ContextNotebookDao(database),
      ownerKeyStore: owner,
    );
    diskLoader = ContentPackageLoader(bundle: _DiskBundle());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = _tallViewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _host(
        CompatibilityLookupScreen(
          from: CompatibilityEntry.giftIdeas,
          createCubit: () => CompatibilityLookupCubit(
            labels: labels,
            cards: cards,
            loader: diskLoader,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapChip(
    WidgetTester tester,
    String slot,
    String valueId,
  ) async {
    final Finder chip = find.byKey(Key('compat_label_chip_${slot}_$valueId'));
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();
  }

  /// The shipped cell for an ordered pair, so the expectations below quote the
  /// pack rather than a copy of it.
  Future<CompatCell> shippedCell(String selfId, String partnerId) async {
    final ContentPackage<CompatItem> pack = await diskLoader.load<CompatItem>(
      compatZodiacAssetKey,
      expectedSchemaId: compatZodiacSchemaId,
      itemParser: compatItemFromJson,
    );
    return lookupCell(pack, selfId: selfId, partnerId: partnerId)!;
  }

  group('tra cứu theo cặp nhãn có thứ tự (AC-11, BR-2)', () {
    testWidgets('picking both sides of one system shows that system\'s cell',
        (WidgetTester tester) async {
      await pumpScreen(tester);

      // Nothing to read before both sides are declared, and no result is
      // guessed from a half-filled pair.
      expect(find.byKey(const Key('compat_empty_state')), findsOneWidget);
      expect(find.byKey(const Key('compat_result_zodiac')), findsNothing);

      await tapChip(tester, 'zodiac_self', 'aries');
      expect(
        find.byKey(const Key('compat_result_zodiac')),
        findsNothing,
        reason: 'one side alone is not a pair',
      );

      await tapChip(tester, 'zodiac_partner', 'taurus');

      final CompatCell cell = await shippedCell('aries', 'taurus');
      expect(find.byKey(const Key('compat_result_zodiac')), findsOneWidget);
      expect(find.text(cell.fit), findsOneWidget);
      expect(find.text(cell.friction), findsOneWidget);
      expect(find.text(cell.activity), findsOneWidget);
      expect(find.text(cell.question), findsOneWidget);
      expect(find.byKey(const Key('compat_empty_state')), findsNothing);

      // The other system stays incomplete without blocking this result.
      expect(find.byKey(const Key('compat_result_mbti')), findsNothing);
    });

    testWidgets('swapping the two sides reads a different cell, not the same one',
        (WidgetTester tester) async {
      await pumpScreen(tester);

      await tapChip(tester, 'zodiac_self', 'aries');
      await tapChip(tester, 'zodiac_partner', 'taurus');
      final CompatCell forward = await shippedCell('aries', 'taurus');
      expect(find.text(forward.fit), findsOneWidget);

      // Re-declaring both sides the other way round. The pair is ordered, so
      // this is a different row of the table and not the same row read
      // backwards (BR-2).
      await tapChip(tester, 'zodiac_self', 'taurus');
      await tapChip(tester, 'zodiac_partner', 'aries');

      final CompatCell reversed = await shippedCell('taurus', 'aries');
      expect(reversed.id, isNot(forward.id));
      expect(find.text(reversed.fit), findsOneWidget);
      expect(find.text(forward.fit), findsNothing);
    });

    testWidgets('withdrawing a label takes its result with it (AC-9)',
        (WidgetTester tester) async {
      await pumpScreen(tester);

      await tapChip(tester, 'zodiac_self', 'aries');
      await tapChip(tester, 'zodiac_partner', 'taurus');
      expect(find.byKey(const Key('compat_result_zodiac')), findsOneWidget);

      final Finder clear =
          find.byKey(const Key('compat_label_clear_zodiac_partner'));
      await tester.ensureVisible(clear);
      await tester.pumpAndSettle();
      await tester.tap(clear);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('compat_result_zodiac')), findsNothing);
      expect(await labels.label(
        subject: LabelSubject.partner,
        system: LabelSystem.zodiac,
      ), isNull);
    });
  });

  group('đẩy thẻ sang kho hoạt động (SC-2)', () {
    testWidgets('the activity action creates exactly one card, with the new origin',
        (WidgetTester tester) async {
      await pumpScreen(tester);
      await tapChip(tester, 'zodiac_self', 'aries');
      await tapChip(tester, 'zodiac_partner', 'taurus');

      final Finder addToStore = find.descendant(
        of: find.byKey(const Key('compat_result_zodiac')),
        matching: find.byKey(const Key('compat_activity_add_to_store')),
      );
      await tester.ensureVisible(addToStore);
      await tester.pumpAndSettle();
      await tester.tap(addToStore);
      await tester.pumpAndSettle();

      final List<ActivityCard> created =
          await cards.cardsByStatus(status: ActivityCardStatus.idea, limit: 50);
      final CompatCell cell = await shippedCell('aries', 'taurus');
      expect(created, hasLength(1));
      expect(created.single.origin, ActivityCardOrigin.compatibilityLookup);
      expect(created.single.title, cell.activity);

      // Created immediately and announced afterwards; the screen stays open.
      expect(
        find.byKey(const Key('compat_card_created_snackbar')),
        findsOneWidget,
      );
      expect(find.byType(CompatibilityLookupScreen), findsOneWidget);
    });
  });

  group('màn (10) không ghi vào sổ tay (BR-10, AC-31)', () {
    testWidgets('declaring labels and pushing a card leaves the notebook empty',
        (WidgetTester tester) async {
      await pumpScreen(tester);
      await tapChip(tester, 'zodiac_self', 'aries');
      await tapChip(tester, 'zodiac_partner', 'taurus');
      await tapChip(tester, 'mbti_self', 'intj');

      final Finder addToStore = find.descendant(
        of: find.byKey(const Key('compat_result_zodiac')),
        matching: find.byKey(const Key('compat_activity_add_to_store')),
      );
      await tester.ensureVisible(addToStore);
      await tester.pumpAndSettle();
      await tester.tap(addToStore);
      await tester.pumpAndSettle();

      // The labels live in this story's own table; the notebook that STORY-004
      // owns must not have grown a row.
      expect(await labels.labels(), hasLength(3));
      for (final NotebookKind kind in NotebookKind.values) {
        expect(await notebook.entries(kind: kind), isEmpty);
      }
      expect(await notebook.entries(), isEmpty);
      expect(await notebook.skills(), isEmpty);
    });
  });

  group('bằng chứng visual-fidelity', () {
    testWidgets('captures 10-bang-tra-an-khop', (WidgetTester tester) async {
      // One complete axis and one half-declared axis in the same frame, with a
      // guessed partner label, so the capture carries the states the spec makes
      // rules about (result block order, guess marking, clear action).
      await labels.saveLabel(
        subject: LabelSubject.self,
        system: LabelSystem.zodiac,
        value: 'aries',
        certainty: LabelCertainty.known,
      );
      await labels.saveLabel(
        subject: LabelSubject.partner,
        system: LabelSystem.zodiac,
        value: 'taurus',
        certainty: LabelCertainty.guess,
      );
      await labels.saveLabel(
        subject: LabelSubject.self,
        system: LabelSystem.mbti,
        value: 'intj',
        certainty: LabelCertainty.known,
      );

      await _captureScreen(
        tester,
        CompatibilityLookupScreen(
          from: CompatibilityEntry.giftIdeas,
          createCubit: () => CompatibilityLookupCubit(
            labels: labels,
            cards: cards,
            loader: diskLoader,
          ),
        ),
        '10-bang-tra-an-khop.png',
      );

      expect(
        File('$_visualOutputDir/10-bang-tra-an-khop.png').existsSync(),
        isTrue,
      );
    }, skip: !kCaptureVisuals);

    testWidgets('captures the no-label state', (WidgetTester tester) async {
      // Nothing declared yet: the evidence AC-6 needs is a frame where no
      // value is preselected on any card, least of all the other person's.
      await _captureScreen(
        tester,
        CompatibilityLookupScreen(
          from: CompatibilityEntry.giftIdeas,
          createCubit: () => CompatibilityLookupCubit(
            labels: labels,
            cards: cards,
            loader: diskLoader,
          ),
        ),
        '10-bang-tra-an-khop-chua-co-nhan.png',
      );

      expect(
        File('$_visualOutputDir/10-bang-tra-an-khop-chua-co-nhan.png')
            .existsSync(),
        isTrue,
      );
    }, skip: !kCaptureVisuals);
  });
}
