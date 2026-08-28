import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../chat_strings.dart';

/// Compact, refined chat header presence affordance: a glowing pulsing online dot
/// and the localized online status label.
class PartnerPresenceChip extends StatelessWidget {
  const PartnerPresenceChip({super.key, required this.partnerDisplayName});

  final String partnerDisplayName;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Semantics(
      container: true,
      label: ChatStrings.presenceChipSemanticLabel(
        context: context,
        partnerDisplayName: partnerDisplayName,
      ),
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colors.colorSurface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: colors.colorGreen.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _PulsingOnlineDot(color: colors.colorGreen),
              const SizedBox(width: 5),
              Text(
                ChatStrings.presenceChipStatus(context),
                style: type.caption.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: colors.colorGreen,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingOnlineDot extends StatefulWidget {
  const _PulsingOnlineDot({required this.color});

  final Color color;

  @override
  State<_PulsingOnlineDot> createState() => _PulsingOnlineDotState();
}

class _PulsingOnlineDotState extends State<_PulsingOnlineDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void disposeValidate() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _animation.value * 0.6),
                blurRadius: 4 * _animation.value,
                spreadRadius: 1 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

