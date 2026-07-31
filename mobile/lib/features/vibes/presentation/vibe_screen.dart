import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'vibe_cubit.dart';
import 'vibe_state.dart';
import 'vibe_strings.dart';
import 'widgets/partner_vibe_card.dart';
import 'widgets/vibe_history_strip.dart';
import 'widgets/vibe_mood_grid.dart';

/// `vibe` screen (`ux/uiux-spec.md` §2, §4, §7;
/// `coding-plan/phase-P3-vibe-screen-entrypoint.md`): composes the P1
/// [VibeCubit] and P2 widgets into header -> mood grid -> partner card ->
/// history strip, wrapped in `RefreshIndicator.adaptive` (UX §10.4
/// pull/refresh delivery, no platform fork).
///
/// [createCubit] defaults to wiring the `getIt`-registered [VibeCubit]
/// (STORY-010 P1 `service_locator.dart`); tests supply a fake
/// repository-backed instance instead, mirroring `SplashScreen`'s
/// `createSessionGateCubit` precedent
/// (`features/auth/presentation/screens/splash_screen.dart`).
class VibeScreen extends StatelessWidget {
  const VibeScreen({super.key, VibeCubit Function()? createCubit})
    : _createCubit = createCubit;

  final VibeCubit Function()? _createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VibeCubit>(
      create: (_) => (_createCubit ?? () => getIt<VibeCubit>())()..load(),
      child: const _VibeView(),
    );
  }
}

class _VibeView extends StatelessWidget {
  const _VibeView();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Scaffold(
      backgroundColor: colors.colorBackground,
      appBar: CupidHeader(
        title: context.checkInPromptTitle,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: BlocBuilder<VibeCubit, VibeState>(
        builder: (context, state) {
          return RefreshIndicator.adaptive(
            onRefresh: () => context.read<VibeCubit>().refresh(),
            child: ListView(
              padding: EdgeInsets.all(CupidSpacing.lg),
              children: <Widget>[
                Text(
                  context.checkInPromptSubtitle,
                  style: context.cupidType.body.copyWith(
                    color: colors.colorTextMuted,
                  ),
                ),
                SizedBox(height: CupidSpacing.lg),
                VibeMoodGrid(
                  selected: state.selectedMood,
                  enabled: !state.submitting,
                  onPick: (mood) => context.read<VibeCubit>().pick(mood),
                ),
                if (state.failure != null) ...[
                  SizedBox(height: CupidSpacing.sm),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _vibeFailureMessage(context, state.failure!),
                      style: context.cupidType.caption.copyWith(
                        color: colors.colorRed,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: CupidSpacing.lg),
                PartnerVibeCard(mood: state.partnerToday),
                SizedBox(height: CupidSpacing.lg),
                VibeHistoryStrip(mine: state.myWeek, partner: state.partnerWeek),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Maps a [CupidApiFailure] to one short inline line (UX §4), mirroring the
/// STORY-003 `authFailureMessage` convention
/// (`features/auth/presentation/auth_failure_text.dart`) rather than
/// exposing the raw failure type to the UI. `vibe_strings.dart` is P2's write
/// scope, so this mapping stays local to this phase's file.
String _vibeFailureMessage(BuildContext context, CupidApiFailure failure) {
  return switch (failure) {
    NetworkUnavailableFailure() => context.viEn(
      'Không có kết nối mạng',
      'No internet connection',
    ),
    TimeoutFailure() => context.viEn(
      'Kết nối quá chậm, vui lòng thử lại',
      'Connection timed out, please try again',
    ),
    UnauthorizedFailure() => context.viEn(
      'Phiên đăng nhập đã hết hạn',
      'Your session has expired',
    ),
    HttpStatusFailure() || UnexpectedFailure() => context.viEn(
      'Đã có lỗi xảy ra. Vui lòng thử lại.',
      'Something went wrong. Please try again.',
    ),
  };
}
