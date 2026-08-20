import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../tokens/cupid_sky_palette.dart';
import 'cupid_theme_context.dart';

/// Paints the shared app-shell sky wash behind [child] — the solid
/// `colorBackground` fill and `CupidSkyPalette`'s three radial layers — and the
/// three twinkle star particles above it. The particles paint above the child
/// because the design source authors them as `position:absolute` siblings of
/// the screen body, which CSS paints above in-flow screen content.
///
/// The design source wraps every screen block in one frame that carries this
/// background, so this widget is mounted once at the composition root through
/// `MaterialApp.builder` rather than per screen. `buildCupidTheme` sets
/// `scaffoldBackgroundColor` to transparent so screens' own `Scaffold`s do not
/// occlude it.
class CupidAppBackground extends StatefulWidget {
  const CupidAppBackground({required this.child, super.key});

  final Widget child;

  @override
  State<CupidAppBackground> createState() => _CupidAppBackgroundState();
}

class _CupidAppBackgroundState extends State<CupidAppBackground>
    with SingleTickerProviderStateMixin {
  /// The three stars have unrelated periods and start delays, so no single
  /// `0..1` controller cycle covers all of them; the ticker is used as a
  /// monotonic clock and each star derives its own phase from it.
  final ValueNotifier<Duration> _elapsed = ValueNotifier<Duration>(
    Duration.zero,
  );

  late final Ticker _ticker = createTicker(
    (Duration elapsed) => _elapsed.value = elapsed,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      if (_ticker.isActive) {
        _ticker.stop();
        _elapsed.value = Duration.zero;
      }
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _elapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<CupidSkyLayer> layers =
        Theme.of(context).brightness == Brightness.dark
        ? CupidSkyPalette.darkLayers
        : CupidSkyPalette.lightLayers;

    return ColoredBox(
      color: context.cupidColors.colorBackground,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CustomPaint(painter: CupidSkyPainter(layers: layers)),
          widget.child,
          _CupidSkyStars(elapsed: _elapsed),
        ],
      ),
    );
  }
}

/// Paints [CupidSkyLayer]s as stacked elliptical radial gradients covering the
/// whole canvas, back to front.
class CupidSkyPainter extends CustomPainter {
  const CupidSkyPainter({required this.layers});

  final List<CupidSkyLayer> layers;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    final Rect surface = Offset.zero & size;

    for (final CupidSkyLayer layer in layers) {
      final double radiusX = layer.radiusXFactor * size.width;
      final double radiusY = layer.radiusYFactor * size.height;
      final Offset center = Offset(
        layer.centerXFactor * size.width,
        layer.centerYFactor * size.height,
      );

      // Scale about the center so the circle of radius radiusX becomes a
      // radiusX x radiusY ellipse.
      final Matrix4 ellipse = Matrix4.identity()
        ..translateByDouble(center.dx, center.dy, 0, 1)
        ..scaleByDouble(1, radiusY / radiusX, 1, 1)
        ..translateByDouble(-center.dx, -center.dy, 0, 1);

      final Paint paint = Paint()
        ..shader = ui.Gradient.radial(
          center,
          radiusX,
          // The same RGB at zero alpha, never Colors.transparent: fading
          // through transparent black leaves a visible dark halo.
          <Color>[layer.color, layer.color.withAlpha(0)],
          <double>[0.0, layer.endStop],
          TileMode.clamp,
          ellipse.storage,
        );

      canvas.drawRect(surface, paint);
    }
  }

  @override
  bool shouldRepaint(CupidSkyPainter oldDelegate) =>
      oldDelegate.layers != layers;
}

/// The decorative twinkle layer. It never takes part in semantics or hit
/// testing, and repaints independently of the gradient behind it.
class _CupidSkyStars extends StatelessWidget {
  const _CupidSkyStars({required this.elapsed});

  final ValueListenable<Duration> elapsed;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Size surface = constraints.biggest;
              return ValueListenableBuilder<Duration>(
                valueListenable: elapsed,
                builder: (BuildContext context, Duration value, Widget? child) {
                  return Stack(
                    children: <Widget>[
                      for (final CupidSkyStar star in CupidSkyPalette.stars)
                        _star(star, surface, value),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _star(CupidSkyStar star, Size surface, Duration elapsed) {
    final double phase = _twinklePhase(star, elapsed);
    final double opacity =
        CupidSkyPalette.twinkleMinOpacity +
        (CupidSkyPalette.twinkleMaxOpacity - CupidSkyPalette.twinkleMinOpacity) *
            phase;
    final double scale =
        CupidSkyPalette.twinkleMinScale +
        (CupidSkyPalette.twinkleMaxScale - CupidSkyPalette.twinkleMinScale) *
            phase;

    return Positioned(
      left: star.leftFactor == null ? null : star.leftFactor! * surface.width,
      right: star.rightFactor == null
          ? null
          : star.rightFactor! * surface.width,
      top: star.topFactor * surface.height,
      width: star.size,
      height: star.size,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: star.color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  /// Eased `0..1` position in the star's symmetric `low -> high -> low` cycle.
  double _twinklePhase(CupidSkyStar star, Duration elapsed) {
    final int sinceStartMs =
        elapsed.inMilliseconds - star.delay.inMilliseconds;
    if (sinceStartMs <= 0) {
      return 0;
    }
    final double linear =
        (sinceStartMs % star.period.inMilliseconds) /
        star.period.inMilliseconds;
    final double triangle = linear <= 0.5 ? linear * 2 : (1 - linear) * 2;
    return Curves.easeInOut.transform(triangle);
  }
}
