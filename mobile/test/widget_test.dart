import 'dart:typed_data';

import 'package:cupid_mobile/app/cupid_app.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/features/chat/data/chat_partner_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
  });

  tearDown(() => getIt.reset());

  testWidgets('App boots to the home screen ready signal', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CupidApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
  });
}
