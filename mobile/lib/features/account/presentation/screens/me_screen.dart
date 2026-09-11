import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/presentation/sign_out_action.dart';
import '../../../context_notebook/context_notebook_entry_point.dart';
import '../../../journal/journal_entry_point.dart';
import '../../../themes/data/theme_catalog.dart';
import '../../../themes/presentation/screens/theme_store_screen.dart';
import '../../../themes/presentation/theme_cubit.dart';
import '../../data/account_repository.dart';
import '../../data/notification_preferences_store.dart';
import '../../domain/cupid_profile.dart';
import '../account_cubit.dart';
import 'notification_settings_screen.dart';
import 'privacy_screen.dart';
import 'profile_edit_screen.dart';

/// vi/en copy for the rows the ARB pipeline has no keys for yet
/// (`mobile/lib/l10n/**` is outside this story's write scope — same precedent
/// `chat_strings.dart` and `auth_strings.dart` use).
extension _MeLocaleText on BuildContext {
  String viEn(String vi, String en) =>
      Localizations.localeOf(this).languageCode == 'vi' ? vi : en;
}

// Geometry the locked design source (`Cupid Screens.dc.html` §isMe) states
// off the `CupidSpacing` scale. Spacing rounds to the token scale; these are
// component sizes and the row rhythm, which would drift visibly if rounded.
const double _avatarDiameter = 64;
const double _editIconSize = 22;
const double _zodiacIconSize = 22;
const double _rowBadgeSize = 38;
const double _rowBadgeRadius = 13;
const double _rowBadgeIconSize = 20;
const double _rowTrailingIconSize = 19;
const double _rowVerticalPadding = 14;
const double _divorceIconSize = 20;
const double _pillIconSize = 12;
const double _pillFontSize = 10;
const double _pillRadius = 999;
const double _versionFontSize = 10;

/// `background:rgba(<tint>,.18)` behind every tinted row badge.
const double _rowBadgeTintOpacity = 0.18;

/// `linear-gradient(150deg, …)` on the profile card, expressed with the
/// CSS-angle convention `CupidColorTokens` already encodes
/// (`begin = (-sin, cos)`, `end = (sin, -cos)`).
const Alignment _gradient150Begin = Alignment(-0.5, -0.8660254037844387);
const Alignment _gradient150End = Alignment(0.5, 0.8660254037844387);

/// `me` hub (`coding-plan/master-plan.md` §6.2 P2, `ux/uiux-spec.md` §1/§3),
/// laid out against the locked design source's `me` canvas screen.
///
/// [authRepository] is optional: nothing in production code constructs a
/// live `AuthRepository` yet — `FirebaseSignInGateway`'s concrete
/// implementation
/// (`mobile/lib/features/auth/data/firebase_sign_in_gateway.dart`) is
/// documented as out of every phase's write scope to date, and
/// `service_locator.dart` registers no `AuthRepository`. When absent, the
/// sign-out row is simply not rendered rather than fabricated; whenever a
/// repository is supplied, the existing `SignOutAction` is placed unmodified
/// per §6.2 P2 ("do not reimplement sign-out"). The design source has no
/// sign-out affordance on this screen, so `AppShell` (the only production
/// caller) passes nothing.
class MeScreen extends StatelessWidget {
  const MeScreen({
    super.key,
    required this.accountRepository,
    this.authRepository,
    this.resolveProfile,
  });

  final AccountRepository accountRepository;
  final AuthRepository? authRepository;

  /// Preview-only override of `GET /users/me`, mirroring
  /// `HomeScreen.resolveProfile`.
  final Future<CupidProfile> Function()? resolveProfile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountCubit>(
      create: (_) => AccountCubit(
        repository: accountRepository,
        resolveProfile: resolveProfile,
      ),
      child: _MeView(
        accountRepository: accountRepository,
        authRepository: authRepository,
      ),
    );
  }
}

class _MeView extends StatelessWidget {
  const _MeView({required this.accountRepository, this.authRepository});

  final AccountRepository accountRepository;
  final AuthRepository? authRepository;

  Future<void> _openEdit(BuildContext context, CupidProfile profile) async {
    final CupidProfile? updated = await Navigator.of(context).push(
      MaterialPageRoute<CupidProfile>(
        builder: (_) => ProfileEditScreen(
          accountRepository: accountRepository,
          profile: profile,
        ),
      ),
    );
    if (updated != null && context.mounted) {
      context.read<AccountCubit>().applyUpdated(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final bool isIos = CupidPlatform.of(context) == CupidPlatform.ios;

    return Scaffold(
      appBar: CupidHeader(title: l10n.me_hub_title),
      body: BlocBuilder<AccountCubit, AccountState>(
        builder: (context, state) {
          return switch (state) {
            AccountLoading() => Center(
              child: Text(
                l10n.me_loading,
                style: type.body.copyWith(color: colors.colorTextMuted),
              ),
            ),
            AccountFailed() => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    l10n.me_load_error,
                    style: type.body.copyWith(color: colors.colorText),
                  ),
                  SizedBox(height: CupidSpacing.sm),
                  TextButton(
                    onPressed: () => context.read<AccountCubit>().load(),
                    child: Text(l10n.me_retry),
                  ),
                ],
              ),
            ),
            AccountLoaded(:final profile) => SafeArea(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  CupidSpacing.md,
                  CupidSpacing.sm,
                  CupidSpacing.md,
                  CupidSpacing.xl,
                ),
                children: <Widget>[
                  _ProfileSummaryCard(
                    profile: profile,
                    colors: colors,
                    type: type,
                    platformTokens: platformTokens,
                    onTap: () => _openEdit(context, profile),
                  ),
                  SizedBox(height: CupidSpacing.md),
                  _PrivateStorageBlock(
                    colors: colors,
                    type: type,
                    platformTokens: platformTokens,
                  ),
                  SizedBox(height: CupidSpacing.md),
                  _SettingsCard(
                    colors: colors,
                    platformTokens: platformTokens,
                    rows: <Widget>[
                      _MenuRow(
                        icon: CupidIcons.shieldMoon,
                        badgeTint: colors.colorMint,
                        label: l10n.me_menu_privacy,
                        colors: colors,
                        type: type,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PrivacyScreen(
                              accountRepository: accountRepository,
                            ),
                          ),
                        ),
                      ),
                      _MenuRow(
                        icon: CupidIcons.notifications,
                        badgeTint: colors.colorAmber,
                        label: l10n.me_menu_notifications,
                        colors: colors,
                        type: type,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => NotificationSettingsScreen(
                              store: getIt<NotificationPreferencesStore>(),
                            ),
                          ),
                        ),
                      ),
                      if (getIt.isRegistered<ThemeCubit>())
                        BlocBuilder<ThemeCubit, ThemeState>(
                          bloc: getIt<ThemeCubit>(),
                          builder: (context, themeState) {
                            final active = themeState.activeTheme;
                            return _MenuRow(
                              icon: CupidIcons.palette,
                              badgeTint: colors.colorAccentPurple,
                              label: context.viEn('Kho Theme', 'Theme store'),
                              colors: colors,
                              type: type,
                              trailingWidget: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      gradient: active.gradient,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    active.localizedName(context),
                                    style: type.caption.copyWith(
                                      color: colors.colorTextMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const ThemeStoreScreen(),
                                ),
                              ),
                            );
                          },
                        )
                      else
                        _MenuRow(
                          icon: CupidIcons.palette,
                          badgeTint: colors.colorAccentPurple,
                          label: context.viEn('Kho Theme', 'Theme store'),
                          colors: colors,
                          type: type,
                          trailingWidget: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  gradient: cupidThemeCatalog.first.gradient,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                context.viEn('Tinh Vân', 'Nebula'),
                                style: type.caption.copyWith(
                                  color: colors.colorTextMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const ThemeStoreScreen(),
                            ),
                          ),
                        ),
                      if (getIt.isRegistered<ThemeCubit>())
                        BlocBuilder<ThemeCubit, ThemeState>(
                          bloc: getIt<ThemeCubit>(),
                          builder: (context, themeState) {
                            return _MenuRow(
                              icon: CupidIcons.autoAwesome,
                              badgeTint: colors.colorAccentPink,
                              label: context.viEn(
                                'Hiệu ứng động theme',
                                'Theme dynamic effects',
                              ),
                              colors: colors,
                              type: type,
                              trailingWidget: GestureDetector(
                                onTap: () => getIt<ThemeCubit>().setEffectsEnabled(
                                  !themeState.isEffectsEnabled,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 44,
                                  height: 26,
                                  padding: const EdgeInsets.all(2.5),
                                  alignment: themeState.isEffectsEnabled
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    gradient: themeState.isEffectsEnabled
                                        ? colors.gradientHot
                                        : null,
                                    color: themeState.isEffectsEnabled
                                        ? null
                                        : colors.colorLine,
                                  ),
                                  child: const DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: OnAccentPalette.foreground,
                                      shape: BoxShape.circle,
                                    ),
                                    child: SizedBox(width: 21, height: 21),
                                  ),
                                ),
                              ),
                              showChevron: false,
                              onTap: () => getIt<ThemeCubit>().setEffectsEnabled(
                                !themeState.isEffectsEnabled,
                              ),
                            );
                          },
                        ),
                      _MenuRow(
                        icon: isIos ? CupidIcons.iosShare : CupidIcons.share,
                        badgeTint: colors.colorPeach,
                        label: context.viEn('Ảnh chia sẻ', 'Share cards'),
                        colors: colors,
                        type: type,
                      ),
                      _MenuRow(
                        icon: CupidIcons.blurOn,
                        badgeTint: colors.colorAccentPurple,
                        label: l10n.me_menu_typing_ghost,
                        colors: colors,
                        type: type,
                        trailingValue: profile.isGhostModeEnabled
                            ? 'ON'
                            : 'OFF',
                        showChevron: false,
                      ),
                      _MenuRow(
                        icon: CupidIcons.draw,
                        badgeTint: colors.colorAccentPink,
                        label: l10n.me_menu_love_contract,
                        colors: colors,
                        type: type,
                      ),
                      _MenuRow(
                        icon: CupidIcons.translate,
                        badgeTint: colors.colorTextMuted,
                        badgeBackground: colors.colorSurfaceAlt,
                        label: context.viEn('Ngôn ngữ', 'Language'),
                        colors: colors,
                        type: type,
                        trailingValue: profile.language == 'vi'
                            ? 'Tiếng Việt'
                            : 'English',
                        showChevron: false,
                        showDivider: false,
                      ),
                    ],
                  ),
                  SizedBox(height: CupidSpacing.md),
                  _DigitalDivorceCard(
                    colors: colors,
                    type: type,
                    platformTokens: platformTokens,
                  ),
                  SizedBox(height: CupidSpacing.md),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: CupidSpacing.xs),
                    child: Text(
                      'Cupid 1.0.0 (MVP) · iOS 15+ / Android 8+',
                      textAlign: TextAlign.center,
                      style: type.labelMono.copyWith(
                        fontSize: _versionFontSize,
                        color: colors.colorTextMuted,
                      ),
                    ),
                  ),
                  if (authRepository != null) ...<Widget>[
                    SizedBox(height: CupidSpacing.md),
                    SignOutAction(authRepository: authRepository!),
                  ],
                ],
              ),
            ),
          };
        },
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.profile,
    required this.colors,
    required this.type,
    required this.platformTokens,
    required this.onTap,
  });

  final CupidProfile profile;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;
  final VoidCallback onTap;

  String _formatDate(DateTime date) {
    String pad2(int value) => value.toString().padLeft(2, '0');
    return '${pad2(date.day)}/${pad2(date.month)}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final CupidZodiacSign? sign = CupidZodiacSign.tryParse(profile.zodiacSign);
    final String? zodiacLabel = sign == null
        ? profile.zodiacSign
        : context.viEn(sign.viLabel, sign.enLabel);
    final TextStyle captionStyle = type.caption.copyWith(
      color: colors.colorTextMuted,
    );

    final List<Widget> captionParts = <Widget>[
      if (sign != null) CupidZodiacIcon(sign, size: _zodiacIconSize),
      if (zodiacLabel != null) Text(zodiacLabel, style: captionStyle),
      if (zodiacLabel != null && profile.birthday != null)
        Text('·', style: captionStyle),
      if (profile.birthday != null)
        Text(_formatDate(profile.birthday!), style: captionStyle),
    ];

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: _gradient150Begin,
          end: _gradient150End,
          colors: <Color>[
            colors.colorAccentPink.withValues(alpha: 0.2),
            colors.colorAccentPurple.withValues(alpha: 0.18),
          ],
        ),
        border: Border.all(color: colors.colorLine),
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(CupidSpacing.lg),
            child: Row(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: platformTokens.elevationShadow,
                  ),
                  child: CircleAvatar(
                    radius: _avatarDiameter / 2,
                    backgroundColor: colors.colorSurfaceAlt,
                    backgroundImage: profile.photoUrl == null
                        ? null
                        : NetworkImage(profile.photoUrl!),
                    child: profile.photoUrl == null
                        ? CupidIcon(
                            CupidIcons.person,
                            color: colors.colorTextMuted,
                          )
                        : null,
                  ),
                ),
                SizedBox(width: CupidSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        profile.displayName ?? profile.email,
                        style: type.display.copyWith(
                          fontSize: type.cardTitle.fontSize,
                          color: colors.colorText,
                        ),
                      ),
                      if (captionParts.isNotEmpty) ...<Widget>[
                        SizedBox(height: CupidSpacing.xs),
                        Row(
                          children: <Widget>[
                            for (int i = 0; i < captionParts.length; i++)
                              ...<Widget>[
                                if (i > 0) SizedBox(width: CupidSpacing.sm),
                                captionParts[i],
                              ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                CupidIcon(
                  CupidIcons.edit,
                  variant: CupidIconVariant.line,
                  size: _editIconSize,
                  color: colors.colorTextMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The "Kho riêng của tôi" block (REQ-016 STORY-003 `ux/uiux-spec.md` §1): the
/// device-local, self-only surfaces, grouped away from the settings card.
///
/// STORY-004 appends its notebook and skill-profile rows to [rows] below. Each
/// row must keep pushing its own independent route — no shared screen and no
/// sub-tab switching between them (AC-17, spec §8).
///
/// The glyph and tint are the ones `Cupid Screens.dc.html` gives this surface on
/// the "Tôi" tab (`lock` in `--mint`, line 1852-1856); the design draws it as a
/// single banner, which the spec deliberately re-shapes into a headed row block
/// so STORY-004's rows have somewhere to land.
class _PrivateStorageBlock extends StatelessWidget {
  const _PrivateStorageBlock({
    required this.colors,
    required this.type,
    required this.platformTokens,
  });

  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final List<Widget> rows = <Widget>[
      _MenuRow(
        icon: CupidIcons.lock,
        badgeTint: colors.colorMint,
        label: l10n.me_menu_private_journal,
        colors: colors,
        type: type,
        onTap: () => openJournalScreen(context),
      ),
      _MenuRow(
        icon: CupidIcons.menuBook,
        badgeTint: colors.colorAccentLilac,
        label: l10n.me_menu_context_notebook,
        colors: colors,
        type: type,
        onTap: () => openNotebookScreen(context),
      ),
      _MenuRow(
        icon: CupidIcons.checklist,
        badgeTint: colors.colorButter,
        label: l10n.me_menu_skill_profile,
        colors: colors,
        type: type,
        showDivider: false,
        onTap: () => openSkillProfileScreen(context),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            left: CupidSpacing.xs,
            bottom: CupidSpacing.sm,
          ),
          child: Text(
            l10n.me_section_private_storage,
            style: type.caption.copyWith(
              color: colors.colorTextMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _SettingsCard(
          colors: colors,
          platformTokens: platformTokens,
          rows: rows,
        ),
      ],
    );
  }
}

/// The grouped settings card wrapping every [_MenuRow].
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.rows,
    required this.colors,
    required this.platformTokens,
  });

  final List<Widget> rows;
  final CupidColorTokens colors;
  final CupidPlatformTokens platformTokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: CupidSpacing.md,
            vertical: CupidSpacing.xs,
          ),
          child: Column(children: rows),
        ),
      ),
    );
  }
}

/// A settings menu row. Privacy/notifications navigate to their P4/P5
/// destinations via [onTap]; the rows whose destinations belong to other
/// stories (`ux/uiux-spec.md` §6) render exactly as the design source states
/// them but stay forward-link-only (no [onTap]) until their owning story
/// wires a real destination.
class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.badgeTint,
    required this.label,
    required this.colors,
    required this.type,
    this.badgeBackground,
    this.trailingValue,
    this.trailingWidget,
    this.showChevron = true,
    this.showDivider = true,
    this.onTap,
  });

  final IconData icon;
  final Color badgeTint;
  final Color? badgeBackground;
  final String label;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final String? trailingValue;
  final Widget? trailingWidget;
  final bool showChevron;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: colors.colorLine))
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: _rowVerticalPadding),
          child: Row(
            children: <Widget>[
              Container(
                width: _rowBadgeSize,
                height: _rowBadgeSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      badgeBackground ??
                      badgeTint.withValues(alpha: _rowBadgeTintOpacity),
                  borderRadius: BorderRadius.circular(_rowBadgeRadius),
                ),
                child: CupidIcon(
                  icon,
                  size: _rowBadgeIconSize,
                  color: badgeTint,
                ),
              ),
              SizedBox(width: CupidSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: type.body.copyWith(
                    color: colors.colorText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailingWidget != null)
                trailingWidget!
              else if (trailingValue != null)
                Text(
                  trailingValue!,
                  style: type.caption.copyWith(color: colors.colorTextMuted),
                ),
              if (showChevron)
                CupidIcon(
                  CupidIcons.chevronRight,
                  size: _rowTrailingIconSize,
                  color: colors.colorTextMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Digital Divorce teaser card. The design source states it as a Phase 1.5
/// announcement with no `onClick` binding, so it is rendered without a
/// destination.
class _DigitalDivorceCard extends StatelessWidget {
  const _DigitalDivorceCard({
    required this.colors,
    required this.type,
    required this.platformTokens,
  });

  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CupidIcon(
                CupidIcons.heartBroken,
                size: _divorceIconSize,
                color: colors.colorGhost,
              ),
              SizedBox(width: CupidSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Digital Divorce',
                      style: type.body.copyWith(
                        color: colors.colorText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: CupidSpacing.xs),
                    Text(
                      context.viEn(
                        '7 ngày hoà giải, xuất kỷ niệm, rồi xoá sạch',
                        '7-day cooling off, export memories, then wipe',
                      ),
                      style: type.caption.copyWith(
                        color: colors.colorTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              CupidIcon(
                CupidIcons.chevronRight,
                size: _rowTrailingIconSize,
                color: colors.colorTextMuted,
              ),
            ],
          ),
          SizedBox(height: CupidSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: CupidSpacing.sm,
                vertical: CupidSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colors.colorSurfaceAlt,
                borderRadius: BorderRadius.circular(_pillRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CupidIcon(
                    CupidIcons.schedule,
                    size: _pillIconSize,
                    color: colors.colorTextMuted,
                  ),
                  SizedBox(width: CupidSpacing.xs),
                  Text(
                    'Phase 1.5',
                    style: type.caption.copyWith(
                      fontSize: _pillFontSize,
                      color: colors.colorTextMuted,
                    ),
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
