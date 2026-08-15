import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../icons/cupid_icons.dart';
import '../theme/cupid_platform.dart';
import '../theme/cupid_theme_context.dart';
import '../tokens/cupid_color_tokens.dart';
import '../tokens/cupid_platform_tokens.dart';
import '../tokens/cupid_spacing.dart';
import '../tokens/cupid_typography_tokens.dart';

/// Screen header — one of the four widgets in `design_system/adaptive/`
/// allowed to branch on platform (D3, AC 4). Behavior is
/// `ux/uiux-spec.md` section 6, "Header" row: iOS renders a large title with
/// a chevron-plus-text back affordance; Material renders a top app bar with
/// an arrow-only back affordance.
///
/// [onBack] is null for a screen with no back affordance (for example a top
/// -level tab root); when non-null the platform-appropriate back control is
/// shown.
class CupidHeader extends StatelessWidget implements PreferredSizeWidget {
  const CupidHeader({
    super.key,
    required this.title,
    this.onBack,
    this.backLabel,
    this.actions = const <Widget>[],
  });

  final String title;
  final VoidCallback? onBack;

  /// Text shown next to the chevron on iOS. Ignored on Material, where the
  /// back affordance is arrow-only per `ux/uiux-spec.md` section 6.
  final String? backLabel;

  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final CupidPlatform platform = CupidPlatform.of(context);
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return platform == CupidPlatform.ios
        ? _IosHeader(
            title: title,
            onBack: onBack,
            backLabel: backLabel,
            actions: actions,
            platformTokens: platformTokens,
            colors: colors,
            type: type,
          )
        : _MaterialHeader(
            title: title,
            onBack: onBack,
            actions: actions,
            platformTokens: platformTokens,
            colors: colors,
            type: type,
          );
  }
}

class _IosHeader extends StatelessWidget {
  const _IosHeader({
    required this.title,
    required this.onBack,
    required this.backLabel,
    required this.actions,
    required this.platformTokens,
    required this.colors,
    required this.type,
  });

  final String title;
  final VoidCallback? onBack;
  final String? backLabel;
  final List<Widget> actions;
  final CupidPlatformTokens platformTokens;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;

  @override
  Widget build(BuildContext context) {
    // ClipRect is load-bearing: an unclipped BackdropFilter samples and blurs
    // the whole screen behind it, not just the header band.
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Padding(
          padding: EdgeInsets.only(
            top: platformTokens.safeTop,
            left: CupidSpacing.md,
            right: CupidSpacing.md,
            bottom: CupidSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              if (onBack != null)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: platformTokens.tapTarget,
                    minHeight: platformTokens.tapTarget,
                  ),
                  child: InkWell(
                    onTap: onBack,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          CupidIcons.chevronLeft,
                          color: colors.colorAccentPink,
                          size: 26,
                        ),
                        if (backLabel != null)
                          Text(
                            backLabel!,
                            style: type.body.copyWith(
                              color: colors.colorAccentPink,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  title,
                  style: type.display.copyWith(color: colors.colorText),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}

class _MaterialHeader extends StatelessWidget {
  const _MaterialHeader({
    required this.title,
    required this.onBack,
    required this.actions,
    required this.platformTokens,
    required this.colors,
    required this.type,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final CupidPlatformTokens platformTokens;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;

  @override
  Widget build(BuildContext context) {
    // The design source renders this bar transparent over the screen
    // background with a pink 26px back arrow and a Nunito 800/21px title
    // (`Cupid Screens.dc.html`, the shared `showHeader` block).
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: colors.colorText,
      elevation: 0,
      scrolledUnderElevation: 0,
      // ClipRect is load-bearing: an unclipped BackdropFilter samples and
      // blurs the whole screen behind it, not just the header band.
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: const SizedBox.expand(),
        ),
      ),
      titleTextStyle: type.display.copyWith(
        fontSize: 21,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.21, // -.01em
        color: colors.colorText,
      ),
      leading: onBack == null
          ? null
          : ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: platformTokens.tapTarget,
                minHeight: platformTokens.tapTarget,
              ),
              child: IconButton(
                icon: const Icon(CupidIcons.arrowBack, size: 26),
                color: colors.colorAccentPink,
                onPressed: onBack,
              ),
            ),
      title: Text(title),
      actions: actions,
    );
  }
}
