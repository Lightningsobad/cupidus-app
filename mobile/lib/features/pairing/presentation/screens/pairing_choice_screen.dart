import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../invite_cubit.dart';
import '../joincode_cubit.dart';
import '../pairing_strings.dart';
import 'invite_screen.dart';
import 'joincode_screen.dart';

/// Layout values transcribed verbatim from the `isPairStart` block of the
/// locked design source (`cupid-app-design-system/Cupid Screens.dc.html` lines
/// 1571-1615). The 8pt `CupidSpacing` scale and the `CupidTypographyTokens`
/// roles have no step matching these, so they are carried as design-source
/// values rather than rounded to a nearby token (same precedent as
/// `forgot_screen.dart`).
const EdgeInsets _screenPadding = EdgeInsets.fromLTRB(20, 14, 20, 40);
const double _badgeSize = 92;
const double _badgeRadius = 34;
const double _badgeIconSize = 42;
const double _badgePinkAlpha = 0.26;
const double _badgePurpleAlpha = 0.22;
const double _titleSize = 25;
const double _titleLineHeight = 1.25;
const double _titleGap = 18;
const double _subtitleGap = 8;
const double _subtitleLineHeight = 1.6;
const double _subtitleMaxWidth = 290;
const double _headerGap = 26;
const double _rowGap = 12;
const EdgeInsets _rowPadding = EdgeInsets.all(18);
const double _rowBorderWidth = 1.5;
const double _rowContentGap = 14;
const double _primaryBorderAlpha = 0.45;
const double _tileSize = 50;
const double _tileRadius = 18;
const double _tileIconSize = 25;
const double _purpleTileAlpha = 0.2;
const double _mintTileAlpha = 0.16;
const double _rowTitleSize = 16;
const double _rowTitleLineHeight = 1.3;
const double _rowBodySize = 12.5;
const double _rowBodyLineHeight = 1.5;
const double _rowBodyGap = 3;
const double _chevronSize = 20;
const double _noteGap = 22;
const EdgeInsets _notePadding = EdgeInsets.symmetric(
  horizontal: 15,
  vertical: 13,
);
const double _noteSurfaceAlpha = 0.05;
const double _noteIconSize = 17;
const double _noteIconGap = 9;
const double _noteTextSize = 11.5;
const double _noteLineHeight = 1.55;
const double _noteTextTrailingInset = 46;

/// Direction vectors for the hero badge's
/// `linear-gradient(140deg, rgba(255,127,182,.26), rgba(183,140,245,.22))`,
/// derived exactly like `cupid_color_tokens.dart`'s `_gradient120*` pair:
/// `sin(140deg) = 0.6427876096865393`, `cos(140deg) = -0.766044443118978`.
///
/// A plain [LinearGradient] resolves these as box-normalized positions rather
/// than as a CSS direction vector, which is why the shared tokens funnel
/// through `CupidCssAngleGradient`. The badge is [_badgeSize] square, the
/// degenerate case where both maths agree exactly (pinned by
/// `test/design_system/gradient_axis_test.dart`'s "square 400x400" row), so no
/// angle correction — and therefore no new shared token — is needed here.
const Alignment _badgeGradientBegin = Alignment(
  -0.6427876096865393,
  -0.766044443118978,
);
const Alignment _badgeGradientEnd = Alignment(
  0.6427876096865393,
  0.766044443118978,
);

/// Row identity for tests and assistive-tech ordering.
const Key createCodeRowKey = Key('pairing_choice_create_row');
const Key enterCodeRowKey = Key('pairing_choice_enter_code_row');
const Key scanQrRowKey = Key('pairing_choice_scan_qr_row');

/// `pairing_choice` node (`ux/uiux-spec.md` section 6) — the pairing-flow stack
/// root for an unpaired user: `NO_TABS`, architecturally distinct from the main
/// tab shell. Renders the design source's three pairing options: create a code
/// (pushes [InviteScreen]), enter the partner's code manually, or scan the
/// partner's QR — the latter two share one push edge into [JoincodeScreen],
/// matching the design source's own `goJoinCode` mapping.
///
/// [router] is threaded into the pushed screens rather than used to route these
/// two edges: both destinations carry `create*Cubit` seams that a registry
/// [WidgetBuilder] cannot supply, so the edges stay direct pushes and the
/// router is passed along for the `waiting`/`paired` tail below them.
///
/// The design source's "later, look around first" link is deliberately absent:
/// its `goHome` target has no reachable destination for an unpaired user
/// (`pair_gate_shell.dart` renders `AppShell` only for `PairGatePaired`), so
/// shipping it would mean adding a pair-gate bypass — a new capability outside
/// this redesign (`architecture/solution.md` D1).
class PairingChoiceScreen extends StatelessWidget {
  const PairingChoiceScreen({
    super.key,
    this.router,
    InviteCubit Function()? createInviteCubit,
    JoincodeCubit Function()? createJoincodeCubit,
  }) : _createInviteCubit = createInviteCubit,
       _createJoincodeCubit = createJoincodeCubit;

  final OnboardingRouter? router;
  final InviteCubit Function()? _createInviteCubit;
  final JoincodeCubit Function()? _createJoincodeCubit;

  void _openInvite(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            InviteScreen(router: router, createInviteCubit: _createInviteCubit),
      ),
    );
  }

  void _openJoincode(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JoincodeScreen(
          router: router,
          createJoincodeCubit: _createJoincodeCubit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Scaffold(
      key: const Key('pairing_stack'),
      body: SafeArea(
        // The design source is a fixed portrait frame, but neither `main.dart`
        // nor the Android manifest locks orientation, so this column exceeds
        // the viewport once rotated or at an elevated font scale.
        child: SingleChildScrollView(
          padding: _screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    width: _badgeSize,
                    height: _badgeSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: _badgeGradientBegin,
                        end: _badgeGradientEnd,
                        colors: <Color>[
                          colors.colorAccentPink.withValues(
                            alpha: _badgePinkAlpha,
                          ),
                          colors.colorAccentPurple.withValues(
                            alpha: _badgePurpleAlpha,
                          ),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(_badgeRadius),
                    ),
                    child: CupidIcon(
                      CupidIcons.joinLeft,
                      size: _badgeIconSize,
                      color: colors.colorAccentPink,
                    ),
                  ),
                  SizedBox(height: _titleGap),
                  Text(
                    context.viEn(
                      'Ghép đôi kiểu nào?',
                      'How do you want to pair?',
                    ),
                    textAlign: TextAlign.center,
                    style: type.display.copyWith(
                      fontSize: _titleSize,
                      height: _titleLineHeight,
                      color: colors.colorText,
                    ),
                  ),
                  SizedBox(height: _subtitleGap),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _subtitleMaxWidth,
                    ),
                    child: Text(
                      context.viEn(
                        'Chỉ một người cần tạo mã — người còn lại nhập vào là '
                            'xong.',
                        'Only one of you creates a code — the other just '
                            'enters it.',
                      ),
                      textAlign: TextAlign.center,
                      style: type.caption.copyWith(
                        height: _subtitleLineHeight,
                        color: colors.colorTextMuted,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: _headerGap),
              _PairingOptionRow(
                key: createCodeRowKey,
                icon: CupidIcons.qrCode2,
                tileGradient: colors.gradientHot,
                iconColor: colors.colorOnAccent,
                title: context.viEn('Tôi tạo mã mời', "I'll create the code"),
                body: context.viEn(
                  'Nhận mã 8 ký tự + QR, gửi cho người ấy',
                  'Get an 8-char code + QR to send them',
                ),
                chevronColor: colors.colorAccentPink,
                isPrimary: true,
                onTap: () => _openInvite(context),
              ),
              SizedBox(height: _rowGap),
              _PairingOptionRow(
                key: enterCodeRowKey,
                icon: CupidIcons.dialpad,
                tileColor: colors.colorAccentPurple.withValues(
                  alpha: _purpleTileAlpha,
                ),
                iconColor: colors.colorAccentPurple,
                title: context.viEn(
                  'Người ấy đã có mã',
                  'They already have a code',
                ),
                body: context.viEn(
                  'Nhập tay hoặc dán từ tin nhắn',
                  'Type it in or paste from a message',
                ),
                chevronColor: colors.colorTextMuted,
                isPrimary: false,
                onTap: () => _openJoincode(context),
              ),
              SizedBox(height: _rowGap),
              _PairingOptionRow(
                key: scanQrRowKey,
                icon: CupidIcons.qrCodeScanner,
                tileColor: colors.colorMint.withValues(alpha: _mintTileAlpha),
                iconColor: colors.colorMint,
                title: context.viEn(
                  'Quét QR trên máy họ',
                  'Scan the QR on their phone',
                ),
                body: context.viEn(
                  'Nhanh nhất khi hai người ngồi cạnh nhau',
                  "Fastest when you're sitting together",
                ),
                chevronColor: colors.colorTextMuted,
                isPrimary: false,
                // Shares the create-code row's sibling edge verbatim: one
                // destination, one method, no `qrMode` flag for STORY-003 to
                // unpick when it adds camera capture on that screen.
                onTap: () => _openJoincode(context),
              ),
              SizedBox(height: _noteGap),
              Container(
                padding: _notePadding,
                decoration: BoxDecoration(
                  color: colors.colorText.withValues(alpha: _noteSurfaceAlpha),
                  borderRadius: BorderRadius.circular(platform.radiusSmall),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ExcludeSemantics(
                      child: CupidIcon(
                        CupidIcons.lock,
                        variant: CupidIconVariant.soft,
                        size: _noteIconSize,
                        color: colors.colorMint,
                      ),
                    ),
                    SizedBox(width: _noteIconGap),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: _noteTextTrailingInset,
                        ),
                        child: Text(
                          context.viEn(
                            'Một tài khoản Cupid chỉ ghép được với một người. '
                                'Muốn đổi thì phải huỷ ghép trước.',
                            'One Cupid account pairs with one person only. To '
                                'change, unpair first.',
                          ),
                          style: type.caption.copyWith(
                            fontSize: _noteTextSize,
                            height: _noteLineHeight,
                            color: colors.colorTextMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One tappable pairing-method row. [isPrimary] switches on the recommended
/// option's pink-tinted border and glow shadow; every other difference between
/// the three rows is a parameter, so the design source's single row pattern
/// stays a single widget.
class _PairingOptionRow extends StatelessWidget {
  const _PairingOptionRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.chevronColor,
    required this.isPrimary,
    required this.onTap,
    this.tileColor,
    this.tileGradient,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final Color chevronColor;
  final bool isPrimary;
  final VoidCallback onTap;

  /// Flat tint fill for the leading tile. Mutually exclusive with
  /// [tileGradient], which the recommended row uses instead.
  final Color? tileColor;
  final Gradient? tileGradient;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final BorderRadius shape = BorderRadius.circular(platform.radiusCard);

    return Semantics(
      button: true,
      // The supporting copy is part of the accessible name so it is not lost
      // to assistive tech; the tile and chevron glyphs are decorative
      // reinforcement and are excluded rather than announced separately.
      label: '$title, $body',
      onTap: onTap,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.colorSurface,
          borderRadius: shape,
          border: Border.all(
            color: isPrimary
                ? colors.colorAccentPink.withValues(alpha: _primaryBorderAlpha)
                : colors.colorLine,
            width: _rowBorderWidth,
          ),
          boxShadow: isPrimary ? colors.glowShadow : null,
        ),
        // Transparent so the row's own fill and glow above stay visible while
        // the ink response paints over them (`cupid_primary_button.dart` uses
        // the same decorate-then-overlay split).
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: shape,
            child: Padding(
              padding: _rowPadding,
              child: Row(
                children: <Widget>[
                  Container(
                    width: _tileSize,
                    height: _tileSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tileColor,
                      gradient: tileGradient,
                      borderRadius: BorderRadius.circular(_tileRadius),
                    ),
                    child: CupidIcon(icon, size: _tileIconSize, color: iconColor),
                  ),
                  SizedBox(width: _rowContentGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: type.body.copyWith(
                            fontSize: _rowTitleSize,
                            fontWeight: FontWeight.w800,
                            height: _rowTitleLineHeight,
                            color: colors.colorText,
                          ),
                        ),
                        SizedBox(height: _rowBodyGap),
                        Text(
                          body,
                          style: type.caption.copyWith(
                            fontSize: _rowBodySize,
                            height: _rowBodyLineHeight,
                            color: colors.colorTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: _rowContentGap),
                  CupidIcon(
                    CupidIcons.chevronRight,
                    size: _chevronSize,
                    color: chevronColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
