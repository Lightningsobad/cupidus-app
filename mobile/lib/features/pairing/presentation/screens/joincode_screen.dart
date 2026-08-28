import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/pairing_failure.dart';
import '../../data/pairing_repository.dart';
import '../camera_permission_gate.dart';
import '../joincode_cubit.dart';
import '../pairing_failure_text.dart';
import '../pairing_strings.dart';
import '../scan_code_route.dart';
import 'scan_code_screen.dart';

/// `content_paste` glyph the design source's paste pill uses
/// (`Cupid Screens.dc.html:1572`). `CupidIcons` does not expose it and
/// `design_system/` is outside this story's write scope, so it is declared
/// file-locally like `invite_screen.dart`'s own action glyphs; the codepoint
/// was read from the bundled `MaterialSymbolsRounded-Variable.ttf` cmap with
/// `fontTools`, not recalled from another icon font's PUA range.
const IconData _contentPasteIcon = IconData(
  0xe14f,
  fontFamily: CupidIcons.fontFamily,
);

/// `qr_code_scanner` glyph the design source's second action pill uses
/// (`Cupid Screens.dc.html:1632`), declared and verified the same way.
const IconData _qrCodeScannerIcon = IconData(
  0xf206,
  fontFamily: CupidIcons.fontFamily,
);

/// The shipped pairing-code contract: `InvitationsService.generateCode` emits
/// 6 hex characters and every mobile surface agrees. The design source's
/// "8 ký tự" copy is a content error in the mockup itself (it draws 5 boxes,
/// not 8) — REQ-002/STORY-047 triage item 3a closed it with no code change.
const int _codeLength = 6;

/// Design-source metrics for the `isJoinCode` slot row
/// (`Cupid Screens.dc.html:1564-1576`). The source sizes a slot `46x56` with a
/// `1.5px` border and no `box-sizing:border-box`, so its painted box is
/// `49x59`; Flutter insets borders, so the outer size carries the border here
/// (the same transcription `otp_screen.dart`'s `_CodeBox` already makes).
const double _slotWidth = 49;
const double _slotHeight = 59;
const double _slotGap = 9;
const double _slotBorderWidth = 1.5;
const double _slotFontSize = 21;

/// The action pills and the `invite` cross-link. `CupidSpacing`'s 8pt scale has
/// no 10/14/19/48 step, so these are transcribed verbatim from the source
/// rather than rounded to a nearby token (the `invite_screen.dart` precedent).
const double _pasteHeight = 48;
const double _pasteIconSize = 19;
const double _pasteLabelFontSize = 14;
const double _pillGap = 10;
const double _actionGap = 14;
const double _crossLinkFontSize = 13;

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
    this.initialCode = '',
    this.scanPermissionGate = const PermissionHandlerCameraGate(),
    this.scanPreviewBuilder,
    JoincodeCubit Function()? createJoincodeCubit,
  }) : _createJoincodeCubit = createJoincodeCubit;

  final void Function(BuildContext context)? onPaired;
  final OnboardingRouter? router;

  /// Handed straight to [ScanCodeRoute]. Injected so the widget tests and the
  /// preview entrypoint can drive every scan state on a machine with no camera.
  final CameraPermissionGate scanPermissionGate;
  final ScanPreviewBuilder? scanPreviewBuilder;

  /// Characters already entered when the screen opens, so the design source's
  /// partial and filled slot states are capturable from the preview
  /// entrypoint without driving the keyboard (the `OtpScreen.initialCode`
  /// precedent).
  final String initialCode;

  final JoincodeCubit Function()? _createJoincodeCubit;

  JoincodeCubit _defaultJoincodeCubit() => JoincodeCubit(
    acceptInvitation: getIt<PairingRepository>().acceptInvitation,
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JoincodeCubit>(
      create: (_) => (_createJoincodeCubit ?? _defaultJoincodeCubit)(),
      child: _JoincodeView(
        onPaired: onPaired,
        router: router,
        initialCode: initialCode,
        scanPermissionGate: scanPermissionGate,
        scanPreviewBuilder: scanPreviewBuilder,
      ),
    );
  }
}

class _JoincodeView extends StatefulWidget {
  const _JoincodeView({
    required this.onPaired,
    required this.router,
    required this.initialCode,
    required this.scanPermissionGate,
    required this.scanPreviewBuilder,
  });

  final void Function(BuildContext context)? onPaired;
  final OnboardingRouter? router;
  final String initialCode;
  final CameraPermissionGate scanPermissionGate;
  final ScanPreviewBuilder? scanPreviewBuilder;

  @override
  State<_JoincodeView> createState() => _JoincodeViewState();
}

class _JoincodeViewState extends State<_JoincodeView> {
  late final TextEditingController _codeController = TextEditingController(
    text: widget.initialCode,
  )..addListener(_onCodeChanged);
  final FocusNode _codeFocusNode = FocusNode();
  bool _pairedHandled = false;

  OnboardingRouter get _router => widget.router ?? getIt<OnboardingRouter>();

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  /// The slot row is painted from the controller's text, so every edit —
  /// typing, a multi-slot paste, or a backspace across slots — has to repaint
  /// it.
  void _onCodeChanged() => setState(() {});

  void _submit(BuildContext context) {
    final String code = _codeController.text.trim().toUpperCase();
    context.read<JoincodeCubit>().submit(code);
  }

  /// Fills the slot row from the clipboard (`Cupid Screens.dc.html:1572`).
  /// Trimmed, uppercased and truncated to the shipped [_codeLength] so a
  /// pasted invite link tail or a code with stray whitespace still lands.
  Future<void> _pasteCode() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String? text = data?.text;
    if (text == null || !mounted) return;
    final String code = text.trim().toUpperCase();
    final String truncated = code.length > _codeLength
        ? code.substring(0, _codeLength)
        : code;
    _codeController.value = TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: truncated.length),
    );
  }

  /// Opens the scan overlay on the screen's own [JoincodeCubit], so a scanned
  /// code and a typed one are the same pairing call.
  ///
  /// Nothing here reads or writes `_codeController` or its focus node: the UX
  /// `Fallback Guarantee` is that the screen comes back exactly as the user
  /// left it, and the only thing the exit reason changes is whether the caret
  /// returns to the code row.
  Future<void> _openScanner(BuildContext context) async {
    final ScanCodeExit? exit = await Navigator.of(context).push(
      ScanCodeRoute(
        joincodeCubit: context.read<JoincodeCubit>(),
        permissionGate: widget.scanPermissionGate,
        previewBuilder: widget.scanPreviewBuilder,
      ),
    );
    if (!mounted || exit != ScanCodeExit.manualEntry) return;
    _codeFocusNode.requestFocus();
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
                        _CodeSlotField(
                          controller: _codeController,
                          focusNode: _codeFocusNode,
                          enabled: !isBusy,
                          errorText: errorText,
                          colors: colors,
                          type: type,
                          platformTokens: platformTokens,
                        ),
                        SizedBox(height: CupidSpacing.lg),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _ActionPill(
                                icon: _contentPasteIcon,
                                label: context.viEn('Dán', 'Paste'),
                                onPressed: isBusy ? null : _pasteCode,
                                colors: colors,
                                type: type,
                                platformTokens: platformTokens,
                              ),
                            ),
                            const SizedBox(width: _pillGap),
                            Expanded(
                              child: _ActionPill(
                                icon: _qrCodeScannerIcon,
                                label: context.viEn('Quét QR', 'Scan QR'),
                                onPressed: isBusy
                                    ? null
                                    : () => _openScanner(context),
                                colors: colors,
                                type: type,
                                platformTokens: platformTokens,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: _actionGap),
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
                        if (state is JoincodeFailed &&
                            state.failure is AlreadyPairedFailure) ...<Widget>[
                          const SizedBox(height: _actionGap),
                          _AlreadyPairedProceedButton(
                            onPressed: () => _handlePairedOnce(context),
                          ),
                        ],
                        const SizedBox(height: _actionGap),
                        _InviteCrossLink(
                          onPressed: () =>
                              _router.push(context, OnboardingNode.invite),
                          colors: colors,
                          type: type,
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

/// The design source's six-slot code entry (`Cupid Screens.dc.html:1564-1569`).
///
/// The slots are the visual only. One accessible [TextField] stacked over them
/// carries the real text state (§9: a single accessible field backs the
/// 6-character entry, not six independently-focusable boxes), which is also
/// what keeps paste-fills-multiple-slots and backspace-across-slots working
/// for free. Its glyphs and cursor are transparent because the slots draw the
/// characters; it still owns the field's accessible name and the inline
/// rejection line, so the error stays tied to the control by description
/// rather than by colour alone.
class _CodeSlotField extends StatelessWidget {
  const _CodeSlotField({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.errorText,
    required this.colors,
    required this.type,
    required this.platformTokens,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final String? errorText;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;

  @override
  Widget build(BuildContext context) {
    final String code = controller.text.toUpperCase();
    final Color hidden = colors.colorText.withValues(alpha: 0);

    return Stack(
      children: <Widget>[
        // Sizing child. `isCollapsed` plus a forced strut pins its content box
        // to exactly one slot row, so the decorator's error line lands
        // directly below the slots instead of inside them.
        TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.characters,
          showCursor: false,
          enableInteractiveSelection: false,
          style: type.labelMono.copyWith(
            fontSize: _slotFontSize,
            color: hidden,
          ),
          strutStyle: const StrutStyle(
            fontSize: _slotHeight,
            height: 1,
            forceStrutHeight: true,
          ),
          inputFormatters: <TextInputFormatter>[
            LengthLimitingTextInputFormatter(_codeLength),
          ],
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            counterText: '',
            // Carries the field's accessible name — the design source's slot
            // row has no label chrome, and the heading above only names it
            // visually. Rendered transparent so the slots stay the visual.
            hintText: context.viEn('Mã ghép đôi', 'Pairing code'),
            hintStyle: type.labelMono.copyWith(
              fontSize: _slotFontSize,
              color: hidden,
            ),
            // Ties the inline rejection line to the field via an accessible
            // description, not colour alone (§9), rather than a separate
            // untethered error [Text].
            errorText: errorText,
            errorMaxLines: 3,
            errorStyle: type.caption.copyWith(
              height: 1.6,
              color: colors.colorRed,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: _slotHeight,
          child: ExcludeSemantics(
            child: IgnorePointer(
              child: Center(
                // 6 slots + 5 gaps need 339px, which overflows the narrowest
                // phones inside this screen's gutter. Scaling down keeps the
                // design frame exact where it fits and degrades instead of
                // painting an overflow stripe where it does not (the
                // `otp_screen.dart` precedent).
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (int i = 0; i < _codeLength; i++) ...<Widget>[
                        if (i > 0) const SizedBox(width: _slotGap),
                        _CodeSlot(
                          key: Key('joincode-slot-$i'),
                          character: i < code.length ? code[i] : null,
                          // The design source glows the slot the last
                          // character landed in and parks the caret in the
                          // next one (`CPD-8` + `|`).
                          active: i == code.length - 1,
                          caret: i == code.length,
                          hasError: errorText != null,
                          colors: colors,
                          type: type,
                          platformTokens: platformTokens,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One code slot: `background:var(--surf)`, `border:1.5px solid var(--line)`,
/// `border-radius:16px`, switching the border to `var(--pink)` plus
/// `box-shadow:var(--glow)` on the active slot and to `var(--red)` while the
/// entry is rejected.
class _CodeSlot extends StatelessWidget {
  const _CodeSlot({
    super.key,
    required this.character,
    required this.active,
    required this.caret,
    required this.hasError,
    required this.colors,
    required this.type,
    required this.platformTokens,
  });

  /// `null` for a slot with no character yet.
  final String? character;

  /// Whether this slot carries the design source's accent border and glow.
  final bool active;

  /// Whether this slot holds the design source's pink text-entry caret.
  final bool caret;

  final bool hasError;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;

  @override
  Widget build(BuildContext context) {
    final bool glow = active && !hasError;
    final Color border = hasError
        ? colors.colorRed
        : (active ? colors.colorAccentPink : colors.colorLine);

    return Container(
      width: _slotWidth,
      height: _slotHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
        border: Border.all(color: border, width: _slotBorderWidth),
        boxShadow: glow ? colors.glowShadow : null,
      ),
      child: character == null && !caret
          ? null
          : Text(
              character ?? '|',
              style: type.labelMono.copyWith(
                fontSize: _slotFontSize,
                fontWeight: FontWeight.w500,
                color: character != null
                    ? colors.colorText
                    : colors.colorAccentPink,
              ),
            ),
    );
  }
}

/// One of the two action pills the design source's row carries
/// (`Cupid Screens.dc.html:1630-1632`): `Dán` and `Quét QR`, each `flex:1`.
class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.colors,
    required this.type,
    required this.platformTokens,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(
      platformTokens.radiusButton,
    );

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Container(
          height: _pasteHeight,
          decoration: BoxDecoration(
            border: Border.all(color: colors.colorLine, width: _slotBorderWidth),
            borderRadius: radius,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CupidIcon(
                icon,
                size: _pasteIconSize,
                color: colors.colorTextMuted,
              ),
              SizedBox(width: CupidSpacing.sm),
              Text(
                label,
                style: type.body.copyWith(
                  fontSize: _pasteLabelFontSize,
                  fontWeight: FontWeight.w700,
                  color: colors.colorText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shortcut to `invite` for a user who is actually the code creator and landed
/// on this branch by mistake (`Cupid Screens.dc.html:1576`). Not a duplicate of
/// the in-body back control: `pairingChoice` has no `OnboardingChain`
/// successor, so back from here lands on `pairingChoice`, never on `invite`.
class _InviteCrossLink extends StatelessWidget {
  const _InviteCrossLink({
    required this.onPressed,
    required this.colors,
    required this.type,
  });

  final VoidCallback onPressed;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: CupidSpacing.sm),
          child: Text(
            context.viEn(
              'Tôi mới là người tạo mã →',
              'I am the one with the code →',
            ),
            textAlign: TextAlign.center,
            style: type.body.copyWith(
              fontSize: _crossLinkFontSize,
              fontWeight: FontWeight.w700,
              color: colors.colorAccentPink,
            ),
          ),
        ),
      ),
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

class _AlreadyPairedProceedButton extends StatelessWidget {
  const _AlreadyPairedProceedButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
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
          key: const Key('joincode_already_paired_cta'),
          onTap: onPressed,
          borderRadius: radius,
          child: SizedBox(
            height: 48,
            child: Center(
              child: Text(
                context.viEn('Vào ứng dụng →', 'Go to app →'),
                style: type.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.colorText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

