import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Single Emoji sticker item representation.
class EmojiItem {
  const EmojiItem({
    required this.id,
    required this.nameVi,
    required this.nameEn,
    required this.code,
    required this.emotion,
    this.keywords = const <String>[],
  });

  final String id;
  final String nameVi;
  final String nameEn;
  final String code;
  final String emotion;
  final List<String> keywords;

  String get name => nameVi;

  String localizedName(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    return isEn ? nameEn : nameVi;
  }

  factory EmojiItem.fromJson(Map<String, dynamic> json) {
    return EmojiItem(
      id: json['id'] as String? ?? '',
      nameVi: json['nameVi'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      code: json['code'] as String? ?? '',
      emotion: json['emotion'] as String? ?? 'happy',
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((k) => k.toString())
              .toList() ??
          const <String>[],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'nameVi': nameVi,
        'nameEn': nameEn,
        'code': code,
        'emotion': emotion,
        'keywords': keywords,
      };
}

/// Emoji pack definition holding 20 standard expressions.
class EmojiPack {
  const EmojiPack({
    required this.id,
    required this.nameVi,
    required this.nameEn,
    required this.tagVi,
    required this.tagEn,
    required this.storyVi,
    required this.storyEn,
    required this.price,
    required this.icon,
    required this.bannerColors,
    required this.emojis,
    this.badge,
  });

  final String id;
  final String nameVi;
  final String nameEn;
  final String tagVi;
  final String tagEn;
  final String storyVi;
  final String storyEn;
  final int price;
  final String icon;
  final List<Color> bannerColors;
  final List<EmojiItem> emojis;
  final String? badge;

  String get name => nameVi;
  String get tag => tagVi;
  String get story => storyVi;

  String localizedName(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    return isEn ? nameEn : nameVi;
  }

  String localizedTag(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    return isEn ? tagEn : tagVi;
  }

  String localizedStory(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    return isEn ? storyEn : storyVi;
  }

  factory EmojiPack.fromJson(Map<String, dynamic> json) {
    final bannerArr = json['bannerGradient'] as List<dynamic>?;
    final bannerColors = bannerArr != null && bannerArr.isNotEmpty
        ? bannerArr.map((c) => EmojiPalette.parseHex(c.toString())).toList()
        : EmojiPalette.mochiCatBanner;

    final emojisRaw = json['emojis'] as List<dynamic>? ?? const <dynamic>[];
    final emojis = emojisRaw
        .map((e) => EmojiItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return EmojiPack(
      id: json['id'] as String? ?? '',
      nameVi: json['nameVi'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      tagVi: json['tagVi'] as String? ?? '',
      tagEn: json['tagEn'] as String? ?? '',
      storyVi: json['storyVi'] as String? ?? '',
      storyEn: json['storyEn'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      icon: json['icon'] as String? ?? '💖',
      bannerColors: bannerColors,
      emojis: emojis,
      badge: json['badge'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'nameVi': nameVi,
        'nameEn': nameEn,
        'tagVi': tagVi,
        'tagEn': tagEn,
        'storyVi': storyVi,
        'storyEn': storyEn,
        'price': price,
        'icon': icon,
        'bannerGradient': bannerColors
            .map((c) => '#${c.toARGB32().toRadixString(16).padLeft(8, '0')}')
            .toList(),
        'emojis': emojis.map((e) => e.toJson()).toList(),
        'badge': badge,
      };
}

/// Couple Emoji state synchronized with backend or local preferences.
class CoupleEmojiState {
  const CoupleEmojiState({
    required this.activePackId,
    required this.downloadedPackIds,
  });

  final String activePackId;
  final List<String> downloadedPackIds;

  bool isDownloaded(String packId) => downloadedPackIds.contains(packId);

  factory CoupleEmojiState.fromJson(Map<String, dynamic> json) {
    final downloaded = (json['downloadedPackIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>['mochi-cat', 'baby-dino'];

    return CoupleEmojiState(
      activePackId: json['activePackId'] as String? ?? 'mochi-cat',
      downloadedPackIds: downloaded,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'activePackId': activePackId,
        'downloadedPackIds': downloadedPackIds,
      };
}
