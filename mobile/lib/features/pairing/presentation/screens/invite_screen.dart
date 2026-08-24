// The cubit factories below are private fields fed by public named
// parameters, so the lint's own fix (`this._field`) is not expressible — a
// named parameter cannot start with `_` (same suppression as
// `core/navigation/app_shell.dart`).
// ignore_for_file: prefer_initializing_formals

import 'package:cupid_api/cupid_api.dart' show UpdateProfileDtoCoupleTypeEnum;
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/data/account_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/pairing_invitation.dart';
import '../../data/pairing_repository.dart';
import '../couple_type.dart';
import '../invite_cubit.dart';
import '../waiting_cubit.dart';
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

/// Couple-type grid geometry (`ux/ux-spec.md` §6.8), transcribed from
/// `cupid-app-design-system/Cupid Screens.dc.html:180-196`. These gaps and box
/// sizes have no matching step on the token scale, so they are carried as
/// literals the same way the code card's own 9/10/18 gaps are.
const double _coupleIconTileSize = 38;
const double _coupleIconTileRadius = 13;
const double _coupleIconSize = 21;
const double _coupleIconLabelGap = 10;
const double _coupleLabelGap = 3;
const double _coupleCellHorizontalPadding = 14;
const double _coupleGridGutter = 10;
const double _coupleHeadingSubtextGap = 4;
const double _coupleSubtextGridGap = 12;
const double _coupleCellBorderWidth = 1.5;

/// `linear-gradient(140deg, rgba(255,127,182,.22), rgba(183,140,245,.22))` —
/// the selected cell's translucent fill. The 140deg direction pair is
/// `_MoodCell`'s (`features/vibes/presentation/widgets/vibe_mood_grid.dart`),
/// but both alpha stops are this screen's own `:185` value, not `_MoodCell`'s
/// inherited `.3`/`.26`.
const Alignment _coupleGradientBegin = Alignment(
  -0.6427876096865393,
  -0.766044443118978,
);
const Alignment _coupleGradientEnd = Alignment(
  0.6427876096865393,
  0.766044443118978,
);
const double _coupleSelectedPinkOpacity = 0.22;
const double _coupleSelectedPurpleOpacity = 0.22;

/// `invite` screen (`ux/uiux-spec.md` §3, §6, §9) — inviter's code-display
/// card. In-chain, so `NO_CHROME` applies (AC4/ADR-7): no header, no tab bar.
/// The back edge the graph gives this node survives as an in-body control.
///
/// REQ-009 STORY-001 added the couple-type picker and its Continue CTA below
/// the card, closing the exclusion the earlier scope decision made. Continue
/// persists the selection and stops there — STORY-002 owns its destination.
class InviteScreen extends StatelessWidget {
  const InviteScreen({
    super.key,
    this.router,
    InviteCubit Function()? createInviteCubit,
    WaitingCubit Function()? createWaitingCubit,
  }) : _createInviteCubit = createInviteCubit,
       _createWaitingCubit = createWaitingCubit;

  /// Threaded to the pushed [WaitingScreen], which owns the `waiting` ->
  /// `paired` edge. Defaults to the composition root there.
  final OnboardingRouter? router;
  final InviteCubit Function()? _createInviteCubit;
  final WaitingCubit Function()? _createWaitingCubit;

  /// The composition root is the only place the generated
  /// [UpdateProfileDtoCoupleTypeEnum] is allowed to appear: the cubit and the
  /// widgets below speak the local [CoupleType] only
  /// (`architecture/solution.md` §4).
  InviteCubit _defaultInviteCubit() {
    final AccountRepository account = getIt<AccountRepository>();
    return InviteCubit(
      generateInvitation: getIt<PairingRepository>().generateInvitation,
      fetchCoupleType: () async => (await account.fetchProfile()).coupleType,
      saveCoupleType: (CoupleType coupleType) =>
          account.updateProfile(coupleType: _wireCoupleType(coupleType)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InviteCubit>(
      create: (_) => (_createInviteCubit ?? _defaultInviteCubit)(),
      child: _InviteView(
        router: router,
        createWaitingCubit: _createWaitingCubit,
      ),
    );
  }
}

class _InviteView extends StatelessWidget {
  const _InviteView({
    required this.router,
    WaitingCubit Function()? createWaitingCubit,
  }) : _createWaitingCubit = createWaitingCubit;

  final OnboardingRouter? router;

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
    // `invite` -> `waiting` stays a direct push rather than an
    // `OnboardingRouter` edge: `WaitingScreen` needs this invitation's
    // `expiresAt`/`code`, which a registry `WidgetBuilder` cannot carry. It is
    // the same limitation that keeps `profileSetup` out of that registry.
    // `WaitingScreen` owns the `waiting` -> `paired` edge from here.
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WaitingScreen(
          expiresAt: invitation.expiresAt,
          code: invitation.code,
          router: router,
          createWaitingCubit: _createWaitingCubit,
        ),
      ),
    );
  }

  /// Persists the selection and stops there — STORY-002 owns where Continue
  /// goes next. A failed write keeps the selection and re-enables the CTA, so
  /// the only feedback needed here is a retry prompt.
  Future<void> _submitCoupleType(BuildContext context) async {
    final bool saved = await context.read<InviteCubit>().submitCoupleType();
    if (saved || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.viEn(
            'Không thể lưu lựa chọn. Vui lòng thử lại.',
            'Could not save your choice. Please try again.',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor override intentionally removed (REQ-002 STORY-032
      // AC1): the shared CupidAppBackground app-shell layer now paints the
      // sky-gradient wash behind every screen; a Scaffold-level solid fill
      // here would occlude it.
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _InChainBackButton(
              tooltip: context.viEn('Quay lại', 'Back'),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: BlocBuilder<InviteCubit, InviteState>(
                builder: (context, state) {
                  return switch (state) {
                    InviteLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    InviteFailed() => _InviteError(
                      onRetry: () => context.read<InviteCubit>().refresh(),
                    ),
                    InviteReady(
                      :final invitation,
                      :final remaining,
                      :final selectedCoupleType,
                      :final isSaving,
                    ) =>
                      SingleChildScrollView(
                        padding: _screenPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _InviteCodeCard(
                              invitation: invitation,
                              remaining: remaining,
                              onShare: () => _share(context, invitation),
                              onCopy: () => _copy(context, invitation),
                            ),
                            const SizedBox(height: CupidSpacing.lg),
                            _CoupleTypeSection(
                              selected: selectedCoupleType,
                              onSelect: context
                                  .read<InviteCubit>()
                                  .selectCoupleType,
                            ),
                            const SizedBox(height: CupidSpacing.lg),
                            CupidPrimaryButton(
                              label: context.viEn('Tiếp tục', 'Continue'),
                              onPressed:
                                  selectedCoupleType == null || isSaving
                                  ? null
                                  : () => _submitCoupleType(context),
                            ),
                          ],
                        ),
                      ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// In-body back affordance for an in-chain screen. `NO_CHROME` (AC4/ADR-7)
/// removes the header, not the back edge the navigation graph gives the node,
/// so the header's arrow treatment and tap target move into the body.
class _InChainBackButton extends StatelessWidget {
  const _InChainBackButton({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: platformTokens.tapTarget,
          minHeight: platformTokens.tapTarget,
        ),
        child: IconButton(
          icon: const Icon(CupidIcons.arrowBack, size: 26),
          color: colors.colorAccentPink,
          tooltip: tooltip,
          onPressed: onPressed,
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
                  context.viEn('Gửi link mời', 'Share invite'),
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

/// Heading + supporting subtext + 4-card grid (`ux/ux-spec.md` §6.5). Sits
/// directly on the screen
/// background rather than inside its own `colorSurface` card, so the cards —
/// not an outer container — read as the selectable unit.
class _CoupleTypeSection extends StatelessWidget {
  const _CoupleTypeSection({required this.selected, required this.onSelect});

  final CoupleType? selected;
  final ValueChanged<CoupleType> onSelect;

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          context.viEn(
            'Tụi mình thuộc kiểu nào?',
            'What kind of couple are we?',
          ),
          style: context.cupidType.body.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.colorText,
          ),
        ),
        const SizedBox(height: _coupleHeadingSubtextGap),
        Text(
          context.viEn(
            'Cupid sẽ bật/tắt tính năng phù hợp cho kiểu của bạn.',
            'Cupid tunes default features to your type.',
          ),
          style: context.cupidType.caption.copyWith(
            fontWeight: FontWeight.w400,
            color: colors.colorTextMuted,
          ),
        ),
        const SizedBox(height: _coupleSubtextGridGap),
        _CoupleTypeGrid(selected: selected, onSelect: onSelect),
      ],
    );
  }
}

/// 2x2 grid in `ux/ux-spec.md` §6.7's catalog order (1,2 top row; 3,4 bottom).
class _CoupleTypeGrid extends StatelessWidget {
  const _CoupleTypeGrid({required this.selected, required this.onSelect});

  final CoupleType? selected;
  final ValueChanged<CoupleType> onSelect;

  @override
  Widget build(BuildContext context) {
    const List<CoupleType> catalog = CoupleType.values;

    return Column(
      children: <Widget>[
        _CoupleTypeRow(
          coupleTypes: catalog.sublist(0, 2),
          selected: selected,
          onSelect: onSelect,
        ),
        const SizedBox(height: _coupleGridGutter),
        _CoupleTypeRow(
          coupleTypes: catalog.sublist(2),
          selected: selected,
          onSelect: onSelect,
        ),
      ],
    );
  }
}

class _CoupleTypeRow extends StatelessWidget {
  const _CoupleTypeRow({
    required this.coupleTypes,
    required this.selected,
    required this.onSelect,
  });

  final List<CoupleType> coupleTypes;
  final CoupleType? selected;
  final ValueChanged<CoupleType> onSelect;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final (int index, CoupleType coupleType) in coupleTypes.indexed)
            Expanded(
              child: Padding(
                // Column gap only, never an outer inset: the grid's own edges
                // align with the screen padding.
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : _coupleGridGutter,
                ),
                child: _CoupleTypeCell(
                  coupleType: coupleType,
                  isSelected: coupleType == selected,
                  onSelect: onSelect,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One selectable card. Visual contract copied from `_MoodCell`
/// (`features/vibes/presentation/widgets/vibe_mood_grid.dart`), with
/// icon + label + subtext content instead of face + label.
class _CoupleTypeCell extends StatelessWidget {
  const _CoupleTypeCell({
    required this.coupleType,
    required this.isSelected,
    required this.onSelect,
  });

  final CoupleType coupleType;
  final bool isSelected;
  final ValueChanged<CoupleType> onSelect;

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final String label = context.viEn(
      coupleType.labelVi,
      coupleType.labelEn,
    );
    final String subtext = context.viEn(
      coupleType.subtextVi,
      coupleType.subtextEn,
    );

    return Semantics(
      button: true,
      selected: isSelected,
      // The subtext is folded into the semantic label: it is descriptive, not
      // independently interactive.
      label: '$label, $subtext',
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: () => onSelect(coupleType),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: platform.tapTarget,
              minHeight: platform.tapTarget,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: CupidSpacing.md,
                horizontal: _coupleCellHorizontalPadding,
              ),
              decoration: BoxDecoration(
                color: isSelected ? null : colors.colorSurface,
                gradient: isSelected
                    ? LinearGradient(
                        begin: _coupleGradientBegin,
                        end: _coupleGradientEnd,
                        colors: <Color>[
                          colors.colorAccentPink.withValues(
                            alpha: _coupleSelectedPinkOpacity,
                          ),
                          colors.colorAccentPurple.withValues(
                            alpha: _coupleSelectedPurpleOpacity,
                          ),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(platform.radiusCard),
                border: Border.all(
                  // The off state keeps its own surface color as the border so
                  // selecting a cell never resizes it (same rationale as
                  // `_MoodCell`; no transparent token exists and the no-fork
                  // guard bans the framework's raw color constants).
                  color: isSelected
                      ? colors.colorAccentPink
                      : colors.colorSurface,
                  width: _coupleCellBorderWidth,
                ),
                boxShadow: isSelected
                    ? colors.glowShadow
                    : platform.elevationShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: _coupleIconTileSize,
                    height: _coupleIconTileSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? null : colors.colorSurfaceAlt,
                      gradient: isSelected ? colors.gradientHot : null,
                      borderRadius: BorderRadius.circular(
                        _coupleIconTileRadius,
                      ),
                    ),
                    child: CupidIcon(
                      coupleType.icon,
                      size: _coupleIconSize,
                      // The tile fill is the selection signal, so the glyph
                      // follows its own tile's contrast pair.
                      color: isSelected
                          ? colors.colorOnAccent
                          : colors.colorTextMuted,
                    ),
                  ),
                  const SizedBox(height: _coupleIconLabelGap),
                  Text(
                    label,
                    style: type.caption.copyWith(
                      color: isSelected
                          ? colors.colorText
                          : colors.colorTextMuted,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: _coupleLabelGap),
                  Text(
                    subtext,
                    style: type.caption.copyWith(
                      color: colors.colorTextMuted,
                      fontWeight: FontWeight.w400,
                    ),
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

/// Maps the local catalog onto the generated request enum by wire literal, so
/// the 4 strings stay declared in exactly one place
/// (`presentation/couple_type.dart`).
UpdateProfileDtoCoupleTypeEnum _wireCoupleType(CoupleType coupleType) {
  return UpdateProfileDtoCoupleTypeEnum.values.firstWhere(
    (UpdateProfileDtoCoupleTypeEnum value) =>
        value.value == coupleType.wireValue,
  );
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
