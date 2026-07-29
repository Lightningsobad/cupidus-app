import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The two platform silhouettes the design source targets: iOS-style shape,
/// motion and typeface-stack conventions, and Material-style equivalents.
///
/// This is the platform axis from `ux/uiux-spec.md` section 1. It is
/// orthogonal to [Brightness] (the theme axis, see `CupidColorTokens`) and
/// never forks screen code directly — only the four adaptive widgets in
/// `design_system/adaptive/` (ADR-004, D3) branch on this enum.
enum CupidPlatform {
  ios,
  material;

  /// Resolves the platform to render, honoring a [CupidPlatformOverride]
  /// ancestor when present so tests and QA can force either platform on one
  /// device (needed to prove `story_master.md` AC 1's four combinations).
  static CupidPlatform of(BuildContext context) {
    return CupidPlatformOverride.maybeOf(context) ?? resolveDefault();
  }

  /// Resolves the platform from [defaultTargetPlatform] with no override:
  /// iOS and macOS resolve to [CupidPlatform.ios]; every other target
  /// resolves to [CupidPlatform.material].
  static CupidPlatform resolveDefault() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupidPlatform.ios;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return CupidPlatform.material;
    }
  }
}

/// Forces [CupidPlatform.of] to resolve to [platform] for every descendant,
/// regardless of [defaultTargetPlatform]. Used by widget tests and manual QA
/// to render all 4 platform x theme combinations on a single device.
class CupidPlatformOverride extends InheritedWidget {
  const CupidPlatformOverride({
    super.key,
    required this.platform,
    required super.child,
  });

  final CupidPlatform platform;

  static CupidPlatform? maybeOf(BuildContext context) {
    final CupidPlatformOverride? widget = context
        .dependOnInheritedWidgetOfExactType<CupidPlatformOverride>();
    return widget?.platform;
  }

  @override
  bool updateShouldNotify(CupidPlatformOverride oldWidget) =>
      platform != oldWidget.platform;
}
