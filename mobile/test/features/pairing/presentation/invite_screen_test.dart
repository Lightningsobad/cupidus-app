import 'dart:async';

import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pairing/data/pairing_invitation.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link_poller.dart';
import 'package:cupid_mobile/features/pairing/presentation/couple_type.dart';
import 'package:cupid_mobile/features/pairing/presentation/invite_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/joincode_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/invite_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/joincode_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/paired_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/waiting_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/waiting_cubit.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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

/// Stands in for `WaitingScreen`'s GetIt-backed default cubit: its
/// `PairingRepository` constructor param is private to its own library, so it
/// cannot be faked from this file. Uses the real, already-tested
/// `PartnerLinkPoller` with a timer factory that is never invoked, so the
/// poller stays idle rather than scheduling a real `Timer`.
/// [partnerId] lets a test drive [WaitingCubit.refreshNow] straight to
/// [WaitingPaired] (via `getPartnerLink`, the field `refreshNow` reads),
/// independent of the never-invoked poller timer factory below.
WaitingCubit _fakeWaitingCubit({String? partnerId}) {
  return WaitingCubit(
    getPartnerLink: () async => PartnerLink(partnerId: partnerId),
    expiresAt: DateTime.utc(2026, 1, 2),
    createPoller: (onPaired, onTimedOut) => PartnerLinkPoller(
      fetchPartnerLink: () async => const PartnerLink(partnerId: null),
      expiresAt: DateTime.utc(2026, 1, 2),
      onPaired: onPaired,
      onTimedOut: onTimedOut,
      timerFactory: (duration, callback) => _FakeTimer(callback),
    ),
  );
}

/// Stands in for the `getIt`-registered production registry, which this suite
/// never calls `setupServiceLocator()` to build. `InviteScreen` threads it down
/// to the `WaitingScreen` it pushes, which owns the `waiting` -> `paired` edge.
OnboardingRouter _stubRouter() => OnboardingRouter(
  builders: <OnboardingNode, WidgetBuilder>{
    OnboardingNode.paired: (_) => const PairedScreen(),
  },
);

/// [locale] is left null by the pre-REQ-009 cases, which resolve to the test
/// binding's `en-US` and assert English copy. The couple-type cases pass
/// `vi`, the surface named by the phase test scope.
Widget _harness({
  required InviteCubit Function() createInviteCubit,
  WaitingCubit Function()? createWaitingCubit,
  Locale? locale,
}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    locale: locale,
    home: InviteScreen(
      createInviteCubit: createInviteCubit,
      createWaitingCubit: createWaitingCubit ?? _fakeWaitingCubit,
      router: _stubRouter(),
    ),
  );
}

/// The semantic labels the picker publishes, one per card. Read off
/// [CoupleType] rather than retyped so a copy change cannot make these
/// assertions quietly match nothing.
Set<String> _coupleCardLabels() => <String>{
  for (final CoupleType coupleType in CoupleType.values)
    '${coupleType.labelVi}, ${coupleType.subtextVi}',
};

/// Reads the cards' `Semantics` properties directly instead of through
/// `tester.getSemantics`, so `selected` can be counted across all four cards
/// in one pass (AC3's "exactly one" is a property of the set, not of a node).
Iterable<SemanticsProperties> _coupleCardSemantics(WidgetTester tester) {
  final Set<String> labels = _coupleCardLabels();
  return tester
      .widgetList<Semantics>(find.byType(Semantics))
      .map((Semantics semantics) => semantics.properties)
      .where((SemanticsProperties properties) => labels.contains(properties.label));
}

CoupleType? _selectedCard(WidgetTester tester) {
  for (final CoupleType coupleType in CoupleType.values) {
    final String label = '${coupleType.labelVi}, ${coupleType.subtextVi}';
    final bool isSelected = _coupleCardSemantics(tester).any(
      (SemanticsProperties properties) =>
          properties.label == label && properties.selected == true,
    );
    if (isSelected) return coupleType;
  }
  return null;
}

/// The picker pushes the CTA past an 800x600 test surface, where an
/// out-of-viewport `tester.tap` only warns instead of failing.
Future<void> _useTallSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

PairingInvitation _invitation() => PairingInvitation(
  code: '3F9A2B',
  expiresAt: DateTime.utc(2026, 1, 2),
);

void main() {
  // The test environment has no default mock handler for the
  // `flutter/platform` channel's `Clipboard.setData` method, so without this
  // the awaited call inside `_copyAndAdvance` never completes.
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall methodCall,
        ) async {
          return null;
        });
  });

  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('renders the code and a live expiresAt countdown', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 1, 1, 12);
    final invitation = PairingInvitation(
      code: '3F9A2B',
      expiresAt: now.add(const Duration(hours: 23, minutes: 40)),
    );

    await tester.pumpWidget(
      _harness(
        createInviteCubit: () => InviteCubit(
          generateInvitation: () async => invitation,
          now: () => now,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('3F9A2B'), findsOneWidget);
    expect(find.text('6-character code'), findsOneWidget);
    expect(find.text('Expires in 23h 40m'), findsOneWidget);
  });

  testWidgets('the code card matches the design source treatment', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 1, 1, 12);
    final invitation = PairingInvitation(
      code: '3F9A2B',
      expiresAt: now.add(const Duration(hours: 1)),
    );

    await tester.pumpWidget(
      _harness(
        createInviteCubit: () => InviteCubit(
          generateInvitation: () async => invitation,
          now: () => now,
        ),
      ),
    );
    await tester.pump();

    const CupidColorTokens colors = CupidColorTokens.dark();
    const CupidPlatformTokens platform = CupidPlatformTokens.material();

    final BoxDecoration card = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .firstWhere((decoration) => decoration.color == colors.colorSurface);
    expect(card.borderRadius, BorderRadius.circular(platform.radiusCard));
    expect(card.boxShadow, platform.elevationShadow);

    // `--pink` -> `--purple` gradient-clip over the mono code (uiux-spec §3).
    expect(
      find.ancestor(of: find.text('3F9A2B'), matching: find.byType(ShaderMask)),
      findsOneWidget,
    );
    final TextStyle codeStyle = tester.widget<Text>(find.text('3F9A2B')).style!;
    expect(codeStyle.fontFamily, 'Roboto Mono');
    expect(codeStyle.fontSize, 36);
    expect(codeStyle.fontWeight, FontWeight.w500);
    expect(codeStyle.letterSpacing, closeTo(36 * 0.16, 0.001));

    // Secondary copy action is an icon-only square, not a labelled button.
    expect(find.widgetWithText(OutlinedButton, 'Copy code'), findsNothing);
    expect(tester.getSize(find.byTooltip('Copy code')), const Size(48, 48));
  });

  testWidgets('an idempotent refresh does not flash a spinner', (tester) async {
    var callCount = 0;
    final invitation = PairingInvitation(
      code: '3F9A2B',
      expiresAt: DateTime.utc(2026, 1, 2),
    );
    late InviteCubit cubit;

    await tester.pumpWidget(
      _harness(
        createInviteCubit: () {
          cubit = InviteCubit(
            generateInvitation: () async {
              callCount++;
              return invitation;
            },
            now: () => DateTime.utc(2026, 1, 1),
          );
          return cubit;
        },
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('3F9A2B'), findsOneWidget);

    await cubit.refresh();
    await tester.pump();

    expect(callCount, 2);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('3F9A2B'), findsOneWidget);
  });

  testWidgets('copy announces via a snackbar and advances to waiting', (
    tester,
  ) async {
    final invitation = PairingInvitation(
      code: '3F9A2B',
      expiresAt: DateTime.utc(2026, 1, 2),
    );

    await tester.pumpWidget(
      _harness(
        createInviteCubit: () => InviteCubit(
          generateInvitation: () async => invitation,
          now: () => DateTime.utc(2026, 1, 1),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Copy code'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.text('Copied'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(WaitingScreen), findsOneWidget);
  });

  testWidgets('share announces a distinct message and advances to waiting', (
    tester,
  ) async {
    final invitation = PairingInvitation(
      code: '3F9A2B',
      expiresAt: DateTime.utc(2026, 1, 2),
    );

    await tester.pumpWidget(
      _harness(
        createInviteCubit: () => InviteCubit(
          generateInvitation: () async => invitation,
          now: () => DateTime.utc(2026, 1, 1),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Share invite'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.text('Copied to share'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(WaitingScreen), findsOneWidget);
  });

  testWidgets('detecting a partner on WaitingScreen navigates through to '
      'PairedScreen (onPaired production wiring)', (tester) async {
    final invitation = PairingInvitation(
      code: '3F9A2B',
      expiresAt: DateTime.utc(2026, 1, 2),
    );

    await tester.pumpWidget(
      _harness(
        createInviteCubit: () => InviteCubit(
          generateInvitation: () async => invitation,
          now: () => DateTime.utc(2026, 1, 1),
        ),
        createWaitingCubit: () => _fakeWaitingCubit(partnerId: 'partner-1'),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Copy code'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(WaitingScreen), findsOneWidget);

    await tester.tap(find.text('Refresh'));
    await tester.pump();
    await tester.pump();
    // Bounded pumps rather than `pumpAndSettle`: `PairedScreen`'s bob
    // animation repeats forever by design and would never settle
    // (mirrors `paired_screen_test.dart`'s own pattern).
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(PairedScreen), findsOneWidget);
    expect(find.byType(WaitingScreen), findsNothing);
  });

  testWidgets('a generation failure shows an error with a retry action', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        createInviteCubit: () => InviteCubit(
          generateInvitation: () async => throw Exception('boom'),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text('Could not create an invite code. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('carries no header or tab chrome (AC4 NO_CHROME/NO_TABS)', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        createInviteCubit: () => InviteCubit(
          generateInvitation: () async => PairingInvitation(
            code: '3F9A2B',
            expiresAt: DateTime.utc(2026, 1, 2),
          ),
          now: () => DateTime.utc(2026, 1, 1),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(CupidHeader), findsNothing);
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.byType(CupidTabBar), findsNothing);
  });

  testWidgets('the in-body back control still pops the route', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCupidTheme(
          platform: CupidPlatform.material,
          brightness: Brightness.dark,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => InviteScreen(
                      createInviteCubit: () => InviteCubit(
                        generateInvitation: () async => PairingInvitation(
                          code: '3F9A2B',
                          expiresAt: DateTime.utc(2026, 1, 2),
                        ),
                        now: () => DateTime.utc(2026, 1, 1),
                      ),
                      createWaitingCubit: _fakeWaitingCubit,
                      router: _stubRouter(),
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(InviteScreen), findsOneWidget);

    await tester.tap(find.byIcon(CupidIcons.arrowBack));
    await tester.pumpAndSettle();

    expect(find.byType(InviteScreen), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('AC1: the picker sits between the code card and the CTA, in '
      'catalog order', (tester) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(
      _harness(
        locale: const Locale('vi'),
        createInviteCubit: () => InviteCubit(
          generateInvitation: () async => _invitation(),
          now: () => DateTime.utc(2026, 1, 1),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Tụi mình thuộc kiểu nào?'), findsOneWidget);
    expect(
      find.text('Cupid sẽ bật/tắt tính năng phù hợp cho kiểu của bạn.'),
      findsOneWidget,
    );
    expect(find.text('Yêu xa'), findsOneWidget);
    expect(find.text('Cùng thành phố'), findsOneWidget);
    expect(find.text('Mới hẹn hò'), findsOneWidget);
    expect(find.text('Gắn bó lâu dài'), findsOneWidget);
    expect(_coupleCardSemantics(tester), hasLength(4));

    final Offset subtitle = tester.getTopLeft(
      find.text('Cupid sẽ bật/tắt tính năng phù hợp cho kiểu của bạn.'),
    );
    final Offset longDistance = tester.getTopLeft(find.text('Yêu xa'));
    final Offset sameCity = tester.getTopLeft(find.text('Cùng thành phố'));
    final Offset dating = tester.getTopLeft(find.text('Mới hẹn hò'));
    final Offset livingTogether = tester.getTopLeft(find.text('Gắn bó lâu dài'));

    expect(tester.getBottomLeft(find.text('3F9A2B')).dy, lessThan(subtitle.dy));
    expect(
      tester.getBottomLeft(find.text('Tụi mình thuộc kiểu nào?')).dy,
      lessThan(subtitle.dy),
    );
    expect(subtitle.dy, lessThan(longDistance.dy));
    expect(longDistance.dx, lessThan(sameCity.dx));
    expect(longDistance.dy, lessThan(dating.dy));
    expect(dating.dx, lessThan(livingTogether.dx));
    expect(
      livingTogether.dy,
      lessThan(tester.getTopLeft(find.text('Tiếp tục')).dy),
    );

    // The cell block is left-aligned, not centered: labels of differing width
    // in one column now share a left edge instead of drifting apart, and each
    // cell's subtext starts on that same edge.
    expect(longDistance.dx, dating.dx);
    expect(sameCity.dx, livingTogether.dx);
    expect(
      tester.getTopLeft(find.text(CoupleType.longDistance.subtextVi)).dx,
      longDistance.dx,
    );
    expect(
      tester.getTopLeft(find.text(CoupleType.sameCity.subtextVi)).dx,
      sameCity.dx,
    );
  });

  testWidgets('D1: the two grid columns are equal width, split by one gutter', (
    tester,
  ) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(
      _harness(
        locale: const Locale('vi'),
        createInviteCubit: () => InviteCubit(
          generateInvitation: () async => _invitation(),
          now: () => DateTime.utc(2026, 1, 1),
        ),
      ),
    );
    await tester.pump();

    Rect cellOf(String label) => tester.getRect(
      find
          .ancestor(
            of: find.text(label),
            matching: find.byType(GestureDetector),
          )
          .first,
    );

    final Rect left = cellOf('Yêu xa');
    final Rect right = cellOf('Cùng thành phố');

    // Regression guard for D1: the gutter used to be a `Padding` inset on the
    // right cell only, which made that track one full gutter narrower.
    expect(left.width, closeTo(right.width, 0.01));
    expect(right.left - left.right, closeTo(10, 0.01));

    final Rect bottomLeft = cellOf('Mới hẹn hò');
    final Rect bottomRight = cellOf('Gắn bó lâu dài');
    expect(bottomLeft.width, closeTo(bottomRight.width, 0.01));
    expect(bottomRight.left - bottomLeft.right, closeTo(10, 0.01));
  });

  testWidgets('AC2: the CTA is disabled until a card is chosen', (tester) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(
      _harness(
        locale: const Locale('vi'),
        createInviteCubit: () => InviteCubit(
          generateInvitation: () async => _invitation(),
          now: () => DateTime.utc(2026, 1, 1),
        ),
      ),
    );
    await tester.pump();

    expect(_selectedCard(tester), isNull);
    expect(
      tester
          .widget<CupidPrimaryButton>(
            find.widgetWithText(CupidPrimaryButton, 'Tiếp tục'),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.text('Mới hẹn hò'));
    await tester.pump();

    expect(
      tester
          .widget<CupidPrimaryButton>(
            find.widgetWithText(CupidPrimaryButton, 'Tiếp tục'),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('AC3: choosing a second card swaps the selection', (tester) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(
      _harness(
        locale: const Locale('vi'),
        createInviteCubit: () => InviteCubit(
          generateInvitation: () async => _invitation(),
          now: () => DateTime.utc(2026, 1, 1),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Yêu xa'));
    await tester.pump();

    expect(
      _coupleCardSemantics(
        tester,
      ).where((SemanticsProperties p) => p.selected == true),
      hasLength(1),
    );
    expect(_selectedCard(tester), CoupleType.longDistance);

    await tester.tap(find.text('Gắn bó lâu dài'));
    await tester.pump();

    expect(
      _coupleCardSemantics(
        tester,
      ).where((SemanticsProperties p) => p.selected == true),
      hasLength(1),
    );
    expect(_selectedCard(tester), CoupleType.livingTogether);
  });

  testWidgets('AC4: Continue persists the chosen card as its wire value', (
    tester,
  ) async {
    await _useTallSurface(tester);
    final saved = <CoupleType>[];

    await tester.pumpWidget(
      _harness(
        locale: const Locale('vi'),
        createInviteCubit: () => InviteCubit(
          generateInvitation: () async => _invitation(),
          now: () => DateTime.utc(2026, 1, 1),
          saveCoupleType: (CoupleType coupleType) async =>
              saved.add(coupleType),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Cùng thành phố'));
    await tester.pump();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pump();
    await tester.pump();

    expect(saved, <CoupleType>[CoupleType.sameCity]);
    expect(saved.single.wireValue, 'SAME_CITY');
    // STORY-002 owns where Continue goes next; this phase must not navigate.
    expect(find.byType(InviteScreen), findsOneWidget);
    expect(find.byType(WaitingScreen), findsNothing);
  });

  testWidgets('AC5: a persisted couple type is selected on the first paint', (
    tester,
  ) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(
      _harness(
        locale: const Locale('vi'),
        createInviteCubit: () => InviteCubit(
          generateInvitation: () async => _invitation(),
          now: () => DateTime.utc(2026, 1, 1),
          fetchCoupleType: () async => 'LIVING_TOGETHER',
        ),
      ),
    );
    await tester.pump();

    expect(_selectedCard(tester), CoupleType.livingTogether);
    expect(
      tester
          .widget<CupidPrimaryButton>(
            find.widgetWithText(CupidPrimaryButton, 'Tiếp tục'),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('a failed write keeps the selection and offers a retry', (
    tester,
  ) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(
      _harness(
        locale: const Locale('vi'),
        createInviteCubit: () => InviteCubit(
          generateInvitation: () async => _invitation(),
          now: () => DateTime.utc(2026, 1, 1),
          saveCoupleType: (_) async => throw Exception('boom'),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Yêu xa'));
    await tester.pump();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Không thể lưu lựa chọn. Vui lòng thử lại.'),
      findsOneWidget,
    );
    expect(_selectedCard(tester), CoupleType.longDistance);
    expect(
      tester
          .widget<CupidPrimaryButton>(
            find.widgetWithText(CupidPrimaryButton, 'Tiếp tục'),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('AC7: joincode carries no couple-type card', (tester) async {
    await _useTallSurface(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCupidTheme(
          platform: CupidPlatform.material,
          brightness: Brightness.dark,
        ),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        locale: const Locale('vi'),
        home: JoincodeScreen(
          createJoincodeCubit: () =>
              JoincodeCubit(acceptInvitation: (_) async {}),
          router: _stubRouter(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(JoincodeScreen), findsOneWidget);
    expect(find.text('Tụi mình thuộc kiểu nào?'), findsNothing);
    expect(_coupleCardSemantics(tester), isEmpty);
    for (final CoupleType coupleType in CoupleType.values) {
      expect(find.text(coupleType.labelVi), findsNothing);
    }
  });
}
