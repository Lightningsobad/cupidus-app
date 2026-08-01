import 'vibe_mood.dart';

/// TypeORM `Vibe` row shape (`architecture/solution.md` §2: `id`, `userId`,
/// `mood`, `note?`, `createdAt`). `note` is parsed but unused in v1 UI.
class VibeEntry {
  const VibeEntry({
    required this.id,
    required this.mood,
    required this.createdAt,
    this.note,
  });

  final String id;
  final VibeMood mood;
  final DateTime createdAt;
  final String? note;

  /// Returns `null` when `mood` is not one of the 5 frozen wire values
  /// (R-010-5), so the caller skips the entry instead of throwing.
  static VibeEntry? fromJson(Map<String, dynamic> json) {
    final mood = VibeMood.fromWire(json['mood'] as String);
    if (mood == null) {
      return null;
    }
    return VibeEntry(
      id: json['id'] as String,
      mood: mood,
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String?,
    );
  }
}
