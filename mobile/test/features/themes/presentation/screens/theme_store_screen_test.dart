import 'package:cupid_api/cupid_api.dart';
import 'package:cupid_mobile/design_system/theme/cupid_platform.dart';
import 'package:cupid_mobile/design_system/theme/cupid_theme.dart';
import 'package:cupid_mobile/features/themes/data/theme_models.dart';
import 'package:cupid_mobile/features/themes/data/themes_repository.dart';
import 'package:cupid_mobile/features/themes/presentation/screens/theme_store_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeThemesRepository extends ThemesRepository {
  _FakeThemesRepository()
      : super(api: CupidApi(dio: Dio(), interceptors: const []));

  @override
  Future<CoupleThemeState> getThemeState() async {
    return const CoupleThemeState(
      coupleId: 'userA:userB',
      activeThemeId: 'nebula',
      ownedThemeIds: <String>['nebula'],
      heartsBalance: 1240,
      wishlistThemeId: 'sakura',
      wishlistSavedBy: 'userB',
    );
  }
}

void main() {
  testWidgets('ThemeStoreScreen renders header, hero card, categories, and theme grid in VI locale',
      (tester) async {
    final repository = _FakeThemesRepository();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        theme: buildCupidTheme(
          platform: CupidPlatform.ios,
          brightness: Brightness.dark,
        ),
        home: ThemeStoreScreen(repository: repository),
      ),
    );

    await tester.pumpAndSettle();

    // Check header
    expect(find.text('Kho Theme'), findsOneWidget);

    // Check Hero "Đang dùng" & theme name
    expect(find.text('ĐANG DÙNG'), findsOneWidget);
    expect(find.text('Tinh Vân'), findsWidgets);
    expect(find.text('1.240'), findsOneWidget);

    // Check filter chips
    expect(find.text('Tất cả'), findsOneWidget);
    expect(find.text('Đã có'), findsWidgets);
    expect(find.text('Nền tối'), findsOneWidget);
    expect(find.text('Nền sáng'), findsOneWidget);
    expect(find.text('Theo mùa'), findsOneWidget);

    // Check wishlist banner
    expect(find.text('Người yêu đã lưu Mùa Hoa Anh Đào'), findsOneWidget);

    // Check theme items in grid
    expect(find.text('Hoàng Hôn Đà Lạt'), findsOneWidget);
    expect(find.text('Mùa Hoa Anh Đào'), findsOneWidget);
    expect(find.text('Đại Dương Xanh'), findsOneWidget);

    // Check commitment footer
    expect(find.textContaining('Theme là của cả hai'), findsOneWidget);
  });
}
