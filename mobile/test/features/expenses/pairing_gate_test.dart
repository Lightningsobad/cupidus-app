import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/expenses/data/pairing_state_reader.dart';
import 'package:cupid_mobile/features/expenses/presentation/expense_strings.dart';
import 'package:cupid_mobile/features/expenses/presentation/widgets/pairing_required_gate.dart';
import 'package:cupid_mobile/features/pairing/data/pairing_invitation.dart';
import 'package:cupid_mobile/features/pairing/data/pairing_repository.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/invite_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stubs the transport layer beneath [CupidApiClient.create], matching
/// `couple_pairing_store_test.dart`'s convention (real interceptor pipeline,
/// no live network call, no mocking package dependency).
class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => _handler(options);
}

ResponseBody _jsonResponse(Object? body, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

CupidApi _apiWithHandler(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final api = CupidApiClient.create();
  api.dio.httpClientAdapter = _FakeHttpClientAdapter(handler);
  return api;
}

BackendUserIdStore _backendUserIdStore(String id) =>
    BackendUserIdStore()..updateFromLoginResponse({'id': id});

/// Never resolves, matching `home_screen_test.dart`'s `_NoOpDreamJarRepository`
/// precedent for a getIt-registered dependency that a test's widget tree
/// reaches for but never needs to complete: [InviteCubit] always fires
/// [generateInvitation] on construction (`invite_cubit.dart`), so this keeps
/// `InviteScreen` in its initial loading state without a live network call.
class _NeverReadyPairingRepository extends PairingRepository {
  _NeverReadyPairingRepository() : super(api: CupidApiClient.create());

  @override
  Future<PairingInvitation> generateInvitation() =>
      Completer<PairingInvitation>().future;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('PairingStateReader.isPaired (ADR-015.7)', () {
    test('true when CouplePairingStore resolves paired', () async {
      final store = CouplePairingStore(
        api: _apiWithHandler(
          (options) async =>
              _jsonResponse({'id': 'user-1', 'partnerId': 'user-2'}, 200),
        ),
        backendUserIdStore: _backendUserIdStore('user-1'),
      );
      final reader = PairingStateReader(pairingStore: store);

      expect(await reader.isPaired(), isTrue);
    });

    test('false when CouplePairingStore resolves unpaired', () async {
      final store = CouplePairingStore(
        api: _apiWithHandler(
          (options) async => _jsonResponse({'id': 'user-1'}, 200),
        ),
        backendUserIdStore: _backendUserIdStore('user-1'),
      );
      final reader = PairingStateReader(pairingStore: store);

      expect(await reader.isPaired(), isFalse);
    });

    test(
      'false (never optimistic) when CouplePairingStore cannot confirm a '
      'status',
      () async {
        final store = CouplePairingStore(
          api: _apiWithHandler(
            (options) async => throw DioException(
              requestOptions: options,
              error: const UnexpectedFailure(),
            ),
          ),
          backendUserIdStore: _backendUserIdStore('user-1'),
        );
        final reader = PairingStateReader(pairingStore: store);

        expect(await reader.isPaired(), isFalse);
      },
    );
  });

  group('PairingRequiredGate (ux/uiux-spec.md §6)', () {
    setUp(() {
      getIt.registerLazySingleton<PairingRepository>(
        _NeverReadyPairingRepository.new,
      );
    });

    tearDown(() => getIt.reset());

    Widget harness() {
      return MaterialApp(
        theme: buildCupidTheme(
          platform: CupidPlatform.material,
          brightness: Brightness.dark,
        ),
        locale: const Locale('en'),
        home: const PairingRequiredGate(),
      );
    }

    testWidgets(
      'shows the dedicated pairing-required message and action, never a '
      'generic error or empty state',
      (tester) async {
        await tester.pumpWidget(harness());

        expect(
          find.text(
            ExpenseStrings.pairingGateMessage(
              tester.element(find.byType(PairingRequiredGate)),
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.text(
            ExpenseStrings.pairingGateActionLabel(
              tester.element(find.byType(PairingRequiredGate)),
            ),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('tapping the primary action navigates into InviteScreen', (
      tester,
    ) async {
      await tester.pumpWidget(harness());

      await tester.tap(
        find.text(
          ExpenseStrings.pairingGateActionLabel(
            tester.element(find.byType(PairingRequiredGate)),
          ),
        ),
      );
      // InviteScreen's loading state renders a CircularProgressIndicator,
      // whose implicit repeating animation never settles while
      // `_NeverReadyPairingRepository.generateInvitation` stays unresolved --
      // pumpAndSettle would time out here. Pump one frame for the tap, then a
      // bounded duration to let the MaterialPageRoute push transition finish.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(InviteScreen), findsOneWidget);
    });
  });
}
