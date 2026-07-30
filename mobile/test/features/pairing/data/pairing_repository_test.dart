import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/pairing/data/pairing_failure.dart';
import 'package:cupid_mobile/features/pairing/data/pairing_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._respond);

  final ResponseBody Function(RequestOptions options) _respond;
  RequestOptions? lastOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    return _respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(int statusCode, Object? body) => ResponseBody.fromString(
  jsonEncode(body),
  statusCode,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

PairingRepository _repositoryReturning(int statusCode, Object? body) {
  final api = CupidApiClient.create();
  api.dio.httpClientAdapter = _ScriptedAdapter(
    (_) => _jsonResponse(statusCode, body),
  );
  return PairingRepository(api: api);
}

void main() {
  group('PairingRepository.generateInvitation', () {
    test('parses the 6-hex code and expiresAt from the response body', () async {
      final repository = _repositoryReturning(200, {
        'code': '3F9A2B',
        'expiresAt': '2026-08-01T12:00:00.000Z',
      });

      final invitation = await repository.generateInvitation();

      expect(invitation.code, '3F9A2B');
      expect(invitation.expiresAt, DateTime.parse('2026-08-01T12:00:00.000Z'));
    });

    test('renders the code exactly as returned, with no reformatting', () async {
      final repository = _repositoryReturning(200, {
        'code': 'ab12cd',
        'expiresAt': '2026-08-01T12:00:00.000Z',
      });

      final invitation = await repository.generateInvitation();

      expect(invitation.code, 'ab12cd');
    });

    test('throws UnexpectedFailure on a malformed body', () async {
      final repository = _repositoryReturning(200, {'code': 'ABCDEF'});

      await expectLater(
        repository.generateInvitation(),
        throwsA(isA<UnexpectedFailure>()),
      );
    });
  });

  group('PairingRepository.getPartnerLink', () {
    test('parses a non-null partnerId', () async {
      final repository = _repositoryReturning(200, {'partnerId': 'partner-1'});

      final link = await repository.getPartnerLink();

      expect(link.partnerId, 'partner-1');
      expect(link.isPaired, isTrue);
    });

    test('parses a null partnerId', () async {
      final repository = _repositoryReturning(200, {'partnerId': null});

      final link = await repository.getPartnerLink();

      expect(link.partnerId, isNull);
      expect(link.isPaired, isFalse);
    });
  });

  group('PairingRepository.acceptInvitation', () {
    test('succeeds without throwing on 200', () async {
      final repository = _repositoryReturning(200, {'success': true});

      await repository.acceptInvitation('3F9A2B');
    });

    test('maps 404 to InvalidOrExpiredCodeFailure', () async {
      final repository = _repositoryReturning(404, {
        'statusCode': 404,
        'message': 'Invalid or expired code',
      });

      await expectLater(
        repository.acceptInvitation('BADCOD'),
        throwsA(isA<InvalidOrExpiredCodeFailure>()),
      );
    });

    test('maps 400 to InvalidOrExpiredCodeFailure', () async {
      final repository = _repositoryReturning(400, {
        'statusCode': 400,
        'message': 'Code expired',
      });

      await expectLater(
        repository.acceptInvitation('3F9A2B'),
        throwsA(isA<InvalidOrExpiredCodeFailure>()),
      );
    });

    test(
      'maps 409 "You are already paired with a partner" to AlreadyPairedFailure',
      () async {
        final repository = _repositoryReturning(409, {
          'statusCode': 409,
          'message': 'You are already paired with a partner',
        });

        await expectLater(
          repository.acceptInvitation('3F9A2B'),
          throwsA(isA<AlreadyPairedFailure>()),
        );
      },
    );

    test('maps 409 "Cannot invite yourself" to SelfInviteFailure', () async {
      final repository = _repositoryReturning(409, {
        'statusCode': 409,
        'message': 'Cannot invite yourself',
      });

      await expectLater(
        repository.acceptInvitation('3F9A2B'),
        throwsA(isA<SelfInviteFailure>()),
      );
    });

    test(
      'maps 409 "This person is already paired with a partner" to '
      'InviterAlreadyPairedFailure',
      () async {
        final repository = _repositoryReturning(409, {
          'statusCode': 409,
          'message': 'This person is already paired with a partner',
        });

        await expectLater(
          repository.acceptInvitation('3F9A2B'),
          throwsA(isA<InviterAlreadyPairedFailure>()),
        );
      },
    );

    test('maps an unrecognized 409 message to UnmappedPairingFailure', () async {
      final repository = _repositoryReturning(409, {
        'statusCode': 409,
        'message': 'Something else entirely',
      });

      await expectLater(
        repository.acceptInvitation('3F9A2B'),
        throwsA(isA<UnmappedPairingFailure>()),
      );
    });

    test('maps a 500 to UnmappedPairingFailure carrying the HttpStatusFailure', () async {
      final repository = _repositoryReturning(500, {
        'statusCode': 500,
        'message': 'boom',
      });

      final failure = await repository
          .acceptInvitation('3F9A2B')
          .then<PairingFailure?>((_) => null, onError: (Object e) => e as PairingFailure);

      expect(failure, isA<UnmappedPairingFailure>());
      expect(
        (failure as UnmappedPairingFailure).cause,
        isA<HttpStatusFailure>(),
      );
    });
  });
}
