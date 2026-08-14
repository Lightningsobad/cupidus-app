import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pairing/data/pairing_failure.dart';
import 'package:cupid_mobile/features/pairing/presentation/joincode_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/joincode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// STORY-012 design-fidelity assertions against `cupid-app-design-system`
/// (`project/Cupid Screens.dc.html`, `isJoinCode` block) in the enabled dark
/// theme. Behavioural coverage lives in
/// `test/features/pairing/presentation/joincode_screen_test.dart`.
const CupidColorTokens _dark = CupidColorTokens.dark();
const CupidPlatformTokens _material = CupidPlatformTokens.material();

/// The audited configuration is dark + `vi`: production pins `Locale('vi')`
/// while `enableEnLocale` is off (`cupid_app.dart`), and `pairing_strings.dart`
/// resolves copy from the ambient locale. `supportedLocales` must list `vi`
/// too — `WidgetsApp` resolves `locale` against it, so a `vi`-only `locale`
/// would still fall back to the default `en` list.
Widget _harness({JoincodeCubit Function()? createJoincodeCubit}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: const Locale('vi'),
    supportedLocales: const <Locale>[Locale('vi'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: JoincodeScreen(
      createJoincodeCubit:
          createJoincodeCubit ??
          () => JoincodeCubit(acceptInvitation: (_) async {}),
    ),
  );
}

InputDecoration _decoration(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).decoration!;

void _expectCodeBoxBorder(InputBorder? border, Color expectedColor) {
  expect(border, isA<OutlineInputBorder>());
  final OutlineInputBorder outline = border! as OutlineInputBorder;
  expect(outline.borderRadius, BorderRadius.circular(_material.radiusSmall));
  expect(outline.borderSide.color, expectedColor);
  expect(outline.borderSide.width, 1.5);
}

/// The badge tile is the nearest [Container] ancestor of the body's only
/// [CupidIcon]; `CupidHeader` renders its back affordance with a bare [Icon],
/// so no header glyph is matched here.
Finder _heroBadge() => find
    .ancestor(of: find.byType(CupidIcon), matching: find.byType(Container))
    .first;

void main() {
  testWidgets('hero badge renders the design source 78x78 r28 link tile', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    expect(tester.getSize(_heroBadge()), const Size(78, 78));

    final BoxDecoration decoration =
        tester.widget<Container>(_heroBadge()).decoration! as BoxDecoration;
    expect(decoration.color, _dark.colorAccentPurple.withValues(alpha: 0.2));
    expect(
      decoration.borderRadius,
      BorderRadius.circular(_material.radiusSheet),
    );

    final CupidIcon icon = tester.widget(find.byType(CupidIcon));
    expect(icon.icon, CupidIcons.link);
    expect(icon.size, 38);
    expect(icon.color, _dark.colorAccentPurple);
  });

  testWidgets('content column flows from the top, not vertically centred', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    final double viewportTop = tester
        .getTopLeft(find.byType(SingleChildScrollView))
        .dy;
    expect(tester.getTopLeft(_heroBadge()).dy - viewportTop, CupidSpacing.lg);
  });

  testWidgets('heading and sub-copy use the design source display/caption '
      'roles', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    final Text heading = tester.widget(find.text('Nhập mã của người ấy'));
    expect(heading.style!.fontFamily, 'Nunito');
    expect(heading.style!.fontWeight, FontWeight.w900);
    expect(heading.style!.fontSize, 25);
    expect(heading.style!.height, 1.25);
    expect(heading.style!.color, _dark.colorText);
    expect(heading.textAlign, TextAlign.center);

    final Text subCopy = tester.widget(
      find.text('Bảo Bae đọc mã 6 ký tự trên máy họ cho bạn.'),
    );
    expect(subCopy.style!.fontSize, 13);
    expect(subCopy.style!.height, 1.6);
    expect(subCopy.style!.color, _dark.colorTextMuted);
    expect(subCopy.textAlign, TextAlign.center);
  });

  testWidgets('vi sub-copy stays inside the design source 280px column', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    final Finder subCopy = find.text(
      'Bảo Bae đọc mã 6 ký tự trên máy họ cho bạn.',
    );
    // Line count is deliberately not asserted. `flutter test` substitutes a
    // fixed-advance test font where every glyph is `fontSize` wide, so this
    // string measures ~3 line boxes here while the emulator capture in
    // visual-fidelity/ shows it on one line at 411dp with the real font. Only
    // the width constraint and the absence of an overflow are font-independent.
    final Size size = tester.getSize(subCopy);
    expect(size.width, lessThanOrEqualTo(280));
    expect(tester.takeException(), isNull);
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

    final TextStyle style = tester
        .widget<TextField>(find.byType(TextField))
        .style!;
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
    final TextStyle style = tester
        .widget<TextField>(find.byType(TextField))
        .style!;
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
          acceptInvitation: (_) async =>
              throw const InvalidOrExpiredCodeFailure(),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), '3F9A2B');
    await tester.tap(find.text('Ghép đôi'));
    await tester.pump();
    await tester.pump();

    final InputDecoration decoration = _decoration(tester);
    expect(decoration.errorText, 'Mã không đúng hoặc đã hết hạn');
    expect(decoration.errorStyle!.color, _dark.colorRed);
    _expectCodeBoxBorder(decoration.errorBorder, _dark.colorRed);
    _expectCodeBoxBorder(decoration.focusedErrorBorder, _dark.colorRed);
  });
}
