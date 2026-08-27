import 'package:cupid_mobile/features/themes/data/theme_catalog.dart';
import 'package:cupid_mobile/features/themes/data/theme_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeDefinition & ThemeCatalog', () {
    test('catalog contains all 8 predefined themes', () {
      expect(cupidThemeCatalog.length, 8);
      final ids = cupidThemeCatalog.map((t) => t.id).toList();
      expect(ids, containsAll(<String>[
        'nebula',
        'sunset',
        'sakura',
        'midnight',
        'matcha',
        'neon',
        'butter',
        'starmap',
      ]));
    });

    test('getThemeDefinition returns theme or fallback to nebula', () {
      final sunset = getThemeDefinition('sunset');
      expect(sunset.id, 'sunset');
      expect(sunset.nameVi, 'Hoàng Hôn Đà Lạt');
      expect(sunset.price, 320);

      final unknown = getThemeDefinition('unknown-id');
      expect(unknown.id, 'nebula');
    });

    test('ThemePaletteColor parses hex correctly', () {
      final color = ThemePaletteColor.fromHex('#B78CF5', 'Lilac');
      expect(color.name, 'Lilac');
      expect(color.hex.toARGB32(), 0xFFB78CF5);
    });
  });

  group('CoupleThemeState', () {
    test('parses json correctly and handles default fields', () {
      final json = <String, dynamic>{
        'coupleId': 'userA:userB',
        'activeThemeId': 'sunset',
        'ownedThemeIds': <String>['nebula', 'sunset'],
        'heartsBalance': 920,
        'pendingThemeId': 'sakura',
        'pendingRequestedBy': 'userA',
      };

      final state = CoupleThemeState.fromJson(json);
      expect(state.coupleId, 'userA:userB');
      expect(state.activeThemeId, 'sunset');
      expect(state.isOwned('sunset'), isTrue);
      expect(state.isOwned('sakura'), isFalse);
      expect(state.isActive('sunset'), isTrue);
      expect(state.isPending('sakura'), isTrue);
      expect(state.heartsBalance, 920);
    });
  });
}
