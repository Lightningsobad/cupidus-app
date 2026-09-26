import '../../../core/content/content_package.dart';
import 'invite_preset.dart';

/// One schema id for every category (`architecture/contract-summary.md` §2).
/// STORY-007 must not mint `req016.presets.thanks.v1`: a per-category schema id
/// would fork the content gate into a second branch and break AC-29.
const String presetsSchemaId = 'req016.presets.v1';

/// The only category this story ships (AC-22).
const String inviteCategoryId = 'invite';

/// Category id to asset key by string convention, not by a lookup table:
/// adding a category is adding a file, never editing this line (AC-21/AC-29).
String presetAssetKey(String categoryId) =>
    'assets/data/req016/presets.$categoryId.v1.json';

/// Loads shipped preset packages by category. Parsing is per-category and
/// happens once — the sheet flips between frames constantly (AC-27), and a
/// re-parse on every flip would make N a performance property of the data,
/// which R-15b forbids.
class PresetCatalogue {
  PresetCatalogue({ContentPackageLoader loader = const ContentPackageLoader()})
      : _loader = loader;

  final ContentPackageLoader _loader;
  final Map<String, Future<ContentPackage<InvitePreset>>> _packages =
      <String, Future<ContentPackage<InvitePreset>>>{};

  Future<ContentPackage<InvitePreset>> load(String categoryId) =>
      _packages.putIfAbsent(
        categoryId,
        () => _loader.load<InvitePreset>(
          presetAssetKey(categoryId),
          expectedSchemaId: presetsSchemaId,
          itemParser: invitePresetFromJson,
        ),
      );
}
