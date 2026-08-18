import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/pairing_repository.dart';
import '../joincode_cubit.dart';
import '../pairing_failure_text.dart';
import '../pairing_strings.dart';

/// `joincode` screen (`ux/uiux-spec.md` §4, §5, §9) — invitee's manual
/// code-entry path. In-chain, so `NO_CHROME` applies (AC4/ADR-7): no header,
/// no tab bar. The §1 back edge to `invite` survives as an in-body control.
///
/// The invitee lands on `paired` immediately once `accept` succeeds, with no
/// intermediate `waiting` step (AC2/ADR-4): `acceptInvitation(code)` confirms
/// synchronously, which the inviter's path has no equivalent of. [onPaired]
/// overrides that default edge for tests.
class JoincodeScreen extends StatelessWidget {
  const JoincodeScreen({
    super.key,
    this.onPaired,
    this.router,
    JoincodeCubit Function()? createJoincodeCubit,
  }) : _createJoincodeCubit = createJoincodeCubit;

  final void Function(BuildContext context)? onPaired;
  final OnboardingRouter? router;
  final JoincodeCubit Function()? _createJoincodeCubit;

  JoincodeCubit _defaultJoincodeCubit() => JoincodeCubit(
    acceptInvitation: getIt<PairingRepository>().acceptInvitation,
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JoincodeCubit>(
      create: (_) => (_createJoincodeCubit ?? _defaultJoincodeCubit)(),
      child: _JoincodeView(onPaired: onPaired, router: router),
    );
  }
}

class _JoincodeView extends StatefulWidget {
  const _JoincodeView({required this.onPaired, required this.router});

  final void Function(BuildContext context)? onPaired;
  final OnboardingRouter? router;

  @override
  State<_JoincodeView> createState() => _JoincodeViewState();
}

class _JoincodeViewState extends State<_JoincodeView> {
  final TextEditingController _codeController = TextEditingController();
  bool _pairedHandled = false;

  OnboardingRouter get _router => widget.router ?? getIt<OnboardingRouter>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final String code = _codeController.text.trim().toUpperCase();
    context.read<JoincodeCubit>().submit(code);
  }

  void _handlePairedOnce(BuildContext context) {
    if (_pairedHandled) return;
    _pairedHandled = true;
    final void Function(BuildContext context)? override = widget.onPaired;
    if (override != null) {
      override(context);
      return;
    }
    // `resetTo` rather than a push: the pairing stack must not be reachable by
    // back navigation once the couple is linked.
    _router.resetTo(context, OnboardingNode.paired);
  }

  /// Design source `Cupid Screens.dc.html` §isJoinCode renders the six-slot
  /// entry as boxes with `background:var(--surf)`, `border:1.5px solid
  /// var(--line)`, `border-radius:16px`, switching the border to
  /// `var(--pink)` plus `box-shadow:var(--glow)` on the active slot. The
  /// single accessible field below carries that same box treatment, so the
  /// border side is built once per state here.
  OutlineInputBorder _codeFieldBorder(
    CupidPlatformTokens platformTokens,
    Color color,
  ) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return BlocConsumer<JoincodeCubit, JoincodeState>(
      listener: (context, state) {
        if (state is! JoincodeSuccess) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) _handlePairedOnce(context);
        });
      },
      builder: (context, state) {
        final bool isBusy = state is JoincodeInProgress;
        final String? errorText = state is JoincodeFailed
            ? pairingFailureMessage(context, state.failure)
            : null;

        return Scaffold(
          // backgroundColor override intentionally removed (REQ-002
          // STORY-032 AC1): the shared CupidAppBackground app-shell layer now
          // paints the sky-gradient wash behind every screen; a
          // Scaffold-level solid fill here would occlude it.
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _InChainBackButton(
                  tooltip: context.viEn('Quay lại', 'Back'),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  // The design source's column flows from the top
                  // (`flex-direction:column` with no `justify-content:center`),
                  // so this must not be wrapped in a [Center].
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      CupidSpacing.lg,
                      CupidSpacing.lg,
                      CupidSpacing.lg,
                      CupidSpacing.xl,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              // `rgba(183,140,245,.2)` in the design source is
                              // `--purple` at 20% alpha, so it is derived from the
                              // token rather than transcribed as a literal.
                              color: colors.colorAccentPurple.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(
                                platformTokens.radiusSheet,
                              ),
                            ),
                            child: Center(
                              child: CupidIcon(
                                CupidIcons.link,
                                size: 38,
                                color: colors.colorAccentPurple,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: CupidSpacing.lg),
                        Text(
                          context.viEn(
                            'Nhập mã của người ấy',
                            'Enter their code',
                          ),
                          textAlign: TextAlign.center,
                          style: type.display.copyWith(
                            fontSize: 25,
                            height: 1.25,
                            color: colors.colorText,
                          ),
                        ),
                        SizedBox(height: CupidSpacing.sm),
                        Center(
                          // `max-width:280px` on the design source's sub-copy.
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 280),
                            child: Text(
                              context.viEn(
                                'Bảo Bae đọc mã 6 ký tự trên máy họ cho bạn.',
                                'Ask Bae to read you the 6-character code on '
                                    'their phone.',
                              ),
                              textAlign: TextAlign.center,
                              style: type.caption.copyWith(
                                height: 1.6,
                                color: colors.colorTextMuted,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: CupidSpacing.lg),
                        // A single accessible field backs the 6-character entry
                        // (§9): not six independently-focusable visual boxes.
                        TextField(
                          controller: _codeController,
                          enabled: !isBusy,
                          textAlign: TextAlign.center,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 6,
                          style: type.labelMono.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 21,
                            letterSpacing: 8,
                            color: colors.colorText,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: colors.colorSurface,
                            // Carries the field's accessible name now that the
                            // design source's box row has no label chrome; the
                            // heading above names it visually.
                            hintText: context.viEn(
                              'Mã ghép đôi',
                              'Pairing code',
                            ),
                            hintStyle: type.labelMono.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 21,
                              color: colors.colorTextMuted,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: CupidSpacing.md,
                              vertical: CupidSpacing.md,
                            ),
                            enabledBorder: _codeFieldBorder(
                              platformTokens,
                              colors.colorLine,
                            ),
                            disabledBorder: _codeFieldBorder(
                              platformTokens,
                              colors.colorLine,
                            ),
                            focusedBorder: _codeFieldBorder(
                              platformTokens,
                              colors.colorAccentPink,
                            ),
                            errorBorder: _codeFieldBorder(
                              platformTokens,
                              colors.colorRed,
                            ),
                            focusedErrorBorder: _codeFieldBorder(
                              platformTokens,
                              colors.colorRed,
                            ),
                            // Ties the inline rejection line to the field via an
                            // accessible description, not color alone (§9),
                            // rather than a separate untethered error [Text].
                            errorText: errorText,
                            errorMaxLines: 3,
                            errorStyle: type.caption.copyWith(
                              height: 1.6,
                              color: colors.colorRed,
                            ),
                          ),
                        ),
                        SizedBox(height: CupidSpacing.lg),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CupidPrimaryButton(
                              label: isBusy
                                  ? ''
                                  : context.viEn('Ghép đôi', 'Pair up'),
                              onPressed: isBusy ? null : () => _submit(context),
                            ),
                            if (isBusy)
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.colorText,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// In-body back affordance for an in-chain screen. `NO_CHROME` (AC4/ADR-7)
/// removes the header, not the §1 back edge to `invite`, so the header's arrow
/// treatment, tap target, and `maybePop` behaviour move into the body.
class _InChainBackButton extends StatelessWidget {
  const _InChainBackButton({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: platformTokens.tapTarget,
          minHeight: platformTokens.tapTarget,
        ),
        child: IconButton(
          icon: const Icon(CupidIcons.arrowBack, size: 26),
          color: colors.colorAccentPink,
          tooltip: tooltip,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
