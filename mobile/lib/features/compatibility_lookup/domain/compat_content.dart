import '../../../core/content/content_package.dart';

/// The three compatibility package families
/// (`architecture/contract-summary.md` §2). The two lookup packs stay separate
/// schemas on purpose: merging `zodiac` and `mbti` into one index is the BR-4
/// violation, and separate schema ids make it a compile-time impossibility
/// rather than a review note.
const String compatBandsSchemaId = 'req016.compat_bands.v1';
const String compatZodiacSchemaId = 'req016.compat_zodiac.v1';
const String compatMbtiSchemaId = 'req016.compat_mbti.v1';

const String compatBandsAssetKey = 'assets/data/req016/compat_bands.v1.json';
const String compatZodiacAssetKey = 'assets/data/req016/compat_zodiac.v1.json';
const String compatMbtiAssetKey = 'assets/data/req016/compat_mbti.v1.json';

const String compatCellIdSeparator = '__';

/// The one place the cell id convention is spelled out. A cell id is derived
/// from its ordered pair, never assigned freely, so an author cannot ship two
/// cells claiming the same pair under different ids.
String compatCellId(String selfId, String partnerId) =>
    '$selfId$compatCellIdSeparator$partnerId';

/// What an item inside a lookup pack is. A closed set: an unknown value is a
/// parse error, so an out-of-repo CMS cannot invent a third kind that the gate
/// has no rules for.
enum CompatItemKind {
  axisValue('axis_value'),
  cell('cell');

  const CompatItemKind(this.wireValue);

  final String wireValue;

  static CompatItemKind? fromWireValue(String value) {
    for (final CompatItemKind kind in values) {
      if (kind.wireValue == value) {
        return kind;
      }
    }
    return null;
  }
}

/// One qualitative DẢI label.
///
/// There is deliberately no order, rank, weight, or level field: the band set
/// is a vocabulary, not a scale (AC-17/BR-7). A sortable field here is what
/// turns a label back into the percentage AC-16 forbids.
class CompatBand implements ContentItem {
  const CompatBand({
    required this.id,
    required this.label,
    required this.rawJson,
  });

  @override
  final String id;

  final String label;

  /// The item exactly as the package shipped it. The gate's AC-37(c) number
  /// scan reads this rather than the typed fields, because typing the model is
  /// precisely what erases the stray JSON numbers that rule exists to find.
  final Map<String, Object?> rawJson;
}

sealed class CompatItem implements ContentItem {
  const CompatItem({required this.id, required this.rawJson});

  @override
  final String id;

  /// See [CompatBand.rawJson].
  final Map<String, Object?> rawJson;

  CompatItemKind get kind;
}

/// One value of a lookup pack's axis. The number of these in a pack *is* the
/// axis size (AC-36) — no caller ever assumes a count.
final class CompatAxisValue extends CompatItem {
  const CompatAxisValue({
    required super.id,
    required super.rawJson,
    required this.label,
  });

  final String label;

  @override
  CompatItemKind get kind => CompatItemKind.axisValue;
}

/// One cell of the lookup table, for one *ordered* pair.
final class CompatCell extends CompatItem {
  const CompatCell({
    required super.id,
    required super.rawJson,
    required this.selfId,
    required this.partnerId,
    required this.bandId,
    required this.fit,
    required this.friction,
    required this.activity,
    required this.question,
  });

  final String selfId;
  final String partnerId;
  final String bandId;

  final String fit;

  /// A missing friction point is a parse error, not a permitted variant: a cell
  /// that is all praise is the R-7 failure this story exists to prevent
  /// (AC-13/AC-37b).
  final String friction;

  final String activity;

  /// Ends the cell with something to ask a real person rather than a verdict
  /// about them (AC-20/AC-21/AC-37e).
  final String question;

  /// The four a reader is always promised (AC-12). None of them is optional.
  List<String> get quartet => <String>[fit, friction, activity, question];

  @override
  CompatItemKind get kind => CompatItemKind.cell;
}

CompatBand compatBandFromJson(Map<String, Object?> json, String source) =>
    CompatBand(
      id: requireContentString(json, 'id', source),
      label: requireContentString(json, 'label', source),
      rawJson: Map<String, Object?>.unmodifiable(json),
    );

CompatItem compatItemFromJson(Map<String, Object?> json, String source) {
  final String wireValue = requireContentString(json, 'kind', source);
  final CompatItemKind? kind = CompatItemKind.fromWireValue(wireValue);
  if (kind == null) {
    throw ContentPackageFormatException(
      source,
      'unsupported kind "$wireValue"',
    );
  }

  final String id = requireContentString(json, 'id', source);
  final Map<String, Object?> rawJson = Map<String, Object?>.unmodifiable(json);

  switch (kind) {
    case CompatItemKind.axisValue:
      return CompatAxisValue(
        id: id,
        rawJson: rawJson,
        label: requireContentString(json, 'label', source),
      );
    case CompatItemKind.cell:
      return CompatCell(
        id: id,
        rawJson: rawJson,
        selfId: requireContentString(json, 'self_id', source),
        partnerId: requireContentString(json, 'partner_id', source),
        bandId: requireContentString(json, 'band_id', source),
        fit: requireContentString(json, 'fit', source),
        friction: requireContentString(json, 'friction', source),
        activity: requireContentString(json, 'activity', source),
        question: requireContentString(json, 'question', source),
      );
  }
}

/// Looks up the cell for an *ordered* pair (BR-2).
///
/// `(aries, pisces)` and `(pisces, aries)` are two different cells, because the
/// reader is one of the two and the text is written from their side. Collapsing
/// this to an unordered pair halves the pack and silently tells half the
/// readers about the wrong person.
CompatCell? lookupCell(
  ContentPackage<CompatItem> pack, {
  required String selfId,
  required String partnerId,
}) {
  for (final CompatItem item in pack.items) {
    if (item is CompatCell &&
        item.selfId == selfId &&
        item.partnerId == partnerId) {
      return item;
    }
  }
  return null;
}
