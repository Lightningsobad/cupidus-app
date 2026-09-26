import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('identifiers are literal ASCII (R-15a, contract-summary.md §2)', () {
    test('ActivityCardStatus wire values match the agreed identifiers', () {
      expect(ActivityCardStatus.idea.wireValue, 'idea');
      expect(ActivityCardStatus.scheduled.wireValue, 'scheduled');
      expect(ActivityCardStatus.done.wireValue, 'done');
      expect(ActivityCardStatus.memory.wireValue, 'memory');
    });

    test('ActivityCardStatus.fromWireValue round-trips every value', () {
      for (final status in ActivityCardStatus.values) {
        expect(ActivityCardStatus.fromWireValue(status.wireValue), status);
      }
    });

    test('ActivityCardOrigin wire values match the agreed identifiers', () {
      expect(ActivityCardOrigin.manual.wireValue, 'manual');
      expect(ActivityCardOrigin.pastedLink.wireValue, 'pasted_link');
      expect(
        ActivityCardOrigin.occasionSuggestion.wireValue,
        'occasion_suggestion',
      );
    });

    test('ActivityCardOrigin.fromWireValue round-trips every value', () {
      for (final origin in ActivityCardOrigin.values) {
        expect(ActivityCardOrigin.fromWireValue(origin.wireValue), origin);
      }
    });

    test('ActivityCardReplyState wire values match the agreed identifiers '
        '(R-1b)', () {
      expect(ActivityCardReplyState.notAnswered.wireValue, 'not_answered');
      expect(ActivityCardReplyState.answered.wireValue, 'answered');
    });

    test('ActivityCardReplyState.fromWireValue round-trips every value', () {
      for (final state in ActivityCardReplyState.values) {
        expect(ActivityCardReplyState.fromWireValue(state.wireValue), state);
      }
    });

    test('ActivityCardIndoorOutdoor wire values match the agreed '
        'identifiers', () {
      expect(ActivityCardIndoorOutdoor.indoor.wireValue, 'indoor');
      expect(ActivityCardIndoorOutdoor.outdoor.wireValue, 'outdoor');
    });
  });

  group('primaryActionFor (ux/uiux-spec.md §2, bảng SC-4)', () {
    test('is total over every ActivityCardStatus', () {
      for (final status in ActivityCardStatus.values) {
        expect(() => primaryActionFor(status), returnsNormally);
      }
    });

    test('maps each status to exactly the SC-4 action', () {
      expect(
        primaryActionFor(ActivityCardStatus.idea),
        ActivityCardPrimaryAction.scheduleDate,
      );
      expect(
        primaryActionFor(ActivityCardStatus.scheduled),
        ActivityCardPrimaryAction.prepare,
      );
      expect(
        primaryActionFor(ActivityCardStatus.done),
        ActivityCardPrimaryAction.recordMemory,
      );
      expect(
        primaryActionFor(ActivityCardStatus.memory),
        ActivityCardPrimaryAction.review,
      );
    });

    test('never returns the same action for two different statuses '
        '(exactly one primary action per card, AC-11)', () {
      final actions = ActivityCardStatus.values.map(primaryActionFor).toSet();
      expect(actions, hasLength(ActivityCardStatus.values.length));
    });
  });
}
