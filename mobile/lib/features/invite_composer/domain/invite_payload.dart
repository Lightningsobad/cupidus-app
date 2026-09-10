import 'dart:convert';

import '../../../core/content/content_package.dart';
import 'invite_preset.dart';
import 'invite_renderer.dart';
import 'mad_libs.dart';

/// One exported invite as it is stored: the structured input the sentence was
/// rendered from, never the sentence itself (`architecture/contract-summary.md`
/// §4, SB-125/AC-17).
///
/// [userEditedText] is the manual override the user typed over the rendered
/// draft (AC-7). It is a *secondary* field, not the primary storage form —
/// writing rendered output into [filledValues] or into any of the id columns
/// would flatten the payload and break AC-17 even though the screen would still
/// look right.
///
/// There is deliberately no send/open/seen timestamp and no Share Sheet result
/// here: this app hands the item to the OS and learns nothing afterwards
/// (R-1b/AC-16/AC-19).
class InvitePayload {
  InvitePayload({
    required this.id,
    required this.cardId,
    required this.categoryId,
    required this.presetId,
    required this.packVersion,
    required Map<String, String> filledValues,
    required this.userEditedText,
    required this.createdAt,
  }) : filledValues = Map<String, String>.unmodifiable(filledValues);

  /// Client-generated UUID v4, permanently stable.
  final String id;

  /// The card this invite was composed from.
  final String cardId;

  /// Preset category (`invite` is the only one this story ships, AC-22).
  final String categoryId;

  /// `items[].id` of the preset. Stable across pack versions on purpose: this,
  /// not an index or a pack-scoped key, is what makes an old payload re-render
  /// after the content pack is revised.
  final String presetId;

  /// Pack `version` at export time. Recorded so a later revision is
  /// *detectable*; re-rendering does not depend on it.
  final String packVersion;

  /// `{variableName: value}` for the variables that had data, keyed by
  /// [MadLibsVariable.wireValue]. Kept at wire level rather than as a
  /// `Map<MadLibsVariable, String>` so a row written by a future build survives
  /// a round trip through an older one without losing keys it cannot name.
  final Map<String, String> filledValues;

  /// `null` means the user did not edit, not "empty invite".
  final String? userEditedText;

  final DateTime createdAt;
}

/// Rebuilds the exact string the user exported (AC-18).
///
/// The edited branch is checked first, so an edited payload re-renders without
/// touching the content pack at all — that path cannot be broken by a preset
/// being revised, reworded, or reordered.
String renderStored(InvitePayload payload, ContentPackage<InvitePreset> package) {
  final String? edited = payload.userEditedText;
  if (edited != null) {
    return edited;
  }
  final InvitePreset? preset = package.itemById(payload.presetId);
  if (preset == null) {
    throw StateError(
      'stored invite "${payload.id}" refers to preset "${payload.presetId}", '
      'which package "${package.id}" v${package.version} does not contain',
    );
  }
  return renderInvite(preset, madLibsValuesFrom(payload.filledValues));
}

/// Wire map to renderer input. Keys outside the closed set are dropped rather
/// than rejected: an unknown key can only come from a build that knows a
/// variable this one does not, and dropping it takes the same AC-6 clause-drop
/// branch as a variable the card never had.
MadLibsValues madLibsValuesFrom(Map<String, String> filledValues) =>
    MadLibsValues(<MadLibsVariable, String>{
      for (final MapEntry<String, String> entry in filledValues.entries)
        if (MadLibsVariable.fromWireValue(entry.key) case final MadLibsVariable v)
          v: entry.value,
    });

/// Renderer input to wire map, for the export path.
Map<String, String> filledValuesFrom(MadLibsValues values) =>
    <String, String>{
      for (final MapEntry<MadLibsVariable, String> entry
          in values.variables.entries)
        entry.key.wireValue: entry.value,
    };

/// JSON codec for [InvitePayload.filledValues] and nothing else. The remaining
/// fields stay as their own columns: merging them into one blob would make
/// `preset_id` and `card_id` unqueryable and put the SB-125 contract inside an
/// opaque string.
String encodeFilledValues(Map<String, String> filledValues) =>
    jsonEncode(filledValues);

/// Inverse of [encodeFilledValues]. A row that is not a flat string-to-string
/// object is corrupt, and corruption surfaces here as a loud [FormatException]
/// rather than as a silently half-filled sentence.
Map<String, String> decodeFilledValues(String source) {
  final Object? decoded;
  try {
    decoded = jsonDecode(source);
  } on FormatException catch (error) {
    throw FormatException('filled_values is not valid JSON: ${error.message}');
  }
  if (decoded is! Map<String, Object?>) {
    throw const FormatException('filled_values must be a JSON object');
  }
  final Map<String, String> values = <String, String>{};
  for (final MapEntry<String, Object?> entry in decoded.entries) {
    final Object? value = entry.value;
    if (value is! String) {
      throw FormatException(
        'filled_values["${entry.key}"] must be a string, got '
        '${value.runtimeType}',
      );
    }
    values[entry.key] = value;
  }
  return values;
}
