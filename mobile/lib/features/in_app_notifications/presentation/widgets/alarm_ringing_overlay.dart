import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color _transparent = Color.fromARGB(0, 0, 0, 0);

class AlarmRingingOverlay {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onDismiss,
    OverlayState? overlay,
  }) {
    _currentEntry?.remove();
    _currentEntry = null;

    HapticFeedback.heavyImpact();

    final overlayState = overlay ??
        Overlay.maybeOf(context, rootOverlay: true) ??
        Overlay.maybeOf(context);
    if (overlayState == null) return;
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _AlarmRingingWidget(
        title: title,
        message: message,
        onDismiss: () {
          entry.remove();
          if (_currentEntry == entry) _currentEntry = null;
          onDismiss();
        },
      ),
    );

    _currentEntry = entry;
    overlayState.insert(entry);
  }
}

class _AlarmRingingWidget extends StatefulWidget {
  const _AlarmRingingWidget({
    required this.title,
    required this.message,
    required this.onDismiss,
  });

  final String title;
  final String message;
  final VoidCallback onDismiss;

  @override
  State<_AlarmRingingWidget> createState() => _AlarmRingingWidgetState();
}

class _AlarmRingingWidgetState extends State<_AlarmRingingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Continuous haptics for ringing effect
    _triggerPeriodicHaptics();
  }

  void _triggerPeriodicHaptics() async {
    while (mounted) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) break;
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.cupidColors;

    return Material(
      color: colors.colorBackground.withValues(alpha: 0.94),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: colors.gradientHot,
                    boxShadow: [
                      BoxShadow(
                        color: colors.colorAccentPink.withValues(alpha: 0.6),
                        blurRadius: 36,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.alarm_on_rounded,
                    color: colors.colorOnAccent,
                    size: 64,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.colorText,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.colorTextMuted,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: colors.gradientHot,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: colors.colorAccentPink.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: widget.onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _transparent,
                    foregroundColor: colors.colorOnAccent,
                    shadowColor: _transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'DẬY NÀO BAE! (TẮT BÁO THỨC)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
