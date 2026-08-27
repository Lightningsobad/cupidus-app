import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

const Color _transparent = Color.fromARGB(0, 0, 0, 0);

class ContractSigningDialog extends StatelessWidget {
  const ContractSigningDialog({
    super.key,
    required this.contractId,
    required this.clauses,
    required this.onSign,
    required this.onDismiss,
  });

  final String contractId;
  final List<String> clauses;
  final VoidCallback onSign;
  final VoidCallback onDismiss;

  static Future<void> show(
    BuildContext context, {
    required String contractId,
    required List<String> clauses,
    required VoidCallback onSign,
    required VoidCallback onDismiss,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ContractSigningDialog(
        contractId: contractId,
        clauses: clauses,
        onSign: () {
          Navigator.of(ctx).pop();
          onSign();
        },
        onDismiss: () {
          Navigator.of(ctx).pop();
          onDismiss();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.cupidColors;

    return Dialog(
      backgroundColor: _transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.colorSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colors.colorAccentPurple.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.colorBackground.withValues(alpha: 0.6),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: colors.colorAccentPurple.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.colorAccentPurple.withValues(alpha: 0.2),
                border: Border.all(
                  color: colors.colorAccentPurple.withValues(alpha: 0.4),
                ),
              ),
              alignment: Alignment.center,
              child: const Text('📜', style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 18),
            Text(
              'Hợp Đồng Tình Yêu Chờ Ký',
              style: TextStyle(
                color: colors.colorText,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Bae vừa soạn một bản Hợp Đồng Tình Yêu gồm ${clauses.length} điều khoản. Hãy xem và đặt bút ký ngay nhé!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.colorTextMuted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (clauses.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                constraints: const BoxConstraints(maxHeight: 120),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.colorSurfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.colorLine),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: clauses.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      '• ${clauses[index]}',
                      style: TextStyle(color: colors.colorTextMuted, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.colorTextMuted,
                      side: BorderSide(color: colors.colorLine),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Để sau'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: colors.gradientHot,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: colors.colorAccentPink.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onSign,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _transparent,
                        foregroundColor: colors.colorOnAccent,
                        shadowColor: _transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Ký Ngay ✍️',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
