import 'package:flutter/widgets.dart';

import '../../../design_system/icons/cupid_icons.dart';

/// The closed vocabulary for `activity_cards.activity_type`
/// (`architecture/contract-summary.md` §3). Wire values are ASCII, stable, and
/// append-only (R-15a); the shipped `occasions.v1.json` package is the only
/// producer, so a member may be added here only after the package carries it.
///
/// The field stays nullable everywhere: a card the user wrote themselves has
/// no type, and AC-6 makes `title` the single mandatory field. `null` means
/// "type not known", and is deliberately not an `other` member.
enum ActivityType {
  outing('outing'),
  home('home'),
  visit('visit'),
  dining('dining'),
  handmade('handmade'),
  walk('walk'),
  photo('photo'),
  gift('gift');

  const ActivityType(this.wireValue);

  final String wireValue;
}

/// Lenient read: an unrecognized string becomes `null` rather than throwing.
///
/// Installed devices hold rows written before this vocabulary existed, whose
/// `activity_type` is free text. Those rows must survive and lose only their
/// icon, so this never throws and is deliberately case-sensitive — the wire
/// value is the exact ASCII identifier, not a display label.
ActivityType? activityTypeFromWireValue(String? value) {
  if (value == null) {
    return null;
  }
  for (final ActivityType type in ActivityType.values) {
    if (type.wireValue == value) {
      return type;
    }
  }
  return null;
}

/// Leading glyph for line 2 of a card (`ux/uiux-spec.md` §2, delta D-5). A
/// `null` type still gets a neutral glyph so every card with a second line
/// carries a leading icon rather than starting ragged.
///
/// Total over [ActivityType] on purpose: adding a member is a compile error
/// here until it has a glyph, which is what keeps the map measurable instead
/// of scattering `switch` statements through the widget tree.
IconData activityTypeIcon(ActivityType? type) {
  if (type == null) {
    return CupidIcons.label;
  }
  switch (type) {
    case ActivityType.outing:
      return CupidIcons.localActivity;
    case ActivityType.home:
      return CupidIcons.home;
    case ActivityType.visit:
      return CupidIcons.groups;
    case ActivityType.dining:
      return CupidIcons.restaurant;
    case ActivityType.handmade:
      return CupidIcons.draw;
    case ActivityType.walk:
      return CupidIcons.directionsWalk;
    case ActivityType.photo:
      return CupidIcons.photoCamera;
    case ActivityType.gift:
      return CupidIcons.redeem;
  }
}
