import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

const Color _transparent = Color.fromARGB(0, 0, 0, 0);

class ThemeRequestDialog extends StatelessWidget {
  const ThemeRequestDialog({
    super.key,
    required this.themeName,
    required this.themeId,
    required this.price,
    required this.onApprove,
    required this.onReject,
  });

  final String themeName;
  final String themeId;
  final int price;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  static Future<void> show(
    BuildContext context, {
    required String themeName,
    required String themeId,
    required int price,
    required VoidCallback onApprove,
    required VoidCallback onReject,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ThemeRequestDialog(
        themeName: themeName,
        themeId: themeId,
        price: price,
        onApprove: () {
          Navigator.of(ctx).pop();
          onApprove();
        },
        onReject: () {
          Navigator.of(ctx).pop();
          onReject();
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
            color: colors.colorAccentPink.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.colorBackground.withValues(alpha: 0.6),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: colors.colorAccentPink.withValues(alpha: 0.15),
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
                color: colors.colorAccentPink.withValues(alpha: 0.2),
                border: Border.all(
                  color: colors.colorAccentPink.withValues(alpha: 0.4),
                ),
              ),
              alignment: Alignment.center,
              child: const Text('🎨', style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 18),
            Text(
              'Đề Xuất Đổi Giao Diện',
              style: TextStyle(
                color: colors.colorText,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Bae muốn đổi sang giao diện "$themeName"${price > 0 ? " (Chi phí: $price 💕)" : ""}. Bạn có đồng ý không?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.colorTextMuted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
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
                      onPressed: onApprove,
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
                        'Đồng ý ngay',
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
