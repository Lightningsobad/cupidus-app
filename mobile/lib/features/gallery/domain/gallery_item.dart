/// Mobile-side gallery item contract (`architecture/solution.md` §2, §4).
///
/// Deliberately does not model the backend `isEncrypted`/`encryptionKeyId`
/// fields: `architecture/solution.md` §5 D-1 rules them vestigial from the
/// abandoned Private Gallery concept, so this story must not read them or
/// derive any lock affordance from them.
class GalleryItem {
  const GalleryItem({
    required this.id,
    required this.userId,
    required this.filename,
    required this.createdAt,
    this.thumbnailUrl,
    this.mimeType,
  });

  final String id;
  final String userId;
  final String filename;
  final DateTime createdAt;
  final String? thumbnailUrl;
  final String? mimeType;

  factory GalleryItem.fromJson(Map<String, dynamic> json) => GalleryItem(
        id: json['id'] as String,
        userId: json['userId'] as String,
        filename: json['filename'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        thumbnailUrl: json['thumbnailUrl'] as String?,
        mimeType: json['mimeType'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'filename': filename,
        'createdAt': createdAt.toIso8601String(),
        'thumbnailUrl': thumbnailUrl,
        'mimeType': mimeType,
      };
}
