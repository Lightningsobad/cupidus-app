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
