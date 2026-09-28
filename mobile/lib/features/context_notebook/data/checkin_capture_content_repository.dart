import '../../../core/content/content_package.dart';
import '../domain/checkin_capture_content.dart';

/// Loads the REQ-017 check-in capture copy package. Asset-only, like every other
/// content package: no HTTP client and no model call on this path.
class CheckinCaptureContentRepository {
  CheckinCaptureContentRepository({ContentPackageLoader? loader})
      : _loader = loader ?? const ContentPackageLoader();

  final ContentPackageLoader _loader;

  CheckinCaptureCopySet? _cached;

  Future<CheckinCaptureCopySet> load() async {
    return _cached ??= CheckinCaptureCopySet(
      await _loader.load<CheckinCaptureCopy>(
        checkinCaptureAssetKey,
        expectedSchemaId: checkinCaptureSchemaId,
        itemParser: checkinCaptureCopyFromJson,
      ),
    );
  }
}
