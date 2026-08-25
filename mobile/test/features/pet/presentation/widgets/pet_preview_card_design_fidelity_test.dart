import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pet/data/pet_models.dart';
import 'package:cupid_mobile/features/pet/data/pet_mood.dart';
import 'package:cupid_mobile/features/pet/data/pet_repository.dart';
import 'package:cupid_mobile/features/pet/presentation/pet_screen.dart';
import 'package:cupid_mobile/features/pet/presentation/pet_strings.dart';
import 'package:cupid_mobile/features/pet/presentation/widgets/bun_sprite.dart';
import 'package:cupid_mobile/features/pet/presentation/widgets/pet_preview_card.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fake_pet_repository.dart';

/// STORY-003 (REQ-010): pins the `PetReady` variant of the Home pet preview
/// card to `ux/uiux-spec.md` §1-§3, and pins the four states the design source
/// does *not* depict to their unchanged flat chrome (§0).
///
/// Token values are read back out of the live theme rather than hardcoded, so
/// each assertion stays about *which token* the card uses instead of about a
/// literal that would silently drift from `cupid_color_tokens.dart`.

Widget _harness(Widget child) => MediaQuery(
  // BunSprite bobs indefinitely for happy/inlove/neutral moods; disable
  // motion so pumpAndSettle can complete (mirrors pet_entry_point_test.dart).
  data: const MediaQueryData(disableAnimations: true),
  child: MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    // The design source is authored in Vietnamese; AC1 scopes fidelity to the
    // dark theme + `vi` locale configuration.
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: child,
  ),
);

/// The design canvas' own pet state (`Cupid Screens.dc.html` line 1979:
/// `petXp: 62, petLv: 3`). `131` is what the backend's frozen level math needs
/// to reproduce both: `floor(131 / 50) + 1 == 3` and `(131 % 50) / 50 == 0.62`.
PetStatus _designStatus({
  PetMood mood = PetMood.content,
  int level = 3,
  int totalInteractions = 131,
  String name = 'Bún',
}) => PetStatus(
  pet: Pet(
    id: 'pet-1',
    coupleId: 'couple-1',
    species: PetSpecies.bunny,
    name: name,
    happiness: 62,
    level: level,
    totalInteractions: totalInteractions,
    lastInteraction: null,
  ),
  mood: mood,
  decayedHappiness: 62,
  milestone: null,
  nextMilestone: 150,
);

Future<void> _pumpCard(WidgetTester tester, FakePetRepository repository) async {
  await tester.pumpWidget(
    _harness(Scaffold(body: PetPreviewCard(repository: repository))),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpReady(WidgetTester tester, {PetStatus? status}) => _pumpCard(
  tester,
  FakePetRepository()
    ..paired = true
    ..status = status ?? _designStatus(),
);

BuildContext _cardContext(WidgetTester tester) =>
    tester.element(find.byType(PetPreviewCard));

/// The ready shell is the only decoration in the card carrying both a gradient
/// and a border; the XP-bar fill has a gradient but no border, so this cannot
/// match it by accident.
BoxDecoration _readyShellDecoration(WidgetTester tester) {
  final Finder finder = find.descendant(
    of: find.byType(PetPreviewCard),
    matching: find.byWidgetPredicate(
      (Widget widget) =>
          widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).gradient != null &&
          (widget.decoration as BoxDecoration).border != null,
    ),
  );
  expect(finder, findsOneWidget);
  return tester.widget<DecoratedBox>(finder).decoration as BoxDecoration;
}

Finder _glow() => find.descendant(
  of: find.descendant(
    of: find.byType(PetPreviewCard),
    matching: find.byType(IgnorePointer),
  ),
  matching: find.byType(Container),
);

/// `CupidSpacing.sm` is also 8, so height alone would additionally match the
/// spacer above the bar; the [Stack] child is what makes this the track.
Finder _xpTrack() => find.descendant(
  of: find.byType(PetPreviewCard),
  matching: find.byWidgetPredicate(
    (Widget widget) =>
        widget is SizedBox && widget.height == 8 && widget.child is Stack,
  ),
);

void main() {
  setUp(getIt.reset);
  tearDown(getIt.reset);

  group('AC1/AC2 §1 ready-state card chrome', () {
    testWidgets('paints the 130deg pink/mint wash from named tokens', (
      WidgetTester tester,
    ) async {
      await _pumpReady(tester);

      final CupidColorTokens colors = _cardContext(tester).cupidColors;
      final LinearGradient gradient =
          _readyShellDecoration(tester).gradient! as LinearGradient;

      expect(gradient.colors, <Color>[
        colors.colorAccentPink.withAlpha(51),
        colors.colorMint.withAlpha(41),
      ]);
      // `linear-gradient(130deg, ...)`: CSS 0deg points "to top" and rotates
      // clockwise, so the axis is `(sin130, -cos130)`.
      expect(
        gradient.begin,
        const Alignment(-0.766044443118978, -0.6427876096865393),
      );
      expect(
        gradient.end,
        const Alignment(0.766044443118978, 0.6427876096865393),
      );
    });

    testWidgets('carries the 1px --line border at the card radius', (
      WidgetTester tester,
    ) async {
      await _pumpReady(tester);

      final BuildContext context = _cardContext(tester);
      final CupidColorTokens colors = context.cupidColors;
      final CupidPlatformTokens platformTokens = context.cupidPlatform;
      final BoxDecoration decoration = _readyShellDecoration(tester);

      expect(decoration.border, Border.all(color: colors.colorLine, width: 1));
      expect(
        decoration.borderRadius,
        BorderRadius.circular(platformTokens.radiusCard),
      );
    });

    testWidgets('clips at the card radius so the glow cannot bleed out', (
      WidgetTester tester,
    ) async {
      await _pumpReady(tester);

      final CupidPlatformTokens platformTokens =
          _cardContext(tester).cupidPlatform;
      final Finder shellClip = find
          .ancestor(of: _glow(), matching: find.byType(ClipRRect))
          .first;

      expect(
        tester.widget<ClipRRect>(shellClip).borderRadius,
        BorderRadius.circular(platformTokens.radiusCard),
      );
    });
  });

  group('AC1/AC2 §2 decorative glow circle', () {
    testWidgets('is a 74px white-at-26% circle fading out at stop 0.7', (
      WidgetTester tester,
    ) async {
      await _pumpReady(tester);

      expect(_glow(), findsOneWidget);
      expect(tester.getSize(_glow()), const Size(74, 74));

      final BoxDecoration decoration =
          tester.widget<Container>(_glow()).decoration! as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);

      final RadialGradient gradient = decoration.gradient! as RadialGradient;
      expect(gradient.colors, <Color>[
        Colors.white.withAlpha(66),
        Colors.white.withAlpha(0),
      ]);
      expect(gradient.stops, <double>[0.0, 0.7]);
    });

    testWidgets('sits at top:-14 and right:12% of the card width', (
      WidgetTester tester,
    ) async {
      await _pumpReady(tester);

      final Rect card = tester.getRect(find.byType(PetPreviewCard));
      final Rect glow = tester.getRect(_glow());

      expect(glow.top, closeTo(card.top - 14, 0.01));
      // Anchored to 12% of the *card's* width, not a transcribed pixel value.
      expect(card.right - glow.right, closeTo(card.width * 0.12, 0.01));
    });
  });

  group('AC1/AC2 §3 content layout', () {
    testWidgets('renders the pet name in Nunito 17/w900 on --tx', (
      WidgetTester tester,
    ) async {
      await _pumpReady(tester);

      final CupidColorTokens colors = _cardContext(tester).cupidColors;
      final Text name = tester.widget<Text>(find.text('Bún'));

      expect(name.style?.fontFamily, 'Nunito');
      expect(name.style?.fontWeight, FontWeight.w900);
      expect(name.style?.fontSize, 17);
      expect(name.style?.color, colors.colorText);
    });

    testWidgets('pairs the name and the level chip on one baseline row', (
      WidgetTester tester,
    ) async {
      await _pumpReady(tester);

      final Finder baselineRow = find
          .ancestor(of: find.text('Lv.3'), matching: find.byType(Row))
          .first;

      expect(
        find.descendant(of: baselineRow, matching: find.text('Bún')),
        findsOneWidget,
      );

      final Row row = tester.widget<Row>(baselineRow);
      expect(row.crossAxisAlignment, CrossAxisAlignment.baseline);
      expect(row.textBaseline, TextBaseline.alphabetic);
    });

    testWidgets('centers the sprite against the text block (§3.1)', (
      WidgetTester tester,
    ) async {
      await _pumpReady(tester);

      final Row outerRow = tester.widget<Row>(
        find
            .ancestor(of: find.byType(BunSprite), matching: find.byType(Row))
            .first,
      );

      expect(outerRow.crossAxisAlignment, CrossAxisAlignment.center);
    });

    testWidgets('the chip reads Lv.N only, with no mood suffix', (
      WidgetTester tester,
    ) async {
      await _pumpReady(tester);

      expect(find.text('Lv.3'), findsOneWidget);
      // The design badge carries no mood text; the mood only ever reaches this
      // card through the caption line below, never through the chip.
      expect(find.textContaining('·'), findsNothing);
    });

    testWidgets('the chip is pink-at-22% on a 6px radius with 10px pink mono', (
      WidgetTester tester,
    ) async {
      await _pumpReady(tester);

      final CupidColorTokens colors = _cardContext(tester).cupidColors;
      final BoxDecoration decoration = tester
          .widget<Container>(
            find
                .ancestor(
                  of: find.text('Lv.3'),
                  matching: find.byType(Container),
                )
                .first,
          )
          .decoration! as BoxDecoration;

      expect(decoration.color, colors.colorAccentPink.withAlpha(56));
      expect(decoration.borderRadius, BorderRadius.circular(6));

      final Text chip = tester.widget<Text>(find.text('Lv.3'));
      expect(chip.style?.fontFamily, 'Roboto Mono');
      expect(chip.style?.fontSize, 10);
      expect(chip.style?.color, colors.colorAccentPink);
    });

    testWidgets('the status caption states its own 12px role, not caption 13', (
      WidgetTester tester,
    ) async {
      await _pumpReady(tester);

      final BuildContext context = _cardContext(tester);
      final CupidColorTokens colors = context.cupidColors;
      final Text caption = tester.widget<Text>(
        find.text(context.petStatusLine(PetMood.content)),
      );

      expect(caption.style?.fontSize, 12);
      expect(caption.style?.color, colors.colorTextMuted);
    });

    testWidgets('a long pet name ellipsizes instead of overflowing the row', (
      WidgetTester tester,
    ) async {
      await _pumpReady(tester, status: _designStatus(name: 'Bún' * 40));

      expect(tester.takeException(), isNull);
      expect(find.text('Lv.3'), findsOneWidget);
    });
  });

  group('AC1/AC2 §3.5 XP bar', () {
    testWidgets(
      'is an 8px --surf track filled by gradientDream at levelProgress',
      (WidgetTester tester) async {
        await _pumpReady(tester);

        final CupidColorTokens colors = _cardContext(tester).cupidColors;

        // The previous LinearProgressIndicator cannot paint a gradient fill.
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(_xpTrack(), findsOneWidget);

        final ColoredBox trackFill = tester.widget<ColoredBox>(
          find.descendant(of: _xpTrack(), matching: find.byType(ColoredBox)),
        );
        expect(trackFill.color, colors.colorSurface);

        final FractionallySizedBox fill = tester.widget<FractionallySizedBox>(
          find.descendant(
            of: _xpTrack(),
            matching: find.byType(FractionallySizedBox),
          ),
        );
        expect(fill.widthFactor, _designStatus().levelProgress);
        expect(fill.widthFactor, closeTo(0.62, 1e-9));

        final BoxDecoration fillDecoration = tester
            .widget<DecoratedBox>(
              find.descendant(
                of: _xpTrack(),
                matching: find.byType(DecoratedBox),
              ),
            )
            .decoration as BoxDecoration;
        expect(fillDecoration.gradient, colors.gradientDream);
      },
    );

    testWidgets('spans the text column, not levelProgress of a tight row', (
      WidgetTester tester,
    ) async {
      await _pumpReady(tester);

      final BuildContext context = _cardContext(tester);
      final Rect card = tester.getRect(find.byType(PetPreviewCard));
      final Rect caption = tester.getRect(
        find.text(context.petStatusLine(PetMood.content)),
      );
      final Rect track = tester.getRect(_xpTrack());

      // The design nests the bar in the `flex:1;min-width:0` text column, so it
      // starts at the caption's left edge, right of the 74px sprite.
      expect(track.left, closeTo(caption.left, 0.01));
      expect(
        track.width,
        closeTo(card.width - 2 * CupidSpacing.md - 74 - CupidSpacing.md, 0.01),
      );
    });

    testWidgets('renders an empty bar at a level boundary', (
      WidgetTester tester,
    ) async {
      await _pumpReady(tester, status: _designStatus(totalInteractions: 100));

      final FractionallySizedBox fill = tester.widget<FractionallySizedBox>(
        find.descendant(
          of: _xpTrack(),
          matching: find.byType(FractionallySizedBox),
        ),
      );
      expect(fill.widthFactor, 0.0);
    });
  });

  group('§0 the four undepicted states keep their flat chrome', () {
    void expectFlatShell(WidgetTester tester) {
      final CupidColorTokens colors = _cardContext(tester).cupidColors;
      final Container shell = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(PetPreviewCard),
              matching: find.byWidgetPredicate(
                (Widget widget) =>
                    widget is Container && widget.decoration is BoxDecoration,
              ),
            )
            .first,
      );
      final BoxDecoration decoration = shell.decoration! as BoxDecoration;

      expect(decoration.color, colors.colorSurface);
      expect(decoration.gradient, isNull);
      expect(decoration.border, isNull);

      // No glow, and therefore none of the ready shell's chrome either.
      expect(
        find.descendant(
          of: find.byType(PetPreviewCard),
          matching: find.byType(IgnorePointer),
        ),
        findsNothing,
      );
    }

    testWidgets('PetLoading', (WidgetTester tester) async {
      await tester.pumpWidget(
        _harness(
          Scaffold(
            body: PetPreviewCard(
              repository: FakePetRepository()
                ..paired = true
                ..status = _designStatus(),
            ),
          ),
        ),
      );
      // No further pump: the first built frame is the cubit's initial state.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expectFlatShell(tester);

      await tester.pumpAndSettle();
    });

    testWidgets('PetLocked', (WidgetTester tester) async {
      await _pumpCard(tester, FakePetRepository()..paired = false);

      expect(find.text(_cardContext(tester).petLockedHeadline), findsOneWidget);
      expectFlatShell(tester);
    });

    testWidgets('PetNoPet', (WidgetTester tester) async {
      await _pumpCard(
        tester,
        FakePetRepository()
          ..paired = true
          ..status = null,
      );

      expect(find.text(_cardContext(tester).petAdoptHeadline), findsOneWidget);
      expectFlatShell(tester);
    });

    testWidgets('PetFailure', (WidgetTester tester) async {
      await _pumpCard(
        tester,
        FakePetRepository()
          ..paired = true
          // The capture harness' own failure: an unauthenticated `GET
          // /users/me`. `PetCubit.load` only converts `CupidApiFailure`.
          ..readStatusError = const UnauthorizedFailure(),
      );

      expect(find.text('Không thể tải Bún'), findsOneWidget);
      expectFlatShell(tester);
    });
  });

  group('AC4 the tap contract survives the shell split', () {
    testWidgets('the ready card reaches PetScreen even through the glow', (
      WidgetTester tester,
    ) async {
      final FakePetRepository repository = FakePetRepository()
        ..paired = true
        ..status = _designStatus();
      getIt.registerSingleton<PetRepository>(repository);

      await _pumpCard(tester, repository);

      // The decorative circle sits above the content; IgnorePointer is what
      // keeps it from swallowing this gesture.
      await tester.tapAt(tester.getCenter(_glow()));
      await tester.pumpAndSettle();

      expect(find.byType(PetScreen), findsOneWidget);
    });

    testWidgets('the locked card still reaches PetScreen', (
      WidgetTester tester,
    ) async {
      final FakePetRepository repository = FakePetRepository()..paired = false;
      getIt.registerSingleton<PetRepository>(repository);

      await _pumpCard(tester, repository);

      await tester.tap(find.byType(PetPreviewCard));
      await tester.pumpAndSettle();

      expect(find.byType(PetScreen), findsOneWidget);
    });

    testWidgets('the ready shell exposes exactly one tap target', (
      WidgetTester tester,
    ) async {
      await _pumpReady(tester);

      expect(
        find.descendant(
          of: find.byType(PetPreviewCard),
          matching: find.byType(GestureDetector),
        ),
        findsOneWidget,
      );

      final Semantics semantics = tester.widget<Semantics>(
        find
            .descendant(
              of: find.byType(PetPreviewCard),
              matching: find.byWidgetPredicate(
                (Widget widget) =>
                    widget is Semantics && widget.properties.button == true,
              ),
            )
            .first,
      );
      expect(semantics.properties.label, 'Mở Bún');
    });
  });
}
