import 'package:cupid_mobile/features/onboarding/presentation/widgets/zodiac_glyph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Canonical English names as `zodiacSignFor()` returns them.
const List<String> _allSigns = <String>[
  'Aries',
  'Taurus',
  'Gemini',
  'Cancer',
  'Leo',
  'Virgo',
  'Libra',
  'Scorpio',
  'Sagittarius',
  'Capricorn',
  'Aquarius',
  'Pisces',
];

void main() {
  group('ZodiacGlyph', () {
    testWidgets('paints every sign at the chip size without throwing', (
      tester,
    ) async {
      for (final String sign in _allSigns) {
        await tester.pumpWidget(
          Center(child: ZodiacGlyph(sign: sign, size: 26)),
        );

        expect(tester.takeException(), isNull, reason: sign);
        expect(tester.getSize(find.byType(ZodiacGlyph)), const Size(26, 26));
      }
    });

    testWidgets('is decorative — the chip label carries the meaning', (
      tester,
    ) async {
      await tester.pumpWidget(
        const Center(child: ZodiacGlyph(sign: 'Pisces', size: 26)),
      );

      expect(
        find.descendant(
          of: find.byType(ZodiacGlyph),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    });
  });

  group('zodiacGlyphSpecFor', () {
    test('maps one sign per element to the design component palette', () {
      // `Zodiac Icon.dc.html` EL map: fire/earth/air/water.
      expect(
        zodiacGlyphSpecFor('Aries').ink,
        const Color.fromRGBO(255, 149, 118, 1),
      );
      expect(
        zodiacGlyphSpecFor('Taurus').ink,
        const Color.fromRGBO(95, 211, 188, 1),
      );
      expect(
        zodiacGlyphSpecFor('Gemini').ink,
        const Color.fromRGBO(183, 140, 245, 1),
      );
      expect(
        zodiacGlyphSpecFor('Cancer').ink,
        const Color.fromRGBO(255, 127, 182, 1),
      );
      expect(
        zodiacGlyphSpecFor('Gemini').disc,
        const Color.fromRGBO(183, 140, 245, 0.18),
      );
    });

    test('resolves the vi/en label from the design component SIGNS map', () {
      expect(zodiacGlyphSpecFor('Pisces').label(isVi: true), 'Song Ngư');
      expect(zodiacGlyphSpecFor('Pisces').label(isVi: false), 'Pisces');
      expect(zodiacGlyphSpecFor('Capricorn').label(isVi: true), 'Ma Kết');
    });

    test('falls back to cancer for an unknown sign instead of throwing', () {
      expect(zodiacGlyphSpecFor('Ophiuchus').sign, 'cancer');
      expect(zodiacGlyphSpecFor('').sign, 'cancer');
    });
  });
}
