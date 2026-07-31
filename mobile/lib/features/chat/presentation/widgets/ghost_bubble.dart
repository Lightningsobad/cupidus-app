import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../chat_strings.dart';
import '../ghost_cubit.dart' show ghostBubbleFadeDuration;

/// Renders the partner's live typing-ghost draft (`ux/uiux-spec.md` §3d).
/// Deliberately distinct from `message_bubble.dart` — dashed
/// `rgba(183,140,245,.6)` border, `rgba(183,140,245,.12)` fill, a
/// blinking-cursor character, and any deleted-but-typed tail rendered
/// struck-through in `--ghost` with a fade to 45% opacity. This is the core
/// "see what they deleted" mechanic; never simplify to a plain "…is typing"
/// indicator.
class GhostBubble extends StatefulWidget {
  const GhostBubble({
    super.key,
    required this.keptContent,
    required this.struckContent,
  });

  /// The partner's current draft with any deleted tail already removed.
  final String keptContent;

  /// The tail removed from the partner's previous draft since the last
  /// `ghostTyping`, already diffed by `GhostCubit` (receiver-side; the
  /// backend carries no deletion information).
  final String struckContent;

  @override
  State<GhostBubble> createState() => _GhostBubbleState();
}

class _GhostBubbleState extends State<GhostBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final Color purple = colors.colorAccentPurple;

    return Semantics(
      // Polite, not assertive — the partner's draft updates per keystroke,
      // and an assertive interruption on every change would be unusable
      // (`ux/uiux-spec.md` §8). `liveRegion` maps to a polite announcement;
      // meaningful transitions (ghost on/off, a full message arriving) are
      // announced separately at assertive priority by the screen that owns
      // those transitions, not by this per-keystroke bubble.
      liveRegion: true,
      label: ChatStrings.ghostPartnerDraftSemanticLabel(
        context,
        '${widget.keptContent}${widget.struckContent}',
      ),
      child: ExcludeSemantics(
        child: Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.78,
            ),
            child: CustomPaint(
              painter: _DashedRRectBorderPainter(
                color: purple.withValues(alpha: 0.6),
                radius: 22,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: CupidSpacing.md,
                  vertical: CupidSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text.rich(
                  TextSpan(
                    style: type.body.copyWith(color: colors.colorText),
                    children: [
                      TextSpan(text: widget.keptContent),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: FadeTransition(
                          opacity: _cursorController,
                          child: Text(
                            '▍',
                            style: type.body.copyWith(color: purple),
                          ),
                        ),
                      ),
                      if (widget.struckContent.isNotEmpty)
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: TweenAnimationBuilder<double>(
                            key: ValueKey(widget.struckContent),
                            tween: Tween<double>(begin: 1.0, end: 0.45),
                            duration: ghostBubbleFadeDuration,
                            builder: (context, opacity, child) => Opacity(
                              opacity: opacity,
                              child: child,
                            ),
                            child: Text(
                              widget.struckContent,
                              style: type.body.copyWith(
                                color: colors.colorGhost,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dashed rounded-rectangle border painter. No dashed-border package is a
/// project dependency (`mobile/pubspec.yaml`), so this is a small local
/// `CustomPainter` rather than a new dependency for one border style.
class _DashedRRectBorderPainter extends CustomPainter {
  const _DashedRRectBorderPainter({required this.color, required this.radius});

  static const double _strokeWidth = 1.5;
  static const double _dashWidth = 4;
  static const double _dashGap = 3;

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final Path path = Path()..addRRect(rrect);
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = distance + _dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + _dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectBorderPainter oldDelegate) =>
      color != oldDelegate.color || radius != oldDelegate.radius;
}
