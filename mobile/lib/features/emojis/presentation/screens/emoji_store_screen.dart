import 'package:flutter/material.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import '../../data/emoji_catalog.dart';
import '../../data/emoji_models.dart';
import '../../data/emojis_repository.dart';

class EmojiStoreScreen extends StatefulWidget {
  const EmojiStoreScreen({
    super.key,
    required this.repository,
  });

  final EmojisRepository repository;

  @override
  State<EmojiStoreScreen> createState() => _EmojiStoreScreenState();
}

class _EmojiStoreScreenState extends State<EmojiStoreScreen> {
  List<EmojiPack> _catalog = cupidEmojiCatalog;
  CoupleEmojiState _state = const CoupleEmojiState(
    activePackId: 'mochi-cat',
    downloadedPackIds: <String>['mochi-cat', 'baby-dino'],
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    setState(() => _isLoading = true);
    try {
      final catalog = await widget.repository.fetchCatalog();
      final state = await widget.repository.getCoupleState();
      if (mounted) {
        setState(() {
          _catalog = catalog;
          _state = state;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDownload(String packId) async {
    try {
      final updated = await widget.repository.unlockOrDownloadPack(packId);
      if (mounted) {
        final colors = context.cupidColors;
        setState(() => _state = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã tải thành công bộ emoji vào bàn phím chat! 🎉'),
            backgroundColor: colors.colorGreen,
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Scaffold(
      appBar: CupidHeader(
        title: 'Kho Sticker & Emoji 💖',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _catalog.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final pack = _catalog[index];
                final bool isDownloaded = _state.isDownloaded(pack.id);

                return Container(
                  decoration: BoxDecoration(
                    color: colors.colorSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.colorLine),
                    boxShadow: context.cupidPlatform.elevationShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card Top Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: pack.bannerColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: EmojiPalette.pureWhite,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: EmojiPalette.black10,
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(pack.icon, style: const TextStyle(fontSize: 28)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        pack.localizedName(context),
                                        style: type.display.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: EmojiPalette.textDark,
                                        ),
                                      ),
                                      if (pack.badge != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: EmojiPalette.accentPartyPompom,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            pack.badge!.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: EmojiPalette.pureWhite,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    pack.localizedTag(context),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: EmojiPalette.textMutedDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Story description
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text(
                          pack.localizedStory(context),
                          style: type.body.copyWith(
                            fontSize: 13,
                            color: colors.colorTextMuted,
                          ),
                        ),
                      ),

                      // Preview of 20 Emojis Horizontal Ribbon
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          height: 72,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: pack.emojis.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, emojiIdx) {
                              final item = pack.emojis[emojiIdx];
                              return Container(
                                width: 64,
                                height: 64,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colors.colorSurfaceAlt.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: EmojiStickerGraphic(
                                  emoji: item,
                                  size: 46,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Action Button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: ElevatedButton(
                          onPressed: isDownloaded
                              ? null
                              : () => _handleDownload(pack.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDownloaded
                                ? colors.colorSurfaceAlt
                                : colors.colorAccentPink,
                            foregroundColor: colors.colorOnAccent,
                            disabledBackgroundColor: colors.colorSurfaceAlt,
                            disabledForegroundColor: colors.colorTextMuted,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isDownloaded ? Icons.check_circle : Icons.download,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isDownloaded
                                    ? 'Đã Có Trong Bàn Phím'
                                    : (pack.price == 0 ? 'Tải Về Miễn Phí' : 'Mở Khóa (${pack.price} ❤️)'),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
