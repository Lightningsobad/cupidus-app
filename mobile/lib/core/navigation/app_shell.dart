import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../features/gallery/presentation/screens/gallery_screen.dart';
import '../../features/home/presentation/home_screen.dart';

/// `home` tab glyph, confirmed via a `fontTools` cmap lookup on the bundled
/// `MaterialSymbolsRounded-Variable.ttf` (same sourcing rule as
/// `CupidIcons`). Defined locally rather than added to `CupidIcons` because
/// this phase's write scope does not include
/// `design_system/icons/cupid_icons.dart`.
const IconData _homeTabIcon = IconData(0xe88a, fontFamily: CupidIcons.fontFamily);

/// `photo_library` glyph for the epic-4 gallery tab slot (see [_homeTabIcon]
/// for why this isn't in `CupidIcons`).
const IconData _galleryTabIcon = IconData(
  0xe413,
  fontFamily: CupidIcons.fontFamily,
);

/// Root navigation shell. STORY-013 P1 adds the first discoverable tab
/// (`ux/uiux-spec.md` §2 screen inventory: "epic-4 gallery tab" / §3 flow
/// map) alongside the placeholder `home` destination. Only the selected
/// destination is built (no `IndexedStack` of all tabs at once), so a tab
/// that is never selected never resolves its DI dependencies — in
/// particular, `GalleryScreen`'s `GalleryRepository` lookup only runs once
/// the gallery tab is actually tapped.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const List<Widget Function()> _destinationBuilders = [
    _buildHome,
    _buildGallery,
  ];

  static Widget _buildHome() => const HomeScreen();
  static Widget _buildGallery() => const GalleryScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _destinationBuilders[_currentIndex](),
      bottomNavigationBar: CupidTabBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          CupidTabBarItem(icon: _homeTabIcon, label: 'Home'),
          CupidTabBarItem(icon: _galleryTabIcon, label: 'Gallery'),
        ],
      ),
    );
  }
}
