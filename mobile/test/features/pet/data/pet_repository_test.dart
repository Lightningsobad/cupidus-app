import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/pet/data/pet_mood.dart';
import 'package:cupid_mobile/features/pet/data/pet_models.dart';
import 'package:cupid_mobile/features/pet/data/pet_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _CapturedRequest {
  _CapturedRequest({required this.method, required this.path, this.data});

  final String method;
  final String path;
  final Object? data;
}

class _StubResponse {
  const _StubResponse(this.statusCode, this.body);

  final int statusCode;

  /// Raw JSON text on the wire, matching the backend's actual `null` body
  /// for an empty `/pets/status` response.
  final String body;
}

/// A hand-rolled `HttpClientAdapter` double: this story's write scope
/// forbids a new pub dependency (`architecture/solution.md` §4 Mobile Lane
/// Handoff), so no mock-adapter package is available for asserting
/// path/verb/body per the P2 risk-surface gate
/// (`coding-plan/master-plan.md` §3A).
class _StubHttpClientAdapter implements HttpClientAdapter {
  _StubHttpClientAdapter(this._responses);

  final List<_StubResponse> _responses;
  final List<_CapturedRequest> requests = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(
      _CapturedRequest(
        method: options.method,
        path: options.path,
        data: options.data,
      ),
    );
    final stub = _responses.removeAt(0);
    return ResponseBody.fromString(
      stub.body,
      stub.statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

const _fullStatusBody = '''
{
  "pet": {
    "id": "pet-1",
    "coupleId": "couple-1",
    "species": "bunny",
    "name": "Bun",
    "happiness": 72,
    "level": 2,
    "totalInteractions": 63,
    "lastInteraction": "2026-07-30T02:10:00.000Z"
  },
  "mood": "happy",
  "decayedHappiness": 72,
  "milestone": "50 interactions!",
  "nextMilestone": 100
}
''';

String _statusBodyWithMood(String mood) => '''
{
  "pet": {
    "id": "pet-1",
    "coupleId": "couple-1",
    "species": "bunny",
    "name": "Bun",
    "happiness": 72,
    "level": 2,
    "totalInteractions": 63,
    "lastInteraction": "2026-07-30T02:10:00.000Z"
  },
  "mood": "$mood",
  "decayedHappiness": 72,
  "milestone": "50 interactions!",
  "nextMilestone": 100
}
''';

({PetRepository repository, _StubHttpClientAdapter adapter}) _buildRepository(
  List<_StubResponse> responses,
) {
  final api = CupidApiClient.create();
  final adapter = _StubHttpClientAdapter(responses);
  api.dio.httpClientAdapter = adapter;
  return (repository: PetRepository(api: api), adapter: adapter);
}

void main() {
  group('PetRepository.readPairing', () {
    test('GET /users/me with a partnerId maps to isPaired true', () async {
      final built = _buildRepository([
        const _StubResponse(200, '{"id":"u1","partnerId":"u2"}'),
      ]);

      final pairing = await built.repository.readPairing();

      expect(pairing.isPaired, isTrue);
      expect(built.adapter.requests, hasLength(1));
      expect(built.adapter.requests.single.method, 'GET');
      expect(built.adapter.requests.single.path, '/users/me');
    });

    test('a null partnerId maps to isPaired false', () async {
      final built = _buildRepository([
        const _StubResponse(200, '{"id":"u1","partnerId":null}'),
      ]);

      final pairing = await built.repository.readPairing();

      expect(pairing.isPaired, isFalse);
    });
  });

  group('PetRepository.readStatus', () {
    test('GET /pets/status parses a full payload', () async {
      final built = _buildRepository([
        const _StubResponse(200, _fullStatusBody),
      ]);

      final status = await built.repository.readStatus();

      expect(built.adapter.requests.single.method, 'GET');
      expect(built.adapter.requests.single.path, '/pets/status');
      expect(status, isNotNull);
      expect(status!.pet.id, 'pet-1');
      expect(status.pet.species, PetSpecies.bunny);
      expect(status.mood, PetMood.happy);
      expect(status.decayedHappiness, 72);
      expect(status.nextMilestone, 100);
    });

    test('an empty body maps to null', () async {
      final built = _buildRepository([const _StubResponse(200, 'null')]);

      final status = await built.repository.readStatus();

      expect(status, isNull);
    });

    test('an unknown mood value falls back to content', () async {
      final built = _buildRepository([
        _StubResponse(200, _statusBodyWithMood('euphoric')),
      ]);

      final status = await built.repository.readStatus();

      expect(status!.mood, PetMood.content);
    });
  });

  group('PetRepository.interact', () {
    test(
      'PATCH /pets/interact then refetches GET /pets/status',
      () async {
        final built = _buildRepository([
          const _StubResponse(200, '{"id":"pet-1"}'),
          const _StubResponse(200, _fullStatusBody),
        ]);

        final status = await built.repository.interact();

        expect(built.adapter.requests, hasLength(2));
        expect(built.adapter.requests[0].method, 'PATCH');
        expect(built.adapter.requests[0].path, '/pets/interact');
        expect(built.adapter.requests[1].method, 'GET');
        expect(built.adapter.requests[1].path, '/pets/status');
        expect(status.pet.id, 'pet-1');
      },
    );

    test('a 400 cooldown response surfaces as HttpStatusFailure', () async {
      final built = _buildRepository([
        const _StubResponse(400, '{"message":"Slow down!"}'),
      ]);

      await expectLater(
        built.repository.interact(),
        throwsA(
          isA<HttpStatusFailure>().having(
            (f) => f.statusCode,
            'statusCode',
            400,
          ),
        ),
      );
    });
  });

  group('PetRepository.adopt', () {
    test(
      'POST /pets/adopt sends the species and name, then refetches status',
      () async {
        final built = _buildRepository([
          const _StubResponse(200, '{"id":"pet-1"}'),
          const _StubResponse(200, _fullStatusBody),
        ]);

        final status = await built.repository.adopt(
          species: PetSpecies.bunny,
          name: 'Bun',
        );

        expect(built.adapter.requests, hasLength(2));
        expect(built.adapter.requests[0].method, 'POST');
        expect(built.adapter.requests[0].path, '/pets/adopt');
        expect(
          built.adapter.requests[0].data,
          {'species': 'bunny', 'name': 'Bun'},
        );
        expect(built.adapter.requests[1].path, '/pets/status');
        expect(status.pet.id, 'pet-1');
      },
    );

    test('a 409 conflict response surfaces as HttpStatusFailure', () async {
      final built = _buildRepository([
        const _StubResponse(409, '{"message":"Your couple already has a pet"}'),
      ]);

      await expectLater(
        built.repository.adopt(species: PetSpecies.cat, name: 'Miu'),
        throwsA(
          isA<HttpStatusFailure>().having(
            (f) => f.statusCode,
            'statusCode',
            409,
          ),
        ),
      );
    });

    test('a 400 not-yet-eligible response surfaces as HttpStatusFailure', () async {
      final built = _buildRepository([
        const _StubResponse(400, '{"message":"not yet"}'),
      ]);

      await expectLater(
        built.repository.adopt(species: PetSpecies.dog, name: 'Rex'),
        throwsA(isA<HttpStatusFailure>()),
      );
    });
  });
}
