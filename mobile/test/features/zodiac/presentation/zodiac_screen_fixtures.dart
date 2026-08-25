import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/zodiac/data/zodiac_repository.dart';
import 'package:cupid_mobile/features/zodiac/domain/zodiac_red_flag.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';

/// The same payload `main_preview.dart`'s `_PreviewZodiacRepository` serves, so
/// the golden, the widget assertions and the device capture all describe one
/// render rather than three similar ones.
const ZodiacRedFlagReady kZodiacReadyFixture = ZodiacRedFlagReady(
  contentDate: '2026-07-29',
  conflictIndex: ZodiacConflictIndex(
    score: 7,
    scoreMax: 10,
    headline: 'Cự Giải và Song Ngư',
    body:
        'Cự Giải (nhạy cảm, giàu cảm xúc) và Song Ngư (mơ mộng, giàu trực '
        'giác) cần thêm thời gian để hiểu nhau, nhưng hoàn toàn có thể '
        'hòa hợp.',
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
      id: 'tip-01',
      icon: ZodiacTipIcon.videocam,
      tint: ZodiacTipTint.mint,
      title: 'Gọi video 10 phút',
      body:
          'Dành 10 phút gọi video để kể cho nhau nghe một chuyện vui '
          'trong ngày.',
    ),
    ZodiacDailyTip(
      id: 'tip-02',
      icon: ZodiacTipIcon.block,
      tint: ZodiacTipTint.pink,
      title: 'Tạm dừng tranh luận',
      body:
          'Nếu thấy giọng điệu căng thẳng, hãy tạm dừng 5 phút trước khi '
          'nói tiếp.',
    ),
    ZodiacDailyTip(
      id: 'tip-03',
      icon: ZodiacTipIcon.localCafe,
      tint: ZodiacTipTint.amber,
      title: 'Hẹn cà phê cuối tuần',
      body: 'Rủ nhau một buổi cà phê không điện thoại vào cuối tuần này.',
    ),
  ],
);

const ZodiacRedFlagIncompleteProfile kZodiacIncompleteFixture =
    ZodiacRedFlagIncompleteProfile(
      contentDate: '2026-07-29',
      missing: <String>['partner_zodiac'],
    );

/// Deliberately unlike the design fixture: a `3/6` pair whose fill is `0.5`,
/// which no `10`-denominator or `70%`-width literal can produce.
const ZodiacRedFlagReady kZodiacOffScaleFixture = ZodiacRedFlagReady(
  contentDate: '2026-01-02',
  conflictIndex: ZodiacConflictIndex(
    score: 3,
    scoreMax: 6,
    headline: 'Bạch Dương và Kim Ngưu',
    body: 'Hai người có nhịp sống khác nhau nhưng vẫn bù trừ được cho nhau.',
  ),
  partners: <ZodiacPartner>[
    // `displayName: null` is the contract's nullable case: the disc must fall
    // back to the sign label, never to a placeholder name.
    ZodiacPartner(
      role: ZodiacPartnerRole.self,
      displayName: null,
      sign: CupidZodiacSign.aries,
    ),
    ZodiacPartner(
      role: ZodiacPartnerRole.partner,
      displayName: null,
      sign: CupidZodiacSign.taurus,
    ),
  ],
  dailyTips: <ZodiacDailyTip>[
    ZodiacDailyTip(
      id: 'tip-04',
      icon: ZodiacTipIcon.nightlight,
      tint: ZodiacTipTint.lilac,
      title: 'Ngủ sớm hơn',
      body: 'Tắt đèn sớm 30 phút và nhắn chúc ngủ ngon.',
    ),
  ],
);

/// No mocking package is added; the suite follows `vibe_screen_test.dart`'s
/// hand-written double precedent.
class FakeZodiacRepository implements ZodiacRepository {
  FakeZodiacRepository.ready([ZodiacRedFlagReady today = kZodiacReadyFixture])
    : _today = today,
      _failure = null;

  FakeZodiacRepository.incomplete()
    : _today = kZodiacIncompleteFixture,
      _failure = null;

  FakeZodiacRepository.failing([
    CupidApiFailure failure = const NetworkUnavailableFailure(),
  ]) : _today = null,
       _failure = failure;

  final ZodiacRedFlagToday? _today;
  final CupidApiFailure? _failure;

  int fetchCount = 0;

  @override
  Future<ZodiacRedFlagToday> fetchToday() async {
    fetchCount++;
    final CupidApiFailure? failure = _failure;
    if (failure != null) throw failure;
    return _today!;
  }
}

/// Dark theme plus the `vi` locale — the pair the visual-fidelity comparison
/// and every assertion in this suite are stated against. [CupidAppBackground]
/// is mounted the same way `CupidApp` mounts it: the screen's scaffold is
/// transparent, so without it the golden would pin a render the device never
/// produces.
Widget zodiacHarness(Widget home) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: buildCupidTheme(
    platform: CupidPlatform.material,
    brightness: Brightness.dark,
  ),
  locale: const Locale('vi'),
  localizationsDelegates: AppL10n.localizationsDelegates,
  supportedLocales: AppL10n.supportedLocales,
  builder: (BuildContext context, Widget? child) =>
      CupidAppBackground(child: child ?? const SizedBox.shrink()),
  home: home,
);
