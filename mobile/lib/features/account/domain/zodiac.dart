/// Pure Western tropical zodiac lookup. Returns the canonical English sign
/// name matching the `zodiacSign` free-string field the backend accepts
/// (`backend/src/modules/users/dto/update-profile.dto.ts` example `Aries`).
String zodiacSignFor(DateTime birthday) {
  final month = birthday.month;
  final day = birthday.day;

  bool inRange(int startMonth, int startDay, int endMonth, int endDay) {
    if (month == startMonth && day >= startDay) return true;
    if (month == endMonth && day <= endDay) return true;
    return false;
  }

  if (inRange(3, 21, 4, 19)) return 'Aries';
  if (inRange(4, 20, 5, 20)) return 'Taurus';
  if (inRange(5, 21, 6, 20)) return 'Gemini';
  if (inRange(6, 21, 7, 22)) return 'Cancer';
  if (inRange(7, 23, 8, 22)) return 'Leo';
  if (inRange(8, 23, 9, 22)) return 'Virgo';
  if (inRange(9, 23, 10, 22)) return 'Libra';
  if (inRange(10, 23, 11, 21)) return 'Scorpio';
  if (inRange(11, 22, 12, 21)) return 'Sagittarius';
  if (inRange(12, 22, 1, 19)) return 'Capricorn';
  if (inRange(1, 20, 2, 18)) return 'Aquarius';
  return 'Pisces'; // Feb 19 - Mar 20
}
