import 'package:cupid_api/cupid_api.dart';
import 'package:cupid_mobile/design_system/theme/cupid_platform.dart';
import 'package:cupid_mobile/design_system/theme/cupid_theme.dart';
import 'package:cupid_mobile/features/themes/data/theme_catalog.dart';
import 'package:cupid_mobile/features/themes/data/theme_models.dart';
import 'package:cupid_mobile/features/themes/data/themes_repository.dart';
import 'package:cupid_mobile/features/themes/presentation/screens/theme_detail_screen.dart';
import 'package:cupid_mobile/features/themes/presentation/theme_cubit.dart';
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
    );
  }
}

void main() {
  testWidgets('ThemeDetailScreen renders mockup, title, palette, and action button in VI locale',
      (tester) async {
    final repository = _FakeThemesRepository();
    final cubit = ThemeCubit(repository: repository);
    await cubit.loadThemeState();

    final sunset = getThemeDefinition('sunset');

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        theme: buildCupidTheme(
          platform: CupidPlatform.ios,
          brightness: Brightness.dark,
        ),
        home: ThemeDetailScreen(
          theme: sunset,
          cubit: cubit,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Check header & title
    expect(find.text('Chi tiết theme'), findsOneWidget);
    expect(find.text('Hoàng Hôn Đà Lạt'), findsOneWidget);

    // Check couple preview names and chat mockup
    expect(find.text('Minh & Linh'), findsOneWidget);
    expect(find.text('Tối nay ăn gì?'), findsOneWidget);
    expect(find.text('Em nấu 🍜'), findsOneWidget);

    // Check palette colors
    expect(find.text('Dusk'), findsOneWidget);
    expect(find.text('Rosé'), findsOneWidget);
    expect(find.text('Ember'), findsOneWidget);
    expect(find.text('Butter'), findsOneWidget);
    expect(find.text('Cream'), findsOneWidget);

    // Check breakdown list
    expect(find.text('Nền màn hình chính & chuồng pet'), findsOneWidget);
    expect(find.text('Bong bóng chat & Typing Ghost'), findsOneWidget);
    expect(find.text('Dùng vĩnh viễn'), findsOneWidget);

    // Check action CTA
    expect(find.text('Mở khoá · 320 tim'), findsOneWidget);
    expect(find.text('Ví chung còn 1.240 tim'), findsOneWidget);
  });

  testWidgets('ThemeDetailScreen displays friendly error snackbar when error occurs',
      (tester) async {
    final repository = _FakeThemesRepository();
    final cubit = ThemeCubit(repository: repository);
    final sunset = getThemeDefinition('sunset');

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        theme: buildCupidTheme(
          platform: CupidPlatform.ios,
          brightness: Brightness.dark,
        ),
        home: ThemeDetailScreen(
          theme: sunset,
          cubit: cubit,
        ),
      ),
    );

    await tester.pumpAndSettle();

    cubit.emit(cubit.state.copyWith(
      errorMessage: () => 'Không tìm thấy giao diện yêu cầu.',
    ));
    await tester.pumpAndSettle();

    expect(find.text('Không tìm thấy giao diện yêu cầu.'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
  });
}
