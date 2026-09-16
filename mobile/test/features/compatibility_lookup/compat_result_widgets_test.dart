import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/compatibility_lookup/domain/compat_content.dart';
import 'package:cupid_mobile/features/compatibility_lookup/presentation/widgets/compat_activity_block.dart';
import 'package:cupid_mobile/features/compatibility_lookup/presentation/widgets/compat_band_chip.dart';
import 'package:cupid_mobile/features/compatibility_lookup/presentation/widgets/compat_facet_block.dart';
import 'package:cupid_mobile/features/compatibility_lookup/presentation/widgets/compat_question_block.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Off by default so the ordinary scoped suite stays hermetic. Enable with:
/// `flutter test test/features/compatibility_lookup/compat_result_widgets_test.dart \
///   --dart-define=CAPTURE_VISUALS=true`
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

const Size _kReferenceViewport = Size(415, 1100);

const String _outputDir = 'build/visual-fidelity/STORY-010';

final GlobalKey _captureBoundaryKey = GlobalKey();

const CompatBand _band = CompatBand(
  id: 'band.easy_going',
  label: 'Dễ đi cùng nhau',
  rawJson: <String, Object?>{},
);

const CompatCell _cell = CompatCell(
  id: 'cell.leo__cancer',
  rawJson: <String, Object?>{},
  selfId: 'leo',
  partnerId: 'cancer',
  bandId: 'band.easy_going',
  fit: 'Bạn thích rủ rê, người ấy thích được rủ — kế hoạch cuối tuần thường '
      'trôi rất êm.',
  friction: 'Bạn quyết nhanh, người ấy cần thời gian ngẫm — lúc gấp dễ thành '
      'ra giục nhau.',
  activity: 'Thử để người ấy chọn quán, còn bạn chọn giờ.',
  question: 'Lần gần nhất mình quyết vội, bạn thấy thế nào?',
);

Widget _host(Widget child, {CupidPlatform platform = CupidPlatform.ios}) {
  return MaterialApp(
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    debugShowCheckedModeBanner: false,
    theme: buildCupidTheme(platform: platform, brightness: Brightness.dark),
    home: CupidPlatformOverride(
      platform: platform,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(CupidSpacing.md),
          child: child,
        ),
      ),
    ),
  );
}

/// The four blocks in the order `ux/uiux-spec.md` section 3 fixes: band chip,
/// fit, friction immediately after fit, activity, question last (AC-19).
Widget _resultBlock({VoidCallback? onAddToMyStore}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      const CompatBandChip(band: _band),
      const SizedBox(height: CupidSpacing.md),
      CompatFacetBlock(kind: CompatFacetKind.fit, text: _cell.fit),
      const SizedBox(height: CupidSpacing.md),
      CompatFacetBlock(kind: CompatFacetKind.friction, text: _cell.friction),
      const SizedBox(height: CupidSpacing.md),
      CompatActivityBlock(cell: _cell, onAddToMyStore: onAddToMyStore),
      const SizedBox(height: CupidSpacing.md),
      const CompatQuestionBlock(cell: _cell),
    ],
  );
}

typedef _FacetGeometry = ({
  Size size,
  BoxDecoration decoration,
  EdgeInsetsGeometry padding,
  TextStyle titleStyle,
  String titleText,
  TextStyle bodyStyle,
  double iconSize,
  IconData icon,
  List<double> gaps,
});

_FacetGeometry _facetGeometry(WidgetTester tester, CompatFacetKind kind) {
  final Finder block = find.byKey(Key('compat_facet_block_${kind.name}'));
  final Finder texts = find.descendant(of: block, matching: find.byType(Text));
  final Icon icon = tester.widget<Icon>(
    find.descendant(of: block, matching: find.byType(Icon)).first,
  );

  return (
    size: tester.getSize(block),
    decoration:
        tester.widget<DecoratedBox>(block).decoration as BoxDecoration,
    padding: tester
        .widget<Padding>(
          find.descendant(of: block, matching: find.byType(Padding)).first,
        )
        .padding,
    titleStyle: tester.widget<Text>(texts.at(0)).style!,
    titleText: tester.widget<Text>(texts.at(0)).data!,
    bodyStyle: tester.widget<Text>(texts.at(1)).style!,
    iconSize: icon.size!,
    icon: icon.icon!,
    gaps: tester
        .widgetList<SizedBox>(
          find.descendant(of: block, matching: find.byType(SizedBox)),
        )
        .map((SizedBox box) => box.width ?? box.height ?? 0)
        .toList(),
  );
}

/// Widget tests ship no asset bundle, so the bundled variable fonts are read
/// straight off disk. Without them every glyph rasterizes as a fallback box and
/// the capture proves nothing about typography or Vietnamese diacritics.
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

    // The framework's own icon font ships outside `assets/fonts/`; the
    // `Scaffold`/`MaterialApp` chrome reaches for it and a missing family
    // renders notdef boxes into the evidence image.
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

/// The four blocks stacked at the reference width run past the default 800x600
/// frame, which would push the activity button offscreen and make its `tap()`
/// miss. The frame grows; the product layout does not shrink to fit it.
void _useReferenceViewport(WidgetTester tester) {
  tester.view.physicalSize = _kReferenceViewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('fit and friction blocks are geometrically identical', (
    WidgetTester tester,
  ) async {
    _useReferenceViewport(tester);
    await tester.pumpWidget(_host(_resultBlock()));
    await tester.pumpAndSettle();

    final _FacetGeometry fit = _facetGeometry(tester, CompatFacetKind.fit);
    final _FacetGeometry friction = _facetGeometry(
      tester,
      CompatFacetKind.friction,
    );

    // The rule the phase exists for: cover the titles and the two blocks must
    // be indistinguishable (`ux/uiux-spec.md` section 3.3, AC-33).
    expect(friction.size.width, fit.size.width);
    expect(friction.padding, fit.padding);
    expect(friction.decoration.color, fit.decoration.color);
    expect(friction.decoration.borderRadius, fit.decoration.borderRadius);
    expect(friction.decoration.border, fit.decoration.border);
    expect(friction.decoration.gradient, isNull);
    expect(fit.decoration.gradient, isNull);
    expect(friction.titleStyle.fontSize, fit.titleStyle.fontSize);
    expect(friction.titleStyle.fontWeight, fit.titleStyle.fontWeight);
    expect(friction.titleStyle.color, fit.titleStyle.color);
    expect(friction.bodyStyle.fontSize, fit.bodyStyle.fontSize);
    expect(friction.bodyStyle.fontWeight, fit.bodyStyle.fontWeight);
    expect(friction.bodyStyle.color, fit.bodyStyle.color);
    expect(friction.iconSize, fit.iconSize);
    expect(friction.gaps, fit.gaps);

    // Guards against the comparison passing because both sides collapsed into
    // the same nothing: the two blocks really are two different renders.
    expect(friction.titleText, isNot(fit.titleText));
    expect(friction.icon, isNot(fit.icon));

    // The friction block sits immediately after the fit block, not at the
    // bottom of the screen.
    expect(
      tester.getTopLeft(find.byKey(const Key('compat_facet_block_friction'))).dy,
      greaterThan(
        tester.getTopLeft(find.byKey(const Key('compat_facet_block_fit'))).dy,
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('compat_activity_block'))).dy,
      greaterThan(
        tester
            .getTopLeft(find.byKey(const Key('compat_facet_block_friction')))
            .dy,
      ),
    );
  });

  testWidgets('friction block is never hidden behind a disclosure', (
    WidgetTester tester,
  ) async {
    _useReferenceViewport(tester);
    await tester.pumpWidget(_host(_resultBlock()));
    await tester.pumpAndSettle();

    expect(find.byType(ExpansionTile), findsNothing);
    expect(find.byType(ExpansionPanelList), findsNothing);
    expect(find.text(_cell.friction), findsOneWidget);
  });

  testWidgets('result block carries no scale, meter or score', (
    WidgetTester tester,
  ) async {
    _useReferenceViewport(tester);
    await tester.pumpWidget(_host(_resultBlock()));
    await tester.pumpAndSettle();

    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(Slider), findsNothing);

    // AC-31: the question is read, never answered here.
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(TextFormField), findsNothing);

    final RegExp scaleWording = RegExp(r'%|/10|\bđiểm\b|\bthang\b');
    for (final Text text in tester.widgetList<Text>(find.byType(Text))) {
      final String? data = text.data;
      if (data == null) {
        continue;
      }
      expect(
        scaleWording.hasMatch(data),
        isFalse,
        reason: 'scale wording leaked into the result block: "$data"',
      );
    }

    // The band renders its label and nothing that reads as a position on an
    // axis (AC-32).
    expect(find.text(_band.label), findsOneWidget);
    expect(
      (tester
                  .widget<DecoratedBox>(find.byKey(const Key('compat_band_chip')))
                  .decoration
              as BoxDecoration)
          .gradient,
      isNull,
    );
  });

  testWidgets('tapping the activity action signals the caller exactly once', (
    WidgetTester tester,
  ) async {
    _useReferenceViewport(tester);
    int calls = 0;
    await tester.pumpWidget(_host(_resultBlock(onAddToMyStore: () => calls++)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('compat_activity_add_to_store')));
    await tester.pumpAndSettle();

    expect(calls, 1);
  });

  testWidgets(
    'captures the result block',
    (WidgetTester tester) async {
      _useReferenceViewport(tester);
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
            // The dark sky wash is mounted at the composition root, not by
            // each screen; without it the capture renders on the bare scaffold
            // fill and reads as a light-mode regression that is not one.
            builder: (BuildContext context, Widget? child) =>
                CupidAppBackground(
                  enableEffectsOverride: false,
                  child: child!,
                ),
            home: CupidPlatformOverride(
              platform: CupidPlatform.material,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(CupidSpacing.md),
                  child: _resultBlock(onAddToMyStore: () {}),
                ),
              ),
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
        final ByteData? png = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        image.dispose();
        final File out = File('$_outputDir/compat-result-block-material.png');
        out.parent.createSync(recursive: true);
        out.writeAsBytesSync(png!.buffer.asUint8List());
      });
    },
    skip: !kCaptureVisuals,
  );
}
