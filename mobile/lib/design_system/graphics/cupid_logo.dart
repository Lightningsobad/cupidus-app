import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/cupid_theme_context.dart';
import '../tokens/cupid_color_tokens.dart';

/// The variant of the Cupid logo mark (`Cupid Logo.dc.html`).
enum CupidLogoVariant {
  /// Standard mark: pink disc with heart cutout + purple orbit dot (`#mk`).
  standard,

  /// Reduced mark for sizes <= 20px: heart cutout 10% smaller, orbit dot
  /// slightly larger (`#mkSmall`).
  small,

  /// Disc only without orbit dot, for app icon, favicon, or watermark
  /// (`#mkDisc`).
  discOnly,

  /// Monochrome single-color mark using [CupidLogo.monochromeColor] or
  /// [CupidColorTokens.colorText] (`#mkMono`).
  monochrome,
}

/// Official Cupid Logo component matching `Cupid Logo.dc.html` specifications.
///
/// Features:
/// - Flat Cupid Pink disc (`#FF7FB6`) with an 8°-tilted negative-space heart
///   cutout (`PathOperation.difference`), ensuring the true background (or
///   photo) shines through.
/// - Purple orbit dot (`#B78CF5`) representing the other partner.
/// - Opening animation support: orbit dot flies on an arc into the heart cutout
///   while the disc bounces 4% (`1.0 -> 1.04 -> 1.0`).
/// - 4 variants: [CupidLogoVariant.standard], [CupidLogoVariant.small],
///   [CupidLogoVariant.discOnly], and [CupidLogoVariant.monochrome].
class CupidLogo extends StatelessWidget {
  const CupidLogo({
    super.key,
    this.size = 48,
    this.variant = CupidLogoVariant.standard,
    this.discColor,
    this.orbitColor,
    this.monochromeColor,
    this.animationProgress,
    this.semanticLabel = 'Cupid',
  });

  /// Size (width and height) of the logo in logical pixels.
  final double size;

  /// Logo variant to render.
  final CupidLogoVariant variant;

  /// Optional override for the main disc color (defaults to
  /// [CupidColorTokens.colorAccentPink]).
  final Color? discColor;

  /// Optional override for the orbit dot color (defaults to
  /// [CupidColorTokens.colorAccentPurple]).
  final Color? orbitColor;

  /// Optional override for monochrome color when [variant] is
  /// [CupidLogoVariant.monochrome] (defaults to [CupidColorTokens.colorText]).
  final Color? monochromeColor;

  /// Animation progress from `0.0` to `1.0` for the app-opening animation.
  /// When null, renders the settled static logo.
  final double? animationProgress;

  /// Accessibility label.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens? tokens = Theme.of(
      context,
    ).extension<CupidColorTokens>();

    final Color resolvedDiscColor =
        discColor ?? tokens?.colorAccentPink ?? const Color(0xFFFF7FB6);
    final Color resolvedOrbitColor =
        orbitColor ?? tokens?.colorAccentPurple ?? const Color(0xFFB78CF5);
    final Color resolvedMonoColor =
        monochromeColor ?? tokens?.colorText ?? const Color(0xFFF7EEFB);

    final Widget logoWidget = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: CupidLogoPainter(
          variant: variant,
          discColor: resolvedDiscColor,
          orbitColor: resolvedOrbitColor,
          monochromeColor: resolvedMonoColor,
          animationProgress: animationProgress,
        ),
      ),
    );

    if (semanticLabel != null && semanticLabel!.isNotEmpty) {
      return Semantics(label: semanticLabel, image: true, child: logoWidget);
    }
    return logoWidget;
  }
}

/// CustomPainter rendering the exact geometry from `Cupid Logo.dc.html`.
class CupidLogoPainter extends CustomPainter {
  const CupidLogoPainter({
    this.variant = CupidLogoVariant.standard,
    required this.discColor,
    required this.orbitColor,
    required this.monochromeColor,
    this.animationProgress,
  });

  final CupidLogoVariant variant;
  final Color discColor;
  final Color orbitColor;
  final Color monochromeColor;
  final double? animationProgress;

  static const double _viewBoxSize = 100.0;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / _viewBoxSize;
    canvas.save();
    canvas.scale(scale, scale);

    final double t = (animationProgress ?? 0.0).clamp(0.0, 1.0);

    // Opening animation bounce: disc expands up to 4% at midpoint, then settles.
    final double discScale =
        animationProgress != null ? 1.0 + 0.04 * math.sin(t * math.pi) : 1.0;

    final Color primaryColor = switch (variant) {
      CupidLogoVariant.monochrome => monochromeColor,
      _ => discColor,
    };

    final Color dotColor = switch (variant) {
      CupidLogoVariant.monochrome => monochromeColor,
      _ => orbitColor,
    };

    // 1. Disc Geometry (viewBox: 100x100)
    final Offset discCenter = switch (variant) {
      CupidLogoVariant.discOnly => const Offset(50.0, 50.0),
      _ => const Offset(50.0, 53.0),
    };
    final double discRadius = switch (variant) {
      CupidLogoVariant.discOnly => 46.0 * discScale,
      _ => 40.0 * discScale,
    };

    final Path discPath = Path()
      ..addOval(Rect.fromCircle(center: discCenter, radius: discRadius));

    // 2. Heart Cutout Geometry
    final Path heartBasePath = _buildHeartBasePath();
    final Matrix4 heartTransform = _buildHeartTransform(
      isSmall: variant == CupidLogoVariant.small,
      discCenter: discCenter,
      discScale: discScale,
    );
    final Path transformedHeartPath = heartBasePath.transform(
      heartTransform.storage,
    );

    // Negative space cutout: subtract heart from disc.
    final Path cutoutDisc = Path.combine(
      PathOperation.difference,
      discPath,
      transformedHeartPath,
    );

    final Paint discPaint = Paint()
      ..color = primaryColor
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    canvas.drawPath(cutoutDisc, discPaint);

    // 3. Orbit Dot Geometry
    if (variant != CupidLogoVariant.discOnly) {
      _paintOrbitDot(canvas, dotColor, t);
    }

    canvas.restore();
  }

  void _paintOrbitDot(Canvas canvas, Color color, double t) {
    final bool isSmall = variant == CupidLogoVariant.small;
    final Offset startDot = isSmall
        ? const Offset(90.0, 12.0)
        : const Offset(89.0, 13.0);
    final double baseRadius = isSmall ? 8.5 : 7.5;

    Offset dotCenter = startDot;
    double dotRadius = baseRadius;
    double dotOpacity = 1.0;

    if (animationProgress != null) {
      // Animate along an arc toward the heart center (~50, 48).
      const Offset target = Offset(50.0, 48.0);
      const Offset control = Offset(82.0, 54.0);

      // Quadratic bezier arc interpolation: (1-t)^2 * P0 + 2(1-t)t * P1 + t^2 * P2
      final double invT = 1.0 - t;
      final double dx =
          invT * invT * startDot.dx +
          2 * invT * t * control.dx +
          t * t * target.dx;
      final double dy =
          invT * invT * startDot.dy +
          2 * invT * t * control.dy +
          t * t * target.dy;

      dotCenter = Offset(dx, dy);
      dotRadius = baseRadius * (1.0 - 0.15 * t);
      // Soft fade as it settles in the heart.
      dotOpacity = (1.0 - 0.4 * t).clamp(0.0, 1.0);
    }

    final Paint dotPaint = Paint()
      ..color = color.withValues(alpha: color.a * dotOpacity)
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    canvas.drawCircle(dotCenter, dotRadius, dotPaint);
  }

  /// Base SVG path from `Cupid Logo.dc.html`:
  /// `M9 40 C4 24, 15 10.5, 29 10.5 C39 10.5, 46 16.5, 50 24.5 C54 16.5, 61 10.5, 71 10.5 C85 10.5, 96 24, 91 40 C87 53, 62 69, 52.5 77.5 C51 78.8, 49 78.8, 47.5 77.5 C38 69, 13 53, 9 40 Z`
  static Path _buildHeartBasePath() {
    return Path()
      ..moveTo(9.0, 40.0)
      ..cubicTo(4.0, 24.0, 15.0, 10.5, 29.0, 10.5)
      ..cubicTo(39.0, 10.5, 46.0, 16.5, 50.0, 24.5)
      ..cubicTo(54.0, 16.5, 61.0, 10.5, 71.0, 10.5)
      ..cubicTo(85.0, 10.5, 96.0, 24.0, 91.0, 40.0)
      ..cubicTo(87.0, 53.0, 62.0, 69.0, 52.5, 77.5)
      ..cubicTo(51.0, 78.8, 49.0, 78.8, 47.5, 77.5)
      ..cubicTo(38.0, 69.0, 13.0, 53.0, 9.0, 40.0)
      ..close();
  }

  /// SVG matrix transformation:
  /// Standard: `translate(19,22) scale(0.62) rotate(-8 50 45)`
  /// Small: `translate(21.5,24.5) scale(0.56) rotate(-8 50 45)`
  static Matrix4 _buildHeartTransform({
    required bool isSmall,
    required Offset discCenter,
    required double discScale,
  }) {
    final double tx = isSmall ? 21.5 : 19.0;
    final double ty = isSmall ? 24.5 : 22.0;
    final double scaleVal = (isSmall ? 0.56 : 0.62) * discScale;
    const double rad = -8.0 * (math.pi / 180.0);

    // Apply SVG transform chain: Translate(tx, ty) * Scale(s) * RotateAround(50, 45, -8deg)
    final Matrix4 matrix = Matrix4.identity();

    // If disc is bouncing, scale around disc center
    if (discScale != 1.0) {
      matrix
        ..translate(discCenter.dx, discCenter.dy)
        ..scale(discScale, discScale)
        ..translate(-discCenter.dx, -discCenter.dy);
    }

    matrix
      ..translate(tx, ty)
      ..scale(scaleVal, scaleVal)
      ..translate(50.0, 45.0)
      ..rotateZ(rad)
      ..translate(-50.0, -45.0);

    return matrix;
  }

  @override
  bool shouldRepaint(covariant CupidLogoPainter oldDelegate) {
    return oldDelegate.variant != variant ||
        oldDelegate.discColor != discColor ||
        oldDelegate.orbitColor != orbitColor ||
        oldDelegate.monochromeColor != monochromeColor ||
        oldDelegate.animationProgress != animationProgress;
  }
}
