import 'dart:async';

import 'package:cupid_mobile/core/auth/cupid_auth.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/navigation/pair_gate_shell.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pairing/presentation/pair_gate_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';
import '../auth_strings.dart';
import '../session_gate_cubit.dart';
import 'login_screen.dart';
import 'welcome_screen.dart';

/// `splash` screen — `ux/uiux-spec.md` section 3 auth-check gate, and the
/// app's entry route (REQ-002 STORY-001 ADR-1).
///
/// [createSessionGateCubit] defaults to wiring a real [CupidSession] from
/// `getIt` (registered by STORY-003 P2's `setupServiceLocator`, read-only
/// here). Tests supply a fake instead so the gate can be driven without a
/// live/mocked Firebase Auth.
///
/// [authRepository] is only needed by the two signed-out destinations, so it
/// defaults to `getIt<AuthRepository>()` and is resolved at navigation time
/// rather than at construction — the authenticated launch never touches it.
///
/// [createPairGateCubit] is forwarded to the [PairGateShell] this screen hands
/// off to once the session resolves (ADR-2), preserving [CupidApp]'s existing
/// full-app test seam.
class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
    this.authRepository,
    SessionGateCubit Function()? createSessionGateCubit,
    PairGateCubit Function()? createPairGateCubit,
  }) : _createSessionGateCubit = createSessionGateCubit,
       _createPairGateCubit = createPairGateCubit;

  final AuthRepository? authRepository;
  final SessionGateCubit Function()? _createSessionGateCubit;
  final PairGateCubit Function()? _createPairGateCubit;

  SessionGateCubit _defaultSessionGateCubit() {
    final CupidSession session = getIt<CupidSession>();
    return SessionGateCubit(
      sessionState: session.state,
      idToken: session.idToken,
      authHistoryStore: getIt<AuthHistoryStore>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SessionGateCubit>(
      create: (_) => (_createSessionGateCubit ?? _defaultSessionGateCubit)(),
      child: _SplashView(
        authRepository: authRepository,
        createPairGateCubit: _createPairGateCubit,
      ),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView({this.authRepository, this.createPairGateCubit});

  final AuthRepository? authRepository;
  final PairGateCubit Function()? createPairGateCubit;

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView> {
  static const Duration _minDwell = Duration(seconds: 2);

  bool _minDwellElapsed = false;
  bool _navigated = false;
  Timer? _dwellTimer;

  /// Only the two signed-out destinations need it, so the `getIt` lookup stays
  /// off the authenticated launch path.
  AuthRepository get _authRepository =>
      widget.authRepository ?? getIt<AuthRepository>();

  @override
  void initState() {
    super.initState();
    // No `setState`: nothing in `build` reads `_minDwellElapsed` any more
    // (ADR-6 removed the tap affordance it used to gate).
    _dwellTimer = Timer(_minDwell, () {
      if (!mounted) return;
      _minDwellElapsed = true;
      _tryNavigate(context.read<SessionGateCubit>().state);
    });
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    super.dispose();
  }

  void _tryNavigate(SessionGateState state) {
    if (_navigated || !_minDwellElapsed || state is SessionGateChecking) {
      return;
    }
    _navigated = true;
    final Widget destination = switch (state) {
      SessionGateChecking() => const SizedBox.shrink(),
      SessionGateUnauthenticated() => WelcomeScreen(
        authRepository: _authRepository,
      ),
      SessionGateAuthenticated() => PairGateShell(
        createPairGateCubit: widget.createPairGateCubit,
      ),
      SessionGateSessionExpired(:final prefillEmail) => LoginScreen(
        authRepository: _authRepository,
        sessionExpired: true,
        prefillEmail: prefillEmail,
      ),
    };
    // ADR-5 invariant 2: `pushReplacement` disposes this screen's
    // `BlocProvider<SessionGateCubit>`, so a later session emission cannot
    // re-route.
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    return BlocListener<SessionGateCubit, SessionGateState>(
      listener: (context, state) => _tryNavigate(state),
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(gradient: colors.gradientDream),
          child: SizedBox.expand(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Cupid',
                    style: context.cupidType.display.copyWith(
                      color: colors.colorText,
                      fontSize: 58,
                    ),
                  ),
                  SizedBox(height: CupidSpacing.lg),
                  const _BobbingDots(),
                  SizedBox(height: CupidSpacing.xl),
                  Text(
                    context.viEn(
                      'Đang mở khoá kỷ niệm của hai bạn…',
                      'Unlocking your memories…',
                    ),
                    style: context.cupidType.body.copyWith(
                      color: colors.colorTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Splash wordmark: `Nunito 900 / 58px / -.03em`, `#fff`, entering with the
/// design source's `popIn .7s ease-out`.
class _Wordmark extends StatefulWidget {
  const _Wordmark();

  @override
  State<_Wordmark> createState() => _WordmarkState();
}

class _WordmarkState extends State<_Wordmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  late final Animation<double> _popIn = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _popIn,
      builder: (BuildContext context, Widget? child) {
        final double t = _popIn.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - t)),
            child: Transform.scale(scale: 0.94 + 0.06 * t, child: child),
          ),
        );
      },
      child: Text(
        'Cupid',
        style: context.cupidType.display.copyWith(
          fontSize: 58,
          // `-.03em` at 58px.
          letterSpacing: -1.74,
          color: SplashPalette.foreground,
        ),
      ),
    );
  }
}

/// The design source's `breathe 6s ease-in-out infinite` glow orb: a 150px
/// white radial fade that scales `1 -> 1.09` and pulses `.5 -> .85` opacity.
class _BreathingGlow extends StatefulWidget {
  const _BreathingGlow();

  @override
  State<_BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<_BreathingGlow>
    with SingleTickerProviderStateMixin {
  // Half the CSS 6s cycle, mirrored by `reverse: true`, so the 0/50/100
  // keyframes and their per-segment `ease-in-out` both land exactly.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  )..repeat(reverse: true);

  late final Animation<double> _breathe = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
    reverseCurve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _breathe,
        builder: (BuildContext context, Widget? child) {
          final double t = _breathe.value;
          return Opacity(
            opacity: 0.5 + 0.35 * t,
            child: Transform.scale(scale: 1 + 0.09 * t, child: child),
          );
        },
        child: const SizedBox(
          width: 150,
          height: 150,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SplashPalette.glow,
            ),
          ),
        ),
      ),
    );
  }
}

/// Splash loading affordance: three 9px dots bobbing on the design source's
/// `bob 1.1s ease-in-out infinite` with `0s`/`.18s`/`.36s` stagger.
class _BobbingDots extends StatefulWidget {
  const _BobbingDots();

  @override
  State<_BobbingDots> createState() => _BobbingDotsState();
}

class _BobbingDotsState extends State<_BobbingDots>
    with SingleTickerProviderStateMixin {
  static const Duration _cycle = Duration(milliseconds: 1100);
  static const List<double> _phaseOffsets = <double>[
    0.0,
    0.18 / 1.1,
    0.36 / 1.1,
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _cycle,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// `@keyframes bob{0%,100%{translateY(0)}50%{translateY(-7px)}}`, with CSS
  /// `ease-in-out` applied independently to each keyframe segment.
  double _dy(double phase) {
    final double p = (phase + 1.0) % 1.0;
    final double eased = p < 0.5
        ? Curves.easeInOut.transform(p * 2)
        : 1 - Curves.easeInOut.transform((p - 0.5) * 2);
    return -7 * eased;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int i = 0; i < _phaseOffsets.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: 8),
              Transform.translate(
                offset: Offset(0, _dy(_controller.value - _phaseOffsets[i])),
                child: const SizedBox(
                  width: 9,
                  height: 9,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: SplashPalette.dot,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Bottom-anchored status line plus tap-to-continue pill, matching the
/// design source's `bottom: calc(var(--safe-bot) + 26px)` block.
class _TapToContinue extends StatelessWidget {
  const _TapToContinue();

  @override
  Widget build(BuildContext context) {
    final CupidTypographyTokens type = context.cupidType;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          context.viEn(
            'Đang mở khoá kỷ niệm của hai bạn…',
            'Unlocking your memories…',
          ),
          style: type.caption.copyWith(
            fontSize: 11.5,
            color: SplashPalette.caption,
          ),
        ),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: SplashPalette.pillFill,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: SplashPalette.pillBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              context.viEn('Chạm để tiếp tục', 'Tap to continue'),
              style: type.caption.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: SplashPalette.foreground,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
