import 'dart:ui' as ui;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../pairing_strings.dart';

/// Design-source metrics for the `isInvite` QR frame
/// (`cupid-app-design-system/Cupid Screens.dc.html` lines 173-179). None of
/// these sizes land on `CupidSpacing`'s 8pt scale, so they are transcribed
/// verbatim the same way `invite_screen.dart` carries its own card metrics.
const double _frameSize = 186;
const double _framePadding = 16;
const double _frameRadius = 28;
const double _qrSize = _frameSize - 2 * _framePadding;
const double _glowSize = 290;
const double _badgeSize = 40;
const double _badgeRadius = 14;
const double _badgeRingWidth = 5;
const double _badgeIconSize = 21;
const double _scanBandHeight = 26;
const double _scanBandEdgeWidth = 1.5;

/// `left:-6%;right:-6%` on the scan band, and the `translateY(-6%)` ->
/// `translateY(106%)` sweep of `@keyframes qrScan`.
const double _scanOverhang = 0.06;

/// One clock drives both design loops: `breathe 4.5s` and `qrScan 3.4s`. 153s
/// is their least common period, so 34 breathe cycles and 45 scan cycles fit
/// it exactly and neither loop drifts against the other.
const Duration _clockPeriod = Duration(milliseconds: 153000);
const double _breatheCycles = 34;
const double _scanCycles = 45;

/// `cubic-bezier(.45,0,.55,1)` on `qrScan`.
const Cubic _scanCurve = Cubic(0.45, 0, 0.55, 1);

/// `@keyframes qrScan` fades the band in by 12% and back out from 88%.
const double _scanFadeIn = 0.12;
const double _scanFadeOut = 0.88;

/// `@keyframes breathe`: `scale(1)`/`opacity:.5` at the ends, `scale(1.09)`/
/// `opacity:.85` at the midpoint.
const double _breatheMinScale = 1;
const double _breatheMaxScale = 1.09;
const double _breatheMinOpacity = 0.5;
const double _breatheMaxOpacity = 0.85;

/// `filter: blur(6px)` on the ambient glow blob.
const double _glowBlurSigma = 6;

/// The inviter's pairing QR: a live, scannable rendering of [code] on the
/// design's white paper frame, with the center heart badge and the sweeping
/// scan band that signal the code is live.
///
/// Pure presentation — it reads no cubit and issues no request. [code] is the
/// one pairing-code value the card also renders as text
/// (`architecture/contract-summary.md`: the payload is that bare string, never
/// a URL, prefix, or case transform).
class InviteQrFrame extends StatefulWidget {
  const InviteQrFrame({super.key, required this.code});

  /// The pairing code to encode, passed through byte-for-byte.
  final String code;

  @override
  State<InviteQrFrame> createState() => _InviteQrFrameState();
}

class _InviteQrFrameState extends State<InviteQrFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(vsync: this, duration: _clockPeriod)..repeat();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: context.viEn(
        'Mã QR chứa mã ghép đôi ${widget.code}',
        'QR code containing pairing code ${widget.code}',
      ),
      // The package publishes its own generic "qr code" label on the image it
      // builds; excluding the subtree keeps the code-carrying label above as
      // the only node a screen reader reaches.
      child: ExcludeSemantics(
        child: SizedBox(
          width: _frameSize,
          height: _frameSize,
          child: Stack(
            // The glow is a decorative bleed wider than the frame; the card's
            // own bounds are what the design clips it against.
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                left: (_frameSize - _glowSize) / 2,
                top: (_frameSize - _glowSize) / 2,
                width: _glowSize,
                height: _glowSize,
                child: _AmbientGlow(clock: _clock),
              ),
              _QrPaper(code: widget.code, clock: _clock),
            ],
          ),
        ),
      ),
    );
  }
}

/// `animation: breathe 4.5s ease-in-out infinite` on the radial blob behind
/// the frame.
class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.clock});

  final Animation<double> clock;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: clock,
        builder: (BuildContext context, Widget? child) {
          final double phase = (clock.value * _breatheCycles) % 1;
          // The keyframes are symmetric around the 50% midpoint, so one
          // triangle wave reproduces both halves.
          final double eased = Curves.easeInOut.transform(
            1 - (2 * phase - 1).abs(),
          );
          return Opacity(
            opacity: ui.lerpDouble(
              _breatheMinOpacity,
              _breatheMaxOpacity,
              eased,
            )!,
            child: Transform.scale(
              scale: ui.lerpDouble(
                _breatheMinScale,
                _breatheMaxScale,
                eased,
              )!,
              child: child,
            ),
          );
        },
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(
            sigmaX: _glowBlurSigma,
            sigmaY: _glowBlurSigma,
          ),
          child: const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: QrPalette.ambientGlow,
            ),
          ),
        ),
      ),
    );
  }
}

/// The white `186x186` paper: QR art, sweeping scan band, and center badge.
class _QrPaper extends StatelessWidget {
  const _QrPaper({required this.code, required this.clock});

  final String code;
  final Animation<double> clock;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _frameSize,
      height: _frameSize,
      padding: const EdgeInsets.all(_framePadding),
      decoration: BoxDecoration(
        color: QrPalette.paper,
        borderRadius: BorderRadius.circular(_frameRadius),
        boxShadow: const <BoxShadow>[QrPalette.frameShadow],
      ),
      child: ClipRect(
        child: Stack(
          children: <Widget>[
            QrImageView(
              data: code,
              size: _qrSize,
              padding: EdgeInsets.zero,
              backgroundColor: QrPalette.paper,
              // The center badge occludes the QR's middle modules, so the
              // payload has to survive on redundancy alone
              // (`architecture/contract-summary.md` section 3).
              errorCorrectionLevel: QrErrorCorrectLevel.H,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: QrPalette.moduleInk,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: QrPalette.moduleInk,
              ),
            ),
            _ScanBand(clock: clock),
            const Center(child: _HeartBadge()),
          ],
        ),
      ),
    );
  }
}

/// `animation: qrScan 3.4s cubic-bezier(.45,0,.55,1) infinite` — the band
/// sweeps the full art height and loops, so the frame reads as live rather
/// than as a static picture.
class _ScanBand extends StatelessWidget {
  const _ScanBand({required this.clock});

  final Animation<double> clock;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: clock,
      builder: (BuildContext context, Widget? child) {
        final double phase = (clock.value * _scanCycles) % 1;
        final double travel = _scanCurve.transform(phase);
        final double opacity = switch (phase) {
          < _scanFadeIn => phase / _scanFadeIn,
          > _scanFadeOut => (1 - phase) / (1 - _scanFadeOut),
          _ => 1,
        };
        return Positioned(
          left: -_scanOverhang * _qrSize,
          right: -_scanOverhang * _qrSize,
          top: ui.lerpDouble(
            -_scanOverhang * _qrSize,
            (1 + _scanOverhang) * _qrSize,
            travel,
          ),
          height: _scanBandHeight,
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: const IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: QrPalette.scanBand,
            border: Border(
              bottom: BorderSide(
                color: QrPalette.scanEdge,
                width: _scanBandEdgeWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The `40x40` gradient heart sitting on top of the art, lifted clear of the
/// modules by its `5px` paper ring.
class _HeartBadge extends StatelessWidget {
  const _HeartBadge();

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;

    return Container(
      width: _badgeSize,
      height: _badgeSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: colors.gradientHot,
        borderRadius: BorderRadius.circular(_badgeRadius),
        boxShadow: const <BoxShadow>[
          QrPalette.badgeShadow,
          // `0 0 0 5px #FFFDFE`: the cutout that reads as the badge sitting on
          // the art rather than blending into it. Painted last so the soft
          // lift above does not tint it.
          BoxShadow(
            color: QrPalette.paper,
            spreadRadius: _badgeRingWidth,
            blurRadius: 0,
          ),
        ],
      ),
      child: CupidIcon(
        CupidIcons.favorite,
        size: _badgeIconSize,
        color: colors.colorOnAccent,
      ),
    );
  }
}
