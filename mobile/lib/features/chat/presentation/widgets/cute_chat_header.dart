import 'package:flutter/material.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import '../chat_strings.dart';
import 'partner_presence_chip.dart';

/// Charming Chat Header for couples with pulsing heart, sweet presence chip,
/// and adaptive platform silhouettes.
class CuteChatHeader extends StatefulWidget implements PreferredSizeWidget {
  const CuteChatHeader({
    super.key,
    required this.selfDisplayName,
    required this.partnerDisplayName,
    this.onBack,
  });

  final String? selfDisplayName;
  final String? partnerDisplayName;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CuteChatHeader> createState() => _CuteChatHeaderState();
}

class _CuteChatHeaderState extends State<CuteChatHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.14).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? partnerName = widget.partnerDisplayName;
    final String? selfName = widget.selfDisplayName;
    final String titleText = ChatStrings.headerPairingTitle(
      selfDisplayName: selfName,
      partnerDisplayName: partnerName,
    );
    final String titleSemanticLabel = ChatStrings.headerPairingSemanticLabel(
      context: context,
      selfDisplayName: selfName,
      partnerDisplayName: partnerName,
    );

    return CupidHeader(
      title: titleText,
      titleSemanticLabel:
          titleSemanticLabel.isEmpty ? null : titleSemanticLabel,
      onBack: widget.onBack,
      trailing: partnerName == null || partnerName.isEmpty
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: const Text('💕', style: TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 4),
                PartnerPresenceChip(partnerDisplayName: partnerName),
              ],
            ),
    );
  }
}
