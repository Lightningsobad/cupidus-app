import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/generated/app_l10n.dart';
import '../../data/account_repository.dart';
import '../../domain/cupid_profile.dart';
import '../account_cubit.dart';

/// `privacy` screen (`coding-plan/master-plan.md` §6.2 P4, `ux/uiux-spec.md`
/// §4, DEC-3). The three tier cards stay static informational content.
/// STORY-021 (`req_master.md` § Open Question Triage / Approved Scope Change
/// entry #5) adds one editable control for `isGhostModeEnabled` between the
/// Level 1 and Level 2 cards, wired to the already-existing `PATCH
/// /users/me` contract — the screen's prior "no toggle, no PATCH, no
/// isGhostModeEnabled" state was a build defect, not an approved scope cut.
/// Still no "Export all my data" button or other admin affordance (DEC-5).
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key, required this.accountRepository});

  final AccountRepository accountRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountCubit>(
      create: (_) => AccountCubit(repository: accountRepository),
      child: Builder(
        builder: (context) {
          final AppL10n l10n = AppL10n.of(context);
          final CupidColorTokens colors = context.cupidColors;
          final CupidTypographyTokens type = context.cupidType;
          final CupidPlatformTokens platformTokens = context.cupidPlatform;

          return Scaffold(
            appBar: CupidHeader(
              title: l10n.privacy_title,
              onBack: () => Navigator.of(context).maybePop(),
              backLabel: l10n.me_hub_title,
            ),
            body: SafeArea(
              child: ListView(
                padding: EdgeInsets.all(CupidSpacing.lg),
                children: <Widget>[
                  Text(
                    l10n.privacy_intro,
                    style: type.body.copyWith(color: colors.colorTextMuted),
                  ),
                  SizedBox(height: CupidSpacing.lg),
                  _TierCard(
                    icon: Icons.smartphone,
                    levelLabel: l10n.privacy_tier1_label,
                    levelColor: colors.colorAccentPink,
                    iconBackground: colors.colorAccentPink.withValues(
                      alpha: 0.28,
                    ),
                    title: l10n.privacy_tier1_title,
                    description: l10n.privacy_tier1_description,
                    tags: <String>[
                      l10n.privacy_tier1_tag_typing_ghost,
                      l10n.privacy_tier1_tag_private_gallery,
                      l10n.privacy_tier1_tag_messages,
                    ],
                    highlighted: true,
                    colors: colors,
                    type: type,
                    platformTokens: platformTokens,
                  ),
                  SizedBox(height: CupidSpacing.md),
                  _PrivacyControlsSection(
                    accountRepository: accountRepository,
                    colors: colors,
                    type: type,
                    platformTokens: platformTokens,
                    l10n: l10n,
                  ),
                  SizedBox(height: CupidSpacing.md),
                  _TierCard(
                    icon: Icons.enhanced_encryption,
                    levelLabel: l10n.privacy_tier2_label,
                    levelColor: colors.colorAccentPurple,
                    iconBackground: colors.colorAccentPurple.withValues(
                      alpha: 0.2,
                    ),
                    title: l10n.privacy_tier2_title,
                    description: l10n.privacy_tier2_description,
                    tags: <String>[
                      l10n.privacy_tier2_tag_dream_jar,
                      l10n.privacy_tier2_tag_love_timeline,
                      l10n.privacy_tier2_tag_vibe_check,
                    ],
                    highlighted: false,
                    colors: colors,
                    type: type,
                    platformTokens: platformTokens,
                  ),
                  SizedBox(height: CupidSpacing.md),
                  _TierCard(
                    icon: Icons.cloud,
                    levelLabel: l10n.privacy_tier3_label,
                    levelColor: colors.colorTextMuted,
                    iconBackground: colors.colorSurfaceAlt,
                    title: l10n.privacy_tier3_title,
                    description: l10n.privacy_tier3_description,
                    tags: <String>[
                      l10n.privacy_tier3_tag_profile,
                      l10n.privacy_tier3_tag_love_pet_stats,
                      l10n.privacy_tier3_tag_alarm_settings,
                    ],
                    highlighted: false,
                    colors: colors,
                    type: type,
                    platformTokens: platformTokens,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// One of the three privacy-tier informational cards
/// (`ux/uiux-spec.md` §4, design source lines 893-921). Purely presentational
/// — no `onTap`, no trailing control of any kind.
class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.icon,
    required this.levelLabel,
    required this.levelColor,
    required this.iconBackground,
    required this.title,
    required this.description,
    required this.tags,
    required this.highlighted,
    required this.colors,
    required this.type,
    required this.platformTokens,
  });

  final IconData icon;
  final String levelLabel;
  final Color levelColor;
  final Color iconBackground;
  final String title;
  final String description;
  final List<String> tags;

  /// Level 1 renders as a tinted gradient card with a border (design source
  /// line 893); levels 2/3 render as plain surface cards with elevation
  /// (lines 903, 913).
  final bool highlighted;

  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(
      platformTokens.radiusCard,
    );

    return Container(
      padding: EdgeInsets.all(CupidSpacing.md),
      decoration: highlighted
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  colors.colorAccentPink.withValues(alpha: 0.22),
                  colors.colorAccentPurple.withValues(alpha: 0.14),
                ],
              ),
              borderRadius: radius,
              border: Border.all(
                color: colors.colorAccentPink.withValues(alpha: 0.4),
              ),
            )
          : BoxDecoration(
              color: colors.colorSurface,
              borderRadius: radius,
              boxShadow: platformTokens.elevationShadow,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(
                    platformTokens.radiusSmall,
                  ),
                ),
                child: Icon(icon, size: 21, color: levelColor),
              ),
              SizedBox(width: CupidSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      levelLabel,
                      style: type.labelMono.copyWith(
                        color: levelColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      title,
                      style: type.body.copyWith(
                        color: colors.colorText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: CupidSpacing.sm),
          Text(
            description,
            style: type.caption.copyWith(color: colors.colorTextMuted),
          ),
          SizedBox(height: CupidSpacing.sm),
          Wrap(
            spacing: CupidSpacing.xs,
            runSpacing: CupidSpacing.xs,
            children: <Widget>[
              for (final String tag in tags)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: CupidSpacing.sm,
                    vertical: CupidSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.colorSurfaceAlt,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tag,
                    style: type.caption.copyWith(
                      color: colors.colorText,
                      fontSize: 11,
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

/// STORY-021 AC2 (`ux/uiux-spec.md` §2-3): the one editable-control card
/// inserted between the Level 1 and Level 2 tier cards. `BlocBuilder` is
/// scoped to the toggle row only, so this card's own section label always
/// renders immediately, matching the screen's existing never-block-behind-a-
/// spinner pattern.
class _PrivacyControlsSection extends StatelessWidget {
  const _PrivacyControlsSection({
    required this.accountRepository,
    required this.colors,
    required this.type,
    required this.platformTokens,
    required this.l10n,
  });

  final AccountRepository accountRepository;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;
  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.privacy_controls_section_label,
          style: type.labelMono.copyWith(
            color: colors.colorTextMuted,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: CupidSpacing.sm),
        Container(
          padding: EdgeInsets.all(CupidSpacing.md),
          decoration: BoxDecoration(
            color: colors.colorSurface,
            borderRadius: BorderRadius.circular(platformTokens.radiusCard),
            boxShadow: platformTokens.elevationShadow,
          ),
          child: BlocBuilder<AccountCubit, AccountState>(
            builder: (context, state) {
              return _GhostModeToggleRow(
                state: state,
                accountRepository: accountRepository,
                colors: colors,
                type: type,
                platformTokens: platformTokens,
                l10n: l10n,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// The single toggle row for `isGhostModeEnabled` (`ux/uiux-spec.md` §3-5).
/// Stateful so a tap can optimistically flip the pill and ignore further taps
/// while its own `PATCH /users/me` call is in flight, independent of
/// `AccountCubit`'s own state — `AccountCubit.applyUpdated()` is only called
/// once the PATCH resolves.
class _GhostModeToggleRow extends StatefulWidget {
  const _GhostModeToggleRow({
    required this.state,
    required this.accountRepository,
    required this.colors,
    required this.type,
    required this.platformTokens,
    required this.l10n,
  });

  final AccountState state;
  final AccountRepository accountRepository;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;
  final AppL10n l10n;

  @override
  State<_GhostModeToggleRow> createState() => _GhostModeToggleRowState();
}

class _GhostModeToggleRowState extends State<_GhostModeToggleRow> {
  bool _inFlight = false;

  /// The tapped-to value while a PATCH is outstanding (or just resolved but
  /// `AccountCubit` has not yet re-emitted). Cleared in [didUpdateWidget] once
  /// the cubit's own state confirms the same value, never eagerly on success,
  /// so the pill never flickers back to the pre-tap value for a frame.
  bool? _optimisticValue;

  @override
  void didUpdateWidget(covariant _GhostModeToggleRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final AccountState newState = widget.state;
    if (_optimisticValue != null &&
        newState is AccountLoaded &&
        newState.profile.isGhostModeEnabled == _optimisticValue) {
      _optimisticValue = null;
    }
  }

  Future<void> _handleTap(bool currentValue) async {
    if (_inFlight) return;
    final bool newValue = !currentValue;
    setState(() {
      _inFlight = true;
      _optimisticValue = newValue;
    });

    try {
      final CupidProfile profile = await widget.accountRepository
          .updateProfile(isGhostModeEnabled: newValue);
      if (!mounted) return;
      context.read<AccountCubit>().applyUpdated(profile);
      setState(() {
        _inFlight = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _inFlight = false;
        _optimisticValue = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l10n.privacy_controls_update_error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AccountState state = widget.state;
    final CupidProfile? profile = state is AccountLoaded
        ? state.profile
        : null;

    // Fail-safe: before the first successful load (or if it fails), the
    // toggle's true state is unknown, so it renders inert in the "off" track
    // color rather than guessing (`ux/uiux-spec.md` §4).
    final bool initialInert = profile == null;
    final bool inert = initialInert || _inFlight;
    final bool value = initialInert
        ? false
        : (_optimisticValue ?? profile.isGhostModeEnabled);

    final String semanticLabel = inert
        ? widget.l10n.privacy_controls_ghost_mode_semantic_loading
        : (value
              ? widget.l10n.privacy_controls_ghost_mode_semantic_on
              : widget.l10n.privacy_controls_ghost_mode_semantic_off);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.visibility_off,
          size: 20,
          color: widget.colors.colorTextMuted,
        ),
        SizedBox(width: CupidSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.l10n.privacy_controls_ghost_mode_title,
                style: widget.type.body.copyWith(
                  color: widget.colors.colorText,
                ),
              ),
              SizedBox(height: 2),
              Text(
                widget.l10n.privacy_controls_ghost_mode_subtitle,
                style: widget.type.caption.copyWith(
                  color: widget.colors.colorTextMuted,
                ),
              ),
              if (state is AccountFailed) ...<Widget>[
                SizedBox(height: 2),
                Text(
                  widget.l10n.privacy_controls_load_error,
                  style: widget.type.caption.copyWith(
                    color: widget.colors.colorRed,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: CupidSpacing.sm),
        Semantics(
          button: true,
          enabled: !inert,
          label: semanticLabel,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: widget.platformTokens.tapTarget,
              minHeight: widget.platformTokens.tapTarget,
            ),
            child: GestureDetector(
              key: const Key('privacy-controls-ghost-mode-toggle'),
              onTap: inert
                  ? null
                  : () => _handleTap(profile.isGhostModeEnabled),
              child: Center(
                child: _TogglePill(value: value, colors: widget.colors),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Duplicated visual shape of `notification_settings_screen.dart`'s private
/// `_TogglePill` (`architecture/solution.md` §4 Mobile Lane guardrails):
/// promoting it into `design_system/` would force edits to that screen and
/// its tests, breaking the AC3 non-regression gate. Purely presentational —
/// the tap gesture and accessible label live on the caller, per
/// `ux/uiux-spec.md` §5's `ghost_settings_screen.dart` precedent.
class _TogglePill extends StatelessWidget {
  const _TogglePill({required this.value, required this.colors});

  final bool value;
  final CupidColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 50,
      height: 30,
      padding: const EdgeInsets.all(3),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: value ? colors.gradientHot : null,
        color: value ? null : colors.colorSurfaceAlt,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.colorText,
          shape: BoxShape.circle,
        ),
        child: const SizedBox(width: 24, height: 24),
      ),
    );
  }
}
