import '../../../core/content/content_package.dart';
import 'mad_libs.dart';

/// Who a clause's joke points at (`architecture/contract-summary.md` §2).
///
/// `recipient` is absent from this enum rather than filtered downstream: a
/// package declaring it dies in the parser, so no later refactor can reopen
/// the door to teasing the person being invited (R-1d).
enum ClauseTarget {
  sender('sender'),
  neutral('neutral');

  const ClauseTarget(this.wireValue);

  final String wireValue;

  static ClauseTarget? fromWireValue(String value) {
    for (final ClauseTarget target in values) {
      if (target.wireValue == value) {
        return target;
      }
    }
    return null;
  }
}

/// The one structural role a clause can carry. The decline door (R-1c/AC-10)
/// is the only clause the invite body is required to contain.
enum ClauseRole {
  declineDoor('decline_door');

  const ClauseRole(this.wireValue);

  final String wireValue;

  static ClauseRole? fromWireValue(String value) {
    for (final ClauseRole role in values) {
      if (role.wireValue == value) {
        return role;
      }
    }
    return null;
  }
}

/// One authored sentence of an invite (`contract-summary.md` §3, rows 4-7).
class PresetClause {
  const PresetClause({
    required this.text,
    required this.requires,
    required this.targets,
    this.role,
  });

  /// Verbatim authored text, placeholders included. The content side owns the
  /// wording, the punctuation, and where the sentence breaks.
  final String text;

  /// Variables that must all be present, or the whole clause is dropped
  /// (AC-6). An empty list makes the clause unconditional.
  final List<MadLibsVariable> requires;

  final ClauseTarget targets;
  final ClauseRole? role;
}

/// One parodic frame the user can pick in the composer sheet.
class InvitePreset implements ContentItem {
  const InvitePreset({
    required this.id,
    required this.frame,
    required this.clauses,
  });

  @override
  final String id;

  /// Chip label. Content, not l10n (`contract-summary.md` §3, row 2).
  final String frame;

  /// Declaration order is render order.
  final List<PresetClause> clauses;
}

/// [ContentItemParser] for the `req016.presets.v1` schema. Every mandatory
/// field is checked here; a missing or mistyped field is a load error, never a
/// silent default (`contract-summary.md` §3).
InvitePreset invitePresetFromJson(Map<String, Object?> json, String source) {
  final String id = requireContentString(json, 'id', source);
  final String frame = requireContentString(json, 'frame', source);
  final List<Map<String, Object?>> rawClauses = requireContentObjectList(
    json,
    'clauses',
    source,
  );
  if (rawClauses.isEmpty) {
    throw ContentPackageFormatException(
      source,
      'preset "$id" must declare at least one clause',
    );
  }

  return InvitePreset(
    id: id,
    frame: frame,
    clauses: List<PresetClause>.unmodifiable(<PresetClause>[
      for (final Map<String, Object?> rawClause in rawClauses)
        _clauseFromJson(rawClause, id, source),
    ]),
  );
}

PresetClause _clauseFromJson(
  Map<String, Object?> json,
  String presetId,
  String source,
) {
  final String text = requireContentString(json, 'text', source);

  final List<MadLibsVariable> requires = <MadLibsVariable>[];
  for (final String name in requireContentStringList(
    json,
    'requires',
    source,
  )) {
    final MadLibsVariable? variable = MadLibsVariable.fromWireValue(name);
    if (variable == null) {
      throw ContentPackageFormatException(
        source,
        'preset "$presetId" requires unknown mad-libs variable "$name"',
      );
    }
    requires.add(variable);
  }

  // Every placeholder must be gated by `requires`, otherwise a card missing
  // that field would keep the clause and print literal braces (AC-6).
  for (final RegExpMatch match in madLibsPlaceholderPattern.allMatches(text)) {
    final String name = match.group(1)!;
    final MadLibsVariable? variable = MadLibsVariable.fromWireValue(name);
    if (variable == null) {
      throw ContentPackageFormatException(
        source,
        'preset "$presetId" uses unknown placeholder "${match.group(0)}"',
      );
    }
    if (!requires.contains(variable)) {
      throw ContentPackageFormatException(
        source,
        'preset "$presetId" uses placeholder "${match.group(0)}" without '
        'listing "$name" in "requires"',
      );
    }
  }

  final String rawTargets = requireContentString(json, 'targets', source);
  final ClauseTarget? targets = ClauseTarget.fromWireValue(rawTargets);
  if (targets == null) {
    throw ContentPackageFormatException(
      source,
      'preset "$presetId" declares unsupported targets "$rawTargets"',
    );
  }

  final String? rawRole = optionalContentString(json, 'role', source);
  ClauseRole? role;
  if (rawRole != null) {
    role = ClauseRole.fromWireValue(rawRole);
    if (role == null) {
      throw ContentPackageFormatException(
        source,
        'preset "$presetId" declares unsupported clause role "$rawRole"',
      );
    }
  }

  return PresetClause(
    text: text,
    requires: List<MadLibsVariable>.unmodifiable(requires),
    targets: targets,
    role: role,
  );
}
