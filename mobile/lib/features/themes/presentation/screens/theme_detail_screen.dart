import 'package:dio/dio.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/themes_repository.dart';
import '../theme_cubit.dart';

class ThemeDetailScreen extends StatelessWidget {
  const ThemeDetailScreen({
    super.key,
    required this.theme,
    this.cubit,
    this.isRequester,
  });

  final ThemeDefinition theme;
  final ThemeCubit? cubit;
  final bool? isRequester;

  static const String routeName = '/themes/detail';

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider<ThemeCubit>.value(
        value: cubit!..loadThemeState(),
        child: _ThemeDetailView(
          theme: theme,
          isRequesterOverride: isRequester,
        ),
      );
    }

    if (getIt.isRegistered<ThemeCubit>()) {
      return BlocProvider<ThemeCubit>.value(
        value: getIt<ThemeCubit>()..loadThemeState(),
        child: _ThemeDetailView(
          theme: theme,
          isRequesterOverride: isRequester,
        ),
      );
    }

    return BlocProvider<ThemeCubit>(
      create: (_) => ThemeCubit(
        repository: getIt.isRegistered<ThemesRepository>()
            ? getIt<ThemesRepository>()
            : ThemesRepository(
                api: getIt.isRegistered<CupidApi>()
                    ? getIt<CupidApi>()
                    : CupidApi(dio: Dio(), interceptors: const []),
              ),
      )..loadThemeState(),
      child: _ThemeDetailView(
        theme: theme,
        isRequesterOverride: isRequester,
      ),
    );
  }
}

class _ThemeDetailView extends StatelessWidget {
  const _ThemeDetailView({
    required this.theme,
    this.isRequesterOverride,
  });

  final ThemeDefinition theme;
  final bool? isRequesterOverride;

  String _formatNumber(int val) {
    return NumberFormat('#,###', 'vi_VN').format(val);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.cupidColors;
    final type = context.cupidType;
    final platformTokens = context.cupidPlatform;
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    return BlocConsumer<ThemeCubit, ThemeState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: colors.colorOnAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: colors.colorOnAccent,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: colors.colorRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<ThemeCubit>();
        final coupleState = state.coupleState;

        final bool isOn = coupleState.isActive(theme.id);
        final bool isOwned = coupleState.isOwned(theme.id);
        final bool isPendingThis = coupleState.isPending(theme.id);
        final currentUserId = getIt.isRegistered<BackendUserIdStore>()
            ? getIt<BackendUserIdStore>().backendUserId
            : null;
        final bool isRequester = isRequesterOverride ??
            (coupleState.pendingRequestedBy != null &&
                (coupleState.pendingRequestedBy == currentUserId ||
                    coupleState.pendingRequestedBy == 'userA' ||
                    coupleState.pendingRequestedBy == 'me'));

        return Scaffold(
          appBar: CupidHeader(
            title: isEn ? 'Theme details' : 'Chi tiết theme',
            onBack: () => Navigator.of(context).maybePop(),
            backLabel: isEn ? 'Back' : 'Quay lại',
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // 1. Interactive Preview Hero
                _HeroChatMockup(
                  theme: theme,
                  isEn: isEn,
                  type: type,
                ),

                // 2. Info & Palette Section
                Padding(
                  padding: EdgeInsets.all(CupidSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Title + Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              theme.localizedName(context),
                              style: type.display.copyWith(
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                                color: colors.colorText,
                              ),
                            ),
                          ),
                          if (theme.badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.colorAccentPink.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                theme.badge!.toUpperCase(),
                                style: type.labelMono.copyWith(
                                  fontSize: 9.5,
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.w800,
                                  color: colors.colorAccentPink,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        theme.localizedStory(context),
                        style: type.body.copyWith(
                          fontSize: 13,
                          height: 1.6,
                          color: colors.colorTextMuted,
                        ),
                      ),
                      SizedBox(height: CupidSpacing.md),

                      // 5-Color Palette Strip
                      _PaletteStrip(
                        palette: theme.palette,
                        colors: colors,
                        type: type,
                      ),
                      SizedBox(height: CupidSpacing.md),

                      // Changes Breakdown Card
                      _ChangesCard(
                        colors: colors,
                        type: type,
                        platformTokens: platformTokens,
                        isEn: isEn,
                      ),
                      SizedBox(height: CupidSpacing.md),

                      // Action Bottom Buttons
                      _ActionArea(
                        theme: theme,
                        isOn: isOn,
                        isOwned: isOwned,
                        isPending: isPendingThis,
                        isRequester: isRequester,
                        heartsBalance: coupleState.heartsBalance,
                        isActionLoading: state.isActionInProgress,
                        onAsk: () => cubit.requestTheme(theme.id),
                        onApprove: () => cubit.approveTheme(),
                        formatNumber: _formatNumber,
                        colors: colors,
                        type: type,
                        platformTokens: platformTokens,
                        isEn: isEn,
                      ),
                      SizedBox(height: CupidSpacing.xl),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroChatMockup extends StatelessWidget {
  const _HeroChatMockup({
    required this.theme,
    required this.isEn,
    required this.type,
  });

  final ThemeDefinition theme;
  final bool isEn;
  final CupidTypographyTokens type;

  @override
  Widget build(BuildContext context) {
    final colors = context.cupidColors;
    final dot1 = theme.dots.isNotEmpty ? theme.dots[0] : colors.colorAccentPurple;
    final dot2 = theme.dots.length > 1 ? theme.dots[1] : colors.colorAccentPink;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: theme.gradient),
      child: Stack(
        children: <Widget>[
          // Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    colors.colorBackground.withValues(alpha: 0.08),
                    colors.colorBackground.withValues(alpha: 0.50),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.colorBackground.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.colorGlowCore.withValues(alpha: 0.20)),
            ),
            child: Column(
              children: <Widget>[
                // Avatars & Couple Header
                Row(
                  children: <Widget>[
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: dot1,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.colorGlowCore.withValues(alpha: 0.6), width: 2),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(-14, 0),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: dot2,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.colorGlowCore.withValues(alpha: 0.6), width: 2),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Minh & Linh',
                        style: type.body.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: colors.colorGlowCore,
                        ),
                      ),
                    ),
                    Icon(
                      CupidIcons.favorite,
                      size: 16,
                      color: colors.colorGlowCore.withValues(alpha: 0.75),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Chat bubbles
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: colors.colorGlowCore.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        CupidIcons.pets,
                        size: 32,
                        color: colors.colorGlowCore,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: colors.colorGlowCore.withValues(alpha: 0.20),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(5),
                                ),
                              ),
                              child: Text(
                                isEn ? 'Dinner tonight?' : 'Tối nay ăn gì?',
                                style: type.body.copyWith(
                                  fontSize: 11.5,
                                  color: colors.colorGlowCore,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: dot1,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(5),
                                ),
                              ),
                              child: Text(
                                isEn ? "I'll cook 🍜" : 'Em nấu 🍜',
                                style: type.body.copyWith(
                                  fontSize: 11.5,
                                  color: colors.colorGlowCore,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteStrip extends StatelessWidget {
  const _PaletteStrip({
    required this.palette,
    required this.colors,
    required this.type,
  });

  final List<ThemePaletteColor> palette;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: palette.map((colorItem) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: <Widget>[
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorItem.hex,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.colorLine),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  colorItem.name,
                  style: type.labelMono.copyWith(
                    fontSize: 8.5,
                    color: colors.colorTextMuted,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ChangesCard extends StatelessWidget {
  const _ChangesCard({
    required this.colors,
    required this.type,
    required this.platformTokens,
    required this.isEn,
  });

  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final changes = <Map<String, dynamic>>[
      {
        'icon': CupidIcons.savings,
        'label': isEn ? 'Home & pet background' : 'Nền màn hình chính & chuồng pet',
      },
      {
        'icon': CupidIcons.blurOn,
        'label': isEn ? 'Chat bubbles & typing ghost' : 'Bong bóng chat & Typing Ghost',
      },
      {
        'icon': CupidIcons.iosShare,
        'label': isEn ? 'Keepsake card frames' : 'Khung thẻ kỷ niệm',
      },
      {
        'icon': CupidIcons.notifications,
        'label': isEn ? 'Notification & widget skin' : 'Thông báo & widget màn hình khoá',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Column(
        children: <Widget>[
          ...changes.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colors.colorLine)),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    item['icon'] as IconData,
                    size: 19,
                    color: colors.colorAccentPurple,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['label'] as String,
                      style: type.body.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: colors.colorText,
                      ),
                    ),
                  ),
                  Icon(
                    CupidIcons.checkCircle,
                    size: 17,
                    color: colors.colorMint,
                  ),
                ],
              ),
            );
          }),
          // Expiry info row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              children: <Widget>[
                Icon(
                  CupidIcons.schedule,
                  size: 19,
                  color: colors.colorTextMuted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isEn ? 'Yours forever' : 'Dùng vĩnh viễn',
                    style: type.body.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: colors.colorText,
                    ),
                  ),
                ),
                Text(
                  isEn ? 'no expiry' : 'không hết hạn',
                  style: type.caption.copyWith(
                    fontSize: 11.5,
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

class _ActionArea extends StatelessWidget {
  const _ActionArea({
    required this.theme,
    required this.isOn,
    required this.isOwned,
    required this.isPending,
    required this.isRequester,
    required this.heartsBalance,
    required this.isActionLoading,
    required this.onAsk,
    required this.onApprove,
    required this.formatNumber,
    required this.colors,
    required this.type,
    required this.platformTokens,
    required this.isEn,
  });

  final ThemeDefinition theme;
  final bool isOn;
  final bool isOwned;
  final bool isPending;
  final bool isRequester;
  final int heartsBalance;
  final bool isActionLoading;
  final VoidCallback onAsk;
  final VoidCallback onApprove;
  final String Function(int) formatNumber;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    if (isOn) {
      return Container(
        height: 52,
        decoration: BoxDecoration(
          color: colors.colorSurfaceAlt,
          borderRadius: BorderRadius.circular(platformTokens.radiusButton),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              CupidIcons.checkCircle,
              size: 20,
              color: colors.colorMint,
            ),
            const SizedBox(width: 8),
            Text(
              isEn ? "You're both wearing this" : 'Hai đứa đang dùng',
              style: type.body.copyWith(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: colors.colorTextMuted,
              ),
            ),
          ],
        ),
      );
    }

    if (isPending) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: colors.colorAmber.withValues(alpha: 0.14),
              border: Border.all(color: colors.colorAmber.withValues(alpha: 0.36)),
              borderRadius: BorderRadius.circular(platformTokens.radiusCard),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  CupidIcons.hourglass,
                  size: 20,
                  color: colors.colorAmber,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        isRequester
                            ? (isEn ? 'Waiting for partner' : 'Đang đợi người yêu đồng ý')
                            : (isEn ? 'Partner wants this theme' : 'Người yêu muốn đổi sang theme này'),
                        style: type.body.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: colors.colorAmber,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isRequester
                            ? (isEn
                                ? 'A theme only changes when you both say yes.'
                                : 'Theme chỉ đổi khi cả hai cùng đồng ý.')
                            : (isEn
                                ? 'Hearts come out of your shared wallet.'
                                : 'Tim sẽ trừ vào ví chung của hai đứa.'),
                        style: type.caption.copyWith(
                          fontSize: 11.5,
                          color: colors.colorTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!isRequester) ...<Widget>[
            const SizedBox(height: 12),
            InkWell(
              onTap: isActionLoading ? null : onApprove,
              borderRadius: BorderRadius.circular(platformTokens.radiusButton),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: colors.gradientHot,
                  borderRadius: BorderRadius.circular(platformTokens.radiusButton),
                  boxShadow: colors.glowShadow,
                ),
                child: Center(
                  child: isActionLoading
                      ? CircularProgressIndicator(color: colors.colorGlowCore)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              CupidIcons.check,
                              size: 20,
                              color: colors.colorGlowCore,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEn ? 'Approve the change' : 'Đồng ý đổi theme',
                              style: type.body.copyWith(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: colors.colorGlowCore,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ],
      );
    }

    // Default CTA: Request switch / unlock
    final String formattedPrice = theme.price == 0
        ? (isEn ? 'Free' : 'Miễn phí')
        : '${formatNumber(theme.price)} tim';

    final String ctaLabel = isOwned
        ? (isEn ? 'Ask to switch' : 'Xin đổi sang theme này')
        : (isEn ? 'Unlock for $formattedPrice' : 'Mở khoá · $formattedPrice');

    final String ctaHint = isOwned
        ? (isEn
            ? 'Partner has to approve before it changes'
            : 'Người yêu cần đồng ý thì theme mới đổi')
        : (isEn
            ? 'Shared wallet · ${formatNumber(heartsBalance)} tim'
            : 'Ví chung còn ${formatNumber(heartsBalance)} tim');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        InkWell(
          onTap: isActionLoading ? null : onAsk,
          borderRadius: BorderRadius.circular(platformTokens.radiusButton),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: colors.gradientHot,
              borderRadius: BorderRadius.circular(platformTokens.radiusButton),
              boxShadow: colors.glowShadow,
            ),
            child: Center(
              child: isActionLoading
                  ? CircularProgressIndicator(color: colors.colorGlowCore)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          isOwned ? CupidIcons.palette : CupidIcons.favorite,
                          size: 20,
                          color: colors.colorGlowCore,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ctaLabel,
                          style: type.body.copyWith(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: colors.colorGlowCore,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          ctaHint,
          textAlign: TextAlign.center,
          style: type.caption.copyWith(
            fontSize: 11.5,
            color: colors.colorTextMuted,
          ),
        ),
      ],
    );
  }
}
