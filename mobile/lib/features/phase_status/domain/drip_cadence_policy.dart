import '../../../core/content/content_package.dart';
import '../../before_you_go/domain/before_you_go_resolver.dart';
import '../data/phase_status_prefs.dart';
import 'phase_content.dart';

/// The BR-9 ceiling: at most one drip line per week, never daily.
///
/// A product constraint matched to how often the user actually plans something,
/// not a tuning knob. It is deliberately not derived from how many items the
/// package holds, so an almost-exhausted store cannot widen it (BR-16/AC-38).
const int dripMinimumDaysBetweenShows = 7;

/// Picks the single drip line the quiet phase may show right now, or `null`.
///
/// `null` is the normal answer most of the time and the only answer once the
/// store is exhausted. The caller draws nothing: no "đã hết" notice, no
/// remaining count, no progress indicator, no promise of a next one (AC-38).
/// There is no "show the next one anyway" entry point here, so filling the
/// silence is not expressible against this API.
class DripCadencePolicy {
  DripCadencePolicy(this._prefs);

  final PhaseStatusPrefs _prefs;

  /// [today] is a parameter rather than a clock read inside, so the cadence is
  /// reproducible in a test and identical for two surfaces resolving seconds
  /// apart.
  ///
  /// Consumption is recorded by item id rather than index, so an author who
  /// reorders or grows the package cannot resurrect a line the user already
  /// read.
  Future<DripItem?> nextItem({
    required ContentPackage<DripItem> drip,
    required DateTime today,
  }) async {
    final String? lastShownOn = await _prefs.dripLastShownOn();
    if (lastShownOn != null) {
      final int? elapsedDays = _civilDaysSince(lastShownOn, today);
      // An unparseable cursor is not a record of a show, so it re-arms rather
      // than silencing the surface forever; the next show rewrites it.
      if (elapsedDays != null && elapsedDays < dripMinimumDaysBetweenShows) {
        return null;
      }
    }

    final List<String> seenIds = await _prefs.dripSeenIds();
    for (final DripItem item in drip.items) {
      if (seenIds.contains(item.id)) {
        continue;
      }
      await _prefs.setDripLastShownOn(civilDateIso(today));
      await _prefs.markDripSeen(item.id);
      return item;
    }

    return null;
  }
}

/// Whole civil days between two `YYYY-MM-DD` calendar dates, or `null` when
/// [dateIso] is not one. Compared at UTC midnight so a daylight-saving shift
/// cannot turn seven days into six.
int? _civilDaysSince(String dateIso, DateTime today) {
  final DateTime? parsed = DateTime.tryParse(dateIso);
  if (parsed == null) {
    return null;
  }
  final DateTime from = DateTime.utc(parsed.year, parsed.month, parsed.day);
  final DateTime to = DateTime.utc(today.year, today.month, today.day);
  return to.difference(from).inDays;
}
