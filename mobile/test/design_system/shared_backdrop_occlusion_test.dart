import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/otp_screen.dart';
import 'package:cupid_mobile/features/love_contracts/data/love_contract_repository.dart';
import 'package:cupid_mobile/features/love_contracts/presentation/screens/love_contract_screen.dart';
import 'package:cupid_mobile/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart';
import 'package:cupid_mobile/features/onboarding/presentation/screens/permissions_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/joincode_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/joincode_screen.dart';
import 'package:cupid_mobile/features/vow/presentation/screens/vow_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// REQ-002 STORY-046: per-screen backdrop probes for the 6 screens that used to
/// set an opaque `backgroundColor: colors.colorBackground` on their own
/// `Scaffold`, occluding the shared `CupidAppBackground` sky wash mounted once
/// at `cupid_app.dart:59`.
///
/// Each screen gets two renders of the same probe pixel:
///  - a negative control whose theme forces an opaque `scaffoldBackgroundColor`.
///    Seeing that sentinel proves the probe pixel is the very pixel the removed
///    override used to paint, and that the screen no longer overrides the
///    theme's transparent scaffold fill itself.
///  - the production theme, where the same pixel must read as the sky wash.
const Key _probeKey = Key('shared_backdrop_probe');

/// Under the first dark sky layer's ellipse (center 15%, -8%), so the wash
/// reads distinctly purple against the flat fill. Same rationale as
/// `cupid_app_background_test.dart`'s own wash probe.
const int _probeX = 120;
const int _probeY = 10;

/// Pure green appears in neither the flat fill nor any sky layer, so its green
/// channel alone separates "the Scaffold painted here" from "the wash did".
const Color _scaffoldFillSentinel = Color(0xFF00FF00);

final Color _flatFill = const CupidColorTokens.dark().colorBackground;

Widget _host({required Widget home, Color? scaffoldFill}) {
  final ThemeData theme = buildCupidTheme(
    platform: CupidPlatform.material,
    brightness: Brightness.dark,
  );

  return MaterialApp(
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    theme: scaffoldFill == null
        ? theme
        : theme.copyWith(scaffoldBackgroundColor: scaffoldFill),
    // Mirrors the production composition root: the background is mounted once
    // through `MaterialApp.builder`, not per screen.
    builder: (BuildContext context, Widget? child) => MediaQuery(
      // Parks the star ticker so `pumpAndSettle` terminates.
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: RepaintBoundary(
        key: _probeKey,
        child: CupidAppBackground(child: child ?? const SizedBox.shrink()),
      ),
    ),
    home: CupidPlatformOverride(
      platform: CupidPlatform.material,
      child: home,
    ),
  );
}

Future<Color> _probePixel(WidgetTester tester) async {
  final RenderRepaintBoundary boundary = tester
      .renderObject<RenderRepaintBoundary>(find.byKey(_probeKey));
  late final int imageWidth;
  // Rasterizing needs real async: the fake-async test zone never completes the
  // engine's toImage future.
  final ByteData rgba = (await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage();
    imageWidth = image.width;
    return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  }))!;

  final int offset = (_probeY * imageWidth + _probeX) * 4;
  return Color.fromARGB(
    rgba.getUint8(offset + 3),
    rgba.getUint8(offset),
    rgba.getUint8(offset + 1),
    rgba.getUint8(offset + 2),
  );
}

Future<Color> _renderAndProbe(
  WidgetTester tester,
  Widget Function() screen, {
  Color? scaffoldFill,
  required bool settles,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(_host(home: screen(), scaffoldFill: scaffoldFill));
  if (settles) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }
  return _probePixel(tester);
}

Future<void> _expectSharedBackdropShowsThrough(
  WidgetTester tester,
  Widget Function() screen, {
  /// `vow` runs a perpetual idle animation, so it can only be pumped a fixed
  /// number of frames.
  bool settles = true,
}) async {
  final Color occluded = await _renderAndProbe(
    tester,
    screen,
    scaffoldFill: _scaffoldFillSentinel,
    settles: settles,
  );
  expect(
    occluded.g,
    greaterThan(0.5),
    reason:
        'the probe pixel must be one the screen Scaffold paints, otherwise it '
        'proves nothing about the removed override',
  );

  final Color washed = await _renderAndProbe(
    tester,
    screen,
    settles: settles,
  );
  expect(
    tester
        .widgetList<Scaffold>(find.byType(Scaffold))
        .map((Scaffold scaffold) => scaffold.backgroundColor),
    everyElement(isNull),
    reason: 'no Scaffold may reintroduce a solid backdrop fill',
  );
  expect(washed.g, lessThan(0.2));
  expect(washed, isNot(_flatFill));
  expect(washed.r, greaterThan(_flatFill.r));
  expect(washed.b, greaterThan(_flatFill.b));
}

class _ScriptedAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(<String, dynamic>{
      'id': 'contract-1',
      'requesterId': 'user-1',
      'partnerId': 'user-2',
      'clauses': const <String>['Luôn nói thật'],
      'status': 'created',
      'signedAtRequester': null,
      'signedAtPartner': null,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
      'viewerRole': 'requester',
    }),
    200,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

LoveContractRepository _loveContractRepository() {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
    ..httpClientAdapter = _ScriptedAdapter()
    ..interceptors.add(const CupidErrorInterceptor());
  return LoveContractRepository(
    CupidApi(dio: dio, interceptors: const <Interceptor>[]),
  );
}

void main() {
  testWidgets('AC2: otp shows the shared sky wash, not a solid fill', (
    WidgetTester tester,
  ) async {
    await _expectSharedBackdropShowsThrough(
      tester,
      () => const OtpScreen(email: 'minh@gmail.com'),
    );
  });

  testWidgets('AC3: contract shows the shared sky wash, not a solid fill', (
    WidgetTester tester,
  ) async {
    await _expectSharedBackdropShowsThrough(
      tester,
      // The in-chain entry is the header-less one, so the probe pixel is
      // backdrop rather than app-bar chrome.
      () => LoveContractScreen(
        repository: _loveContractRepository(),
        entry: LoveContractEntry.onboardingStep,
      ),
    );
  });

  testWidgets('AC4: profile setup shows the shared sky wash, not a solid fill', (
    WidgetTester tester,
  ) async {
    await _expectSharedBackdropShowsThrough(
      tester,
      () => OnboardingProfileSetupScreen(
        profile: CupidProfile(
          id: 'user-1',
          email: 'linh@example.com',
          language: 'vi',
          vowTaken: false,
          isGhostModeEnabled: true,
          displayName: 'Linh',
          birthday: DateTime(2001, 3, 3),
        ),
        onContinue: () {},
      ),
    );
  });

  testWidgets('AC5: permissions shows the shared sky wash, not a solid fill', (
    WidgetTester tester,
  ) async {
    await _expectSharedBackdropShowsThrough(
      tester,
      () => const PermissionsScreen(),
    );
  });

  testWidgets('AC6: joincode shows the shared sky wash, not a solid fill', (
    WidgetTester tester,
  ) async {
    await _expectSharedBackdropShowsThrough(
      tester,
      () => JoincodeScreen(
        createJoincodeCubit: () =>
            JoincodeCubit(acceptInvitation: (_) async {}),
      ),
    );
  });

  testWidgets('AC7: vow shows the shared sky wash, not a solid fill', (
    WidgetTester tester,
  ) async {
    await _expectSharedBackdropShowsThrough(
      tester,
      () => const VowScreen(selfInitial: 'M', partnerInitial: 'L'),
      settles: false,
    );
  });
}
