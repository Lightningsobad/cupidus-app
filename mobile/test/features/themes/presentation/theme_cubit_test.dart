import 'package:cupid_api/cupid_api.dart';
import 'package:cupid_mobile/features/themes/data/theme_models.dart';
import 'package:cupid_mobile/features/themes/data/themes_repository.dart';
import 'package:cupid_mobile/features/themes/presentation/theme_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeThemesRepository extends ThemesRepository {
  _FakeThemesRepository()
      : super(api: CupidApi(dio: Dio(), interceptors: const []));

  CoupleThemeState mockState = const CoupleThemeState(
    coupleId: 'userA:userB',
    activeThemeId: 'nebula',
    ownedThemeIds: <String>['nebula'],
    heartsBalance: 1240,
  );

  @override
  Future<CoupleThemeState> getThemeState() async => mockState;

  @override
  Future<CoupleThemeState> requestTheme(String themeId) async {
    mockState = CoupleThemeState(
      coupleId: mockState.coupleId,
      activeThemeId: mockState.activeThemeId,
      ownedThemeIds: mockState.ownedThemeIds,
      heartsBalance: mockState.heartsBalance,
      pendingThemeId: themeId,
      pendingRequestedBy: 'userA',
    );
    return mockState;
  }

  @override
  Future<CoupleThemeState> approveTheme() async {
    mockState = CoupleThemeState(
      coupleId: mockState.coupleId,
      activeThemeId: mockState.pendingThemeId ?? 'nebula',
      ownedThemeIds: <String>[...mockState.ownedThemeIds, mockState.pendingThemeId ?? 'nebula'],
      heartsBalance: mockState.heartsBalance - 320,
      pendingThemeId: null,
      pendingRequestedBy: null,
    );
    return mockState;
  }

  @override
  Future<CoupleThemeState> rejectTheme() async {
    mockState = CoupleThemeState(
      coupleId: mockState.coupleId,
      activeThemeId: mockState.activeThemeId,
      ownedThemeIds: mockState.ownedThemeIds,
      heartsBalance: mockState.heartsBalance,
      pendingThemeId: null,
      pendingRequestedBy: null,
    );
    return mockState;
  }

  @override
  Future<CoupleThemeState> toggleWishlist(String themeId) async {
    mockState = CoupleThemeState(
      coupleId: mockState.coupleId,
      activeThemeId: mockState.activeThemeId,
      ownedThemeIds: mockState.ownedThemeIds,
      heartsBalance: mockState.heartsBalance,
      wishlistThemeId: mockState.wishlistThemeId == themeId ? null : themeId,
    );
    return mockState;
  }
}

void main() {
  group('ThemeCubit', () {
    late _FakeThemesRepository repository;
    late ThemeCubit cubit;

    setUp(() {
      repository = _FakeThemesRepository();
      cubit = ThemeCubit(repository: repository);
    });

    test('initial state has default nebula and category all', () {
      expect(cubit.state.selectedCategory, ThemeCategory.all);
      expect(cubit.state.coupleState.activeThemeId, 'nebula');
      expect(cubit.state.activeTheme.id, 'nebula');
      expect(cubit.state.filteredThemes.length, 8);
    });

    test('loadThemeState fetches state from repository', () async {
      repository.mockState = const CoupleThemeState(
        coupleId: 'userA:userB',
        activeThemeId: 'sunset',
        ownedThemeIds: <String>['nebula', 'sunset'],
        heartsBalance: 920,
      );

      await cubit.loadThemeState();

      expect(cubit.state.coupleState.activeThemeId, 'sunset');
      expect(cubit.state.activeTheme.id, 'sunset');
      expect(cubit.state.coupleState.heartsBalance, 920);
    });

    test('setCategory filters themes appropriately', () {
      cubit.setCategory(ThemeCategory.light);
      expect(cubit.state.filteredThemes.every((t) => t.isLight), isTrue);

      cubit.setCategory(ThemeCategory.seasonal);
      expect(
        cubit.state.filteredThemes.every(
          (t) => t.badge == 'seasonal' || t.badge == 'limited',
        ),
        isTrue,
      );
    });

    test('requestTheme sets pending theme', () async {
      final success = await cubit.requestTheme('sunset');
      expect(success, isTrue);
      expect(cubit.state.coupleState.pendingThemeId, 'sunset');
      expect(cubit.state.coupleState.isPending('sunset'), isTrue);
    });

    test('approveTheme unlocks, activates and updates balance', () async {
      await cubit.requestTheme('sunset');
      final success = await cubit.approveTheme();
      expect(success, isTrue);
      expect(cubit.state.coupleState.activeThemeId, 'sunset');
      expect(cubit.state.coupleState.ownedThemeIds, contains('sunset'));
      expect(cubit.state.coupleState.heartsBalance, 1240 - 320);
      expect(cubit.state.coupleState.pendingThemeId, isNull);
    });
  });
}
