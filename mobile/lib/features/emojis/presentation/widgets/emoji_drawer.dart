import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import '../../data/emoji_catalog.dart';
import '../../data/emoji_models.dart';
import '../../data/emojis_repository.dart';
import '../screens/emoji_store_screen.dart';

/// Keyboard-like bottom drawer displaying tabs for each downloaded Emoji Pack
/// and an interactive grid of emojis.
class EmojiDrawer extends StatefulWidget {
  const EmojiDrawer({
    super.key,
    required this.onEmojiSelected,
    this.emojisRepository,
    this.height = 280,
  });

  final void Function(String emojiCode, String packId) onEmojiSelected;
  final EmojisRepository? emojisRepository;
  final double height;

  @override
  State<EmojiDrawer> createState() => _EmojiDrawerState();
}

class _EmojiDrawerState extends State<EmojiDrawer> with SingleTickerProviderStateMixin {
  List<EmojiPack> _catalog = cupidEmojiCatalog;
  CoupleEmojiState _coupleState = const CoupleEmojiState(
    activePackId: 'mochi-cat',
    downloadedPackIds: <String>['mochi-cat', 'baby-dino'],
  );
  int _selectedTabIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.emojisRepository == null) return;
    setState(() => _isLoading = true);
    try {
      final catalog = await widget.emojisRepository!.fetchCatalog();
      final state = await widget.emojisRepository!.getCoupleState();
      if (mounted) {
        setState(() {
          _catalog = catalog;
          _coupleState = state;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<EmojiPack> get _downloadedPacks {
    final downloaded = _catalog
        .where((p) => _coupleState.isDownloaded(p.id))
        .toList();
    return downloaded.isNotEmpty ? downloaded : _catalog;
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final List<EmojiPack> packs = _downloadedPacks;

    if (_selectedTabIndex >= packs.length) {
      _selectedTabIndex = 0;
    }

    final EmojiPack currentPack = packs[_selectedTabIndex];

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: colors.colorSurface,
        border: Border(
          top: BorderSide(color: colors.colorLine),
        ),
      ),
      child: Column(
        children: [
          // Emoji Grid Area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: currentPack.emojis.length,
                    itemBuilder: (context, index) {
                      final item = currentPack.emojis[index];
                      return InkWell(
                        onTap: () => widget.onEmojiSelected(item.code, currentPack.id),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.colorSurfaceAlt.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: EmojiStickerGraphic(
                            emoji: item,
                            size: 52,
                            showLabel: true,
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom Pack Tabs Bar + Store Link
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colors.colorSurfaceAlt,
              border: Border(
                top: BorderSide(color: colors.colorLine.withValues(alpha: 0.5)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: packs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final p = packs[index];
                      final bool isSelected = index == _selectedTabIndex;
                      return InkWell(
                        onTap: () => setState(() => _selectedTabIndex = index),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: isSelected ? colors.gradientHot : null,
                            color: isSelected ? null : colors.colorSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected ? null : Border.all(color: colors.colorLine),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(p.icon, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                p.localizedName(context),
                                style: context.cupidType.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? colors.colorOnAccent : colors.colorText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 8),

                // Button to open Emoji Store
                InkWell(
                  onTap: () async {
                    if (widget.emojisRepository != null) {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => EmojiStoreScreen(
                            repository: widget.emojisRepository!,
                          ),
                        ),
                      );
                      unawaited(_loadData());
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.colorAccentPink.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.colorAccentPink),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_shopping_cart, size: 14, color: colors.colorAccentPink),
                        const SizedBox(width: 4),
                        Text(
                          'Kho Sticker',
                          style: context.cupidType.caption.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colors.colorAccentPink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
