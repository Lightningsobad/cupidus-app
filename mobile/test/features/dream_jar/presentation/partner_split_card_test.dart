import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/widgets/partner_split_card.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

List<Contribution> _contributions() => <Contribution>[
  Contribution(
    id: 'c1',
    dreamJarId: 'jar-1',
    userId: 'me',
    amount: 2180000,
    note: null,
    createdAt: DateTime(2026, 1, 1),
  ),
  Contribution(
    id: 'c2',
    dreamJarId: 'jar-1',
    userId: 'partner',
    amount: 1720000,
    note: null,
    createdAt: DateTime(2026, 1, 2),
  ),
];

Widget _harness(String? currentUserId) => MaterialApp(
  theme: buildCupidTheme(
    platform: CupidPlatform.material,
    brightness: Brightness.dark,
  ),
  locale: const Locale('vi'),
  localizationsDelegates: AppL10n.localizationsDelegates,
  supportedLocales: AppL10n.supportedLocales,
  home: Scaffold(
    body: PartnerSplitCard(
      contributions: _contributions(),
      currentUserId: currentUserId,
    ),
  ),
);

void main() {
  testWidgets('splits the totals once the signed-in id is known', (
    tester,
  ) async {
    await tester.pumpWidget(_harness('me'));
    await tester.pumpAndSettle();

    expect(find.text('2,18tr'), findsOneWidget);
    expect(find.text('1,72tr'), findsOneWidget);
    expect(find.text('Bạn đang dẫn trước 460.000₫'), findsOneWidget);
  });

  // Only an explicit sign-in populates BackendUserIdStore, so a signed-in user
  // reopening the app spends the whole session with an unresolved id — this is
  // the common path, not an edge case.
  testWidgets(
    'shows an unattributed notice instead of crediting the partner when the '
    'signed-in id has not resolved',
    (tester) async {
      await tester.pumpWidget(_harness(null));
      await tester.pumpAndSettle();

      expect(find.text('Chưa xác định được ai góp bao nhiêu'), findsOneWidget);

      // Crediting the whole jar to the partner is the defect being pinned.
      expect(find.text('3,9tr'), findsNothing);
      expect(find.text('Người ấy đang dẫn trước 3.900.000₫'), findsNothing);
      expect(find.text('Bạn'), findsNothing);
      expect(find.text('Người ấy'), findsNothing);

      // The card and its heading stay on screen; only the comparison degrades.
      expect(find.text('Ai thương cái hũ hơn'), findsOneWidget);
    },
  );
}
