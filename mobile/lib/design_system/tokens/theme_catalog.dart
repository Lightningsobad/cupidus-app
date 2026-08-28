import 'package:flutter/material.dart';
import 'cupid_sky_palette.dart';

Color parseHexColor(String hexCode, [Color fallback = const Color(0xFFFFFFFF)]) {
  try {
    final clean = hexCode.replaceAll('#', '').trim();
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    } else if (clean.length == 8) {
      return Color(int.parse(clean, radix: 16));
    }
    return fallback;
  } catch (_) {
    return fallback;
  }
}

/// Palette color entry of a theme.
class ThemePaletteColor {
  const ThemePaletteColor({required this.hex, required this.name});

  final Color hex;
  final String name;

  factory ThemePaletteColor.fromHex(String hexCode, String name) {
    return ThemePaletteColor(hex: parseHexColor(hexCode), name: name);
  }

  factory ThemePaletteColor.fromJson(Map<String, dynamic> json) {
    return ThemePaletteColor(
      hex: parseHexColor(json['hex'] as String? ?? '#FFFFFF'),
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'hex': '#${hex.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
        'name': name,
      };
}

/// Dynamic particle configuration served from backend.
class ThemeParticleConfig {
  const ThemeParticleConfig({
    this.enabled = true,
    this.shape = 'star',
    this.count = 12,
    this.minSize = 3.0,
    this.maxSize = 6.0,
    this.minSpeed = 0.2,
    this.maxSpeed = 0.6,
    this.minOpacity = 0.25,
    this.maxOpacity = 1.0,
    this.colors = const <Color>[Color(0xFFFFFFFF)],
    this.directionDegrees = 90.0,
    this.swayAmplitude = 0.0,
    this.twinklePeriodMs = 4000,
  });

  final bool enabled;
  final String shape;
  final int count;
  final double minSize;
  final double maxSize;
  final double minSpeed;
  final double maxSpeed;
  final double minOpacity;
  final double maxOpacity;
  final List<Color> colors;
  final double directionDegrees;
  final double swayAmplitude;
  final int twinklePeriodMs;

  factory ThemeParticleConfig.fromJson(Map<String, dynamic> json) {
    return ThemeParticleConfig(
      enabled: json['enabled'] as bool? ?? true,
      shape: json['shape'] as String? ?? 'star',
      count: (json['count'] as num?)?.toInt() ?? 12,
      minSize: (json['minSize'] as num?)?.toDouble() ?? 3.0,
      maxSize: (json['maxSize'] as num?)?.toDouble() ?? 6.0,
      minSpeed: (json['minSpeed'] as num?)?.toDouble() ?? 0.2,
      maxSpeed: (json['maxSpeed'] as num?)?.toDouble() ?? 0.6,
      minOpacity: (json['minOpacity'] as num?)?.toDouble() ?? 0.25,
      maxOpacity: (json['maxOpacity'] as num?)?.toDouble() ?? 1.0,
      colors: (json['colors'] as List<dynamic>?)
              ?.map((c) => parseHexColor(c.toString()))
              .toList() ??
          const <Color>[Color(0xFFFFFFFF)],
      directionDegrees:
          (json['directionDegrees'] as num?)?.toDouble() ?? 90.0,
      swayAmplitude: (json['swayAmplitude'] as num?)?.toDouble() ?? 0.0,
      twinklePeriodMs: (json['twinklePeriodMs'] as num?)?.toInt() ?? 4000,
    );
  }
}

/// Special event and ambient effects configuration served from backend.
class ThemeSpecialFXConfig {
  const ThemeSpecialFXConfig({
    this.hasShootingStars = false,
    this.shootingStarIntervalMs = 6000,
    this.hasConstellationLines = false,
    this.hasNeonFlicker = false,
    this.nightDimming = false,
  });

  final bool hasShootingStars;
  final int shootingStarIntervalMs;
  final bool hasConstellationLines;
  final bool hasNeonFlicker;
  final bool nightDimming;

  factory ThemeSpecialFXConfig.fromJson(Map<String, dynamic> json) {
    return ThemeSpecialFXConfig(
      hasShootingStars: json['hasShootingStars'] as bool? ?? false,
      shootingStarIntervalMs:
          (json['shootingStarIntervalMs'] as num?)?.toInt() ?? 6000,
      hasConstellationLines: json['hasConstellationLines'] as bool? ?? false,
      hasNeonFlicker: json['hasNeonFlicker'] as bool? ?? false,
      nightDimming: json['nightDimming'] as bool? ?? false,
    );
  }
}

/// Interactive touch reaction configuration served from backend.
class ThemeTouchReactionConfig {
  const ThemeTouchReactionConfig({
    this.type = 'ripple',
    this.color = const Color(0xFFB78CF5),
    this.durationMs = 600,
  });

  final String type;
  final Color color;
  final int durationMs;

  factory ThemeTouchReactionConfig.fromJson(Map<String, dynamic> json) {
    return ThemeTouchReactionConfig(
      type: json['type'] as String? ?? 'ripple',
      color: json['color'] != null
          ? parseHexColor(json['color'].toString(), const Color(0xFFB78CF5))
          : const Color(0xFFB78CF5),
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 600,
    );
  }
}

/// Complete Dynamic FX configuration of a theme.
class ThemeFXConfig {
  const ThemeFXConfig({
    required this.type,
    this.particles = const ThemeParticleConfig(),
    this.specialFX = const ThemeSpecialFXConfig(),
    this.touchReaction = const ThemeTouchReactionConfig(),
  });

  final String type;
  final ThemeParticleConfig particles;
  final ThemeSpecialFXConfig specialFX;
  final ThemeTouchReactionConfig touchReaction;

  factory ThemeFXConfig.fromJson(Map<String, dynamic> json) {
    return ThemeFXConfig(
      type: json['type'] as String? ?? 'nebula',
      particles: json['particles'] is Map<String, dynamic>
          ? ThemeParticleConfig.fromJson(
              json['particles'] as Map<String, dynamic>)
          : const ThemeParticleConfig(),
      specialFX: json['specialFX'] is Map<String, dynamic>
          ? ThemeSpecialFXConfig.fromJson(
              json['specialFX'] as Map<String, dynamic>)
          : const ThemeSpecialFXConfig(),
      touchReaction: json['touchReaction'] is Map<String, dynamic>
          ? ThemeTouchReactionConfig.fromJson(
              json['touchReaction'] as Map<String, dynamic>)
          : const ThemeTouchReactionConfig(),
    );
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
    this.fxConfig,
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
  final ThemeFXConfig? fxConfig;

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

  factory ThemeDefinition.fromJson(Map<String, dynamic> json) {
    LinearGradient grad;
    if (json['gradient'] is Map<String, dynamic>) {
      final g = json['gradient'] as Map<String, dynamic>;
      final beginArr = g['begin'] as List<dynamic>?;
      final endArr = g['end'] as List<dynamic>?;
      final colorsArr = g['colors'] as List<dynamic>?;
      final begin = beginArr != null && beginArr.length >= 2
          ? Alignment((beginArr[0] as num).toDouble(), (beginArr[1] as num).toDouble())
          : Alignment.topLeft;
      final end = endArr != null && endArr.length >= 2
          ? Alignment((endArr[0] as num).toDouble(), (endArr[1] as num).toDouble())
          : Alignment.bottomRight;
      final colors = colorsArr != null && colorsArr.isNotEmpty
          ? colorsArr.map((c) => parseHexColor(c.toString())).toList()
          : const <Color>[Color(0xFF3A2B6B), Color(0xFF8B5FCF)];
      grad = LinearGradient(begin: begin, end: end, colors: colors);
    } else {
      grad = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF3A2B6B), Color(0xFF8B5FCF), Color(0xFFFF7FB6)],
      );
    }

    final dots = (json['dots'] as List<dynamic>?)
            ?.map((d) => parseHexColor(d.toString()))
            .toList() ??
        const <Color>[Color(0xFFB78CF5), Color(0xFFFF7FB6), Color(0xFF79E2CD)];

    final palette = (json['palette'] as List<dynamic>?)
            ?.map((p) => ThemePaletteColor.fromJson(p as Map<String, dynamic>))
            .toList() ??
        const <ThemePaletteColor>[];

    ThemeFXConfig? fx;
    if (json['fxConfig'] is Map<String, dynamic>) {
      fx = ThemeFXConfig.fromJson(json['fxConfig'] as Map<String, dynamic>);
    }

    return ThemeDefinition(
      id: json['id'] as String? ?? 'nebula',
      nameVi: json['nameVi'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      tagVi: json['tagVi'] as String? ?? '',
      tagEn: json['tagEn'] as String? ?? '',
      storyVi: json['storyVi'] as String? ?? '',
      storyEn: json['storyEn'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      gradient: grad,
      dots: dots,
      palette: palette,
      badge: json['badge'] as String?,
      isLight: json['isLight'] as bool? ?? false,
      fxConfig: fx,
    );
  }
}

/// Fallback catalog used on cold offline boot until backend catalog syncs.
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
    fxConfig: ThemeFXConfig(
      type: 'nebula',
      particles: ThemeParticleConfig(
        enabled: true,
        shape: 'star',
        count: 14,
        minSize: 3,
        maxSize: 6,
        minSpeed: 0.1,
        maxSpeed: 0.4,
        minOpacity: 0.25,
        maxOpacity: 1.0,
        colors: <Color>[Color(0xFFFFFFFF), Color(0xFFFFD9EA), Color(0xFFCEB4FF)],
        directionDegrees: 45,
        twinklePeriodMs: 4000,
      ),
      specialFX: ThemeSpecialFXConfig(
        hasShootingStars: false,
        nightDimming: false,
      ),
      touchReaction: ThemeTouchReactionConfig(
        type: 'ripple',
        color: Color(0xFFB78CF5),
        durationMs: 600,
      ),
    ),
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
    fxConfig: ThemeFXConfig(
      type: 'sunset',
      particles: ThemeParticleConfig(
        enabled: true,
        shape: 'bokeh',
        count: 12,
        minSize: 4,
        maxSize: 10,
        minSpeed: 0.2,
        maxSpeed: 0.6,
        minOpacity: 0.2,
        maxOpacity: 0.8,
        colors: <Color>[Color(0xFFFF9576), Color(0xFFFFC97E), Color(0xFFFFB067), Color(0xFFFFE4A0)],
        directionDegrees: -90,
        swayAmplitude: 15,
      ),
      specialFX: ThemeSpecialFXConfig(
        nightDimming: false,
      ),
      touchReaction: ThemeTouchReactionConfig(
        type: 'ember',
        color: Color(0xFFFF9576),
        durationMs: 700,
      ),
    ),
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
    fxConfig: ThemeFXConfig(
      type: 'sakura',
      particles: ThemeParticleConfig(
        enabled: true,
        shape: 'petal',
        count: 18,
        minSize: 6,
        maxSize: 14,
        minSpeed: 0.5,
        maxSpeed: 1.2,
        minOpacity: 0.35,
        maxOpacity: 0.9,
        colors: <Color>[Color(0xFFFF9EC4), Color(0xFFFFD9E4), Color(0xFFFFEBF1)],
        directionDegrees: 80,
        swayAmplitude: 28,
      ),
      specialFX: ThemeSpecialFXConfig(
        nightDimming: false,
      ),
      touchReaction: ThemeTouchReactionConfig(
        type: 'wind_push',
        color: Color(0xFFFF9EC4),
        durationMs: 800,
      ),
    ),
  ),

  // 4. Midnight
  ThemeDefinition(
    id: 'midnight',
    nameVi: 'Nửa Đêm',
    nameEn: 'Midnight',
    tagVi: 'tối sâu · dễ ngủ',
    tagEn: 'deep dark · sleep friendly',
    storyVi:
        'Dành cho những cuộc gọi 2 giờ sáng. Độ sáng tự hạ sau 23h, nhắc nhở đồng bộ chuyển sang xanh lạnh.',
    storyEn:
        'Built for 2am calls. Brightness eases after 11pm and the synced reminder turns cold blue.',
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
    fxConfig: ThemeFXConfig(
      type: 'midnight',
      particles: ThemeParticleConfig(
        enabled: true,
        shape: 'firefly',
        count: 7,
        minSize: 4,
        maxSize: 8,
        minSpeed: 0.2,
        maxSpeed: 0.5,
        minOpacity: 0.15,
        maxOpacity: 0.85,
        colors: <Color>[Color(0xFF8FB8E8), Color(0xFFA6CEFF), Color(0xFFE8F0FF)],
        directionDegrees: -45,
        swayAmplitude: 20,
        twinklePeriodMs: 5000,
      ),
      specialFX: ThemeSpecialFXConfig(
        nightDimming: true,
      ),
      touchReaction: ThemeTouchReactionConfig(
        type: 'water_wave',
        color: Color(0xFF4F86C6),
        durationMs: 900,
      ),
    ),
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
    fxConfig: ThemeFXConfig(
      type: 'matcha',
      particles: ThemeParticleConfig(
        enabled: true,
        shape: 'dew',
        count: 5,
        minSize: 3,
        maxSize: 6,
        minSpeed: 0.1,
        maxSpeed: 0.3,
        minOpacity: 0.2,
        maxOpacity: 0.7,
        colors: <Color>[Color(0xFF79E2CD), Color(0xFFA8D8B9), Color(0xFFF2FBF4)],
        directionDegrees: 90,
        swayAmplitude: 5,
      ),
      specialFX: ThemeSpecialFXConfig(
        nightDimming: false,
      ),
      touchReaction: ThemeTouchReactionConfig(
        type: 'water_wave',
        color: Color(0xFF79E2CD),
        durationMs: 750,
      ),
    ),
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
    fxConfig: ThemeFXConfig(
      type: 'neon',
      particles: ThemeParticleConfig(
        enabled: true,
        shape: 'spark',
        count: 16,
        minSize: 2,
        maxSize: 6,
        minSpeed: 0.8,
        maxSpeed: 2.0,
        minOpacity: 0.4,
        maxOpacity: 1.0,
        colors: <Color>[Color(0xFFFF3D9A), Color(0xFF28D8D8), Color(0xFFB4249B), Color(0xFFFFFFFF)],
        directionDegrees: 60,
      ),
      specialFX: ThemeSpecialFXConfig(
        hasNeonFlicker: true,
        nightDimming: false,
      ),
      touchReaction: ThemeTouchReactionConfig(
        type: 'spark',
        color: Color(0xFF28D8D8),
        durationMs: 500,
      ),
    ),
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
    fxConfig: ThemeFXConfig(
      type: 'butter',
      particles: ThemeParticleConfig(
        enabled: true,
        shape: 'bubble',
        count: 10,
        minSize: 4,
        maxSize: 12,
        minSpeed: 0.3,
        maxSpeed: 0.7,
        minOpacity: 0.25,
        maxOpacity: 0.8,
        colors: <Color>[Color(0xFFFFD79E), Color(0xFFFFAB93), Color(0xFFFFF8EC)],
        directionDegrees: -90,
        swayAmplitude: 12,
      ),
      specialFX: ThemeSpecialFXConfig(
        nightDimming: false,
      ),
      touchReaction: ThemeTouchReactionConfig(
        type: 'bubble_pop',
        color: Color(0xFFFFAB93),
        durationMs: 600,
      ),
    ),
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
    fxConfig: ThemeFXConfig(
      type: 'starmap',
      particles: ThemeParticleConfig(
        enabled: true,
        shape: 'star',
        count: 22,
        minSize: 2,
        maxSize: 7,
        minSpeed: 0.1,
        maxSpeed: 0.3,
        minOpacity: 0.3,
        maxOpacity: 1.0,
        colors: <Color>[Color(0xFFFFE9A8), Color(0xFF9E8CF5), Color(0xFFEDEBFF), Color(0xFFFFFFFF)],
        directionDegrees: 0,
        twinklePeriodMs: 3200,
      ),
      specialFX: ThemeSpecialFXConfig(
        hasShootingStars: true,
        shootingStarIntervalMs: 6500,
        hasConstellationLines: true,
        nightDimming: false,
      ),
      touchReaction: ThemeTouchReactionConfig(
        type: 'star_trace',
        color: Color(0xFFFFE9A8),
        durationMs: 800,
      ),
    ),
  ),

  // 9. Cozy Christmas
  ThemeDefinition(
    id: 'christmas',
    nameVi: 'Giáng Sinh Ấm Áp',
    nameEn: 'Cozy Christmas',
    tagVi: 'theo mùa · tuyết rơi & nến ấm',
    tagEn: 'seasonal · falling snow & warm glow',
    storyVi:
        'Bông tuyết trắng rơi nhè nhẹ, cây thông lung linh và ánh nến ấm áp xua tan cái lạnh mùa đông.',
    storyEn:
        'Gentle falling snowflakes, twinkling pine trees and warm candlelight to warm your winter nights.',
    price: 390,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF122B1E), Color(0xFF4A1521), Color(0xFF8B2635), Color(0xFFF4D06F)],
    ),
    dots: <Color>[
      Color(0xFFF4D06F),
      Color(0xFFE63946),
      Color(0xFF2A9D8F),
    ],
    palette: <ThemePaletteColor>[
      ThemePaletteColor(hex: Color(0xFF0D1F15), name: 'Pine Forest'),
      ThemePaletteColor(hex: Color(0xFF8B2635), name: 'Crimson Red'),
      ThemePaletteColor(hex: Color(0xFF2A9D8F), name: 'Holly Green'),
      ThemePaletteColor(hex: Color(0xFFF4D06F), name: 'Warm Gold'),
      ThemePaletteColor(hex: Color(0xFFFFFBF2), name: 'Snow Cream'),
    ],
    badge: 'seasonal',
    fxConfig: ThemeFXConfig(
      type: 'christmas',
      particles: ThemeParticleConfig(
        enabled: true,
        shape: 'snowflake',
        count: 22,
        minSize: 3.5,
        maxSize: 9.0,
        minSpeed: 0.3,
        maxSpeed: 0.8,
        minOpacity: 0.35,
        maxOpacity: 0.95,
        colors: <Color>[Color(0xFFFFFFFF), Color(0xFFF4D06F), Color(0xFFE0F2FE), Color(0xFFFFE4E6)],
        directionDegrees: 80.0,
        swayAmplitude: 20.0,
        twinklePeriodMs: 3500,
      ),
      specialFX: ThemeSpecialFXConfig(
        nightDimming: false,
      ),
      touchReaction: ThemeTouchReactionConfig(
        type: 'spark',
        color: Color(0xFFF4D06F),
        durationMs: 650,
      ),
    ),
  ),
];

ThemeDefinition getThemeDefinition(String id, [List<ThemeDefinition>? catalog]) {
  final list = catalog != null && catalog.isNotEmpty ? catalog : cupidThemeCatalog;
  return list.firstWhere(
    (t) => t.id == id,
    orElse: () => cupidThemeCatalog.firstWhere(
      (t) => t.id == id,
      orElse: () => cupidThemeCatalog.first,
    ),
  );
}
