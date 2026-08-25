import 'dart:async';

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../camera_permission_gate.dart';
import '../joincode_cubit.dart';
import '../pairing_strings.dart';
import '../scan_code_cubit.dart';
import '../scan_code_route.dart';

/// Builds the camera surface and reports each decoded payload.
///
/// This seam exists so widget tests and `main_preview.dart` can render every
/// state with a placeholder: a build machine has no camera, which would
/// otherwise leave AC5 unverifiable.
typedef ScanPreviewBuilder =
    Widget Function(BuildContext context, ValueChanged<String> onDetected);

/// `CupidIcons` carries none of these glyphs and `design_system/` is outside
/// this story's write scope, so they are declared file-locally like
/// `joincode_screen.dart`'s `_contentPasteIcon`. Every codepoint was read from
/// the bundled `MaterialSymbolsRounded-Variable.ttf` cmap with `fontTools`,
/// not recalled from another icon font's PUA range.
const IconData _closeIcon = IconData(0xe14c, fontFamily: CupidIcons.fontFamily);
const IconData _photoCameraIcon = IconData(
  0xe3b0,
  fontFamily: CupidIcons.fontFamily,
);
const IconData _errorIcon = IconData(0xf8b6, fontFamily: CupidIcons.fontFamily);
const IconData _noPhotographyIcon = IconData(
  0xf1a8,
  fontFamily: CupidIcons.fontFamily,
);

/// `ux/ux-spec.md`: viewfinder at "roughly 70% of the shorter screen
/// dimension".
const double _viewfinderFraction = 0.7;
const double _viewfinderBorderWidth = 3;
const double _openingIconSize = 40;
const double _stateIconSize = 40;
const double _errorCardIconSize = 28;
const double _closeIconSize = 26;

/// The link treatment shared with `joincode_screen.dart`'s switch link: pink,
/// weight 700, 13px.
const double _linkFontSize = 13;

/// State 3's mint flash, State 4's card timeout — both from `ux/ux-spec.md`.
const Duration _recognizedFlashDuration = Duration(milliseconds: 400);
const Duration _invalidAutoDismiss = Duration(seconds: 3);

/// `ux/ux-spec.md` Responsive Behavior: message cards cap their width rather
/// than stretching edge to edge. 280 is the cap the join-code screen's own
/// sub-copy already uses.
const double _cardMaxWidth = 280;

/// Full-screen scan overlay (`ux/ux-spec.md` States 1-7).
///
/// Expects a [JoincodeCubit] above it — [ScanCodeRoute] provides the join-code
/// screen's own instance, which is what makes a scanned code and a typed one
/// resolve identically.
class ScanCodeScreen extends StatelessWidget {
  const ScanCodeScreen({
    super.key,
    this.permissionGate = const PermissionHandlerCameraGate(),
    ScanPreviewBuilder? previewBuilder,
  }) : previewBuilder = previewBuilder ?? _mobileScannerPreview;

  final CameraPermissionGate permissionGate;
  final ScanPreviewBuilder previewBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ScanCodeCubit>(
      create: (BuildContext _) => ScanCodeCubit(
        permissionGate: permissionGate,
        joincodeCubit: context.read<JoincodeCubit>(),
      )..start(),
      child: _ScanCodeView(previewBuilder: previewBuilder),
    );
  }
}

class _ScanCodeView extends StatefulWidget {
  const _ScanCodeView({required this.previewBuilder});

  final ScanPreviewBuilder previewBuilder;

  @override
  State<_ScanCodeView> createState() => _ScanCodeViewState();
}

class _ScanCodeViewState extends State<_ScanCodeView> {
  StreamSubscription<void>? _closeSubscription;
  Timer? _invalidTimer;

  @override
  void initState() {
    super.initState();
    _closeSubscription = context.read<ScanCodeCubit>().closeRequests.listen(
      (_) => _exit(ScanCodeExit.dismissed),
    );
  }

  @override
  void dispose() {
    _invalidTimer?.cancel();
    unawaited(_closeSubscription?.cancel());
    super.dispose();
  }

  void _exit(ScanCodeExit reason) {
    if (!mounted) return;
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop(reason);
  }

  void _onStateChanged(BuildContext context, ScanCodeState state) {
    _invalidTimer?.cancel();
    if (state is! ScanCodeInvalid) return;

    // A misread or a half-framed code must not permanently block re-scanning,
    // so the card steps aside on its own; `Thử lại` is the impatient path to
    // the same place.
    _invalidTimer = Timer(_invalidAutoDismiss, () {
      if (mounted) context.read<ScanCodeCubit>().retry();
    });
  }

  @override
  Widget build(BuildContext context) {
    // No `backgroundColor`: like every other screen, this one stays
    // transparent so the shared `--sky` wash mounted once in `cupid_app.dart`
    // shows through. The camera surface covers it on the states that have one.
    return Scaffold(
      body: BlocConsumer<ScanCodeCubit, ScanCodeState>(
        listener: _onStateChanged,
        builder: (BuildContext context, ScanCodeState state) {
          return Stack(
            children: <Widget>[
              Positioned.fill(child: _body(context, state)),
              Positioned(
                top: 0,
                left: 0,
                child: SafeArea(
                  child: _CloseControl(
                    onPressed: () => _exit(ScanCodeExit.dismissed),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, ScanCodeState state) {
    return switch (state) {
      ScanCodeOpening() => const _OpeningState(),
      ScanCodeScanning() || ScanCodeRecognized() || ScanCodeInvalid() =>
        _CameraStates(
          state: state,
          previewBuilder: widget.previewBuilder,
          onDetected: context.read<ScanCodeCubit>().onDetected,
          onRetry: context.read<ScanCodeCubit>().retry,
          onManualEntry: () => _exit(ScanCodeExit.manualEntry),
        ),
      ScanCodePermissionDenied() => _MessageState(
        icon: _noPhotographyIcon,
        message: context.viEn(
          'Cupid cần quyền camera để quét mã QR',
          'Cupid needs camera access to scan QR codes',
        ),
        // Not a re-prompt: once the OS prompt has been answered, asking again
        // from inside the app is not ours to do on most platforms.
        primaryLabel: context.viEn('Nhập mã thủ công', 'Enter code manually'),
        onPrimary: () => _exit(ScanCodeExit.manualEntry),
      ),
      ScanCodePermissionPermanentlyDenied() => _MessageState(
        icon: _noPhotographyIcon,
        message: context.viEn(
          'Cupid cần quyền camera trong Cài đặt để quét mã QR',
          'Camera access is off in Settings — turn it on to scan QR codes',
        ),
        primaryLabel: context.viEn('Mở Cài đặt', 'Open Settings'),
        onPrimary: context.read<ScanCodeCubit>().openSettings,
        onManualEntry: () => _exit(ScanCodeExit.manualEntry),
      ),
      ScanCodeUnavailable() => _MessageState(
        icon: _noPhotographyIcon,
        message: context.viEn(
          'Không thể mở camera trên thiết bị này',
          "Camera isn't available on this device",
        ),
        primaryLabel: context.viEn('Nhập mã thủ công', 'Enter code manually'),
        onPrimary: () => _exit(ScanCodeExit.manualEntry),
      ),
    };
  }
}

/// State 1 — permission is being resolved, no camera yet.
class _OpeningState extends StatelessWidget {
  const _OpeningState();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CupidIcon(
            _photoCameraIcon,
            size: _openingIconSize,
            color: colors.colorTextMuted,
          ),
          SizedBox(height: CupidSpacing.md),
          SizedBox(
            width: CupidSpacing.lg,
            height: CupidSpacing.lg,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.colorTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// States 2, 3 and 4 — all three keep the camera running, so they share one
/// preview instance. Rebuilding the preview between them would restart the
/// camera and show up as a stutter on every failed scan.
class _CameraStates extends StatelessWidget {
  const _CameraStates({
    required this.state,
    required this.previewBuilder,
    required this.onDetected,
    required this.onRetry,
    required this.onManualEntry,
  });

  final ScanCodeState state;
  final ScanPreviewBuilder previewBuilder;
  final ValueChanged<String> onDetected;
  final VoidCallback onRetry;
  final VoidCallback onManualEntry;

  @override
  Widget build(BuildContext context) {
    final bool recognized = state is ScanCodeRecognized;
    final bool invalid = state is ScanCodeInvalid;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        previewBuilder(context, onDetected),
        _Viewfinder(recognized: recognized),
        if (!invalid)
          Positioned.fill(
            child: _ScanningChrome(
              recognized: recognized,
              onManualEntry: onManualEntry,
            ),
          ),
        if (invalid)
          Positioned.fill(
            child: _InvalidCard(
              onRetry: onRetry,
              onManualEntry: onManualEntry,
            ),
          ),
      ],
    );
  }
}

/// The centered framing guide. Mint plus a checkmark on success, never mint
/// alone: the accessibility section forbids signalling by color only.
class _Viewfinder extends StatelessWidget {
  const _Viewfinder({required this.recognized});

  final bool recognized;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final Size screen = MediaQuery.sizeOf(context);
    final double side =
        (screen.width < screen.height ? screen.width : screen.height) *
        _viewfinderFraction;

    return Center(
      child: AnimatedContainer(
        duration: _recognizedFlashDuration,
        width: side,
        height: side,
        decoration: BoxDecoration(
          border: Border.all(
            color: recognized ? colors.colorMint : colors.colorAccentPink,
            width: _viewfinderBorderWidth,
          ),
          borderRadius: BorderRadius.circular(platformTokens.radiusSheet),
        ),
        child: recognized
            ? Center(
                child: CupidIcon(
                  CupidIcons.check,
                  size: _stateIconSize,
                  color: colors.colorMint,
                ),
              )
            : null,
      ),
    );
  }
}

/// State 2's helper copy and manual-entry link, kept out of the way of the
/// viewfinder. Hidden during State 3 so no "scanning" wording survives past a
/// real decode.
class _ScanningChrome extends StatelessWidget {
  const _ScanningChrome({required this.recognized, required this.onManualEntry});

  final bool recognized;
  final VoidCallback onManualEntry;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    if (recognized) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: CupidSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              context.viEn(
                'Đưa camera vào mã QR của người ấy',
                'Point your camera at their QR code',
              ),
              textAlign: TextAlign.center,
              style: type.caption.copyWith(color: colors.colorTextMuted),
            ),
            SizedBox(height: CupidSpacing.md),
            _ManualEntryLink(onPressed: onManualEntry),
            SizedBox(height: CupidSpacing.lg),
          ],
        ),
      ),
    );
  }
}

/// State 4 — honest failure over a still-running preview.
class _InvalidCard extends StatelessWidget {
  const _InvalidCard({required this.onRetry, required this.onManualEntry});

  final VoidCallback onRetry;
  final VoidCallback onManualEntry;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
        child: Container(
          padding: EdgeInsets.all(CupidSpacing.lg),
          decoration: BoxDecoration(
            color: colors.colorSurface,
            border: Border.all(color: colors.colorLine),
            borderRadius: BorderRadius.circular(platformTokens.radiusCard),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CupidIcon(
                _errorIcon,
                size: _errorCardIconSize,
                color: colors.colorRed,
              ),
              SizedBox(height: CupidSpacing.sm),
              Text(
                context.viEn(
                  'Mã QR không hợp lệ hoặc đã hết hạn',
                  'This QR code is invalid or has expired',
                ),
                textAlign: TextAlign.center,
                style: type.caption.copyWith(color: colors.colorText),
              ),
              SizedBox(height: CupidSpacing.md),
              CupidPrimaryButton(
                label: context.viEn('Thử lại', 'Try again'),
                onPressed: onRetry,
              ),
              SizedBox(height: CupidSpacing.xs),
              _ManualEntryLink(onPressed: onManualEntry),
            ],
          ),
        ),
      ),
    );
  }
}

/// States 5, 6 and 7 — no camera to show, one clear way forward, and for
/// State 6 a second one back to the code row.
class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.onManualEntry,
  });

  final IconData icon;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;

  /// Present only when the primary action is not itself the manual-entry exit.
  final VoidCallback? onManualEntry;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
        child: Padding(
          padding: EdgeInsets.all(CupidSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CupidIcon(icon, size: _stateIconSize, color: colors.colorTextMuted),
              SizedBox(height: CupidSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: type.caption.copyWith(
                  height: 1.6,
                  color: colors.colorText,
                ),
              ),
              SizedBox(height: CupidSpacing.lg),
              CupidPrimaryButton(label: primaryLabel, onPressed: onPrimary),
              if (onManualEntry != null) ...<Widget>[
                SizedBox(height: CupidSpacing.xs),
                _ManualEntryLink(onPressed: onManualEntry!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The guaranteed way back to typing the code by hand, present in every state
/// the spec asks for.
class _ManualEntryLink extends StatelessWidget {
  const _ManualEntryLink({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: CupidSpacing.sm),
          child: Text(
            context.viEn('Nhập mã thủ công', 'Enter code manually'),
            textAlign: TextAlign.center,
            style: type.body.copyWith(
              fontSize: _linkFontSize,
              fontWeight: FontWeight.w700,
              color: colors.colorAccentPink,
            ),
          ),
        ),
      ),
    );
  }
}

/// The universal escape, present in all seven states.
class _CloseControl extends StatelessWidget {
  const _CloseControl({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: platformTokens.tapTarget,
        minHeight: platformTokens.tapTarget,
      ),
      child: IconButton(
        icon: CupidIcon(
          _closeIcon,
          size: _closeIconSize,
          color: colors.colorTextMuted,
        ),
        tooltip: context.viEn('Đóng', 'Close'),
        onPressed: onPressed,
      ),
    );
  }
}

Widget _mobileScannerPreview(
  BuildContext context,
  ValueChanged<String> onDetected,
) {
  return _MobileScannerPreview(onDetected: onDetected);
}

/// Owns the camera session. It is a widget rather than something the cubit
/// holds so the controller dies with the subtree — pop, back gesture,
/// permission failure and a state that has no preview all unmount it, and a
/// retained session shows up to the user as a stuck camera indicator.
class _MobileScannerPreview extends StatefulWidget {
  const _MobileScannerPreview({required this.onDetected});

  final ValueChanged<String> onDetected;

  @override
  State<_MobileScannerPreview> createState() => _MobileScannerPreviewState();
}

class _MobileScannerPreviewState extends State<_MobileScannerPreview> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const <BarcodeFormat>[BarcodeFormat.qrCode],
  );

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: _controller,
      fit: BoxFit.cover,
      onDetect: (BarcodeCapture capture) {
        for (final Barcode barcode in capture.barcodes) {
          final String? value = barcode.rawValue;
          if (value != null && value.isNotEmpty) {
            widget.onDetected(value);
            return;
          }
        }
      },
    );
  }
}
