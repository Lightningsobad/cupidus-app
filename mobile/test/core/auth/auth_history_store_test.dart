import 'package:cupid_mobile/core/auth/auth_history_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('reports no previous session on a fresh install', () async {
    final store = AuthHistoryStore();

    expect(await store.hasPreviousSession(), isFalse);
    expect(await store.lastEmail(), isNull);
  });

  test('markAuthenticated records the marker and the prefill email', () async {
    final store = AuthHistoryStore();

    await store.markAuthenticated(email: 'alice@example.com');

    expect(await store.hasPreviousSession(), isTrue);
    expect(await store.lastEmail(), 'alice@example.com');
  });

  test('markAuthenticated without an email drops a stale address', () async {
    final store = AuthHistoryStore();
    await store.markAuthenticated(email: 'alice@example.com');

    await store.markAuthenticated();

    expect(await store.hasPreviousSession(), isTrue);
    expect(await store.lastEmail(), isNull);
  });

  test('clearOnSignOut resets the device to the never-signed-in state',
      () async {
    final store = AuthHistoryStore();
    await store.markAuthenticated(email: 'alice@example.com');

    await store.clearOnSignOut();

    expect(await store.hasPreviousSession(), isFalse);
    expect(await store.lastEmail(), isNull);
  });

  test('persists under the auth. key namespace', () async {
    await AuthHistoryStore().markAuthenticated(email: 'alice@example.com');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('auth.has_previous_session_v1'), isTrue);
    expect(prefs.getString('auth.last_email_v1'), 'alice@example.com');
  });

  test('reads and writes through the injected preferences seam', () async {
    var calls = 0;
    final store = AuthHistoryStore(
      preferences: () async {
        calls++;
        return SharedPreferences.getInstance();
      },
    );

    await store.markAuthenticated(email: 'alice@example.com');
    expect(await store.hasPreviousSession(), isTrue);
    expect(calls, greaterThan(1));
  });
}
