import 'package:flutter_test/flutter_test.dart';
import 'package:cupid_mobile/features/emojis/data/emoji_catalog.dart';
import 'package:cupid_mobile/features/emojis/data/emoji_models.dart';

void main() {
  group('Emoji Catalog & Models Test', () {
    test('Static catalog contains 2 standard emoji packs with 20 expressions each', () {
      expect(cupidEmojiCatalog.length, greaterThanOrEqualTo(2));

      final mochiCat = cupidEmojiCatalog.firstWhere((p) => p.id == 'mochi-cat');
      expect(mochiCat.name, 'Mèo Béo Mochi');
      expect(mochiCat.emojis.length, 20);

      final babyDino = cupidEmojiCatalog.firstWhere((p) => p.id == 'baby-dino');
      expect(babyDino.name, 'Khủng Long Nhí Dodo');
      expect(babyDino.emojis.length, 20);
    });

    test('findEmojiItem retrieves correct emoji item by code', () {
      final happyCat = findEmojiItem(':mochi_cat_happy:');
      expect(happyCat, isNotNull);
      expect(happyCat!.name, 'Cười Vui Vẻ');
      expect(happyCat.code, ':mochi_cat_happy:');

      final loveDino = findEmojiItem(':dino_love:');
      expect(loveDino, isNotNull);
      expect(loveDino!.name, 'Mắt Tim Lơ Lửng');
      expect(loveDino.code, ':dino_love:');

      final nonExistent = findEmojiItem('unknown_code');
      expect(nonExistent, isNull);
    });

    test('EmojiPack serialization and deserialization roundtrip', () {
      final original = cupidEmojiCatalog.first;
      final json = original.toJson();
      final restored = EmojiPack.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.emojis.length, original.emojis.length);
      expect(restored.emojis.first.code, original.emojis.first.code);
    });

    test('CoupleEmojiState serialization and helper methods', () {
      const state = CoupleEmojiState(
        activePackId: 'mochi-cat',
        downloadedPackIds: ['mochi-cat', 'baby-dino'],
      );

      expect(state.isDownloaded('mochi-cat'), isTrue);
      expect(state.isDownloaded('baby-dino'), isTrue);
      expect(state.isDownloaded('non-downloaded-pack'), isFalse);

      final json = state.toJson();
      final restored = CoupleEmojiState.fromJson(json);

      expect(restored.activePackId, 'mochi-cat');
      expect(restored.downloadedPackIds, containsAll(['mochi-cat', 'baby-dino']));
    });
  });
}
