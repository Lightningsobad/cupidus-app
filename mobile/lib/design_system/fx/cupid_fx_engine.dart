import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../tokens/theme_catalog.dart';

/// Single particle internal state simulated by [CupidFxPainter].
class _SimulatedParticle {
  _SimulatedParticle({
    required this.initialNormalizedX,
    required this.initialNormalizedY,
    required this.size,
    required this.speed,
    required this.color,
    required this.swayAmplitude,
    required this.swayFrequency,
    required this.twinklePeriodMs,
    required this.phaseOffsetMs,
    required this.shape,
  });

  final double initialNormalizedX;
  final double initialNormalizedY;
  final double size;
  final double speed;
  final Color color;
  final double swayAmplitude;
  final double swayFrequency;
  final int twinklePeriodMs;
  final int phaseOffsetMs;
  final String shape;
}

/// Touch ripple/spark event state.
class _TouchEffectPoint {
  _TouchEffectPoint({
    required this.position,
    required this.startTime,
    required this.color,
    required this.type,
    required this.durationMs,
  });

  final Offset position;
  final Duration startTime;
  final Color color;
  final String type;
  final int durationMs;
}

/// Declarative Dynamic FX Engine for rendering rich theme particles, meteors & interactive touch reactions.
class CupidFxOverlay extends StatefulWidget {
  const CupidFxOverlay({
    super.key,
    required this.fxConfig,
    required this.elapsed,
    this.isEnabled = true,
  });

  final ThemeFXConfig? fxConfig;
  final ValueListenable<Duration> elapsed;
  final bool isEnabled;

  @override
  State<CupidFxOverlay> createState() => _CupidFxOverlayState();
}

class _CupidFxOverlayState extends State<CupidFxOverlay> {
  List<_SimulatedParticle> _particles = <_SimulatedParticle>[];
  final List<_TouchEffectPoint> _touchPoints = <_TouchEffectPoint>[];
  String? _lastConfigType;

  @override
  void initState() {
    super.initState();
    _initParticles();
  }

  @override
  void didUpdateWidget(CupidFxOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fxConfig?.type != widget.fxConfig?.type ||
        oldWidget.fxConfig?.particles.count != widget.fxConfig?.particles.count) {
      _initParticles();
    }
  }

  void _initParticles() {
    final fx = widget.fxConfig;
    if (fx == null || !fx.particles.enabled) {
      _particles = <_SimulatedParticle>[];
      _lastConfigType = fx?.type;
      return;
    }

    final pConfig = fx.particles;
    final random = math.Random(fx.type.hashCode);
    final count = pConfig.count.clamp(1, 40);
    final colors = pConfig.colors.isNotEmpty
        ? pConfig.colors
        : <Color>[const Color(0xFFFFFFFF)];

    _particles = List<_SimulatedParticle>.generate(count, (index) {
      final size = pConfig.minSize +
          random.nextDouble() * (pConfig.maxSize - pConfig.minSize);
      final speed = pConfig.minSpeed +
          random.nextDouble() * (pConfig.maxSpeed - pConfig.minSpeed);
      final color = colors[index % colors.length];
      final phaseOffsetMs = random.nextInt(8000);
      final swayFreq = 0.5 + random.nextDouble() * 1.5;

      return _SimulatedParticle(
        initialNormalizedX: random.nextDouble(),
        initialNormalizedY: random.nextDouble(),
        size: size,
        speed: speed,
        color: color,
        swayAmplitude: pConfig.swayAmplitude,
        swayFrequency: swayFreq,
        twinklePeriodMs: pConfig.twinklePeriodMs,
        phaseOffsetMs: phaseOffsetMs,
        shape: pConfig.shape,
      );
    });

    _lastConfigType = fx.type;
  }

  void _handlePointerDown(PointerDownEvent event, Duration elapsed) {
    if (!widget.isEnabled || widget.fxConfig == null) return;
    final touchCfg = widget.fxConfig!.touchReaction;

    setState(() {
      _touchPoints.add(
        _TouchEffectPoint(
          position: event.localPosition,
          startTime: elapsed,
          color: touchCfg.color,
          type: touchCfg.type,
          durationMs: touchCfg.durationMs,
        ),
      );
      // Clean up old touch points
      _touchPoints.removeWhere((tp) =>
          (elapsed - tp.startTime).inMilliseconds > tp.durationMs + 200);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled || widget.fxConfig == null) {
      return const SizedBox.shrink();
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) =>
          _handlePointerDown(event, widget.elapsed.value),
      child: IgnorePointer(
        ignoring: true,
        child: RepaintBoundary(
          child: ValueListenableBuilder<Duration>(
            valueListenable: widget.elapsed,
            builder: (context, elapsed, _) {
              return CustomPaint(
                size: Size.infinite,
                painter: CupidFxPainter(
                  fxConfig: widget.fxConfig!,
                  particles: _particles,
                  touchPoints: _touchPoints,
                  elapsed: elapsed,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Custom painter executing particle kinematics, shooting stars & touch ripples.
class CupidFxPainter extends CustomPainter {
  CupidFxPainter({
    required this.fxConfig,
    required this.particles,
    required this.touchPoints,
    required this.elapsed,
  });

  final ThemeFXConfig fxConfig;
  final List<_SimulatedParticle> particles;
  final List<_TouchEffectPoint> touchPoints;
  final Duration elapsed;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final pConfig = fxConfig.particles;
    final special = fxConfig.specialFX;

    // 1. Paint particles
    if (pConfig.enabled) {
      for (final p in particles) {
        _paintParticle(canvas, size, p, pConfig);
      }
    }

    // 2. Paint shooting stars if configured (Star Map)
    if (special.hasShootingStars) {
      _paintShootingStar(canvas, size, special.shootingStarIntervalMs);
    }

    // 3. Paint touch reaction ripples/embers/sparks
    _paintTouchReactions(canvas);
  }

  void _paintParticle(
    Canvas canvas,
    Size size,
    _SimulatedParticle p,
    ThemeParticleConfig pConfig,
  ) {
    final int elapsedMs = elapsed.inMilliseconds + p.phaseOffsetMs;
    final double dirDeg = pConfig.directionDegrees;
    final double dirRad = dirDeg * math.pi / 180.0;

    // Motion displacement
    final double totalTravel = (elapsedMs * 0.04 * p.speed);
    final double moveX = math.cos(dirRad) * totalTravel;
    final double moveY = math.sin(dirRad) * totalTravel;

    // Sway factor (sine wave)
    final double sway = p.swayAmplitude > 0
        ? math.sin(elapsedMs * 0.002 * p.swayFrequency) * p.swayAmplitude
        : 0.0;

    // Normalized wrap-around coords
    double px = (p.initialNormalizedX * size.width + moveX + sway) % (size.width + 40) - 20;
    double py = (p.initialNormalizedY * size.height + moveY) % (size.height + 40) - 20;

    if (px < -20) px += size.width + 40;
    if (py < -20) py += size.height + 40;

    // Twinkle opacity
    final double twinklePeriod = p.twinklePeriodMs > 0 ? p.twinklePeriodMs.toDouble() : 4000.0;
    final double phase = (math.sin(elapsedMs * 2 * math.pi / twinklePeriod) + 1.0) / 2.0;
    final double opacity = (pConfig.minOpacity +
            (pConfig.maxOpacity - pConfig.minOpacity) * phase)
        .clamp(0.0, 1.0);

    final Paint paint = Paint()
      ..color = p.color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    switch (p.shape) {
      case 'star':
        _drawStar(canvas, Offset(px, py), p.size * (0.85 + 0.3 * phase), paint);
        break;
      case 'petal':
        final double rotation = (elapsedMs * 0.001 * p.speed) % (2 * math.pi);
        _drawPetal(canvas, Offset(px, py), p.size, rotation, paint);
        break;
      case 'bokeh':
      case 'bubble':
        _drawBubble(canvas, Offset(px, py), p.size, paint);
        break;
      case 'spark':
        _drawSpark(canvas, Offset(px, py), p.size * 2.5, dirRad, paint);
        break;
      case 'snowflake':
      case 'snow':
        final double rotation = (elapsedMs * 0.0005 * p.speed) % (2 * math.pi);
        _drawSnowflake(canvas, Offset(px, py), p.size, rotation, paint);
        break;
      case 'firefly':
      case 'dew':
      default:
        canvas.drawCircle(Offset(px, py), p.size / 2, paint);
        break;
    }
  }

  void _drawSnowflake(
      Canvas canvas, Offset center, double size, double rotation, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final Paint linePaint = Paint()
      ..color = paint.color
      ..strokeWidth = math.max(1.0, size * 0.15)
      ..strokeCap = StrokeCap.round;

    final double half = size / 2;
    // 6 symmetrical arms
    for (int i = 0; i < 6; i++) {
      final double armAngle = i * math.pi / 3;
      final double cosA = math.cos(armAngle);
      final double sinA = math.sin(armAngle);

      final Offset end = Offset(cosA * half, sinA * half);
      canvas.drawLine(Offset.zero, end, linePaint);

      // Side branches for crystalline effect
      if (size > 4.5) {
        final double branchStart = half * 0.55;
        final double branchLen = half * 0.35;
        final Offset branchRoot = Offset(cosA * branchStart, sinA * branchStart);

        final double bAngle1 = armAngle + math.pi / 4;
        final double bAngle2 = armAngle - math.pi / 4;

        canvas.drawLine(
          branchRoot,
          Offset(branchRoot.dx + math.cos(bAngle1) * branchLen,
              branchRoot.dy + math.sin(bAngle1) * branchLen),
          linePaint,
        );
        canvas.drawLine(
          branchRoot,
          Offset(branchRoot.dx + math.cos(bAngle2) * branchLen,
              branchRoot.dy + math.sin(bAngle2) * branchLen),
          linePaint,
        );
      }
    }

    // Small glowing center
    canvas.drawCircle(Offset.zero, math.max(0.8, size * 0.18), paint);

    canvas.restore();
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final Path path = Path();
    final double half = size / 2;
    final double quarter = size / 4.5;

    path.moveTo(center.dx, center.dy - half);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + half, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + half);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - half, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - half);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawPetal(
      Canvas canvas, Offset center, double size, double rotation, Paint paint) {
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
    // Draw subtle inner highlight
    final Paint highlight = Paint()
      ..color = Colors.white.withValues(alpha: paint.color.a * 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(center.dx - size / 5, center.dy - size / 5), size / 6, highlight);
  }

  void _drawSpark(
      Canvas canvas, Offset center, double length, double angle, Paint paint) {
    final Paint linePaint = Paint()
      ..color = paint.color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final Offset end = Offset(
      center.dx + math.cos(angle) * length,
      center.dy + math.sin(angle) * length,
    );
    canvas.drawLine(center, end, linePaint);
  }

  void _paintShootingStar(Canvas canvas, Size size, int intervalMs) {
    final int cycle = elapsed.inMilliseconds % intervalMs;
    const int durationMs = 1200;

    if (cycle < durationMs) {
      final double t = cycle / durationMs;
      // Interpolate start from top-right to bottom-left
      final double startX = size.width * 0.95 - t * size.width * 0.75;
      final double startY = size.height * 0.06 + t * size.height * 0.35;
      final double tailLength = 90.0 * (1.0 - math.pow(t - 0.5, 2) * 4).clamp(0.0, 1.0);

      final double angle = math.atan2(size.height * 0.35, -size.width * 0.75);
      final Offset head = Offset(startX, startY);
      final Offset tail = Offset(
        startX - math.cos(angle) * tailLength,
        startY - math.sin(angle) * tailLength,
      );

      final Paint cometPaint = Paint()
        ..shader = LinearGradient(
          colors: <Color>[
            const Color(0xFFFFFFFF),
            const Color(0xFFFFE9A8).withValues(alpha: 0.6),
            const Color(0xFF9E8CF5).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromPoints(head, tail))
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(tail, head, cometPaint);
      canvas.drawCircle(
          head, 2.5, Paint()..color = const Color(0xFFFFFFFF));
    }
  }

  void _paintTouchReactions(Canvas canvas) {
    for (final tp in touchPoints) {
      final int ageMs = (elapsed - tp.startTime).inMilliseconds;
      if (ageMs < 0 || ageMs > tp.durationMs) continue;

      final double progress = (ageMs / tp.durationMs).clamp(0.0, 1.0);
      final double eased = Curves.easeOutCubic.transform(progress);
      final double opacity = (1.0 - progress).clamp(0.0, 1.0);

      final Paint ripplePaint = Paint()
        ..color = tp.color.withValues(alpha: opacity * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (3.0 * (1.0 - progress)).clamp(0.5, 3.0);

      final double radius = 10.0 + eased * 60.0;
      canvas.drawCircle(tp.position, radius, ripplePaint);

      // Inner flash
      if (progress < 0.4) {
        final double innerOpacity = (1.0 - progress / 0.4) * 0.5;
        canvas.drawCircle(
          tp.position,
          radius * 0.4,
          Paint()
            ..color = tp.color.withValues(alpha: innerOpacity)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CupidFxPainter oldDelegate) => true;
}
