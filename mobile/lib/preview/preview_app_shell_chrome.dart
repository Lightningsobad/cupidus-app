import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// The five `AppShell` tab destinations (`core/navigation/app_shell.dart`).
/// This set must stay a faithful mirror of `AppShell`'s destination list:
/// captures are taken through this chrome, not through the real shell, so a
/// drift here makes a shell-shape criterion pass in production and still fail
/// in the evidence.
enum PreviewAppShellTab { home, chat, pet, viChung, toi }

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

  @override
  Widget build(BuildContext context) {
    final List<CupidTabBarItem> items = <CupidTabBarItem>[
      CupidTabBarItem(
        icon: Icons.home_rounded,
        label: context.viEn('Nhà', 'Home'),
      ),
      CupidTabBarItem(
        icon: Icons.chat_bubble_outline,
        label: context.viEn('Trò chuyện', 'Chat'),
      ),
      CupidTabBarItem(
        icon: CupidIcons.pets,
        label: context.viEn('Pet', 'Pet'),
      ),
      CupidTabBarItem(
        icon: CupidIcons.savings,
        label: context.viEn('Ví chung', 'Wallet'),
      ),
      CupidTabBarItem(
        icon: CupidIcons.person,
        label: context.viEn('Tôi', 'Me'),
      ),
    ];
    final int currentIndex = switch (activeTab) {
      PreviewAppShellTab.home => 0,
      PreviewAppShellTab.chat => 1,
      PreviewAppShellTab.pet => 2,
      PreviewAppShellTab.viChung => 3,
      PreviewAppShellTab.toi => 4,
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
