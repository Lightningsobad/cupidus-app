import '../../../core/content/content_package.dart';
import '../../context_notebook/context_notebook_entry_point.dart';
import '../domain/gift_content.dart';
import '../domain/gift_selector.dart';

/// The read side of the gift flow: three shipped packs, plus whatever the user
/// has already written in the notebook and the skill profile.
///
/// Read-only on purpose. There is no store of its own behind this class — no
/// local schema, no "saved gift" list, and no rotation cursor written down.
/// The one place a chosen idea lands is the shared hub of screen (1)
/// (`architecture/contract-summary.md` §6, SC-1'/AC-22).
class GiftRepository {
  GiftRepository({
    required ContextNotebookReader notebook,
    ContentPackageLoader loader = const ContentPackageLoader(),
  })  : _notebook = notebook,
        _loader = loader;

  final ContextNotebookReader _notebook;
  final ContentPackageLoader _loader;

  /// Held after the first read because the packs are bundled assets that cannot
  /// change while the app runs. Stored as the in-flight future so two screens
  /// opening at once share one parse instead of racing.
  Future<GiftCatalogue>? _catalogue;

  /// Throws rather than degrading when a pack is malformed: a half-loaded
  /// catalogue would silently drop ideas an author shipped (R-15a).
  Future<GiftCatalogue> catalogue() => _catalogue ??= _loadCatalogue();

  /// A fresh read every call. The notebook changes while the gift screen is
  /// open — the inline ask card writes to it — so a cached snapshot here would
  /// show suggestions that ignore what the user just answered.
  Future<GiftContextSnapshot> context() async {
    final List<NotebookEntry> entries = await _notebook.entries();
    final List<SkillEntry> skills = await _notebook.skills();

    final List<GiftContextValue> values = <GiftContextValue>[
      for (final NotebookEntry entry in entries)
        GiftContextValue(
          kind: _contextKindOf(entry.kind),
          key: entry.value,
          label: entry.value,
        ),
      // A skill the user typed rather than tapped has no seed id, so no pack
      // row is keyed by it: the index maps durable seed ids, never free text
      // (`architecture/contract-summary.md` §2). It stays out of the snapshot
      // instead of being matched by its wording.
      for (final SkillEntry skill in skills)
        if (skill.seedId case final String seedId)
          GiftContextValue(
            kind: GiftContextKind.skill,
            key: seedId,
            label: skill.label,
          ),
    ];

    return GiftContextSnapshot(
      values: List<GiftContextValue>.unmodifiable(values),
    );
  }

  Future<GiftCatalogue> _loadCatalogue() async {
    final ContentPackage<GiftIdea> gifts = await _loader.load<GiftIdea>(
      giftsAssetKey,
      expectedSchemaId: giftsSchemaId,
      itemParser: giftIdeaFromJson,
    );
    final ContentPackage<GiftIndexRow> giftIndex =
        await _loader.load<GiftIndexRow>(
      giftIndexAssetKey,
      expectedSchemaId: giftIndexSchemaId,
      itemParser: giftIndexRowFromJson,
    );
    final ContentPackage<GiftTaxonomyItem> taxonomy =
        await _loader.load<GiftTaxonomyItem>(
      giftTaxonomyAssetKey,
      expectedSchemaId: giftTaxonomySchemaId,
      itemParser: giftTaxonomyItemFromJson,
    );

    return GiftCatalogue(
      gifts: gifts,
      giftIndex: giftIndex,
      taxonomy: taxonomy,
    );
  }

  GiftContextKind _contextKindOf(NotebookKind kind) => switch (kind) {
        NotebookKind.interest => GiftContextKind.interest,
        NotebookKind.event => GiftContextKind.event,
      };
}
