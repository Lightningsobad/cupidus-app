import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/love_contracts/data/love_contract_repository.dart';
import 'package:cupid_mobile/features/love_contracts/presentation/screens/love_contract_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// REQ-002 STORY-060 AC2: the `contract` screen must show the three ambient
/// twinkle dots the design reference
/// (`design-reference-contract-myunsigned-android.png`) puts over its own
/// opaque card. STORY-056 DEF-1 recorded them as missing, because the shared
/// shell painted them below the Navigator.
const Key _probeKey = Key('love_contract_particle_probe');

/// The source's percentage star positions only land where the design reference
/// puts them on a phone-sized frame.
const Size _surface = Size(390, 844);

Widget _host({required Widget home}) {
  return MaterialApp(
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    // Mirrors the production composition root (`cupid_app.dart:58-59`).
    builder: (BuildContext context, Widget? child) => RepaintBoundary(
      key: _probeKey,
      child: CupidAppBackground(child: child ?? const SizedBox.shrink()),
    ),
    home: CupidPlatformOverride(
      platform: CupidPlatform.material,
      child: home,
    ),
  );
}

/// Reads one pixel of the rasterized [_probeKey] boundary. The caller pins
/// `devicePixelRatio` to 1 so logical coordinates index the image directly.
Future<Color> _probePixel(WidgetTester tester, Offset at) async {
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

  final int offset = (at.dy.round() * imageWidth + at.dx.round()) * 4;
  return Color.fromARGB(
    rgba.getUint8(offset + 3),
    rgba.getUint8(offset),
    rgba.getUint8(offset + 1),
    rgba.getUint8(offset + 2),
  );
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
  testWidgets(
    'AC2: the contract screen paints the three ambient particle dots above '
    'its own card',
    (WidgetTester tester) async {
      tester.view.physicalSize = _surface;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(
          // The in-chain entry renders without `CupidHeader`, so the probe
          // pixel is card surface rather than app-bar chrome.
          home: LoveContractScreen(
            repository: _loveContractRepository(),
            entry: LoveContractEntry.onboardingStep,
          ),
        ),
      );
      // The star ticker never settles, so the load is pumped frame by frame.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(const Key('love_contract_ready')), findsOneWidget);

      // Star 2 is the probe: at this frame size the other two centres sit over
      // the card's own near-white title text and clause rows, so their controls
      // cannot separate "the card is painted here" from "the dot is". Its
      // twinkle peak is at `delay + period / 2` = 800ms + 2300ms.
      await tester.pump(const Duration(milliseconds: 3000));

      final CupidSkyStar star = CupidSkyPalette.stars[1];
      final Offset starCenter = Offset(
        _surface.width - star.rightFactor! * _surface.width - star.size / 2,
        star.topFactor * _surface.height + star.size / 2,
      );

      // At its peak the star is fully opaque, so the pixel is its own token
      // colour rather than a blend with whatever is underneath.
      final Color onStar = await _probePixel(tester, starCenter);
      expect(onStar.r, closeTo(star.color.r, 0.02));
      expect(onStar.g, closeTo(star.color.g, 0.02));
      expect(onStar.b, closeTo(star.color.b, 0.02));

      final Color control = await _probePixel(
        tester,
        starCenter + const Offset(40, 0),
      );
      expect(
        <double>[control.r, control.g, control.b],
        everyElement(lessThan(0.5)),
        reason:
            'the control pixel must be the opaque contract card, otherwise the '
            'dot is sitting on bare backdrop rather than above the card',
      );
    },
  );
}
