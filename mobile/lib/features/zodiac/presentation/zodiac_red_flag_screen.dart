import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/design_system/tokens/cupid_css_angle_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../account/data/account_repository.dart';
import '../../account/domain/cupid_profile.dart';
import '../../account/presentation/screens/profile_edit_screen.dart';
import '../../chat/data/chat_repository.dart';
import '../data/zodiac_repository.dart';
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
  const ZodiacRedFlagScreen({
    super.key,
    ZodiacCubit Function()? createCubit,
    this.accountRepository,
    this.zodiacRepository,
    this.chatRepository,
  }) : _createCubit = createCubit;

  /// Published for STORY-002's Home quick-grid entry
  /// (`coding-plan/phase-P3-mobile-zodiac-screen-route.md` §1B).
  static const String routeName = '/zodiac/red-flag';

  final ZodiacCubit Function()? _createCubit;
  final AccountRepository? accountRepository;
  final ZodiacRepository? zodiacRepository;
  final ChatRepository? chatRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ZodiacCubit>(
      create: (_) => (_createCubit ?? () => getIt<ZodiacCubit>())()..load(),
      child: _ZodiacRedFlagView(
        accountRepository: accountRepository,
        zodiacRepository: zodiacRepository,
        chatRepository: chatRepository,
      ),
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
  const _ZodiacRedFlagView({
    this.accountRepository,
    this.zodiacRepository,
    this.chatRepository,
  });

  final AccountRepository? accountRepository;
  final ZodiacRepository? zodiacRepository;
  final ChatRepository? chatRepository;

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
          ZodiacIncompleteProfile(:final ZodiacRedFlagIncompleteProfile today) =>
            _ZodiacIncompleteProfileState(
              today: today,
              accountRepository: accountRepository,
              zodiacRepository: zodiacRepository,
              chatRepository: chatRepository,
            ),
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

/// State 2c (`ux/ux-spec.md` §2c): cute card prompting both users to update
/// their birthdays, with direct CTA to profile edit and partner reminders.
class _ZodiacIncompleteProfileState extends StatefulWidget {
  const _ZodiacIncompleteProfileState({
    required this.today,
    this.accountRepository,
    this.zodiacRepository,
    this.chatRepository,
  });

  final ZodiacRedFlagIncompleteProfile today;
  final AccountRepository? accountRepository;
  final ZodiacRepository? zodiacRepository;
  final ChatRepository? chatRepository;

  @override
  State<_ZodiacIncompleteProfileState> createState() =>
      _ZodiacIncompleteProfileStateState();
}

class _ZodiacIncompleteProfileStateState
    extends State<_ZodiacIncompleteProfileState> {
  bool _isLoading = false;
  bool _isReminding = false;

  Future<void> _navigateToProfileEdit(BuildContext context) async {
    final AccountRepository? repository = widget.accountRepository ??
        (getIt.isRegistered<AccountRepository>()
            ? getIt<AccountRepository>()
            : null);
    if (repository == null) return;

    setState(() => _isLoading = true);
    try {
      final CupidProfile profile = await repository.fetchProfile();
      if (!mounted) return;
      setState(() => _isLoading = false);

      final CupidProfile? updated = await Navigator.of(context).push(
        MaterialPageRoute<CupidProfile>(
          builder: (_) => ProfileEditScreen(
            accountRepository: repository,
            profile: profile,
          ),
        ),
      );

      if (mounted && (updated != null || true)) {
        context.read<ZodiacCubit>().load();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _remindPartner(BuildContext context) async {
    setState(() => _isReminding = true);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    try {
      final ZodiacRepository? repo = widget.zodiacRepository ??
          (getIt.isRegistered<ZodiacRepository>()
              ? getIt<ZodiacRepository>()
              : null);
      if (repo != null) {
        await repo.remindPartner();
      }
    } catch (_) {}

    try {
      final ChatRepository? chatRepo = widget.chatRepository ??
          (getIt.isRegistered<ChatRepository>()
              ? getIt<ChatRepository>()
              : null);
      if (chatRepo != null) {
        await chatRepo.send(
          'Cục cưng ơi! Cập nhật ngày sinh trong Cupid đi nè để tụi mình xem bói cung hoàng đạo và chỉ số hợp nhau nha ✨🔮💕',
        );
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isReminding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viEn(
              context,
              'Đã gửi lời nhắc siêu cute đến người ấy rồi nha! 💌✨',
              'Sent a cute reminder to your partner! 💌✨',
            ),
            style: type.body.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.colorOnAccent,
            ),
          ),
          backgroundColor: colors.colorAccentPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    final bool isPartnerMissingOnly =
        !widget.today.missing.contains('self_zodiac') &&
        widget.today.missing.contains('partner_zodiac');
    final bool isSelfMissingOnly =
        widget.today.missing.contains('self_zodiac') &&
        !widget.today.missing.contains('partner_zodiac');

    final String title = isPartnerMissingOnly
        ? _viEn(
            context,
            'Đang chờ ngày sinh của người ấy nè 🔮',
            'Waiting for partner’s birthday 🔮',
          )
        : _viEn(
            context,
            'Chưa đủ thông tin cung hoàng đạo nè ✨',
            'Zodiac details are incomplete ✨',
          );

    final String body = isPartnerMissingOnly
        ? _viEn(
            context,
            'Bạn đã điền ngày sinh rồi nè ✨ Giờ chỉ cần người ấy cập nhật nữa là Cupid có thể giải mã tình yêu cho hai bạn rồi! 💕',
            'You’ve added your birthday! ✨ Now we just need your partner to add theirs so Cupid can reveal today’s cosmic love index! 💕',
          )
        : isSelfMissingOnly
            ? _viEn(
                context,
                'Người ấy đã cập nhật ngày sinh rồi đó! Giờ chỉ chờ bạn điền ngày sinh nữa là Cupid đọc được chỉ số hôm nay ngay 💕',
                'Your partner has already added their birthday! Now Cupid is just waiting for you to add yours 💕',
              )
            : _viEn(
                context,
                'Hai bạn cần điền ngày sinh trong hồ sơ để Cupid bói vận may và chỉ số tương hợp cho hai bạn nhé! 💕',
                'Both of you need a birthday on your profile before Cupid can read today’s cosmic index & vibe! 💕',
              );

    final Color badgeColor = isPartnerMissingOnly
        ? colors.colorAccentPink
        : colors.colorAccentLilac;

    return _CenteredCard(
      children: <Widget>[
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.16),
            shape: BoxShape.circle,
            border: Border.all(
              color: badgeColor.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: ExcludeSemantics(
            child: CupidIcon(
              isPartnerMissingOnly
                  ? CupidIcons.notificationsActive
                  : _autoAwesomeIcon,
              size: 36,
              color: badgeColor,
            ),
          ),
        ),
        SizedBox(height: CupidSpacing.md),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: type.cardTitle.copyWith(
              color: colors.colorText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(height: CupidSpacing.sm),
        Text(
          body,
          textAlign: TextAlign.center,
          style: type.body.copyWith(
            color: colors.colorTextMuted,
            height: 1.5,
          ),
        ),
        SizedBox(height: CupidSpacing.lg),
        if (isPartnerMissingOnly) ...<Widget>[
          CupidPrimaryButton(
            leadingIcon: CupidIcons.notificationsActive,
            label: _viEn(
              context,
              'Nhắc người ấy cập nhật ngay 💌',
              'Remind partner now 💌',
            ),
            onPressed: _isReminding ? null : () => _remindPartner(context),
          ),
          SizedBox(height: CupidSpacing.xs),
          TextButton(
            onPressed: _isLoading ? null : () => _navigateToProfileEdit(context),
            child: Text(
              _viEn(
                context,
                'Chỉnh sửa ngày sinh của bạn',
                'Edit your birthday',
              ),
              style: type.caption.copyWith(
                color: colors.colorTextMuted,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ] else ...<Widget>[
          CupidPrimaryButton(
            leadingIcon: CupidIcons.edit,
            label: _viEn(
              context,
              'Cập nhật ngày sinh ngay ✨',
              'Update birthday now ✨',
            ),
            onPressed: _isLoading ? null : () => _navigateToProfileEdit(context),
          ),
        ],
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
