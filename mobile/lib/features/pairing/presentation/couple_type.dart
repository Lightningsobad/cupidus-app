import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/widgets.dart';

/// Couple-type glyphs whose codepoints were read from the bundled
/// `MaterialSymbolsRounded-Variable.ttf` cmap with `fontTools`
/// (`coding-plan/test-results.md`), never from memory. Declared here rather
/// than as `CupidIcons` members because `design_system/` is outside this
/// story's write scope, mirroring `screens/invite_screen.dart`'s own
/// `_iosShareIcon`/`_contentCopyIcon`; promote them once it is in scope.
const IconData _locationCityIcon = IconData(
  0xe7f1,
  fontFamily: CupidIcons.fontFamily,
);
const IconData _autoAwesomeIcon = IconData(
  0xe65f,
  fontFamily: CupidIcons.fontFamily,
);
const IconData _allInclusiveIcon = IconData(
  0xeb3d,
  fontFamily: CupidIcons.fontFamily,
);

/// The 4 couple-type cards in the order they are rendered
/// (`ux/uiux-spec.md` §6.7 grid order: 1,2 top row; 3,4 bottom row).
///
/// [wireValue] is the only place the backend's closed `CoupleType` enum
/// literals exist on the mobile side (`architecture/contract-summary.md`
/// section 2) — a mismatch is a runtime `400`, not a build error.
enum CoupleType {
  longDistance(
    wireValue: 'LONG_DISTANCE',
    icon: CupidIcons.flightTakeoff,
    labelVi: 'Yêu xa',
    labelEn: 'Long-distance',
    subtextVi: 'Tụi mình đang ở hai nơi khác nhau',
    subtextEn: "We're in different places",
  ),
  sameCity(
    wireValue: 'SAME_CITY',
    icon: _locationCityIcon,
    labelVi: 'Cùng thành phố',
    labelEn: 'Same city',
    subtextVi: 'Tụi mình ở cùng một thành phố',
    subtextEn: 'We live in the same city',
  ),
  dating(
    wireValue: 'DATING',
    icon: _autoAwesomeIcon,
    labelVi: 'Mới hẹn hò',
    labelEn: 'Just started dating',
    subtextVi: 'Tụi mình mới bắt đầu tìm hiểu nhau',
    subtextEn: 'We just started getting to know each other',
  ),

  /// The backend enum is closed at 4 values and carries no `LONG_TERM`, so the
  /// "Gắn bó lâu dài" card maps to the one remaining slot
  /// (`architecture/contract-summary.md` section 2 — accepted drift, not an
  /// oversight).
  livingTogether(
    wireValue: 'LIVING_TOGETHER',
    icon: _allInclusiveIcon,
    labelVi: 'Gắn bó lâu dài',
    labelEn: 'Long-term',
    subtextVi: 'Tụi mình đã gắn bó với nhau lâu rồi',
    subtextEn: "We've been together for a while",
  );

  const CoupleType({
    required this.wireValue,
    required this.icon,
    required this.labelVi,
    required this.labelEn,
    required this.subtextVi,
    required this.subtextEn,
  });

  final String wireValue;
  final IconData icon;
  final String labelVi;
  final String labelEn;
  final String subtextVi;
  final String subtextEn;
}

/// Unknown or absent inbound values parse to `null` (no card pre-selected)
/// rather than throwing: a profile can carry a legacy value this build does
/// not know (`architecture/contract-summary.md` section 2).
CoupleType? coupleTypeFromWire(String? value) {
  if (value == null) return null;
  for (final CoupleType coupleType in CoupleType.values) {
    if (coupleType.wireValue == value) return coupleType;
  }
  return null;
}
