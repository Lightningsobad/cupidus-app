import 'dart:ui' show Tristate;

import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pet/data/pet_models.dart';
import 'package:cupid_mobile/features/pet/data/pet_mood.dart';
import 'package:cupid_mobile/features/pet/presentation/pet_screen.dart';
import 'package:cupid_mobile/features/pet/presentation/widgets/species_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fake_pet_repository.dart';

Widget _harness(Widget child, {FocusNode? rootFocusNode}) {
  return MediaQuery(
    // BunSprite bobs indefinitely for happy/inlove/neutral moods; these
    // tests assert on sheet content, not animation, so disable motion the
    // same way pet_screen_test.dart does to let pumpAndSettle complete.
    data: const MediaQueryData(disableAnimations: true),
    child: MaterialApp(
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      home: rootFocusNode != null
          ? Focus(focusNode: rootFocusNode, child: child)
          : child,
    ),
  );
}

PetStatus _status({String name = 'Bun'}) => PetStatus(
      pet: Pet(
        id: 'pet-1',
        coupleId: 'couple-1',
        species: PetSpecies.bunny,
        name: name,
        happiness: 70,
        level: 1,
        totalInteractions: 0,
        lastInteraction: null,
      ),
      mood: PetMood.content,
      decayedHappiness: 70,
      milestone: null,
      nextMilestone: 50,
    );

Finder _sheetDescendant(Finder matching) =>
    find.descendant(of: find.byType(BottomSheet), matching: matching);

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(CupidPrimaryButton, 'Adopt'));
  await tester.pumpAndSettle();
}

Future<void> _fillForm(
  WidgetTester tester, {
  required String species,
  required String name,
}) async {
  await tester.tap(_sheetDescendant(find.text(species)));
  await tester.pump();
  await tester.enterText(_sheetDescendant(find.byType(TextField)), name);
  await tester.pump();
}

Future<void> _submit(WidgetTester tester) async {
  await tester.tap(
    _sheetDescendant(find.widgetWithText(CupidPrimaryButton, 'Adopt')),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('AdoptSheet CTA gating', () {
    testWidgets('CTA disabled with no species and no name', (
      WidgetTester tester,
    ) async {
      final repository = FakePetRepository()
        ..paired = true
        ..status = null;

      await tester.pumpWidget(_harness(PetScreen(repository: repository)));
      await tester.pumpAndSettle();
      await _openSheet(tester);

      final CupidPrimaryButton cta = tester
          .widgetList<CupidPrimaryButton>(
            _sheetDescendant(find.byType(CupidPrimaryButton)),
          )
          .single;
      expect(cta.onPressed, isNull);
    });

    testWidgets('CTA disabled without a species even with a valid name', (
      WidgetTester tester,
    ) async {
      final repository = FakePetRepository()
        ..paired = true
        ..status = null;

      await tester.pumpWidget(_harness(PetScreen(repository: repository)));
      await tester.pumpAndSettle();
      await _openSheet(tester);
      await tester.enterText(_sheetDescendant(find.byType(TextField)), 'Bun');
      await tester.pump();

      final CupidPrimaryButton cta = tester
          .widgetList<CupidPrimaryButton>(
            _sheetDescendant(find.byType(CupidPrimaryButton)),
          )
          .single;
      expect(cta.onPressed, isNull);
    });

    testWidgets('CTA disabled for a 31-character name with species selected', (
      WidgetTester tester,
    ) async {
      final repository = FakePetRepository()
        ..paired = true
        ..status = null;

      await tester.pumpWidget(_harness(PetScreen(repository: repository)));
      await tester.pumpAndSettle();
      await _openSheet(tester);
      await _fillForm(tester, species: 'Cat', name: 'A' * 31);

      final CupidPrimaryButton cta = tester
          .widgetList<CupidPrimaryButton>(
            _sheetDescendant(find.byType(CupidPrimaryButton)),
          )
          .single;
      expect(cta.onPressed, isNull);
    });

    testWidgets('CTA enabled for a 1-character name with species selected', (
      WidgetTester tester,
    ) async {
      final repository = FakePetRepository()
        ..paired = true
        ..status = null;

      await tester.pumpWidget(_harness(PetScreen(repository: repository)));
      await tester.pumpAndSettle();
      await _openSheet(tester);
      await _fillForm(tester, species: 'Cat', name: 'A');

      final CupidPrimaryButton cta = tester
          .widgetList<CupidPrimaryButton>(
            _sheetDescendant(find.byType(CupidPrimaryButton)),
          )
          .single;
      expect(cta.onPressed, isNotNull);
    });

    testWidgets('CTA enabled for a 30-character name with species selected', (
      WidgetTester tester,
    ) async {
      final repository = FakePetRepository()
        ..paired = true
        ..status = null;

      await tester.pumpWidget(_harness(PetScreen(repository: repository)));
      await tester.pumpAndSettle();
      await _openSheet(tester);
      await _fillForm(tester, species: 'Dog', name: 'A' * 30);

      final CupidPrimaryButton cta = tester
          .widgetList<CupidPrimaryButton>(
            _sheetDescendant(find.byType(CupidPrimaryButton)),
          )
          .single;
      expect(cta.onPressed, isNotNull);
    });
  });

  group('AdoptSheet submit', () {
    testWidgets('submits exactly {species, name} with the trimmed name', (
      WidgetTester tester,
    ) async {
      final repository = FakePetRepository()
        ..paired = true
        ..status = null
        ..statusAfterAdopt = _status(name: 'Bun');

      await tester.pumpWidget(_harness(PetScreen(repository: repository)));
      await tester.pumpAndSettle();
      await _openSheet(tester);
      await _fillForm(tester, species: 'Bunny', name: '  Bun  ');
      await _submit(tester);

      expect(repository.adoptCalls, 1);
      expect(
        repository.lastAdoptArgs,
        (species: PetSpecies.bunny, name: 'Bun'),
      );
    });

    testWidgets(
      'AdoptSucceeded dismisses the sheet and reloads the pet screen',
      (WidgetTester tester) async {
        final repository = FakePetRepository()
          ..paired = true
          ..status = null
          ..statusAfterAdopt = _status(name: 'Mochi');

        await tester.pumpWidget(_harness(PetScreen(repository: repository)));
        await tester.pumpAndSettle();
        await _openSheet(tester);
        await _fillForm(tester, species: 'Bunny', name: 'Mochi');
        await _submit(tester);

        expect(find.byType(BottomSheet), findsNothing);
        expect(find.text('Mochi'), findsOneWidget);
        // Initial `PetCubit.load()` on mount, plus the reload triggered by
        // `AdoptSucceeded`.
        expect(repository.readStatusCalls, greaterThanOrEqualTo(2));
      },
    );

    testWidgets(
      'AdoptConflict renders inline error and Done dismisses and reloads',
      (WidgetTester tester) async {
        final repository = FakePetRepository()
          ..paired = true
          ..status = null
          ..adoptError = const HttpStatusFailure(
            409,
            'Your couple already has a pet! Say hi to Mochi',
          );

        await tester.pumpWidget(_harness(PetScreen(repository: repository)));
        await tester.pumpAndSettle();
        await _openSheet(tester);
        await _fillForm(tester, species: 'Bunny', name: 'Bun');
        await _submit(tester);

        expect(find.textContaining('Mochi'), findsOneWidget);
        final Finder doneButton = _sheetDescendant(
          find.widgetWithText(CupidPrimaryButton, 'Done'),
        );
        expect(doneButton, findsOneWidget);

        repository.adoptError = null;
        repository.status = _status(name: 'Mochi');
        await tester.tap(doneButton);
        await tester.pumpAndSettle();

        expect(find.byType(BottomSheet), findsNothing);
        expect(find.text('Mochi'), findsOneWidget);
      },
    );

    testWidgets(
      'AdoptRejectedNotYet renders friendly copy with no status code or '
      'countdown',
      (WidgetTester tester) async {
        final repository = FakePetRepository()
          ..paired = true
          ..status = null
          ..adoptError = const HttpStatusFailure(
            400,
            'You must be paired for at least 24 hours to adopt a pet',
          );

        await tester.pumpWidget(_harness(PetScreen(repository: repository)));
        await tester.pumpAndSettle();
        await _openSheet(tester);
        await _fillForm(tester, species: 'Bunny', name: 'Bun');
        await _submit(tester);

        expect(find.textContaining('400'), findsNothing);
        for (final String forbidden in <String>['24', 'giờ', 'hour']) {
          expect(find.textContaining(forbidden), findsNothing);
        }
        expect(
          _sheetDescendant(find.widgetWithText(CupidPrimaryButton, 'Close')),
          findsOneWidget,
        );
      },
    );

    testWidgets('AdoptFailed renders generic retry copy', (
      WidgetTester tester,
    ) async {
      final repository = FakePetRepository()
        ..paired = true
        ..status = null
        ..adoptError = const NetworkUnavailableFailure();

      await tester.pumpWidget(_harness(PetScreen(repository: repository)));
      await tester.pumpAndSettle();
      await _openSheet(tester);
      await _fillForm(tester, species: 'Bunny', name: 'Bun');
      await _submit(tester);

      expect(find.text('No internet connection'), findsOneWidget);
      expect(
        _sheetDescendant(find.widgetWithText(CupidPrimaryButton, 'Close')),
        findsOneWidget,
      );
    });
  });

  group('SpeciesPicker accessibility', () {
    testWidgets(
      'exposes single-select radio-group semantics for each species',
      (WidgetTester tester) async {
        final repository = FakePetRepository()
          ..paired = true
          ..status = null;
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(_harness(PetScreen(repository: repository)));
        await tester.pumpAndSettle();
        await _openSheet(tester);

        final SemanticsNode catNode = tester.getSemantics(
          _sheetDescendant(find.text('Cat')),
        );
        expect(catNode.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
        expect(catNode.flagsCollection.isButton, isTrue);
        expect(catNode.flagsCollection.isSelected, Tristate.isFalse);

        await tester.tap(_sheetDescendant(find.text('Cat')));
        await tester.pump();

        final SemanticsNode catNodeAfter = tester.getSemantics(
          _sheetDescendant(find.text('Cat')),
        );
        expect(catNodeAfter.flagsCollection.isSelected, Tristate.isTrue);

        handle.dispose();
      },
    );
  });

  group('AdoptSheet dismiss accessibility', () {
    testWidgets('returns focus into PetScreen after the sheet dismisses', (
      WidgetTester tester,
    ) async {
      final repository = FakePetRepository()
        ..paired = true
        ..status = null;
      // `PetAdoptPromptCard`/`CupidPrimaryButton` are outside this phase's
      // write scope and expose no `focusNode` param, so a dedicated root
      // `Focus` node stands in for "focus already inside PetScreen" — this
      // still exercises the same framework trap/restore path
      // (`showModalBottomSheet` pushes a new focus scope, then restores the
      // previously focused scope on pop) without editing out-of-scope files.
      final rootFocusNode = FocusNode(debugLabel: 'PetScreen root');
      addTearDown(rootFocusNode.dispose);

      await tester.pumpWidget(
        _harness(
          PetScreen(repository: repository),
          rootFocusNode: rootFocusNode,
        ),
      );
      await tester.pumpAndSettle();

      rootFocusNode.requestFocus();
      await tester.pump();
      expect(rootFocusNode.hasFocus, isTrue);

      await _openSheet(tester);
      expect(rootFocusNode.hasFocus, isFalse);

      // Dismiss via the modal barrier, mirroring a user tapping outside the
      // sheet (the same pop path `Navigator` uses for a barrier tap).
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing);
      expect(rootFocusNode.hasFocus, isTrue);
    });
  });

  group('PetLocked unreachability (AC3)', () {
    testWidgets(
      'no adopt CTA or species picker is reachable when unpaired',
      (WidgetTester tester) async {
        final repository = FakePetRepository()..paired = false;

        await tester.pumpWidget(_harness(PetScreen(repository: repository)));
        await tester.pumpAndSettle();

        expect(find.byType(CupidPrimaryButton), findsNothing);
        expect(find.byType(SpeciesPicker), findsNothing);
        expect(find.text('Adopt'), findsNothing);
      },
    );
  });
}
