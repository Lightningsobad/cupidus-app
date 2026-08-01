import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/realtime/backend_user_id_store.dart';
import '../../data/ghost_config_models.dart';
import '../../data/ghost_config_repository.dart';
import '../anti_ghost_cubit.dart';
import '../screens/anti_ghost_screen.dart';

/// STORY-008 P2 (`ux/uiux-spec.md` §2.1): the Home dashboard "Anti-Ghosting"
/// quick-access card. Its subtitle mirrors the same lifecycle read
/// [AntiGhostScreen] performs, so tapping through always lands on whichever
/// state (A/B/C/D) the live data resolves to — this card makes no separate
/// routing decision of its own.
///
/// Guards on `get_it` registration before building [AntiGhostCubit]: nothing
/// in this codebase currently calls `setupServiceLocator()` on the
/// `HomeScreen` boot path (`AppShell` mounts `HomeScreen` directly, and
/// `main.dart` never wires the locator), so resolving the repository
/// unconditionally would crash `mobile/test/widget_test.dart` and the app's
/// first frame. That bootstrap wiring is a cross-cutting gap outside this
/// phase's write scope; this guard renders a static, still-tappable card
/// instead of depending on it.
class AntiGhostEntryCard extends StatelessWidget {
  const AntiGhostEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (!getIt.isRegistered<GhostConfigRepository>() ||
        !getIt.isRegistered<BackendUserIdStore>()) {
      return const _AntiGhostEntryCardChrome(subtitle: null, isPending: false);
    }
    return BlocProvider<AntiGhostCubit>(
      create: (_) => AntiGhostCubit(
        repository: getIt<GhostConfigRepository>(),
        backendUserIdStore: getIt<BackendUserIdStore>(),
      ),
      child: const _AntiGhostEntryCardView(),
    );
  }
}

class _AntiGhostEntryCardView extends StatelessWidget {
  const _AntiGhostEntryCardView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AntiGhostCubit, AntiGhostState>(
      builder: (context, state) {
        // AC3 (`ux/uiux-spec.md` §1): an unpaired user has no entry point to
        // this feature at all, not just a guarded settings screen.
        if (state is AntiGhostPairingRequired) {
          return const SizedBox.shrink();
        }
        final AppL10n l10n = AppL10n.of(context);
        final _CardCopy copy = _copyFor(l10n, state);
        return _AntiGhostEntryCardChrome(
          subtitle: copy.subtitle,
          isPending: copy.isPending,
        );
      },
    );
  }

  _CardCopy _copyFor(AppL10n l10n, AntiGhostState state) {
    if (state is! AntiGhostLoaded) {
      // Loading / load-failed: still reachable, no lifecycle text to show yet
      // (`AntiGhostScreen` itself renders the spinner/retry state).
      return const _CardCopy(subtitle: null, isPending: false);
    }
    final AntiGhostLifecycle lifecycle = state.lifecycle;
    if (lifecycle is AntiGhostActiveConfig) {
      return _CardCopy(
        subtitle: l10n.anti_ghost_active_summary(
          lifecycle.config.timeoutMinutes,
          _penaltyLabel(l10n, lifecycle.config.penalty),
        ),
        isPending: false,
      );
    }
    if (lifecycle is AntiGhostPendingMine) {
      return _CardCopy(subtitle: l10n.anti_ghost_pending_mine_badge, isPending: true);
    }
    if (lifecycle is AntiGhostPendingPartner) {
      return _CardCopy(subtitle: l10n.anti_ghost_pending_partner_title, isPending: true);
    }
    if (lifecycle is AntiGhostPendingUnknownRole) {
      return _CardCopy(subtitle: l10n.anti_ghost_pending_unknown_title, isPending: true);
    }
    // AntiGhostNoConfig (UX §2.1 first-run copy).
    return _CardCopy(subtitle: l10n.anti_ghost_card_not_set_up_subtitle, isPending: false);
  }
}

class _CardCopy {
  const _CardCopy({required this.subtitle, required this.isPending});

  final String? subtitle;
  final bool isPending;
}

String _penaltyLabel(AppL10n l10n, Penalty penalty) {
  return switch (penalty) {
    Penalty.emojiStorm => l10n.anti_ghost_penalty_emoji_storm,
    Penalty.noise => l10n.anti_ghost_penalty_noise,
    Penalty.none => l10n.anti_ghost_penalty_none,
  };
}

/// Shared chrome for both the live (`get_it`-backed) and static-fallback
/// variants: icon tile on the purple accent token, title, and an optional
/// subtitle — the amber pending badge always pairs an icon with the
/// subtitle's text (`ux/uiux-spec.md` §4: no colour-only signalling).
class _AntiGhostEntryCardChrome extends StatelessWidget {
  const _AntiGhostEntryCardChrome({required this.subtitle, required this.isPending});

  final String? subtitle;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final double tapTarget = context.cupidPlatform.tapTarget;
    final Color subtitleColor = isPending ? colors.colorAmber : colors.colorTextMuted;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: subtitle == null ? l10n.anti_ghost_title : '${l10n.anti_ghost_title}. $subtitle',
      child: Material(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(context.cupidPlatform.radiusCard),
        child: InkWell(
          borderRadius: BorderRadius.circular(context.cupidPlatform.radiusCard),
          onTap: () => Navigator.of(context).push<void>(
            MaterialPageRoute<void>(builder: (_) => const AntiGhostScreen()),
          ),
          child: Container(
            constraints: BoxConstraints(minHeight: tapTarget),
            padding: EdgeInsets.all(CupidSpacing.md),
            child: Row(
              children: [
                Container(
                  width: tapTarget,
                  height: tapTarget,
                  decoration: BoxDecoration(
                    color: colors.colorAccentPurple.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(context.cupidPlatform.radiusSmall),
                  ),
                  alignment: Alignment.center,
                  child: CupidIcon(CupidIcons.timer, color: colors.colorAccentPurple),
                ),
                SizedBox(width: CupidSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              l10n.anti_ghost_title,
                              style: type.cardTitle.copyWith(color: colors.colorText),
                            ),
                          ),
                          if (isPending) ...[
                            SizedBox(width: CupidSpacing.xs),
                            CupidIcon(CupidIcons.timer, size: 14, color: colors.colorAmber),
                          ],
                        ],
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: CupidSpacing.xs),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: type.body.copyWith(color: subtitleColor),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
