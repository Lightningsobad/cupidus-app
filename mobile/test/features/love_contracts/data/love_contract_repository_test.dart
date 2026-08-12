import 'dart:convert';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/features/love_contracts/data/love_contract.dart';
import 'package:cupid_mobile/features/love_contracts/data/love_contract_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// A `DioAdapter`-free stand-in for a scripted HTTP response, consistent
/// with the pattern in `test/features/auth/data/auth_repository_test.dart`
/// (injected fakes, no mocking package).
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._respond);

  final Future<ResponseBody> Function(RequestOptions options) _respond;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) => _respond(options);
}

ResponseBody _jsonResponse(Object? data, [int statusCode = 200]) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

LoveContractRepository _repositoryWith(HttpClientAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
    ..httpClientAdapter = adapter
    ..interceptors.add(const CupidErrorInterceptor());
  return LoveContractRepository(CupidApi(dio: dio, interceptors: const []));
}

final _fullContractJson = <String, dynamic>{
  'id': 'contract-1',
  'requesterId': 'user-1',
  'partnerId': null,
  'clauses': ['Always tell the truth'],
  'status': 'signed_requester',
  'viewerRole': 'requester',
  'signedAtRequester': '2026-01-01T00:00:00.000Z',
  'signedAtPartner': null,
  'createdAt': '2026-01-01T00:00:00.000Z',
  'updatedAt': '2026-01-01T00:00:00.000Z',
};

void main() {
  group('LoveContract.fromJson', () {
    test('maps a full success payload', () {
      final contract = LoveContract.fromJson(_fullContractJson);

      expect(contract.id, 'contract-1');
      expect(contract.clauses, ['Always tell the truth']);
      expect(contract.viewerRole, ContractViewerRole.requester);
      expect(contract.signedAtRequester, DateTime.parse('2026-01-01T00:00:00.000Z'));
      expect(contract.signedAtPartner, isNull);
      expect(contract.status, ContractSignStatus.signedByMe);
    });

    test('never throws for an empty map and falls back to defaults', () {
      final contract = LoveContract.fromJson(const {});

      expect(contract.id, '');
      expect(contract.clauses, isEmpty);
      expect(contract.viewerRole, ContractViewerRole.requester);
      expect(contract.signedAtRequester, isNull);
      expect(contract.signedAtPartner, isNull);
      expect(contract.status, ContractSignStatus.unsigned);
    });

    test('falls back to requester for an unknown viewerRole string', () {
      final contract = LoveContract.fromJson({
        ..._fullContractJson,
        'viewerRole': 'some_future_role',
      });

      expect(contract.viewerRole, ContractViewerRole.requester);
    });

    test('treats a missing clauses key as an empty list', () {
      final json = Map<String, dynamic>.from(_fullContractJson)
        ..remove('clauses');

      expect(LoveContract.fromJson(json).clauses, isEmpty);
    });

    test('treats a non-string clause entry defensively', () {
      final contract = LoveContract.fromJson({
        ..._fullContractJson,
        'clauses': ['ok', 42, null],
      });

      expect(contract.clauses, ['ok']);
    });
  });

  group('LoveContract.status derivation (ADR-019c)', () {
    /// `contract-summary.md` §Client Derivation Rule — 4 timestamp
    /// combinations x 2 viewer roles = 8 cases.
    final cases = <({
      String description,
      String viewerRole,
      String? signedAtRequester,
      String? signedAtPartner,
      ContractSignStatus expected,
    })>[
      (
        description: 'requester viewer, neither signed -> unsigned',
        viewerRole: 'requester',
        signedAtRequester: null,
        signedAtPartner: null,
        expected: ContractSignStatus.unsigned,
      ),
      (
        description: 'requester viewer, requester signed only -> signedByMe',
        viewerRole: 'requester',
        signedAtRequester: '2026-01-01T00:00:00.000Z',
        signedAtPartner: null,
        expected: ContractSignStatus.signedByMe,
      ),
      (
        description:
            'requester viewer, partner signed only -> partnerAlreadySigned',
        viewerRole: 'requester',
        signedAtRequester: null,
        signedAtPartner: '2026-01-01T00:00:00.000Z',
        expected: ContractSignStatus.partnerAlreadySigned,
      ),
      (
        description: 'requester viewer, both signed -> bothSigned',
        viewerRole: 'requester',
        signedAtRequester: '2026-01-01T00:00:00.000Z',
        signedAtPartner: '2026-01-02T00:00:00.000Z',
        expected: ContractSignStatus.bothSigned,
      ),
      (
        description: 'partner viewer, neither signed -> unsigned',
        viewerRole: 'partner',
        signedAtRequester: null,
        signedAtPartner: null,
        expected: ContractSignStatus.unsigned,
      ),
      (
        description:
            'partner viewer, requester signed only -> partnerAlreadySigned '
            '(the regression this story exists for — must never be signedByMe)',
        viewerRole: 'partner',
        signedAtRequester: '2026-01-01T00:00:00.000Z',
        signedAtPartner: null,
        expected: ContractSignStatus.partnerAlreadySigned,
      ),
      (
        description: 'partner viewer, partner signed only -> signedByMe',
        viewerRole: 'partner',
        signedAtRequester: null,
        signedAtPartner: '2026-01-01T00:00:00.000Z',
        expected: ContractSignStatus.signedByMe,
      ),
      (
        description: 'partner viewer, both signed -> bothSigned',
        viewerRole: 'partner',
        signedAtRequester: '2026-01-01T00:00:00.000Z',
        signedAtPartner: '2026-01-02T00:00:00.000Z',
        expected: ContractSignStatus.bothSigned,
      ),
    ];

    for (final testCase in cases) {
      test(testCase.description, () {
        final contract = LoveContract.fromJson({
          ..._fullContractJson,
          'viewerRole': testCase.viewerRole,
          'signedAtRequester': testCase.signedAtRequester,
          'signedAtPartner': testCase.signedAtPartner,
        });

        expect(contract.status, testCase.expected);
      });
    }
  });

  group('LoveContractRepository.fetchCurrent', () {
    test('returns null for the empty (null body) state', () async {
      final repository = _repositoryWith(
        _ScriptedAdapter((options) async => _jsonResponse(null)),
      );

      expect(await repository.fetchCurrent(), isNull);
    });

    test('returns a parsed contract on success', () async {
      final repository = _repositoryWith(
        _ScriptedAdapter((options) async => _jsonResponse(_fullContractJson)),
      );

      final contract = await repository.fetchCurrent();

      expect(contract, isNotNull);
      expect(contract!.id, 'contract-1');
    });

    test('maps a connection error to NetworkUnavailableFailure', () async {
      final repository = _repositoryWith(
        _ScriptedAdapter(
          (options) async => throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          ),
        ),
      );

      await expectLater(
        repository.fetchCurrent(),
        throwsA(isA<NetworkUnavailableFailure>()),
      );
    });
  });

  group('LoveContractRepository.saveClauses', () {
    test('posts the clauses and returns the parsed contract', () async {
      RequestOptions? capturedOptions;
      final repository = _repositoryWith(
        _ScriptedAdapter((options) async {
          capturedOptions = options;
          return _jsonResponse(_fullContractJson);
        }),
      );

      final contract = await repository.saveClauses(['Be kind']);

      expect(contract.id, 'contract-1');
      expect(capturedOptions?.path, '/love-contracts');
      expect(capturedOptions?.data, {
        'clauses': ['Be kind'],
      });
    });

    test('maps a 500 response to HttpStatusFailure', () async {
      final repository = _repositoryWith(
        _ScriptedAdapter(
          (options) async => _jsonResponse({'message': 'boom'}, 500),
        ),
      );

      await expectLater(
        repository.saveClauses(['Be kind']),
        throwsA(
          isA<HttpStatusFailure>().having(
            (f) => f.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
    });
  });

  group('LoveContractRepository.sign', () {
    test('returns the parsed contract on success', () async {
      final repository = _repositoryWith(
        _ScriptedAdapter((options) async => _jsonResponse(_fullContractJson)),
      );

      final contract = await repository.sign();

      expect(contract.status, ContractSignStatus.signedByMe);
    });

    test(
      '404 maps to a CupidApiFailure marked isSignUnavailable',
      () async {
        final repository = _repositoryWith(
          _ScriptedAdapter(
            (options) async =>
                _jsonResponse({'message': 'No pending contract found to sign'}, 404),
          ),
        );

        try {
          await repository.sign();
          fail('expected a CupidApiFailure');
        } on CupidApiFailure catch (failure) {
          expect(failure.isSignUnavailable, isTrue);
        }
      },
    );

    test('a network failure is not marked isSignUnavailable', () async {
      final repository = _repositoryWith(
        _ScriptedAdapter(
          (options) async => throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          ),
        ),
      );

      try {
        await repository.sign();
        fail('expected a CupidApiFailure');
      } on CupidApiFailure catch (failure) {
        expect(failure.isSignUnavailable, isFalse);
        expect(failure, isA<NetworkUnavailableFailure>());
      }
    });
  });
}
