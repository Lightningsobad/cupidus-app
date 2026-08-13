import 'dart:async';

import 'package:cupid_mobile/core/auth/cupid_auth.dart';
import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';
import '../auth_strings.dart';
import '../session_gate_cubit.dart';
import 'login_screen.dart';
import 'welcome_screen.dart';

/// `splash` screen — `ux/uiux-spec.md` section 3 auth-check gate.
///
/// [createSessionGateCubit] defaults to wiring a real [CupidSession] from
/// `getIt` (registered by STORY-003 P2's `setupServiceLocator`, read-only
/// here). Tests supply a fake instead so the gate can be driven without a
/// live/mocked Firebase Auth.
///
/// [resolvePairingStatus] is forwarded to every [HomeScreen] this screen
/// navigates to (STORY-012's `getIt<CouplePairingStore>()`-backed default,
/// matching `HomeScreen`'s own doc comment), so tests that never register a
/// `CouplePairingStore` can still drive splash routing with a fake.
class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
    required this.authRepository,
    SessionGateCubit Function()? createSessionGateCubit,
    Future<PairingStatus> Function()? resolvePairingStatus,
  }) : _createSessionGateCubit = createSessionGateCubit,
       _resolvePairingStatus = resolvePairingStatus;

  final AuthRepository authRepository;
  final SessionGateCubit Function()? _createSessionGateCubit;
  final Future<PairingStatus> Function()? _resolvePairingStatus;

  SessionGateCubit _defaultSessionGateCubit() {
    final CupidSession session = getIt<CupidSession>();
    return SessionGateCubit(
      sessionState: session.state,
      idToken: session.idToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SessionGateCubit>(
      create: (_) => (_createSessionGateCubit ?? _defaultSessionGateCubit)(),
      child: _SplashView(
        authRepository: authRepository,
        resolvePairingStatus: _resolvePairingStatus,
      ),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView({required this.authRepository, this.resolvePairingStatus});

  final AuthRepository authRepository;
  final Future<PairingStatus> Function()? resolvePairingStatus;

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView> {
  static const Duration _minDwell = Duration(seconds: 2);

  bool _minDwellElapsed = false;
  bool _navigated = false;
  Timer? _dwellTimer;
  SessionGateState? _pendingState;

  @override
  void initState() {
    super.initState();
    _dwellTimer = Timer(_minDwell, () {
      if (!mounted) return;
      setState(() => _minDwellElapsed = true);
      _tryNavigate(context.read<SessionGateCubit>().state);
    });
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    super.dispose();
  }

  void _tryNavigate(SessionGateState state) {
    _pendingState = state;
    if (_navigated || !_minDwellElapsed || state is SessionGateChecking) {
      return;
    }
    _navigated = true;
    final Widget destination = switch (state) {
      SessionGateChecking() => const SizedBox.shrink(),
      SessionGateUnauthenticated() => WelcomeScreen(
        authRepository: widget.authRepository,
      ),
      SessionGateAuthenticated() => HomeScreen(
        resolvePairingStatus: widget.resolvePairingStatus,
      ),
      SessionGateSessionExpired(:final prefillEmail) => LoginScreen(
        authRepository: widget.authRepository,
        sessionExpired: true,
        prefillEmail: prefillEmail,
      ),
    };
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => destination));
  }

  /// Tap-to-continue affordance (section 3): treated the same as a
  /// non-forced token read timing out (ADR-011h optimistic success) so an
  /// impatient tap never blocks on the network.
  void _onTapToContinue() {
    if (_pendingState is SessionGateChecking || _pendingState == null) {
      _navigated = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) =>
              HomeScreen(resolvePairingStatus: widget.resolvePairingStatus),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read above the `Scaffold` so this is the raw window inset, matching the
    // design source's `--safe-bot` rather than a `Scaffold`-adjusted value.
    final double safeBottom = MediaQuery.paddingOf(context).bottom;
    return BlocListener<SessionGateCubit, SessionGateState>(
      listener: (context, state) => _tryNavigate(state),
      child: Scaffold(
        body: GestureDetector(
          onTap: _minDwellElapsed ? _onTapToContinue : null,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: SplashPalette.background,
            ),
            child: SizedBox.expand(
              child: ClipRect(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Stack(
                      children: <Widget>[
                        Positioned(
                          top: constraints.maxHeight * 0.22,
                          left: constraints.maxWidth * 0.14,
                          child: const _BreathingGlow(),
                        ),
                        const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              _Wordmark(),
                              SizedBox(height: 26),
                              _BobbingDots(),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: safeBottom + 26,
                          child: const _TapToContinue(),
                        ),
                      ],
                    );
                  },
                ),
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
