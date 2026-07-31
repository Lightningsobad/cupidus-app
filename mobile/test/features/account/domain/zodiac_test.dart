import 'package:cupid_mobile/features/account/domain/zodiac.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('zodiacSignFor', () {
    void expectSign(String label, DateTime date, String expected) {
      test('$label -> $expected', () {
        expect(zodiacSignFor(date), expected);
      });
    }

    expectSign('start of Aries', DateTime(2000, 3, 21), 'Aries');
    expectSign('end of Aries', DateTime(2000, 4, 19), 'Aries');
    expectSign('day before Aries', DateTime(2000, 3, 20), 'Pisces');

    expectSign('start of Taurus', DateTime(2000, 4, 20), 'Taurus');
    expectSign('end of Taurus', DateTime(2000, 5, 20), 'Taurus');
    expectSign('day before Taurus', DateTime(2000, 4, 19), 'Aries');

    expectSign('start of Gemini', DateTime(2000, 5, 21), 'Gemini');
    expectSign('end of Gemini', DateTime(2000, 6, 20), 'Gemini');
    expectSign('day before Gemini', DateTime(2000, 5, 20), 'Taurus');

    expectSign('start of Cancer', DateTime(2000, 6, 21), 'Cancer');
    expectSign('end of Cancer', DateTime(2000, 7, 22), 'Cancer');
    expectSign('day before Cancer', DateTime(2000, 6, 20), 'Gemini');

    expectSign('start of Leo', DateTime(2000, 7, 23), 'Leo');
    expectSign('end of Leo', DateTime(2000, 8, 22), 'Leo');
    expectSign('day before Leo', DateTime(2000, 7, 22), 'Cancer');

    expectSign('start of Virgo', DateTime(2000, 8, 23), 'Virgo');
    expectSign('end of Virgo', DateTime(2000, 9, 22), 'Virgo');
    expectSign('day before Virgo', DateTime(2000, 8, 22), 'Leo');

    expectSign('start of Libra', DateTime(2000, 9, 23), 'Libra');
    expectSign('end of Libra', DateTime(2000, 10, 22), 'Libra');
    expectSign('day before Libra', DateTime(2000, 9, 22), 'Virgo');

    expectSign('start of Scorpio', DateTime(2000, 10, 23), 'Scorpio');
    expectSign('end of Scorpio', DateTime(2000, 11, 21), 'Scorpio');
    expectSign('day before Scorpio', DateTime(2000, 10, 22), 'Libra');

    expectSign('start of Sagittarius', DateTime(2000, 11, 22), 'Sagittarius');
    expectSign('end of Sagittarius', DateTime(2000, 12, 21), 'Sagittarius');
    expectSign('day before Sagittarius', DateTime(2000, 11, 21), 'Scorpio');

    expectSign('start of Capricorn', DateTime(2000, 12, 22), 'Capricorn');
    expectSign('end of Capricorn', DateTime(2001, 1, 19), 'Capricorn');
    expectSign(
      'day before Capricorn',
      DateTime(2000, 12, 21),
      'Sagittarius',
    );

    expectSign('start of Aquarius', DateTime(2000, 1, 20), 'Aquarius');
    expectSign('end of Aquarius', DateTime(2000, 2, 18), 'Aquarius');
    expectSign('day before Aquarius', DateTime(2000, 1, 19), 'Capricorn');

    expectSign('start of Pisces', DateTime(2000, 2, 19), 'Pisces');
    expectSign('end of Pisces', DateTime(2000, 3, 20), 'Pisces');
    expectSign('day before Pisces', DateTime(2000, 2, 18), 'Aquarius');
  });
}
