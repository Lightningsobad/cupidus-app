import 'package:flutter/material.dart';

import '../core/config/cupid_feature_flags.dart';
import '../core/navigation/pair_gate_shell.dart';
import '../design_system/theme/cupid_platform.dart';
import '../design_system/theme/cupid_theme.dart';
import '../features/pairing/presentation/pair_gate_cubit.dart';
import '../l10n/generated/app_l10n.dart';

/// Composes flags, theme, and localization (`architecture/solution.md` ADR-004a).
/// This is the only file allowed to compose these three concerns together —
/// screens read tokens/strings through the design-system contract instead.
///
/// [createPairGateCubit] forwards to [AppShell] (see its doc comment); tests
/// that boot the full [CupidApp] use it to avoid depending on `getIt`.
class CupidApp extends StatelessWidget {
  const CupidApp({super.key, this.createPairGateCubit});

  final PairGateCubit Function()? createPairGateCubit;

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
      home: PairGateShell(createPairGateCubit: createPairGateCubit),
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
