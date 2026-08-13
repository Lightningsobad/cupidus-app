import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/chat_partner_store.dart';
import '../../data/ghost_consent_store.dart';
import '../chat_strings.dart';
import '../ghost_cubit.dart';

/// Direction vectors for the hero card's `linear-gradient(145deg, ...)`,
/// derived the same way as the 120deg pair in `cupid_color_tokens.dart`:
/// begin = `(-sin, cos)`, end = `(sin, -cos)`.
const Alignment _gradient145Begin = Alignment(
  -0.573576436351046,
  -0.8191520442889918,
);
const Alignment _gradient145End = Alignment(
  0.573576436351046,
  0.8191520442889918,
);

/// `ghostset` screen (`ux/uiux-spec.md` §4). Reached from the Home
/// dashboard tile in the design source's own flow, not from inside `chat`
/// (`ux/uiux-spec.md` §2 Flow Map) — this widget does not wire its own
/// route/nav entry either way; that is P4's scope
/// (`coding-plan/phase-P3-typing-ghost.md` §6).
///
/// Geometry, colour and typography below are transcribed from the locked
/// design source `cupid-app-design-system/project/Cupid Screens.dc.html`,
/// `<sc-if value="{{ isGhostSet }}">` at lines 391-431 plus the binding block
/// at lines 2200-2213.
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
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
            children: [
              _PrivacyChip(colors: colors),
              const SizedBox(height: 13),
              _HeroCard(colors: colors),
              const SizedBox(height: 13),
              _ToggleCard(
                colors: colors,
                state: state,
                onTogglePressed: () => _handleTogglePressed(context),
              ),
              const SizedBox(height: 13),
              _LegendCard(colors: colors),
              const SizedBox(height: 13),
              _EphemeralFooterCard(colors: colors),
            ],
          );
        },
      ),
    );
  }
}

/// Standing Level-1 device-only lock affordance. Typing Ghost content is
/// Level-1 data, and every Level-1 surface must show this at all times
/// (system UX memory §5/§8); the chip's own geometry and copy are the design
/// source's Level-1 chip at line 334.
class _PrivacyChip extends StatelessWidget {
  const _PrivacyChip({required this.colors});

  final CupidColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final CupidTypographyTokens type = context.cupidType;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: colors.colorSurface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupidIcon(
              CupidIcons.lock,
              variant: CupidIconVariant.soft,
              size: 13,
              color: colors.colorMint,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                context.viEn(
                  'Level 1 · chỉ nằm trên máy hai người',
                  'Level 1 · on your devices only',
                ),
                style: type.caption.copyWith(
                  fontSize: 10.5,
                  color: colors.colorTextMuted,
                ),
              ),
            ),
          ],
        ),
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
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final Color purple = colors.colorAccentPurple;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: _gradient145Begin,
          end: _gradient145End,
          colors: <Color>[
            purple.withValues(alpha: 0.32),
            colors.colorAccentPink.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        border: Border.all(color: purple.withValues(alpha: 0.45)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -24,
            right: -16,
            child: Opacity(
              opacity: 0.2,
              child: Icon(Icons.blur_on, size: 130, color: purple),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: colors.gradientHot,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: colors.glowShadow,
                  ),
                  child: const Center(
                    child: Icon(Icons.blur_on, size: 30, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  ChatStrings.ghostSetHeroHeadline(context),
                  style: type.display.copyWith(
                    fontSize: 25,
                    height: 1.2,
                    color: colors.colorText,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  ChatStrings.ghostSetHeroBody(context),
                  style: type.caption.copyWith(
                    fontSize: 13.5,
                    height: 1.6,
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

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: platformTokens.elevationShadow,
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
                      style: type.display.copyWith(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: colors.colorText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      ChatStrings.ghostSetToggleStateLine(
                        context,
                        state.consentLevel,
                      ),
                      style: type.caption.copyWith(
                        fontSize: 12,
                        color: colors.colorTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              _ConsentSwitch(
                colors: colors,
                consentLevel: state.consentLevel,
                onPressed: onTogglePressed,
              ),
            ],
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 15),
            color: colors.colorLine,
          ),
          // The design source lays these out as a 2-column grid, so the tiles
          // stay equal height when one value wraps and the other does not.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ConsentTile(
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
                const SizedBox(width: 10),
                Expanded(
                  child: _ConsentTile(
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
          ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.handshake, size: 15, color: colors.colorAccentPink),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  ChatStrings.ghostSetMutualConsentFooter(context),
                  style: type.caption.copyWith(
                    fontSize: 11.5,
                    color: colors.colorTextMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The design source's 54x32 pill switch (line 403): `--grad-hot` track with
/// the knob at `flex-end` while on, `--line` track with the knob at
/// `flex-start` otherwise. `pending` shares the off-position track — only the
/// state line and the accessible label distinguish it (lines 2205-2209).
class _ConsentSwitch extends StatelessWidget {
  const _ConsentSwitch({
    required this.colors,
    required this.consentLevel,
    required this.onPressed,
  });

  final CupidColorTokens colors;
  final GhostConsentLevel consentLevel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isOn = consentLevel == GhostConsentLevel.on;

    return Semantics(
      button: true,
      label: ChatStrings.ghostToggleSemanticLabel(context, consentLevel),
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 54,
          height: context.cupidPlatform.tapTarget,
          child: Center(
            child: Container(
              width: 54,
              height: 32,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                gradient: isOn ? colors.gradientHot : null,
                color: isOn ? null : colors.colorLine,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Align(
                alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Color.fromRGBO(60, 20, 80, 0.28),
                        offset: Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConsentTile extends StatelessWidget {
  const _ConsentTile({
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.colorSurfaceAlt,
        borderRadius: BorderRadius.circular(context.cupidPlatform.radiusSmall),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: type.caption.copyWith(
              fontSize: 11,
              color: colors.colorTextMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valueText,
            textAlign: TextAlign.center,
            style: type.caption.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendCard extends StatelessWidget {
  const _LegendCard({required this.colors});

  final CupidColorTokens colors;

  static const BorderRadius _previewRadius = BorderRadius.only(
    topLeft: Radius.circular(22),
    topRight: Radius.circular(22),
    bottomRight: Radius.circular(22),
    bottomLeft: Radius.circular(7),
  );

  @override
  Widget build(BuildContext context) {
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final Color purple = colors.colorAccentPurple;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context
                .viEn('Nhìn như thế nào', 'What it looks like')
                .toUpperCase(),
            style: type.caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: colors.colorTextMuted,
            ),
          ),
          const SizedBox(height: 12),
          CustomPaint(
            painter: _DashedRRectBorderPainter(
              color: purple.withValues(alpha: 0.6),
              borderRadius: _previewRadius,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: purple.withValues(alpha: 0.12),
                borderRadius: _previewRadius,
              ),
              child: Text.rich(
                TextSpan(
                  style: type.caption.copyWith(
                    fontSize: 15,
                    height: 1.5,
                    color: colors.colorText,
                  ),
                  children: <InlineSpan>[
                    const TextSpan(text: 'anh ăn cơm chưa'),
                    TextSpan(
                      text: '▌',
                      style: TextStyle(color: colors.colorAccentPink),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: 'anh ơi em nhớ',
                      style: TextStyle(
                        color: colors.colorGhost,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _LegendItem(
                swatchColor: colors.colorGhost,
                label: ChatStrings.ghostSetLegendDeleted(context),
                colors: colors,
              ),
              const SizedBox(width: 16),
              _LegendItem(
                swatchColor: colors.colorText,
                label: ChatStrings.ghostSetLegendLive(context),
                colors: colors,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.swatchColor,
    required this.label,
    required this.colors,
  });

  final Color swatchColor;
  final String label;
  final CupidColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: swatchColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: context.cupidType.caption.copyWith(
            fontSize: 11.5,
            color: colors.colorTextMuted,
          ),
        ),
      ],
    );
  }
}

class _EphemeralFooterCard extends StatelessWidget {
  const _EphemeralFooterCard({required this.colors});

  final CupidColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    // The design source marks the lead sentence `<strong>` in `--tx` while
    // the rest stays `--tx2`; the copy itself is a single `ChatStrings` entry.
    final String footer = ChatStrings.ghostSetEphemeralFooter(context);
    final int leadEnd = footer.indexOf('. ');
    final String lead = leadEnd == -1
        ? footer
        : footer.substring(0, leadEnd + 1);
    final String rest = leadEnd == -1 ? '' : footer.substring(leadEnd + 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: colors.colorMint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        border: Border.all(color: colors.colorMint.withValues(alpha: 0.34)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_moon, size: 20, color: colors.colorMint),
          const SizedBox(width: 11),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: type.caption.copyWith(
                  fontSize: 12.5,
                  height: 1.55,
                  color: colors.colorTextMuted,
                ),
                children: <InlineSpan>[
                  TextSpan(
                    text: lead,
                    style: TextStyle(
                      color: colors.colorText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: rest),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashed rounded-rectangle border painter, mirroring the technique already
/// used by `ghost_bubble.dart` and `timeline_screen.dart` — no dashed-border
/// package is a project dependency (`mobile/pubspec.yaml`).
class _DashedRRectBorderPainter extends CustomPainter {
  const _DashedRRectBorderPainter({
    required this.color,
    required this.borderRadius,
  });

  static const double _strokeWidth = 1;
  static const double _dashWidth = 4;
  static const double _dashGap = 3;

  final Color color;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..addRRect(borderRadius.toRRect(Offset.zero & size));
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = distance + _dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + _dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectBorderPainter oldDelegate) =>
      color != oldDelegate.color || borderRadius != oldDelegate.borderRadius;
}
