/// REQ-016 STORY-001 P9 regression guard (`coding-plan/master-plan.md`
/// §8.5, §8.7 rule 3): [PairGateShell] must pin the unpaired root straight to
/// [PairingStatus.unpaired] rather than let [HomeScreen] fall back to its own
/// `getIt<CouplePairingStore>()` resolver. That second, independent status
/// source can answer [PairingStatus.unknown], and `_SoloHomeGateState` maps
/// any non-`unpaired` value onto the couple dashboard — exactly the failure
/// mode this file proves cannot happen, both when the store is entirely
/// unregistered and when it is registered but would answer `unknown`.
library;

import 'dart:typed_data';

import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/database/daos/activity_card_dao.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/navigation/pair_gate_shell.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/data/activity_card_repository_impl.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/presentation/pair_gate_cubit.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Always fails with a connection error, so a [CouplePairingStore] built on
/// top of it resolves to [PairingStatus.unknown] (no cache, network failure).
/// Plugged into [CupidApiClient.create]'s [Dio] the same way
/// `test/core/couple/couple_pairing_store_test.dart` does, rather than a
/// hand-built [CupidApi]: that helper's real interceptor pipeline (auth slot,
/// timeouts) is what makes the failure resolve promptly instead of hanging.
class _AlwaysFailingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Registers the composition-root dependencies the solo surface's
/// `ActivityCardHubView` resolves through `getIt`, backed by an in-memory
/// database — mirrors `test/core/navigation/app_shell_test.dart`'s harness.
void _registerActivityCardRepository() {
  final BackendUserIdStore backendUserIdStore = BackendUserIdStore()
    ..updateFromLoginResponse(<String, Object?>{'id': 'me-1'});
  final CupidDatabase database = CupidDatabase(NativeDatabase.memory());
  getIt.registerSingleton<CupidDatabase>(
    database,
    dispose: (CupidDatabase db) => db.close(),
  );
  getIt.registerSingleton<ActivityCardRepository>(
    ActivityCardRepositoryImpl(
      dao: ActivityCardDao(database),
      ownerKeyStore: backendUserIdStore,
    ),
  );
}

Widget _harness() => MaterialApp(
  theme: buildCupidTheme(platform: CupidPlatform.material, brightness: Brightness.dark),
  localizationsDelegates: AppL10n.localizationsDelegates,
  supportedLocales: AppL10n.supportedLocales,
  home: PairGateShell(
    createPairGateCubit: () => PairGateCubit(
      getPartnerLink: () async => const PartnerLink(partnerId: null),
    ),
  ),
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    _registerActivityCardRepository();
  });

  tearDown(() => getIt.reset());

  testWidgets(
    'unpaired renders the solo surface, never the couple dashboard, when '
    'CouplePairingStore is not registered at all',
    (tester) async {
      expect(getIt.isRegistered<CouplePairingStore>(), isFalse);

      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('solo_stage_one_shell')), findsOneWidget);
      expect(find.byKey(const Key('home_screen_ready_signal')), findsNothing);
    },
  );

  testWidgets(
    'unpaired renders the solo surface, never the couple dashboard, when '
    'CouplePairingStore is registered but resolves to unknown',
    (tester) async {
      final CupidApi api = CupidApiClient.create()
        ..dio.httpClientAdapter = _AlwaysFailingAdapter();
      final BackendUserIdStore backendUserIdStore = BackendUserIdStore()
        ..updateFromLoginResponse(<String, Object?>{'id': 'me-1'});
      final CouplePairingStore store = CouplePairingStore(
        api: api,
        backendUserIdStore: backendUserIdStore,
      );
      getIt.registerSingleton<CouplePairingStore>(store);
      // `runAsync` escapes `testWidgets`'s fake-clock zone: without it, any
      // real Timer inside the interceptor pipeline never fires and this
      // await hangs until the real (not fake) 10-minute test-framework
      // timeout kills it, instead of resolving in milliseconds like the
      // equivalent plain `test()` in `couple_pairing_store_test.dart`.
      final PairingStatus? status = await tester.runAsync(store.resolve);
      expect(status, PairingStatus.unknown);

      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('solo_stage_one_shell')), findsOneWidget);
      expect(find.byKey(const Key('home_screen_ready_signal')), findsNothing);
    },
  );
}
