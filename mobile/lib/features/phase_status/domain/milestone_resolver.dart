import '../../../core/content/content_package.dart';
import '../data/phase_status_prefs.dart';
import 'phase_content.dart';

/// The one milestone the app has just recognised, and the number to substitute
/// into the caption's `{n}`.
///
/// [value] is the threshold that was crossed, not the current counter value: a
/// user who jumps from 3 to 30 kept 30 things, but the milestone being
/// recognised is 25.
class MilestoneResolution {
  const MilestoneResolution({required this.item, required this.value});

  final NudgeItem item;

  final int value;

  @override
  bool operator ==(Object other) =>
      other is MilestoneResolution && other.item.id == item.id && other.value == value;

  @override
  int get hashCode => Object.hash(item.id, value);

  @override
  String toString() => 'MilestoneResolution(${item.id}, $value)';
}

/// Recognises a crossed milestone exactly once, then stops (AC-28/BR-8).
///
/// "Stops" is the whole feature. This returns a caption to draw and nothing
/// else: no action, no button, no invite, no two-way flow — those belong to
/// chặng 1.5, outside REQ-016. A caller cannot ask this for a target, a
/// remaining distance, or a next threshold, so the "progress toward a required
/// milestone" that BR-7/AC-27 forbid is not expressible against this API.
class MilestoneResolver {
  MilestoneResolver(this._prefs);

  final PhaseStatusPrefs _prefs;

  /// Returns the milestone to show right now, or `null` — which is the ordinary
  /// case, not a failure.
  ///
  /// [thresholds] come from the `nudges.v1.json` package root, so the ladder is
  /// authored data rather than a constant in this file (BR-16). The counter
  /// value is passed in; this never reads a card store and never reads a clock,
  /// so a milestone cannot be triggered by time passing.
  ///
  /// The durable cursor is the highest value already announced, so a milestone
  /// announced in an earlier session never comes back on the next open, and a
  /// counter that later drops below the threshold does not re-arm it.
  Future<MilestoneResolution?> resolve({
    required int counterValue,
    required List<int> thresholds,
    required ContentPackage<NudgeItem> nudges,
  }) async {
    final int? crossed = _highestCrossed(counterValue, thresholds);
    if (crossed == null) {
      return null;
    }

    final int? lastShown = await _prefs.milestoneLastShownValue();
    if (lastShown != null && lastShown >= crossed) {
      return null;
    }

    final NudgeItem? item = _milestoneItem(nudges);
    if (item == null) {
      return null;
    }

    await _prefs.setMilestoneLastShownValue(crossed);
    return MilestoneResolution(item: item, value: crossed);
  }

  int? _highestCrossed(int counterValue, List<int> thresholds) {
    int? crossed;
    for (final int threshold in thresholds) {
      if (threshold <= counterValue && (crossed == null || threshold > crossed)) {
        crossed = threshold;
      }
    }
    return crossed;
  }

  NudgeItem? _milestoneItem(ContentPackage<NudgeItem> nudges) {
    for (final NudgeItem item in nudges.items) {
      if (item.slot == NudgeSlot.milestone) {
        return item;
      }
    }
    return null;
  }
}
