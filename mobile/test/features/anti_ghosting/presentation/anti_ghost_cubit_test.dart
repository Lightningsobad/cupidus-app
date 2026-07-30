import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/anti_ghosting/data/ghost_config_models.dart';
import 'package:cupid_mobile/features/anti_ghosting/data/ghost_config_repository.dart';
import 'package:cupid_mobile/features/anti_ghosting/presentation/anti_ghost_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hand-written fake transport (no `mocktail`/`bloc_test`, neither is a
/// dependency), mirroring `ghost_config_repository_test.dart`'s
/// `_FakeHttpClientAdapter`. Unlike that repository-level test, this fake is
/// wired behind [CupidErrorInterceptor] so `DioException.error` carries a
/// [CupidApiFailure], exactly as production `CupidApiClient.create` wires it
/// (`cupid_api_client.dart`).
class _FakeHttpClientAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  final List<_QueuedResponse Function(RequestOptions)> _queue = [];

  void queueJson(Object? body, {int statusCode = 200}) {
    _queue.add((_) => _QueuedResponse(jsonEncode(body), statusCode, asJson: true));
  }

  void queueStatus(int statusCode) {
    _queue.add((_) => _QueuedResponse('', statusCode, asJson: false));
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final queued = _queue.isNotEmpty ? _queue.removeAt(0)(options) : const _QueuedResponse('{}', 200, asJson: true);
    if (queued.statusCode >= 400) {
      throw DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: queued.statusCode,
          data: queued.asJson ? jsonDecode(queued.body) : queued.body,
        ),
        type: DioExceptionType.badResponse,
      );
    }
    return ResponseBody.fromString(
      queued.body,
      queued.statusCode,
      headers: queued.asJson
          ? {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            }
          : {},
    );
  }

  @override
  void close({bool force = false}) {}
}

class _QueuedResponse {
  const _QueuedResponse(this.body, this.statusCode, {required this.asJson});

  final String body;
  final int statusCode;
  final bool asJson;
}

void main() {
  late _FakeHttpClientAdapter adapter;
  late GhostConfigRepository repository;
  late BackendUserIdStore backendUserIdStore;

  Map<String, Object?> configJson({
    String id = 'config-1',
    int timeoutMinutes = 10,
    String penalty = 'emoji_storm',
    String proposedBy = 'user-a',
    String status = 'pending_approval',
  }) {
    return {
      'id': id,
      'coupleId': 'a:b',
      'timeoutMinutes': timeoutMinutes,
      'penalty': penalty,
      'proposedBy': proposedBy,
      'approvedBy': null,
      'status': status,
      'createdAt': '2026-07-30T00:00:00.000Z',
      'updatedAt': '2026-07-30T00:00:00.000Z',
    };
  }

  setUp(() {
    adapter = _FakeHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
      ..httpClientAdapter = adapter
      ..interceptors.add(const CupidErrorInterceptor());
    repository = GhostConfigRepository(api: CupidApi(dio: dio, interceptors: const []));
    backendUserIdStore = BackendUserIdStore();
  });

  AntiGhostCubit buildCubit() {
    return AntiGhostCubit(repository: repository, backendUserIdStore: backendUserIdStore);
  }

  // A single zero-delay Future only flushes one macrotask turn; Dio's
  // interceptor chain (error interceptor, adapter round-trip) needs several,
  // so loop a handful of zero-delay turns rather than one.
  Future<void> pumpMicrotasks() async {
    for (var i = 0; i < 100; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  group('AntiGhostCubit.load', () {
    test('State D: emits AntiGhostActiveConfig when an active config exists', () async {
      adapter.queueJson(configJson(status: 'active'));
      final cubit = buildCubit();

      await pumpMicrotasks();

      final state = cubit.state;
      expect(state, isA<AntiGhostLoaded>());
      expect((state as AntiGhostLoaded).lifecycle, isA<AntiGhostActiveConfig>());
      await cubit.close();
    });

    test('State A: emits AntiGhostNoConfig when nothing active or pending', () async {
      adapter.queueJson(null); // fetchActive -> null
      adapter.queueJson(<Object?>[]); // fetchPending -> []
      final cubit = buildCubit();

      await pumpMicrotasks();

      final state = cubit.state as AntiGhostLoaded;
      expect(state.lifecycle, isA<AntiGhostNoConfig>());
      await cubit.close();
    });

    test('State B: pending config proposed by the signed-in user', () async {
      backendUserIdStore.updateFromLoginResponse({'id': 'user-a'});
      adapter.queueJson(null);
      adapter.queueJson([configJson(proposedBy: 'user-a')]);
      final cubit = buildCubit();

      await pumpMicrotasks();

      final state = cubit.state as AntiGhostLoaded;
      expect(state.lifecycle, isA<AntiGhostPendingMine>());
      await cubit.close();
    });

    test('State C: pending config proposed by the partner', () async {
      backendUserIdStore.updateFromLoginResponse({'id': 'user-a'});
      adapter.queueJson(null);
      adapter.queueJson([configJson(proposedBy: 'user-b')]);
      final cubit = buildCubit();

      await pumpMicrotasks();

      final state = cubit.state as AntiGhostLoaded;
      expect(state.lifecycle, isA<AntiGhostPendingPartner>());
      await cubit.close();
    });

    test('unknown role: pending config resolved before backendUserId is known', () async {
      adapter.queueJson(null);
      adapter.queueJson([configJson(proposedBy: 'user-a')]);
      final cubit = buildCubit();

      await pumpMicrotasks();

      final state = cubit.state as AntiGhostLoaded;
      expect(state.lifecycle, isA<AntiGhostPendingUnknownRole>());
      await cubit.close();
    });

    test('AC3: a 400 on the initial fetch emits AntiGhostPairingRequired', () async {
      adapter.queueStatus(400);
      final cubit = buildCubit();

      await pumpMicrotasks();

      expect(cubit.state, isA<AntiGhostPairingRequired>());
      await cubit.close();
    });

    test('a non-400 failure emits AntiGhostLoadFailed', () async {
      adapter.queueStatus(500);
      final cubit = buildCubit();

      await pumpMicrotasks();

      expect(cubit.state, isA<AntiGhostLoadFailed>());
      await cubit.close();
    });
  });

  group('AntiGhostCubit.propose', () {
    test('reloads from the server after a successful propose', () async {
      adapter.queueJson(null);
      adapter.queueJson(<Object?>[]);
      final cubit = buildCubit();
      await pumpMicrotasks();

      adapter.queueJson(configJson());
      adapter.queueJson(configJson(status: 'active'));
      await cubit.propose(timeoutMinutes: 10, penalty: Penalty.emojiStorm);
      await pumpMicrotasks();

      expect(adapter.requests.map((r) => '${r.method} ${r.path}'), [
        'GET /ghost-config',
        'GET /ghost-config/pending',
        'POST /ghost-config',
        'GET /ghost-config',
      ]);
      final state = cubit.state as AntiGhostLoaded;
      expect(state.lifecycle, isA<AntiGhostActiveConfig>());
      expect(state.isSubmitting, isFalse);
      await cubit.close();
    });

    test('a double-tap while submitting issues exactly one POST', () async {
      adapter.queueJson(null);
      adapter.queueJson(<Object?>[]);
      final cubit = buildCubit();
      await pumpMicrotasks();

      adapter.queueJson(configJson());
      adapter.queueJson(configJson(status: 'active'));
      final first = cubit.propose(timeoutMinutes: 10, penalty: Penalty.emojiStorm);
      final second = cubit.propose(timeoutMinutes: 15, penalty: Penalty.noise);
      await Future.wait([first, second]);
      await pumpMicrotasks();

      final postRequests = adapter.requests.where((r) => r.method == 'POST');
      expect(postRequests, hasLength(1));
      await cubit.close();
    });

    test('a stale 400 during propose reloads silently instead of surfacing an error', () async {
      adapter.queueJson(null);
      adapter.queueJson(<Object?>[]);
      final cubit = buildCubit();
      await pumpMicrotasks();

      adapter.queueStatus(400);
      adapter.queueJson(configJson(status: 'active'));
      await cubit.propose(timeoutMinutes: 10, penalty: Penalty.emojiStorm);
      await pumpMicrotasks();

      final state = cubit.state as AntiGhostLoaded;
      expect(state.lifecycle, isA<AntiGhostActiveConfig>());
      expect(state.actionFailure, isNull);
      await cubit.close();
    });

    test('a non-400 failure during propose surfaces actionFailure and clears isSubmitting', () async {
      adapter.queueJson(null);
      adapter.queueJson(<Object?>[]);
      final cubit = buildCubit();
      await pumpMicrotasks();

      adapter.queueStatus(500);
      await cubit.propose(timeoutMinutes: 10, penalty: Penalty.emojiStorm);
      await pumpMicrotasks();

      final state = cubit.state as AntiGhostLoaded;
      expect(state.actionFailure, isNotNull);
      expect(state.isSubmitting, isFalse);
      expect(state.lifecycle, isA<AntiGhostNoConfig>());
      await cubit.close();
    });
  });

  group('AntiGhostCubit.approve / reject', () {
    test('approve issues exactly one PATCH and reloads', () async {
      backendUserIdStore.updateFromLoginResponse({'id': 'user-a'});
      adapter.queueJson(null);
      adapter.queueJson([configJson(id: 'config-9', proposedBy: 'user-b')]);
      final cubit = buildCubit();
      await pumpMicrotasks();

      adapter.queueJson(configJson(id: 'config-9', status: 'active'));
      adapter.queueJson(configJson(id: 'config-9', status: 'active'));
      await cubit.approve('config-9');
      await pumpMicrotasks();

      final patchRequests = adapter.requests.where((r) => r.method == 'PATCH');
      expect(patchRequests, hasLength(1));
      expect(patchRequests.single.path, '/ghost-config/config-9/approve');
      final state = cubit.state as AntiGhostLoaded;
      expect(state.lifecycle, isA<AntiGhostActiveConfig>());
      await cubit.close();
    });

    test('reject issues exactly one PATCH and reloads', () async {
      backendUserIdStore.updateFromLoginResponse({'id': 'user-a'});
      adapter.queueJson(null);
      adapter.queueJson([configJson(id: 'config-9', proposedBy: 'user-b')]);
      final cubit = buildCubit();
      await pumpMicrotasks();

      adapter.queueJson(configJson(id: 'config-9', status: 'rejected'));
      adapter.queueJson(null);
      adapter.queueJson(<Object?>[]);
      await cubit.reject('config-9');
      await pumpMicrotasks();

      final patchRequests = adapter.requests.where((r) => r.method == 'PATCH');
      expect(patchRequests, hasLength(1));
      expect(patchRequests.single.path, '/ghost-config/config-9/reject');
      final state = cubit.state as AntiGhostLoaded;
      expect(state.lifecycle, isA<AntiGhostNoConfig>());
      await cubit.close();
    });
  });
}
