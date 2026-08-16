import 'dart:convert';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/love_contracts/data/love_contract_repository.dart';
import 'package:cupid_mobile/features/love_contracts/presentation/screens/love_contract_screen.dart';
import 'package:cupid_mobile/features/love_contracts/presentation/widgets/hold_to_sign_button.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// STORY-015 design fidelity: the enabled dark theme + `vi` locale rendering
/// of the `contract` screen against `cupid-app-design-system`
/// (`project/Cupid Screens.dc.html`, `isContract` block).
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._handlers);

  final Map<String, Future<ResponseBody> Function(RequestOptions)> _handlers;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    final handler = _handlers['${options.method} ${options.path}'];
    if (handler == null) {
      throw StateError('No scripted handler for ${options.path}');
    }
    return handler(options);
  }
}

ResponseBody _jsonResponse(Object? data) => ResponseBody.fromString(
  jsonEncode(data),
  200,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

LoveContractRepository _repositoryWith(Map<String, dynamic> contract) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
    ..httpClientAdapter = _ScriptedAdapter({
      'GET /love-contracts/my-pending': (_) async => _jsonResponse(contract),
    })
    ..interceptors.add(const CupidErrorInterceptor());
  return LoveContractRepository(CupidApi(dio: dio, interceptors: const []));
}

Map<String, dynamic> _contract({
  required String viewerRole,
  String? signedAtRequester,
  String? signedAtPartner,
}) => <String, dynamic>{
  'id': 'contract-1',
  'requesterId': 'user-1',
  'partnerId': 'user-2',
  'clauses': const <String>['Luôn nói thật'],
  'status': 'created',
  'signedAtRequester': signedAtRequester,
  'signedAtPartner': signedAtPartner,
  'createdAt': '2026-01-01T00:00:00.000Z',
  'updatedAt': '2026-01-01T00:00:00.000Z',
  'viewerRole': viewerRole,
};

Widget _harness(LoveContractRepository repository) => MaterialApp(
  locale: const Locale('vi'),
  localizationsDelegates: AppL10n.localizationsDelegates,
  supportedLocales: AppL10n.supportedLocales,
  theme: buildCupidTheme(
    platform: CupidPlatform.material,
    brightness: Brightness.dark,
  ),
  home: LoveContractScreen(repository: repository),
);

CupidColorTokens _colorsOf(WidgetTester tester) =>
    tester.element(find.byKey(const Key('love_contract_ready'))).cupidColors;

Future<void> _pumpState(
  WidgetTester tester, {
  String? signedAtRequester,
  String? signedAtPartner,
}) async {
  await tester.pumpWidget(
    _harness(
      _repositoryWith(
        _contract(
          viewerRole: 'requester',
          signedAtRequester: signedAtRequester,
          signedAtPartner: signedAtPartner,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'the contract header renders the sequence label with the design source '
    'mono treatment (uppercase, 10px, .18em tracking, pink)',
    (tester) async {
      await _pumpState(tester);

      final Text label = tester.widget<Text>(find.text('BẢN CAM KẾT SỐ 001'));
      expect(label.style!.fontFamily, 'Roboto Mono');
      expect(label.style!.fontSize, 10);
      expect(label.style!.letterSpacing, 1.8);
      expect(label.style!.color, _colorsOf(tester).colorAccentPink);
    },
  );

  testWidgets('clause ids keep the mono type treatment (AC4)', (tester) async {
    await _pumpState(tester);

    final Text clauseId = tester.widget<Text>(find.text('§1'));
    expect(clauseId.style!.fontFamily, 'Roboto Mono');
    expect(clauseId.style!.color, _colorsOf(tester).colorTextMuted);
  });

  testWidgets(
    'the add-clause affordance renders a single leading plus, not the '
    'localized plus plus a duplicate add icon',
    (tester) async {
      await _pumpState(tester);

      expect(find.text('+ Thêm điều khoản riêng'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('love_contract_add_clause_button')),
          matching: find.byIcon(CupidIcons.add),
        ),
        findsNothing,
      );
    },
  );

  testWidgets('the footer lock note pairs the mint lock glyph with the note', (
    tester,
  ) async {
    await _pumpState(tester);

    final Icon lock = tester.widget<Icon>(find.byIcon(CupidIcons.lock));
    expect(lock.color, _colorsOf(tester).colorMint);
    expect(
      find.text('Bản hợp đồng lưu ở Level 2 — mã hoá đầu-cuối'),
      findsOneWidget,
    );
  });

  testWidgets('unsigned state shows the sign caption above the hold control', (
    tester,
  ) async {
    await _pumpState(tester);

    expect(find.byKey(const Key('love_contract_signed_card')), findsNothing);
    expect(find.byType(HoldToSignButton), findsOneWidget);
    expect(
      find.text('Giữ ngón tay để ký — cam kết thì phải nặng tay một chút'),
      findsOneWidget,
    );
  });

  testWidgets(
    'self-signed state renders the signed card with the design source green '
    'tint, 40% green hairline, card radius and 64px minimum height',
    (tester) async {
      await _pumpState(tester, signedAtRequester: '2026-01-02T00:00:00.000Z');

      final CupidColorTokens colors = _colorsOf(tester);
      final CupidPlatformTokens platform = tester
          .element(find.byKey(const Key('love_contract_ready')))
          .cupidPlatform;
      final Container card = tester.widget<Container>(
        find.byKey(const Key('love_contract_signed_card')),
      );
      final BoxDecoration decoration = card.decoration! as BoxDecoration;

      expect(decoration.color, colors.colorGreen.withValues(alpha: 0.12));
      expect(
        (decoration.border! as Border).top.color,
        colors.colorGreen.withValues(alpha: 0.4),
      );
      expect(
        decoration.borderRadius,
        BorderRadius.circular(platform.radiusCard),
      );
      expect(card.constraints!.minHeight, 64);

      final Text heading = tester.widget<Text>(find.text('Bạn đã ký'));
      expect(heading.style!.color, colors.colorGreen);
      expect(heading.style!.fontWeight, FontWeight.w700);
      expect(find.text('Đang chờ đối tác ký'), findsOneWidget);
    },
  );

  testWidgets(
    'both-signed state reuses the same signed-card treatment and swaps only '
    'the status line',
    (tester) async {
      await _pumpState(
        tester,
        signedAtRequester: '2026-01-02T00:00:00.000Z',
        signedAtPartner: '2026-01-03T00:00:00.000Z',
      );

      final CupidColorTokens colors = _colorsOf(tester);
      final Container card = tester.widget<Container>(
        find.byKey(const Key('love_contract_signed_card')),
      );
      final BoxDecoration decoration = card.decoration! as BoxDecoration;

      expect(decoration.color, colors.colorGreen.withValues(alpha: 0.12));
      expect(find.text('Bạn đã ký'), findsOneWidget);
      expect(find.text('Cả hai đã ký'), findsOneWidget);
      expect(find.byType(HoldToSignButton), findsNothing);

      final Icon check = tester.widget<Icon>(find.byIcon(CupidIcons.check));
      expect(check.color, colors.colorGreen);
      expect(check.size, 18);
    },
  );
}
