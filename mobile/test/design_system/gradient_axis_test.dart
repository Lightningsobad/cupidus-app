import 'dart:math' as math;

import 'package:cupid_mobile/design_system/tokens/cupid_color_tokens.dart';
import 'package:cupid_mobile/design_system/tokens/cupid_css_angle_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every consumer aspect class of the two CSS-angle tokens.
const Map<String, Size> _boxMatrix = <String, Size>{
  // welcome's full-screen backdrop — gradientBrandBackdrop's only consumer,
  // and the box that produced the measured 6.86-vs-15.00 deg defect.
  'welcome backdrop 412x915': Size(412, 915),
  // The degenerate case: box-normalized and geometric math agree here, so a
  // square-only matrix would pass against the defect and prove nothing.
  'square 400x400': Size(400, 400),
  // The class ~20 gradientHot consumers occupy: buttons, chips, toggles,
  // bubbles.
  'wide pill 380x52': Size(380, 52),
  // The opposite extreme, to pin sign and orientation.
  'tall narrow 52x380': Size(52, 380),
};

const CupidColorTokens _dark = CupidColorTokens.dark();
const CupidColorTokens _light = CupidColorTokens.light();

/// CSS angle of a gradient line: degrees clockwise from "to top", so the
/// direction vector is `(sin0, -cos0)` in screen space, where y grows downward.
double _cssAngleOf((Offset, Offset) line) {
  final Offset direction = line.$2 - line.$1;
  final double degrees =
      math.atan2(direction.dx, -direction.dy) * 180 / math.pi;
  return degrees < 0 ? degrees + 360 : degrees;
}

/// CSS gradient-line length: `|W*sin0| + |H*cos0|`.
double _cssExtent(Size box, double degrees) {
  final double radians = degrees * math.pi / 180;
  return (box.width * math.sin(radians)).abs() +
      (box.height * math.cos(radians)).abs();
}

/// The gradient line a plain [LinearGradient] would paint — the pre-fix math,
/// kept so the matrix can prove its assertions actually discriminate.
(Offset, Offset) _boxNormalizedLine(LinearGradient gradient, Rect rect) {
  return (
    (gradient.begin as Alignment).withinRect(rect),
    (gradient.end as Alignment).withinRect(rect),
  );
}

typedef _AngleToken = ({CupidCssAngleGradient gradient, double degrees});

void main() {
  final Map<String, _AngleToken> tokens = <String, _AngleToken>{
    'gradientBrandBackdrop': (
      gradient: _dark.gradientBrandBackdrop as CupidCssAngleGradient,
      degrees: 165,
    ),
    'gradientHot': (
      gradient: _dark.gradientHot as CupidCssAngleGradient,
      degrees: 95,
    ),
  };

  group('CSS angle and extent hold on every consumer box shape', () {
    for (final MapEntry<String, _AngleToken> token in tokens.entries) {
      for (final MapEntry<String, Size> box in _boxMatrix.entries) {
        test('${token.key} renders ${token.value.degrees}deg on ${box.key}', () {
          final Rect rect = Offset.zero & box.value;
          final (Offset, Offset) line = token.value.gradient.gradientLineFor(
            rect,
          );

          expect(
            _cssAngleOf(line),
            closeTo(token.value.degrees, 1e-9),
            reason: 'axis must be the declared CSS angle, not box-normalized',
          );
          expect(
            (line.$2 - line.$1).distance,
            closeTo(_cssExtent(box.value, token.value.degrees), 1e-9),
            reason:
                'stop percentages land off-position if the CSS gradient-line '
                'length is wrong',
          );
          final Offset midpoint = Offset.lerp(line.$1, line.$2, 0.5)!;
          expect(
            <double>[midpoint.dx, midpoint.dy],
            <Matcher>[
              closeTo(rect.center.dx, 1e-9),
              closeTo(rect.center.dy, 1e-9),
            ],
            reason: 'the CSS gradient line is centred on the box',
          );
        });
      }
    }
  });

  group('the matrix discriminates against the pre-fix math', () {
    test('gradientBrandBackdrop: box-normalized reads 6.88deg on 412x915', () {
      final Rect rect = Offset.zero & _boxMatrix['welcome backdrop 412x915']!;

      expect(
        _cssAngleOf(_boxNormalizedLine(_dark.gradientBrandBackdrop, rect)),
        closeTo(173.12, 0.01),
        reason: '180 - 6.88 off vertical: the defect this phase removes, and '
            'what welcome measured at 6.86 on a real capture',
      );
    });

    test('gradientHot: box-normalized reads 90.69deg on the 380x52 pill', () {
      final Rect rect = Offset.zero & _boxMatrix['wide pill 380x52']!;

      expect(
        _cssAngleOf(_boxNormalizedLine(_dark.gradientHot, rect)),
        closeTo(90.69, 0.01),
        reason:
            '0.69 instead of 5.00 deg off horizontal — a sub-5-deg error, '
            'below what a screenshot comparison resolves, which is why these '
            '~20 consumers are verified numerically rather than by capture',
      );
    });

    test('both maths agree on the square box, so the matrix needs the rest', () {
      final Rect rect = Offset.zero & _boxMatrix['square 400x400']!;

      for (final _AngleToken token in tokens.values) {
        expect(
          _cssAngleOf(_boxNormalizedLine(token.gradient, rect)),
          closeTo(token.degrees, 1e-9),
        );
      }
    });
  });

  group('the fix reaches every consumer', () {
    test('both tokens carry the corrected shader in both themes', () {
      expect(_dark.gradientBrandBackdrop, isA<CupidCssAngleGradient>());
      expect(_dark.gradientHot, isA<CupidCssAngleGradient>());
      expect(_light.gradientBrandBackdrop, isA<CupidCssAngleGradient>());
      expect(_light.gradientHot, isA<CupidCssAngleGradient>());
    });

    test('the direct createShader path is corrected too', () {
      // waiting_screen.dart:281 calls colors.gradientHot.createShader(bounds)
      // directly, bypassing BoxDecoration. The override is on the instance, so
      // that path needs no special case.
      const Rect bounds = Rect.fromLTWH(0, 0, 380, 52);

      expect(_dark.gradientHot.createShader(bounds), isNotNull);
      expect(
        _dark.gradientHot.createShader(
          bounds,
          textDirection: TextDirection.rtl,
        ),
        isNotNull,
      );
    });

    test('a theme lerp does not silently drop the correction', () {
      // LinearGradient.lerp returns a plain LinearGradient. Both tokens are
      // byte-identical across themes, so the const instances canonicalize and
      // lerp short-circuits; this pins that assumption instead of trusting it.
      expect(
        LinearGradient.lerp(
          _dark.gradientBrandBackdrop,
          _light.gradientBrandBackdrop,
          0.5,
        ),
        isA<CupidCssAngleGradient>(),
      );
      expect(
        LinearGradient.lerp(_dark.gradientHot, _light.gradientHot, 0.5),
        isA<CupidCssAngleGradient>(),
      );
    });
  });

  test('colors and stops are untouched by the axis fix', () {
    expect(_dark.gradientBrandBackdrop.colors, <Color>[
      const Color(0xFF7B2FBE),
      const Color(0xFFFF4B8C),
      const Color(0xFFFF3366),
    ]);
    expect(_dark.gradientBrandBackdrop.stops, <double>[0.0, 0.58, 1.0]);
    expect(_dark.gradientHot.colors, <Color>[
      const Color(0xFFFF7FB6),
      const Color(0xFFB78CF5),
    ]);
    expect(_dark.gradientHot.stops, isNull);

    // gradientDream has no measured defect and is explicitly out of scope.
    expect(_dark.gradientDream, isNot(isA<CupidCssAngleGradient>()));
  });
}
