import 'dart:convert';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/features/love_contracts/data/love_contract.dart';
import 'package:cupid_mobile/features/love_contracts/data/love_contract_repository.dart';
import 'package:cupid_mobile/features/love_contracts/presentation/love_contract_bloc.dart';
import 'package:cupid_mobile/features/love_contracts/presentation/love_contract_event.dart';
import 'package:cupid_mobile/features/love_contracts/presentation/love_contract_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// A `DioAdapter`-free scripted HTTP double, consistent with
/// `test/features/love_contracts/data/love_contract_repository_test.dart`
/// (injected fakes, no mocking package). Each call is logged by
/// `METHOD path` so tests can assert call order and count.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._handlers);

  final Map<String, Future<ResponseBody> Function(RequestOptions)> _handlers;
  final List<String> calls = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    final key = '${options.method} ${options.path}';
    calls.add(key);
    final handler = _handlers[key];
    if (handler == null) {
      throw StateError('No scripted handler for $key');
    }
    return handler(options);
  }
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

Future<ResponseBody> Function(RequestOptions) _fixed(
  Future<ResponseBody> Function() respond,
) => (options) => respond();

({LoveContractRepository repository, _ScriptedAdapter adapter})
_repositoryWith(
  Map<String, Future<ResponseBody> Function(RequestOptions)> handlers,
) {
  final adapter = _ScriptedAdapter(handlers);
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
    ..httpClientAdapter = adapter
    ..interceptors.add(const CupidErrorInterceptor());
  return (
    repository: LoveContractRepository(CupidApi(dio: dio, interceptors: const [])),
    adapter: adapter,
  );
}

final _contractJson = <String, dynamic>{
  'id': 'contract-1',
  'requesterId': 'user-1',
  'partnerId': null,
  'clauses': ['Always tell the truth', 'Water the plants'],
  'status': 'created',
  'viewerRole': 'requester',
  'signedAtRequester': null,
  'signedAtPartner': null,
  'createdAt': '2026-01-01T00:00:00.000Z',
  'updatedAt': '2026-01-01T00:00:00.000Z',
};

final _signedContractJson = <String, dynamic>{
  ..._contractJson,
  'status': 'signed_requester',
  'signedAtRequester': '2026-01-01T00:00:00.000Z',
};

final _partnerContractJson = <String, dynamic>{
  ..._contractJson,
  'viewerRole': 'partner',
};

final _partnerSignedContractJson = <String, dynamic>{
  ..._partnerContractJson,
  'status': 'signed_partner',
  'signedAtPartner': '2026-01-01T00:00:00.000Z',
};

LoveContractBloc _blocReadyWithoutSelection({String? partnerDisplayName}) {
  final scripted = _repositoryWith({
    'GET /love-contracts/my-pending': _fixed(() async => _jsonResponse(null)),
  });
  return LoveContractBloc(
    repository: scripted.repository,
    partnerDisplayName: () => partnerDisplayName,
  );
}

void main() {
  group('LoveContractBloc load', () {
    test('emits loading then ready-empty when there is no pending contract', () async {
      final bloc = _blocReadyWithoutSelection(partnerDisplayName: 'Linh');
      addTearDown(bloc.close);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[isA<LoveContractLoading>(), isA<LoveContractReady>()]),
      );

      bloc.add(const LoveContractOpened());
      await expectation;

      final state = bloc.state as LoveContractReady;
      expect(state.selectedClauseIds, isEmpty);
      expect(state.signStatus, ContractSignStatus.unsigned);
      expect(state.partnerDisplayName, 'Linh');
      expect(state.canSign, isFalse);
    });

    test(
      'emits ready with reconciled preset and custom clauses when a contract exists',
      () async {
        final scripted = _repositoryWith({
          'GET /love-contracts/my-pending': _fixed(
            () async => _jsonResponse(_contractJson),
          ),
        });
        final bloc = LoveContractBloc(
          repository: scripted.repository,
          partnerDisplayName: () => null,
        );
        addTearDown(bloc.close);

        bloc.add(const LoveContractOpened());
        await expectLater(bloc.stream, emitsThrough(isA<LoveContractReady>()));

        final state = bloc.state as LoveContractReady;
        expect(state.customClauses, hasLength(1));
        expect(state.customClauses.single.text, 'Water the plants');
        expect(state.selectedClauseIds, contains('preset-honesty'));
        expect(state.selectedClauseIds, contains(state.customClauses.single.id));
        expect(state.selectedCount, 2);
      },
    );

    test('emits load-failed on a network error', () async {
      final scripted = _repositoryWith({
        'GET /love-contracts/my-pending': (options) async => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      });
      final bloc = LoveContractBloc(
        repository: scripted.repository,
        partnerDisplayName: () => null,
      );
      addTearDown(bloc.close);

      bloc.add(const LoveContractOpened());
      await expectLater(bloc.stream, emitsThrough(isA<LoveContractLoadFailed>()));

      final state = bloc.state as LoveContractLoadFailed;
      expect(state.failure, isA<NetworkUnavailableFailure>());
    });

    test('ContractRetryRequested recovers after a prior failure', () async {
      var attempt = 0;
      final scripted = _repositoryWith({
        'GET /love-contracts/my-pending': (options) async {
          attempt += 1;
          if (attempt == 1) {
            throw DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
            );
          }
          return _jsonResponse(null);
        },
      });
      final bloc = LoveContractBloc(
        repository: scripted.repository,
        partnerDisplayName: () => null,
      );
      addTearDown(bloc.close);

      bloc.add(const LoveContractOpened());
      await expectLater(bloc.stream, emitsThrough(isA<LoveContractLoadFailed>()));

      bloc.add(const ContractRetryRequested());
      await expectLater(bloc.stream, emitsThrough(isA<LoveContractReady>()));

      expect(bloc.state, isA<LoveContractReady>());
      expect(attempt, 2);
    });
  });

  group('LoveContractBloc clause selection', () {
    test('ClauseToggled toggles a preset clause on and off with no network call', () async {
      final bloc = _blocReadyWithoutSelection();
      addTearDown(bloc.close);

      bloc.add(const LoveContractOpened());
      await expectLater(bloc.stream, emitsThrough(isA<LoveContractReady>()));

      bloc.add(const ClauseToggled('preset-honesty'));
      await pumpEventQueue();
      var state = bloc.state as LoveContractReady;
      expect(state.selectedClauseIds, {'preset-honesty'});

      bloc.add(const ClauseToggled('preset-honesty'));
      await pumpEventQueue();
      state = bloc.state as LoveContractReady;
      expect(state.selectedClauseIds, isEmpty);
    });

    test('CustomClauseAdded appends and auto-selects a trimmed clause', () async {
      final bloc = _blocReadyWithoutSelection();
      addTearDown(bloc.close);

      bloc.add(const LoveContractOpened());
      await expectLater(bloc.stream, emitsThrough(isA<LoveContractReady>()));

      bloc.add(const CustomClauseAdded('  Be kind  '));
      await pumpEventQueue();

      final state = bloc.state as LoveContractReady;
      expect(state.customClauses.single.text, 'Be kind');
      expect(state.selectedClauseIds, contains(state.customClauses.single.id));
    });

    test('CustomClauseAdded rejects an empty/whitespace-only clause', () async {
      final bloc = _blocReadyWithoutSelection();
      addTearDown(bloc.close);

      bloc.add(const LoveContractOpened());
      await expectLater(bloc.stream, emitsThrough(isA<LoveContractReady>()));
      final before = bloc.state as LoveContractReady;

      bloc.add(const CustomClauseAdded('   '));
      await pumpEventQueue();

      expect(bloc.state, before);
    });

    test('a 21st selected clause is rejected while the 20th is accepted', () async {
      final bloc = _blocReadyWithoutSelection();
      addTearDown(bloc.close);

      bloc.add(const LoveContractOpened());
      await expectLater(bloc.stream, emitsThrough(isA<LoveContractReady>()));

      for (var i = 0; i < 20; i++) {
        bloc.add(CustomClauseAdded('clause $i'));
      }
      await pumpEventQueue();

      var state = bloc.state as LoveContractReady;
      expect(state.selectedCount, 20);

      bloc.add(const CustomClauseAdded('clause 20'));
      await pumpEventQueue();

      state = bloc.state as LoveContractReady;
      expect(state.selectedCount, 20);
      expect(state.customClauses, hasLength(20));
    });
  });

  group('LoveContractBloc signing ritual', () {
    test('signing is unreachable with zero selected clauses', () async {
      final scripted = _repositoryWith({
        'GET /love-contracts/my-pending': _fixed(() async => _jsonResponse(null)),
      });
      final bloc = LoveContractBloc(
        repository: scripted.repository,
        partnerDisplayName: () => null,
      );
      addTearDown(bloc.close);

      bloc.add(const LoveContractOpened());
      await expectLater(bloc.stream, emitsThrough(isA<LoveContractReady>()));

      bloc.add(const SignHoldStarted());
      bloc.add(const SignHoldCompleted());
      await pumpEventQueue();

      expect(scripted.adapter.calls, ['GET /love-contracts/my-pending']);
      final state = bloc.state as LoveContractReady;
      expect(state.inFlight, isFalse);
      expect(state.signStatus, ContractSignStatus.unsigned);
    });

    test('SignHoldCompleted with no preceding SignHoldStarted is a no-op', () async {
      final bloc = _blocReadyWithoutSelection();
      addTearDown(bloc.close);

      bloc.add(const LoveContractOpened());
      await expectLater(bloc.stream, emitsThrough(isA<LoveContractReady>()));

      bloc.add(const CustomClauseAdded('Be kind'));
      await pumpEventQueue();
      final beforeCompleted = bloc.state as LoveContractReady;

      bloc.add(const SignHoldCompleted());
      await pumpEventQueue();

      expect(bloc.state, beforeCompleted);
    });

    test('hold started then cancelled makes no network call', () async {
      final scripted = _repositoryWith({
        'GET /love-contracts/my-pending': _fixed(
          () async => _jsonResponse(_contractJson),
        ),
      });
      final bloc = LoveContractBloc(
        repository: scripted.repository,
        partnerDisplayName: () => null,
      );
      addTearDown(bloc.close);

      bloc.add(const LoveContractOpened());
      await expectLater(bloc.stream, emitsThrough(isA<LoveContractReady>()));

      bloc.add(const SignHoldStarted());
      bloc.add(const SignHoldCancelled());
      bloc.add(const SignHoldCompleted());
      await pumpEventQueue();

      expect(scripted.adapter.calls, ['GET /love-contracts/my-pending']);
    });

    test('hold started then completed saves clauses before signing', () async {
      final scripted = _repositoryWith({
        'GET /love-contracts/my-pending': _fixed(
          () async => _jsonResponse(_contractJson),
        ),
        'POST /love-contracts': _fixed(
          () async => _jsonResponse(_contractJson),
        ),
        'PATCH /love-contracts/sign': _fixed(
          () async => _jsonResponse(_signedContractJson),
        ),
      });
      final bloc = LoveContractBloc(
        repository: scripted.repository,
        partnerDisplayName: () => null,
      );
      addTearDown(bloc.close);

      bloc.add(const LoveContractOpened());
      await expectLater(bloc.stream, emitsThrough(isA<LoveContractReady>()));

      bloc.add(const SignHoldStarted());
      bloc.add(const SignHoldCompleted());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<LoveContractState>(
            (state) =>
                state is LoveContractReady &&
                state.signStatus == ContractSignStatus.signedByMe &&
                !state.inFlight,
          ),
        ),
      );

      expect(scripted.adapter.calls, [
        'GET /love-contracts/my-pending',
        'POST /love-contracts',
        'PATCH /love-contracts/sign',
      ]);
    });

    test(
      'a second SignHoldCompleted right after the first produces exactly one save+sign pair',
      () async {
        final scripted = _repositoryWith({
          'GET /love-contracts/my-pending': _fixed(
            () async => _jsonResponse(_contractJson),
          ),
          'POST /love-contracts': _fixed(
            () async => _jsonResponse(_contractJson),
          ),
          'PATCH /love-contracts/sign': _fixed(
            () async => _jsonResponse(_signedContractJson),
          ),
        });
        final bloc = LoveContractBloc(
          repository: scripted.repository,
          partnerDisplayName: () => null,
        );
        addTearDown(bloc.close);

        bloc.add(const LoveContractOpened());
        await expectLater(bloc.stream, emitsThrough(isA<LoveContractReady>()));

        bloc.add(const SignHoldStarted());
        bloc.add(const SignHoldCompleted());
        bloc.add(const SignHoldCompleted());

        await expectLater(
          bloc.stream,
          emitsThrough(
            predicate<LoveContractState>(
              (state) =>
                  state is LoveContractReady &&
                  state.signStatus == ContractSignStatus.signedByMe,
            ),
          ),
        );
        await pumpEventQueue();

        expect(scripted.adapter.calls, [
          'GET /love-contracts/my-pending',
          'POST /love-contracts',
          'PATCH /love-contracts/sign',
        ]);
      },
    );

    test(
      'a sign failure keeps the ready state with actionFailure set and inFlight false',
      () async {
        final scripted = _repositoryWith({
          'GET /love-contracts/my-pending': _fixed(
            () async => _jsonResponse(_contractJson),
          ),
          'POST /love-contracts': _fixed(
            () async => _jsonResponse(_contractJson),
          ),
          'PATCH /love-contracts/sign': _fixed(
            () async => _jsonResponse({'message': 'No pending contract found to sign'}, 404),
          ),
        });
        final bloc = LoveContractBloc(
          repository: scripted.repository,
          partnerDisplayName: () => null,
        );
        addTearDown(bloc.close);

        bloc.add(const LoveContractOpened());
        await expectLater(bloc.stream, emitsThrough(isA<LoveContractReady>()));

        bloc.add(const SignHoldStarted());
        bloc.add(const SignHoldCompleted());

        await expectLater(
          bloc.stream,
          emitsThrough(
            predicate<LoveContractState>(
              (state) =>
                  state is LoveContractReady &&
                  state.actionFailure != null &&
                  !state.inFlight,
            ),
          ),
        );

        final state = bloc.state as LoveContractReady;
        expect(state.actionFailure!.isSignUnavailable, isTrue);
        expect(state.signStatus, ContractSignStatus.unsigned);
      },
    );
  });

  group('LoveContractBloc viewer-aware sign flow (ADR-019e)', () {
    test(
      'partner viewer + completed hold calls sign() only, never saveClauses()',
      () async {
        final scripted = _repositoryWith({
          'GET /love-contracts/my-pending': _fixed(
            () async => _jsonResponse(_partnerContractJson),
          ),
          'PATCH /love-contracts/sign': _fixed(
            () async => _jsonResponse(_partnerSignedContractJson),
          ),
        });
        final bloc = LoveContractBloc(
          repository: scripted.repository,
          partnerDisplayName: () => null,
        );
        addTearDown(bloc.close);

        bloc.add(const LoveContractOpened());
        await expectLater(bloc.stream, emitsThrough(isA<LoveContractReady>()));
        expect(
          (bloc.state as LoveContractReady).viewerRole,
          ContractViewerRole.partner,
        );

        bloc.add(const SignHoldStarted());
        bloc.add(const SignHoldCompleted());

        await expectLater(
          bloc.stream,
          emitsThrough(
            predicate<LoveContractState>(
              (state) =>
                  state is LoveContractReady &&
                  state.signStatus == ContractSignStatus.signedByMe &&
                  !state.inFlight,
            ),
          ),
        );

        expect(scripted.adapter.calls, [
          'GET /love-contracts/my-pending',
          'PATCH /love-contracts/sign',
        ]);
      },
    );

    test(
      'requester viewer + completed hold still saves clauses then signs',
      () async {
        final scripted = _repositoryWith({
          'GET /love-contracts/my-pending': _fixed(
            () async => _jsonResponse(_contractJson),
          ),
          'POST /love-contracts': _fixed(
            () async => _jsonResponse(_contractJson),
          ),
          'PATCH /love-contracts/sign': _fixed(
            () async => _jsonResponse(_signedContractJson),
          ),
        });
        final bloc = LoveContractBloc(
          repository: scripted.repository,
          partnerDisplayName: () => null,
        );
        addTearDown(bloc.close);

        bloc.add(const LoveContractOpened());
        await expectLater(bloc.stream, emitsThrough(isA<LoveContractReady>()));

        bloc.add(const SignHoldStarted());
        bloc.add(const SignHoldCompleted());

        await expectLater(
          bloc.stream,
          emitsThrough(
            predicate<LoveContractState>(
              (state) =>
                  state is LoveContractReady &&
                  state.signStatus == ContractSignStatus.signedByMe &&
                  !state.inFlight,
            ),
          ),
        );

        expect(scripted.adapter.calls, [
          'GET /love-contracts/my-pending',
          'POST /love-contracts',
          'PATCH /love-contracts/sign',
        ]);
      },
    );

    test('partner viewer: ClauseToggled and CustomClauseAdded are no-ops', () async {
      final scripted = _repositoryWith({
        'GET /love-contracts/my-pending': _fixed(
          () async => _jsonResponse(_partnerContractJson),
        ),
      });
      final bloc = LoveContractBloc(
        repository: scripted.repository,
        partnerDisplayName: () => null,
      );
      addTearDown(bloc.close);

      bloc.add(const LoveContractOpened());
      await expectLater(bloc.stream, emitsThrough(isA<LoveContractReady>()));
      final before = bloc.state as LoveContractReady;
      expect(before.canEditClauses, isFalse);

      bloc.add(const ClauseToggled('preset-honesty'));
      bloc.add(const CustomClauseAdded('Be kind'));
      await pumpEventQueue();

      expect(bloc.state, before);
    });

    test('a viewer who already signed cannot re-sign (canSign false)', () async {
      final scripted = _repositoryWith({
        'GET /love-contracts/my-pending': _fixed(
          () async => _jsonResponse(_signedContractJson),
        ),
      });
      final bloc = LoveContractBloc(
        repository: scripted.repository,
        partnerDisplayName: () => null,
      );
      addTearDown(bloc.close);

      bloc.add(const LoveContractOpened());
      await expectLater(bloc.stream, emitsThrough(isA<LoveContractReady>()));

      final state = bloc.state as LoveContractReady;
      expect(state.signStatus, ContractSignStatus.signedByMe);
      expect(state.canSign, isFalse);

      bloc.add(const SignHoldStarted());
      bloc.add(const SignHoldCompleted());
      await pumpEventQueue();

      expect(scripted.adapter.calls, ['GET /love-contracts/my-pending']);
    });
  });
}
