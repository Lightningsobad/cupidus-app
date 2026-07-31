import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/vibes/data/vibes_repository.dart';
import 'package:cupid_mobile/features/vibes/domain/vibe_entry.dart';
import 'package:cupid_mobile/features/vibes/domain/vibe_mood.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// A captured outbound request, recorded by [_apiReturning] so tests can
/// assert on the path/query/body `VibesRepository` sent.
class _Call {
  _Call(this.path, this.queryParameters, this.data);

  final String path;
  final Map<String, dynamic> queryParameters;
  final Object? data;
}

/// Resolves or rejects every request without touching the network, isolating
/// `VibesRepository`'s parsing/rethrow logic from the shared interceptor
/// pipeline (covered by its own tests).
class _StubInterceptor extends Interceptor {
  _StubInterceptor(this._respond);

  final void Function(
    RequestOptions options,
    RequestInterceptorHandler handler,
  )
  _respond;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _respond(options, handler);
  }
}

CupidApi _apiReturning(Object? data, {List<_Call>? calls}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://vibes.test'));
  dio.interceptors.add(
    _StubInterceptor((options, handler) {
      calls?.add(_Call(options.path, options.queryParameters, options.data));
      handler.resolve(
        Response(requestOptions: options, data: data, statusCode: 200),
      );
    }),
  );
  return CupidApi(dio: dio, interceptors: const []);
}

CupidApi _apiFailingWith(CupidApiFailure? error) {
  final dio = Dio(BaseOptions(baseUrl: 'https://vibes.test'));
  dio.interceptors.add(
    _StubInterceptor((options, handler) {
      handler.reject(DioException(requestOptions: options, error: error));
    }),
  );
  return CupidApi(dio: dio, interceptors: const []);
}

void main() {
  group('VibesRepository.fetchMyToday', () {
    test('parses a present check-in', () async {
      final repository = VibesRepository(
        _apiReturning({
          'id': 'v1',
          'mood': 'horny',
          'note': 'feeling good',
          'createdAt': '2026-07-30T08:00:00.000Z',
        }),
      );

      final entry = await repository.fetchMyToday();

      expect(entry, isNotNull);
      expect(entry!.id, 'v1');
      expect(entry.mood, VibeMood.horny);
      expect(entry.note, 'feeling good');
      expect(entry.createdAt, DateTime.parse('2026-07-30T08:00:00.000Z'));
    });

    test('returns null for a null body', () async {
      final repository = VibesRepository(_apiReturning(null));
      expect(await repository.fetchMyToday(), isNull);
    });

    test('returns null for an empty string body', () async {
      final repository = VibesRepository(_apiReturning(''));
      expect(await repository.fetchMyToday(), isNull);
    });

    test('returns null for an empty map body', () async {
      final repository = VibesRepository(_apiReturning(<String, dynamic>{}));
      expect(await repository.fetchMyToday(), isNull);
    });

    test('skips an entry with an unknown mood instead of throwing', () async {
      final repository = VibesRepository(
        _apiReturning({
          'id': 'v1',
          'mood': 'soft',
          'createdAt': '2026-07-30T08:00:00.000Z',
        }),
      );

      expect(await repository.fetchMyToday(), isNull);
    });
  });

  group('VibesRepository.fetchMyHistory', () {
    test('requests days=8 and skips unknown-mood entries', () async {
      final calls = <_Call>[];
      final repository = VibesRepository(
        _apiReturning([
          {'id': '1', 'mood': 'happy', 'createdAt': '2026-07-29T10:00:00Z'},
          {'id': '2', 'mood': 'soft', 'createdAt': '2026-07-28T10:00:00Z'},
        ], calls: calls),
      );

      final entries = await repository.fetchMyHistory();

      expect(entries.map((e) => e.id), ['1']);
      expect(calls.single.path, '/vibes/history');
      expect(calls.single.queryParameters['days'], 8);
    });
  });

  group('VibesRepository.fetchPartnerHistory', () {
    test('returns an empty list, not an error, when unpaired', () async {
      final calls = <_Call>[];
      final repository = VibesRepository(
        _apiReturning(<Object?>[], calls: calls),
      );

      expect(await repository.fetchPartnerHistory(), isEmpty);
      expect(calls.single.path, '/vibes/partner');
      expect(calls.single.queryParameters['days'], 8);
    });
  });

  group('VibesRepository.submitMood', () {
    test('posts the wire mood value with no note key', () async {
      final calls = <_Call>[];
      final repository = VibesRepository(_apiReturning(null, calls: calls));

      await repository.submitMood(VibeMood.horny);

      expect(calls.single.path, '/vibes');
      final body = calls.single.data as Map<String, dynamic>;
      expect(body, {'mood': 'horny'});
      expect(body.containsKey('note'), isFalse);
    });
  });

  group('VibesRepository failure mapping', () {
    test('rethrows the mapped CupidApiFailure for every method', () async {
      final repository = VibesRepository(
        _apiFailingWith(const NetworkUnavailableFailure()),
      );

      final calls = <Future<Object?> Function()>[
        repository.fetchMyToday,
        repository.fetchMyHistory,
        repository.fetchPartnerHistory,
        () => repository.submitMood(VibeMood.happy),
      ];

      for (final call in calls) {
        await expectLater(call(), throwsA(isA<NetworkUnavailableFailure>()));
      }
    });

    test('falls back to UnexpectedFailure when DioException.error is unset', () async {
      final repository = VibesRepository(_apiFailingWith(null));

      await expectLater(
        repository.submitMood(VibeMood.happy),
        throwsA(isA<UnexpectedFailure>()),
      );
    });
  });

  group('bucketByLocalDay', () {
    VibeEntry entry(String id, DateTime createdAt, VibeMood mood) =>
        VibeEntry(id: id, mood: mood, createdAt: createdAt);

    test(
      'produces 7 oldest->newest slots, newest wins per day, tolerates an 8th day',
      () {
        final now = DateTime(2026, 7, 30, 9);
        final entriesDescending = [
          entry('today-newer', DateTime(2026, 7, 30, 20), VibeMood.happy),
          entry('today-older', DateTime(2026, 7, 30, 8), VibeMood.sad),
          entry('minus-2', DateTime(2026, 7, 28, 12), VibeMood.angry),
          entry('minus-8', DateTime(2026, 7, 22, 12), VibeMood.tired),
        ];

        final buckets = bucketByLocalDay(entriesDescending, now: now);

        expect(buckets, hasLength(7));
        expect(buckets.last?.id, 'today-newer');
        expect(buckets[4]?.id, 'minus-2');
        expect(buckets.first, isNull);
        expect(buckets.any((e) => e?.id == 'minus-8'), isFalse);
      },
    );

    test('renders null for every slot when there are no entries', () {
      final now = DateTime(2026, 7, 30, 9);
      final buckets = bucketByLocalDay(const [], now: now);
      expect(buckets, List<VibeEntry?>.filled(7, null));
    });
  });
}
