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

/// Screen chrome title, `t_vibe` in the design source's locale maps — the
/// same literal in `vi` and `en`, so it does not route through
/// `vibe_strings.dart` (which is outside this story's write scope anyway).
const String _vibeScreenTitle = 'Vibe Check';

/// Design-source geometry with no token equivalent (`Cupid Screens.dc.html`,
/// `isVibe` block): screen padding `8px 16px 40px`, hero block padding
/// `14px 0 22px` with a 7px title/subtitle gap, and a 27px/1.25 hero title.
const double _screenTopPadding = 8;
const double _screenBottomPadding = 40;
const double _heroTopPadding = 14;
const double _heroBottomPadding = 22;
const double _heroSubtitleGap = 7;
const double _heroTitleSize = 27;
const double _heroTitleHeight = 1.25;

/// The decorative halo behind the hero title: a 180x90 box carrying
/// `radial-gradient(circle, rgba(255,127,182,.28), transparent 68%)`. CSS
/// sizes that circle to the farthest corner (`sqrt(90^2 + 45^2) = 100.62`),
/// which Flutter expresses as a fraction of the box's shortest side (90).
const double _heroGlowWidth = 180;
const double _heroGlowHeight = 90;
const double _heroGlowRadius = 1.118034;
const double _heroGlowOpacity = 0.28;
const double _heroGlowFadeStop = 0.68;

/// Gap between the mood grid and the partner card (`margin-top:16px`) and
/// between the partner card and the history strip (`margin-top:13px`).
const double _partnerCardTopGap = CupidSpacing.md;
const double _historyStripTopGap = 13;

class _VibeView extends StatelessWidget {
  const _VibeView();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Scaffold(
      appBar: CupidHeader(
        title: _vibeScreenTitle,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: BlocBuilder<VibeCubit, VibeState>(
        builder: (context, state) {
          return RefreshIndicator.adaptive(
            onRefresh: () => context.read<VibeCubit>().refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                CupidSpacing.md,
                _screenTopPadding,
                CupidSpacing.md,
                _screenBottomPadding,
              ),
              children: <Widget>[
                const _VibeHero(),
                VibeMoodGrid(
                  selected: state.selectedMood,
                  enabled: !state.submitting,
                  onPick: (mood) => context.read<VibeCubit>().pick(mood),
                ),
                if (state.failure != null) ...[
                  const SizedBox(height: CupidSpacing.sm),
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
                const SizedBox(height: _partnerCardTopGap),
                PartnerVibeCard(mood: state.partnerToday),
                const SizedBox(height: _historyStripTopGap),
                VibeHistoryStrip(mine: state.myWeek, partner: state.partnerWeek),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The centered prompt block above the mood grid: halo, 27px display title
/// and muted subtitle. The design source animates the halo (`breathe
/// 6.5s infinite`); it is rendered statically here because an unbounded
/// repeating animation makes `pumpAndSettle` in this feature's widget tests
/// time out.
class _VibeHero extends StatelessWidget {
  const _VibeHero();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Stack(
      alignment: Alignment.topCenter,
      // The halo is 90 tall while the padded text block is shorter, and it is
      // decorative overflow in the source too (`position:absolute` with no
      // containing-block clip), so the Stack must not crop it.
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          // `top:0` resolves against the hero block's own box in the source,
          // not against the text inside its 14px top padding — so the halo
          // sits outside that Padding.
          top: 0,
          child: IgnorePointer(
            child: Container(
              width: _heroGlowWidth,
              height: _heroGlowHeight,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: _heroGlowRadius,
                  colors: <Color>[
                    colors.colorAccentPink.withValues(alpha: _heroGlowOpacity),
                    colors.colorAccentPink.withValues(alpha: 0),
                  ],
                  stops: const <double>[0, _heroGlowFadeStop],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: _heroTopPadding,
            bottom: _heroBottomPadding,
          ),
          child: Column(
            children: <Widget>[
              Text(
                context.checkInPromptTitle,
                textAlign: TextAlign.center,
                style: context.cupidType.display.copyWith(
                  fontSize: _heroTitleSize,
                  height: _heroTitleHeight,
                  color: colors.colorText,
                ),
              ),
              const SizedBox(height: _heroSubtitleGap),
              Text(
                context.checkInPromptSubtitle,
                textAlign: TextAlign.center,
                style: context.cupidType.caption.copyWith(
                  color: colors.colorTextMuted,
                ),
              ),
            ],
          ),
        ),
      ],
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
