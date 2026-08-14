import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cupid_mobile/app/cupid_app.dart';
import 'package:cupid_mobile/core/auth/cupid_auth.dart';
import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/auth/presentation/session_gate_cubit.dart';
import 'package:cupid_mobile/features/chat/data/chat_partner_store.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/presentation/pair_gate_cubit.dart';
import 'package:dio/dio.dart';

/// Fake [HttpClientAdapter] so `ChatEntryGate`'s best-effort
/// `refreshFromServer()` call (`chat_entry_gate.dart:38`) never reaches a
/// real network; mirrors `test/core/navigation/app_shell_test.dart`.
class _FakeHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUp(() async {
    await getIt.reset();
    final dio = Dio()..httpClientAdapter = _FakeHttpClientAdapter();
    getIt.registerSingleton<ChatPartnerStore>(ChatPartnerStore(dio: dio));
    // `HomeScreen` (mounted by `AppShell`'s Home tab) has no override hook
    // for its default `getIt<CouplePairingStore>()` lookup, unlike
    // `AppShell`'s other stores above; register one backed by the same fake
    // adapter so the readiness gate resolves without a real network call.
    getIt.registerSingleton<CouplePairingStore>(
      CouplePairingStore(
        api: CupidApi(dio: dio, interceptors: const []),
        backendUserIdStore: BackendUserIdStore(),
      ),
    );
  });

  tearDown(() => getIt.reset());

  testWidgets('App boots to the home screen ready signal', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      CupidApp(
        // REQ-002 STORY-001 ADR-1: splash is the entry route now, so booting to
        // home means resolving the launch session check first. A real
        // `CupidSession` needs a live/mocked `FirebaseAuth`, hence the seam.
        createSessionGateCubit: () => SessionGateCubit(
          sessionState: Stream<CupidSessionState>.value(
            const CupidSessionSignedIn(uid: 'u1', email: 'a@b.com'),
          ),
          idToken: ({forceRefresh = false}) async => 'token',
        ),
        createPairGateCubit: () => PairGateCubit(
          getPartnerLink: () async => const PartnerLink(partnerId: 'partner-1'),
        ),
      ),
    );
    // `pumpAndSettle` alone cannot clear the splash: its dot animation never
    // settles, so the 2s dwell (AC4) has to be advanced explicitly first.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
  });
}
