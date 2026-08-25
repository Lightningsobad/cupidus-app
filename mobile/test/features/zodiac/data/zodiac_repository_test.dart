import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/icons/cupid_zodiac_icon.dart';
import 'package:cupid_mobile/features/zodiac/data/zodiac_repository.dart';
import 'package:cupid_mobile/features/zodiac/domain/zodiac_red_flag.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fixtures copied verbatim from `architecture/contract-summary.md` §1.
Map<String, dynamic> readyBody() => <String, dynamic>{
  'status': 'ready',
  'contentDate': '2026-08-25',
  'conflictIndex': <String, dynamic>{
    'score': 7,
    'scoreMax': 10,
    'headline': 'Ngày của những va chạm nhỏ',
    'body': 'Cự Giải cần được trấn an, Song Ngư lại đang trôi trong suy nghĩ.',
  },
  'partners': <dynamic>[
    <String, dynamic>{
      'role': 'self',
      'displayName': 'Minh',
      'zodiacSign': 'cancer',
    },
    <String, dynamic>{
      'role': 'partner',
      'displayName': 'Linh',
      'zodiacSign': 'pisces',
    },
  ],
  'dailyTips': <dynamic>[
    <String, dynamic>{
      'id': 'tip-04',
      'icon': 'videocam',
      'tint': 'mint',
      'title': 'Gọi video 10 phút',
      'body': 'Nghe giọng nhau trước khi nhắn tin.',
    },
    <String, dynamic>{
      'id': 'tip-09',
      'icon': 'block',
      'tint': 'pink',
      'title': 'Đừng nhắc chuyện cũ',
      'body': 'Hôm nay không phải ngày để tổng kết.',
    },
    <String, dynamic>{
      'id': 'tip-02',
      'icon': 'local_cafe',
      'tint': 'amber',
      'title': 'Rủ nhau cà phê',
      'body': 'Đổi không gian để đổi tâm trạng.',
    },
  ],
};

Map<String, dynamic> incompleteBody() => <String, dynamic>{
  'status': 'incomplete_profile',
  'contentDate': '2026-08-25',
  'missing': <dynamic>['partner_zodiac'],
};

class _StubInterceptor extends Interceptor {
  _StubInterceptor(this._respond);

  final void Function(RequestOptions, RequestInterceptorHandler) _respond;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _respond(options, handler);
  }
}

CupidApi _apiReturning(Object? data, {List<String>? paths}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://zodiac.test'));
  dio.interceptors.add(
    _StubInterceptor((options, handler) {
      paths?.add(options.path);
      handler.resolve(
        Response(requestOptions: options, data: data, statusCode: 200),
      );
    }),
  );
  return CupidApi(dio: dio, interceptors: const []);
}

CupidApi _apiFailingWith(CupidApiFailure? error) {
  final dio = Dio(BaseOptions(baseUrl: 'https://zodiac.test'));
  dio.interceptors.add(
    _StubInterceptor((options, handler) {
      handler.reject(DioException(requestOptions: options, error: error));
    }),
  );
  return CupidApi(dio: dio, interceptors: const []);
}

void main() {
  group('parseZodiacRedFlagToday ready', () {
    test('yields 2 partners with partners[0].role == self', () {
      final parsed = parseZodiacRedFlagToday(readyBody());

      final ready = parsed as ZodiacRedFlagReady;
      expect(ready.contentDate, '2026-08-25');
      expect(ready.partners, hasLength(2));
      expect(ready.partners[0].role, ZodiacPartnerRole.self);
      expect(ready.partners[0].sign, CupidZodiacSign.cancer);
      expect(ready.partners[1].role, ZodiacPartnerRole.partner);
      expect(ready.partners[1].sign, CupidZodiacSign.pisces);
    });

    test('yields 3 tips in wire order', () {
      final ready = parseZodiacRedFlagToday(readyBody()) as ZodiacRedFlagReady;

      expect(
        ready.dailyTips.map((tip) => tip.id).toList(),
        <String>['tip-04', 'tip-09', 'tip-02'],
      );
      expect(ready.dailyTips[2].icon, ZodiacTipIcon.localCafe);
      expect(ready.dailyTips[2].tint, ZodiacTipTint.amber);
    });

    test('derives the bar fraction from score/scoreMax', () {
      final ready = parseZodiacRedFlagToday(readyBody()) as ZodiacRedFlagReady;

      expect(ready.conflictIndex.score, 7);
      expect(ready.conflictIndex.scoreMax, 10);
      expect(ready.conflictIndex.fillFraction, closeTo(0.7, 1e-9));
    });

    test('falls back to the sign viLabel when displayName is null', () {
      final body = readyBody();
      (body['partners'] as List)[1]['displayName'] = null;

      final ready = parseZodiacRedFlagToday(body) as ZodiacRedFlagReady;

      expect(ready.partners[1].label, CupidZodiacSign.pisces.viLabel);
    });
  });

  group('parseZodiacRedFlagToday incomplete_profile', () {
    test('yields the incomplete-profile variant with no content', () {
      final parsed = parseZodiacRedFlagToday(incompleteBody());

      final incomplete = parsed as ZodiacRedFlagIncompleteProfile;
      expect(incomplete.contentDate, '2026-08-25');
      expect(incomplete.missing, <String>['partner_zodiac']);
    });

    test('maps an unknown status to incomplete_profile, never ready', () {
      final body = readyBody()..['status'] = 'ready_v2';

      final parsed = parseZodiacRedFlagToday(body);

      expect(parsed, isA<ZodiacRedFlagIncompleteProfile>());
      expect((parsed as ZodiacRedFlagIncompleteProfile).missing, isEmpty);
    });
  });

  group('parseZodiacRedFlagToday fallbacks', () {
    test('an unknown tint resolves to neutral without throwing', () {
      final body = readyBody();
      (body['dailyTips'] as List)[0]['tint'] = 'chartreuse';

      final ready = parseZodiacRedFlagToday(body) as ZodiacRedFlagReady;

      expect(ready.dailyTips[0].tint, ZodiacTipTint.neutral);
    });

    test('an unknown icon resolves to favorite without throwing', () {
      final body = readyBody();
      (body['dailyTips'] as List)[0]['icon'] = 'rocket_launch';

      final ready = parseZodiacRedFlagToday(body) as ZodiacRedFlagReady;

      expect(ready.dailyTips[0].icon, ZodiacTipIcon.favorite);
    });
  });

  group('parseZodiacRedFlagToday contract violations', () {
    test('a ready body missing a required key throws, no substituted default', () {
      final body = readyBody();
      (body['conflictIndex'] as Map).remove('scoreMax');

      expect(
        () => parseZodiacRedFlagToday(body),
        throwsA(isA<UnexpectedFailure>()),
      );
    });

    test('a ready body missing dailyTips throws', () {
      final body = readyBody()..remove('dailyTips');

      expect(
        () => parseZodiacRedFlagToday(body),
        throwsA(isA<UnexpectedFailure>()),
      );
    });

    test('an unrecognised zodiacSign in a ready body throws', () {
      final body = readyBody();
      (body['partners'] as List)[0]['zodiacSign'] = 'ophiuchus';

      expect(
        () => parseZodiacRedFlagToday(body),
        throwsA(isA<UnexpectedFailure>()),
      );
    });

    test('a non-object body throws', () {
      expect(
        () => parseZodiacRedFlagToday('nope'),
        throwsA(isA<UnexpectedFailure>()),
      );
    });
  });

  group('ZodiacRepository.fetchToday', () {
    test('calls GET /zodiac/red-flag/today with no query params', () async {
      final paths = <String>[];
      final repository = ZodiacRepository(
        _apiReturning(readyBody(), paths: paths),
      );

      await repository.fetchToday();

      expect(paths, <String>['/zodiac/red-flag/today']);
    });

    test('rethrows the mapped CupidApiFailure from DioException.error', () async {
      final repository = ZodiacRepository(
        _apiFailingWith(const UnauthorizedFailure()),
      );

      expect(
        repository.fetchToday(),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });

    test('falls back to UnexpectedFailure when the error is unmapped', () async {
      final repository = ZodiacRepository(_apiFailingWith(null));

      expect(repository.fetchToday(), throwsA(isA<UnexpectedFailure>()));
    });
  });
}
