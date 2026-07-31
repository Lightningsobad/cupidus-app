import 'package:cupid_mobile/features/vibes/domain/vibe_mood.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VibeMood', () {
    test('every backend Mood value round-trips through fromWire', () {
      for (final mood in VibeMood.values) {
        expect(VibeMood.fromWire(mood.wireValue), mood);
      }
    });

    test('horny displays as spicy', () {
      expect(VibeMood.horny.displayId, 'spicy');
      expect(VibeMood.horny.wireValue, 'horny');
    });

    test('fromWire returns null for an unknown wire value, not a throw', () {
      expect(VibeMood.fromWire('soft'), isNull);
      expect(VibeMood.fromWire(''), isNull);
    });
  });
}
