import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/chat_partner_store.dart';
import '../../data/ghost_consent_store.dart';
import '../chat_strings.dart';
import '../ghost_cubit.dart';

/// `ghostset` screen (`ux/uiux-spec.md` §4). Reached from the Home
/// dashboard tile in the design source's own flow, not from inside `chat`
/// (`ux/uiux-spec.md` §2 Flow Map) — this widget does not wire its own
/// route/nav entry either way; that is P4's scope
/// (`coding-plan/phase-P3-typing-ghost.md` §6).
class GhostSettingsScreen extends StatelessWidget {
  const GhostSettingsScreen({
    super.key,
    required this.coordinator,
    required this.consentStore,
    required this.partnerStore,
    required this.backendUserIdStore,
    this.onBack,
  });

  final RealtimeCoordinator coordinator;
  final GhostConsentStore consentStore;
  final ChatPartnerStore partnerStore;
  final BackendUserIdStore backendUserIdStore;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GhostCubit>(
      create: (_) => GhostCubit(
        coordinator: coordinator,
        consentStore: consentStore,
        partnerStore: partnerStore,
        backendUserIdStore: backendUserIdStore,
      ),
      child: _GhostSettingsView(onBack: onBack),
    );
  }
}

class _GhostSettingsView extends StatelessWidget {
  const _GhostSettingsView({this.onBack});

  final VoidCallback? onBack;

  Future<void> _handleTogglePressed(BuildContext context) async {
    final GhostCubit cubit = context.read<GhostCubit>();
    if (cubit.state.consentLevel == GhostConsentLevel.on) {
      await cubit.optOut();
    } else {
      await cubit.optIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Scaffold(
      appBar: CupidHeader(
        title: ChatStrings.ghostSetToggleTitle(context),
        onBack: onBack,
      ),
      body: BlocBuilder<GhostCubit, GhostState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(CupidSpacing.md),
            children: [
              _HeroCard(colors: colors),
              const SizedBox(height: CupidSpacing.md),
              _ToggleCard(
                colors: colors,
                state: state,
                onTogglePressed: () => _handleTogglePressed(context),
              ),
              const SizedBox(height: CupidSpacing.md),
              _LegendCard(colors: colors),
              const SizedBox(height: CupidSpacing.md),
              _EphemeralFooterCard(colors: colors),
            ],
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.colors});

  final CupidColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final CupidTypographyTokens type = context.cupidType;

    return Container(
      padding: const EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        gradient: colors.gradientDream,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.blur_on, color: Colors.white, size: 28),
          const SizedBox(height: CupidSpacing.sm),
          Text(
            ChatStrings.ghostSetHeroHeadline(context),
            style: type.cardTitle.copyWith(color: Colors.white),
          ),
          const SizedBox(height: CupidSpacing.xs),
          Text(
            ChatStrings.ghostSetHeroBody(context),
            style: type.body.copyWith(color: Colors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  const _ToggleCard({
    required this.colors,
    required this.state,
    required this.onTogglePressed,
  });

  final CupidColorTokens colors;
  final GhostState state;
  final VoidCallback onTogglePressed;

  @override
  Widget build(BuildContext context) {
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final bool isOn = state.consentLevel == GhostConsentLevel.on;
    final bool isPending = state.consentLevel == GhostConsentLevel.pending;

    return Container(
      padding: const EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ChatStrings.ghostSetToggleTitle(context),
                      style: type.body.copyWith(
                        color: colors.colorText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ChatStrings.ghostSetToggleStateLine(
                        context,
                        state.consentLevel,
                      ),
                      style: type.caption.copyWith(
                        color: isOn ? colors.colorMint : colors.colorTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: ChatStrings.ghostToggleSemanticLabel(
                  context,
                  state.consentLevel,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: platformTokens.tapTarget,
                    minHeight: platformTokens.tapTarget,
                  ),
                  child: GestureDetector(
                    onTap: onTogglePressed,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: isOn
                            ? colors.colorAccentPurple.withValues(alpha: 0.24)
                            : colors.colorSurfaceAlt,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: CupidSpacing.sm,
                        ),
                        child: Center(
                          child: Text(
                            isPending
                                ? '···'
                                : ChatStrings.ghostToggleGlyph(
                                    state.consentLevel,
                                  ),
                            style: type.caption.copyWith(
                              color: isOn
                                  ? colors.colorAccentPurple
                                  : colors.colorTextMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: CupidSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ConsentColumn(
                  label: ChatStrings.ghostSetYouColumn(context),
                  // "You" reflects this device's own local opt-in — off
                  // when the local flag or the server flag is false, agreed
                  // otherwise (ADR-013e).
                  valueText: state.consentLevel == GhostConsentLevel.off
                      ? ChatStrings.ghostSetConsentOff(context)
                      : ChatStrings.ghostSetConsentAgreed(context),
                  valueColor: state.consentLevel == GhostConsentLevel.off
                      ? colors.colorTextMuted
                      : colors.colorMint,
                  colors: colors,
                ),
              ),
              Expanded(
                child: _ConsentColumn(
                  label: ChatStrings.ghostSetPartnerColumn(context),
                  // The contract exposes no partner flag — never render a
                  // definite "off" here (`coding-plan/phase-P3-typing-ghost
                  // .md` §6 required checks).
                  valueText: ChatStrings.ghostSetPartnerUnknown(context),
                  valueColor: colors.colorTextMuted,
                  colors: colors,
                ),
              ),
            ],
          ),
          const SizedBox(height: CupidSpacing.sm),
          Text(
            ChatStrings.ghostSetMutualConsentFooter(context),
            style: type.caption.copyWith(color: colors.colorTextMuted),
          ),
        ],
      ),
    );
  }
}

class _ConsentColumn extends StatelessWidget {
  const _ConsentColumn({
    required this.label,
    required this.valueText,
    required this.valueColor,
    required this.colors,
  });

  final String label;
  final String valueText;
  final Color valueColor;
  final CupidColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final CupidTypographyTokens type = context.cupidType;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: type.caption.copyWith(color: colors.colorTextMuted)),
        Text(
          valueText,
          style: type.body.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LegendCard extends StatelessWidget {
  const _LegendCard({required this.colors});

  final CupidColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final CupidTypographyTokens type = context.cupidType;

    return Container(
      padding: const EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: type.body.copyWith(color: colors.colorText),
              children: [
                const TextSpan(text: 'he'),
                TextSpan(
                  text: 'llo',
                  style: TextStyle(
                    color: colors.colorGhost,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: CupidSpacing.sm),
          Row(
            children: [
              _LegendSwatch(color: colors.colorText),
              const SizedBox(width: CupidSpacing.xs),
              Text(
                ChatStrings.ghostSetLegendLive(context),
                style: type.caption.copyWith(color: colors.colorTextMuted),
              ),
              const SizedBox(width: CupidSpacing.md),
              _LegendSwatch(color: colors.colorGhost),
              const SizedBox(width: CupidSpacing.xs),
              Text(
                ChatStrings.ghostSetLegendDeleted(context),
                style: type.caption.copyWith(color: colors.colorTextMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendSwatch extends StatelessWidget {
  const _LegendSwatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _EphemeralFooterCard extends StatelessWidget {
  const _EphemeralFooterCard({required this.colors});

  final CupidColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final CupidTypographyTokens type = context.cupidType;

    return Container(
      padding: const EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorMint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: colors.colorMint),
          const SizedBox(width: CupidSpacing.sm),
          Expanded(
            child: Text(
              ChatStrings.ghostSetEphemeralFooter(context),
              style: type.caption.copyWith(color: colors.colorText),
            ),
          ),
        ],
      ),
    );
  }
}
