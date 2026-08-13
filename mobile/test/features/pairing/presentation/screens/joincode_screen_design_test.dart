import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pairing/data/pairing_failure.dart';
import 'package:cupid_mobile/features/pairing/presentation/joincode_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/joincode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// STORY-012 design-fidelity assertions against `cupid-app-design-system`
/// (`project/Cupid Screens.dc.html`, `isJoinCode` block) in the enabled dark
/// theme. Behavioural coverage lives in
/// `test/features/pairing/presentation/joincode_screen_test.dart`.
const CupidColorTokens _dark = CupidColorTokens.dark();
const CupidPlatformTokens _material = CupidPlatformTokens.material();

Widget _harness({JoincodeCubit Function()? createJoincodeCubit}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: JoincodeScreen(
      createJoincodeCubit:
          createJoincodeCubit ?? () => JoincodeCubit(acceptInvitation: (_) async {}),
    ),
  );
}

InputDecoration _decoration(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).decoration!;

void _expectCodeBoxBorder(InputBorder? border, Color expectedColor) {
  expect(border, isA<OutlineInputBorder>());
  final OutlineInputBorder outline = border! as OutlineInputBorder;
  expect(
    outline.borderRadius,
    BorderRadius.circular(_material.radiusSmall),
  );
  expect(outline.borderSide.color, expectedColor);
  expect(outline.borderSide.width, 1.5);
}

void main() {
  testWidgets('heading and sub-copy use the design source display/caption '
      'roles', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    final Text heading = tester.widget(find.text('Enter their code'));
    expect(heading.style!.fontFamily, 'Nunito');
    expect(heading.style!.fontWeight, FontWeight.w900);
    expect(heading.style!.fontSize, 25);
    expect(heading.style!.height, 1.25);
    expect(heading.style!.color, _dark.colorText);
    expect(heading.textAlign, TextAlign.center);

    final Text subCopy = tester.widget(
      find.text('Ask Bae to read you the 6-character code on their phone.'),
    );
    expect(subCopy.style!.fontSize, 13);
    expect(subCopy.style!.height, 1.6);
    expect(subCopy.style!.color, _dark.colorTextMuted);
    expect(subCopy.textAlign, TextAlign.center);
  });

  testWidgets('empty code entry renders the design source surface box', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    final InputDecoration decoration = _decoration(tester);
    expect(decoration.filled, isTrue);
    expect(decoration.fillColor, _dark.colorSurface);
    expect(decoration.labelText, isNull);
    expect(decoration.counterText, '');
    _expectCodeBoxBorder(decoration.enabledBorder, _dark.colorLine);
    _expectCodeBoxBorder(decoration.disabledBorder, _dark.colorLine);
    _expectCodeBoxBorder(decoration.focusedBorder, _dark.colorAccentPink);

    final TextStyle style =
        tester.widget<TextField>(find.byType(TextField)).style!;
    expect(style.fontFamily, 'Roboto Mono');
    expect(style.fontWeight, FontWeight.w500);
    expect(style.fontSize, 21);
    expect(style.color, _dark.colorText);
  });

  testWidgets('partial entry keeps the mono code treatment', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    await tester.enterText(find.byType(TextField), '3F9');
    await tester.pump();

    expect(find.text('3F9'), findsOneWidget);
    final TextStyle style =
        tester.widget<TextField>(find.byType(TextField)).style!;
    expect(style.fontFamily, 'Roboto Mono');
    expect(style.fontSize, 21);
    _expectCodeBoxBorder(_decoration(tester).enabledBorder, _dark.colorLine);
  });

  testWidgets('invalid code swaps the box border to the danger token', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        createJoincodeCubit: () => JoincodeCubit(
          acceptInvitation: (_) async => throw const InvalidOrExpiredCodeFailure(),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), '3F9A2B');
    await tester.tap(find.text('Pair up'));
    await tester.pump();
    await tester.pump();

    final InputDecoration decoration = _decoration(tester);
    expect(decoration.errorText, 'Invalid or expired code');
    expect(decoration.errorStyle!.color, _dark.colorRed);
    _expectCodeBoxBorder(decoration.errorBorder, _dark.colorRed);
    _expectCodeBoxBorder(decoration.focusedErrorBorder, _dark.colorRed);
  });
}
