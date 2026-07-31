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
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    return BlocListener<SessionGateCubit, SessionGateState>(
      listener: (context, state) => _tryNavigate(state),
      child: Scaffold(
        body: GestureDetector(
          onTap: _minDwellElapsed ? _onTapToContinue : null,
          child: DecoratedBox(
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
                    if (_minDwellElapsed) ...[
                      SizedBox(height: CupidSpacing.xxl),
                      Text(
                        context.viEn('Chạm để tiếp tục', 'Tap to continue'),
                        style: context.cupidType.caption.copyWith(
                          color: colors.colorTextMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Splash loading affordance: three dots bobbing in a staggered vertical
/// offset, no color/theme fork — style comes entirely from
/// [CupidColorTokens.colorText].
class _BobbingDots extends StatefulWidget {
  const _BobbingDots();

  @override
  State<_BobbingDots> createState() => _BobbingDotsState();
}

class _BobbingDotsState extends State<_BobbingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(3, (index) {
            final double t = (_controller.value + index * 0.2) % 1.0;
            final double dy = -6 * (1 - (2 * t - 1).abs());
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: CupidSpacing.xs),
              child: Transform.translate(
                offset: Offset(0, dy),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.colorText,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(width: 8, height: 8),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
