import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../chat_strings.dart';

// Off-scale metrics transcribed verbatim from the locked design source
// (`cupid-app-design-system/project/Cupid Screens.dc.html`, `showPartnerChip`
// node: pill `padding:5px 10px 5px 6px;gap:7px`, avatar `24px` with a `10px`
// 700-weight initial, dot `8px` at `right:-1px;bottom:-1px` with a `2px` ring,
// status `font-size:11px`). None map onto the 8pt `CupidSpacing` scale or the
// `caption` type role — see `ux/uiux-spec.md` §1.4.
const double _chipPaddingTop = 5;
const double _chipPaddingRight = 10;
const double _chipPaddingBottom = 5;
const double _chipPaddingLeft = 6;
const double _chipGap = 7;
const double _avatarSize = 24;
const double _avatarInitialFontSize = 10;
const double _dotSize = 8;
const double _dotRingWidth = 2;
const double _dotOverlap = -1;
const double _statusFontSize = 11;

/// Chat header presence affordance: the partner's avatar initial, a static
/// online dot, and the fixed v1 `đang online` stub label
/// (`ux/uiux-spec.md` §1.4, `story_master.md` AC3).
///
/// The online state is a design-source constant, not a live signal — nothing
/// in the app computes presence today (`story_master.md` Out of Scope).
///
/// [partnerDisplayName] is non-nullable on purpose: the avatar initial and the
/// accessible label are both derived from it, so there is no coherent chip to
/// render without a partner name. The caller decides whether the chip exists
/// (`chat_screen.dart`), rather than this widget degrading into a blank
/// gradient circle announcing an absent person as online.
class PartnerPresenceChip extends StatelessWidget {
  const PartnerPresenceChip({super.key, required this.partnerDisplayName});

  final String partnerDisplayName;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Semantics(
      container: true,
      // Not a tap target — the design source node carries no `onClick`, so no
      // `button` role (`ux/uiux-spec.md` §4).
      label: ChatStrings.presenceChipSemanticLabel(
        context: context,
        partnerDisplayName: partnerDisplayName,
      ),
      // The status text is excluded alongside the decorative avatar and dot:
      // the label above already carries the whole announcement, so leaving the
      // visible `đang online` in the tree would make assistive tech read the
      // status twice (`ux/uiux-spec.md` §4, `paired_screen.dart:70` pattern).
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            _chipPaddingLeft,
            _chipPaddingTop,
            _chipPaddingRight,
            _chipPaddingBottom,
          ),
          // Same pill recipe as `_PrivacyChip` in `chat_screen.dart`, which the
          // design source confirms by giving both nodes `background:var(--surf)`.
          decoration: BoxDecoration(
            color: colors.colorSurface,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _AvatarWithOnlineDot(
                initial: _avatarInitial(partnerDisplayName),
                colors: colors,
                type: type,
              ),
              const SizedBox(width: _chipGap),
              Text(
                ChatStrings.presenceChipStatus(context),
                style: type.caption.copyWith(
                  fontSize: _statusFontSize,
                  color: colors.colorTextMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _avatarInitial(String displayName) =>
      displayName.isEmpty ? '' : displayName.substring(0, 1).toUpperCase();
}

class _AvatarWithOnlineDot extends StatelessWidget {
  const _AvatarWithOnlineDot({
    required this.initial,
    required this.colors,
    required this.type,
  });

  final String initial;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;

  @override
  Widget build(BuildContext context) {
    return Stack(
      // The dot deliberately overhangs the avatar circle by 1dp; the default
      // `Clip.hardEdge` would shave that overhang off.
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          width: _avatarSize,
          height: _avatarSize,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: PartnerChipPalette.avatarGradient,
          ),
          child: Text(
            initial,
            style: type.caption.copyWith(
              fontSize: _avatarInitialFontSize,
              fontWeight: FontWeight.w700,
              color: CouplePresencePalette.avatarInitial,
            ),
          ),
        ),
        Positioned(
          right: _dotOverlap,
          bottom: _dotOverlap,
          child: Container(
            width: _dotSize,
            height: _dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.colorGreen,
              // Rings in the chip's own pill fill, not `colorBackground`: the
              // dot sits on the pill, not on the screen. Do not copy
              // `home_screen.dart:458` here (`ux/uiux-spec.md` §1.4).
              border: Border.all(
                color: colors.colorSurface,
                width: _dotRingWidth,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
