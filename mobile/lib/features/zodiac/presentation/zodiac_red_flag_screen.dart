import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/design_system/tokens/cupid_css_angle_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/zodiac_red_flag.dart';
import 'widgets/zodiac_conflict_index_card.dart';
import 'widgets/zodiac_daily_tips_card.dart';
import 'zodiac_cubit.dart';
import 'zodiac_state.dart';

/// `zodiac` screen (`ux/ux-spec.md` §2, §4, §5;
/// `coding-plan/phase-P3-mobile-zodiac-screen-route.md`): the red-flag header
/// card, the conflict-index card and the daily-tip card, plus the honest
/// single-card degraded state that replaces all three.
///
/// [createCubit] defaults to the `getIt`-registered [ZodiacCubit] (P2
/// `service_locator.dart`); tests and the preview harness supply a
/// fixture-backed instance instead, mirroring `VibeScreen`'s precedent.
class ZodiacRedFlagScreen extends StatelessWidget {
  const ZodiacRedFlagScreen({super.key, this._createCubit});

  /// Published for STORY-002's Home quick-grid entry
  /// (`coding-plan/phase-P3-mobile-zodiac-screen-route.md` §1B).
  static const String routeName = '/zodiac/red-flag';

  final ZodiacCubit Function()? _createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ZodiacCubit>(
      create: (_) => (_createCubit ?? () => getIt<ZodiacCubit>())()..load(),
      child: const _ZodiacRedFlagView(),
    );
  }
}

/// Screen chrome title, `t_zodiac` in the design source's locale maps — the
/// same literal in `vi` and `en`.
const String _screenTitle = 'Zodiac Red Flag';

/// Design-source geometry with no token equivalent (`Cupid Screens.dc.html`
/// L602-633): screen padding `8px 16px 40px`, a `13px` gap between cards,
/// header-card padding `22px 20px`, its `110px` decorative glyph offset
/// `-10px` past the top-right corner at `.2` opacity, a `9px` eyebrow gap,
/// `12px`/`9px` gaps under the eyebrow and headline, and a centered `11px`
/// disclaimer inside `0 20px` padding.
const double _screenTopPadding = 8;
const double _screenBottomPadding = 40;
const double _cardGap = 13;
const double _headerCardHorizontalPadding = 20;
const double _headerCardVerticalPadding = 22;
const double _headerBorderOpacity = 0.4;
const double _decorGlyphSize = 110;
const double _decorGlyphInset = -10;
const double _decorGlyphOpacity = 0.2;
const double _eyebrowIconSize = 18;
const double _eyebrowGap = 9;
const double _eyebrowSize = 10;
const double _eyebrowLetterSpacing = 1.6;
const double _headlineTopGap = 12;
const double _headlineSize = 23;
const double _headlineHeight = 1.3;
const double _headerBodyTopGap = 9;
const double _headerBodySize = 13;
const double _headerBodyHeight = 1.6;
const double _disclaimerHorizontalPadding = 20;
const double _disclaimerSize = 11;
const double _disclaimerHeight = 1.5;
const double _degradedIconSize = 48;

/// Skeleton block heights approximating the three card shapes (`ux/ux-spec.md`
/// §2d), following `TimelineSkeletonCard`'s recipe: a `colorSurfaceAlt` box at
/// `radiusCard`, no shimmer animation (an unbounded repeating animation makes
/// `pumpAndSettle` in widget tests time out).
const List<double> _skeletonCardHeights = <double>[168, 148, 196];

/// The header card's `linear-gradient(155deg, ...)` direction vector, derived
/// like `cupid_color_tokens.dart`'s own pairs: `sin(155deg) = 0.4226182617407`,
/// `cos(155deg) = -0.9063077870366`. It goes through [CupidCssAngleGradient]
/// for the same reason those do — a plain [LinearGradient] renders a declared
/// CSS angle box-normalized rather than geometric.
const Alignment _gradient155Begin = Alignment(
  -0.4226182617406994,
  -0.9063077870366499,
);
const Alignment _gradient155End = Alignment(
  0.4226182617406994,
  0.9063077870366499,
);
const double _headerGradientPurpleOpacity = 0.34;
const double _headerGradientPinkOpacity = 0.16;

/// `auto_awesome` 0xe65f, `warning` 0xe002 and `info` 0xe88e, confirmed in the
/// bundled `MaterialSymbolsRounded-Variable.ttf` cmap. Declared here rather
/// than in [CupidIcons] because `design_system/icons/cupid_icons.dart` is
/// outside this phase's write scope.
const IconData _autoAwesomeIcon = IconData(
  0xe65f,
  fontFamily: CupidIcons.fontFamily,
);
const IconData _warningIcon = IconData(
  0xe002,
  fontFamily: CupidIcons.fontFamily,
);
const IconData _infoIcon = IconData(0xe88e, fontFamily: CupidIcons.fontFamily);

class _ZodiacRedFlagView extends StatelessWidget {
  const _ZodiacRedFlagView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupidHeader(
        title: _screenTitle,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: BlocBuilder<ZodiacCubit, ZodiacState>(
        builder: (BuildContext context, ZodiacState state) => switch (state) {
          ZodiacLoading() => const _ZodiacSkeleton(),
          ZodiacReady(:final ZodiacRedFlagReady today) => _ZodiacContent(
            today: today,
          ),
          // `architecture/contract-summary.md` §6: the degraded card replaces
          // the three content cards, it does not render beside them.
          ZodiacIncompleteProfile() => const _ZodiacIncompleteProfileState(),
          ZodiacError(:final CupidApiFailure failure) => _ZodiacErrorState(
            failure: failure,
          ),
        },
      ),
    );
  }
}

class _ZodiacContent extends StatelessWidget {
  const _ZodiacContent({required this.today});

  final ZodiacRedFlagReady today;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        CupidSpacing.md,
        _screenTopPadding,
        CupidSpacing.md,
        _screenBottomPadding,
      ),
      children: <Widget>[
        _ZodiacHeaderCard(
          contentDate: today.contentDate,
          conflictIndex: today.conflictIndex,
        ),
        const SizedBox(height: _cardGap),
        ZodiacConflictIndexCard(
          conflictIndex: today.conflictIndex,
          partners: today.partners,
        ),
        const SizedBox(height: _cardGap),
        ZodiacDailyTipsCard(tips: today.dailyTips),
        const SizedBox(height: _cardGap),
        const _ZodiacDisclaimer(),
      ],
    );
  }
}

/// Card 1 (`Cupid Screens.dc.html` L603-611). The eyebrow date is
/// [ZodiacRedFlagToday.contentDate], the server's own calendar day — never
/// `DateTime.now()` (`architecture/contract-summary.md` §3 row 1).
class _ZodiacHeaderCard extends StatelessWidget {
  const _ZodiacHeaderCard({
    required this.contentDate,
    required this.conflictIndex,
  });

  final String contentDate;
  final ZodiacConflictIndex conflictIndex;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: CupidCssAngleGradient(
          begin: _gradient155Begin,
          end: _gradient155End,
          colors: <Color>[
            colors.colorAccentPurple.withValues(
              alpha: _headerGradientPurpleOpacity,
            ),
            colors.colorAccentPink.withValues(
              alpha: _headerGradientPinkOpacity,
            ),
          ],
        ),
        border: Border.all(
          color: colors.colorAccentPurple.withValues(
            alpha: _headerBorderOpacity,
          ),
        ),
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: _decorGlyphInset,
            right: _decorGlyphInset,
            child: ExcludeSemantics(
              child: Opacity(
                opacity: _decorGlyphOpacity,
                child: CupidIcon(
                  _autoAwesomeIcon,
                  size: _decorGlyphSize,
                  color: colors.colorAccentPurple,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _headerCardHorizontalPadding,
              vertical: _headerCardVerticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    ExcludeSemantics(
                      child: CupidIcon(
                        _warningIcon,
                        size: _eyebrowIconSize,
                        color: colors.colorButter,
                      ),
                    ),
                    const SizedBox(width: _eyebrowGap),
                    Flexible(
                      child: Text(
                        _eyebrowLabel(context, contentDate),
                        style: type.labelMono.copyWith(
                          fontSize: _eyebrowSize,
                          letterSpacing: _eyebrowLetterSpacing,
                          color: colors.colorButter,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: _headlineTopGap),
                Semantics(
                  header: true,
                  child: Text(
                    conflictIndex.headline,
                    style: type.display.copyWith(
                      fontSize: _headlineSize,
                      height: _headlineHeight,
                      color: colors.colorText,
                    ),
                  ),
                ),
                const SizedBox(height: _headerBodyTopGap),
                Text(
                  conflictIndex.body,
                  style: type.body.copyWith(
                    fontSize: _headerBodySize,
                    height: _headerBodyHeight,
                    color: colors.colorTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZodiacDisclaimer extends StatelessWidget {
  const _ZodiacDisclaimer();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _disclaimerHorizontalPadding,
      ),
      child: Text(
        _viEn(
          context,
          'Đây là tính năng cho vui. Cupid không chịu trách nhiệm nếu bạn '
              'thật sự tin vào cung hoàng đạo 🔮',
          'This is for fun. Cupid takes no responsibility if you actually '
              'believe it 🔮',
        ),
        textAlign: TextAlign.center,
        style: context.cupidType.caption.copyWith(
          fontSize: _disclaimerSize,
          height: _disclaimerHeight,
          color: colors.colorTextMuted,
        ),
      ),
    );
  }
}

/// State 2c (`ux/ux-spec.md` §2c): one neutral card, no partner named, and
/// none of Card 1/2/3 mounted. Not an error state — the wording is honest
/// about missing profile data, not alarming.
class _ZodiacIncompleteProfileState extends StatelessWidget {
  const _ZodiacIncompleteProfileState();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return _CenteredCard(
      children: <Widget>[
        ExcludeSemantics(
          child: CupidIcon(
            _infoIcon,
            size: _degradedIconSize,
            color: colors.colorTextMuted,
          ),
        ),
        SizedBox(height: CupidSpacing.md),
        Semantics(
          header: true,
          child: Text(
            _viEn(
              context,
              'Chưa đủ thông tin cung hoàng đạo',
              'Zodiac details are incomplete',
            ),
            textAlign: TextAlign.center,
            style: context.cupidType.cardTitle.copyWith(
              color: colors.colorText,
            ),
          ),
        ),
        SizedBox(height: CupidSpacing.sm),
        Text(
          _viEn(
            context,
            'Cả hai người cần điền ngày sinh trong hồ sơ để Cupid đọc được '
                'chỉ số hôm nay.',
            'Both of you need a birthday on your profile before Cupid can '
                'read today’s index.',
          ),
          textAlign: TextAlign.center,
          style: context.cupidType.body.copyWith(color: colors.colorTextMuted),
        ),
      ],
    );
  }
}

/// The app's generic error/retry pattern (`ux/ux-spec.md` §2d), mirroring
/// `pet_screen.dart`'s `_FailureState`.
class _ZodiacErrorState extends StatelessWidget {
  const _ZodiacErrorState({required this.failure});

  final CupidApiFailure failure;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return _CenteredCard(
      children: <Widget>[
        Text(
          _zodiacFailureMessage(context, failure),
          textAlign: TextAlign.center,
          style: context.cupidType.body.copyWith(color: colors.colorText),
        ),
        SizedBox(height: CupidSpacing.md),
        CupidPrimaryButton(
          label: _viEn(context, 'Thử lại', 'Try again'),
          onPressed: () => context.read<ZodiacCubit>().load(),
        ),
      ],
    );
  }
}

/// The shared surface/shadow/radius card the 2c and error states both sit in,
/// vertically centered in the content area below the app bar and still
/// scrollable when the copy outgrows a short viewport.
class _CenteredCard extends StatelessWidget {
  const _CenteredCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(CupidSpacing.md),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - CupidSpacing.md * 2,
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(CupidSpacing.lg),
                decoration: BoxDecoration(
                  color: colors.colorSurface,
                  borderRadius: BorderRadius.circular(
                    platformTokens.radiusCard,
                  ),
                  boxShadow: platformTokens.elevationShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ZodiacSkeleton extends StatelessWidget {
  const _ZodiacSkeleton();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return ExcludeSemantics(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          CupidSpacing.md,
          _screenTopPadding,
          CupidSpacing.md,
          _screenBottomPadding,
        ),
        children: <Widget>[
          for (final double height in _skeletonCardHeights) ...<Widget>[
            Container(
              height: height,
              decoration: BoxDecoration(
                color: colors.colorSurfaceAlt,
                borderRadius: BorderRadius.circular(platformTokens.radiusCard),
              ),
            ),
            const SizedBox(height: _cardGap),
          ],
        ],
      ),
    );
  }
}

/// "RED FLAG · DD/MM" from the server's `YYYY-MM-DD` calendar day. The design's
/// literal `29/07` is fixture text and is not reproduced.
String _eyebrowLabel(BuildContext context, String contentDate) {
  final List<String> parts = contentDate.split('-');
  final String day = parts.length == 3 ? '${parts[2]}/${parts[1]}' : contentDate;
  return _viEn(context, 'Red flag · $day', 'Red flag · $day').toUpperCase();
}

/// Maps the closed [CupidApiFailure] set to one short user-facing line, the
/// same convention as `pet_screen.dart`'s `_petFailureMessage`. Kept local
/// because no `zodiac_strings.dart` exists in this phase's write scope.
String _zodiacFailureMessage(BuildContext context, CupidApiFailure failure) {
  return switch (failure) {
    NetworkUnavailableFailure() => _viEn(
      context,
      'Không có kết nối mạng',
      'No internet connection',
    ),
    TimeoutFailure() => _viEn(
      context,
      'Kết nối quá chậm, vui lòng thử lại',
      'Connection timed out, please try again',
    ),
    UnauthorizedFailure() => _viEn(
      context,
      'Phiên đăng nhập đã hết hạn',
      'Your session has expired',
    ),
    HttpStatusFailure() || UnexpectedFailure() => _viEn(
      context,
      'Đã có lỗi xảy ra. Vui lòng thử lại.',
      'Something went wrong. Please try again.',
    ),
  };
}

/// Locale pick for this file's static labels. `zodiac_strings.dart` does not
/// exist and is outside this phase's write scope, so the mapping stays local.
String _viEn(BuildContext context, String vi, String en) =>
    Localizations.localeOf(context).languageCode == 'vi' ? vi : en;
