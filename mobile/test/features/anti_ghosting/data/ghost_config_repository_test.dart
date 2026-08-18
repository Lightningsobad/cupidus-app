import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/anti_ghosting/data/ghost_config_models.dart';
import 'package:cupid_mobile/features/anti_ghosting/data/ghost_config_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hand-written fake transport (no `mocktail`, which is not a dependency):
/// captures every outgoing [RequestOptions] and replays one queued canned
/// response, mirroring `SyncTransformer`'s JSON-decoding rules so tests can
/// assert on the same `response.data` shapes the repository sees in
/// production.
class _FakeHttpClientAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  Object? _queuedBody = const <String, Object?>{};
  int _queuedStatus = 200;
  bool _queuedAsJson = true;

  void queueJson(Object? body, {int statusCode = 200}) {
    _queuedBody = body;
    _queuedStatus = statusCode;
    _queuedAsJson = true;
  }

  /// Simulates a genuinely empty response body with no JSON content-type,
  /// as distinct from an explicit JSON `null`.
  void queueEmptyBody({int statusCode = 200}) {
    _queuedBody = '';
    _queuedStatus = statusCode;
    _queuedAsJson = false;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final text = _queuedAsJson ? jsonEncode(_queuedBody) : _queuedBody as String;
    return ResponseBody.fromString(
      text,
      _queuedStatus,
      headers: _queuedAsJson
          ? {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            }
          : {},
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _FakeHttpClientAdapter adapter;
  late GhostConfigRepository repository;

  Map<String, Object?> configJson({
    String id = 'config-1',
    String coupleId = 'a:b',
    int timeoutMinutes = 10,
    String penalty = 'emoji_storm',
    String proposedBy = 'user-a',
    String? approvedBy,
    String status = 'pending_approval',
  }) {
    return {
      'id': id,
      'coupleId': coupleId,
      'timeoutMinutes': timeoutMinutes,
      'penalty': penalty,
      'proposedBy': proposedBy,
      'approvedBy': approvedBy,
      'status': status,
      'createdAt': '2026-07-30T00:00:00.000Z',
      'updatedAt': '2026-07-30T00:00:00.000Z',
    };
  }

  setUp(() {
    adapter = _FakeHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
      ..httpClientAdapter = adapter;
    repository = GhostConfigRepository(
      api: CupidApi(dio: dio, interceptors: const []),
    );
  });

  group('GhostConfigRepository.fetchActive', () {
    test('issues GET /ghost-config and parses the active config', () async {
      adapter.queueJson(configJson(status: 'active'));

      final config = await repository.fetchActive();

      expect(adapter.requests, hasLength(1));
      expect(adapter.requests.single.method, 'GET');
      expect(adapter.requests.single.path, '/ghost-config');
      expect(config, isNotNull);
      expect(config!.id, 'config-1');
      expect(config.status, ConfigStatus.active);
    });

    test('returns null for a JSON null body', () async {
      adapter.queueJson(null);

      expect(await repository.fetchActive(), isNull);
    });

    test('returns null for a genuinely empty body', () async {
      adapter.queueEmptyBody();

      expect(await repository.fetchActive(), isNull);
    });
  });

  group('GhostConfigRepository.fetchPending', () {
    test('issues GET /ghost-config/pending and parses the array', () async {
      adapter.queueJson([configJson(id: 'p1'), configJson(id: 'p2')]);

      final pending = await repository.fetchPending();

      expect(adapter.requests.single.method, 'GET');
      expect(adapter.requests.single.path, '/ghost-config/pending');
      expect(pending.map((c) => c.id), ['p1', 'p2']);
    });

    test('returns an empty list for a JSON null body', () async {
      adapter.queueJson(null);

      expect(await repository.fetchPending(), isEmpty);
    });

    test('returns an empty list for an empty JSON array', () async {
      adapter.queueJson(<Object?>[]);

      expect(await repository.fetchPending(), isEmpty);
    });

    test('returns an empty list for a genuinely empty body', () async {
      adapter.queueEmptyBody();

      expect(await repository.fetchPending(), isEmpty);
    });
  });

  group('GhostConfigRepository.propose', () {
    test(
      'sends exactly timeoutMinutes, penalty, and publicCountdown to POST /ghost-config',
      () async {
        adapter.queueJson(configJson());

        await repository.propose(timeoutMinutes: 15, penalty: Penalty.noise);

        final request = adapter.requests.single;
        expect(request.method, 'POST');
        expect(request.path, '/ghost-config');
        expect(request.data, {
          'timeoutMinutes': 15,
          'penalty': 'noise',
          'publicCountdown': true,
        });
      },
    );

    test('rejects timeoutMinutes below 1 without calling the network', () async {
      await expectLater(
        repository.propose(timeoutMinutes: 0, penalty: Penalty.none),
        throwsArgumentError,
      );
      expect(adapter.requests, isEmpty);
    });

    test('rejects timeoutMinutes above 120 without calling the network', () async {
      await expectLater(
        repository.propose(timeoutMinutes: 121, penalty: Penalty.none),
        throwsArgumentError,
      );
      expect(adapter.requests, isEmpty);
    });

    test('accepts the 1-120 boundary values', () async {
      adapter.queueJson(configJson());
      await repository.propose(timeoutMinutes: 1, penalty: Penalty.none);
      adapter.queueJson(configJson());
      await repository.propose(timeoutMinutes: 120, penalty: Penalty.none);

      expect(adapter.requests, hasLength(2));
    });
  });

  group('GhostConfigRepository.approve', () {
    test('issues PATCH /ghost-config/:id/approve', () async {
      adapter.queueJson(configJson(status: 'active'));

      final config = await repository.approve('config-9');

      final request = adapter.requests.single;
      expect(request.method, 'PATCH');
      expect(request.path, '/ghost-config/config-9/approve');
      expect(config.status, ConfigStatus.active);
    });
  });

  group('GhostConfigRepository.reject', () {
    test('issues PATCH /ghost-config/:id/reject', () async {
      adapter.queueJson(configJson(status: 'rejected'));

      final config = await repository.reject('config-9');

      final request = adapter.requests.single;
      expect(request.method, 'PATCH');
      expect(request.path, '/ghost-config/config-9/reject');
      expect(config.status, ConfigStatus.rejected);
    });
  });

  group('GhostConfigRepository.fetchStormStatus', () {
    test('issues GET /ghost-config/storm-status/:partnerId', () async {
      adapter.queueJson({'eligible': true, 'penalty': 'emoji_storm'});

      final status = await repository.fetchStormStatus('partner-1');

      final request = adapter.requests.single;
      expect(request.method, 'GET');
      expect(request.path, '/ghost-config/storm-status/partner-1');
      expect(status.eligible, isTrue);
      expect(status.penalty, Penalty.emojiStorm);
    });

    test('treats a null penalty as legitimately absent, not unknown', () async {
      adapter.queueJson({'eligible': false, 'penalty': null});

      final status = await repository.fetchStormStatus('partner-1');

      expect(status.eligible, isFalse);
      expect(status.penalty, isNull);
    });
  });

  group('Penalty wire mapping', () {
    test('round-trips every known wire value', () {
      expect(Penalty.fromWire('emoji_storm'), Penalty.emojiStorm);
      expect(Penalty.fromWire('noise'), Penalty.noise);
      expect(Penalty.fromWire('none'), Penalty.none);
      expect(Penalty.emojiStorm.wireValue, 'emoji_storm');
      expect(Penalty.noise.wireValue, 'noise');
      expect(Penalty.none.wireValue, 'none');
    });

    test('falls back to none for an unknown wire value without throwing', () {
      expect(Penalty.fromWire('something_new'), Penalty.none);
      expect(Penalty.fromWire(null), Penalty.none);
    });
  });

  group('ConfigStatus wire mapping', () {
    test('round-trips every known wire value', () {
      expect(ConfigStatus.fromWire('active'), ConfigStatus.active);
      expect(ConfigStatus.fromWire('pending_approval'), ConfigStatus.pendingApproval);
      expect(ConfigStatus.fromWire('rejected'), ConfigStatus.rejected);
      expect(ConfigStatus.fromWire('superseded'), ConfigStatus.superseded);
      expect(ConfigStatus.active.wireValue, 'active');
      expect(ConfigStatus.pendingApproval.wireValue, 'pending_approval');
      expect(ConfigStatus.rejected.wireValue, 'rejected');
      expect(ConfigStatus.superseded.wireValue, 'superseded');
    });

    test('falls back to unknown for an unrecognized wire value without throwing', () {
      expect(ConfigStatus.fromWire('something_new'), ConfigStatus.unknown);
      expect(ConfigStatus.fromWire(null), ConfigStatus.unknown);
    });
  });
}
