import 'package:flutter/material.dart';

/// One elliptical radial layer of the app-shell sky wash.
///
/// Every factor is a fraction of the painted surface. The design source writes
/// each layer as `radial-gradient(x% y% at cx% cy%, color, transparent stop%)`,
/// where the leading percentage pair is the ellipse's horizontal and vertical
/// *radius*, not its width and height.
@immutable
class CupidSkyLayer {
  const CupidSkyLayer({
    required this.radiusXFactor,
    required this.radiusYFactor,
    required this.centerXFactor,
    required this.centerYFactor,
    required this.color,
    required this.endStop,
  });

  /// Horizontal ellipse radius, as a fraction of the surface width.
  final double radiusXFactor;

  /// Vertical ellipse radius, as a fraction of the surface height.
  final double radiusYFactor;

  /// Ellipse center X, as a fraction of the surface width.
  final double centerXFactor;

  /// Ellipse center Y, as a fraction of the surface height. Values outside
  /// `0..1` place the center beyond the surface edge, as the source does.
  final double centerYFactor;

  /// Color at the ellipse center. It fades out to the same RGB at zero alpha.
  final Color color;

  /// Gradient stop, `0..1`, at which [color] has fully faded out.
  final double endStop;
}

/// One twinkling star particle of the app-shell sky wash.
///
/// Exactly one of [leftFactor] and [rightFactor] is set, matching the source's
/// per-particle `left:`/`right:` placement.
@immutable
class CupidSkyStar {
  const CupidSkyStar({
    required this.topFactor,
    required this.size,
    required this.color,
    required this.period,
    required this.delay,
    this.leftFactor,
    this.rightFactor,
  });

  /// Offset from the surface left edge, as a fraction of the surface width.
  final double? leftFactor;

  /// Offset from the surface right edge, as a fraction of the surface width.
  final double? rightFactor;

  /// Offset from the surface top edge, as a fraction of the surface height.
  final double topFactor;

  /// Diameter in logical pixels, at rest scale.
  final double size;

  final Color color;

  /// Duration of one full `low -> high -> low` twinkle cycle.
  final Duration period;

  /// How long the particle holds its rest state before its first cycle.
  final Duration delay;
}

/// App-shell background values transcribed from the locked design source
/// (`cupid-app-design-system/project/Cupid Screens.dc.html`, the root frame
/// `div` that wraps every screen block).
///
/// `CupidColorTokens.skyGradient` carries the same three radial layers as a
/// verbatim CSS string, and its own dartdoc defers the rendering mechanism to
/// whichever story first paints it. These are that string parsed into
/// paintable values for `CupidAppBackground` — the layers have independent
/// per-layer ellipse size and position, which no single Flutter [Gradient]
/// object expresses.
///
/// The star particles are declared once in the source frame block, outside any
/// `[data-plat]` or theme branch, so they do not vary with platform or theme.
abstract final class CupidSkyPalette {
  /// Dark-theme layers, in paint order (`CupidColorTokens.dark().skyGradient`).
  static const List<CupidSkyLayer> darkLayers = <CupidSkyLayer>[
    CupidSkyLayer(
      radiusXFactor: 1.20,
      radiusYFactor: 0.70,
      centerXFactor: 0.15,
      centerYFactor: -0.08,
      color: Color.fromRGBO(123, 47, 190, 0.55),
      endStop: 0.62,
    ),
    CupidSkyLayer(
      radiusXFactor: 0.90,
      radiusYFactor: 0.55,
      centerXFactor: 0.95,
      centerYFactor: 0.06,
      color: Color.fromRGBO(255, 75, 140, 0.32),
      endStop: 0.60,
    ),
    CupidSkyLayer(
      radiusXFactor: 0.80,
      radiusYFactor: 0.50,
      centerXFactor: 0.50,
      centerYFactor: 1.08,
      color: Color.fromRGBO(0, 201, 167, 0.16),
      endStop: 0.62,
    ),
  ];

  /// Light-theme layers, in paint order
  /// (`CupidColorTokens.light().skyGradient`).
  static const List<CupidSkyLayer> lightLayers = <CupidSkyLayer>[
    CupidSkyLayer(
      radiusXFactor: 1.20,
      radiusYFactor: 0.70,
      centerXFactor: 0.12,
      centerYFactor: -0.10,
      color: Color.fromRGBO(255, 182, 214, 0.72),
      endStop: 0.62,
    ),
    CupidSkyLayer(
      radiusXFactor: 0.90,
      radiusYFactor: 0.55,
      centerXFactor: 0.96,
      centerYFactor: 0.04,
      color: Color.fromRGBO(206, 180, 255, 0.60),
      endStop: 0.60,
    ),
    CupidSkyLayer(
      radiusXFactor: 0.80,
      radiusYFactor: 0.50,
      centerXFactor: 0.50,
      centerYFactor: 1.08,
      color: Color.fromRGBO(178, 240, 226, 0.50),
      endStop: 0.62,
    ),
  ];

  /// The three twinkle particles, theme- and platform-independent.
  static const List<CupidSkyStar> stars = <CupidSkyStar>[
    CupidSkyStar(
      leftFactor: 0.08,
      topFactor: 0.14,
      size: 6,
      color: Color(0xFFFFFFFF),
      period: Duration(milliseconds: 3400),
      delay: Duration.zero,
    ),
    CupidSkyStar(
      rightFactor: 0.16,
      topFactor: 0.09,
      size: 4,
      color: Color(0xFFFFD9EA),
      period: Duration(milliseconds: 4600),
      delay: Duration(milliseconds: 800),
    ),
    CupidSkyStar(
      rightFactor: 0.07,
      topFactor: 0.26,
      size: 5,
      color: Color(0xFFCEB4FF),
      period: Duration(milliseconds: 5200),
      delay: Duration(milliseconds: 1600),
    ),
  ];

  /// Twinkle rest state, held at the start and under reduce-motion.
  static const double twinkleMinOpacity = 0.25;
  static const double twinkleMinScale = 0.85;

  /// Twinkle peak, reached at the midpoint of each [CupidSkyStar.period].
  static const double twinkleMaxOpacity = 1.0;
  static const double twinkleMaxScale = 1.15;
}
