import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/cupid_auth_token_provider.dart';

/// Provides JWT token storage and retrieval via SharedPreferences
class JwtTokenProvider implements CupidAuthTokenProvider {
  static const String tokenKey = 'cupid_jwt_access_token';
  static const String userEmailKey = 'cupid_user_email';
  static const String userIdKey = 'cupid_user_id';

  String? _cachedToken;

  Future<void> saveSession({
    required String token,
    required String email,
    required String userId,
  }) async {
    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setString(userEmailKey, email);
    await prefs.setString(userIdKey, userId);
  }

  Future<void> clearSession() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userEmailKey);
    await prefs.remove(userIdKey);
  }

  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<String?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  @override
  Future<String?> readAccessToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(tokenKey);
    return _cachedToken;
  }

  @override
  Future<String?> refreshAccessToken() async {
    return readAccessToken();
  }
}
