import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../chat_strings.dart';
import '../ghost_cubit.dart' show ghostBubbleFadeDuration;

// Off-scale metrics transcribed verbatim from the locked design source
// (`cupid-app-design-system/project/Cupid Screens.dc.html`, `isChat` block,
// `showGhostBubble` branch). They do not map onto the 8pt `CupidSpacing`
// scale or the `body`/`caption` type roles, so they are pinned here.
const double _maxWidthFactor = 0.84;
const double _headerIconSize = 13;
const double _headerGap = 5;
const double _headerFontSize = 10;
const double _headerToBubbleGap = 5;
const double _bubblePaddingX = 15;
const double _bubblePaddingY = 12;
const double _bubbleFontSize = 15.5;
const double _bubbleLineHeight = 1.5;
const double _struckLeftGap = 7;

/// `@keyframes ghostFade{from{opacity:.95}to{opacity:.45}}`, played over
/// `ghostBubbleFadeDuration` (1.3s) with `ease-out`.
const double _ghostFadeFrom = 0.95;
const double _ghostFadeTo = 0.45;

/// `text-decoration-color:rgba(180,166,206,.85)` — the dark-theme
/// `colorGhost` value at 85% alpha, so it is derived from the token rather
/// than pinned, and follows the light theme's ghost hue too.
const double _struckLineAlpha = 0.85;

const BorderRadius _ghostRadius = BorderRadius.only(
  topLeft: Radius.circular(22),
  topRight: Radius.circular(22),
  bottomRight: Radius.circular(22),
  bottomLeft: Radius.circular(7),
);

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
    required this.partnerDisplayName,
  });

  /// Drives the `"<name> đang nghĩ…"` header above the bubble. `null` hides
  /// the header rather than inventing a placeholder name.
  final String? partnerDisplayName;

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
              maxWidth: MediaQuery.sizeOf(context).width * _maxWidthFactor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.partnerDisplayName != null) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.blur_on, size: _headerIconSize, color: purple),
                      const SizedBox(width: _headerGap),
                      Flexible(
                        child: Text(
                          ChatStrings.ghostBubbleHeader(
                            context,
                            widget.partnerDisplayName!,
                          ),
                          style: type.caption.copyWith(
                            fontSize: _headerFontSize,
                            fontWeight: FontWeight.w800,
                            letterSpacing: _headerFontSize * 0.04,
                            color: purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: _headerToBubbleGap),
                ],
                CustomPaint(
                  painter: _DashedRRectBorderPainter(
                    color: purple.withValues(alpha: 0.6),
                    radius: _ghostRadius,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _bubblePaddingX,
                      vertical: _bubblePaddingY,
                    ),
                    decoration: BoxDecoration(
                      color: purple.withValues(alpha: 0.12),
                      borderRadius: _ghostRadius,
                    ),
                    child: Text.rich(
                      TextSpan(
                        style: type.body.copyWith(
                          fontSize: _bubbleFontSize,
                          height: _bubbleLineHeight,
                          color: colors.colorText,
                        ),
                        children: [
                          TextSpan(text: widget.keptContent),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: FadeTransition(
                              opacity: _cursorController,
                              child: Text(
                                '▌',
                                style: type.body.copyWith(
                                  fontSize: _bubbleFontSize,
                                  color: colors.colorAccentPink,
                                ),
                              ),
                            ),
                          ),
                          if (widget.struckContent.isNotEmpty)
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: TweenAnimationBuilder<double>(
                                key: ValueKey(widget.struckContent),
                                tween: Tween<double>(
                                  begin: _ghostFadeFrom,
                                  end: _ghostFadeTo,
                                ),
                                duration: ghostBubbleFadeDuration,
                                curve: Curves.easeOut,
                                builder: (context, opacity, child) => Opacity(
                                  opacity: opacity,
                                  child: child,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: _struckLeftGap,
                                  ),
                                  child: Text(
                                    widget.struckContent,
                                    style: type.body.copyWith(
                                      fontSize: _bubbleFontSize,
                                      height: _bubbleLineHeight,
                                      color: colors.colorGhost,
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: colors.colorGhost
                                          .withValues(alpha: _struckLineAlpha),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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

  static const double _strokeWidth = 1;
  static const double _dashWidth = 4;
  static const double _dashGap = 3;

  final Color color;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = radius.toRRect(Offset.zero & size);
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
