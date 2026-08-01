import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../data/ghost_config_models.dart';
import '../../data/ghost_config_repository.dart';
import '../ghost_storm_cubit.dart';

/// STORY-008 P3 chat mount seam (`architecture/solution.md` ADR-3;
/// `ux/uiux-spec.md` §2.4). Mount instruction for STORY-007 (or requirement
/// integration): place exactly one `GhostStateRow(partnerId: partner.id)`
/// below the chat message list and above the composer, below the
/// Typing-Ghost bubble. No other wiring is required — this widget owns its
/// own `GhostStormCubit`, resolves `GhostConfigRepository` from `get_it`
/// itself, and drives its own app-lifecycle poll (ADR-2); it has no compile
/// dependency on any `features/chat/` type.
///
/// Contract note: `GET /ghost-config/storm-status/:partnerId` returns only
/// `{eligible, penalty}` (`ghost_config_models.dart` `StormStatus`) — no seen
/// timestamp. `eligible: true` is therefore this row's sole "seen, no reply"
/// signal (it is only ever true once the backend has confirmed a seen,
/// unanswered message past the couple's configured timeout); the copy omits
/// an elapsed-minutes count that the contract does not supply, rather than
/// inventing a client-side clock (ADR-5 precedent: nothing client-only
/// invented). `penalty: none` is a valid active-config value distinct from
/// "no active config", which is why the CTA can be suppressed while the
/// neutral line still renders.
class GhostStateRow extends StatelessWidget {
  const GhostStateRow({super.key, required this.partnerId});

  final String partnerId;

  @override
  Widget build(BuildContext context) {
    // Mirrors `AntiGhostEntryCard`'s guard: nothing on the current
    // `HomeScreen`/`main.dart` boot path calls `setupServiceLocator()`, so
    // resolving the repository unconditionally would crash any harness that
    // mounts this row before the locator is wired.
    if (!getIt.isRegistered<GhostConfigRepository>()) {
      return const SizedBox.shrink();
    }
    return BlocProvider<GhostStormCubit>(
      create: (_) => GhostStormCubit(
        repository: getIt<GhostConfigRepository>(),
        partnerId: partnerId,
      ),
      child: const _GhostStateRowView(),
    );
  }
}

class _GhostStateRowView extends StatefulWidget {
  const _GhostStateRowView();

  @override
  State<_GhostStateRowView> createState() => _GhostStateRowViewState();
}

class _GhostStateRowViewState extends State<_GhostStateRowView>
    with WidgetsBindingObserver {
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

  /// ADR-2: app-foreground resume is a refresh trigger and restarts the 60s
  /// poll; any other lifecycle state stops it (no polling while backgrounded).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    context.read<GhostStormCubit>().handleAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GhostStormCubit, GhostStormState>(
      builder: (context, state) {
        if (state is! GhostStormLoaded || !state.status.eligible) {
          return const SizedBox.shrink();
        }
        return _EligibleRow(penalty: state.status.penalty);
      },
    );
  }
}

/// The five render cases (`coding-plan/phase-P3-chat-ghost-state-row.md` AC):
/// this widget only builds once `eligible: true`, so it always shows the
/// neutral line; the CTA pill is then branched (or omitted) on [penalty].
class _EligibleRow extends StatelessWidget {
  const _EligibleRow({required this.penalty});

  final Penalty? penalty;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final _CtaCopy? cta = _ctaFor(l10n, penalty);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: CupidSpacing.md,
        vertical: CupidSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // UX §4: never colour alone — the amber signal always pairs an
          // icon with a text label.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupidIcon(CupidIcons.timer, size: 16, color: colors.colorAmber),
              SizedBox(width: CupidSpacing.xs),
              Text(
                l10n.ghost_state_row_seen_no_reply,
                style: type.caption.copyWith(color: colors.colorAmber),
              ),
            ],
          ),
          if (cta != null) ...[
            SizedBox(height: CupidSpacing.xs),
            // Live region so screen readers announce the CTA once when it
            // newly appears; an unchanged label on a later poll tick is not
            // re-announced (Flutter only dispatches a semantics update when
            // the node's properties actually change), matching UX §4.
            Semantics(
              liveRegion: true,
              label: cta.label,
              excludeSemantics: true,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: CupidSpacing.sm,
                  vertical: CupidSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.colorAccentPink.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupidIcon(cta.icon, size: 16, color: colors.colorAccentPink),
                    SizedBox(width: CupidSpacing.xs),
                    Text(
                      cta.label,
                      style: type.caption.copyWith(color: colors.colorAccentPink),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// The CTA is suppressed for `none` and for a null `penalty` (no active
  /// config) — the neutral seen line above still renders on its own
  /// (`ux/uiux-spec.md` §2.4).
  _CtaCopy? _ctaFor(AppL10n l10n, Penalty? penalty) {
    return switch (penalty) {
      Penalty.emojiStorm => _CtaCopy(CupidIcons.cyclone, l10n.ghost_state_row_storm_cta),
      Penalty.noise => _CtaCopy(CupidIcons.volumeUp, l10n.ghost_state_row_noise_cta),
      Penalty.none || null => null,
    };
  }
}

class _CtaCopy {
  const _CtaCopy(this.icon, this.label);

  final IconData icon;
  final String label;
}
