import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/theme_models.dart';
import '../data/theme_preferences_store.dart';
import '../data/themes_repository.dart';

String _formatErrorMessage(Object error) {
  if (error is DioException) {
    final dynamic data = error.response?.data;
    if (data is Map) {
      final dynamic msg = data['message'];
      if (msg is List) {
        return msg.join(', ');
      }
      if (msg is String && msg.isNotEmpty) {
        if (msg.contains('Not enough hearts')) {
          return 'Không đủ tim trong ví chung để đổi theme này.';
        }
        if (msg.contains('must be paired')) {
          return 'Cần kết đôi với người yêu để sử dụng Kho Theme.';
        }
        if (msg.contains('already active')) {
          return 'Theme này hiện đang được áp dụng.';
        }
        if (msg.contains('not found in catalog')) {
          return 'Không tìm thấy giao diện yêu cầu.';
        }
        if (msg.contains('No pending theme request')) {
          return 'Không có yêu cầu đổi theme nào đang chờ duyệt.';
        }
        if (msg.contains('Cannot approve your own')) {
          return 'Bạn không thể tự duyệt yêu cầu đổi theme của chính mình.';
        }
        return msg;
      }
    }
    if (error.response?.statusCode == 404) {
      return 'Không tìm thấy thông tin giao diện.';
    }
    if (error.response?.statusCode == 400) {
      return 'Yêu cầu đổi giao diện không hợp lệ.';
    }
    if (error.response?.statusCode == 403) {
      return 'Bạn không có quyền thực hiện thao tác này.';
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng.';
    }
  }
  return 'Đã xảy ra lỗi khi thực hiện thao tác.';
}

enum ThemeCategory {
  all,
  owned,
  dark,
  light,
  seasonal,
}

extension ThemeCategoryX on ThemeCategory {
  String labelVi() {
    switch (this) {
      case ThemeCategory.all:
        return 'Tất cả';
      case ThemeCategory.owned:
        return 'Đã có';
      case ThemeCategory.dark:
        return 'Nền tối';
      case ThemeCategory.light:
        return 'Nền sáng';
      case ThemeCategory.seasonal:
        return 'Theo mùa';
    }
  }

  String labelEn() {
    switch (this) {
      case ThemeCategory.all:
        return 'All';
      case ThemeCategory.owned:
        return 'Owned';
      case ThemeCategory.dark:
        return 'Dark';
      case ThemeCategory.light:
        return 'Light';
      case ThemeCategory.seasonal:
        return 'Seasonal';
    }
  }
}

class ThemeState {
  const ThemeState({
    required this.selectedCategory,
    required this.coupleState,
    required this.catalog,
    required this.isEffectsEnabled,
    required this.isLoading,
    required this.isActionInProgress,
    this.errorMessage,
  });

  final ThemeCategory selectedCategory;
  final CoupleThemeState coupleState;
  final List<ThemeDefinition> catalog;
  final bool isEffectsEnabled;
  final bool isLoading;
  final bool isActionInProgress;
  final String? errorMessage;

  factory ThemeState.initial() => const ThemeState(
        selectedCategory: ThemeCategory.all,
        coupleState: CoupleThemeState(
          coupleId: '',
          activeThemeId: 'nebula',
          ownedThemeIds: <String>['nebula'],
          heartsBalance: 1240,
        ),
        catalog: cupidThemeCatalog,
        isEffectsEnabled: true,
        isLoading: false,
        isActionInProgress: false,
      );

  ThemeDefinition get activeTheme =>
      getThemeDefinition(coupleState.activeThemeId, catalog);

  ThemeDefinition? get wishlistTheme {
    final wishId = coupleState.wishlistThemeId;
    if (wishId == null) return null;
    if (coupleState.isOwned(wishId)) return null;
    return getThemeDefinition(wishId, catalog);
  }

  List<ThemeDefinition> get filteredThemes {
    return catalog.where((theme) {
      switch (selectedCategory) {
        case ThemeCategory.all:
          return true;
        case ThemeCategory.owned:
          return coupleState.isOwned(theme.id);
        case ThemeCategory.light:
          return theme.isLight;
        case ThemeCategory.seasonal:
          return theme.badge == 'seasonal' || theme.badge == 'limited';
        case ThemeCategory.dark:
          return !theme.isLight;
      }
    }).toList();
  }

  ThemeState copyWith({
    ThemeCategory? selectedCategory,
    CoupleThemeState? coupleState,
    List<ThemeDefinition>? catalog,
    bool? isEffectsEnabled,
    bool? isLoading,
    bool? isActionInProgress,
    String? Function()? errorMessage,
  }) {
    return ThemeState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      coupleState: coupleState ?? this.coupleState,
      catalog: catalog ?? this.catalog,
      isEffectsEnabled: isEffectsEnabled ?? this.isEffectsEnabled,
      isLoading: isLoading ?? this.isLoading,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({
    required this.repository,
    ThemePreferencesStore? preferencesStore,
  })  : _preferencesStore = preferencesStore ?? ThemePreferencesStore(),
        super(ThemeState.initial());

  final ThemesRepository repository;
  final ThemePreferencesStore _preferencesStore;
  Timer? _pollingTimer;

  Future<void> setEffectsEnabled(bool enabled) async {
    emit(state.copyWith(isEffectsEnabled: enabled));
    try {
      await _preferencesStore.setEffectsEnabled(enabled);
    } catch (_) {}
  }

  void _checkAndStartPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    if (state.coupleState.pendingThemeId != null) {
      _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
        try {
          final updated = await repository.getThemeState();
          final hadPending = state.coupleState.pendingThemeId != null;
          final isNowResolved = updated.pendingThemeId == null;
          if (isNowResolved && hadPending) {
            _pollingTimer?.cancel();
            _pollingTimer = null;
          }
          emit(state.copyWith(coupleState: updated, isLoading: false));
        } catch (_) {}
      });
    }
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    return super.close();
  }

  Future<void> loadThemeState() async {
    emit(state.copyWith(isLoading: true, errorMessage: () => null));
    try {
      final updatedStateFuture = repository.getThemeState();
      final updatedCatalogFuture = repository.getCatalog();
      final effectsFuture = _preferencesStore.isEffectsEnabled();

      final updated = await updatedStateFuture;
      final catalog = await updatedCatalogFuture;
      final effects = await effectsFuture;

      emit(state.copyWith(
        coupleState: updated,
        catalog: catalog,
        isEffectsEnabled: effects,
        isLoading: false,
      ));
      _checkAndStartPolling();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: () => _formatErrorMessage(e),
      ));
    }
  }

  void setCoupleState(CoupleThemeState updated) {
    emit(state.copyWith(coupleState: updated, isLoading: false));
    _checkAndStartPolling();
  }

  void setCategory(ThemeCategory category) {
    emit(state.copyWith(selectedCategory: category));
  }

  Future<bool> requestTheme(String themeId) async {
    emit(state.copyWith(isActionInProgress: true, errorMessage: () => null));
    try {
      final updated = await repository.requestTheme(themeId);
      emit(state.copyWith(coupleState: updated, isActionInProgress: false));
      _checkAndStartPolling();
      return true;
    } catch (e) {
      emit(state.copyWith(
        isActionInProgress: false,
        errorMessage: () => _formatErrorMessage(e),
      ));
      return false;
    }
  }

  Future<bool> approveTheme() async {
    emit(state.copyWith(isActionInProgress: true, errorMessage: () => null));
    try {
      final updated = await repository.approveTheme();
      emit(state.copyWith(coupleState: updated, isActionInProgress: false));
      _checkAndStartPolling();
      return true;
    } catch (e) {
      emit(state.copyWith(
        isActionInProgress: false,
        errorMessage: () => _formatErrorMessage(e),
      ));
      return false;
    }
  }

  Future<bool> rejectTheme() async {
    emit(state.copyWith(isActionInProgress: true, errorMessage: () => null));
    try {
      final updated = await repository.rejectTheme();
      emit(state.copyWith(coupleState: updated, isActionInProgress: false));
      _checkAndStartPolling();
      return true;
    } catch (e) {
      emit(state.copyWith(
        isActionInProgress: false,
        errorMessage: () => _formatErrorMessage(e),
      ));
      return false;
    }
  }

  Future<bool> toggleWishlist(String themeId) async {
    emit(state.copyWith(isActionInProgress: true, errorMessage: () => null));
    try {
      final updated = await repository.toggleWishlist(themeId);
      emit(state.copyWith(coupleState: updated, isActionInProgress: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isActionInProgress: false,
        errorMessage: () => _formatErrorMessage(e),
      ));
      return false;
    }
  }
}
