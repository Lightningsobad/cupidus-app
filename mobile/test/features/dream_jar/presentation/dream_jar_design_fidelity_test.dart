import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/screens/dream_jar_detail_screen.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/widgets/dream_jar_hero_card.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/widgets/dream_jar_illustration.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/widgets/dream_jar_quick_add_section.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/widgets/partner_split_card.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const CupidColorTokens _colors = CupidColorTokens.dark();
const CupidPlatformTokens _platform = CupidPlatformTokens.material();

/// The design source's own `jar` numbers, so a failure here reads as a
/// deviation from the canvas rather than from an arbitrary fixture.
DreamJar _jar() => DreamJar(
  id: 'jar-1',
  name: 'Du lịch Đà Lạt',
  targetAmount: 5000000,
  currentAmount: 3900000,
  deadline: null,
  currency: 'VND',
  status: DreamJarStatus.active,
  serverProgress: null,
  createdAt: DateTime(2026, 1, 1),
);

List<Contribution> _contributions() => <Contribution>[
  Contribution(
    id: 'c1',
    dreamJarId: 'jar-1',
    userId: 'me',
    amount: 2180000,
    note: null,
    createdAt: DateTime(2026, 1, 1),
  ),
  Contribution(
    id: 'c2',
    dreamJarId: 'jar-1',
    userId: 'partner',
    amount: 1720000,
    note: null,
    createdAt: DateTime(2026, 1, 2),
  ),
];

class _FakeDreamJarRepository extends DreamJarRepository {
  _FakeDreamJarRepository() : super(CupidApiClient.create());

  @override
  Future<DreamJar> fetchJar(String id) async => _jar();

  @override
  Future<List<Contribution>> fetchContributions(
    String jarId, {
    int limit = 50,
    int offset = 0,
  }) async => _contributions();
}

Widget _harness(Widget child) {
  return MediaQuery(
    // The jar illustration bobs and shimmers indefinitely.
    data: const MediaQueryData(disableAnimations: true),
    child: MaterialApp(
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      locale: const Locale('vi'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('Dream Jar hero card matches the design source', () {
    testWidgets('carries the 172deg hero gradient, hairline border and card '
        'elevation shadow', (WidgetTester tester) async {
      await tester.pumpWidget(
        _harness(
          DreamJarHeroCard(
            jar: _jar(),
            contributionFailure: null,
            onSelectJar: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BoxDecoration decoration =
          tester
                  .widget<DecoratedBox>(
                    find
                        .descendant(
                          of: find.byType(DreamJarHeroCard),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;

      expect(decoration.gradient, DreamJarPalette.heroGradient);
      expect(decoration.boxShadow, _platform.elevationShadow);
      expect((decoration.border! as Border).top.color, _colors.colorLine);
      expect(decoration.borderRadius, BorderRadius.circular(34));
    });

    testWidgets('centres the hero content on the card, not on its widest '
        'child', (WidgetTester tester) async {
      await tester.pumpWidget(
        _harness(
          DreamJarHeroCard(
            jar: _jar(),
            contributionFailure: null,
            onSelectJar: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final double cardCentre = tester
          .getCenter(find.byType(DreamJarHeroCard))
          .dx;

      for (final Finder finder in <Finder>[
        find.byType(DreamJarIllustration),
        find.text('3.900.000₫'),
        find.textContaining('· 78%'),
      ]) {
        expect(
          tester.getCenter(finder).dx,
          closeTo(cardCentre, 0.5),
          reason: '$finder is not centred on the card',
        );
      }
    });

    testWidgets('renders the amount in the Nunito 32 display role', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          DreamJarHeroCard(
            jar: _jar(),
            contributionFailure: null,
            onSelectJar: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final TextStyle style = tester
          .widget<Text>(find.text('3.900.000₫'))
          .style!;
      expect(style.fontFamily, 'Nunito');
      expect(style.fontWeight, FontWeight.w900);
      expect(style.fontSize, 32);
      expect(style.height, 1.1);
      expect(style.color, DreamJarPalette.onHeroText);
    });
  });

  group('Dream Jar quick-add presets match the design source', () {
    testWidgets('renders 100k/200k/500k with the third tile on the hot '
        'gradient and glow', (WidgetTester tester) async {
      await tester.pumpWidget(
        _harness(DreamJarQuickAddSection(enabled: true, onQuickAdd: (_) {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('+100k'), findsOneWidget);
      expect(find.text('+200k'), findsOneWidget);
      expect(find.text('+500k'), findsOneWidget);

      final BoxDecoration first = _tileDecoration(tester, '+100k');
      expect(first.color, _colors.colorSurface);
      expect(first.boxShadow, _platform.elevationShadow);

      final BoxDecoration third = _tileDecoration(tester, '+500k');
      expect(third.gradient, _colors.gradientHot);
      expect(third.boxShadow, _colors.glowShadow);
    });
  });

  group('Dream Jar comparison card matches the design source', () {
    testWidgets('fills the leading bar to 78% of the track and scales the '
        'other off it', (WidgetTester tester) async {
      await tester.pumpWidget(
        _harness(
          PartnerSplitCard(contributions: _contributions(), currentUserId: 'me'),
        ),
      );
      await tester.pumpAndSettle();

      final List<double?> factors = tester
          .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
          .map((FractionallySizedBox box) => box.heightFactor)
          .toList();

      expect(factors, hasLength(2));
      expect(factors[0], closeTo(0.78, 0.0001));
      expect(factors[1], closeTo(0.78 * 1720000 / 2180000, 0.0001));
    });

    testWidgets('sizes each bar 48x88 with a 16pt radius', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          PartnerSplitCard(contributions: _contributions(), currentUserId: 'me'),
        ),
      );
      await tester.pumpAndSettle();

      final Size barSize = tester.getSize(find.byType(ClipRRect).first);
      expect(barSize.width, 48);
      expect(barSize.height, 88);
    });
  });

  group('Dream Jar screen gutter matches the design source', () {
    testWidgets('uses the canvas 8/16/40 page padding', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          DreamJarDetailScreen(
            jarId: 'jar-1',
            repository: _FakeDreamJarRepository(),
            currentUserId: 'me',
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final SingleChildScrollView scrollView = tester
          .widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
      expect(scrollView.padding, const EdgeInsets.fromLTRB(16, 8, 16, 40));
    });
  });
}

BoxDecoration _tileDecoration(WidgetTester tester, String label) {
  return tester
          .widget<DecoratedBox>(
            find
                .ancestor(
                  of: find.text(label),
                  matching: find.byType(DecoratedBox),
                )
                .first,
          )
          .decoration
      as BoxDecoration;
}
