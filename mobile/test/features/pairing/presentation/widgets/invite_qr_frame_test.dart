import 'dart:io';
import 'dart:typed_data';

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/pairing/presentation/widgets/invite_qr_frame.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Lower-case on purpose: an encoder that "helpfully" upper-cases the payload
/// to reach QR alphanumeric mode would still scan, and would still be the
/// wrong value (`architecture/contract-summary.md` section 1).
const String _fixtureCode = 'zz9qx1';

/// The padded art area inside the 186px paper frame (`ux/ux-spec.md` §1).
const double _artSize = 154;

const double _badgeSize = 40;
const double _badgeBoxCap = 50;

/// Relative to `mobile/`, the directory `flutter test` runs from (same
/// convention as `test/design_system/no_fork_guard_test.dart`).
const String _widgetSourcePath =
    'lib/features/pairing/presentation/widgets/invite_qr_frame.dart';

Widget _harness(String code, {Locale? locale}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    locale: locale,
    // No BlocProvider and no `setupServiceLocator()`: the frame has to render
    // from its `code` argument alone, so mounting it bare is the assertion
    // that it makes no cubit or repository call.
    home: Scaffold(body: Center(child: InviteQrFrame(code: code))),
  );
}

/// The painter the mounted frame actually handed the encoder, as opposed to
/// the argument the test passed in. `QrImageView` keeps its `data` private, so
/// this painter's pixels are the only readable evidence of the real payload.
QrPainter _mountedPainter(WidgetTester tester) {
  return tester
      .widgetList<CustomPaint>(
        find.descendant(
          of: find.byType(QrImageView),
          matching: find.byType(CustomPaint),
        ),
      )
      .map((CustomPaint paint) => paint.painter)
      .whereType<QrPainter>()
      .single;
}

/// An independently encoded QR for [data], configured exactly as the frame
/// configures its own.
QrPainter _reference(String data) {
  return QrPainter(
    data: data,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.H,
    gapless: true,
    eyeStyle: const QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: QrPalette.moduleInk,
    ),
    dataModuleStyle: const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: QrPalette.moduleInk,
    ),
  );
}

Future<Uint8List> _pixels(QrPainter painter) async {
  return (await painter.toImageData(_artSize))!.buffer.asUint8List();
}

void main() {
  testWidgets('AC2: the art encodes the bare code, never an upper-cased or '
      'URL-wrapped variant', (tester) async {
    await tester.pumpWidget(_harness(_fixtureCode));
    await tester.pump();

    final QrPainter mounted = _mountedPainter(tester);

    // `runAsync`: rasterizing a `ui.Picture` is real async work the fake test
    // clock never completes.
    await tester.runAsync(() async {
      final Uint8List rendered = await _pixels(mounted);

      expect(rendered, await _pixels(_reference(_fixtureCode)));
      expect(
        rendered,
        isNot(await _pixels(_reference(_fixtureCode.toUpperCase()))),
      );
      expect(
        rendered,
        isNot(
          await _pixels(
            _reference('https://cupid.app/pair?code=$_fixtureCode'),
          ),
        ),
      );
    });
  });

  testWidgets('AC2: the configured error correction level is H', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(_fixtureCode));
    await tester.pump();

    expect(
      tester.widget<QrImageView>(find.byType(QrImageView)).errorCorrectionLevel,
      QrErrorCorrectLevel.H,
    );
    // The painter reports the level the encoder resolved, not the argument.
    expect(_mountedPainter(tester).errorCorrectionLevel, QrErrorCorrectLevel.H);
  });

  testWidgets('the badge box stays inside the 50px occlusion budget', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(_fixtureCode));
    await tester.pump();

    expect(tester.getSize(find.byType(QrImageView)), const Size(_artSize, _artSize));

    final Finder badge = find
        .ancestor(
          of: find.byIcon(CupidIcons.favorite),
          matching: find.byType(Container),
        )
        .first;
    final BoxDecoration decoration =
        tester.widget<Container>(badge).decoration! as BoxDecoration;
    final BoxShadow ring = decoration.boxShadow!.firstWhere(
      (BoxShadow shadow) => shadow.color == QrPalette.paper,
    );

    expect(tester.getSize(badge), const Size(_badgeSize, _badgeSize));
    expect(
      _badgeSize + 2 * ring.spreadRadius,
      lessThanOrEqualTo(_badgeBoxCap),
    );
  });

  testWidgets('the accessible label names the code it carries', (tester) async {
    await tester.pumpWidget(_harness(_fixtureCode, locale: const Locale('vi')));
    await tester.pump();

    expect(
      tester.getSemantics(find.byType(InviteQrFrame)).label,
      'Mã QR chứa mã ghép đôi $_fixtureCode',
    );

    await tester.pumpWidget(_harness(_fixtureCode, locale: const Locale('en')));
    await tester.pump();

    expect(
      tester.getSemantics(find.byType(InviteQrFrame)).label,
      'QR code containing pairing code $_fixtureCode',
    );
  });

  testWidgets('the animated frame disposes its clock with the widget', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(_fixtureCode));
    await tester.pump();
    // Both design loops run forever, so every pump here is bounded: a
    // `pumpAndSettle` would never find a quiet frame.
    await tester.pump(const Duration(seconds: 2));

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(InviteQrFrame), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('the frame source carries no raw color literal', () {
    final File source = File(_widgetSourcePath);
    expect(source.existsSync(), isTrue, reason: 'missing $_widgetSourcePath');

    final String contents = source.readAsStringSync();
    expect(contents.contains('Color(0x'), isFalse);
    expect(contents.contains('Colors.'), isFalse);
  });
}
