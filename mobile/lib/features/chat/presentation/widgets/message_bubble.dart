import 'package:cached_network_image/cached_network_image.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/emojis/data/emoji_catalog.dart';
import 'package:flutter/material.dart';

import '../chat_strings.dart';

const BorderRadius _mineRadius = BorderRadius.only(
  topLeft: Radius.circular(22),
  topRight: Radius.circular(22),
  bottomRight: Radius.circular(7),
  bottomLeft: Radius.circular(22),
);

const BorderRadius _theirsRadius = BorderRadius.only(
  topLeft: Radius.circular(22),
  topRight: Radius.circular(22),
  bottomRight: Radius.circular(22),
  bottomLeft: Radius.circular(7),
);

const double _maxWidthFactor = 0.78;
const double _bubblePaddingX = 15;
const double _bubblePaddingY = 11;
const double _bubbleFontSize = 15.5;
const double _bubbleLineHeight = 1.4;
const double _metaFontSize = 10;
const double _metaIconSize = 12;

String resolveImageUrl(String content) {
  if (content.startsWith('http://') || content.startsWith('https://')) {
    return content;
  }
  final base = CupidApiConfig.baseUrl.endsWith('/')
      ? CupidApiConfig.baseUrl.substring(0, CupidApiConfig.baseUrl.length - 1)
      : CupidApiConfig.baseUrl;
  final name = content.startsWith('/') ? content.substring(1) : content;
  if (name.startsWith('uploads/')) {
    return '$base/$name';
  }
  return '$base/uploads/$name';
}

/// MessageBubble rendering Text, Photo/Image (with disk caching & fullscreen viewer),
/// or rich Emoji Stickers.
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, required this.isMine});

  final Message message;
  final bool isMine;

  bool get _isImage => message.type == 'image';
  bool get _isEmoji => message.type == 'emoji';

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final String timestamp = _formatTimestamp(message.createdAt);
    final bool seen = message.status == 'seen';

    final String semanticLabel = isMine
        ? ChatStrings.mineBubbleSemanticLabel(
            context: context,
            content: _isImage ? 'Hình ảnh' : message.content,
            timestamp: timestamp,
            seen: seen,
          )
        : ChatStrings.theirBubbleSemanticLabel(
            context: context,
            content: _isImage ? 'Hình ảnh' : message.content,
            timestamp: timestamp,
          );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Semantics(
        container: true,
        label: semanticLabel,
        excludeSemantics: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * _maxWidthFactor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (_isImage)
                _ImageBubbleContent(
                  imageUrl: resolveImageUrl(message.content),
                  isMine: isMine,
                  colors: colors,
                )
              else if (_isEmoji)
                _EmojiBubbleContent(
                  emojiCode: message.content,
                  isMine: isMine,
                )
              else
                _TextBubbleContent(
                  content: message.content,
                  isMine: isMine,
                  colors: colors,
                  type: type,
                ),
              const SizedBox(height: CupidSpacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timestamp,
                    style: type.caption.copyWith(
                      fontSize: _metaFontSize,
                      color: colors.colorTextMuted,
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: CupidSpacing.xs),
                    Icon(
                      seen ? Icons.done_all : Icons.check,
                      size: _metaIconSize,
                      color: colors.colorMint,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextBubbleContent extends StatelessWidget {
  const _TextBubbleContent({
    required this.content,
    required this.isMine,
    required this.colors,
    required this.type,
  });

  final String content;
  final bool isMine;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _bubblePaddingX,
        vertical: _bubblePaddingY,
      ),
      decoration: BoxDecoration(
        gradient: isMine ? colors.gradientHot : null,
        color: isMine ? null : colors.colorSurface,
        borderRadius: isMine ? _mineRadius : _theirsRadius,
        boxShadow: isMine
            ? colors.glowShadow
            : context.cupidPlatform.elevationShadow,
      ),
      child: Text(
        content,
        style: type.body.copyWith(
          fontSize: _bubbleFontSize,
          height: _bubbleLineHeight,
          color: isMine ? colors.colorOnAccent : colors.colorText,
        ),
      ),
    );
  }
}

class _ImageBubbleContent extends StatelessWidget {
  const _ImageBubbleContent({
    required this.imageUrl,
    required this.isMine,
    required this.colors,
  });

  final String imageUrl;
  final bool isMine;
  final CupidColorTokens colors;

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _FullScreenPhotoViewer(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = isMine ? _mineRadius : _theirsRadius;

    return GestureDetector(
      onTap: () => _openFullScreen(context),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 240,
          maxHeight: 280,
          minWidth: 140,
          minHeight: 120,
        ),
        decoration: BoxDecoration(
          color: colors.colorSurface,
          borderRadius: radius,
          boxShadow: isMine
              ? colors.glowShadow
              : context.cupidPlatform.elevationShadow,
          border: Border.all(
            color: isMine ? colors.colorAccentPink.withValues(alpha: 0.3) : colors.colorLine,
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Hero(
            tag: imageUrl,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: colors.colorSurfaceAlt,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.colorAccentPink,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: colors.colorSurfaceAlt,
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 28, color: colors.colorRed),
                    const SizedBox(height: 4),
                    Text(
                      'Ảnh đã lưu',
                      style: context.cupidType.caption.copyWith(
                        color: colors.colorTextMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmojiBubbleContent extends StatelessWidget {
  const _EmojiBubbleContent({
    required this.emojiCode,
    required this.isMine,
  });

  final String emojiCode;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final emojiItem = findEmojiItem(emojiCode);

    if (emojiItem != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: EmojiStickerGraphic(
          emoji: emojiItem,
          size: 96,
          showLabel: false,
        ),
      );
    }

    // Fallback for plain emoji symbols
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        emojiCode,
        style: const TextStyle(fontSize: 48),
      ),
    );
  }
}

class _FullScreenPhotoViewer extends StatelessWidget {
  const _FullScreenPhotoViewer({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: Hero(
                tag: imageUrl,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(color: colors.colorAccentPink),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(Icons.broken_image, color: colors.colorTextMuted, size: 48),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: IconButton(
                  icon: Icon(Icons.close, color: colors.colorText, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTimestamp(DateTime dateTime) {
  final DateTime local = dateTime.toLocal();
  final String hour = local.hour.toString().padLeft(2, '0');
  final String minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
