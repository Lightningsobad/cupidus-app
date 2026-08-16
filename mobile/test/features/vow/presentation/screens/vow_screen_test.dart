import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/vow/presentation/screens/vow_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dark theme + `vi` locale — the only combination enabled for users (OQ5).
Widget _harness({
  bool selfVowed = false,
  bool partnerVowed = false,
  VoidCallback? onVowSigned,
  VoidCallback? onEnterDashboard,
}) {
  return MaterialApp(
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: VowScreen(
      selfVowed: selfVowed,
      partnerVowed: partnerVowed,
      selfInitial: 'M',
      partnerInitial: 'L',
      onVowSigned: onVowSigned,
      onEnterDashboard: onEnterDashboard,
    ),
  );
}

Finder _discOf(Key key) =>
    find.descendant(of: find.byKey(key), matching: find.byType(Container));

void main() {
  testWidgets('AC1: renders the design source header block in vi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    expect(find.text('FINGERPRINT VOW'), findsOneWidget);
    expect(find.text('Cùng đặt ngón tay\nvào một lúc'), findsOneWidget);
    expect(find.textContaining('Vân tay xử lý ngay trên máy.'), findsOneWidget);
  });

  testWidgets('AC4 idle: fingerprint hold target, both partners waiting', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    expect(find.byKey(const Key('vow_hold_target')), findsOneWidget);
    expect(find.byKey(const Key('vow_signed_disc')), findsNothing);
    expect(find.text('đang đợi'), findsNWidgets(2));
    expect(find.text('sẵn sàng'), findsNothing);
    expect(find.byKey(const Key('vow_enter_dashboard_cta')), findsNothing);
  });

  testWidgets('AC3: a full 1.5s dwell signs the vow, a short one does not', (
    WidgetTester tester,
  ) async {
    int signed = 0;
    await tester.pumpWidget(_harness(onVowSigned: () => signed++));
    await tester.pump();

    final TestGesture shortHold = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('vow_hold_target'))),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await shortHold.up();
    await tester.pump();

    expect(signed, 0);
    expect(find.byKey(const Key('vow_signed_disc')), findsNothing);

    final TestGesture fullHold = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('vow_hold_target'))),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await fullHold.up();
    await tester.pump();

    expect(signed, 1);
    expect(find.byKey(const Key('vow_signed_disc')), findsOneWidget);
    expect(find.byKey(const Key('vow_hold_target')), findsNothing);
  });

  testWidgets('AC4 first-partner-signed: check disc, no dashboard CTA', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness(selfVowed: true));
    await tester.pump();

    expect(find.byKey(const Key('vow_signed_disc')), findsOneWidget);
    expect(find.text('sẵn sàng'), findsOneWidget);
    expect(find.text('đang đợi'), findsOneWidget);
    expect(find.byKey(const Key('vow_enter_dashboard_cta')), findsNothing);
  });

  testWidgets('AC4 both-signed: both ready and the dashboard CTA appears', (
    WidgetTester tester,
  ) async {
    int entered = 0;
    await tester.pumpWidget(
      _harness(
        selfVowed: true,
        partnerVowed: true,
        onEnterDashboard: () => entered++,
      ),
    );
    await tester.pump();

    expect(find.text('sẵn sàng'), findsNWidgets(2));
    expect(find.text('Vào Dashboard'), findsOneWidget);

    await tester.tap(find.byKey(const Key('vow_enter_dashboard_cta')));
    await tester.pump();
    expect(entered, 1);
  });

  testWidgets('AC1: signed disc uses the design mint fill and 2px border', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness(selfVowed: true));
    await tester.pump(const Duration(milliseconds: 600));

    final Container disc = tester.widget<Container>(
      _discOf(const Key('vow_signed_disc')).first,
    );
    final BoxDecoration decoration = disc.decoration! as BoxDecoration;
    const Color mint = Color(0xFF79E2CD);

    expect(decoration.shape, BoxShape.circle);
    expect(decoration.color, mint.withValues(alpha: 0.16));
    expect(decoration.border!.top.color, mint);
    expect(decoration.border!.top.width, 2);
  });

  testWidgets('AC1: the shared twinkle star field paints over the screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    expect(find.byType(CupidStarField), findsOneWidget);

    // The source marks the particles `pointer-events:none`, so they must not
    // intercept the hold target underneath them.
    expect(
      tester
          .widget<IgnorePointer>(
            find.descendant(
              of: find.byType(CupidStarField),
              matching: find.byType(IgnorePointer),
            ),
          )
          .ignoring,
      isTrue,
    );
  });

  testWidgets('AC3: the hold target exposes an accessible activation', (
    WidgetTester tester,
  ) async {
    int signed = 0;
    await tester.pumpWidget(_harness(onVowSigned: () => signed++));
    await tester.pump();

    final SemanticsNode node = tester.getSemantics(
      find.byKey(const Key('vow_hold_target')),
    );
    expect(node.label, 'Giữ 1,5 giây để ký Fingerprint Vow');

    final SemanticsHandle handle = tester.ensureSemantics();
    final PipelineOwner owner = tester
        .element(find.byKey(const Key('vow_hold_target')))
        .renderObject!
        .owner!;
    owner.semanticsOwner!.performAction(node.id, SemanticsAction.tap);
    await tester.pump();

    expect(signed, 1);
    expect(find.byKey(const Key('vow_signed_disc')), findsOneWidget);
    handle.dispose();
  });
}
