import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pairing/data/pairing_failure.dart';
import 'package:cupid_mobile/features/pairing/presentation/joincode_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/joincode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// STORY-012 design-fidelity assertions against `cupid-app-design-system`
/// (`project/Cupid Screens.dc.html`, `isJoinCode` block) in the enabled dark
/// theme, extended by STORY-047 for the six-slot code entry, the paste pill,
/// and the `invite` cross-link. Behavioural coverage lives in
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

Finder _slot(int index) => find.descendant(
  of: find.byKey(Key('joincode-slot-$index')),
  matching: find.byType(Container),
);

BoxDecoration _slotDecoration(WidgetTester tester, int index) =>
    tester.widget<Container>(_slot(index)).decoration! as BoxDecoration;

/// A slot's transcribed frame: `46x56` plus the design source's non-inset
/// `1.5px` border, and the `--surf` fill under a `16px` radius.
void _expectSlotFrame(WidgetTester tester, int index) {
  expect(tester.getSize(_slot(index)), const Size(49, 59));
  final BoxDecoration decoration = _slotDecoration(tester, index);
  expect(decoration.color, _dark.colorSurface);
  expect(
    decoration.borderRadius,
    BorderRadius.circular(_material.radiusSmall),
  );
}

void _expectSlotBorder(
  WidgetTester tester,
  int index,
  Color expectedColor, {
  required bool glowing,
}) {
  final BoxDecoration decoration = _slotDecoration(tester, index);
  final Border border = decoration.border! as Border;
  expect(border.top.color, expectedColor);
  expect(border.top.width, 1.5);
  expect(decoration.boxShadow, glowing ? _dark.glowShadow : isNull);
}

/// The glyph a slot paints: the entered character, the pink `|` caret, or
/// nothing at all.
void _expectSlotGlyph(
  WidgetTester tester,
  int index,
  String? character, {
  Color? color,
}) {
  final Finder glyph = find.descendant(
    of: _slot(index),
    matching: find.byType(Text),
  );
  if (character == null) {
    expect(glyph, findsNothing);
    return;
  }
  final Text text = tester.widget(glyph);
  expect(text.data, character);
  expect(text.style!.fontFamily, 'Roboto Mono');
  expect(text.style!.fontWeight, FontWeight.w500);
  expect(text.style!.fontSize, 21);
  expect(text.style!.color, color);
}

/// The hero tile is the nearest [Container] ancestor of the `link` glyph. The
/// paste pill renders a [CupidIcon] too, so the icon is matched by its glyph
/// rather than by type.
Finder _heroIcon() => find.byWidgetPredicate(
  (Widget widget) => widget is CupidIcon && widget.icon == CupidIcons.link,
);

Finder _heroBadge() =>
    find.ancestor(of: _heroIcon(), matching: find.byType(Container)).first;

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

    final CupidIcon icon = tester.widget(_heroIcon());
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

  testWidgets('empty entry renders six idle slots with the caret in the '
      'first', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    for (int i = 0; i < 6; i++) {
      _expectSlotFrame(tester, i);
      _expectSlotBorder(tester, i, _dark.colorLine, glowing: false);
    }
    _expectSlotGlyph(tester, 0, '|', color: _dark.colorAccentPink);
    for (int i = 1; i < 6; i++) {
      _expectSlotGlyph(tester, i, null);
    }

    // The slots are the visual; one field underneath owns the text state, so
    // the entry stays a single accessible control (`ux/uiux-spec.md` §9).
    expect(find.byType(TextField), findsOneWidget);
    final InputDecoration decoration = _decoration(tester);
    expect(decoration.counterText, '');
    expect(decoration.errorText, isNull);
    expect(decoration.hintText, 'Mã ghép đôi');
  });

  testWidgets('partial entry glows the live slot and parks the caret in the '
      'next', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    await tester.enterText(find.byType(TextField), '3F9');
    await tester.pump();

    _expectSlotGlyph(tester, 0, '3', color: _dark.colorText);
    _expectSlotGlyph(tester, 1, 'F', color: _dark.colorText);
    _expectSlotGlyph(tester, 2, '9', color: _dark.colorText);
    _expectSlotGlyph(tester, 3, '|', color: _dark.colorAccentPink);
    _expectSlotGlyph(tester, 4, null);
    _expectSlotGlyph(tester, 5, null);

    _expectSlotBorder(tester, 1, _dark.colorLine, glowing: false);
    _expectSlotBorder(tester, 2, _dark.colorAccentPink, glowing: true);
    _expectSlotBorder(tester, 3, _dark.colorLine, glowing: false);
  });

  testWidgets('a full entry glows the last slot and drops the caret', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    await tester.enterText(find.byType(TextField), '3F9A2B');
    await tester.pump();

    for (int i = 0; i < 5; i++) {
      _expectSlotBorder(tester, i, _dark.colorLine, glowing: false);
    }
    _expectSlotBorder(tester, 5, _dark.colorAccentPink, glowing: true);
    _expectSlotGlyph(tester, 5, 'B', color: _dark.colorText);
  });

  testWidgets('invalid code swaps every slot border to the danger token', (
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

    // The rejection stays tied to the control by description, not by colour
    // alone: it is the field's own `errorText`, not a loose sibling [Text].
    final InputDecoration decoration = _decoration(tester);
    expect(decoration.errorText, 'Mã không đúng hoặc đã hết hạn');
    expect(decoration.errorStyle!.color, _dark.colorRed);

    for (int i = 0; i < 6; i++) {
      _expectSlotBorder(tester, i, _dark.colorRed, glowing: false);
    }
  });

  testWidgets('paste pill matches the design source action row', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    final Finder label = find.text('Dán');
    expect(label, findsOneWidget);
    final Text text = tester.widget(label);
    expect(text.style!.fontSize, 14);
    expect(text.style!.fontWeight, FontWeight.w700);
    expect(text.style!.color, _dark.colorText);

    final Finder pill = find
        .ancestor(of: label, matching: find.byType(Container))
        .first;
    expect(tester.getSize(pill).height, 48);
    final BoxDecoration decoration =
        tester.widget<Container>(pill).decoration! as BoxDecoration;
    expect(
      decoration.borderRadius,
      BorderRadius.circular(_material.radiusButton),
    );
    expect((decoration.border! as Border).top.color, _dark.colorLine);
    expect((decoration.border! as Border).top.width, 1.5);
  });

  testWidgets('invite cross-link uses the design source accent link style', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    final Text link = tester.widget(find.text('Tôi mới là người tạo mã →'));
    expect(link.style!.fontSize, 13);
    expect(link.style!.fontWeight, FontWeight.w700);
    expect(link.style!.color, _dark.colorAccentPink);
  });
}
