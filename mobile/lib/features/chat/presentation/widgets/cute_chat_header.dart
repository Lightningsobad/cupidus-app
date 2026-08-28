import 'package:flutter/material.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import '../chat_strings.dart';
import 'partner_presence_chip.dart';

/// Charming Chat Header for couples with refined presence chip and adaptive platform silhouettes.
class CuteChatHeader extends StatelessWidget implements PreferredSizeWidget {
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
  Widget build(BuildContext context) {
    final String? partnerName = partnerDisplayName;
    final String? selfName = selfDisplayName;
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
      onBack: onBack,
      trailing: partnerName == null || partnerName.isEmpty
          ? null
          : PartnerPresenceChip(partnerDisplayName: partnerName),
    );
  }
}

