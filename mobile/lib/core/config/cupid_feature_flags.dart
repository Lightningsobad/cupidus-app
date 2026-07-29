/// Build-time enablement flags (`architecture/solution.md` ADR-004a).
///
/// These gate **exposure** only. Light theme and the `en` locale remain
/// fully built and directly constructible in tests regardless of flag
/// state — OQ5 forbids gating existence, only user-facing selection.
abstract final class CupidFeatureFlags {
  static const bool enableLightTheme = bool.fromEnvironment(
    'CUPID_ENABLE_LIGHT_THEME',
    defaultValue: false,
  );

  static const bool enableEnLocale = bool.fromEnvironment(
    'CUPID_ENABLE_EN_LOCALE',
    defaultValue: false,
  );
}
