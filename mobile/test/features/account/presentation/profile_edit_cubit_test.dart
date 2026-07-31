import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/network/cupid_error_interceptor.dart';
import 'package:cupid_mobile/features/account/data/account_repository.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:cupid_mobile/features/account/presentation/profile_edit_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Handler = ResponseBody Function(RequestOptions options, String? body);

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final _Handler handler;
  final List<RequestOptions> requests = [];
  final List<String?> bodies = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    String? body;
    if (requestStream != null) {
      final bytes = await requestStream.expand((chunk) => chunk).toList();
      body = utf8.decode(bytes);
    }
    bodies.add(body);
    return handler(options, body);
  }

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

Map<String, dynamic> _profileJson({
  String? displayName = 'Alex',
  String? birthday = '1996-05-15',
  String? zodiacSign = 'Taurus',
}) => {
  'id': 'user-1',
  'email': 'alex@example.com',
  'displayName': displayName,
  'photoUrl': null,
  'birthday': birthday,
  'relationshipStartDate': null,
  'zodiacSign': zodiacSign,
  'language': 'vi',
  'partnerId': null,
  'coupleType': null,
  'vowTaken': false,
  'isGhostModeEnabled': true,
};

const CupidProfile _initialProfile = CupidProfile(
  id: 'user-1',
  email: 'alex@example.com',
  language: 'vi',
  vowTaken: false,
  isGhostModeEnabled: true,
  displayName: 'Alex',
  birthday: null,
);

_FakeAdapter _adapterFor(_Handler handler) => _FakeAdapter(handler);

AccountRepository _repositoryFor(_FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(const CupidErrorInterceptor());
  return AccountRepository(api: CupidApi(dio: dio, interceptors: const []));
}

void main() {
  group('ProfileEditCubit dirty-gating', () {
    test('isDirty is false for the initial, unedited state', () {
      final adapter = _adapterFor((options, body) => _jsonBody({}));
      final cubit = ProfileEditCubit(
        repository: _repositoryFor(adapter),
        profile: _initialProfile,
      );
      addTearDown(cubit.close);

      expect(cubit.state.isDirty, isFalse);
    });

    test('isDirty becomes true after nameChanged', () {
      final adapter = _adapterFor((options, body) => _jsonBody({}));
      final cubit = ProfileEditCubit(
        repository: _repositoryFor(adapter),
        profile: _initialProfile,
      );
      addTearDown(cubit.close);

      cubit.nameChanged('Alexandra');

      expect(cubit.state.isDirty, isTrue);
    });

    test('isDirty becomes true after birthdayChanged', () {
      final adapter = _adapterFor((options, body) => _jsonBody({}));
      final cubit = ProfileEditCubit(
        repository: _repositoryFor(adapter),
        profile: _initialProfile,
      );
      addTearDown(cubit.close);

      cubit.birthdayChanged(DateTime(1996, 5, 15));

      expect(cubit.state.isDirty, isTrue);
    });

    test('zodiacSign updates live as the birthday changes', () {
      final adapter = _adapterFor((options, body) => _jsonBody({}));
      final cubit = ProfileEditCubit(
        repository: _repositoryFor(adapter),
        profile: _initialProfile,
      );
      addTearDown(cubit.close);

      expect(cubit.state.zodiacSign, isNull);

      cubit.birthdayChanged(DateTime(1996, 5, 15));

      expect(cubit.state.zodiacSign, isNotNull);
    });
  });

  group('ProfileEditCubit validation', () {
    test('submit with an empty name sets showNameError and sends nothing', () async {
      final adapter = _adapterFor((options, body) => _jsonBody({}));
      final cubit = ProfileEditCubit(
        repository: _repositoryFor(adapter),
        profile: _initialProfile,
      );
      addTearDown(cubit.close);

      cubit.nameChanged('');
      cubit.birthdayChanged(DateTime(1996, 5, 15));

      await cubit.submit();

      expect(cubit.state.showNameError, isTrue);
      expect(adapter.requests, isEmpty);
    });

    test('submit with a null birthday sets showDobError and sends nothing', () async {
      final adapter = _adapterFor((options, body) => _jsonBody({}));
      final cubit = ProfileEditCubit(
        repository: _repositoryFor(adapter),
        profile: _initialProfile,
      );
      addTearDown(cubit.close);

      cubit.nameChanged('Alexandra');

      await cubit.submit();

      expect(cubit.state.showDobError, isTrue);
      expect(adapter.requests, isEmpty);
    });

    test('submit is a no-op when validation passes but nothing changed', () async {
      final CupidProfile profile = CupidProfile(
        id: 'user-1',
        email: 'alex@example.com',
        language: 'vi',
        vowTaken: false,
        isGhostModeEnabled: true,
        displayName: 'Alex',
        birthday: DateTime(1996, 5, 15),
      );
      final adapter = _adapterFor((options, body) => _jsonBody({}));
      final cubit = ProfileEditCubit(
        repository: _repositoryFor(adapter),
        profile: profile,
      );
      addTearDown(cubit.close);

      // Re-set both fields back to their initial values: validation passes
      // (name non-empty, birthday set) but isDirty is false, so submit()
      // must return before sending anything.
      cubit.nameChanged('Alex');
      cubit.birthdayChanged(DateTime(1996, 5, 15));

      await cubit.submit();

      expect(adapter.requests, isEmpty);
    });
  });

  group('ProfileEditCubit submit', () {
    test('sends birthday and zodiacSign together when the DOB changed', () async {
      final adapter = _adapterFor((options, body) {
        if (options.method == 'PATCH') return _jsonBody({});
        return _jsonBody(_profileJson());
      });
      final cubit = ProfileEditCubit(
        repository: _repositoryFor(adapter),
        profile: _initialProfile,
      );
      addTearDown(cubit.close);

      cubit.birthdayChanged(DateTime(1996, 5, 15));

      await cubit.submit();

      final RequestOptions patchRequest = adapter.requests.firstWhere(
        (r) => r.method == 'PATCH',
      );
      final Map<String, dynamic> sentBody =
          jsonDecode(adapter.bodies[adapter.requests.indexOf(patchRequest)]!)
              as Map<String, dynamic>;

      expect(sentBody.containsKey('birthday'), isTrue);
      expect(sentBody.containsKey('zodiacSign'), isTrue);
      expect(sentBody.containsKey('displayName'), isFalse);
    });

    test('sends only displayName when just the name changed', () async {
      final adapter = _adapterFor((options, body) {
        if (options.method == 'PATCH') return _jsonBody({});
        return _jsonBody(_profileJson());
      });
      final cubit = ProfileEditCubit(
        repository: _repositoryFor(adapter),
        profile: CupidProfile(
          id: 'user-1',
          email: 'alex@example.com',
          language: 'vi',
          vowTaken: false,
          isGhostModeEnabled: true,
          displayName: 'Alex',
          birthday: DateTime(1996, 5, 15),
        ),
      );
      addTearDown(cubit.close);

      cubit.nameChanged('Alexandra');

      await cubit.submit();

      final RequestOptions patchRequest = adapter.requests.firstWhere(
        (r) => r.method == 'PATCH',
      );
      final Map<String, dynamic> sentBody =
          jsonDecode(adapter.bodies[adapter.requests.indexOf(patchRequest)]!)
              as Map<String, dynamic>;

      expect(sentBody, {'displayName': 'Alexandra'});
    });

    test('on success, emits a fresh state with submittedProfile set', () async {
      final adapter = _adapterFor((options, body) {
        if (options.method == 'PATCH') return _jsonBody({});
        return _jsonBody(_profileJson(displayName: 'Alexandra'));
      });
      final cubit = ProfileEditCubit(
        repository: _repositoryFor(adapter),
        profile: _initialProfile,
      );
      addTearDown(cubit.close);

      cubit.nameChanged('Alexandra');
      cubit.birthdayChanged(DateTime(1996, 5, 15));

      await cubit.submit();

      expect(cubit.state.submittedProfile?.displayName, 'Alexandra');
      expect(cubit.state.isDirty, isFalse);
    });

    test('on failure, sets submitFailure and clears isSubmitting', () async {
      final adapter = _adapterFor(
        (options, body) => _jsonBody({'message': 'boom'}, statusCode: 500),
      );
      final cubit = ProfileEditCubit(
        repository: _repositoryFor(adapter),
        profile: _initialProfile,
      );
      addTearDown(cubit.close);

      cubit.nameChanged('Alexandra');
      cubit.birthdayChanged(DateTime(1996, 5, 15));

      await cubit.submit();

      expect(cubit.state.submitFailure, isNotNull);
      expect(cubit.state.isSubmitting, isFalse);
      expect(cubit.state.submittedProfile, isNull);
    });
  });
}
