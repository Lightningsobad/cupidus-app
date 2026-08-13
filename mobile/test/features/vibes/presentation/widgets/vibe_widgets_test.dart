import 'dart:typed_data' show ByteData;
import 'dart:ui' as ui;
import 'dart:ui' show Tristate;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/vibes/domain/vibe_mood.dart';
import 'package:cupid_mobile/features/vibes/presentation/vibe_strings.dart';
import 'package:cupid_mobile/features/vibes/presentation/widgets/partner_vibe_card.dart';
import 'package:cupid_mobile/features/vibes/presentation/widgets/vibe_history_strip.dart';
import 'package:cupid_mobile/features/vibes/presentation/widgets/vibe_mood_face.dart';
import 'package:cupid_mobile/features/vibes/presentation/widgets/vibe_mood_grid.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: locale,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('VibeMoodGrid', () {
    testWidgets('renders exactly the 5 frozen moods, no dropped soft cell', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          VibeMoodGrid(selected: null, enabled: true, onPick: (_) {}),
        ),
      );

      expect(find.byType(VibeMoodFace), findsNWidgets(5));
      for (final String label in <String>[
        'Happy',
        'Sad',
        'Angry',
        'Spicy',
        'Tired',
      ]) {
        expect(find.bySemanticsLabel(label), findsOneWidget);
      }
      expect(find.text('Soft'), findsNothing);
    });

    testWidgets('lays out 3 + 2 rows, the bottom row centered at 2/3 width', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          VibeMoodGrid(selected: null, enabled: true, onPick: (_) {}),
        ),
      );

      expect(find.byType(Row), findsNWidgets(2));
      final FractionallySizedBox bottomRow = tester.widget(
        find.byType(FractionallySizedBox),
      );
      expect(bottomRow.widthFactor, 2 / 3);
    });

    testWidgets('the selected mood reports selected semantics, others do not', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          _harness(
            VibeMoodGrid(selected: VibeMood.sad, enabled: true, onPick: (_) {}),
          ),
        );

        final SemanticsNode selectedData = tester.getSemantics(
          find.bySemanticsLabel('Sad'),
        );
        expect(
          selectedData.getSemanticsData().flagsCollection.isSelected,
          Tristate.isTrue,
        );
        expect(
          selectedData.getSemanticsData().flagsCollection.isButton,
          isTrue,
        );

        final SemanticsNode unselectedData = tester.getSemantics(
          find.bySemanticsLabel('Happy'),
        );
        expect(
          unselectedData.getSemanticsData().flagsCollection.isSelected,
          isNot(Tristate.isTrue),
        );
      } finally {
        handle.dispose();
      }
    });

    testWidgets('every cell meets the Material --tap minimum (48dp)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          VibeMoodGrid(selected: null, enabled: true, onPick: (_) {}),
        ),
      );

      for (final String label in <String>['Happy', 'Sad', 'Angry']) {
        final Size size = tester.getSize(find.bySemanticsLabel(label));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
    });

    testWidgets('enabled: false locks every cell against taps', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      try {
        int tapCount = 0;
        await tester.pumpWidget(
          _harness(
            VibeMoodGrid(
              selected: null,
              enabled: false,
              onPick: (_) => tapCount++,
            ),
          ),
        );

        await tester.tap(find.bySemanticsLabel('Happy'));
        await tester.pump();
        expect(tapCount, 0);

        final SemanticsNode data = tester.getSemantics(
          find.bySemanticsLabel('Happy'),
        );
        expect(
          data.getSemanticsData().flagsCollection.isEnabled,
          isNot(Tristate.none),
        );
        expect(
          data.getSemanticsData().flagsCollection.isEnabled,
          Tristate.isFalse,
        );
      } finally {
        handle.dispose();
      }
    });
  });

  group('PartnerVibeCard', () {
    testWidgets('renders the waiting state for a null mood', (tester) async {
      await tester.pumpWidget(_harness(const PartnerVibeCard(mood: null)));

      expect(find.text('Waiting…'), findsOneWidget);
      expect(find.text('Bae has not checked in yet. Nudge them.'), findsOneWidget);
      expect(find.text('Nudge'), findsOneWidget);
    });

    testWidgets('renders the sad/angry/tired nudge copy variants', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(const PartnerVibeCard(mood: VibeMood.sad)),
      );
      expect(find.text('Bae is down. Send a virtual hug?'), findsOneWidget);
      expect(find.text('Send hug'), findsOneWidget);

      await tester.pumpWidget(
        _harness(const PartnerVibeCard(mood: VibeMood.angry)),
      );
      expect(find.text('Bae is fuming. Milk tea might help.'), findsOneWidget);
      expect(find.text('Order tea'), findsOneWidget);

      await tester.pumpWidget(
        _harness(const PartnerVibeCard(mood: VibeMood.tired)),
      );
      expect(find.text('Bae is drained. Let them sleep in.'), findsOneWidget);
    });

    testWidgets('any other checked-in mood renders the generic acknowledgment', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(const PartnerVibeCard(mood: VibeMood.happy)),
      );
      expect(find.text('Good vibes. Send a sticker back.'), findsOneWidget);
      expect(find.text('Nudge'), findsOneWidget);
    });

    testWidgets('the decorative CTA pill carries no interactive semantics', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          _harness(const PartnerVibeCard(mood: VibeMood.sad)),
        );

        final SemanticsNode data = tester.getSemantics(find.text('Send hug'));
        expect(data.getSemanticsData().flagsCollection.isButton, isFalse);
        expect(
          data.getSemanticsData().hasAction(SemanticsAction.tap),
          isFalse,
        );
      } finally {
        handle.dispose();
      }
    });
  });

  group('VibeHistoryStrip', () {
    testWidgets('renders 7 columns and the none face for a missing day', (
      tester,
    ) async {
      final List<VibeMood?> mine = <VibeMood?>[
        VibeMood.happy,
        null,
        VibeMood.sad,
        VibeMood.angry,
        VibeMood.tired,
        VibeMood.horny,
        VibeMood.happy,
      ];
      final List<VibeMood?> partner = <VibeMood?>[
        null,
        null,
        VibeMood.happy,
        VibeMood.sad,
        VibeMood.tired,
        null,
        VibeMood.angry,
      ];

      await tester.pumpWidget(
        _harness(VibeHistoryStrip(mine: mine, partner: partner)),
      );

      expect(find.byType(VibeMoodFace), findsNWidgets(14));
      final List<VibeMoodFace> faces = tester
          .widgetList<VibeMoodFace>(find.byType(VibeMoodFace))
          .toList();
      expect(faces[0].mood, VibeMood.happy);
      expect(faces[1].mood, null);
      // `text-transform:uppercase` in the design source; `historyHeader`
      // itself still returns the UX §6 A-2 sentence-case copy.
      expect(find.text('LAST 7 DAYS'), findsOneWidget);
    });
  });

  group('STORY-020 design fidelity', () {
    const CupidColorTokens dark = CupidColorTokens.dark();

    Finder cellsOf(Type widget) => find.descendant(
      of: find.byType(widget),
      matching: find.byType(Container),
    );

    testWidgets(
      'the selected mood cell fills with the 140deg translucent pink/purple '
      'gradient, not the opaque dream gradient',
      (tester) async {
        await tester.pumpWidget(
          _harness(
            VibeMoodGrid(
              selected: VibeMood.happy,
              enabled: true,
              onPick: (_) {},
            ),
          ),
        );

        final List<Container> cells = tester
            .widgetList<Container>(cellsOf(VibeMoodGrid))
            .toList();
        expect(cells, hasLength(5));

        final BoxDecoration selected =
            cells.first.decoration! as BoxDecoration;
        final LinearGradient gradient = selected.gradient! as LinearGradient;
        expect(gradient, isNot(dark.gradientDream));
        expect(gradient.colors, hasLength(2));
        expect(gradient.colors.first.a, closeTo(0.3, 0.001));
        expect(gradient.colors.last.a, closeTo(0.26, 0.001));

        expect(selected.border, isNotNull);
        expect(cells[1].decoration, isA<BoxDecoration>());
        expect((cells[1].decoration! as BoxDecoration).gradient, isNull);
      },
    );

    testWidgets('selecting a cell does not resize it', (tester) async {
      await tester.pumpWidget(
        _harness(
          VibeMoodGrid(selected: VibeMood.happy, enabled: true, onPick: (_) {}),
        ),
      );

      final Finder cells = cellsOf(VibeMoodGrid);
      expect(
        tester.getSize(cells.at(0)).height,
        tester.getSize(cells.at(1)).height,
      );
      expect(
        (tester.widget<Container>(cells.at(1)).decoration! as BoxDecoration)
            .border,
        isNotNull,
      );
    });

    testWidgets(
      'the nudge banner is an amber tint with the tips_and_updates glyph and '
      'a gradient CTA pill',
      (tester) async {
        await tester.pumpWidget(
          _harness(const PartnerVibeCard(mood: VibeMood.sad)),
        );

        final List<Container> parts = tester
            .widgetList<Container>(cellsOf(PartnerVibeCard))
            .toList();
        expect(parts, hasLength(4));

        final BoxDecoration banner = parts[2].decoration! as BoxDecoration;
        expect(banner.color, dark.colorAmber.withValues(alpha: 0.14));

        final CupidIcon icon = tester.widget<CupidIcon>(
          find.byType(CupidIcon),
        );
        expect(icon.color, dark.colorButter);

        final BoxDecoration cta = parts[3].decoration! as BoxDecoration;
        expect(cta.gradient, dark.gradientHot);
      },
    );
  });

  group('VibeMoodFace artwork (STORY-020 F-1)', () {
    ui.Picture record(MoodFaceArt art) {
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      MoodFacePainter(art).paint(Canvas(recorder), const Size.square(100));
      return recorder.endRecording();
    }

    /// Rasterizes one face at the design source's 100x100 viewBox so a test
    /// can prove real geometry landed on the canvas. `toImage` needs the real
    /// event loop, not `testWidgets`' fake-async zone, hence `runAsync`.
    Future<ByteData> rasterize(WidgetTester tester, MoodFaceArt art) async {
      final ByteData? rgba = await tester.runAsync<ByteData>(() async {
        final ui.Image image = await record(art).toImage(100, 100);
        return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      });
      return rgba!;
    }

    ({int r, int g, int b, int a}) pixelAt(ByteData rgba, int x, int y) {
      final int i = (y * 100 + x) * 4;
      return (
        r: rgba.getUint8(i),
        g: rgba.getUint8(i + 1),
        b: rgba.getUint8(i + 2),
        a: rgba.getUint8(i + 3),
      );
    }

    test('every VibeMood maps to its design-source face, horny to spicy', () {
      expect(MoodFaceArt.forMood(VibeMood.happy), MoodFaceArt.happy);
      expect(MoodFaceArt.forMood(VibeMood.sad), MoodFaceArt.sad);
      expect(MoodFaceArt.forMood(VibeMood.angry), MoodFaceArt.angry);
      expect(MoodFaceArt.forMood(VibeMood.tired), MoodFaceArt.tired);
      expect(MoodFaceArt.forMood(VibeMood.horny), MoodFaceArt.spicy);
      expect(MoodFaceArt.forMood(null), MoodFaceArt.none);
    });

    testWidgets('all 7 design-source faces paint, including soft', (
      tester,
    ) async {
      expect(MoodFaceArt.values, hasLength(7));
      for (final MoodFaceArt art in MoodFaceArt.values) {
        await rasterize(tester, art);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('the drawn faces replaced the emoji glyphs entirely', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(const VibeMoodFace(mood: VibeMood.happy, size: 52)),
      );

      expect(
        find.descendant(
          of: find.byType(VibeMoodFace),
          matching: find.byType(Text),
        ),
        findsNothing,
      );
      final CustomPaint paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(VibeMoodFace),
          matching: find.byType(CustomPaint),
        ),
      );
      expect(paint.painter, isA<MoodFacePainter>());
      expect((paint.painter! as MoodFacePainter).art, MoodFaceArt.happy);
    });

    testWidgets('happy paints an opaque warm disc, none paints an open ring', (
      tester,
    ) async {
      // Mid-disc, between the brows and above the mouth: the happy face's
      // `mfA` gradient runs #FFE9A8 -> #FFC46B, so red > green > blue at
      // every point along it.
      final ({int r, int g, int b, int a}) happy = pixelAt(
        await rasterize(tester, MoodFaceArt.happy),
        50,
        50,
      );
      expect(happy.a, 255);
      expect(happy.r, greaterThan(happy.g));
      expect(happy.g, greaterThan(happy.b));

      // The `none` face is a dashed outline with no fill, so the same point
      // must stay empty.
      expect(pixelAt(await rasterize(tester, MoodFaceArt.none), 50, 50).a, 0);
    });
  });

  group('VibeLocaleText nudge copy (unit)', () {
    testWidgets('resolves vi/en variants for each mood bucket', (
      tester,
    ) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        _harness(
          Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(ctx.nudgeMessage(VibeMood.sad), 'Bae is down. Send a virtual hug?');
      expect(ctx.nudgeMessage(VibeMood.angry), 'Bae is fuming. Milk tea might help.');
      expect(ctx.nudgeMessage(VibeMood.tired), 'Bae is drained. Let them sleep in.');
      expect(ctx.nudgeMessage(null), 'Bae has not checked in yet. Nudge them.');
      expect(ctx.nudgeMessage(VibeMood.happy), 'Good vibes. Send a sticker back.');

      await tester.pumpWidget(
        _harness(
          Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
          locale: const Locale('vi'),
        ),
      );

      expect(ctx.nudgeMessage(VibeMood.sad), 'Bae đang tủi. Gửi một cái ôm ảo nha?');
      expect(ctx.historyHeader, '7 ngày gần nhất');
    });
  });
}
