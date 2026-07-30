import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cupid_mobile/app/cupid_app.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/presentation/pair_gate_cubit.dart';

void main() {
  testWidgets('App boots to the home screen ready signal', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      CupidApp(
        createPairGateCubit: () => PairGateCubit(
          getPartnerLink: () async => const PartnerLink(partnerId: 'partner-1'),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
  });
}
