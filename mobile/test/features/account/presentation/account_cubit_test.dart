import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/features/account/data/account_repository.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:cupid_mobile/features/account/presentation/account_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Handler = ResponseBody Function(RequestOptions options, String? body);

/// Mirrors `test/features/account/data/account_repository_test.dart`'s fake
/// transport — a hand-written fake below the shared `Dio` pipeline, no
/// bloc_test/mocktail (F3).
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final _Handler handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => handler(options, null);

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(Map<String, dynamic> json, {int statusCode = 200}) {
  return ResponseBody.fromBytes(
    utf8.encode(jsonEncode(json)),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Map<String, dynamic> _profileJson({String displayName = 'Alex'}) => {
  'id': 'user-1',
  'email': 'alex@example.com',
  'displayName': displayName,
  'photoUrl': null,
  'birthday': '1996-05-15',
  'relationshipStartDate': null,
  'zodiacSign': 'Taurus',
  'language': 'vi',
  'partnerId': null,
  'coupleType': null,
  'vowTaken': false,
  'isGhostModeEnabled': true,
};

AccountRepository _repository(_Handler handler) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
  dio.httpClientAdapter = _FakeAdapter(handler);
  dio.interceptors.add(const CupidErrorInterceptor());
  return AccountRepository(api: CupidApi(dio: dio, interceptors: const []));
}

void main() {
  group('AccountCubit', () {
    test('emits loading then loaded on a successful fetch', () async {
      final cubit = AccountCubit(
        repository: _repository((options, body) => _jsonBody(_profileJson())),
      );
      addTearDown(cubit.close);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder(<Matcher>[isA<AccountLoaded>()]),
      );

      await expectation;
      expect(cubit.state, isA<AccountLoaded>());
      expect(
        (cubit.state as AccountLoaded).profile.displayName,
        'Alex',
      );
    });

    test('emits failed when the fetch throws', () async {
      final cubit = AccountCubit(
        repository: _repository(
          (options, body) => _jsonBody({'message': 'boom'}, statusCode: 500),
        ),
      );
      addTearDown(cubit.close);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder(<Matcher>[isA<AccountFailed>()]),
      );

      await expectation;
      expect(cubit.state, isA<AccountFailed>());
    });

    test('load() re-fetches and re-emits loading then loaded', () async {
      var callCount = 0;
      final cubit = AccountCubit(
        repository: _repository((options, body) {
          callCount++;
          return _jsonBody(_profileJson());
        }),
      );
      addTearDown(cubit.close);

      await expectLater(cubit.stream, emitsInOrder(<Matcher>[isA<AccountLoaded>()]));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder(<Matcher>[isA<AccountLoading>(), isA<AccountLoaded>()]),
      );
      await cubit.load();
      await expectation;

      expect(callCount, 2);
    });

    test('applyUpdated() emits the given profile without a network call', () async {
      var callCount = 0;
      final cubit = AccountCubit(
        repository: _repository((options, body) {
          callCount++;
          return _jsonBody(_profileJson());
        }),
      );
      addTearDown(cubit.close);

      await expectLater(cubit.stream, emitsInOrder(<Matcher>[isA<AccountLoaded>()]));

      const CupidProfile updated = CupidProfile(
        id: 'user-1',
        email: 'alex@example.com',
        language: 'vi',
        vowTaken: false,
        isGhostModeEnabled: true,
        displayName: 'Alexandra',
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder(<Matcher>[isA<AccountLoaded>()]),
      );
      cubit.applyUpdated(updated);
      await expectation;

      expect((cubit.state as AccountLoaded).profile.displayName, 'Alexandra');
      expect(callCount, 1);
    });
  });
}
