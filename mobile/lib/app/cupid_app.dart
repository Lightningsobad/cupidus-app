import 'package:flutter/material.dart';

import '../core/config/cupid_feature_flags.dart';
import '../design_system/theme/cupid_app_background.dart';
import '../design_system/theme/cupid_platform.dart';
import '../design_system/theme/cupid_theme.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/session_gate_cubit.dart';
import '../features/pairing/presentation/pair_gate_cubit.dart';
import '../features/zodiac/presentation/zodiac_red_flag_screen.dart';
import '../l10n/generated/app_l10n.dart';

/// Composes flags, theme, and localization (`architecture/solution.md` ADR-004a).
/// This is the only file allowed to compose these three concerns together —
/// screens read tokens/strings through the design-system contract instead.
///
/// REQ-002 STORY-001 ADR-1: the entry route is [SplashScreen], not the pair
/// gate. The pair gate is what splash replaces itself with once the session
/// check says the user is authenticated (ADR-2).
///
/// [createSessionGateCubit] and [createPairGateCubit] are the two injection
/// points a full-[CupidApp] widget test needs: the first drives the launch
/// session check, the second the pairing check splash hands off to. Both
/// default to null so the production tree falls back to the `getIt`-backed
/// defaults owned by [SplashScreen] and [PairGateShell].
class CupidApp extends StatelessWidget {
  const CupidApp({
    super.key,
    this.createPairGateCubit,
    this.createSessionGateCubit,
  });

  final PairGateCubit Function()? createPairGateCubit;
  final SessionGateCubit Function()? createSessionGateCubit;

  @override
  Widget build(BuildContext context) {
    final CupidPlatform platform = CupidPlatform.of(context);

    return MaterialApp(
      title: 'Cupid',
      theme: buildCupidTheme(
        platform: platform,
        brightness: Brightness.light,
      ),
      darkTheme: buildCupidTheme(
        platform: platform,
        brightness: Brightness.dark,
      ),
      themeMode: CupidFeatureFlags.enableLightTheme
          ? ThemeMode.system
          : ThemeMode.dark,
      locale: CupidFeatureFlags.enableEnLocale ? null : const Locale('vi'),
      localeResolutionCallback: CupidFeatureFlags.enableEnLocale
          ? _resolveLocaleFollowingDeviceWithViFallback
          : null,
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      builder: (BuildContext context, Widget? child) =>
          CupidAppBackground(child: child ?? const SizedBox.shrink()),
      home: SplashScreen(
        createSessionGateCubit: createSessionGateCubit,
        createPairGateCubit: createPairGateCubit,
      ),
      // Named routes for screens pushed above the shell. `home:` stays the
      // entry route, so this map must never carry a `'/'` key — `MaterialApp`
      // asserts on that combination.
      routes: <String, WidgetBuilder>{
        ZodiacRedFlagScreen.routeName: (BuildContext context) =>
            const ZodiacRedFlagScreen(),
      },
    );
  }
}

/// Follows the device locale when supported; falls back to `vi` (never the
/// arbitrary first entry in [AppL10n.supportedLocales]) when it is not.
Locale _resolveLocaleFollowingDeviceWithViFallback(
  Locale? deviceLocale,
  Iterable<Locale> supportedLocales,
) {
  if (deviceLocale != null) {
    for (final Locale locale in supportedLocales) {
      if (locale.languageCode == deviceLocale.languageCode) {
        return locale;
      }
    }
  }
  return const Locale('vi');
}
