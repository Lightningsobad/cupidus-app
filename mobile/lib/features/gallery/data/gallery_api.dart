import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/cupid_api.dart';
import '../domain/gallery_item.dart';

/// `POST /uploads` response contract (`architecture/solution.md` §2): only
/// `filename` and `mimeType` are consumed downstream by `POST /gallery`.
class GalleryUploadResult {
  const GalleryUploadResult({required this.filename, this.mimeType});

  final String filename;
  final String? mimeType;
}

/// `GET /users/me` response contract, narrowed to the two fields this story
/// uses (`architecture/solution.md` §2 A-2): `id` for uploader-badge
/// attribution and `partnerId` for the AC3 pairing gate.
class GalleryMe {
  const GalleryMe({required this.id, this.partnerId});

  final String id;
  final String? partnerId;
}

/// `${CupidApiConfig.baseUrl}/uploads/${filename}` with no double slash
/// (`architecture/solution.md` §2 static media derivation). The backend
/// never populates `GalleryItem.thumbnailUrl` today, but callers should
/// still prefer a non-empty `thumbnailUrl` over this derived URL when one is
/// ever present.
String galleryMediaUrl(String filename) {
  final base = CupidApiConfig.baseUrl.endsWith('/')
      ? CupidApiConfig.baseUrl.substring(0, CupidApiConfig.baseUrl.length - 1)
      : CupidApiConfig.baseUrl;
  final name = filename.startsWith('/') ? filename.substring(1) : filename;
  return '$base/uploads/$name';
}

/// The single mobile network entry point for the frozen (A1) backend
/// `gallery`/`uploads` contract (`architecture/solution.md` §4
/// Boundaries And Ownership, D-3 generated-client constraint). Calls the
/// shared `CupidApi.dio` directly and maps JSON by hand: the generated
/// `Epic4PrivateGalleryApi` methods all return `Response<void>` and
/// `/uploads` is absent from the OpenAPI spec entirely, so the generated
/// client is unusable here.
class GalleryApi {
  GalleryApi({required this._api});

  final CupidApi _api;

  Future<List<GalleryItem>> fetchPage({int limit = 30, int offset = 0}) async {
    final response = await _api.dio.get<List<dynamic>>(
      '/gallery',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final items = response.data ?? const <dynamic>[];
    return items
        .map((raw) => GalleryItem.fromJson(raw as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<GalleryUploadResult> uploadFile(
    File file, {
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });
    final response = await _api.dio.post<Map<String, dynamic>>(
      '/uploads',
      data: formData,
      onSendProgress: onSendProgress,
    );
    final body = response.data ?? const <String, dynamic>{};
    return GalleryUploadResult(
      filename: body['filename'] as String,
      mimeType: body['mimeType'] as String?,
    );
  }

  Future<GalleryItem> createItem({
    required String filename,
    String? mimeType,
  }) async {
    final response = await _api.dio.post<Map<String, dynamic>>(
      '/gallery',
      data: {'filename': filename, if (mimeType != null) 'mimeType': mimeType},
    );
    return GalleryItem.fromJson(response.data!);
  }

  Future<GalleryMe> fetchMe() async {
    final response = await _api.dio.get<Map<String, dynamic>>('/users/me');
    final body = response.data ?? const <String, dynamic>{};
    return GalleryMe(
      id: body['id'] as String,
      partnerId: body['partnerId'] as String?,
    );
  }
}
