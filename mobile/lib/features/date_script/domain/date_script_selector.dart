import 'dart:convert';

import '../../../core/content/content_package.dart';
import '../../activity_cards/domain/activity_card.dart';
import '../../activity_cards/domain/activity_type.dart';
import 'date_script_content.dart';

/// FNV-1a 32-bit over the UTF-8 bytes of [value].
///
/// Written out here rather than reaching for [Object.hashCode] because
/// `String.hashCode` is seeded per process in some Dart runtimes: the same card
/// would pick a different script on the next launch, which is exactly the drift
/// AC-8 forbids. `Random`, the clock, and insertion order are out for the same
/// reason (`architecture/contract-summary.md` §3, §5).
///
/// UTF-8 rather than `codeUnits` so the value is a property of the text, not of
/// Dart's UTF-16 representation of it — and so the published FNV-1a vectors the
/// test pins can be used as independent evidence.
int stableHash(String value) {
  int hash = _fnvOffsetBasis;
  for (final int byte in utf8.encode(value)) {
    hash = (hash ^ byte) & _mask32;
    hash = (hash * _fnvPrime) & _mask32;
  }
  return hash;
}

const int _fnvOffsetBasis = 0x811c9dc5;
const int _fnvPrime = 0x01000193;
const int _mask32 = 0xFFFFFFFF;

/// The one script [card] gets, as a total deterministic function of
/// `(pack, card)` (AC-34).
///
/// A card whose [ActivityType] no preset declares — and a card with no type at
/// all — falls through to the generic presets rather than to an empty screen.
/// Since the ship gate rejects a pack without a generic preset, every card in a
/// shipped build resolves to a script.
DateScriptPreset selectPreset(
  ContentPackage<DateScriptPreset> pack,
  ActivityCard card,
) {
  final List<DateScriptPreset> candidates = _candidatesFor(
    pack,
    card.activityType,
  );
  if (candidates.isEmpty) {
    // Only reachable for a package that never passed `validateDateScriptPack`,
    // which an out-of-repo CMS can hand us in memory. Loud beats a RangeError.
    throw ContentPackageFormatException(
      pack.schemaId,
      'package "${pack.id}" has no generic preset to fall back on; it cannot '
      'have passed validateDateScriptPack',
    );
  }
  return candidates[stableHash(card.id) % candidates.length];
}

/// Presets declaring [type], or the generic presets when [type] is `null` or
/// nothing declares it. Pack order is preserved, so the modulo below indexes
/// the order the author shipped.
List<DateScriptPreset> _candidatesFor(
  ContentPackage<DateScriptPreset> pack,
  ActivityType? type,
) {
  final List<DateScriptPreset> generic = <DateScriptPreset>[
    for (final DateScriptPreset preset in pack.items)
      if (preset.activityTypes.isEmpty) preset,
  ];
  if (type == null) {
    return generic;
  }
  final List<DateScriptPreset> typed = <DateScriptPreset>[
    for (final DateScriptPreset preset in pack.items)
      if (preset.activityTypes.contains(type)) preset,
  ];
  return typed.isEmpty ? generic : typed;
}

/// [current] wrapped into `[0, length)`.
///
/// The whole of "what happens when the reader has seen them all": the cursor
/// rolls over, so there is no exhausted state to store, no dead-end screen, no
/// "đã hết kịch bản" message, and no remaining-count to draw (AC-35/R-15b). The
/// rule is stated in terms of [length], never in terms of the seed pack's size.
///
/// Dart's `%` is non-negative for a positive divisor, so a cursor that ran
/// backwards still lands inside the list.
int cycleIndex(int current, int length) => current % length;
