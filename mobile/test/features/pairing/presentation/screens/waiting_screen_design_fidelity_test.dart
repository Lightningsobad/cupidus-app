import 'dart:async';

import 'package:cupid_mobile/core/realtime/realtime_coordinator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link_poller.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/waiting_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/waiting_cubit.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLifecycleSource implements RealtimeLifecycleSource {
  _FakeLifecycleSource(this.currentState);

  @override
  AppLifecycleState currentState;

  final _controller = StreamController<AppLifecycleState>.broadcast(sync: true);

  @override
  Stream<AppLifecycleState> get states => _controller.stream;

  @override
  void dispose() => _controller.close();
}

class _FakeTimer implements Timer {
  _FakeTimer(this.callback);

  final void Function() callback;
  bool _cancelled = false;

  @override
  bool get isActive => !_cancelled;

  @override
  void cancel() => _cancelled = true;

  @override
  int get tick => 0;
}

/// Dark theme + `vi` locale — the only combination enabled for users (OQ5).
/// [code] mirrors what `invite_screen.dart` threads through from the live
/// `PairingInvitation`; pass `null` to exercise the codeless fallback.
Widget _harness({String? code = 'CPD-8F2K'}) {
  final DateTime expiresAt = DateTime.utc(2026, 1, 2);
  return MaterialApp(
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    // Mirrors `cupid_app.dart`: the sky wash is mounted once at the
    // composition root, not per screen, so a bare `home:` harness would not
    // compose the screen the way the running app does.
    builder: (BuildContext context, Widget? child) =>
        CupidAppBackground(child: child ?? const SizedBox.shrink()),
    home: WaitingScreen(
      expiresAt: expiresAt,
      code: code,
      createWaitingCubit: () => WaitingCubit(
        getPartnerLink: () async => const PartnerLink(partnerId: null),
        expiresAt: expiresAt,
        createPoller: (onPaired, onTimedOut) => PartnerLinkPoller(
          fetchPartnerLink: () async => const PartnerLink(partnerId: null),
          expiresAt: expiresAt,
          onPaired: onPaired,
          onTimedOut: onTimedOut,
          lifecycleSource: _FakeLifecycleSource(AppLifecycleState.resumed),
          now: () => DateTime.utc(2026, 1, 1),
          timerFactory: (duration, callback) => _FakeTimer(callback),
        ),
      ),
    ),
  );
}

Finder _sizedBox({double? width, double? height}) {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is SizedBox &&
        (width == null || widget.width == width) &&
        (height == null || widget.height == height),
  );
}

double _firstRingScale(WidgetTester tester) {
  final Transform ring = tester.widget<Transform>(
    find
        .descendant(
          of: _sizedBox(width: 150, height: 150),
          matching: find.byType(Transform),
        )
        .first,
  );
  return ring.transform.getMaxScaleOnAxis();
}

/// STORY-013 design-fidelity guard for the `waiting` screen, asserted against
/// the locked `cupid-app-design-system` source (`Cupid Screens.dc.html`,
/// `isWaiting` block).
void main() {
  const CupidColorTokens colors = CupidColorTokens.dark();
  const CupidPlatformTokens platformTokens = CupidPlatformTokens.material();

  testWidgets('renders the design source pulseRing/bob waiting field', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    expect(_sizedBox(width: 150, height: 150), findsOneWidget);

    final Icon hourglass = tester.widget<Icon>(
      find.byIcon(CupidIcons.hourglass),
    );
    expect(hourglass.size, 46);
    expect(hourglass.color, colors.colorAccentPink);

    // AC 3: no ad hoc spinner; the rings run the pulseRing keyframes rather
    // than sitting static.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    final double firstFrame = _firstRingScale(tester);
    await tester.pump(const Duration(milliseconds: 600));
    expect(_firstRingScale(tester), greaterThan(firstFrame));
  });

  testWidgets('renders over the --sky wash and twinkle stars without '
      'occluding them', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    // STORY-032 moved the `--sky` wash out of this screen into the app-shell
    // `CupidAppBackground`. The per-layer stops, star geometry and twinkle
    // curve are now owned by `CupidSkyPalette` and asserted in
    // `test/design_system/cupid_app_background_test.dart`; what stays this
    // screen's responsibility is that the wash reaches it and that the screen
    // does not paint over it.
    final CupidSkyPainter sky = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((CustomPaint paint) => paint.painter)
        .whereType<CupidSkyPainter>()
        .single;
    expect(sky.layers, same(CupidSkyPalette.darkLayers));

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      isNull,
    );
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).scaffoldBackgroundColor.a,
      0,
    );

    final Set<Color?> circleFills = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((DecoratedBox box) => box.decoration)
        .whereType<BoxDecoration>()
        .where((BoxDecoration it) => it.shape == BoxShape.circle)
        .map((BoxDecoration it) => it.color)
        .toSet();
    expect(
      circleFills,
      containsAll(CupidSkyPalette.stars.map((CupidSkyStar star) => star.color)),
    );
  });

  testWidgets('applies the design source typography and muted subtitle', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    final Text title = tester.widget<Text>(find.text('Đang chờ người ấy…'));
    expect(title.style?.fontFamily, 'Nunito');
    expect(title.style?.fontWeight, FontWeight.w900);
    expect(title.style?.fontSize, 24);
    expect(title.style?.height, 1.25);
    expect(title.style?.color, colors.colorText);

    final Text subtitle = tester.widget<Text>(
      find.text('Gửi mã rồi mà chưa thấy ai vào. Chọc Bae một cái đi.'),
    );
    expect(subtitle.style?.fontSize, 13);
    expect(subtitle.style?.height, 1.6);
    expect(subtitle.style?.color, colors.colorTextMuted);
  });

  testWidgets('styles the refresh action from tokens, not Material defaults', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    expect(_sizedBox(height: 50), findsOneWidget);

    const Set<WidgetState> resting = <WidgetState>{};
    final ButtonStyle style = tester
        .widget<OutlinedButton>(find.byType(OutlinedButton))
        .style!;
    expect(style.side?.resolve(resting)?.color, colors.colorLine);
    expect(style.side?.resolve(resting)?.width, 1.5);
    expect(style.textStyle?.resolve(resting)?.fontSize, 14.5);
    expect(style.textStyle?.resolve(resting)?.fontWeight, FontWeight.w700);
    expect(style.foregroundColor?.resolve(resting), colors.colorText);
  });

  testWidgets('renders the design source code card for the invite code', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    final Container card = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('Mã của bạn'),
            matching: find.byType(Container),
          )
          .first,
    );
    final BoxDecoration decoration = card.decoration! as BoxDecoration;
    expect(decoration.color, colors.colorSurface);
    expect(decoration.borderRadius, BorderRadius.circular(20));
    expect(decoration.boxShadow, platformTokens.elevationShadow);
    expect(
      card.padding,
      const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
    );

    final Text label = tester.widget<Text>(find.text('Mã của bạn'));
    expect(label.style?.fontSize, 11);
    expect(label.style?.color, colors.colorTextMuted);

    final Text code = tester.widget<Text>(find.text('CPD-8F2K'));
    expect(code.style?.fontFamily, 'Roboto Mono');
    expect(code.style?.fontSize, 26);
    expect(code.style?.fontWeight, FontWeight.w500);
    // The design source's `letter-spacing:.14em` resolved at 26px.
    expect(code.style?.letterSpacing, closeTo(3.64, 0.001));

    // `background:var(--grad-hot)` clipped to the glyphs, not a flat fill.
    expect(
      find.ancestor(
        of: find.text('CPD-8F2K'),
        matching: find.byType(ShaderMask),
      ),
      findsOneWidget,
    );
  });

  testWidgets('renders the resend CTA as the gradient primary of the row', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    final Text label = tester.widget<Text>(find.text('Gửi lại'));
    expect(label.style?.fontSize, 14.5);
    expect(label.style?.fontWeight, FontWeight.w800);
    expect(label.style?.color, colors.colorText);

    // The design source prefixes the label with `ios_share` at 19px and an
    // 8px gap; the label must not stand alone.
    final Icon share = tester.widget<Icon>(find.byIcon(CupidIcons.iosShare));
    expect(share.size, 19);
    expect(share.color, colors.colorText);
    expect(
      tester.getRect(find.text('Gửi lại')).left -
          tester.getRect(find.byIcon(CupidIcons.iosShare)).right,
      closeTo(8, 0.01),
    );

    final DecoratedBox box = tester.widget<DecoratedBox>(
      find
          .ancestor(
            of: find.text('Gửi lại'),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final BoxDecoration decoration = box.decoration as BoxDecoration;
    expect(decoration.gradient, colors.gradientHot);
    expect(decoration.boxShadow, colors.glowShadow);
    expect(
      decoration.borderRadius,
      BorderRadius.circular(platformTokens.radiusButton),
    );

    // `flex:1` on both children: the row splits evenly around the 10px gap.
    final Size resend = tester.getSize(find.text('Gửi lại').hitTestable());
    expect(resend.height, lessThanOrEqualTo(50));
    final Rect resendBox = tester.getRect(find.byWidget(box));
    final Rect refreshBox = tester.getRect(find.byType(OutlinedButton));
    expect(resendBox.width, closeTo(refreshBox.width, 0.01));
    expect(refreshBox.left - resendBox.right, closeTo(10, 0.01));
    expect(refreshBox.right - resendBox.left, lessThanOrEqualTo(300));
    expect(resendBox.height, 50);
  });

  testWidgets('omits the code card and resend CTA when no code is supplied', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(code: null));
    await tester.pump();

    expect(find.text('Mã của bạn'), findsNothing);
    expect(find.text('Gửi lại'), findsNothing);
    expect(find.byIcon(CupidIcons.iosShare), findsNothing);
    // The refresh action still occupies the full 50px row on its own.
    expect(find.text('Làm mới'), findsOneWidget);
    expect(_sizedBox(height: 50), findsOneWidget);
  });
}
