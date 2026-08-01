import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../data/gallery_repository.dart';
import '../domain/gallery_item.dart';
import 'gallery_upload_state.dart';

/// Overridable picker seam (`coding-plan/phase-P3-gallery-upload.md` Test
/// Scope: "picker invocation ... asserted in a unit test" without ever
/// invoking the real platform channel). Defaults to
/// [GalleryUploadCubit.defaultPickImages], which calls the real
/// `ImagePicker.pickMultiImage`.
typedef GalleryImagePicker =
    Future<List<XFile>> Function({
      double? maxWidth,
      double? maxHeight,
      int? imageQuality,
    });

/// Overridable connectivity seam (`ux/uiux-spec.md` §5). Defaults to
/// [GalleryUploadCubit.defaultIsOnline], a lightweight DNS-lookup probe —
/// `connectivity_plus` is not in this phase's `pubspec.yaml` write scope.
typedef GalleryConnectivityCheck = Future<bool> Function();

/// Drives `GalleryUploadSheet` (`coding-plan/phase-P3-gallery-upload.md`
/// §3): multi-select upload with independent per-item progress/retry. Each
/// item's two-step sequence runs through `GalleryRepository.uploadPhoto`
/// (`POST /uploads` then `POST /gallery`), so a step-1 failure there never
/// issues step 2 for that item. At most [maxConcurrentUploads] items upload
/// at once; a failed item marks only itself `failed` and never blocks or
/// restarts its siblings.
class GalleryUploadCubit extends Cubit<GalleryUploadState> {
  GalleryUploadCubit({
    required this.repository,
    required this.onUploaded,
    GalleryImagePicker? pickImages,
    GalleryConnectivityCheck? isOnline,
    this.maxConcurrentUploads = 2,
  }) : _pickImages = pickImages ?? defaultPickImages,
       _isOnline = isOnline ?? defaultIsOnline,
       super(const GalleryUploadState());

  final GalleryRepository repository;
  final void Function(GalleryItem item) onUploaded;
  final GalleryImagePicker _pickImages;
  final GalleryConnectivityCheck _isOnline;
  final int maxConcurrentUploads;

  int _nextRecordId = 0;

  /// R4/D-2 downscale budget (`architecture/solution.md` §5): keeps every
  /// upload payload well under the backend's 10 MB multer limit.
  static const double maxDimension = 2048;
  static const int imageQuality = 85;

  static Future<List<XFile>> defaultPickImages({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) {
    return ImagePicker().pickMultiImage(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }

  /// No `connectivity_plus` dependency in this phase's write scope: probes a
  /// real DNS lookup instead. Any failure (including no route to host) is
  /// treated as offline.
  static Future<bool> defaultIsOnline() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  /// Invokes the device photo picker and starts uploading every selection.
  /// While offline, sets [GalleryUploadState.isOffline] and returns without
  /// picking or queuing anything (`ux/uiux-spec.md` §5: "disable the picker
  /// ... instead of queueing").
  Future<void> pick() async {
    final bool online = await _isOnline();
    if (isClosed) return;
    if (!online) {
      emit(state.copyWith(isOffline: true));
      return;
    }
    if (state.isOffline) emit(state.copyWith(isOffline: false));

    final List<XFile> picked = await _pickImages(
      maxWidth: maxDimension,
      maxHeight: maxDimension,
      imageQuality: imageQuality,
    );
    if (picked.isEmpty || isClosed) return;

    final List<GalleryUploadRecord> records = [
      for (final XFile xfile in picked)
        GalleryUploadRecord(id: _newRecordId(), file: File(xfile.path)),
    ];
    emit(state.copyWith(items: [...state.items, ...records]));
    await _uploadAll(records);
  }

  String _newRecordId() => 'upload-${_nextRecordId++}';

  /// Bounded worker pool: exactly [maxConcurrentUploads] items upload
  /// concurrently (or fewer if [records] is smaller), each worker moving to
  /// the next queued item only once its current one settles.
  Future<void> _uploadAll(List<GalleryUploadRecord> records) async {
    final List<GalleryUploadRecord> pending = List.of(records);

    Future<void> worker() async {
      while (pending.isNotEmpty) {
        final record = pending.removeAt(0);
        await _uploadOne(record);
      }
    }

    final int workerCount = maxConcurrentUploads < records.length
        ? maxConcurrentUploads
        : records.length;
    await Future.wait(List.generate(workerCount, (_) => worker()));
  }

  /// Restarts a single failed item from step 1 (`POST /uploads`); never
  /// restarts the whole batch.
  Future<void> retry(String id) async {
    GalleryUploadRecord? record;
    for (final item in state.items) {
      if (item.id == id) {
        record = item;
        break;
      }
    }
    if (record == null || record.status != GalleryUploadItemStatus.failed) {
      return;
    }
    await _uploadOne(record);
  }

  Future<void> _uploadOne(GalleryUploadRecord record) async {
    _updateRecord(
      record.id,
      status: GalleryUploadItemStatus.uploading,
      progress: 0,
    );
    try {
      final GalleryItem item = await repository.uploadPhoto(
        record.file,
        onSendProgress: (sent, total) {
          if (total <= 0) return;
          _updateRecord(record.id, progress: sent / total);
        },
      );
      if (isClosed) return;
      _updateRecord(
        record.id,
        status: GalleryUploadItemStatus.done,
        progress: 1,
      );
      onUploaded(item);
    } catch (_) {
      if (!isClosed) {
        _updateRecord(record.id, status: GalleryUploadItemStatus.failed);
      }
    }
  }

  void _updateRecord(
    String id, {
    GalleryUploadItemStatus? status,
    double? progress,
  }) {
    if (isClosed) return;
    final List<GalleryUploadRecord> items = [
      for (final item in state.items)
        item.id == id
            ? item.copyWith(status: status, progress: progress)
            : item,
    ];
    emit(state.copyWith(items: items));
  }
}
