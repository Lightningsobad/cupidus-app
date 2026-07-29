import 'package:flutter/material.dart';

import 'cupid_platform_tokens.dart';
import '../theme/cupid_platform.dart';

/// Typography roles shared across all 4 platform x theme combinations
/// (`ux/uiux-spec.md` section 4). Text styles carry no color — color is
/// applied at the use site from `CupidColorTokens`.
@immutable
class CupidTypographyTokens extends ThemeExtension<CupidTypographyTokens> {
  const CupidTypographyTokens({
    required this.display,
    required this.cardTitle,
    required this.body,
    required this.caption,
    required this.labelMono,
  });

  /// Builds typography tokens for [platform]. [body], [cardTitle] and
  /// [caption] inherit the platform UI font family (`ux/uiux-spec.md`
  /// section 4: "Body ... rendered via platform fontStackUI"; card title and
  /// caption have no distinct font family documented, so they follow the
  /// same base UI font as body). [display] and [labelMono] use the
  /// documented dedicated families (Nunito, Roboto Mono) on both platforms.
  factory CupidTypographyTokens.forPlatform(CupidPlatform platform) {
    final CupidPlatformTokens platformTokens = platform == CupidPlatform.ios
        ? const CupidPlatformTokens.ios()
        : const CupidPlatformTokens.material();
    final String? uiFontFamily = platformTokens.uiFontFamily;
    return CupidTypographyTokens(
      display: const TextStyle(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w900,
        fontSize: 34,
      ),
      cardTitle: TextStyle(
        fontFamily: uiFontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 22,
      ),
      body: TextStyle(
        fontFamily: uiFontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 17,
      ),
      caption: TextStyle(
        fontFamily: uiFontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 13,
      ),
      // `ux/uiux-spec.md` section 4 documents this role only as "Roboto
      // Mono, weight 400/500" with no point size. `fontSize` is
      // intentionally left unset (no invented value); callers size it per
      // context (tag vs. badge). `FontWeight.w400` is the regular cut;
      // `w500` is also a documented, bundled weight for emphasis, available
      // via `labelMono.copyWith(fontWeight: FontWeight.w500)`.
      labelMono: const TextStyle(
        fontFamily: 'Roboto Mono',
        fontWeight: FontWeight.w400,
      ),
    );
  }

  /// Days counter / contract title role.
  final TextStyle display;
  final TextStyle cardTitle;
  final TextStyle body;

  /// Timestamps, metadata.
  final TextStyle caption;

  /// Tags, badges.
  final TextStyle labelMono;

  @override
  CupidTypographyTokens copyWith({
    TextStyle? display,
    TextStyle? cardTitle,
    TextStyle? body,
    TextStyle? caption,
    TextStyle? labelMono,
  }) {
    return CupidTypographyTokens(
      display: display ?? this.display,
      cardTitle: cardTitle ?? this.cardTitle,
      body: body ?? this.body,
      caption: caption ?? this.caption,
      labelMono: labelMono ?? this.labelMono,
    );
  }

  @override
  CupidTypographyTokens lerp(
    ThemeExtension<CupidTypographyTokens>? other,
    double t,
  ) {
    if (other is! CupidTypographyTokens) {
      return this;
    }
    return CupidTypographyTokens(
      display: TextStyle.lerp(display, other.display, t)!,
      cardTitle: TextStyle.lerp(cardTitle, other.cardTitle, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      labelMono: TextStyle.lerp(labelMono, other.labelMono, t)!,
    );
  }
}
