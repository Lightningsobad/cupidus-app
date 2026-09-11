import 'invite_preset.dart';
import 'mad_libs.dart';

/// Renders one invite. Deterministic by construction: no clock, no randomness,
/// no network, no model call — the same preset and the same values always
/// produce the same string (AC-8, AC-9).
///
/// A clause whose `requires` is not fully satisfied is dropped whole rather
/// than patched, so the surviving sentences are exactly as their author wrote
/// them and no punctuation repair heuristic ever runs (AC-6). Because the
/// decline door is authored with `requires: []`, no card data can remove it
/// (AC-10).
///
/// The engine only joins: it does not capitalize, add or remove full stops, or
/// otherwise edit grammar (`architecture/contract-summary.md` §3).
String renderInvite(InvitePreset preset, MadLibsValues values) {
  final List<String> parts = <String>[];
  for (final PresetClause clause in preset.clauses) {
    if (clause.requires.any(
      (MadLibsVariable variable) => !values.contains(variable),
    )) {
      continue;
    }
    final String filled = _fill(clause.text, values).trim();
    if (filled.isNotEmpty) {
      parts.add(filled);
    }
  }
  return parts.join(' ');
}

String _fill(String text, MadLibsValues values) => text.replaceAllMapped(
      madLibsPlaceholderPattern,
      (Match match) {
        final MadLibsVariable? variable = MadLibsVariable.fromWireValue(
          match.group(1)!,
        );
        return variable == null ? match.group(0)! : values[variable]!;
      },
    );
