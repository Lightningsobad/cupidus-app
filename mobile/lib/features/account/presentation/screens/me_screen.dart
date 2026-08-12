import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/presentation/sign_out_action.dart';
import '../../data/account_repository.dart';
import '../../data/notification_preferences_store.dart';
import '../../domain/cupid_profile.dart';
import '../account_cubit.dart';
import 'notification_settings_screen.dart';
import 'privacy_screen.dart';
import 'profile_edit_screen.dart';

/// `me` hub (`coding-plan/master-plan.md` §6.2 P2, `ux/uiux-spec.md` §1/§3).
///
/// [authRepository] is optional: nothing in production code constructs a
/// live `AuthRepository` yet — `FirebaseSignInGateway`'s concrete
/// implementation
/// (`mobile/lib/features/auth/data/firebase_sign_in_gateway.dart`) is
/// documented as out of every phase's write scope to date, and
/// `service_locator.dart` registers no `AuthRepository`. When absent, the
/// sign-out row is simply not rendered rather than fabricated; whenever a
/// repository is supplied, the existing `SignOutAction` is placed unmodified
/// per §6.2 P2 ("do not reimplement sign-out").
class MeScreen extends StatelessWidget {
  const MeScreen({
    super.key,
    required this.accountRepository,
    this.authRepository,
  });

  final AccountRepository accountRepository;
  final AuthRepository? authRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountCubit>(
      create: (_) => AccountCubit(repository: accountRepository),
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

    return Scaffold(
      backgroundColor: colors.colorBackground,
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
                padding: EdgeInsets.all(CupidSpacing.lg),
                children: <Widget>[
                  _ProfileSummaryCard(
                    profile: profile,
                    colors: colors,
                    type: type,
                    platformTokens: platformTokens,
                    onTap: () => _openEdit(context, profile),
                  ),
                  SizedBox(height: CupidSpacing.lg),
                  _MenuRow(
                    label: l10n.me_menu_privacy,
                    colors: colors,
                    type: type,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            PrivacyScreen(accountRepository: accountRepository),
                      ),
                    ),
                  ),
                  _MenuRow(
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
                  _MenuRow(
                    label: l10n.me_menu_typing_ghost,
                    colors: colors,
                    type: type,
                  ),
                  _MenuRow(
                    label: l10n.me_menu_love_contract,
                    colors: colors,
                    type: type,
                  ),
                  if (authRepository != null) ...<Widget>[
                    SizedBox(height: CupidSpacing.sm),
                    Divider(color: colors.colorLine),
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
    final List<String> captionParts = <String>[
      if (profile.zodiacSign != null) profile.zodiacSign!,
      if (profile.birthday != null) _formatDate(profile.birthday!),
    ];
    final String? caption = captionParts.isEmpty
        ? null
        : captionParts.join(' · ');

    return InkWell(
      borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(CupidSpacing.md),
        decoration: BoxDecoration(
          color: colors.colorSurface,
          borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        ),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 32,
              backgroundColor: colors.colorSurfaceAlt,
              backgroundImage: profile.photoUrl == null
                  ? null
                  : NetworkImage(profile.photoUrl!),
              child: profile.photoUrl == null
                  ? Icon(Icons.person, color: colors.colorTextMuted)
                  : null,
            ),
            SizedBox(width: CupidSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    profile.displayName ?? profile.email,
                    style: type.cardTitle.copyWith(
                      color: colors.colorText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (caption != null) ...<Widget>[
                    SizedBox(height: CupidSpacing.xs),
                    Text(
                      caption,
                      style: type.caption.copyWith(
                        color: colors.colorTextMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.edit, color: colors.colorAccentPink),
          ],
        ),
      ),
    );
  }
}

/// A settings menu row. Privacy/notifications navigate to their P4/P5
/// destinations via [onTap]; Typing Ghost/Love Contract are owned by other
/// stories (`ux/uiux-spec.md` §6) and stay forward-link-only (no [onTap])
/// until their owning story wires a real destination.
class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.label,
    required this.colors,
    required this.type,
    this.onTap,
  });

  final String label;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: type.body.copyWith(color: colors.colorText)),
      trailing: Icon(Icons.chevron_right, color: colors.colorTextMuted),
      onTap: onTap,
    );
  }
}
