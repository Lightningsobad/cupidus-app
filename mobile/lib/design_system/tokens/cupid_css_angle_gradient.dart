import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A [LinearGradient] that paints a true CSS `linear-gradient(<angle>, ...)`
/// line instead of Flutter's box-normalized one.
///
/// [begin] and [end] carry the same values a plain [LinearGradient] would, but
/// this class reads them as a *direction vector* rather than as two positions.
/// Flutter resolves an [Alignment] against the painted box
/// (`centerX + x * width / 2`), so its components are scaled by the box aspect
/// ratio and `sin`/`cos` of a CSS angle only produce that angle on a square box.
/// On welcome's 412x915 backdrop the declared 165deg collapsed to 6.86deg.
///
/// CSS defines the gradient line as passing through the box centre at the
/// declared angle, with length `|W*sin0| + |H*cos0|`. Both halves matter: an
/// axis-only correction leaves the length wrong, which slides every declared
/// stop percentage (it visibly moves `gradientBrandBackdrop`'s 58% pink band).
/// Both are derived here from the unit direction, so no trigonometry is needed
/// at paint time — `|W*dx| + |H*dy|` is the same quantity.
///
/// Every consumer funnels through [createShader], including
/// `BoxDecoration`/`DecoratedBox` and direct `createShader(bounds)` callers, so
/// no call site needs to know this type exists.
///
/// One caveat, accepted deliberately: [LinearGradient.lerp] and [scale] return
/// a plain [LinearGradient] and would drop this override mid-animation. Both
/// tokens using this class are byte-identical in dark and light, so the const
/// instances are canonically identical and `lerp` short-circuits; the fallback
/// [begin]/[end] also keep a dropped instance rendering as it did before this
/// class existed rather than as something arbitrary. Pinned by
/// `test/design_system/gradient_axis_test.dart`.
@immutable
class CupidCssAngleGradient extends LinearGradient {
  const CupidCssAngleGradient({
    required super.begin,
    required super.end,
    required super.colors,
    super.stops,
    super.tileMode,
    super.transform,
  });

  /// The CSS gradient line for [rect]: `(start, end)` of a segment centred on
  /// the box, parallel to the [begin] to [end] direction, with the CSS
  /// gradient-line length.
  (Offset, Offset) gradientLineFor(Rect rect, {TextDirection? textDirection}) {
    final Alignment resolvedBegin = begin.resolve(textDirection);
    final Alignment resolvedEnd = end.resolve(textDirection);

    final double rawX = resolvedEnd.x - resolvedBegin.x;
    final double rawY = resolvedEnd.y - resolvedBegin.y;
    final double magnitude = math.sqrt(rawX * rawX + rawY * rawY);
    final Offset direction = Offset(rawX / magnitude, rawY / magnitude);

    final double extent =
        (rect.width * direction.dx).abs() + (rect.height * direction.dy).abs();
    final Offset half = direction * (extent / 2);

    return (rect.center - half, rect.center + half);
  }

  @override
  Shader createShader(Rect rect, {TextDirection? textDirection}) {
    final (Offset from, Offset to) = gradientLineFor(
      rect,
      textDirection: textDirection,
    );

    return ui.Gradient.linear(
      from,
      to,
      colors,
      stops,
      tileMode,
      transform?.transform(rect, textDirection: textDirection)?.storage,
    );
  }
}
