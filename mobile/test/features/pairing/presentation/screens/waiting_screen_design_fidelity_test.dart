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
Widget _harness() {
  final DateTime expiresAt = DateTime.utc(2026, 1, 2);
  return MaterialApp(
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: WaitingScreen(
      expiresAt: expiresAt,
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
}
