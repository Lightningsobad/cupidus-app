import '../../../core/content/content_package.dart';

/// The three package families this story ships
/// (`architecture/contract-summary.md` §4). Separate schema ids because the
/// item shapes have nothing in common.
const String phaseContentSchemaId = 'req016.phase_content.v1';
const String dripSchemaId = 'req016.drip.v1';
const String nudgesSchemaId = 'req016.nudges.v1';

const String phaseContentAssetKey = 'assets/data/req016/phase_content.v1.json';
const String dripAssetKey = 'assets/data/req016/drip.v1.json';
const String nudgesAssetKey = 'assets/data/req016/nudges.v1.json';

/// The root key of `nudges.v1.json` holding the milestone thresholds. They are
/// package data, not a Dart constant and not a backend value (BR-16).
const String milestoneThresholdsKey = 'thresholds';

/// The one substitution site a content author may write. Dart owns every
/// replacement; outside `{n}` there is no template syntax
/// (`architecture/contract-summary.md` §4).
const String phaseContentNumberPlaceholder = '{n}';

/// The four phases, as the closed ASCII set the native widget reads
/// (`architecture/contract-summary.md` §2). Append-only: renaming a value
/// silently blanks a widget already sitting on someone's home screen, with no
/// compile error on either side.
enum PhaseId {
  waiting('waiting'),
  upcoming('upcoming'),
  dateDay('date_day'),
  quiet('quiet');

  const PhaseId(this.wireValue);

  final String wireValue;

  static PhaseId? fromWireValue(String value) {
    for (final PhaseId id in values) {
      if (id.wireValue == value) {
        return id;
      }
    }
    return null;
  }
}

/// Where a phase line is allowed to appear. The widget is a public surface and
/// carries tighter rules than an in-app screen (BR-11), so the package says
/// which lines may cross onto it rather than a caller deciding by wording.
enum PhaseSurface {
  widget('widget'),
  screen('screen'),
  both('both');

  const PhaseSurface(this.wireValue);

  final String wireValue;

  bool get allowsWidget => this != PhaseSurface.screen;

  bool get allowsScreen => this != PhaseSurface.widget;

  static PhaseSurface? fromWireValue(String value) {
    for (final PhaseSurface surface in values) {
      if (surface.wireValue == value) {
        return surface;
      }
    }
    return null;
  }
}

/// Which reminder a nudge belongs to. A closed set: an unknown slot is a parse
/// error, never a default, because a nudge that silently lands in no slot is a
/// line an author wrote and no reader ever sees.
enum NudgeSlot {
  eveningCheckIn('evening_check_in'),
  countdown('countdown'),
  counter('counter'),
  milestone('milestone'),
  giftProgress('gift_progress'),
  neutral('neutral');

  const NudgeSlot(this.wireValue);

  final String wireValue;

  static NudgeSlot? fromWireValue(String value) {
    for (final NudgeSlot slot in values) {
      if (slot.wireValue == value) {
        return slot;
      }
    }
    return null;
  }
}

/// One phase line.
///
/// [primary] and [secondary] are finished product: the consumer substitutes
/// `{n}` and draws them, it never concatenates, picks between variants, or
/// appends a unit (`architecture/contract-summary.md` §2).
class PhaseContentItem implements ContentItem {
  const PhaseContentItem({
    required this.id,
    required this.phaseId,
    required this.primary,
    required this.secondary,
    required this.surface,
  });

  @override
  final String id;

  final PhaseId phaseId;

  final String primary;

  /// Absent is a valid state, not an error: no second line is drawn.
  final String? secondary;

  final PhaseSurface surface;

  /// Every string a reader can see, which is exactly what the gate measures.
  Iterable<String> get displayStrings => <String>[primary, ?secondary];
}

/// One drip line for the quiet stretch between dates.
///
/// It speaks about what the user holds and what the user did (AC-23/BR-4).
/// There is deliberately no cadence, weight, or ordering field: the frequency
/// ceiling is a product rule (BR-9), not something a content author can relax.
class DripItem implements ContentItem {
  const DripItem({required this.id, required this.body});

  @override
  final String id;

  final String body;

  Iterable<String> get displayStrings => <String>[body];
}

/// One nudge body, optionally titled.
class NudgeItem implements ContentItem {
  const NudgeItem({
    required this.id,
    required this.slot,
    required this.title,
    required this.body,
  });

  @override
  final String id;

  final NudgeSlot slot;

  final String? title;

  final String body;

  Iterable<String> get displayStrings => <String>[?title, body];
}

PhaseContentItem phaseContentItemFromJson(
  Map<String, Object?> json,
  String source,
) {
  final String id = requireContentString(json, 'id', source);

  final String rawPhaseId = requireContentString(json, 'phase_id', source);
  final PhaseId? phaseId = PhaseId.fromWireValue(rawPhaseId);
  if (phaseId == null) {
    throw ContentPackageFormatException(
      source,
      'phase line "$id" declares unsupported phase_id "$rawPhaseId"',
    );
  }

  final String rawSurface = requireContentString(json, 'surface', source);
  final PhaseSurface? surface = PhaseSurface.fromWireValue(rawSurface);
  if (surface == null) {
    throw ContentPackageFormatException(
      source,
      'phase line "$id" declares unsupported surface "$rawSurface"',
    );
  }

  return PhaseContentItem(
    id: id,
    phaseId: phaseId,
    primary: requireContentString(json, 'primary', source),
    secondary: optionalContentString(json, 'secondary', source),
    surface: surface,
  );
}

DripItem dripItemFromJson(Map<String, Object?> json, String source) =>
    DripItem(
      id: requireContentString(json, 'id', source),
      body: requireContentString(json, 'body', source),
    );

NudgeItem nudgeItemFromJson(Map<String, Object?> json, String source) {
  final String id = requireContentString(json, 'id', source);

  final String rawSlot = requireContentString(json, 'slot', source);
  final NudgeSlot? slot = NudgeSlot.fromWireValue(rawSlot);
  if (slot == null) {
    throw ContentPackageFormatException(
      source,
      'nudge "$id" declares unsupported slot "$rawSlot"',
    );
  }

  return NudgeItem(
    id: id,
    slot: slot,
    title: optionalContentString(json, 'title', source),
    body: requireContentString(json, 'body', source),
  );
}

/// Reads the milestone thresholds off the package root and returns them in
/// ascending order, so no caller has to know whether the author kept them
/// sorted.
List<int> milestoneThresholdsFromJson(
  Map<String, Object?> json,
  String source,
) {
  final Object? raw = json[milestoneThresholdsKey];
  if (raw is! List) {
    throw ContentPackageFormatException(
      source,
      'field "$milestoneThresholdsKey" must be a list of whole numbers',
    );
  }

  final List<int> thresholds = <int>[];
  for (final Object? entry in raw) {
    if (entry is! int || entry <= 0) {
      throw ContentPackageFormatException(
        source,
        'every entry of "$milestoneThresholdsKey" must be a whole number '
        'greater than zero',
      );
    }
    if (thresholds.contains(entry)) {
      throw ContentPackageFormatException(
        source,
        'duplicate milestone threshold "$entry"',
      );
    }
    thresholds.add(entry);
  }

  thresholds.sort();
  return List<int>.unmodifiable(thresholds);
}
