import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/pairing_repository.dart';
import '../../data/partner_link.dart';
import '../waiting_cubit.dart';

/// `waiting` screen (`ux/uiux-spec.md` §2/§7/§9) — inviter-only hold state
/// after `invite` generates a code. `NO_CHROME`: no header, no tab bar.
///
/// The poll (`WaitingCubit`/`PartnerLinkPoller`, plan §1 D1) detecting
/// `partnerId != null` is the only trigger for the `waiting` -> `paired` edge;
/// [onPaired] overrides that default edge for tests.
class WaitingScreen extends StatelessWidget {
  const WaitingScreen({
    super.key,
    required this.expiresAt,
    this.code,
    this.onPaired,
    this.router,
    WaitingCubit Function()? createWaitingCubit,
  }) : _createWaitingCubit = createWaitingCubit;

  final DateTime expiresAt;

  /// Invite code shown in the design source's "Mã của bạn" card and re-shared
  /// by its "Gửi lại" CTA. Nullable only because `main_preview.dart`'s
  /// standalone `waiting` capture entry has no invitation to draw one from;
  /// the real navigation path (`invite_screen.dart`) always supplies it.
  final String? code;
  final void Function(BuildContext context, PartnerLink link)? onPaired;
  final OnboardingRouter? router;
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
      child: _WaitingView(code: code, onPaired: onPaired, router: router),
    );
  }
}

class _WaitingView extends StatefulWidget {
  const _WaitingView({
    required this.code,
    required this.onPaired,
    required this.router,
  });

  final String? code;
  final void Function(BuildContext context, PartnerLink link)? onPaired;
  final OnboardingRouter? router;

  @override
  State<_WaitingView> createState() => _WaitingViewState();
}

class _WaitingViewState extends State<_WaitingView> {
  bool _pairedAnnounced = false;
  bool _pairedHandled = false;

  OnboardingRouter get _router => widget.router ?? getIt<OnboardingRouter>();

  void _handlePairedOnce(BuildContext context, PartnerLink link) {
    if (_pairedHandled) return;
    _pairedHandled = true;
    final void Function(BuildContext context, PartnerLink link)? override =
        widget.onPaired;
    if (override != null) {
      override(context, link);
      return;
    }
    // `resetTo` rather than a push: the pairing stack must not be reachable by
    // back navigation once the couple is linked.
    _router.resetTo(context, OnboardingNode.paired);
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
        final String? subtitle = _subtitleText(context, state);
        final String? code = widget.code;

        return Scaffold(
          body: Stack(
            children: <Widget>[
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 40,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const ExcludeSemantics(child: _PulsingHold()),
                        SizedBox(height: CupidSpacing.xl),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _statusText(context, state),
                            textAlign: TextAlign.center,
                            style: context.cupidType.display.copyWith(
                              fontSize: 24,
                              height: 1.25,
                              color: colors.colorText,
                            ),
                          ),
                        ),
                        if (subtitle != null) ...<Widget>[
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 270),
                            child: Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: context.cupidType.caption.copyWith(
                                height: 1.6,
                                color: colors.colorTextMuted,
                              ),
                            ),
                          ),
                        ],
                        if (code != null) ...<Widget>[
                          const SizedBox(height: 24),
                          _CodeCard(code: code),
                        ],
                        const SizedBox(height: 22),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              children: <Widget>[
                                if (code != null) ...<Widget>[
                                  Expanded(child: _ResendButton(code: code)),
                                  const SizedBox(width: 10),
                                ],
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => context
                                        .read<WaitingCubit>()
                                        .refreshNow(),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: colors.colorText,
                                      side: BorderSide(
                                        color: colors.colorLine,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          context.cupidPlatform.radiusButton,
                                        ),
                                      ),
                                      textStyle: context.cupidType.body
                                          .copyWith(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    child: Text(
                                      context.viEn('Làm mới', 'Refresh'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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

  /// Design source's supporting line under the waiting title. Suppressed once
  /// paired: the copy asserts nobody has joined yet, which is false in that
  /// state, and the screen is already navigating away.
  String? _subtitleText(BuildContext context, WaitingState state) {
    if (state is WaitingPaired) return null;
    return context.viEn(
      'Gửi mã rồi mà chưa thấy ai vào. Chọc Bae một cái đi.',
      'Code sent, nobody has joined yet. Go nudge Bae.',
    );
  }
}

/// Design source's "Mã của bạn" card: `--surf` fill, `--shadow` elevation, a
/// muted 11px label above the invite code drawn in `--grad-hot`.
class _CodeCard extends StatelessWidget {
  const _CodeCard({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        // Transcribed from the design source: no shape token covers a 20px
        // card corner (`radiusSmall` = 16, `radiusCard` = 24/26).
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.cupidPlatform.elevationShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            context.viEn('Mã của bạn', 'Your code'),
            style: context.cupidType.caption.copyWith(
              fontSize: 11,
              color: colors.colorTextMuted,
            ),
          ),
          const SizedBox(height: 6),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (Rect bounds) =>
                colors.gradientHot.createShader(bounds),
            child: Text(
              code,
              style: context.cupidType.labelMono.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                // The design source's `letter-spacing:.14em` at 26px.
                letterSpacing: 26 * 0.14,
                color: colors.colorText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Design source's gradient primary CTA ("Gửi lại"): `--grad-hot` fill,
/// `--glow` shadow, pill radius.
///
/// No native-share dependency exists in this app, so — exactly as
/// `invite_screen.dart`'s own share action does — it re-copies the invite
/// payload to the clipboard and announces it instead of opening a share sheet.
class _ResendButton extends StatelessWidget {
  const _ResendButton({required this.code});

  final String code;

  Future<void> _resend(BuildContext context) async {
    final String announcement = context.viEn(
      'Đã sao chép để chia sẻ',
      'Copied to share',
    );
    await Clipboard.setData(
      ClipboardData(text: 'Cupid: $code\nhttps://cupid.app/pair?code=$code'),
    );
    if (!context.mounted) return;
    SemanticsService.sendAnnouncement(
      View.of(context),
      announcement,
      TextDirection.ltr,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(announcement)));
  }

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    final BorderRadius radius = BorderRadius.circular(
      context.cupidPlatform.radiusButton,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: colors.gradientHot,
        borderRadius: radius,
        boxShadow: colors.glowShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => _resend(context),
          borderRadius: radius,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CupidIcon(
                  CupidIcons.iosShare,
                  size: 19,
                  color: colors.colorText,
                ),
                const SizedBox(width: 8),
                // Flexible, not a bare Text: the glyph makes the row's
                // intrinsic width exceed the half-row the design source gives
                // it once the label is long or the text scale is raised.
                Flexible(
                  child: Text(
                    context.viEn('Gửi lại', 'Share again'),
                    textAlign: TextAlign.center,
                    style: context.cupidType.body.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: colors.colorText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Decorative waiting field (§8/§9: reuses the `pulseRing`/`bob` keyframe
/// vocabulary, no new animation primitive) — hidden from assistive tech by the
/// caller's [ExcludeSemantics]; the status text below is the real accessible
/// signal.
class _PulsingHold extends StatefulWidget {
  const _PulsingHold();

  @override
  State<_PulsingHold> createState() => _PulsingHoldState();
}

class _PulsingHoldState extends State<_PulsingHold>
    with TickerProviderStateMixin {
  /// One 2.4s cycle drives both rings; the second ring reads the same clock
  /// half a cycle out of phase, matching the design source's `1.2s` delay.
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  /// `bob` is a 3s round trip, so the reversing controller runs half of it.
  late final AnimationController _bobController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulseController.dispose();
    _bobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        children: <Widget>[
          _PulseRing(progress: _pulseController, color: colors.colorAccentPink),
          _PulseRing(
            progress: _pulseController,
            color: colors.colorAccentPurple,
            phaseOffset: 0.5,
            opacity: 0.35,
          ),
          Positioned.fill(
            left: 24,
            top: 24,
            right: 24,
            bottom: 24,
            child: AnimatedBuilder(
              animation: _bobController,
              builder: (context, child) => Transform.translate(
                offset: Offset(
                  0,
                  -7 * Curves.easeInOut.transform(_bobController.value),
                ),
                child: child,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      colors.colorAccentPink.withValues(alpha: 0.24),
                      colors.colorAccentPurple.withValues(alpha: 0.24),
                    ],
                  ),
                ),
                child: Center(
                  child: CupidIcon(
                    CupidIcons.hourglass,
                    size: 46,
                    color: colors.colorAccentPink,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One `pulseRing` keyframe run: `scale(.9)/opacity .7` expanding to
/// `scale(1.5)/opacity 0` over the first 70% of the cycle, then held invisible
/// for the remainder.
class _PulseRing extends StatelessWidget {
  const _PulseRing({
    required this.progress,
    required this.color,
    this.phaseOffset = 0,
    this.opacity = 0.4,
  });

  final Animation<double> progress;
  final Color color;
  final double phaseOffset;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, child) {
          final double t = (progress.value + phaseOffset) % 1.0;
          if (t >= 0.7) return const SizedBox.shrink();
          final double eased = Curves.easeOut.transform(t / 0.7);
          return Opacity(
            opacity: 0.7 * (1 - eased),
            child: Transform.scale(scale: 0.9 + 0.6 * eased, child: child),
          );
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: opacity),
              width: 1.5,
            ),
          ),
        ),
      ),
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
