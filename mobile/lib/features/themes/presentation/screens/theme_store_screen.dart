import 'package:dio/dio.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/theme_models.dart';
import '../../data/themes_repository.dart';
import '../theme_cubit.dart';
import 'theme_detail_screen.dart';

class ThemeStoreScreen extends StatelessWidget {
  const ThemeStoreScreen({
    super.key,
    this.repository,
    this.cubit,
  });

  final ThemesRepository? repository;
  final ThemeCubit? cubit;

  static const String routeName = '/themes/store';

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider<ThemeCubit>.value(
        value: cubit!..loadThemeState(),
        child: const _ThemeStoreView(),
      );
    }

    if (getIt.isRegistered<ThemeCubit>()) {
      return BlocProvider<ThemeCubit>.value(
        value: getIt<ThemeCubit>()..loadThemeState(),
        child: const _ThemeStoreView(),
      );
    }

    if (repository != null) {
      return BlocProvider<ThemeCubit>(
        create: (_) => ThemeCubit(repository: repository!)..loadThemeState(),
        child: const _ThemeStoreView(),
      );
    }

    if (getIt.isRegistered<ThemesRepository>()) {
      return BlocProvider<ThemeCubit>(
        create: (_) => ThemeCubit(repository: getIt<ThemesRepository>())..loadThemeState(),
        child: const _ThemeStoreView(),
      );
    }

    return BlocProvider<ThemeCubit>(
      create: (_) => ThemeCubit(
        repository: ThemesRepository(
          api: getIt.isRegistered<CupidApi>()
              ? getIt<CupidApi>()
              : CupidApi(dio: Dio(), interceptors: const []),
        ),
      ),
      child: const _ThemeStoreView(),
    );
  }
}

class _ThemeStoreView extends StatelessWidget {
  const _ThemeStoreView();

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
        final activeTheme = state.activeTheme;
        final wishlistTheme = state.wishlistTheme;

        return Scaffold(
          appBar: CupidHeader(
            title: isEn ? 'Theme store' : 'Kho Theme',
            onBack: () => Navigator.of(context).maybePop(),
            backLabel: isEn ? 'Back' : 'Quay lại',
          ),
          body: RefreshIndicator(
            onRefresh: () => cubit.loadThemeState(),
            color: colors.colorAccentPink,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: CupidSpacing.md,
                vertical: CupidSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // 1. Hero Card: Now Wearing
                  _HeroWearingCard(
                    activeTheme: activeTheme,
                    heartsBalance: state.coupleState.heartsBalance,
                    formatNumber: _formatNumber,
                    colors: colors,
                    type: type,
                    platformTokens: platformTokens,
                    isEn: isEn,
                  ),
                  SizedBox(height: CupidSpacing.md),

                  // 2. Category Filter Chips
                  _CategoryChips(
                    selectedCategory: state.selectedCategory,
                    onSelected: (cat) => cubit.setCategory(cat),
                    colors: colors,
                    type: type,
                    isEn: isEn,
                  ),
                  SizedBox(height: CupidSpacing.md),

                  // 3. Wishlist Banner (if available)
                  if (wishlistTheme != null) ...<Widget>[
                    _WishlistBanner(
                      theme: wishlistTheme,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ThemeDetailScreen(
                            theme: wishlistTheme,
                            cubit: cubit,
                          ),
                        ),
                      ),
                      colors: colors,
                      type: type,
                      platformTokens: platformTokens,
                      isEn: isEn,
                    ),
                    SizedBox(height: CupidSpacing.md),
                  ],

                  // 4. Two-Column Theme Cards Grid
                  _ThemeGrid(
                    themes: state.filteredThemes,
                    coupleState: state.coupleState,
                    cubit: cubit,
                    colors: colors,
                    type: type,
                    platformTokens: platformTokens,
                    formatNumber: _formatNumber,
                    isEn: isEn,
                  ),
                  SizedBox(height: CupidSpacing.lg),

                  // 5. Commitment Footer Info Card
                  _CommitmentFooter(
                    colors: colors,
                    type: type,
                    platformTokens: platformTokens,
                    isEn: isEn,
                  ),
                  SizedBox(height: CupidSpacing.xl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroWearingCard extends StatelessWidget {
  const _HeroWearingCard({
    required this.activeTheme,
    required this.heartsBalance,
    required this.formatNumber,
    required this.colors,
    required this.type,
    required this.platformTokens,
    required this.isEn,
  });

  final ThemeDefinition activeTheme;
  final int heartsBalance;
  final String Function(int) formatNumber;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: activeTheme.gradient,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        border: Border.all(color: colors.colorLine),
        boxShadow: platformTokens.elevationShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          // Dark gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    colors.colorBackground.withValues(alpha: 0.10),
                    colors.colorBackground.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(CupidSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        isEn ? 'NOW WEARING' : 'ĐANG DÙNG',
                        style: type.labelMono.copyWith(
                          fontSize: 9.5,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w700,
                          color: colors.colorGlowCore.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeTheme.localizedName(context),
                        style: type.display.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: colors.colorGlowCore,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isEn ? 'Chosen together · 12 Jul' : 'Cả hai đã chọn · 12.07',
                        style: type.caption.copyWith(
                          fontSize: 11.5,
                          color: colors.colorGlowCore.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: colors.colorBackground.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        CupidIcons.favorite,
                        size: 15,
                        color: colors.colorAccentPink,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formatNumber(heartsBalance),
                        style: type.labelMono.copyWith(
                          fontSize: 12,
                          color: colors.colorGlowCore,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.selectedCategory,
    required this.onSelected,
    required this.colors,
    required this.type,
    required this.isEn,
  });

  final ThemeCategory selectedCategory;
  final ValueChanged<ThemeCategory> onSelected;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ThemeCategory.values.map((cat) {
          final isSelected = cat == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 7),
            child: InkWell(
              onTap: () => onSelected(cat),
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.colorAccentPink.withValues(alpha: 0.20)
                      : colors.colorSurface,
                  border: Border.all(
                    color: isSelected
                        ? colors.colorAccentPink.withValues(alpha: 0.45)
                        : colors.colorLine,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isEn ? cat.labelEn() : cat.labelVi(),
                  style: type.body.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? colors.colorAccentPink : colors.colorTextMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _WishlistBanner extends StatelessWidget {
  const _WishlistBanner({
    required this.theme,
    required this.onTap,
    required this.colors,
    required this.type,
    required this.platformTokens,
    required this.isEn,
  });

  final ThemeDefinition theme;
  final VoidCallback onTap;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              colors.colorAccentPink.withValues(alpha: 0.20),
              colors.colorAccentPurple.withValues(alpha: 0.16),
            ],
          ),
          border: Border.all(color: colors.colorAccentPink.withValues(alpha: 0.34)),
          borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: theme.gradient,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    isEn
                        ? 'Partner saved ${theme.nameEn}'
                        : 'Người yêu đã lưu ${theme.nameVi}',
                    style: type.body.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: colors.colorText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isEn
                        ? 'Two weeks left before it leaves the store'
                        : 'Còn hai tuần nữa là rời kho',
                    style: type.caption.copyWith(
                      fontSize: 11.5,
                      color: colors.colorTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupidIcons.chevronRight,
              size: 19,
              color: colors.colorAccentPink,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeGrid extends StatelessWidget {
  const _ThemeGrid({
    required this.themes,
    required this.coupleState,
    required this.cubit,
    required this.colors,
    required this.type,
    required this.platformTokens,
    required this.formatNumber,
    required this.isEn,
  });

  final List<ThemeDefinition> themes;
  final CoupleThemeState coupleState;
  final ThemeCubit cubit;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;
  final String Function(int) formatNumber;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 13) / 2;

        return Wrap(
          spacing: 13,
          runSpacing: 13,
          children: themes.map((theme) {
            final isOn = coupleState.isActive(theme.id);
            final isOwned = coupleState.isOwned(theme.id);

            return SizedBox(
              width: cardWidth,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ThemeDetailScreen(
                      theme: theme,
                      cubit: cubit,
                    ),
                  ),
                ),
                borderRadius: BorderRadius.circular(platformTokens.radiusCard),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.colorSurface,
                    borderRadius: BorderRadius.circular(platformTokens.radiusCard),
                    border: Border.all(
                      color: isOn ? colors.colorAccentPink : const Color.fromARGB(0, 0, 0, 0),
                      width: 1.5,
                    ),
                    boxShadow: platformTokens.elevationShadow,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Swatch header area
                      Container(
                        height: 104,
                        decoration: BoxDecoration(gradient: theme.gradient),
                        child: Stack(
                          children: <Widget>[
                            // Badge pill
                            if (theme.badge != null)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.colorBackground.withValues(alpha: 0.50),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    theme.badge!.toUpperCase(),
                                    style: type.labelMono.copyWith(
                                      fontSize: 9,
                                      letterSpacing: 1.0,
                                      fontWeight: FontWeight.w700,
                                      color: colors.colorGlowCore,
                                    ),
                                  ),
                                ),
                              ),
                            // Active checkmark circle
                            if (isOn)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: colors.colorGlowCore,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    CupidIcons.check,
                                    size: 15,
                                    color: colors.colorBackground,
                                  ),
                                ),
                              ),
                            // 3 dots
                            Positioned(
                              left: 8,
                              bottom: 8,
                              child: Row(
                                children: theme.dots.map((dot) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 4),
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: dot,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colors.colorGlowCore.withValues(alpha: 0.55),
                                        width: 1.5,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Card details
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 11, 12, 13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              theme.localizedName(context),
                              style: type.body.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: colors.colorText,
                                height: 1.25,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              theme.localizedTag(context),
                              style: type.caption.copyWith(
                                fontSize: 11,
                                color: colors.colorTextMuted,
                                height: 1.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 9),
                            Row(
                              children: <Widget>[
                                Icon(
                                  isOwned ? CupidIcons.checkCircle : CupidIcons.favorite,
                                  size: 14,
                                  color: isOwned ? colors.colorMint : colors.colorAccentPink,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isOwned
                                      ? (isEn ? 'Owned' : 'Đã có')
                                      : theme.price == 0
                                          ? (isEn ? 'Free' : 'Miễn phí')
                                          : formatNumber(theme.price),
                                  style: type.labelMono.copyWith(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: isOwned
                                        ? colors.colorMint
                                        : colors.colorAccentPink,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _CommitmentFooter extends StatelessWidget {
  const _CommitmentFooter({
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            CupidIcons.volunteerActivism,
            size: 20,
            color: colors.colorMint,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: type.body.copyWith(
                  fontSize: 12.5,
                  height: 1.55,
                  color: colors.colorTextMuted,
                ),
                children: isEn
                    ? <TextSpan>[
                        TextSpan(
                          text: 'A theme belongs to both. ',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: colors.colorText,
                          ),
                        ),
                        const TextSpan(
                          text:
                              'Either of you can change it, but the other has to agree — and hearts come from the shared wallet.',
                        ),
                      ]
                    : <TextSpan>[
                        TextSpan(
                          text: 'Theme là của cả hai. ',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: colors.colorText,
                          ),
                        ),
                        const TextSpan(
                          text:
                              'Ai đổi cũng được, nhưng người kia phải đồng ý — và tim thì trừ vào ví chung.',
                        ),
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
