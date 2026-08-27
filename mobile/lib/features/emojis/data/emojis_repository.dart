import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'emoji_catalog.dart';
import 'emoji_models.dart';

class EmojisRepository {
  EmojisRepository({
    required Dio dio,
    Future<SharedPreferences> Function()? preferences,
  })  : _dio = dio,
        _preferences = preferences ?? SharedPreferences.getInstance;

  final Dio _dio;
  final Future<SharedPreferences> Function() _preferences;

  static const String _stateCacheKey = 'cupid_couple_emojis_state_cache';

  /// Fetches latest emoji catalog from backend, falls back to static catalog if offline.
  Future<List<EmojiPack>> fetchCatalog() async {
    try {
      final response = await _dio.get<List<dynamic>>('/emojis/catalog');
      if (response.data != null && response.data!.isNotEmpty) {
        return response.data!
            .map((item) => EmojiPack.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      return cupidEmojiCatalog;
    } catch (_) {
      return cupidEmojiCatalog;
    }
  }

  /// Loads the couple's emoji state (downloaded packs, active pack).
  Future<CoupleEmojiState> getCoupleState() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/emojis/state');
      if (response.data != null) {
        final state = CoupleEmojiState.fromJson(response.data!);
        await _saveCachedState(state);
        return state;
      }
    } catch (_) {}

    return _loadCachedState();
  }

  /// Downloads / Unlocks a pack for the couple.
  Future<CoupleEmojiState> unlockOrDownloadPack(String packId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/emojis/unlock',
        data: {'packId': packId},
      );
      if (response.data != null) {
        final state = CoupleEmojiState.fromJson(response.data!);
        await _saveCachedState(state);
        return state;
      }
    } catch (_) {}

    // Local fallback update
    final current = await _loadCachedState();
    if (!current.downloadedPackIds.contains(packId)) {
      final updated = CoupleEmojiState(
        activePackId: current.activePackId,
        downloadedPackIds: [...current.downloadedPackIds, packId],
      );
      await _saveCachedState(updated);
      return updated;
    }
    return current;
  }

  /// Sets the active emoji pack for quick access.
  Future<CoupleEmojiState> setActivePack(String packId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/emojis/active',
        data: {'packId': packId},
      );
      if (response.data != null) {
        final state = CoupleEmojiState.fromJson(response.data!);
        await _saveCachedState(state);
        return state;
      }
    } catch (_) {}

    final current = await _loadCachedState();
    final updated = CoupleEmojiState(
      activePackId: packId,
      downloadedPackIds: current.downloadedPackIds,
    );
    await _saveCachedState(updated);
    return updated;
  }

  Future<void> _saveCachedState(CoupleEmojiState state) async {
    try {
      final prefs = await _preferences();
      await prefs.setString(_stateCacheKey, jsonEncode(state.toJson()));
    } catch (_) {}
  }

  Future<CoupleEmojiState> _loadCachedState() async {
    try {
      final prefs = await _preferences();
      final raw = prefs.getString(_stateCacheKey);
      if (raw != null && raw.isNotEmpty) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return CoupleEmojiState.fromJson(map);
      }
    } catch (_) {}
    return const CoupleEmojiState(
      activePackId: 'mochi-cat',
      downloadedPackIds: <String>['mochi-cat', 'baby-dino'],
    );
  }
}
