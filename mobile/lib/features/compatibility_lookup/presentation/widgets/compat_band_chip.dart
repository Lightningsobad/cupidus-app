import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../domain/compat_content.dart';

/// The DẢI value, drawn as a static text pill and nothing else.
///
/// The constructor takes a [CompatBand] and no second parameter on purpose.
/// There is deliberately no `double`, no `index`, no `rank`, no `level` and no
/// `gradient`: any of those would let the eye read a position on a continuous
/// axis, which is exactly what AC-32 forbids (`ux/uiux-spec.md` section 3.1 —
/// "nếu component có thể trả lời câu 'cái này đầy bao nhiêu phần?', nó SAI").
///
/// Every band renders with the same surface, border, radius and type. The
/// phase allows a discrete `band.id -> colour` map, but the band vocabulary
/// ships inside the content package rather than in Dart, so a map here would
/// either be incomplete or have to fall back to an ordering — one uniform
/// style is the only variant that cannot encode a scale.
class CompatBandChip extends StatelessWidget {
  const CompatBandChip({super.key, required this.band});

  final CompatBand band;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final AppL10n l10n = AppL10n.of(context);

    return Semantics(
      label: l10n.compat_band_chip_semantics(band.label),
      excludeSemantics: true,
      child: DecoratedBox(
        key: const Key('compat_band_chip'),
        decoration: BoxDecoration(
          color: colors.colorSurfaceAlt,
          borderRadius: BorderRadius.circular(platform.radiusSmall),
          border: Border.all(color: colors.colorLine),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CupidSpacing.md,
            vertical: CupidSpacing.sm,
          ),
          child: Text(
            band.label,
            style: type.body.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.colorText,
            ),
          ),
        ),
      ),
    );
  }
}
