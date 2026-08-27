import 'dart:async';
import 'dart:math';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmojiStormOverlay {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required String penalty,
    OverlayState? overlay,
  }) {
    _currentEntry?.remove();
    _currentEntry = null;

    final overlayState = overlay ??
        Overlay.maybeOf(context, rootOverlay: true) ??
        Overlay.maybeOf(context);
    if (overlayState == null) return;
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _EmojiStormWidget(
        penalty: penalty,
        onFinished: () {
          entry.remove();
          if (_currentEntry == entry) _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    overlayState.insert(entry);
  }
}

class _EmojiStormWidget extends StatefulWidget {
  const _EmojiStormWidget({
    required this.penalty,
    required this.onFinished,
  });

  final String penalty;
  final VoidCallback onFinished;

  @override
  State<_EmojiStormWidget> createState() => _EmojiStormWidgetState();
}

class _EmojiStormWidgetState extends State<_EmojiStormWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_StormParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _generateParticles();

    _controller.forward().then((_) {
      if (mounted) {
        widget.onFinished();
      }
    });

    _triggerVibrations();
  }

  void _generateParticles() {
    final emojis = ['👻', '⚡️', '💔', '😡', '💥', '👀', '⏳', '🔥'];
    for (int i = 0; i < 45; i++) {
      _particles.add(_StormParticle(
        emoji: emojis[_random.nextInt(emojis.length)],
        startX: _random.nextDouble(),
        startY: -0.1 - _random.nextDouble() * 0.4,
        speed: 0.8 + _random.nextDouble() * 1.2,
        size: 28.0 + _random.nextDouble() * 24.0,
        rotationSpeed: (_random.nextDouble() - 0.5) * 6,
        horizontalSway: (_random.nextDouble() - 0.5) * 0.15,
      ));
    }
  }

  final List<Timer> _timers = [];

  void _triggerVibrations() {
    _timers.add(Timer(const Duration(milliseconds: 100), () => HapticFeedback.mediumImpact()));
    _timers.add(Timer(const Duration(milliseconds: 350), () => HapticFeedback.heavyImpact()));
    _timers.add(Timer(const Duration(milliseconds: 700), () => HapticFeedback.mediumImpact()));
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.cupidColors;
    final size = MediaQuery.of(context).size;

    return Material(
      color: colors.colorBackground.withValues(alpha: 0.6),
      child: Stack(
        children: [
          // Flashing warning text
          Positioned(
            top: 100,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: colors.colorSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.colorRed, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: colors.colorRed.withValues(alpha: 0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '⚠️ BÃO EMOJI ĐANG DỘI XUỐNG! ⚠️',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.colorRed,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hình phạt Anti-Ghosting đã được kích hoạt!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.colorTextMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Rain of particles
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = _controller.value;

              return Stack(
                children: _particles.map((particle) {
                  final currentY = (particle.startY + progress * particle.speed * 1.5) * size.height;
                  final currentX = (particle.startX + sin(progress * 10) * particle.horizontalSway) * size.width;
                  final rotation = progress * particle.rotationSpeed * pi;

                  if (currentY > size.height + 50 || currentY < -50) {
                    return const SizedBox.shrink();
                  }

                  return Positioned(
                    left: currentX,
                    top: currentY,
                    child: Transform.rotate(
                      angle: rotation,
                      child: Text(
                        particle.emoji,
                        style: TextStyle(fontSize: particle.size),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StormParticle {
  _StormParticle({
    required this.emoji,
    required this.startX,
    required this.startY,
    required this.speed,
    required this.size,
    required this.rotationSpeed,
    required this.horizontalSway,
  });

  final String emoji;
  final double startX;
  final double startY;
  final double speed;
  final double size;
  final double rotationSpeed;
  final double horizontalSway;
}
