import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/pairing_invitation.dart';
import '../../data/pairing_repository.dart';
import '../../data/partner_link.dart';
import '../invite_cubit.dart';
import '../waiting_cubit.dart';
import 'paired_screen.dart';
import 'waiting_screen.dart';

/// Design-source metrics for the `isInvite` block of
/// `cupid-app-design-system/project/Cupid Screens.dc.html`. `CupidSpacing`'s
/// 8pt scale has no 9/10/18/20/22/40 step and no token carries the card's
/// 12.5/11.5px caption sizes, so they are transcribed verbatim from the
/// source rather than rounded to a nearby token.
const EdgeInsets _screenPadding = EdgeInsets.fromLTRB(20, 18, 20, 40);
const EdgeInsets _cardPadding = EdgeInsets.symmetric(
  horizontal: 20,
  vertical: 22,
);
const double _codeFontSize = 36;
const double _codeLetterSpacing = _codeFontSize * 0.16;
const double _cardLabelFontSize = 12.5;
const double _cardCaptionFontSize = 11.5;
const double _actionRowGap = 9;
const double _actionIconSize = 19;
const double _actionHeight = 48;
const double _shareLabelFontSize = 15;
const double _copyBorderWidth = 1.5;

/// `linear-gradient(95deg, var(--pink), var(--purple))` on the code text,
/// mapped with the same CSS-angle convention `CupidColorTokens` uses for its
/// 120deg gradients (`sin 95deg`, `cos 95deg`).
const Alignment _codeGradientBegin = Alignment(
  -0.9961946980917455,
  -0.08715574274765817,
);
const Alignment _codeGradientEnd = Alignment(
  0.9961946980917455,
  0.08715574274765817,
);

/// `ios_share` / `content_copy` glyphs, codepoints confirmed in the bundled
/// `MaterialSymbolsRounded-Variable.ttf` cmap. Declared here rather than as
/// `CupidIcons` members because `design_system/` is outside this story's
/// write scope; promote them once it is in scope.
const IconData _iosShareIcon = IconData(
  0xe6b8,
  fontFamily: CupidIcons.fontFamily,
);
const IconData _contentCopyIcon = IconData(
  0xe14d,
  fontFamily: CupidIcons.fontFamily,
);

/// `invite` screen (`ux/uiux-spec.md` §3, §6, §9) — inviter's code-display
/// card. Has header, back target `profile` (§1 — no `profile` screen exists
/// yet in this repo, so [onBack] just pops); tab bar hidden (`NO_TABS`).
///
/// Scoped to only the code-display + share/copy card per plan §1 D2: no
/// couple-type picker, no "Continue -> Fingerprint Vow" CTA — both excluded
/// by that decision, not stubbed.
class InviteScreen extends StatelessWidget {
  const InviteScreen({
    super.key,
    InviteCubit Function()? createInviteCubit,
    WaitingCubit Function()? createWaitingCubit,
  }) : _createInviteCubit = createInviteCubit,
       _createWaitingCubit = createWaitingCubit;

  final InviteCubit Function()? _createInviteCubit;
  final WaitingCubit Function()? _createWaitingCubit;

  InviteCubit _defaultInviteCubit() => InviteCubit(
    generateInvitation: getIt<PairingRepository>().generateInvitation,
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InviteCubit>(
      create: (_) => (_createInviteCubit ?? _defaultInviteCubit)(),
      child: _InviteView(createWaitingCubit: _createWaitingCubit),
    );
  }
}

class _InviteView extends StatelessWidget {
  const _InviteView({WaitingCubit Function()? createWaitingCubit})
    : _createWaitingCubit = createWaitingCubit;

  /// Threaded through to the pushed [WaitingScreen] (mirrors
  /// `createInviteCubit`'s seam): tests supply a fake poller-backed cubit
  /// instead of `WaitingScreen`'s GetIt-backed default, since
  /// `PairingRepository`'s constructor param is private to its own library
  /// and cannot be faked from outside `data/pairing_repository.dart`.
  final WaitingCubit Function()? _createWaitingCubit;

  /// No `share_plus`-style native-share dependency exists in this phase's
  /// write scope (`pubspec.yaml` is out of scope), so "Share invite" and
  /// "Copy code" both perform the accessible copy-to-clipboard action (§9)
  /// with distinct clipboard payloads/announcements, then both advance to
  /// `waiting` per §3: "After Share or Copy is invoked, advance to waiting."
  Future<void> _share(BuildContext context, PairingInvitation invitation) =>
      _copyAndAdvance(
        context,
        invitation,
        clipboardText:
            'Cupid: ${invitation.code}\n'
            'https://cupid.app/pair?code=${invitation.code}',
        announcement: context.viEn('Đã sao chép để chia sẻ', 'Copied to share'),
      );

  Future<void> _copy(BuildContext context, PairingInvitation invitation) =>
      _copyAndAdvance(
        context,
        invitation,
        clipboardText: invitation.code,
        announcement: context.viEn('Đã sao chép', 'Copied'),
      );

  Future<void> _copyAndAdvance(
    BuildContext context,
    PairingInvitation invitation, {
    required String clipboardText,
    required String announcement,
  }) async {
    await Clipboard.setData(ClipboardData(text: clipboardText));
    if (!context.mounted) return;
    SemanticsService.sendAnnouncement(
      View.of(context),
      announcement,
      TextDirection.ltr,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(announcement)));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WaitingScreen(
          expiresAt: invitation.expiresAt,
          code: invitation.code,
          createWaitingCubit: _createWaitingCubit,
          onPaired: _onWaitingPaired,
        ),
      ),
    );
  }

  /// Advances the inviter from `waiting` to `paired` once
  /// `WaitingCubit`/`PartnerLinkPoller` (D1) detects the partner has joined
  /// (`ux/uiux-spec.md` §2 `waiting -> paired`), clearing the pairing stack so
  /// back navigation cannot return into it.
  void _onWaitingPaired(BuildContext context, PartnerLink link) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const PairedScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;

    return Scaffold(
      appBar: CupidHeader(
        title: context.viEn('Ghép đôi', 'Pair up'),
        onBack: () => Navigator.of(context).maybePop(),
        backLabel: context.viEn('Quay lại', 'Back'),
      ),
      backgroundColor: colors.colorBackground,
      body: SafeArea(
        child: BlocBuilder<InviteCubit, InviteState>(
          builder: (context, state) {
            return switch (state) {
              InviteLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              InviteFailed() => _InviteError(
                onRetry: () => context.read<InviteCubit>().refresh(),
              ),
              InviteReady(:final invitation, :final remaining) =>
                SingleChildScrollView(
                  padding: _screenPadding,
                  child: _InviteCodeCard(
                    invitation: invitation,
                    remaining: remaining,
                    onShare: () => _share(context, invitation),
                    onCopy: () => _copy(context, invitation),
                  ),
                ),
            };
          },
        ),
      ),
    );
  }
}

/// Code-display + share/copy card (`ux/uiux-spec.md` §3; `isInvite` block of
/// `cupid-app-design-system/project/Cupid Screens.dc.html`).
class _InviteCodeCard extends StatelessWidget {
  const _InviteCodeCard({
    required this.invitation,
    required this.remaining,
    required this.onShare,
    required this.onCopy,
  });

  final PairingInvitation invitation;
  final Duration remaining;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final TextStyle cardCaption = type.caption.copyWith(
      fontSize: _cardCaptionFontSize,
      color: colors.colorTextMuted,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(context.cupidPlatform.radiusCard),
        boxShadow: context.cupidPlatform.elevationShadow,
      ),
      child: Padding(
        padding: _cardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.viEn('Mã ghép đôi của bạn', 'Your pairing code'),
              textAlign: TextAlign.center,
              style: type.caption.copyWith(
                fontSize: _cardLabelFontSize,
                color: colors.colorTextMuted,
              ),
            ),
            const SizedBox(height: 10),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (Rect bounds) => LinearGradient(
                begin: _codeGradientBegin,
                end: _codeGradientEnd,
                colors: <Color>[
                  colors.colorAccentPink,
                  colors.colorAccentPurple,
                ],
              ).createShader(bounds),
              child: Text(
                invitation.code,
                textAlign: TextAlign.center,
                style: type.labelMono.copyWith(
                  fontSize: _codeFontSize,
                  fontWeight: FontWeight.w500,
                  letterSpacing: _codeLetterSpacing,
                  color: colors.colorText,
                ),
              ),
            ),
            const SizedBox(height: CupidSpacing.xs),
            Text(
              context.viEn('Mã 6 ký tự', '6-character code'),
              textAlign: TextAlign.center,
              style: cardCaption,
            ),
            Text(
              _formatRemaining(context, remaining),
              textAlign: TextAlign.center,
              style: cardCaption,
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(child: _ShareInviteButton(onPressed: onShare)),
                const SizedBox(width: _actionRowGap),
                _CopyCodeButton(onPressed: onCopy),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Primary "Share invite" pill: gradient fill + glow, not the flat
/// [CupidPrimaryButton] treatment, per the design source's own card CTA and
/// `ux/uiux-spec.md` §3 ("a 'Share invite' pill ... and a secondary
/// copy-to-clipboard icon button").
class _ShareInviteButton extends StatelessWidget {
  const _ShareInviteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final BorderRadius radius = BorderRadius.circular(
      context.cupidPlatform.radiusButton,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: colors.gradientHot,
        borderRadius: radius,
        boxShadow: colors.glowShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: SizedBox(
            height: _actionHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CupidIcon(
                  _iosShareIcon,
                  size: _actionIconSize,
                  color: colors.colorText,
                ),
                const SizedBox(width: CupidSpacing.sm),
                Text(
                  context.viEn('Chia sẻ mã mời', 'Share invite'),
                  style: context.cupidType.body.copyWith(
                    fontSize: _shareLabelFontSize,
                    fontWeight: FontWeight.w700,
                    color: colors.colorText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary copy action: icon-only square with a hairline outline, matching
/// the design source. The label survives only as the tooltip/semantics text.
class _CopyCodeButton extends StatelessWidget {
  const _CopyCodeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final BorderRadius radius = BorderRadius.circular(
      context.cupidPlatform.radiusButton,
    );

    return Tooltip(
      message: context.viEn('Sao chép mã', 'Copy code'),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: Container(
            width: _actionHeight,
            height: _actionHeight,
            decoration: BoxDecoration(
              border: Border.all(
                color: colors.colorLine,
                width: _copyBorderWidth,
              ),
              borderRadius: radius,
            ),
            child: Center(
              child: CupidIcon(
                _contentCopyIcon,
                size: _actionIconSize,
                color: colors.colorTextMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InviteError extends StatelessWidget {
  const _InviteError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(CupidSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.viEn(
                'Không thể tạo mã mời. Vui lòng thử lại.',
                'Could not create an invite code. Please try again.',
              ),
              textAlign: TextAlign.center,
              style: context.cupidType.body.copyWith(color: colors.colorRed),
            ),
            SizedBox(height: CupidSpacing.lg),
            CupidPrimaryButton(
              label: context.viEn('Thử lại', 'Retry'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

/// Live countdown text (§3's copy correction: derive from `expiresAt`, 24h
/// TTL — never the mockup's hardcoded "15 minutes" string).
String _formatRemaining(BuildContext context, Duration remaining) {
  if (remaining <= Duration.zero) {
    return context.viEn('Đã hết hạn', 'Expired');
  }
  final int hours = remaining.inHours;
  final int minutes = remaining.inMinutes.remainder(60);
  return context.viEn(
    'Hết hạn sau ${hours}h ${minutes}p',
    'Expires in ${hours}h ${minutes}m',
  );
}

/// vi/en copy transcribed from `ux/uiux-spec.md`, resolved from the ambient
/// [Locale] (mirrors `features/auth/presentation/auth_strings.dart`'s
/// `AuthLocaleText` — duplicated locally rather than imported cross-feature
/// or added to `pairing_strings.dart`, which is plan §3 P3's file, outside
/// this phase's write scope).
extension _InviteLocaleText on BuildContext {
  bool get _isVi => Localizations.localeOf(this).languageCode == 'vi';

  String viEn(String vi, String en) => _isVi ? vi : en;
}
