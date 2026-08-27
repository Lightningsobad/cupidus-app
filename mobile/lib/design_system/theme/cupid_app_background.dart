import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../features/themes/presentation/theme_cubit.dart';
import '../fx/cupid_fx_engine.dart';
import '../tokens/cupid_sky_palette.dart';
import '../tokens/theme_catalog.dart';
import 'cupid_theme_context.dart';

/// Paints the shared app-shell sky wash behind [child] — the solid
/// `colorBackground` fill, `CupidSkyPalette` radial layers, the base twinkle
/// stars, and dynamic declarative theme FX particles / shooting stars when
/// enabled.
///
/// Mounted once at the composition root through `MaterialApp.builder`.
class CupidAppBackground extends StatefulWidget {
  const CupidAppBackground({
    required this.child,
    super.key,
    this.customLayers,
    this.customFxConfig,
    this.enableEffectsOverride,
  });

  final Widget child;
  final List<CupidSkyLayer>? customLayers;
  final ThemeFXConfig? customFxConfig;
  final bool? enableEffectsOverride;

  @override
  State<CupidAppBackground> createState() => _CupidAppBackgroundState();
}

class _CupidAppBackgroundState extends State<CupidAppBackground>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<Duration> _elapsed = ValueNotifier<Duration>(
    Duration.zero,
  );

  late final Ticker _ticker = createTicker(
    (Duration elapsed) => _elapsed.value = elapsed,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTickerState();
  }

  void _syncTickerState([bool isFxActive = true]) {
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion || !isFxActive) {
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

  Widget _buildContent(
    BuildContext context,
    List<CupidSkyLayer> layers,
    ThemeFXConfig? fxConfig,
    bool isEffectsEnabled,
  ) {
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final bool shouldRunFx = isEffectsEnabled && !reduceMotion;

    if (shouldRunFx) {
      if (!_ticker.isActive) _ticker.start();
    } else {
      if (_ticker.isActive) {
        _ticker.stop();
        _elapsed.value = Duration.zero;
      }
    }

    return ColoredBox(
      color: context.cupidColors.colorBackground,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CustomPaint(painter: CupidSkyPainter(layers: layers)),
          widget.child,
          _CupidSkyStars(elapsed: _elapsed),
          if (shouldRunFx && fxConfig != null)
            CupidFxOverlay(
              fxConfig: fxConfig,
              elapsed: _elapsed,
              isEnabled: shouldRunFx,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (getIt.isRegistered<ThemeCubit>()) {
      return BlocBuilder<ThemeCubit, ThemeState>(
        bloc: getIt<ThemeCubit>(),
        builder: (context, state) {
          final active = state.activeTheme;
          final layers = widget.customLayers ?? active.skyLayers;
          final fx = widget.customFxConfig ?? active.fxConfig;
          final bool isEnabled =
              widget.enableEffectsOverride ?? state.isEffectsEnabled;
          return _buildContent(context, layers, fx, isEnabled);
        },
      );
    }

    final List<CupidSkyLayer> fallbackLayers = widget.customLayers ??
        (Theme.of(context).brightness == Brightness.dark
            ? CupidSkyPalette.darkLayers
            : CupidSkyPalette.lightLayers);

    return _buildContent(
      context,
      fallbackLayers,
      widget.customFxConfig ?? cupidThemeCatalog.first.fxConfig,
      widget.enableEffectsOverride ?? true,
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

      final Matrix4 ellipse = Matrix4.identity()
        ..translateByDouble(center.dx, center.dy, 0, 1)
        ..scaleByDouble(1, radiusY / radiusX, 1, 1)
        ..translateByDouble(-center.dx, -center.dy, 0, 1);

      final Paint paint = Paint()
        ..shader = ui.Gradient.radial(
          center,
          radiusX,
          <Color>[layer.color, layer.color.withValues(alpha: 0)],
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

/// The decorative twinkle layer for the three baseline sky stars.
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
