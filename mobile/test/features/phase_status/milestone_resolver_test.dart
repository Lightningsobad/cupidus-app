import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/phase_status/data/phase_status_prefs.dart';
import 'package:cupid_mobile/features/phase_status/domain/milestone_resolver.dart';
import 'package:cupid_mobile/features/phase_status/domain/phase_content.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

ContentPackage<NudgeItem> _nudges({bool withMilestone = true}) {
  return ContentPackage<NudgeItem>(
    id: 'nudges',
    version: '1.0.0',
    schemaId: nudgesSchemaId,
    items: <NudgeItem>[
      const NudgeItem(
        id: 'nudge.neutral.v1',
        slot: NudgeSlot.neutral,
        title: null,
        body: 'neutral body',
      ),
      if (withMilestone)
        const NudgeItem(
          id: 'nudge.milestone.v1',
          slot: NudgeSlot.milestone,
          title: 'milestone title',
          body: 'milestone body {n}',
        ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const List<int> thresholds = <int>[5, 10, 25, 50, 100];

  late PhaseStatusPrefs prefs;
  late MilestoneResolver resolver;

  void useStore(Map<String, Object> initial) {
    SharedPreferences.setMockInitialValues(initial);
    prefs = PhaseStatusPrefs();
    resolver = MilestoneResolver(prefs);
  }

  setUp(() => useStore(<String, Object>{}));

  Future<MilestoneResolution?> resolveAt(
    int counterValue, {
    ContentPackage<NudgeItem>? nudges,
  }) {
    return resolver.resolve(
      counterValue: counterValue,
      thresholds: thresholds,
      nudges: nudges ?? _nudges(),
    );
  }

  group('recognition — exactly once per threshold (AC-28/BR-8)', () {
    test('crossing a threshold returns the milestone caption once', () async {
      final MilestoneResolution? first = await resolveAt(5);

      expect(first, isNotNull);
      expect(first!.item.id, 'nudge.milestone.v1');
      expect(first.value, 5);
    });

    test('the next open is silent for the same threshold', () async {
      await resolveAt(5);

      expect(await resolveAt(5), isNull);
      expect(await resolveAt(6), isNull);
      expect(await resolveAt(9), isNull);
    });

    test('a later threshold is recognised once in its own turn', () async {
      expect((await resolveAt(5))!.value, 5);
      expect(await resolveAt(7), isNull);
      expect((await resolveAt(10))!.value, 10);
      expect(await resolveAt(10), isNull);
      expect((await resolveAt(25))!.value, 25);
      expect(await resolveAt(25), isNull);
    });

    test('a value below the first threshold recognises nothing', () async {
      expect(await resolveAt(0), isNull);
      expect(await resolveAt(4), isNull);
      expect(await prefs.milestoneLastShownValue(), isNull);
    });

    test('a jump past several thresholds recognises only the highest', () async {
      final MilestoneResolution? jumped = await resolveAt(30);

      expect(jumped!.value, 25);
      expect(await prefs.milestoneLastShownValue(), 25);
      expect(await resolveAt(30), isNull);
    });

    test('a milestone announced in an earlier session stays announced', () async {
      useStore(<String, Object>{
        phaseStatusMilestoneLastShownValueKey: 10,
      });

      expect(await resolveAt(12), isNull);
      expect((await resolveAt(25))!.value, 25);
    });

    test('deleting back below a recognised threshold does not re-arm it',
        () async {
      expect((await resolveAt(10))!.value, 10);

      expect(await resolveAt(6), isNull);
      expect(await resolveAt(10), isNull);
      expect(await prefs.milestoneLastShownValue(), 10);
    });
  });

  group('the resolution stops at recognition (AC-28/BR-7/AC-27)', () {
    test('it carries a caption and a number, and nothing actionable', () async {
      final MilestoneResolution resolution = (await resolveAt(5))!;

      expect(resolution.item.body, contains(phaseContentNumberPlaceholder));
      expect(resolution.item.slot, NudgeSlot.milestone);
      expect(resolution.value, 5);

      // The whole readable payload is the authored caption: no action label,
      // no invite, no share, and no next-threshold distance to render.
      expect(
        resolution.item.displayStrings.toList(),
        <String>['milestone title', 'milestone body {n}'],
      );
    });

    test('the substitution site is the only variable part', () async {
      final MilestoneResolution resolution = (await resolveAt(25))!;

      expect(
        resolution.item.body.replaceAll(
          phaseContentNumberPlaceholder,
          '${resolution.value}',
        ),
        'milestone body 25',
      );
    });
  });

  group('degradation — a missing caption is silence, not a crash', () {
    test('no milestone item in the pack returns null', () async {
      expect(await resolveAt(25, nudges: _nudges(withMilestone: false)), isNull);
    });

    test('and it does not burn the threshold for a later good pack', () async {
      await resolveAt(25, nudges: _nudges(withMilestone: false));

      expect(await prefs.milestoneLastShownValue(), isNull);
      expect((await resolveAt(25))!.value, 25);
    });

    test('an empty threshold ladder recognises nothing', () async {
      final MilestoneResolution? none = await resolver.resolve(
        counterValue: 999,
        thresholds: const <int>[],
        nudges: _nudges(),
      );

      expect(none, isNull);
      expect(await prefs.milestoneLastShownValue(), isNull);
    });
  });
}
