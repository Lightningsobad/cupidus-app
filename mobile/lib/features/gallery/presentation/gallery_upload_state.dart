import 'dart:io';

/// Per-item lifecycle inside a `GalleryUploadCubit` batch
/// (`coding-plan/phase-P3-gallery-upload.md` §3): a failure marks only its
/// own item `failed` and never affects sibling items in the same batch
/// (AC "Selecting N photos produces N independent upload records").
enum GalleryUploadItemStatus { queued, uploading, done, failed }

/// One selected photo's upload record, keyed by [id] so `GalleryUploadCubit`
/// can update or retry a single item without touching the others.
class GalleryUploadRecord {
  const GalleryUploadRecord({
    required this.id,
    required this.file,
    this.status = GalleryUploadItemStatus.queued,
    this.progress = 0.0,
  });

  final String id;
  final File file;
  final GalleryUploadItemStatus status;

  /// `0.0`-`1.0`, driven by `POST /uploads`'s `onSendProgress` callback.
  final double progress;

  GalleryUploadRecord copyWith({
    GalleryUploadItemStatus? status,
    double? progress,
  }) {
    return GalleryUploadRecord(
      id: id,
      file: file,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }
}

/// `GalleryUploadSheet`'s state (`coding-plan/phase-P3-gallery-upload.md`
/// §3): [items] holds every record picked in the current sheet session;
/// [isOffline] gates the picker per `ux/uiux-spec.md` §5 ("disable the
/// picker with an explanatory inline message" instead of queueing a write).
class GalleryUploadState {
  const GalleryUploadState({
    this.items = const <GalleryUploadRecord>[],
    this.isOffline = false,
  });

  final List<GalleryUploadRecord> items;
  final bool isOffline;

  GalleryUploadState copyWith({
    List<GalleryUploadRecord>? items,
    bool? isOffline,
  }) {
    return GalleryUploadState(
      items: items ?? this.items,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}
