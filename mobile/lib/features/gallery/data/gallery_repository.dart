import 'dart:io';

import 'package:dio/dio.dart';

import '../domain/gallery_item.dart';
import 'gallery_api.dart';
import 'gallery_local_cache.dart';

/// A `GET /gallery` read result. [isStale] is `true` only when the network
/// call failed and [items] was served from [GalleryLocalCache] instead
/// (`architecture/solution.md` §4 read-through contract).
class GalleryPage {
  const GalleryPage({required this.items, required this.isStale});

  final List<GalleryItem> items;
  final bool isStale;
}

/// The single mobile owner of gallery network + cache access
/// (`architecture/solution.md` §4 Boundaries And Ownership): presentation
/// code must never call [GalleryApi] or [GalleryLocalCache] directly.
class GalleryRepository {
  GalleryRepository({required this._api, required this._cache});

  final GalleryApi _api;
  final GalleryLocalCache _cache;

  /// Read-through: on success, page 0 is written back to the cache and the
  /// result is fresh; on a [DioException], the cached snapshot is served
  /// instead and marked stale rather than throwing.
  Future<GalleryPage> fetchPage({int limit = 30, int offset = 0}) async {
    try {
      final items = await _api.fetchPage(limit: limit, offset: offset);
      if (offset == 0) {
        await _cache.save(items);
      }
      return GalleryPage(items: items, isStale: false);
    } on DioException {
      final cached = await _cache.load();
      return GalleryPage(items: cached, isStale: true);
    }
  }

  /// The first-page snapshot, always marked stale since it never reflects a
  /// live network read.
  Future<GalleryPage> cachedPage() async {
    final cached = await _cache.load();
    return GalleryPage(items: cached, isStale: true);
  }

  Future<GalleryMe> currentUser() => _api.fetchMe();

  /// Two-step upload sequence (`architecture/solution.md` §4): a step-1
  /// (`POST /uploads`) failure propagates before step 2
  /// (`POST /gallery`) is ever attempted.
  Future<GalleryItem> uploadPhoto(
    File file, {
    ProgressCallback? onSendProgress,
  }) async {
    final uploaded = await _api.uploadFile(file, onSendProgress: onSendProgress);
    return _api.createItem(
      filename: uploaded.filename,
      mimeType: uploaded.mimeType,
    );
  }
}
