import 'package:cupid_api/cupid_api.dart';
import 'package:dio/dio.dart';
import 'theme_models.dart';

class ThemesRepository {
  const ThemesRepository({required this.api});

  final CupidApi api;

  Future<CoupleThemeState> getThemeState() async {
    final response = await api.dio.get<Map<String, dynamic>>('/themes/state');
    if (response.data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Empty response for themes state',
      );
    }
    return CoupleThemeState.fromJson(response.data!);
  }

  Future<CoupleThemeState> requestTheme(String themeId) async {
    final response = await api.dio.post<Map<String, dynamic>>(
      '/themes/request',
      data: <String, dynamic>{'themeId': themeId},
    );
    if (response.data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Empty response for request theme',
      );
    }
    return CoupleThemeState.fromJson(response.data!);
  }

  Future<CoupleThemeState> approveTheme() async {
    final response =
        await api.dio.post<Map<String, dynamic>>('/themes/approve');
    if (response.data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Empty response for approve theme',
      );
    }
    return CoupleThemeState.fromJson(response.data!);
  }

  Future<CoupleThemeState> rejectTheme() async {
    final response = await api.dio.post<Map<String, dynamic>>('/themes/reject');
    if (response.data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Empty response for reject theme',
      );
    }
    return CoupleThemeState.fromJson(response.data!);
  }

  Future<CoupleThemeState> toggleWishlist(String themeId) async {
    final response = await api.dio.post<Map<String, dynamic>>(
      '/themes/wishlist',
      data: <String, dynamic>{'themeId': themeId},
    );
    if (response.data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Empty response for wishlist theme',
      );
    }
    return CoupleThemeState.fromJson(response.data!);
  }
}
