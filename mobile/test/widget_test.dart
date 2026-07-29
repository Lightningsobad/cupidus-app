import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cupid_mobile/main.dart';

void main() {
  testWidgets('App boots to the home screen ready signal', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CupidApp());

    expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
  });
}
