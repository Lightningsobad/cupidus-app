import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/icons/cupid_zodiac_icon.dart';
import 'package:cupid_mobile/features/zodiac/data/zodiac_repository.dart';
import 'package:cupid_mobile/features/zodiac/domain/zodiac_red_flag.dart';
import 'package:cupid_mobile/features/zodiac/presentation/zodiac_cubit.dart';
import 'package:cupid_mobile/features/zodiac/presentation/zodiac_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// `ZodiacRepository` has no interface (the concrete class is the shared
/// contract), so this subclasses it and overrides the one method, matching the
/// `_FakeVibesRepository` precedent. No mocking package is added: none is a
/// `pubspec.yaml` dependency and this phase's write scope excludes it. The
/// wrapped `CupidApi` is never exercised.
class _FakeZodiacRepository extends ZodiacRepository {
  _FakeZodiacRepository() : super(CupidApi(dio: Dio(), interceptors: const []));

  Future<ZodiacRedFlagToday> Function() loader = () async => _ready;

  @override
  Future<ZodiacRedFlagToday> fetchToday() => loader();
}

const _ready = ZodiacRedFlagReady(
  contentDate: '2026-08-25',
  conflictIndex: ZodiacConflictIndex(
    score: 7,
    scoreMax: 10,
    headline: 'Ngày của những va chạm nhỏ',
    body: 'Cự Giải cần được trấn an.',
  ),
  partners: <ZodiacPartner>[
    ZodiacPartner(
      role: ZodiacPartnerRole.self,
      displayName: 'Minh',
      sign: CupidZodiacSign.cancer,
    ),
    ZodiacPartner(
      role: ZodiacPartnerRole.partner,
      displayName: 'Linh',
      sign: CupidZodiacSign.pisces,
    ),
  ],
  dailyTips: <ZodiacDailyTip>[
    ZodiacDailyTip(
      id: 'tip-04',
      icon: ZodiacTipIcon.videocam,
      tint: ZodiacTipTint.mint,
      title: 'Gọi video 10 phút',
      body: 'Nghe giọng nhau trước khi nhắn tin.',
    ),
  ],
);

const _incomplete = ZodiacRedFlagIncompleteProfile(
  contentDate: '2026-08-25',
  missing: <String>['partner_zodiac'],
);

void main() {
  group('ZodiacCubit.load', () {
    test('starts in ZodiacLoading', () {
      final cubit = ZodiacCubit(repository: _FakeZodiacRepository());

      expect(cubit.state, isA<ZodiacLoading>());
    });

    test('emits ZodiacReady for a ready payload', () async {
      final repository = _FakeZodiacRepository()..loader = () async => _ready;
      final cubit = ZodiacCubit(repository: repository);

      await cubit.load();

      final state = cubit.state as ZodiacReady;
      expect(state.today.contentDate, '2026-08-25');
      expect(state.today.partners, hasLength(2));
    });

    test('emits ZodiacIncompleteProfile, not ZodiacError, when degraded', () async {
      final repository = _FakeZodiacRepository()
        ..loader = () async => _incomplete;
      final cubit = ZodiacCubit(repository: repository);

      await cubit.load();

      expect(cubit.state, isA<ZodiacIncompleteProfile>());
      expect(
        (cubit.state as ZodiacIncompleteProfile).today.missing,
        <String>['partner_zodiac'],
      );
    });

    test('emits ZodiacError carrying the CupidApiFailure', () async {
      final repository = _FakeZodiacRepository()
        ..loader = () async => throw const TimeoutFailure();
      final cubit = ZodiacCubit(repository: repository);

      await cubit.load();

      expect((cubit.state as ZodiacError).failure, isA<TimeoutFailure>());
    });

    test('a retry from the error state passes back through loading', () async {
      final repository = _FakeZodiacRepository()
        ..loader = () async => throw const TimeoutFailure();
      final cubit = ZodiacCubit(repository: repository);
      await cubit.load();

      final emitted = expectLater(
        cubit.stream,
        emitsInOrder(<Matcher>[isA<ZodiacLoading>(), isA<ZodiacReady>()]),
      );
      repository.loader = () async => _ready;
      await cubit.load();

      await emitted;
    });
  });
}
