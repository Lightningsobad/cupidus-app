import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/gallery_item.dart';

/// Offline read-through snapshot for the gallery grid's first page
/// (`architecture/solution.md` §4 Affected Components And Layers, §6 Option
/// Evaluation — a `shared_preferences` snapshot in place of a Drift cache,
/// since `drift` is not yet in `mobile/pubspec.yaml` in this worktree).
/// Stores the first page only; there is no offline write queue.
class GalleryLocalCache {
  GalleryLocalCache({Future<SharedPreferences> Function()? preferences})
      : _preferences = preferences ?? SharedPreferences.getInstance;

  static const _storageKey = 'gallery.snapshot.v1';

  final Future<SharedPreferences> Function() _preferences;

  Future<void> save(List<GalleryItem> items) async {
    final prefs = await _preferences();
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<List<GalleryItem>> load() async {
    final prefs = await _preferences();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return const <GalleryItem>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((entry) => GalleryItem.fromJson(entry as Map<String, dynamic>))
        .toList(growable: false);
  }
}
