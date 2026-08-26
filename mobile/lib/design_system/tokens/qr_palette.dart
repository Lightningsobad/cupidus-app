import 'package:flutter/material.dart';

/// Pairing-QR frame values transcribed from the locked design source
/// (`cupid-app-design-system/Cupid Screens.dc.html`, the `isInvite` block,
/// lines 173-179).
///
/// The QR frame paints its own fixed white paper and dark modules regardless
/// of the app theme, because scan contrast is a machine-readability
/// requirement, not a styling choice: a themed dark surface behind the modules
/// would break the reader. None of these values exist in `CupidColorTokens`,
/// and a raw color literal cannot live in `lib/features` without tripping
/// `test/design_system/no_fork_guard_test.dart` (D3/ADR-004), so — mirroring
/// the `SplashPalette` / `VowPalette` precedent — they are declared here as
/// additive, non-shared design-system values consumed only by
/// `InviteQrFrame`.
abstract final class QrPalette {
  /// The QR card's paper (`background:#FFFDFE`), also the badge's ring cutout
  /// (`box-shadow:0 0 0 5px #FFFDFE`).
  static const Color paper = Color(0xFFFFFDFE);

  /// QR module and eye ink. The design source leaves the art itself as a
  /// `{{ qrArt }}` placeholder, so this is the maximum-contrast dark a QR
  /// reader expects on [paper], not a themed accent.
  static const Color moduleInk = Color(0xFF000000);

  /// `box-shadow:0 12px 34px rgba(255,107,168,.26)` under the white frame.
  static const BoxShadow frameShadow = BoxShadow(
    color: Color.fromRGBO(255, 107, 168, 0.26),
    offset: Offset(0, 12),
    blurRadius: 34,
  );

  /// The heart badge's `0 4px 12px rgba(255,107,168,.4)` lift, layered under
  /// its [paper] ring.
  static const BoxShadow badgeShadow = BoxShadow(
    color: Color.fromRGBO(255, 107, 168, 0.4),
    offset: Offset(0, 4),
    blurRadius: 12,
  );

  /// `radial-gradient(circle, rgba(255,107,168,.34), rgba(183,140,245,.14)
  /// 55%, transparent 72%)` — the decorative blob breathing behind the frame.
  static const RadialGradient ambientGlow = RadialGradient(
    colors: <Color>[
      Color.fromRGBO(255, 107, 168, 0.34),
      Color.fromRGBO(183, 140, 245, 0.14),
      Color.fromRGBO(183, 140, 245, 0.0),
    ],
    stops: <double>[0.0, 0.55, 0.72],
  );

  /// `linear-gradient(180deg, rgba(255,107,168,0), rgba(255,107,168,.16))` on
  /// the sweeping scan band.
  static const LinearGradient scanBand = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Color.fromRGBO(255, 107, 168, 0.0),
      Color.fromRGBO(255, 107, 168, 0.16),
    ],
  );

  /// The scan band's leading edge (`border-bottom:1.5px solid
  /// rgba(255,107,168,.75)`).
  static const Color scanEdge = Color.fromRGBO(255, 107, 168, 0.75);
}
