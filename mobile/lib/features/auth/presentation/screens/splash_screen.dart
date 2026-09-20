import 'dart:async';

import 'package:cupid_mobile/core/auth/cupid_auth.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/navigation/pair_gate_shell.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/chapter_closure/domain/return_gate_resolver.dart';
import 'package:cupid_mobile/features/chapter_closure/presentation/screens/return_screen.dart';
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
    this.returnGateResolver,
    SessionGateCubit Function()? createSessionGateCubit,
    PairGateCubit Function()? createPairGateCubit,
  }) : _createSessionGateCubit = createSessionGateCubit,
       _createPairGateCubit = createPairGateCubit;

  final AuthRepository? authRepository;
  final ReturnGateResolver? returnGateResolver;
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
        returnGateResolver: returnGateResolver,
        createPairGateCubit: _createPairGateCubit,
      ),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView({
    this.authRepository,
    this.returnGateResolver,
    this.createPairGateCubit,
  });

  final AuthRepository? authRepository;
  final ReturnGateResolver? returnGateResolver;
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
    if (state is SessionGateAuthenticated) {
      unawaited(_navigateAuthenticated());
      return;
    }
    final Widget destination = switch (state) {
      SessionGateUnauthenticated() => WelcomeScreen(
        authRepository: _authRepository,
      ),
      SessionGateSessionExpired(:final prefillEmail) => LoginScreen(
        authRepository: _authRepository,
        sessionExpired: true,
        prefillEmail: prefillEmail,
      ),
      _ => const SizedBox.shrink(),
    };
    _replaceWith(destination);
  }

  /// REQ-016 STORY-013 P6: the only branch that asks the return gate anything.
  ///
  /// The new open mark is written as soon as the decision is made, so J13 shows
  /// at most once even if the user never taps anything on it (AC-18, AC-24). An
  /// unregistered resolver means "no return gate" rather than a crash, matching
  /// how this screen's other `getIt` seams degrade in harnesses that register
  /// only what they exercise.
  Future<void> _navigateAuthenticated() async {
    final ReturnGateResolver? resolver =
        widget.returnGateResolver ??
        (getIt.isRegistered<ReturnGateResolver>()
            ? getIt<ReturnGateResolver>()
            : null);
    bool showReturn = false;
    if (resolver != null) {
      showReturn = await resolver.shouldShow();
      await resolver.markOpened();
    }
    if (!mounted) {
      return;
    }
    _replaceWith(
      showReturn
          ? ReturnScreen(createPairGateCubit: widget.createPairGateCubit)
          : PairGateShell(createPairGateCubit: widget.createPairGateCubit),
    );
  }

  void _replaceWith(Widget destination) {
    // ADR-5 invariant 2: `pushReplacement` disposes this screen's
    // `BlocProvider<SessionGateCubit>`, so a later session emission cannot
    // re-route.
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
    // Read above `Scaffold`, which consumes the bottom inset for its own body
    // layout; the design source measures the status line from the raw
    // `--safe-bot` frame inset.
    final double safeBottom = MediaQuery.paddingOf(context).bottom;
    return BlocListener<SessionGateCubit, SessionGateState>(
      listener: (context, state) => _tryNavigate(state),
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: SplashPalette.background),
          child: SizedBox.expand(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Positioned(
                      top: constraints.maxHeight * 0.22,
                      left: constraints.maxWidth * 0.14,
                      child: const _BreathingGlow(),
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _SplashHero(),
                        SizedBox(height: 26),
                        _BobbingDots(),
                      ],
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: safeBottom + 26,
                      child: const _StatusLine(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Splash hero: animated [CupidLogo] (with opening arc animation & bounce) and
/// wordmark `Nunito 900 / 58px / -.03em`, `#fff`, entering with `popIn .9s ease-out`.
class _SplashHero extends StatefulWidget {
  const _SplashHero();

  @override
  State<_SplashHero> createState() => _SplashHeroState();
}

class _SplashHeroState extends State<_SplashHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, _) {
              return CupidLogo(
                size: 76,
                animationProgress: _controller.value,
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Cupid',
            style: context.cupidType.display.copyWith(
              fontSize: 58,
              // `-.03em` at 58px.
              letterSpacing: -1.74,
              color: SplashPalette.foreground,
            ),
          ),
        ],
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

/// Bottom-anchored status line from the design source's
/// `bottom: calc(var(--safe-bot) + 26px)` block.
///
/// That block's tap-to-continue pill and its `goWelcome` handler are
/// deliberately not reproduced: ADR-6 removed the tap affordance, so rendering
/// a static "Chạm để tiếp tục" pill would advertise an interaction the screen
/// no longer offers.
class _StatusLine extends StatelessWidget {
  const _StatusLine();

  @override
  Widget build(BuildContext context) {
    return Text(
      context.viEn(
        'Đang mở khoá kỷ niệm của hai bạn…',
        'Unlocking your memories…',
      ),
      textAlign: TextAlign.center,
      style: context.cupidType.caption.copyWith(
        fontSize: 11.5,
        color: SplashPalette.caption,
      ),
    );
  }
}
