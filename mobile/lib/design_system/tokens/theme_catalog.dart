import 'package:flutter/material.dart';
import 'cupid_sky_palette.dart';

/// Palette color entry of a theme.
class ThemePaletteColor {
  const ThemePaletteColor({required this.hex, required this.name});

  final Color hex;
  final String name;

  factory ThemePaletteColor.fromHex(String hexCode, String name) {
    final clean = hexCode.replaceAll('#', '');
    final colorVal = int.parse('FF$clean', radix: 16);
    return ThemePaletteColor(hex: Color(colorVal), name: name);
  }
}

/// Definition of a theme in the Theme Catalog.
class ThemeDefinition {
  const ThemeDefinition({
    required this.id,
    required this.nameVi,
    required this.nameEn,
    required this.tagVi,
    required this.tagEn,
    required this.storyVi,
    required this.storyEn,
    required this.price,
    required this.gradient,
    required this.dots,
    required this.palette,
    this.badge,
    this.isLight = false,
  });

  final String id;
  final String nameVi;
  final String nameEn;
  final String tagVi;
  final String tagEn;
  final String storyVi;
  final String storyEn;
  final int price;
  final LinearGradient gradient;
  final List<Color> dots;
  final List<ThemePaletteColor> palette;
  final String? badge;
  final bool isLight;

  List<CupidSkyLayer> get skyLayers {
    if (palette.length >= 4) {
      return CupidSkyPalette.layersForColors(
        primaryAccent: palette[1].hex,
        secondaryAccent: palette[2].hex,
        tertiaryAccent: palette[3].hex,
      );
    }
    return CupidSkyPalette.darkLayers;
  }

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
}

const List<ThemeDefinition> cupidThemeCatalog = <ThemeDefinition>[
  // 1. Nebula (Free / Default)
  ThemeDefinition(
    id: 'nebula',
    nameVi: 'Tinh Vân',
    nameEn: 'Nebula',
    tagVi: 'mặc định · dịu mắt ban đêm',
    tagEn: 'default · easy at night',
    storyVi:
        'Bản gốc của Cupid: nền tím than, sao lấp lánh và hồng pastel. Bé pet nào cũng hợp.',
    storyEn:
        "Cupid's original: deep violet, quiet stars, pastel pink. Every pet looks good in it.",
    price: 0,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF3A2B6B), Color(0xFF8B5FCF), Color(0xFFFF7FB6)],
    ),
    dots: <Color>[
      Color(0xFFB78CF5),
      Color(0xFFFF7FB6),
      Color(0xFF79E2CD),
    ],
    palette: <ThemePaletteColor>[
      ThemePaletteColor(hex: Color(0xFF241B42), name: 'Surface'),
      ThemePaletteColor(hex: Color(0xFFB78CF5), name: 'Lilac'),
      ThemePaletteColor(hex: Color(0xFFFF7FB6), name: 'Pink'),
      ThemePaletteColor(hex: Color(0xFF79E2CD), name: 'Mint'),
      ThemePaletteColor(hex: Color(0xFFFFF6FB), name: 'Cotton'),
    ],
    badge: 'Mặc định',
  ),

  // 2. Sunset
  ThemeDefinition(
    id: 'sunset',
    nameVi: 'Hoàng Hôn Đà Lạt',
    nameEn: 'Đà Lạt Sunset',
    tagVi: 'ấm · cho cặp yêu xa',
    tagEn: 'warm · for long distance',
    storyVi:
        'Màu của 5 giờ chiều trên đồi thông. Chat bubble chuyển sang cam ấm, đồng hồ hai múi giờ có nắng riêng.',
    storyEn:
        'The colour of 5pm on a pine hill. Chat bubbles turn warm amber; the dual clock gets its own sunlight.',
    price: 320,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF4A2350), Color(0xFFC2508F), Color(0xFFFFB067)],
    ),
    dots: <Color>[
      Color(0xFFFF9576),
      Color(0xFFFFC97E),
      Color(0xFFC2508F),
    ],
    palette: <ThemePaletteColor>[
      ThemePaletteColor(hex: Color(0xFF33203F), name: 'Dusk'),
      ThemePaletteColor(hex: Color(0xFFC2508F), name: 'Rosé'),
      ThemePaletteColor(hex: Color(0xFFFF9576), name: 'Ember'),
      ThemePaletteColor(hex: Color(0xFFFFC97E), name: 'Butter'),
      ThemePaletteColor(hex: Color(0xFFFFF1E4), name: 'Cream'),
    ],
    badge: 'hot',
  ),

  // 3. Sakura
  ThemeDefinition(
    id: 'sakura',
    nameVi: 'Mùa Hoa Anh Đào',
    nameEn: 'Sakura Season',
    tagVi: 'theo mùa · có hiệu ứng cánh hoa',
    tagEn: 'seasonal · petal effect',
    storyVi:
        'Cánh hoa rơi chậm sau màn hình chính, mỗi lần cả hai check-in cùng ngày thì rơi dày hơn.',
    storyEn:
        'Petals drift behind the home screen — and fall thicker on days you both check in.',
    price: 480,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF5B3350), Color(0xFFE58AB0), Color(0xFFFFD9E4)],
    ),
    dots: <Color>[
      Color(0xFFFF9EC4),
      Color(0xFFFFD9E4),
      Color(0xFFA57BC4),
    ],
    palette: <ThemePaletteColor>[
      ThemePaletteColor(hex: Color(0xFF3B2440), name: 'Bark'),
      ThemePaletteColor(hex: Color(0xFFE58AB0), name: 'Blossom'),
      ThemePaletteColor(hex: Color(0xFFFFD9E4), name: 'Petal'),
      ThemePaletteColor(hex: Color(0xFFA57BC4), name: 'Wisteria'),
      ThemePaletteColor(hex: Color(0xFFFFF7FA), name: 'Snow'),
    ],
    badge: 'seasonal',
  ),

  // 4. Midnight
  ThemeDefinition(
    id: 'midnight',
    nameVi: 'Nửa Đêm',
    nameEn: 'Midnight',
    tagVi: 'tối sâu · dễ ngủ',
    tagEn: 'deep dark · sleep friendly',
    storyVi:
        'Dành cho những cuộc gọi 2 giờ sáng. Độ sáng tự hạ sau 23h, báo thức chung chuyển sang xanh lạnh.',
    storyEn:
        'Built for 2am calls. Brightness eases after 11pm and the synced alarm turns cold blue.',
    price: 260,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF0C1130), Color(0xFF1E3A6E), Color(0xFF4F86C6)],
    ),
    dots: <Color>[
      Color(0xFF4F86C6),
      Color(0xFF8FB8E8),
      Color(0xFF2C1E5E),
    ],
    palette: <ThemePaletteColor>[
      ThemePaletteColor(hex: Color(0xFF0C1130), name: 'Ink'),
      ThemePaletteColor(hex: Color(0xFF1E3A6E), name: 'Deep'),
      ThemePaletteColor(hex: Color(0xFF4F86C6), name: 'Tide'),
      ThemePaletteColor(hex: Color(0xFF8FB8E8), name: 'Haze'),
      ThemePaletteColor(hex: Color(0xFFE8F0FF), name: 'Moon'),
    ],
  ),

  // 5. Matcha
  ThemeDefinition(
    id: 'matcha',
    nameVi: 'Trà Xanh',
    nameEn: 'Matcha',
    tagVi: 'mát · ít gây phân tâm',
    tagEn: 'calm · low distraction',
    storyVi:
        'Không gradient chói, không hiệu ứng. Cặp nào hay cãi nhau lúc nửa đêm nên thử theme này.',
    storyEn:
        'No loud gradients, no effects. Couples who argue at midnight should try this one.',
    price: 260,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF1E3A34), Color(0xFF3F7A63), Color(0xFFA8D8B9)],
    ),
    dots: <Color>[
      Color(0xFF79E2CD),
      Color(0xFFA8D8B9),
      Color(0xFF3F7A63),
    ],
    palette: <ThemePaletteColor>[
      ThemePaletteColor(hex: Color(0xFF16302A), name: 'Forest'),
      ThemePaletteColor(hex: Color(0xFF3F7A63), name: 'Leaf'),
      ThemePaletteColor(hex: Color(0xFF79E2CD), name: 'Mint'),
      ThemePaletteColor(hex: Color(0xFFA8D8B9), name: 'Sage'),
      ThemePaletteColor(hex: Color(0xFFF2FBF4), name: 'Rice'),
    ],
  ),

  // 6. Saigon Neon
  ThemeDefinition(
    id: 'neon',
    nameVi: 'Đêm Sài Gòn',
    nameEn: 'Saigon Neon',
    tagVi: 'rực · hợp chụp thẻ kỷ niệm',
    tagEn: 'loud · great for cards',
    storyVi:
        'Viền neon quanh thẻ kỷ niệm, tên hai đứa sáng như biển hiệu quán ăn đêm.',
    storyEn:
        'Neon edges on every keepsake card, both your names lit like a late-night diner sign.',
    price: 420,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF1B0B2E), Color(0xFFB4249B), Color(0xFF28D8D8)],
    ),
    dots: <Color>[
      Color(0xFFFF3D9A),
      Color(0xFF28D8D8),
      Color(0xFFB4249B),
    ],
    palette: <ThemePaletteColor>[
      ThemePaletteColor(hex: Color(0xFF1B0B2E), name: 'Night'),
      ThemePaletteColor(hex: Color(0xFFB4249B), name: 'Magenta'),
      ThemePaletteColor(hex: Color(0xFFFF3D9A), name: 'Hot'),
      ThemePaletteColor(hex: Color(0xFF28D8D8), name: 'Cyan'),
      ThemePaletteColor(hex: Color(0xFFFFE7F6), name: 'Glow'),
    ],
    badge: 'new',
  ),

  // 7. Butter Milk
  ThemeDefinition(
    id: 'butter',
    nameVi: 'Bơ Sữa',
    nameEn: 'Butter Milk',
    tagVi: 'sáng · theme nền sáng đầu tiên',
    tagEn: 'light · our first light theme',
    storyVi:
        'Nền sáng, chữ nâu sữa. Ban ngày ngoài nắng vẫn đọc được tin nhắn.',
    storyEn:
        'Light surfaces, cocoa ink. Readable outdoors, even at noon.',
    price: 380,
    isLight: true,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFFFFF3DC), Color(0xFFFFD79E), Color(0xFFFFB6C9)],
    ),
    dots: <Color>[
      Color(0xFFFFC97E),
      Color(0xFFFFAB93),
      Color(0xFF8C6239),
    ],
    palette: <ThemePaletteColor>[
      ThemePaletteColor(hex: Color(0xFFFFF8EC), name: 'Milk'),
      ThemePaletteColor(hex: Color(0xFFFFD79E), name: 'Butter'),
      ThemePaletteColor(hex: Color(0xFFFFAB93), name: 'Peach'),
      ThemePaletteColor(hex: Color(0xFF8C6239), name: 'Cocoa'),
      ThemePaletteColor(hex: Color(0xFF4A3520), name: 'Ink'),
    ],
  ),

  // 8. Star Map
  ThemeDefinition(
    id: 'starmap',
    nameVi: 'Bản Đồ Sao',
    nameEn: 'Star Map',
    tagVi: 'dựng theo ngày sinh hai đứa',
    tagEn: 'built from both birthdays',
    storyVi:
        'Nền là bầu trời đúng đêm hai đứa quen nhau. Cung hoàng đạo của cả hai được vẽ nối bằng một đường mảnh.',
    storyEn:
        'The sky exactly as it looked the night you met, with both zodiac signs joined by a thin line.',
    price: 640,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF141232), Color(0xFF37307A), Color(0xFF9E8CF5)],
    ),
    dots: <Color>[
      Color(0xFF9E8CF5),
      Color(0xFFFFE9A8),
      Color(0xFF37307A),
    ],
    palette: <ThemePaletteColor>[
      ThemePaletteColor(hex: Color(0xFF141232), name: 'Void'),
      ThemePaletteColor(hex: Color(0xFF37307A), name: 'Orbit'),
      ThemePaletteColor(hex: Color(0xFF9E8CF5), name: 'Nova'),
      ThemePaletteColor(hex: Color(0xFFFFE9A8), name: 'Starlight'),
      ThemePaletteColor(hex: Color(0xFFEDEBFF), name: 'Dust'),
    ],
    badge: 'limited',
  ),
];

ThemeDefinition getThemeDefinition(String id) {
  return cupidThemeCatalog.firstWhere(
    (t) => t.id == id,
    orElse: () => cupidThemeCatalog.first,
  );
}
