import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/data/account_repository.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:cupid_mobile/features/account/presentation/screens/profile_edit_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Handler = ResponseBody Function(RequestOptions options, String? body);

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final _Handler handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => handler(options, null);

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(Map<String, dynamic> json, {int statusCode = 200}) {
  return ResponseBody.fromBytes(
    utf8.encode(jsonEncode(json)),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

AccountRepository _repository(_Handler handler) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
  dio.httpClientAdapter = _FakeAdapter(handler);
  dio.interceptors.add(const CupidErrorInterceptor());
  return AccountRepository(api: CupidApi(dio: dio, interceptors: const []));
}

final CupidProfile _profile = CupidProfile(
  id: 'user-1',
  email: 'alex@example.com',
  language: 'vi',
  vowTaken: false,
  isGhostModeEnabled: true,
  displayName: 'Alex',
  birthday: DateTime(1996, 5, 15),
  zodiacSign: 'Taurus',
);

Widget _harness(
  AccountRepository repository, {
  Locale locale = const Locale('en'),
  CupidProfile? profile,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: ProfileEditScreen(
      accountRepository: repository,
      profile: profile ?? _profile,
    ),
  );
}

/// The avatar slot is the only circular [BoxDecoration] sized to the design
/// source's 104px; the camera badge is the 36px one.
BoxDecoration _circleDecorationOfSize(WidgetTester tester, double diameter) {
  final Container container = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(Stack),
          matching: find.byWidgetPredicate(
            (Widget widget) =>
                widget is Container &&
                widget.constraints?.maxWidth == diameter &&
                widget.constraints?.maxHeight == diameter,
          ),
        )
        .first,
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  group('ProfileEditScreen', () {
    testWidgets('renders fields populated from the initial profile', (tester) async {
      final repository = _repository((options, body) => _jsonBody({}));

      await tester.pumpWidget(_harness(repository));

      expect(find.text('Alex'), findsOneWidget);
      expect(find.text('15/05/1996'), findsOneWidget);
      expect(find.text('Taurus'), findsOneWidget);
    });

    testWidgets('Save is disabled until the draft becomes dirty', (tester) async {
      final repository = _repository((options, body) => _jsonBody({}));

      await tester.pumpWidget(_harness(repository));

      final TextButton saveButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Save'),
      );
      expect(saveButton.onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'Alexandra');
      await tester.pump();

      final TextButton dirtySaveButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Save'),
      );
      expect(dirtySaveButton.onPressed, isNotNull);
    });

    testWidgets('shows an inline error and blocks submit when the name is cleared', (
      tester,
    ) async {
      var patchCalls = 0;
      final repository = _repository((options, body) {
        if (options.method == 'PATCH') patchCalls++;
        return _jsonBody({});
      });

      await tester.pumpWidget(_harness(repository));

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Display name is required'), findsOneWidget);
      expect(patchCalls, 0);
    });
  });

  group('STORY-010 design fidelity against the `profile` canvas', () {
    testWidgets('avatar slot is a 104px circle carrying the elevation shadow', (
      tester,
    ) async {
      final repository = _repository((options, body) => _jsonBody({}));

      await tester.pumpWidget(_harness(repository));

      final BoxDecoration decoration = _circleDecorationOfSize(tester, 104);
      expect(decoration.shape, BoxShape.circle);
      expect(
        decoration.boxShadow,
        const CupidPlatformTokens.material().elevationShadow,
      );
    });

    testWidgets('camera badge is a 36px gradient circle ringed in the '
        'background color and hidden from a11y', (tester) async {
      final repository = _repository((options, body) => _jsonBody({}));

      await tester.pumpWidget(_harness(repository));

      final BoxDecoration decoration = _circleDecorationOfSize(tester, 36);
      const CupidColorTokens colors = CupidColorTokens.dark();
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.gradient, colors.gradientHot);
      expect(decoration.boxShadow, colors.glowShadow);
      expect(decoration.border!.top.width, 3);
      expect(decoration.border!.top.color, colors.colorBackground);
      expect(
        find.descendant(
          of: find.byType(ExcludeSemantics),
          matching: find.byType(CupidIcon),
        ),
        findsOneWidget,
      );
    });

    testWidgets('crop caption renders in the active locale', (tester) async {
      final repository = _repository((options, body) => _jsonBody({}));

      await tester.pumpWidget(
        _harness(repository, locale: const Locale('vi')),
      );
      expect(find.text('Ảnh sẽ được crop tròn'), findsOneWidget);

      await tester.pumpWidget(_harness(repository));
      expect(find.text('Photo is cropped to a circle'), findsOneWidget);
    });

    testWidgets('zodiac chip is a pill in the primary text color, not a '
        'mono accent tag', (tester) async {
      final repository = _repository((options, body) => _jsonBody({}));

      await tester.pumpWidget(_harness(repository));

      final Container chip = tester.widget<Container>(
        find.ancestor(
          of: find.text('Taurus'),
          matching: find.byType(Container),
        ).first,
      );
      final BoxDecoration decoration = chip.decoration! as BoxDecoration;
      expect(
        decoration.borderRadius,
        BorderRadius.circular(
          const CupidPlatformTokens.material().radiusButton,
        ),
      );

      final Text chipText = tester.widget<Text>(find.text('Taurus'));
      expect(chipText.style!.color, const CupidColorTokens.dark().colorText);
      expect(chipText.style!.fontWeight, FontWeight.w700);
      expect(
        chipText.style!.fontFamily,
        isNot(CupidTypographyTokens.forPlatform(
          CupidPlatform.material,
        ).labelMono.fontFamily),
      );
    });

    testWidgets('zodiac helper sits inside the date-of-birth card', (
      tester,
    ) async {
      final repository = _repository((options, body) => _jsonBody({}));

      await tester.pumpWidget(_harness(repository));

      expect(
        find.ancestor(
          of: find.text(
            'Zodiac is auto-derived — powers Zodiac Red Flag',
          ),
          matching: find.widgetWithText(InkWell, 'DATE OF BIRTH'),
        ),
        findsOneWidget,
      );
    });
  });
}
