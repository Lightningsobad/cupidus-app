import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/widgets/dream_jar_entry_card.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpCard(WidgetTester tester, VoidCallback onTap) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCupidTheme(
          platform: CupidPlatform.material,
          brightness: Brightness.dark,
        ),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: Scaffold(
          body: DreamJarEntryCard(
            key: const Key('home_dream_jar_entry_card'),
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  testWidgets('renders the title, subtitle and savings icon by stable key', (
    WidgetTester tester,
  ) async {
    await pumpCard(tester, () {});

    expect(find.byKey(const Key('home_dream_jar_entry_card')), findsOneWidget);
    expect(find.text('Dream Jar'), findsOneWidget);
    expect(find.text('Save toward a shared goal together'), findsOneWidget);
    expect(find.byIcon(CupidIcons.savings), findsOneWidget);
  });

  testWidgets('carries no encryption/lock/shield affordance (ADR-014a)', (
    WidgetTester tester,
  ) async {
    await pumpCard(tester, () {});

    // Only the `savings` glyph renders on the card: no second (lock/shield)
    // icon is present.
    expect(find.byType(CupidIcon), findsOneWidget);
  });

  testWidgets('tapping the card invokes onTap', (WidgetTester tester) async {
    var tapped = false;
    await pumpCard(tester, () => tapped = true);

    await tester.tap(find.byKey(const Key('home_dream_jar_entry_card')));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
