import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/design_system.dart';
import '../../../../design_system/tokens/theme_catalog.dart';
import '../../../auth/presentation/auth_strings.dart';
import '../../../themes/presentation/theme_cubit.dart';

/// Geometry and styling constants for the days counter layout.
/// Transcribed verbatim from `Cupid Screens.dc.html:269` (`font-size:66px;line-height:.9;letter-spacing:-.04em`).
const double _daysCountFontSize = 66.0;
const double _daysRowGap = 11;
const double _daysUnitBaselineLift = 10;
const double _daysUnitFontSize = 19;
const double _growthBadgeSize = 6;
const double _growthBadgeGap = 6;

/// Configuration for theme-specific nurturing effects.
class _NurtureThemeConfig {
  const _NurtureThemeConfig({
    required this.auraPalette,
    required this.particlePalette,
    required this.particleShape,
    required this.shimmerColor,
    required this.accentGlow,
    this.particleCount = 10,
    this.auraRadius = 140.0,
  });

  final List<Color> auraPalette;
  final List<Color> particlePalette;
  final String particleShape;
  final Color shimmerColor;
  final Color accentGlow;
  final int particleCount;
  final double auraRadius;

  static _NurtureThemeConfig fromTheme(ThemeDefinition theme) {
    final fx = theme.fxConfig;
    final particles = fx?.particles;
    final List<Color> rawPalette =
        (particles != null && particles.colors.isNotEmpty)
            ? particles.colors
            : (theme.dots.isNotEmpty ? theme.dots : theme.gradient.colors);
    final Color primary = theme.palette.isNotEmpty
        ? theme.palette[0].hex
        : theme.gradient.colors.first;
    final Color secondary = theme.palette.length > 1
        ? theme.palette[1].hex
        : theme.gradient.colors.last;
    final Color accent = theme.dots.isNotEmpty
        ? theme.dots.first
        : (theme.palette.length > 2 ? theme.palette[2].hex : primary);
    final Color glow = fx?.touchReaction.color ?? accent;

    return _NurtureThemeConfig(
      auraPalette: <Color>[accent, glow],
      particlePalette: rawPalette.length >= 2
          ? rawPalette
          : <Color>[primary, secondary, accent, glow],
      particleShape: particles?.shape ?? 'star',
      shimmerColor: accent,
      accentGlow: glow,
      particleCount: (particles != null && particles.count > 0)
          ? particles.count
          : 10,
      auraRadius: 140.0,
    );
  }
}

/// Simulated particle state around the days counter.
class _NurtureParticle {
  _NurtureParticle({
    required this.originX,
    required this.originY,
    required this.size,
    required this.speed,
    required this.color,
    required this.swayFreq,
    required this.phaseOffsetMs,
  });

  final double originX;
  final double originY;
  final double size;
  final double speed;
  final Color color;
  final double swayFreq;
  final int phaseOffsetMs;
}

/// Dynamic touch burst particle state.
class _TapBurstParticle {
  _TapBurstParticle({
    required this.position,
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
    required this.startTime,
  });

  final Offset position;
  final double angle;
  final double speed;
  final Color color;
  final double size;
  final Duration startTime;
}

/// A theme-reactive living days counter widget that radiates a breathing aura,
/// floats ambient theme spores/sparkles, sweeps subtle light shimmers, and
/// bursts with delight upon user touch.
class ThemedDaysCounterNurture extends StatefulWidget {
  const ThemedDaysCounterNurture({
    super.key,
    required this.days,
    this.themeOverride,
    this.enableAmbientAnimation,
    this.onTap,
  });

  final int days;
  final ThemeDefinition? themeOverride;
  final bool? enableAmbientAnimation;
  final VoidCallback? onTap;

  @override
  State<ThemedDaysCounterNurture> createState() =>
      _ThemedDaysCounterNurtureState();
}

class _ThemedDaysCounterNurtureState extends State<ThemedDaysCounterNurture>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<Duration> _elapsed = ValueNotifier<Duration>(
    Duration.zero,
  );
  late final Ticker _ticker;
  List<_NurtureParticle> _particles = <_NurtureParticle>[];
  final List<_TapBurstParticle> _burstParticles = <_TapBurstParticle>[];
  String? _lastThemeId;
  double _bounceScale = 1.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((Duration elapsed) {
      _elapsed.value = elapsed;
      // Clean up expired tap bursts (> 900ms)
      _burstParticles.removeWhere(
        (p) => (elapsed - p.startTime).inMilliseconds > 900,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTickerState();
  }

  bool _resolveIsFxActive() {
    if (widget.enableAmbientAnimation != null) {
      return widget.enableAmbientAnimation!;
    }
    if (widget.themeOverride != null) {
      return true;
    }
    if (getIt.isRegistered<ThemeCubit>()) {
      return getIt<ThemeCubit>().state.isEffectsEnabled;
    }
    return false;
  }

  void _syncTickerState() {
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final bool isFxActive = _resolveIsFxActive();

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

  void _initParticles(ThemeDefinition theme) {
    if (_lastThemeId == theme.id && _particles.isNotEmpty) return;
    _lastThemeId = theme.id;
    final config = _NurtureThemeConfig.fromTheme(theme);
    final random = math.Random(theme.id.hashCode);

    _particles = List<_NurtureParticle>.generate(config.particleCount, (index) {
      final color =
          config.particlePalette[index % config.particlePalette.length];
      return _NurtureParticle(
        originX: random.nextDouble(),
        originY: random.nextDouble(),
        size: 3.0 + random.nextDouble() * 4.5,
        speed: 0.2 + random.nextDouble() * 0.4,
        color: color,
        swayFreq: 0.8 + random.nextDouble() * 1.4,
        phaseOffsetMs: random.nextInt(6000),
      );
    });
  }

  void _handleTapDown(TapDownDetails details, _NurtureThemeConfig config) {
    HapticFeedback.lightImpact();
    widget.onTap?.call();

    final random = math.Random();
    final Offset localPos = details.localPosition;

    setState(() {
      _bounceScale = 1.07;
      for (int i = 0; i < 10; i++) {
        final double angle = random.nextDouble() * 2 * math.pi;
        final double speed = 40.0 + random.nextDouble() * 80.0;
        final Color color =
            config.particlePalette[i % config.particlePalette.length];
        _burstParticles.add(
          _TapBurstParticle(
            position: localPos,
            angle: angle,
            speed: speed,
            color: color,
            size: 4.0 + random.nextDouble() * 4.0,
            startTime: _elapsed.value,
          ),
        );
      }
    });

    // Reset bounce scale smoothly
    Future<void>.delayed(const Duration(milliseconds: 160), () {
      if (mounted) {
        setState(() {
          _bounceScale = 1.0;
        });
      }
    });
  }

  String _viEn(BuildContext context, String vi, String en) =>
      AuthLocaleText(context).viEn(vi, en);

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    Widget buildWithTheme(ThemeDefinition activeTheme) {
      _initParticles(activeTheme);
      _syncTickerState();
      final config = _NurtureThemeConfig.fromTheme(activeTheme);
      final bool reduceMotion =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      final bool isFxActive = _resolveIsFxActive() && !reduceMotion;

      return Semantics(
        label: _viEn(
          context,
          '${widget.days} ngày bên nhau · Đang được nuôi dưỡng',
          '${widget.days} days together · Nurtured',
        ),
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => _handleTapDown(details, config),
          child: AnimatedScale(
            scale: _bounceScale,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: <Widget>[
                // Background Breathing Aura & Floating Ambient Spores
                if (isFxActive)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: ValueListenableBuilder<Duration>(
                          valueListenable: _elapsed,
                          builder: (context, elapsed, _) {
                            return CustomPaint(
                              painter: _ThemedNurturePainter(
                                config: config,
                                particles: _particles,
                                burstParticles: _burstParticles,
                                elapsed: elapsed,
                                themeId: activeTheme.id,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                // Core Counter Content (Maintains strict test contract)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ShaderMask(
                        key: const Key('home_days_counter'),
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (Rect bounds) =>
                            colors.gradientDream.createShader(bounds),
                        child: Text(
                          '${widget.days}',
                          style: type.display.copyWith(
                            fontSize: _daysCountFontSize,
                            fontWeight: FontWeight.w900,
                            height: 0.92,
                            letterSpacing: -2.64,
                            color: colors.colorText,
                          ),
                        ),
                      ),
                      const SizedBox(width: _daysRowGap),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: _daysUnitBaselineLift,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              _viEn(context, 'ngày bên nhau', 'days together'),
                              style: type.display.copyWith(
                                fontSize: _daysUnitFontSize,
                                fontWeight: FontWeight.w800,
                                color: colors.colorTextMuted,
                              ),
                            ),
                            const SizedBox(width: _growthBadgeGap),
                            // Micro living pulse dot indicator
                            if (isFxActive)
                              ValueListenableBuilder<Duration>(
                                valueListenable: _elapsed,
                                builder: (context, elapsed, _) {
                                  return _LivingNurtureBadge(
                                    color: config.accentGlow,
                                    elapsed: elapsed,
                                    reduceMotion: reduceMotion,
                                  );
                                },
                              )
                            else
                              _LivingNurtureBadge(
                                color: config.accentGlow,
                                elapsed: Duration.zero,
                                reduceMotion: true,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (widget.themeOverride != null) {
      return buildWithTheme(widget.themeOverride!);
    }

    if (getIt.isRegistered<ThemeCubit>()) {
      return BlocBuilder<ThemeCubit, ThemeState>(
        bloc: getIt<ThemeCubit>(),
        builder: (context, state) => buildWithTheme(state.activeTheme),
      );
    }

    return buildWithTheme(cupidThemeCatalog.first);
  }
}

/// Subtle glowing micro-badge representing the living state.
class _LivingNurtureBadge extends StatelessWidget {
  const _LivingNurtureBadge({
    required this.color,
    required this.elapsed,
    required this.reduceMotion,
  });

  final Color color;
  final Duration elapsed;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final double pulse = reduceMotion
        ? 1.0
        : (math.sin(elapsed.inMilliseconds * 2 * math.pi / 2800) + 1.0) / 2.0;
    final double opacity = 0.55 + pulse * 0.45;
    final double size = _growthBadgeSize + pulse * 1.5;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: opacity * 0.7),
            blurRadius: 6.0 + pulse * 4.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the breathing aura, theme-specific spores, and tap bursts.
class _ThemedNurturePainter extends CustomPainter {
  _ThemedNurturePainter({
    required this.config,
    required this.particles,
    required this.burstParticles,
    required this.elapsed,
    required this.themeId,
  });

  final _NurtureThemeConfig config;
  final List<_NurtureParticle> particles;
  final List<_TapBurstParticle> burstParticles;
  final Duration elapsed;
  final String themeId;

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    if (width <= 0 || height <= 0) return;

    final int elapsedMs = elapsed.inMilliseconds;

    // 1. Paint Living Breathing Aura behind the number
    final double auraPhase =
        (math.sin(elapsedMs * 2 * math.pi / 3200) + 1.0) / 2.0;
    final double auraRadius = config.auraRadius * (0.88 + 0.22 * auraPhase);
    final double auraAlpha = 0.18 + 0.14 * auraPhase;

    final Offset center = Offset(width * 0.25, height * 0.55);
    final Rect auraRect = Rect.fromCircle(center: center, radius: auraRadius);

    final Paint auraPaint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          config.auraPalette[0].withValues(alpha: auraAlpha),
          config.auraPalette.length > 1
              ? config.auraPalette[1].withValues(alpha: auraAlpha * 0.5)
              : config.auraPalette[0].withValues(alpha: auraAlpha * 0.3),
          config.auraPalette[0].withValues(alpha: 0.0),
        ],
        stops: const <double>[0.0, 0.55, 1.0],
      ).createShader(auraRect);

    canvas.drawCircle(center, auraRadius, auraPaint);

    // 2. Paint Ambient Floating Spores / Theme Particles
    for (final p in particles) {
      final int pElapsed = elapsedMs + p.phaseOffsetMs;
      final double progress = (pElapsed * 0.0003 * p.speed) % 1.0;
      final double sway = math.sin(pElapsed * 0.002 * p.swayFreq) * 16.0;

      // Wrap-around coordinates relative to text area
      final double px = (p.originX * width + sway) % (width + 30) - 15;
      final double py = (height + 15) - progress * (height + 30);

      // Fade in bottom, bright middle, fade out top
      final double fade = math.sin(progress * math.pi);
      final double alpha = (fade * 0.85).clamp(0.0, 1.0);

      final Paint pPaint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      _drawParticleShape(
        canvas,
        Offset(px, py),
        p.size,
        config.particleShape,
        pPaint,
        pElapsed,
      );
    }

    // 3. Paint Tap-to-Nurture Burst Particles
    for (final bp in burstParticles) {
      final int ageMs = (elapsed - bp.startTime).inMilliseconds;
      if (ageMs < 0 || ageMs > 900) continue;

      final double t = (ageMs / 900.0).clamp(0.0, 1.0);
      final double easedDist = Curves.easeOutCubic.transform(t) * bp.speed;
      final double alpha = (1.0 - t).clamp(0.0, 1.0);

      final double bx = bp.position.dx + math.cos(bp.angle) * easedDist;
      final double by = bp.position.dy + math.sin(bp.angle) * easedDist;

      final Paint bPaint = Paint()
        ..color = bp.color.withValues(alpha: alpha * 0.9)
        ..style = PaintingStyle.fill;

      _drawParticleShape(
        canvas,
        Offset(bx, by),
        bp.size * (1.0 - t * 0.4),
        config.particleShape,
        bPaint,
        elapsedMs,
      );
    }
  }

  void _drawParticleShape(
    Canvas canvas,
    Offset offset,
    double size,
    String shape,
    Paint paint,
    int elapsedMs,
  ) {
    switch (shape) {
      case 'star':
        _drawStar(canvas, offset, size, paint);
        break;
      case 'petal':
        final double rotation = (elapsedMs * 0.001) % (2 * math.pi);
        _drawPetal(canvas, offset, size * 1.3, rotation, paint);
        break;
      case 'bokeh':
      case 'bubble':
        _drawBubble(canvas, offset, size, paint);
        break;
      case 'spark':
        final double angle = (elapsedMs * 0.002) % (2 * math.pi);
        _drawSpark(canvas, offset, size * 2.0, angle, paint);
        break;
      case 'firefly':
      case 'dew':
      default:
        canvas.drawCircle(offset, size / 2, paint);
        break;
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final Path path = Path();
    final double half = size / 2;

    path.moveTo(center.dx, center.dy - half);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + half, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + half);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - half, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - half);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawPetal(
    Canvas canvas,
    Offset center,
    double size,
    double rotation,
    Paint paint,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final Path path = Path();
    path.moveTo(0, -size / 2);
    path.quadraticBezierTo(size / 2.2, 0, 0, size / 2);
    path.quadraticBezierTo(-size / 2.2, 0, 0, -size / 2);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawBubble(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawCircle(center, size / 2, paint);
    final Paint highlight = Paint()
      ..color = paint.color.withValues(alpha: (paint.color.a * 0.6).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx - size / 5, center.dy - size / 5),
      size / 6,
      highlight,
    );
  }

  void _drawSpark(
    Canvas canvas,
    Offset center,
    double length,
    double angle,
    Paint paint,
  ) {
    final Paint linePaint = Paint()
      ..color = paint.color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final Offset end = Offset(
      center.dx + math.cos(angle) * length,
      center.dy + math.sin(angle) * length,
    );
    canvas.drawLine(center, end, linePaint);
  }

  @override
  bool shouldRepaint(_ThemedNurturePainter oldDelegate) => true;
}
