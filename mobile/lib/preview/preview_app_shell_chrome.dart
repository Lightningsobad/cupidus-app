import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// The three `AppShell` tab destinations (`core/navigation/app_shell.dart`).
/// `chat` is listed for DEC-4 completeness even though it is not wired into
/// `previewScreens` yet (§3 of the coding plan — P8 wires it).
enum PreviewAppShellTab { home, chat, gallery }

/// STORY-018 P6 DEC-4: preview-only wrapper that reproduces the real
/// `CupidTabBar` chrome around a captured screen for registry entries with
/// `wrapInShell: true`.
///
/// It cannot mount the real `AppShell` widget itself for a non-Home tab:
/// `AppShell` always starts on its own Home tab and exposes no way to select
/// another one from outside (`core/navigation/app_shell.dart`'s `_index`
/// state is private, and adding a public initial-tab parameter is outside
/// this phase's write scope). So this composes the same production
/// `CupidTabBar` design-system widget `AppShell` uses, and drives the
/// highlighted tab from [activeTab] instead of tap state, since a static
/// capture has no tap to react to.
class PreviewAppShellChrome extends StatelessWidget {
  const PreviewAppShellChrome({
    super.key,
    required this.child,
    required this.activeTab,
  });

  final Widget child;
  final PreviewAppShellTab? activeTab;

  /// Mirrors `core/navigation/app_shell.dart`'s private `_galleryTabIcon`
  /// (same `MaterialSymbolsRounded-Variable.ttf` codepoint, confirmed there
  /// via a `fontTools` cmap lookup) — that constant is file-private, so this
  /// preview-only chrome cannot import it and redeclares it instead.
  static const IconData _galleryTabIcon = IconData(
    0xe413,
    fontFamily: CupidIcons.fontFamily,
  );

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final List<CupidTabBarItem> items = <CupidTabBarItem>[
      CupidTabBarItem(
        icon: Icons.home_rounded,
        label: context.viEn('Trang chủ', 'Home'),
      ),
      CupidTabBarItem(
        icon: Icons.chat_bubble_outline,
        label: context.viEn('Trò chuyện', 'Chat'),
      ),
      CupidTabBarItem(
        icon: _galleryTabIcon,
        label: context.viEn('Thư viện ảnh', 'Gallery'),
      ),
    ];
    final int currentIndex = switch (activeTab) {
      PreviewAppShellTab.home => 0,
      PreviewAppShellTab.chat => 1,
      PreviewAppShellTab.gallery => 2,
      null => -1,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: CupidTabBar(
        items: items,
        currentIndex: currentIndex,
        // No-op: this is a static capture target, not an interactive shell.
        onTap: (int _) {},
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'preview-account-hub-entry',
        backgroundColor: colors.colorAccentPink,
        foregroundColor: colors.colorText,
        onPressed: () {},
        child: const Icon(Icons.person),
      ),
    );
  }
}

/// Same per-file `viEn` helper pattern as e.g. `features/chat/presentation/
/// chat_strings.dart` — resolved from the ambient [Locale] rather than the
/// generated `AppL10n` ARB pipeline, scoped to this file only.
extension _PreviewChromeLocaleText on BuildContext {
  bool get _isVi => Localizations.localeOf(this).languageCode == 'vi';

  String viEn(String vi, String en) => _isVi ? vi : en;
}
