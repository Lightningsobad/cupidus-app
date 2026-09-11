import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../../../core/content/content_package.dart';
import '../domain/phase_content.dart';

/// The three shipped packs plus the milestone thresholds, read together.
///
/// Held as one value because a consumer that got two of the three would be
/// drawing a phase whose nudge copy is missing, which reads as an empty state
/// rather than as the load failure it is.
class PhaseContentCatalogue {
  const PhaseContentCatalogue({
    required this.phaseContent,
    required this.drip,
    required this.nudges,
    required this.milestoneThresholds,
  });

  final ContentPackage<PhaseContentItem> phaseContent;
  final ContentPackage<DripItem> drip;
  final ContentPackage<NudgeItem> nudges;

  /// Ascending, deduplicated, and read from `nudges.v1.json` (BR-16).
  final List<int> milestoneThresholds;
}

/// The read side of every string this story shows.
///
/// Asset-only by construction: no HTTP client, no base URL, and no model call
/// on this path (AC-34/BR-13). Swapping the content source for an out-of-repo
/// CMS replaces the assets behind these keys and touches no Dart (BR-15).
class PhaseContentRepository {
  PhaseContentRepository({AssetBundle? bundle})
      : _bundle = bundle,
        _loader = ContentPackageLoader(bundle: bundle);

  final AssetBundle? _bundle;
  final ContentPackageLoader _loader;

  /// Held after the first read because the packs are bundled assets that cannot
  /// change while the app runs. Stored as the in-flight future so two surfaces
  /// opening at once share one parse instead of racing.
  Future<PhaseContentCatalogue>? _catalogue;

  /// Throws rather than degrading when a pack is malformed. A half-loaded
  /// catalogue would silently drop lines an author shipped, and this story's
  /// empty states look identical to that (R-15a).
  Future<PhaseContentCatalogue> catalogue() => _catalogue ??= _load();

  Future<PhaseContentCatalogue> _load() async {
    final ContentPackage<PhaseContentItem> phaseContent =
        await _loader.load<PhaseContentItem>(
      phaseContentAssetKey,
      expectedSchemaId: phaseContentSchemaId,
      itemParser: phaseContentItemFromJson,
    );
    final ContentPackage<DripItem> drip = await _loader.load<DripItem>(
      dripAssetKey,
      expectedSchemaId: dripSchemaId,
      itemParser: dripItemFromJson,
    );
    final ContentPackage<NudgeItem> nudges = await _loader.load<NudgeItem>(
      nudgesAssetKey,
      expectedSchemaId: nudgesSchemaId,
      itemParser: nudgeItemFromJson,
    );

    return PhaseContentCatalogue(
      phaseContent: phaseContent,
      drip: drip,
      nudges: nudges,
      milestoneThresholds: await _milestoneThresholds(),
    );
  }

  /// The thresholds sit on the package root, which [ContentPackageLoader] does
  /// not surface, so this re-reads the one asset. The bundle caches strings, so
  /// the cost is a second decode of a small file rather than a second load.
  Future<List<int>> _milestoneThresholds() async {
    final String source =
        await (_bundle ?? rootBundle).loadString(nudgesAssetKey);

    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw ContentPackageFormatException(
        nudgesAssetKey,
        'invalid JSON: ${error.message}',
      );
    }
    if (decoded is! Map<String, Object?>) {
      throw ContentPackageFormatException(
        nudgesAssetKey,
        'expected a JSON object at the package root',
      );
    }

    return milestoneThresholdsFromJson(decoded, nudgesAssetKey);
  }
}
