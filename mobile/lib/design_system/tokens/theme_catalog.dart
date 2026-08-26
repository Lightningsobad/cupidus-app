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
    tagVi: 'Huyền bí · Đêm sâu',
    tagEn: 'Mystic · Deep night',
    storyVi:
        'Sắc tím huyền ảo kết hợp cùng gam màu hồng neon tạo cảm giác lãng mạn như dạo bước giữa dải ngân hà tĩnh lặng.',
    storyEn:
        'A dreamy twilight purple combined with neon pink accents creating a romantic celestial atmosphere.',
    price: 0,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF7B2FBE), Color(0xFFFF4B8C)],
    ),
    dots: <Color>[
      Color(0xFF171129),
      Color(0xFF7B2FBE),
      Color(0xFFFF4B8C),
      Color(0xFF00C9A7),
      Color(0xFFF7EEFB),
    ],
    palette: <ThemePaletteColor>[
      ThemePaletteColor(hex: Color(0xFF171129), name: 'Nền không gian'),
      ThemePaletteColor(hex: Color(0xFF7B2FBE), name: 'Tím tinh vân'),
      ThemePaletteColor(hex: Color(0xFFFF4B8C), name: 'Hồng neon'),
      ThemePaletteColor(hex: Color(0xFF00C9A7), name: 'Xanh ngọc'),
      ThemePaletteColor(hex: Color(0xFFF7EEFB), name: 'Ánh sao'),
    ],
    badge: 'Mặc định',
  ),

  // 2. Sunset
  ThemeDefinition(
    id: 'sunset',
    nameVi: 'Hoàng Hôn Đà Lạt',
    nameEn: 'Dalat Sunset',
    tagVi: 'Ấm áp · Lãng mạn',
    tagEn: 'Warm · Romantic',
    storyVi:
        'Nắng chiều vàng cam buông nhẹ xuống những rặng thông và đồi cỏ hồng mộng mơ tại phố núi Đà Lạt.',
    storyEn:
        'Golden orange and warm rose gradients capturing a cozy sunset over Dalat pine hills.',
    price: 480,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFFFD93D)],
    ),
    dots: <Color>[
      Color(0xFF1F1218),
      Color(0xFFFF6B6B),
      Color(0xFFFF8E53),
      Color(0xFFFFD93D),
      Color(0xFFFFF0EB),
    ],
    palette: <ThemePaletteColor>[
      ThemePaletteColor(hex: Color(0xFF1F1218), name: 'Nền hoàng hôn'),
      ThemePaletteColor(hex: Color(0xFFFF6B6B), name: 'Cam hồng dại'),
      ThemePaletteColor(hex: Color(0xFFFF8E53), name: 'Hổ phách'),
      ThemePaletteColor(hex: Color(0xFFFFD93D), name: 'Vàng nắng'),
      ThemePaletteColor(hex: Color(0xFFFFF0EB), name: 'Mây chiều'),
    ],
  ),

  // 3. Sakura
  ThemeDefinition(
    id: 'sakura',
    nameVi: 'Mùa Hoa Anh Đào',
    nameEn: 'Sakura Season',
    tagVi: 'Dịu dàng · Tươi mới',
    tagEn: 'Gentle · Fresh',
    storyVi:
        'Cánh hoa anh đào khẽ rơi trong gió xuân nhẹ nhàng mang lại cảm giác ngọt ngào và ấm áp.',
    storyEn:
        'Gentle blossom pink and soft spring tones evoking sweet blossoming memories.',
    price: 520,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFFFF758C), Color(0xFFFF7EB3), Color(0xFFF7D1BA)],
    ),
    dots: <Color>[
      Color(0xFF1D141C),
      Color(0xFFFF758C),
      Color(0xFFFF7EB3),
      Color(0xFFF7D1BA),
      Color(0xFFFFF5F7),
    ],
    palette: <ThemePaletteColor>[
      ThemePaletteColor(hex: Color(0xFF1D141C), name: 'Nền sương đêm'),
      ThemePaletteColor(hex: Color(0xFFFF758C), name: 'Hồng anh đào'),
      ThemePaletteColor(hex: Color(0xFFFF7EB3), name: 'Hồng phấn'),
      ThemePaletteColor(hex: Color(0xFFF7D1BA), name: 'Cánh đào rơi'),
      ThemePaletteColor(hex: Color(0xFFFFF5F7), name: 'Ánh sương'),
    ],
    badge: 'Mới',
  ),

  // 4. Ocean
  ThemeDefinition(
    id: 'ocean',
    nameVi: 'Đại Dương Xanh',
    nameEn: 'Deep Ocean',
    tagVi: 'Sâu lắng · Bình yên',
    tagEn: 'Serene · Deep',
    storyVi:
        'Làn sóng biển xanh thẳm mang lại cảm giác bình yên, sâu lắng như tình yêu vô tận.',
    storyEn:
        'Aquatic blues and cyan tones reminiscent of calm ocean waves and deep trust.',
    price: 600,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF2E86DE), Color(0xFF00D2D3), Color(0xFF54A0FF)],
    ),
    dots: <Color>[
      Color(0xFF0D1B2A),
      Color(0xFF2E86DE),
      Color(0xFF00D2D3),
      Color(0xFF54A0FF),
      Color(0xFFE8F4F8),
    ],
    palette: <ThemePaletteColor>[
      ThemePaletteColor(hex: Color(0xFF0D1B2A), name: 'Đáy đại dương'),
      ThemePaletteColor(hex: Color(0xFF2E86DE), name: 'Xanh dương thẳm'),
      ThemePaletteColor(hex: Color(0xFF00D2D3), name: 'Xanh ngọc biển'),
      ThemePaletteColor(hex: Color(0xFF54A0FF), name: 'Bọt sóng'),
      ThemePaletteColor(hex: Color(0xFFE8F4F8), name: 'Gió biển'),
    ],
  ),

  // 5. Matcha
  ThemeDefinition(
    id: 'matcha',
    nameVi: 'Trà Chiều Matcha',
    nameEn: 'Matcha Forest',
    tagVi: 'Thư giãn · Thanh mát',
    tagEn: 'Relaxing · Earthy',
    storyVi:
        'Hương trà xanh thơm mát bên khu vườn ngập tràn ánh nắng nhẹ nhàng sớm mai.',
    storyEn:
        'Earthy green botanicals and soothing mint tones creating a relaxing garden mood.',
    price: 450,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF10AC84), Color(0xFF1DD1A1), Color(0xFFC8D6E5)],
    ),
    dots: <Color>[
      Color(0xFF0E1E17),
      Color(0xFF10AC84),
      Color(0xFF1DD1A1),
      Color(0xFF55EFC4),
      Color(0xFFF0FFF4),
    ],
    palette: <ThemePaletteColor>[
      ThemePaletteColor(hex: Color(0xFF0E1E17), name: 'Đất mẹ'),
      ThemePaletteColor(hex: Color(0xFF10AC84), name: 'Lá trà non'),
      ThemePaletteColor(hex: Color(0xFF1DD1A1), name: 'Búp trà xanh'),
      ThemePaletteColor(hex: Color(0xFF55EFC4), name: 'Bạc hà'),
      ThemePaletteColor(hex: Color(0xFFF0FFF4), name: 'Sương sớm'),
    ],
  ),

  // 6. Midnight
  ThemeDefinition(
    id: 'midnight',
    nameVi: 'Đêm Cực Quang',
    nameEn: 'Aurora Borealis',
    tagVi: 'Kỳ ảo · Say đắm',
    tagEn: 'Enchanting · Vivid',
    storyVi:
        'Vũ điệu ánh sáng rực rỡ trên bầu trời đêm bắc cực diệu kỳ.',
    storyEn:
        'Vibrant aurora ribbons dancing across the dark Arctic night sky.',
    price: 750,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF341F97), Color(0xFF5F27CD), Color(0xFF01CBC6)],
    ),
    dots: <Color>[
      Color(0xFF0A0717),
      Color(0xFF341F97),
      Color(0xFF5F27CD),
      Color(0xFF01CBC6),
      Color(0xFFE8EAFF),
    ],
    palette: <ThemePaletteColor>[
      ThemePaletteColor(hex: Color(0xFF0A0717), name: 'Đêm bắc cực'),
      ThemePaletteColor(hex: Color(0xFF341F97), name: 'Chàm thẫm'),
      ThemePaletteColor(hex: Color(0xFF5F27CD), name: 'Tím cực quang'),
      ThemePaletteColor(hex: Color(0xFF01CBC6), name: 'Xanh dạ quang'),
      ThemePaletteColor(hex: Color(0xFFE8EAFF), name: 'Băng tuyết'),
    ],
    badge: 'Đặc sắc',
  ),

  // 7. Lavender
  ThemeDefinition(
    id: 'lavender',
    nameVi: 'Đồi Hoa Oải Hương',
    nameEn: 'Lavender Mist',
    tagVi: 'Thơ mộng · Êm đềm',
    tagEn: 'Dreamy · Soothing',
    storyVi:
        'Sắc tím lavender dịu dàng trải dài ngút ngàn dưới nắng sớm mai.',
    storyEn:
        'Gentle lavender and lilac blooms bathed in morning haze.',
    price: 500,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF8C7AE6), Color(0xFF9C88FF), Color(0xFFE1BEE7)],
    ),
    dots: <Color>[
      Color(0xFF181528),
      Color(0xFF8C7AE6),
      Color(0xFF9C88FF),
      Color(0xFFE1BEE7),
      Color(0xFFFBF8FF),
    ],
    palette: <ThemePaletteColor>[
      ThemePaletteColor(hex: Color(0xFF181528), name: 'Đêm Provence'),
      ThemePaletteColor(hex: Color(0xFF8C7AE6), name: 'Oải hương'),
      ThemePaletteColor(hex: Color(0xFF9C88FF), name: 'Tím nhạt'),
      ThemePaletteColor(hex: Color(0xFFE1BEE7), name: 'Phấn tím'),
      ThemePaletteColor(hex: Color(0xFFFBF8FF), name: 'Khói sớm'),
    ],
  ),

  // 8. Cyberpunk
  ThemeDefinition(
    id: 'cyberpunk',
    nameVi: 'Ánh Đèn Cyberpunk',
    nameEn: 'Cyberpunk Neon',
    tagVi: 'Phá cách · Năng động',
    tagEn: 'Futuristic · Dynamic',
    storyVi:
        'Ánh đèn neon rực rỡ và nhịp sống sôi động của thành phố tương lai.',
    storyEn:
        'Electric neon pink, cyan and high-energy contrast for modern lovers.',
    price: 800,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFFFF007F), Color(0xFF00F0FF), Color(0xFFFFEE00)],
    ),
    dots: <Color>[
      Color(0xFF0F0B1A),
      Color(0xFFFF007F),
      Color(0xFF00F0FF),
      Color(0xFFFFEE00),
      Color(0xFFFFFFFF),
    ],
    palette: <ThemePaletteColor>[
      ThemePaletteColor(hex: Color(0xFF0F0B1A), name: 'Đêm Neon City'),
      ThemePaletteColor(hex: Color(0xFFFF007F), name: 'Hồng Laser'),
      ThemePaletteColor(hex: Color(0xFF00F0FF), name: 'Cyan Điện Tử'),
      ThemePaletteColor(hex: Color(0xFFFFEE00), name: 'Vàng Cảnh Báo'),
      ThemePaletteColor(hex: Color(0xFFFFFFFF), name: 'Tia Chớp'),
    ],
    badge: 'Hot',
  ),
];

ThemeDefinition getThemeDefinition(String id) {
  return cupidThemeCatalog.firstWhere(
    (t) => t.id == id,
    orElse: () => cupidThemeCatalog.first,
  );
}
