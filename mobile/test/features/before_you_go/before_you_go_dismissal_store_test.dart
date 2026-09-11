import 'package:cupid_mobile/features/before_you_go/data/before_you_go_dismissal_store.dart';
import 'package:cupid_mobile/features/before_you_go/domain/before_you_go_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BeforeYouGoDismissalStore store;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    store = BeforeYouGoDismissalStore();
  });

  test('a card that was never closed reads back null', () async {
    expect(await store.dismissedOn('card-1'), isNull);
  });

  test('dismiss stores the civil date under the contract key', () async {
    await store.dismiss('card-1', '2026-09-11');

    expect(await store.dismissedOn('card-1'), '2026-09-11');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getKeys(),
      <String>{'before_you_go.dismissed_on.card-1'},
      reason: 'the key name is the STORY-012 contract, not an implementation '
          'detail; renaming it silently un-dismisses every card in the field',
    );
    expect(
      beforeYouGoDismissedOnKey('card-1'),
      'before_you_go.dismissed_on.card-1',
    );
  });

  test('reopen removes the key rather than blanking it', () async {
    await store.dismiss('card-1', '2026-09-11');
    await store.reopen('card-1');

    expect(await store.dismissedOn('card-1'), isNull);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), isEmpty);
  });

  test('each card carries its own day', () async {
    await store.dismiss('card-1', '2026-09-11');
    await store.dismiss('card-2', '2026-09-12');

    expect(await store.dismissedOn('card-1'), '2026-09-11');
    expect(await store.dismissedOn('card-2'), '2026-09-12');

    await store.reopen('card-1');

    expect(await store.dismissedOn('card-1'), isNull);
    expect(await store.dismissedOn('card-2'), '2026-09-12');
  });

  // The stored value *is* the day it applies to, so no cleanup job has to run:
  // yesterday's key simply stops matching today.
  test('a key written on an earlier day is still readable, and stale',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'before_you_go.dismissed_on.card-1': '2026-09-10',
    });
    store = BeforeYouGoDismissalStore();

    expect(await store.dismissedOn('card-1'), '2026-09-10');
    expect(civilDateIso(DateTime(2026, 9, 11)), isNot('2026-09-10'));
  });

  test('the injected accessor is the only way the store reaches disk',
      () async {
    int opened = 0;
    final BeforeYouGoDismissalStore injected = BeforeYouGoDismissalStore(
      preferences: () async {
        opened += 1;
        return SharedPreferences.getInstance();
      },
    );

    await injected.dismiss('card-9', '2026-09-11');
    await injected.dismissedOn('card-9');

    expect(opened, 2);
  });
}
