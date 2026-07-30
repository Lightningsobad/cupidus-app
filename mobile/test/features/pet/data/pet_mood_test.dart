import 'package:flutter_test/flutter_test.dart';
import 'package:cupid_mobile/features/pet/data/pet_mood.dart';

void main() {
  group('PetMood.fromWire', () {
    test('parses all five backend mood strings', () {
      expect(PetMood.fromWire('ecstatic'), PetMood.ecstatic);
      expect(PetMood.fromWire('happy'), PetMood.happy);
      expect(PetMood.fromWire('content'), PetMood.content);
      expect(PetMood.fromWire('sad'), PetMood.sad);
      expect(PetMood.fromWire('sick'), PetMood.sick);
    });

    test('falls back to content for unknown or missing values', () {
      expect(PetMood.fromWire('furious'), PetMood.content);
      expect(PetMood.fromWire(null), PetMood.content);
    });
  });

  group('BunSpriteState.fromMood', () {
    test('maps every backend mood to its §3 sprite state', () {
      expect(BunSpriteState.fromMood(PetMood.ecstatic), BunSpriteState.inlove);
      expect(BunSpriteState.fromMood(PetMood.happy), BunSpriteState.happy);
      expect(BunSpriteState.fromMood(PetMood.content), BunSpriteState.neutral);
      expect(BunSpriteState.fromMood(PetMood.sad), BunSpriteState.sulk);
      expect(BunSpriteState.fromMood(PetMood.sick), BunSpriteState.sick);
    });

    test('never declares a sleep state', () {
      expect(
        BunSpriteState.values.map((state) => state.name),
        isNot(contains('sleep')),
      );
    });
  });
}
