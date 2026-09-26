import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/content_package.dart';
import '../../../activity_cards/domain/activity_card.dart';
import '../../../activity_cards/domain/activity_card_repository.dart';
import '../../data/relationship_label_repository.dart';
import '../../domain/compat_content.dart';

/// One label vocabulary as the screen needs it: the axis values the pack ships,
/// plus whatever the reader has already declared for each side.
///
/// [values] is carried in state rather than read from a Dart list at build
/// time, so the chip row is exactly as long as the pack and neither `12` nor
/// `16` is ever written down in `lib/` (`contract-summary.md` §2, AC-36).
class CompatAxisInput {
  const CompatAxisInput({
    required this.system,
    required this.values,
    required this.selfLabel,
    required this.partnerLabel,
  });

  final LabelSystem system;
  final List<CompatAxisValue> values;
  final RelationshipLabel? selfLabel;
  final RelationshipLabel? partnerLabel;

  RelationshipLabel? labelFor(LabelSubject subject) =>
      subject == LabelSubject.self ? selfLabel : partnerLabel;

  /// AC-11: one system with both sides declared is enough to render a result.
  /// The other system stays incomplete without blocking anything.
  bool get isComplete => selfLabel != null && partnerLabel != null;
}

/// One system's quartet, ready to draw.
///
/// There is one of these per *complete* system, never a merged one: two
/// systems produce two independent results with their own band, and nothing
/// anywhere combines them into a single figure (BR-4, `contract-summary.md`
/// §6).
class CompatResult {
  const CompatResult({
    required this.system,
    required this.band,
    required this.cell,
    required this.selfLabel,
    required this.partnerLabel,
    required this.selfValueLabel,
    required this.partnerValueLabel,
  });

  final LabelSystem system;
  final CompatBand band;
  final CompatCell cell;

  final RelationshipLabel selfLabel;
  final RelationshipLabel partnerLabel;

  /// The pack's display text for each declared value, so the basis line reads
  /// back the words the reader tapped rather than the wire ids.
  final String selfValueLabel;
  final String partnerValueLabel;
}

class CompatibilityLookupState {
  const CompatibilityLookupState({
    required this.loading,
    required this.axes,
    required this.results,
  });

  static const CompatibilityLookupState initial = CompatibilityLookupState(
    loading: true,
    axes: <CompatAxisInput>[],
    results: <CompatResult>[],
  );

  final bool loading;

  /// Both systems, always, in [LabelSystem] declaration order — including the
  /// complete ones, because editing or withdrawing a label has to stay
  /// available on the same screen that used it (AC-9).
  final List<CompatAxisInput> axes;

  /// Only the systems that have both sides. Empty is the ordinary opening
  /// state, not an error.
  final List<CompatResult> results;
}

/// Screen (10)'s state holder: read the three packs, read the labels the user
/// declared, and look up the ordered pair for every system that has both sides.
///
/// It owns no store. Labels go through the P2 repository and nowhere else, and
/// the one other write it performs lands in the shared activity store. In
/// particular it holds no reference to the context notebook: a lookup result is
/// never written down (AC-31, `contract-summary.md` §4).
class CompatibilityLookupCubit extends Cubit<CompatibilityLookupState> {
  CompatibilityLookupCubit({
    required RelationshipLabelRepository labels,
    required ActivityCardRepository cards,
    ContentPackageLoader loader = const ContentPackageLoader(),
  })  : _labels = labels,
        _cards = cards,
        _loader = loader,
        super(CompatibilityLookupState.initial);

  final RelationshipLabelRepository _labels;
  final ActivityCardRepository _cards;
  final ContentPackageLoader _loader;

  ContentPackage<CompatBand>? _bands;
  final Map<LabelSystem, ContentPackage<CompatItem>> _packs =
      <LabelSystem, ContentPackage<CompatItem>>{};

  /// Reads the three bundled packs once, then the labels.
  ///
  /// No "đang tra cứu" state exists between the two: this is an asset read and
  /// an in-memory scan, and a spinner here would dress a table lookup up as
  /// something thinking about the reader's relationship (AC-28/AC-29).
  Future<void> load() async {
    _bands ??= await _loader.load<CompatBand>(
      compatBandsAssetKey,
      expectedSchemaId: compatBandsSchemaId,
      itemParser: compatBandFromJson,
    );
    _packs[LabelSystem.zodiac] ??= await _loader.load<CompatItem>(
      compatZodiacAssetKey,
      expectedSchemaId: compatZodiacSchemaId,
      itemParser: compatItemFromJson,
    );
    _packs[LabelSystem.mbti] ??= await _loader.load<CompatItem>(
      compatMbtiAssetKey,
      expectedSchemaId: compatMbtiSchemaId,
      itemParser: compatItemFromJson,
    );
    await _refresh();
  }

  /// Declares or re-declares one side of one system, then re-reads.
  ///
  /// [certainty] travels with the value instead of being inferred from which
  /// side it is: guessing about yourself and being sure about the other person
  /// are both things a reader is allowed to say (AC-7/AC-8).
  Future<void> selectLabel({
    required LabelSystem system,
    required LabelSubject subject,
    required String valueId,
    required LabelCertainty certainty,
  }) async {
    await _labels.saveLabel(
      subject: subject,
      system: system,
      value: valueId,
      certainty: certainty,
    );
    await _refresh();
  }

  /// Withdraws one label outright (AC-9). The result built on it disappears
  /// with it, because nothing about a lookup was ever stored.
  Future<void> clearLabel({
    required LabelSystem system,
    required LabelSubject subject,
  }) async {
    await _labels.deleteLabel(subject: subject, system: system);
    await _refresh();
  }

  /// The single write this screen performs, and it lands in the shared activity
  /// store, not anywhere local (SC-2, `contract-summary.md` §6).
  ///
  /// Returns the new card's id so the caller can offer an undo. Nothing about
  /// the push is remembered on this screen: there is no "đã thêm" set, because
  /// a per-lookup memory is the lookup history AC-33 rules out.
  Future<String> addActivityToStore(CompatResult result) async {
    final ActivityCard card = await _cards.createCard(
      NewActivityCard(
        title: result.cell.activity,
        origin: ActivityCardOrigin.compatibilityLookup,
      ),
    );
    return card.id;
  }

  /// Undo for [addActivityToStore]: removes the card the snackbar just
  /// announced. A delete, not a status change, so an undone push leaves the
  /// store exactly as it was.
  Future<void> undoAddToStore(String cardId) => _cards.deleteCard(cardId);

  Future<void> _refresh() async {
    final List<RelationshipLabel> labels = await _labels.labels();
    if (isClosed) {
      return;
    }

    final List<CompatAxisInput> axes = <CompatAxisInput>[
      for (final LabelSystem system in LabelSystem.values)
        CompatAxisInput(
          system: system,
          values: _axisValues(system),
          selfLabel: _labelFor(labels, system, LabelSubject.self),
          partnerLabel: _labelFor(labels, system, LabelSubject.partner),
        ),
    ];

    emit(
      CompatibilityLookupState(
        loading: false,
        axes: axes,
        results: <CompatResult>[
          for (final CompatAxisInput axis in axes)
            if (_resultFor(axis) case final CompatResult result) result,
        ],
      ),
    );
  }

  List<CompatAxisValue> _axisValues(LabelSystem system) {
    final ContentPackage<CompatItem>? pack = _packs[system];
    if (pack == null) {
      return const <CompatAxisValue>[];
    }
    return List<CompatAxisValue>.unmodifiable(
      pack.items.whereType<CompatAxisValue>(),
    );
  }

  static RelationshipLabel? _labelFor(
    List<RelationshipLabel> labels,
    LabelSystem system,
    LabelSubject subject,
  ) {
    for (final RelationshipLabel label in labels) {
      if (label.system == system && label.subject == subject) {
        return label;
      }
    }
    return null;
  }

  /// Builds one system's result, or null while that system is incomplete — or
  /// while the pack has no cell for the pair, which the content gate's coverage
  /// rule makes impossible for a shipped pack (AC-36) but which must still not
  /// crash a reader's screen.
  CompatResult? _resultFor(CompatAxisInput axis) {
    final ContentPackage<CompatItem>? pack = _packs[axis.system];
    final ContentPackage<CompatBand>? bands = _bands;
    final RelationshipLabel? self = axis.selfLabel;
    final RelationshipLabel? partner = axis.partnerLabel;
    if (pack == null || bands == null || self == null || partner == null) {
      return null;
    }

    // Ordered, always: the reader is the `self` side and the text is written
    // from there, so swapping the pair is a different cell and not the same
    // one read backwards (BR-2).
    final CompatCell? cell = lookupCell(
      pack,
      selfId: self.value,
      partnerId: partner.value,
    );
    if (cell == null) {
      return null;
    }

    final CompatBand? band = bands.itemById(cell.bandId);
    if (band == null) {
      return null;
    }

    return CompatResult(
      system: axis.system,
      band: band,
      cell: cell,
      selfLabel: self,
      partnerLabel: partner,
      selfValueLabel: _valueLabel(axis, self.value),
      partnerValueLabel: _valueLabel(axis, partner.value),
    );
  }

  static String _valueLabel(CompatAxisInput axis, String valueId) {
    for (final CompatAxisValue value in axis.values) {
      if (value.id == valueId) {
        return value.label;
      }
    }
    return valueId;
  }
}
