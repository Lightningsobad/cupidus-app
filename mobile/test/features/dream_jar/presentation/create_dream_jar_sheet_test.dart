import 'dart:async';

import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/widgets/create_dream_jar_sheet.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors `create_dream_jar_cubit_test.dart`'s fake — kept local to this
/// file per this repo's existing per-file fake convention
/// (`test/features/auth/presentation/*_test.dart`).
///
/// The success/pop path (`Navigator.of(context).pop(true)` once
/// `CreateDreamJarSuccess` is emitted) is intentionally not exercised here:
/// this harness's single root route has nothing below it to pop to, so
/// [_createJar] is never completed in these tests, keeping every case on
/// the validation/in-flight paths. The success path is covered instead at
/// the cubit-unit-test level.
class _FakeDreamJarRepository extends DreamJarRepository {
  _FakeDreamJarRepository(this._createJar) : super(CupidApiClient.create());

  final Future<DreamJar> Function({
    required String name,
    required num targetAmount,
    DateTime? deadline,
  })
  _createJar;

  int createJarCallCount = 0;

  @override
  Future<DreamJar> createJar({
    required String name,
    required num targetAmount,
    DateTime? deadline,
  }) {
    createJarCallCount++;
    return _createJar(name: name, targetAmount: targetAmount, deadline: deadline);
  }
}

Widget _harness(DreamJarRepository repository) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: const Locale('en'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: Scaffold(body: CreateDreamJarSheet(repository: repository)),
  );
}

void main() {
  testWidgets('shows validation messages for a blank submit', (tester) async {
    final repository = _FakeDreamJarRepository(
      ({required name, required targetAmount, deadline}) =>
          Completer<DreamJar>().future,
    );

    await tester.pumpWidget(_harness(repository));

    await tester.tap(find.text('Create Dream Jar'));
    await tester.pump();

    expect(find.text('Please enter a name'), findsOneWidget);
    expect(find.text('Enter an amount greater than 0'), findsOneWidget);
    expect(repository.createJarCallCount, 0);
  });

  testWidgets('ignores a second submit while the first is in flight', (
    tester,
  ) async {
    final completer = Completer<DreamJar>();
    final repository = _FakeDreamJarRepository(
      ({required name, required targetAmount, deadline}) => completer.future,
    );

    await tester.pumpWidget(_harness(repository));
    await tester.enterText(find.byType(TextField).at(0), 'Trip to Da Lat');
    await tester.enterText(find.byType(TextField).at(1), '500000');

    await tester.tap(find.text('Create Dream Jar'));
    await tester.pump();
    await tester.tap(find.text('Create Dream Jar'), warnIfMissed: false);
    await tester.pump();

    expect(repository.createJarCallCount, 1);
  });
}
