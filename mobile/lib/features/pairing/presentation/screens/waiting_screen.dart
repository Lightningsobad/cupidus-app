import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/pairing_repository.dart';
import '../../data/partner_link.dart';
import '../waiting_cubit.dart';

/// `waiting` screen (`ux/uiux-spec.md` §2/§7/§9) — inviter-only hold state
/// after `invite` generates a code. `NO_CHROME`: no header, no tab bar.
///
/// [onPaired] fires once the poll (`WaitingCubit`/`PartnerLinkPoller`, plan
/// §1 D1) detects `partnerId != null`. It has no default navigation target:
/// `paired_screen.dart` is a later phase (plan §3 P4) not yet built, so this
/// stays a caller-supplied seam instead of importing a screen that doesn't
/// exist yet.
class WaitingScreen extends StatelessWidget {
  const WaitingScreen({
    super.key,
    required this.expiresAt,
    this.onPaired,
    WaitingCubit Function()? createWaitingCubit,
  }) : _createWaitingCubit = createWaitingCubit;

  final DateTime expiresAt;
  final void Function(BuildContext context, PartnerLink link)? onPaired;
  final WaitingCubit Function()? _createWaitingCubit;

  WaitingCubit _defaultWaitingCubit() {
    final PairingRepository repository = getIt<PairingRepository>();
    return WaitingCubit(
      getPartnerLink: repository.getPartnerLink,
      expiresAt: expiresAt,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WaitingCubit>(
      create: (_) => (_createWaitingCubit ?? _defaultWaitingCubit)(),
      child: _WaitingView(onPaired: onPaired),
    );
  }
}

class _WaitingView extends StatefulWidget {
  const _WaitingView({required this.onPaired});

  final void Function(BuildContext context, PartnerLink link)? onPaired;

  @override
  State<_WaitingView> createState() => _WaitingViewState();
}

class _WaitingViewState extends State<_WaitingView> {
  bool _pairedAnnounced = false;
  bool _pairedHandled = false;

  void _handlePairedOnce(BuildContext context, PartnerLink link) {
    if (_pairedHandled) return;
    _pairedHandled = true;
    widget.onPaired?.call(context, link);
  }

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;

    return BlocConsumer<WaitingCubit, WaitingState>(
      listener: (context, state) {
        if (state is! WaitingPaired) return;
        if (!_pairedAnnounced) {
          _pairedAnnounced = true;
          SemanticsService.sendAnnouncement(
            View.of(context),
            context.viEn('Đã ghép đôi thành công', 'You are paired'),
            TextDirection.ltr,
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _handlePairedOnce(context, state.link);
        });
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: colors.colorBackground,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(CupidSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ExcludeSemantics(child: _PulsingHold()),
                    SizedBox(height: CupidSpacing.lg),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _statusText(context, state),
                        textAlign: TextAlign.center,
                        style: context.cupidType.body.copyWith(
                          color: colors.colorText,
                        ),
                      ),
                    ),
                    SizedBox(height: CupidSpacing.xl),
                    OutlinedButton(
                      onPressed: () =>
                          context.read<WaitingCubit>().refreshNow(),
                      child: Text(context.viEn('Làm mới', 'Refresh')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _statusText(BuildContext context, WaitingState state) {
    return switch (state) {
      WaitingInProgress() => context.viEn(
        'Đang chờ người ấy…',
        'Waiting for your partner…',
      ),
      WaitingPaired() => context.viEn('Đã ghép đôi! 🎉', "You're paired! 🎉"),
      WaitingTimedOut() => context.viEn(
        'Hơi lâu đó — thử làm mới nhé',
        'This is taking a while — try refreshing',
      ),
    };
  }
}

/// Decorative pulse (§8/§9: reuses the `pulseRing`/`bob` keyframe vocabulary,
/// no new animation primitive) — hidden from assistive tech by the caller's
/// [ExcludeSemantics]; the status text above is the real accessible signal.
class _PulsingHold extends StatefulWidget {
  const _PulsingHold();

  @override
  State<_PulsingHold> createState() => _PulsingHoldState();
}

class _PulsingHoldState extends State<_PulsingHold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

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
        final double scale = 0.85 + 0.15 * _controller.value;
        return Opacity(
          opacity: 0.5 + 0.5 * _controller.value,
          child: Transform.scale(
            scale: scale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.colorAccentPink,
                shape: BoxShape.circle,
              ),
              child: const SizedBox(width: 64, height: 64),
            ),
          ),
        );
      },
    );
  }
}

/// vi/en copy transcribed from `ux/uiux-spec.md`, resolved from the ambient
/// [Locale] (mirrors `features/auth/presentation/auth_strings.dart`'s
/// `AuthLocaleText` — duplicated locally rather than imported cross-feature
/// or added to `pairing_strings.dart`, which is plan §3 P3's file, outside
/// this phase's write scope).
extension _WaitingLocaleText on BuildContext {
  bool get _isVi => Localizations.localeOf(this).languageCode == 'vi';

  String viEn(String vi, String en) => _isVi ? vi : en;
}
