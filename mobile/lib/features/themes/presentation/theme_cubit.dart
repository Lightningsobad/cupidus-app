import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/theme_models.dart';
import '../data/themes_repository.dart';

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
    required this.isLoading,
    required this.isActionInProgress,
    this.errorMessage,
  });

  final ThemeCategory selectedCategory;
  final CoupleThemeState coupleState;
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
        isLoading: false,
        isActionInProgress: false,
      );

  ThemeDefinition get activeTheme => getThemeDefinition(coupleState.activeThemeId);

  ThemeDefinition? get wishlistTheme {
    final wishId = coupleState.wishlistThemeId;
    if (wishId == null) return null;
    if (coupleState.isOwned(wishId)) return null;
    return getThemeDefinition(wishId);
  }

  List<ThemeDefinition> get filteredThemes {
    return cupidThemeCatalog.where((theme) {
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
    bool? isLoading,
    bool? isActionInProgress,
    String? Function()? errorMessage,
  }) {
    return ThemeState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      coupleState: coupleState ?? this.coupleState,
      isLoading: isLoading ?? this.isLoading,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({required this.repository}) : super(ThemeState.initial());

  final ThemesRepository repository;
  Timer? _pollingTimer;

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
      final updated = await repository.getThemeState();
      emit(state.copyWith(coupleState: updated, isLoading: false));
      _checkAndStartPolling();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: () => e.toString(),
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
        errorMessage: () => e.toString(),
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
        errorMessage: () => e.toString(),
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
        errorMessage: () => e.toString(),
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
        errorMessage: () => e.toString(),
      ));
      return false;
    }
  }
}
