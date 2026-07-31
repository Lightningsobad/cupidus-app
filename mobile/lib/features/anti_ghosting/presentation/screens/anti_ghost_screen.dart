import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/realtime/backend_user_id_store.dart';
import '../../data/ghost_config_models.dart';
import '../../data/ghost_config_repository.dart';
import '../anti_ghost_cubit.dart';

/// STORY-008 P1 (`ux/uiux-spec.md` §2.3 `antighost`): the four config
/// lifecycle states plus the AC3 pairing guard.
class AntiGhostScreen extends StatelessWidget {
  const AntiGhostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AntiGhostCubit>(
      create: (_) => AntiGhostCubit(
        repository: getIt<GhostConfigRepository>(),
        backendUserIdStore: getIt<BackendUserIdStore>(),
      ),
      child: const _AntiGhostView(),
    );
  }
}

class _AntiGhostView extends StatefulWidget {
  const _AntiGhostView();

  @override
  State<_AntiGhostView> createState() => _AntiGhostViewState();
}

class _AntiGhostViewState extends State<_AntiGhostView> with WidgetsBindingObserver {
  bool _isEditingActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// ADR-2: app-foreground resume is one of the pull-model refresh triggers
  /// (no push channel exists for config proposals).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AntiGhostCubit>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;

    return Scaffold(
      backgroundColor: colors.colorBackground,
      appBar: CupidHeader(
        title: l10n.anti_ghost_title,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: BlocBuilder<AntiGhostCubit, AntiGhostState>(
          builder: (context, state) => switch (state) {
            AntiGhostLoading() => const Center(child: CircularProgressIndicator()),
            AntiGhostPairingRequired() => _GuardBody(l10n: l10n),
            AntiGhostLoadFailed() => _LoadFailedBody(l10n: l10n),
            AntiGhostLoaded() => _buildLifecycle(context, l10n, state),
          },
        ),
      ),
    );
  }

  /// State D shows the read-only summary unless the user tapped "Change"
  /// (`ux/uiux-spec.md` §2.3 State D), in which case it falls through to the
  /// same form as State A, pre-filled and submitting as a new proposal.
  Widget _buildLifecycle(BuildContext context, AppL10n l10n, AntiGhostLoaded state) {
    final AntiGhostLifecycle lifecycle = state.lifecycle;

    if (lifecycle is AntiGhostActiveConfig && !_isEditingActive) {
      return _ActiveSummaryBody(
        l10n: l10n,
        config: lifecycle.config,
        onChange: () => setState(() => _isEditingActive = true),
      );
    }
    if (lifecycle is AntiGhostNoConfig || lifecycle is AntiGhostActiveConfig) {
      final GhostConfig? prefill = lifecycle is AntiGhostActiveConfig ? lifecycle.config : null;
      return _ProposeForm(
        l10n: l10n,
        prefill: prefill,
        isSubmitting: state.isSubmitting,
        actionFailure: state.actionFailure,
        onSubmit: (minutes, penalty) => context.read<AntiGhostCubit>().propose(
          timeoutMinutes: minutes,
          penalty: penalty,
        ),
      );
    }
    if (lifecycle is AntiGhostPendingMine) {
      return _PendingMineBody(l10n: l10n, config: lifecycle.config);
    }
    if (lifecycle is AntiGhostPendingPartner) {
      return _PendingPartnerBody(
        l10n: l10n,
        config: lifecycle.config,
        isSubmitting: state.isSubmitting,
        onAccept: () => context.read<AntiGhostCubit>().approve(lifecycle.config.id),
        onDecline: () => context.read<AntiGhostCubit>().reject(lifecycle.config.id),
      );
    }
    // AntiGhostPendingUnknownRole (ADR-4): backend user id not resolved yet.
    return _PendingUnknownBody(l10n: l10n);
  }
}

String _penaltyLabel(AppL10n l10n, Penalty penalty) {
  return switch (penalty) {
    Penalty.emojiStorm => l10n.anti_ghost_penalty_emoji_storm,
    Penalty.noise => l10n.anti_ghost_penalty_noise,
    Penalty.none => l10n.anti_ghost_penalty_none,
  };
}

IconData _penaltyIcon(Penalty penalty) {
  return switch (penalty) {
    Penalty.emojiStorm => CupidIcons.cyclone,
    Penalty.noise => CupidIcons.volumeUp,
    Penalty.none => CupidIcons.notificationsOff,
  };
}

/// AC3 guard state (`ux/uiux-spec.md` §1): no mutating call is ever made here.
class _GuardBody extends StatelessWidget {
  const _GuardBody({required this.l10n});

  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(CupidSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.anti_ghost_guard_title,
              textAlign: TextAlign.center,
              style: type.cardTitle.copyWith(color: colors.colorText),
            ),
            SizedBox(height: CupidSpacing.sm),
            Text(
              l10n.anti_ghost_guard_body,
              textAlign: TextAlign.center,
              style: type.body.copyWith(color: colors.colorTextMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadFailedBody extends StatelessWidget {
  const _LoadFailedBody({required this.l10n});

  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(CupidSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.anti_ghost_load_error,
              textAlign: TextAlign.center,
              style: type.body.copyWith(color: colors.colorText),
            ),
            SizedBox(height: CupidSpacing.md),
            CupidPrimaryButton(
              label: l10n.anti_ghost_retry_cta,
              onPressed: () => context.read<AntiGhostCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }
}

/// State D (`ux/uiux-spec.md` §2.3): active-config summary + "Change".
class _ActiveSummaryBody extends StatelessWidget {
  const _ActiveSummaryBody({
    required this.l10n,
    required this.config,
    required this.onChange,
  });

  final AppL10n l10n;
  final GhostConfig config;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return SingleChildScrollView(
      padding: EdgeInsets.all(CupidSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(CupidSpacing.md),
            decoration: BoxDecoration(
              color: colors.colorSurface,
              borderRadius: BorderRadius.circular(CupidSpacing.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CupidIcon(_penaltyIcon(config.penalty), color: colors.colorAccentPink),
                    SizedBox(width: CupidSpacing.sm),
                    Text(
                      l10n.anti_ghost_active_label,
                      style: type.cardTitle.copyWith(color: colors.colorText),
                    ),
                  ],
                ),
                SizedBox(height: CupidSpacing.sm),
                Text(
                  l10n.anti_ghost_active_summary(
                    config.timeoutMinutes,
                    _penaltyLabel(l10n, config.penalty),
                  ),
                  style: type.body.copyWith(color: colors.colorTextMuted),
                ),
              ],
            ),
          ),
          SizedBox(height: CupidSpacing.lg),
          CupidPrimaryButton(label: l10n.anti_ghost_change_cta, onPressed: onChange),
        ],
      ),
    );
  }
}

/// State B (`ux/uiux-spec.md` §2.3, §4; ADR-6): read-only summary, waiting
/// badge, and a disabled-but-visible controls preview carrying the
/// accessible disabled reason.
class _PendingMineBody extends StatelessWidget {
  const _PendingMineBody({required this.l10n, required this.config});

  final AppL10n l10n;
  final GhostConfig config;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final String penaltyLabel = _penaltyLabel(l10n, config.penalty);
    final bool isPreset = _timeoutPresets.contains(config.timeoutMinutes);

    return SingleChildScrollView(
      padding: EdgeInsets.all(CupidSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.anti_ghost_pending_mine_title,
            style: type.cardTitle.copyWith(color: colors.colorText),
          ),
          SizedBox(height: CupidSpacing.xs),
          Text(
            l10n.anti_ghost_active_summary(config.timeoutMinutes, penaltyLabel),
            style: type.body.copyWith(color: colors.colorTextMuted),
          ),
          SizedBox(height: CupidSpacing.sm),
          Container(
            padding: EdgeInsets.symmetric(horizontal: CupidSpacing.md, vertical: CupidSpacing.sm),
            decoration: BoxDecoration(
              color: colors.colorAccentPurple.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupidIcon(CupidIcons.timer, size: 18, color: colors.colorAccentPurple),
                SizedBox(width: CupidSpacing.xs),
                Text(
                  l10n.anti_ghost_pending_mine_badge,
                  style: type.caption.copyWith(color: colors.colorAccentPurple),
                ),
              ],
            ),
          ),
          SizedBox(height: CupidSpacing.lg),
          Text(
            l10n.anti_ghost_timeout_label,
            style: type.cardTitle.copyWith(color: colors.colorTextMuted),
          ),
          SizedBox(height: CupidSpacing.sm),
          Semantics(
            label: l10n.anti_ghost_pending_mine_disabled_reason,
            container: true,
            // Without this, plain (non-interactive) descendant Text nodes
            // such as the "Penalty" section header merge their own label up
            // into this node's label instead of staying separate.
            explicitChildNodes: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TimeoutChipRow(
                  l10n: l10n,
                  colors: colors,
                  presets: _timeoutPresets,
                  selectedPreset: isPreset ? config.timeoutMinutes : null,
                  isCustom: !isPreset,
                  enabled: false,
                ),
                if (!isPreset)
                  Padding(
                    padding: EdgeInsets.only(top: CupidSpacing.xs),
                    child: Text(
                      l10n.anti_ghost_timeout_minutes_label(config.timeoutMinutes),
                      style: type.body.copyWith(color: colors.colorTextMuted),
                    ),
                  ),
                SizedBox(height: CupidSpacing.sm),
                Text(
                  l10n.anti_ghost_penalty_label,
                  style: type.cardTitle.copyWith(color: colors.colorTextMuted),
                ),
                _PenaltyRadioGroup(
                  l10n: l10n,
                  colors: colors,
                  type: type,
                  selected: config.penalty,
                  enabled: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// State C (`ux/uiux-spec.md` §2.3, §4): review card + Accept/Decline, each
/// carrying a full accessible label naming the actual proposed values.
class _PendingPartnerBody extends StatelessWidget {
  const _PendingPartnerBody({
    required this.l10n,
    required this.config,
    required this.isSubmitting,
    required this.onAccept,
    required this.onDecline,
  });

  final AppL10n l10n;
  final GhostConfig config;
  final bool isSubmitting;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final String penaltyLabel = _penaltyLabel(l10n, config.penalty);

    return SingleChildScrollView(
      padding: EdgeInsets.all(CupidSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.anti_ghost_pending_partner_title,
            style: type.cardTitle.copyWith(color: colors.colorText),
          ),
          SizedBox(height: CupidSpacing.sm),
          Container(
            padding: EdgeInsets.all(CupidSpacing.md),
            decoration: BoxDecoration(
              color: colors.colorSurface,
              borderRadius: BorderRadius.circular(CupidSpacing.md),
            ),
            child: Row(
              children: [
                CupidIcon(_penaltyIcon(config.penalty), color: colors.colorAccentPink),
                SizedBox(width: CupidSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.anti_ghost_active_summary(config.timeoutMinutes, penaltyLabel),
                    style: type.body.copyWith(color: colors.colorText),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: CupidSpacing.lg),
          Semantics(
            label: l10n.anti_ghost_accept_semantic_label(config.timeoutMinutes, penaltyLabel),
            button: true,
            excludeSemantics: true,
            child: CupidPrimaryButton(
              label: l10n.anti_ghost_accept_cta,
              onPressed: isSubmitting ? null : onAccept,
            ),
          ),
          SizedBox(height: CupidSpacing.sm),
          Semantics(
            label: l10n.anti_ghost_decline_semantic_label(config.timeoutMinutes, penaltyLabel),
            button: true,
            excludeSemantics: true,
            child: TextButton(
              onPressed: isSubmitting ? null : onDecline,
              child: Text(
                l10n.anti_ghost_decline_cta,
                style: type.body.copyWith(color: colors.colorTextMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ADR-4: `backendUserId` not resolved yet — read-only, no actions.
class _PendingUnknownBody extends StatelessWidget {
  const _PendingUnknownBody({required this.l10n});

  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    return SingleChildScrollView(
      padding: EdgeInsets.all(CupidSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.anti_ghost_pending_unknown_title,
            style: type.cardTitle.copyWith(color: colors.colorText),
          ),
          SizedBox(height: CupidSpacing.sm),
          Text(
            l10n.anti_ghost_pending_unknown_notice,
            style: type.body.copyWith(color: colors.colorTextMuted),
          ),
        ],
      ),
    );
  }
}

/// State A form (also State D's "Change", pre-filled) (`ux/uiux-spec.md`
/// §2.3 State A).
class _ProposeForm extends StatefulWidget {
  const _ProposeForm({
    required this.l10n,
    required this.prefill,
    required this.isSubmitting,
    required this.actionFailure,
    required this.onSubmit,
  });

  final AppL10n l10n;
  final GhostConfig? prefill;
  final bool isSubmitting;
  final Object? actionFailure;
  final void Function(int minutes, Penalty penalty) onSubmit;

  @override
  State<_ProposeForm> createState() => _ProposeFormState();
}

class _ProposeFormState extends State<_ProposeForm> {
  int? _selectedPreset;
  bool _isCustom = false;
  double _customMinutes = 30;
  late Penalty _penalty;

  @override
  void initState() {
    super.initState();
    final int? prefillMinutes = widget.prefill?.timeoutMinutes;
    if (prefillMinutes != null && !_timeoutPresets.contains(prefillMinutes)) {
      _isCustom = true;
      _customMinutes = prefillMinutes.toDouble();
    } else {
      _selectedPreset = prefillMinutes ?? _timeoutPresets.first;
    }
    _penalty = widget.prefill?.penalty ?? Penalty.emojiStorm;
  }

  int get _effectiveMinutes =>
      _isCustom ? _customMinutes.round() : (_selectedPreset ?? _timeoutPresets.first);

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = widget.l10n;
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return SingleChildScrollView(
      padding: EdgeInsets.all(CupidSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.anti_ghost_intro_title,
            style: type.cardTitle.copyWith(color: colors.colorText),
          ),
          SizedBox(height: CupidSpacing.sm),
          Text(
            l10n.anti_ghost_intro_subtitle,
            style: type.body.copyWith(color: colors.colorTextMuted),
          ),
          SizedBox(height: CupidSpacing.lg),
          Text(
            l10n.anti_ghost_timeout_label,
            style: type.cardTitle.copyWith(color: colors.colorText),
          ),
          SizedBox(height: CupidSpacing.xs),
          Text(
            l10n.anti_ghost_timeout_hint,
            style: type.caption.copyWith(color: colors.colorTextMuted),
          ),
          SizedBox(height: CupidSpacing.sm),
          _TimeoutChipRow(
            l10n: l10n,
            colors: colors,
            presets: _timeoutPresets,
            selectedPreset: _selectedPreset,
            isCustom: _isCustom,
            enabled: true,
            onSelectPreset: (minutes) => setState(() {
              _isCustom = false;
              _selectedPreset = minutes;
            }),
            onSelectCustom: () => setState(() => _isCustom = true),
          ),
          if (_isCustom) ...[
            SizedBox(height: CupidSpacing.sm),
            Text(
              l10n.anti_ghost_timeout_minutes_label(_customMinutes.round()),
              style: type.body.copyWith(color: colors.colorText),
            ),
            Slider(
              min: 1,
              max: 120,
              divisions: 119,
              value: _customMinutes,
              activeColor: colors.colorAccentPink,
              onChanged: (value) => setState(() => _customMinutes = value),
            ),
            Text(
              l10n.anti_ghost_timeout_custom_hint,
              style: type.caption.copyWith(color: colors.colorTextMuted),
            ),
          ],
          SizedBox(height: CupidSpacing.lg),
          Text(
            l10n.anti_ghost_penalty_label,
            style: type.cardTitle.copyWith(color: colors.colorText),
          ),
          _PenaltyRadioGroup(
            l10n: l10n,
            colors: colors,
            type: type,
            selected: _penalty,
            enabled: true,
            onChanged: (penalty) => setState(() => _penalty = penalty),
          ),
          if (widget.actionFailure != null) ...[
            SizedBox(height: CupidSpacing.sm),
            Text(
              l10n.anti_ghost_action_error_generic,
              style: type.caption.copyWith(color: colors.colorRed),
            ),
          ],
          SizedBox(height: CupidSpacing.lg),
          CupidPrimaryButton(
            label: l10n.anti_ghost_propose_cta,
            onPressed: widget.isSubmitting
                ? null
                : () => widget.onSubmit(_effectiveMinutes, _penalty),
          ),
        ],
      ),
    );
  }
}

const List<int> _timeoutPresets = <int>[5, 10, 15];

/// Single-select radio group for [Penalty] (`ux/uiux-spec.md` §2.3, §4:
/// "radio-group semantics ... not three independent switch/toggle
/// semantics"). Shared between the editable form and State B's disabled
/// preview.
class _PenaltyRadioGroup extends StatelessWidget {
  const _PenaltyRadioGroup({
    required this.l10n,
    required this.colors,
    required this.type,
    required this.selected,
    required this.enabled,
    this.onChanged,
  });

  final AppL10n l10n;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final Penalty selected;
  final bool enabled;
  final ValueChanged<Penalty>? onChanged;

  @override
  Widget build(BuildContext context) {
    final Color contentColor = enabled ? colors.colorText : colors.colorTextMuted;
    // RadioGroup's onChanged is non-nullable (unlike the deprecated
    // per-Radio groupValue/onChanged pair), so the disabled variant blocks
    // interaction with IgnorePointer instead of a null callback.
    return IgnorePointer(
      ignoring: !enabled,
      child: RadioGroup<Penalty>(
        groupValue: selected,
        onChanged: (Penalty? value) => onChanged?.call(value ?? selected),
        child: Column(
          children: Penalty.values.map((Penalty penalty) {
            return RadioListTile<Penalty>(
              value: penalty,
              activeColor: colors.colorAccentPink,
              contentPadding: EdgeInsets.zero,
              secondary: CupidIcon(_penaltyIcon(penalty), color: contentColor),
              title: Text(_penaltyLabel(l10n, penalty), style: type.body.copyWith(color: contentColor)),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Timeout preset chip row, shared between the editable form and State B's
/// disabled preview.
class _TimeoutChipRow extends StatelessWidget {
  const _TimeoutChipRow({
    required this.l10n,
    required this.colors,
    required this.presets,
    required this.selectedPreset,
    required this.isCustom,
    required this.enabled,
    this.onSelectPreset,
    this.onSelectCustom,
  });

  final AppL10n l10n;
  final CupidColorTokens colors;
  final List<int> presets;
  final int? selectedPreset;
  final bool isCustom;
  final bool enabled;
  final ValueChanged<int>? onSelectPreset;
  final VoidCallback? onSelectCustom;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CupidSpacing.sm,
      runSpacing: CupidSpacing.sm,
      children: [
        for (final int minutes in presets)
          ChoiceChip(
            label: Text(l10n.anti_ghost_timeout_minutes_label(minutes)),
            selected: !isCustom && selectedPreset == minutes,
            onSelected: enabled ? (_) => onSelectPreset?.call(minutes) : null,
            selectedColor: colors.colorAccentPink,
          ),
        ChoiceChip(
          label: Text(l10n.anti_ghost_timeout_custom_label),
          selected: isCustom,
          onSelected: enabled ? (_) => onSelectCustom?.call() : null,
          selectedColor: colors.colorAccentPink,
        ),
      ],
    );
  }
}
