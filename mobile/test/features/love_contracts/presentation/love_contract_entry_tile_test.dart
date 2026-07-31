import 'dart:convert';

import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/love_contracts/data/love_contract_gate_repository.dart';
import 'package:cupid_mobile/features/love_contracts/data/love_contract_repository.dart';
import 'package:cupid_mobile/features/love_contracts/presentation/screens/love_contract_screen.dart';
import 'package:cupid_mobile/features/love_contracts/presentation/widgets/love_contract_entry_tile.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// Same scripted-adapter double as the P2/P3 screen tests (injected fakes, no
/// mocking package), duplicated locally since test libraries do not share
/// private helpers across files.
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
    final key = '${options.method} ${options.path}';
    final handler = _handlers[key];
    if (handler == null) {
      throw StateError('No scripted handler for $key');
    }
    return handler(options);
  }
}

ResponseBody _jsonResponse(Object? data, [int statusCode = 200]) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

CupidApi _apiWith(
  Map<String, Future<ResponseBody> Function(RequestOptions)> handlers,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
    ..httpClientAdapter = _ScriptedAdapter(handlers)
    ..interceptors.add(const CupidErrorInterceptor());
  return CupidApi(dio: dio, interceptors: const []);
}

/// A scoped locator so these tests never touch the app's global composition
/// root. `GET /users/me` drives the AC4 gate; `GET /love-contracts/my-pending`
/// is only reached once the tile has navigated.
GetIt _locatorWith(
  Future<ResponseBody> Function(RequestOptions) usersMeHandler,
) {
  final locator = GetIt.asNewInstance();
  locator.registerLazySingleton<LoveContractGateRepository>(
    () => LoveContractGateRepository(_apiWith({'GET /users/me': usersMeHandler})),
  );
  locator.registerLazySingleton<LoveContractRepository>(
    () => LoveContractRepository(
      _apiWith({
        'GET /love-contracts/my-pending': (options) async =>
            _jsonResponse(null),
      }),
    ),
  );
  locator.registerLazySingleton<PartnerDisplayName>(() => () => 'Linh');
  return locator;
}

Widget _harness(GetIt locator) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.light,
    ),
    home: Scaffold(body: LoveContractEntryTile(locator: locator)),
  );
}

final Finder _tile = find.byKey(const Key('love_contract_entry_tile'));

void main() {
  testWidgets('a paired user sees the entry tile', (tester) async {
    final locator = _locatorWith(
      (options) async => _jsonResponse(<String, dynamic>{
        'displayName': 'Minh',
        'partnerId': 'partner-1',
      }),
    );

    await tester.pumpWidget(_harness(locator));
    await tester.pumpAndSettle();

    expect(_tile, findsOneWidget);
    expect(find.text('Love Contract'), findsOneWidget);
  });

  testWidgets('an unpaired user sees no entry tile at all (hide, not '
      'disable)', (tester) async {
    final locator = _locatorWith(
      (options) async => _jsonResponse(<String, dynamic>{
        'displayName': 'Minh',
        'partnerId': null,
      }),
    );

    await tester.pumpWidget(_harness(locator));
    await tester.pumpAndSettle();

    expect(
      _tile,
      findsNothing,
      reason: 'AC4 is hide-not-disable: an unpaired user has no partner to '
          'contract with, so the row must be absent rather than locked.',
    );
  });

  testWidgets('a failed gate fetch hides the entry tile', (tester) async {
    final locator = _locatorWith(
      (options) async => throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      ),
    );

    await tester.pumpWidget(_harness(locator));
    await tester.pumpAndSettle();

    expect(
      _tile,
      findsNothing,
      reason: 'The gate must fail closed — an unresolved pairing state must '
          'never surface the entry point.',
    );
  });

  testWidgets('an unregistered gate repository hides the entry tile', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(GetIt.asNewInstance()));
    await tester.pumpAndSettle();

    expect(_tile, findsNothing);
  });

  testWidgets('tapping the tile opens the love contract screen', (
    tester,
  ) async {
    final locator = _locatorWith(
      (options) async => _jsonResponse(<String, dynamic>{
        'displayName': 'Minh',
        'partnerId': 'partner-1',
      }),
    );

    await tester.pumpWidget(_harness(locator));
    await tester.pumpAndSettle();

    expect(find.byType(LoveContractScreen), findsNothing);

    await tester.tap(_tile);
    await tester.pumpAndSettle();

    expect(
      find.byType(LoveContractScreen),
      findsOneWidget,
      reason: 'The tile is the discoverable surface — direct-route-only '
          'access is not acceptable.',
    );
    expect(find.byKey(const Key('love_contract_ready')), findsOneWidget);
  });

  testWidgets('the opened route re-asserts the gate and pops when the user '
      'is no longer paired', (tester) async {
    var call = 0;
    final locator = _locatorWith((options) async {
      call += 1;
      return _jsonResponse(<String, dynamic>{
        'displayName': 'Minh',
        'partnerId': call == 1 ? 'partner-1' : null,
      });
    });

    await tester.pumpWidget(_harness(locator));
    await tester.pumpAndSettle();

    await tester.tap(_tile);
    await tester.pumpAndSettle();

    expect(
      find.byType(LoveContractScreen),
      findsNothing,
      reason: 'A stale navigation must not show contract UI to a user who is '
          'no longer paired.',
    );
    expect(_tile, findsOneWidget);
  });
}
