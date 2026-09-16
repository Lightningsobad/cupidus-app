import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActivityCardOrigin wire values', () {
    test('every value round-trips through its wire value', () {
      for (final ActivityCardOrigin origin in ActivityCardOrigin.values) {
        expect(
          ActivityCardOrigin.fromWireValue(origin.wireValue),
          origin,
          reason: 'wire value "${origin.wireValue}" must decode back to itself',
        );
      }
    });

    test('the values STORY-001..STORY-004 stored still decode', () {
      // Spelled out rather than generated from the enum: a rename would still
      // satisfy a generated round-trip, and a renamed wire value silently
      // orphans every row already written with the old one (R-15a).
      expect(
        ActivityCardOrigin.fromWireValue('manual'),
        ActivityCardOrigin.manual,
      );
      expect(
        ActivityCardOrigin.fromWireValue('pasted_link'),
        ActivityCardOrigin.pastedLink,
      );
      expect(
        ActivityCardOrigin.fromWireValue('occasion_suggestion'),
        ActivityCardOrigin.occasionSuggestion,
      );
      expect(
        ActivityCardOrigin.fromWireValue('gift_suggestion'),
        ActivityCardOrigin.giftSuggestion,
      );
    });

    test('screen (9) has its own origin, appended after the existing ones', () {
      expect(
        ActivityCardOrigin.fromWireValue('date_script'),
        ActivityCardOrigin.dateScript,
      );
      expect(ActivityCardOrigin.dateScript.wireValue, 'date_script');

      // Append-only: the four earlier values keep their positions, so any
      // consumer that persisted an index rather than a wire value is unharmed.
      expect(ActivityCardOrigin.values.take(4).toList(), <ActivityCardOrigin>[
        ActivityCardOrigin.manual,
        ActivityCardOrigin.pastedLink,
        ActivityCardOrigin.occasionSuggestion,
        ActivityCardOrigin.giftSuggestion,
      ]);
      expect(ActivityCardOrigin.values.last, ActivityCardOrigin.dateScript);
    });

    test('an unknown wire value is an error, not a silent default', () {
      expect(
        () => ActivityCardOrigin.fromWireValue('date-script'),
        throwsStateError,
      );
    });

    test('no two origins share a wire value', () {
      final Set<String> seen = <String>{};
      for (final ActivityCardOrigin origin in ActivityCardOrigin.values) {
        expect(
          seen.add(origin.wireValue),
          isTrue,
          reason: 'duplicate wire value "${origin.wireValue}"',
        );
      }
    });
  });

  group('NewActivityCard', () {
    test('carries the date-script origin through to the repository gate', () {
      const NewActivityCard draft = NewActivityCard(
        title: 'Đi xem phim tài liệu',
        origin: ActivityCardOrigin.dateScript,
      );

      expect(draft.origin.wireValue, 'date_script');
      expect(draft.scheduledOn, isNull);
    });
  });
}
