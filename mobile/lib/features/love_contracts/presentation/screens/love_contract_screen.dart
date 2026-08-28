import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/love_contract.dart';
import '../../data/love_contract_repository.dart';
import '../love_contract_bloc.dart';
import '../love_contract_event.dart';
import '../love_contract_state.dart';
import '../widgets/add_clause_sheet.dart';
import '../widgets/clause_toggle_row.dart';
import '../widgets/hold_to_sign_button.dart';

String? _noDisplayName() => null;

/// `architecture/solution.md` ADR-7: this screen is reached two ways and the
/// two entries disagree about chrome, so the caller states which one it is
/// rather than the screen guessing from the navigation stack.
enum LoveContractEntry {
  /// In-chain step between `paired` and `vow`. AC4 `NO_CHROME`: no header, and
  /// signing advances the chain instead of returning to a caller.
  onboardingStep,

  /// Post-home destination reached from the entry tile. Keeps its own header
  /// and back edge; signing stays on the screen.
  standalone,
}

/// `contract` screen shell (`ux/uiux-spec.md` §1-§6;
/// `architecture/solution.md` §4 Boundaries). P2 built the shell, clause
/// list, add-clause entry, and loading/empty/error states; P3 added the
/// hold-to-sign control, the signed/awaiting-partner card, and the
/// sign-action error banner (§5, §6).
///
/// [partnerDisplayName] feeds the `Bloc` (`architecture/solution.md`
/// Assumption A-2: already viewer-relative, no `GET /users/:id` needed).
/// [myDisplayName] is a screen-local
/// counterpart for the caller's own name — not a `Bloc` field, since neither
/// `love_contract_bloc.dart` nor `love_contract_state.dart` are in this
/// phase's write scope; the caller (P4's entry tile) supplies both from the
/// same `GET /users/me` gate fetch it already performs.
class LoveContractScreen extends StatelessWidget {
  const LoveContractScreen({
    super.key,
    required this.repository,
    this.partnerDisplayName = _noDisplayName,
    this.myDisplayName = _noDisplayName,
    this.entry = LoveContractEntry.standalone,
    this.router,
  });

  final LoveContractRepository repository;
  final String? Function() partnerDisplayName;
  final String? Function() myDisplayName;

  /// Defaults to [LoveContractEntry.standalone] so every pre-existing caller
  /// keeps the header and the behaviour it already had; only the chain
  /// registry opts into [LoveContractEntry.onboardingStep].
  final LoveContractEntry entry;
  final OnboardingRouter? router;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoveContractBloc>(
      create: (_) => LoveContractBloc(
        repository: repository,
        partnerDisplayName: partnerDisplayName,
      )..add(const LoveContractOpened()),
      child: _LoveContractView(
        myDisplayName: myDisplayName,
        entry: entry,
        router: router,
      ),
    );
  }
}

/// Whether this viewer has put their own signature on the contract. Both
/// `signedByMe` and `bothSigned` qualify — the partner's side is the `vow`
/// screen's dual-confirmation problem, not a reason to hold the chain here.
bool _viewerHasSigned(LoveContractState state) =>
    state is LoveContractReady &&
    (state.signStatus == ContractSignStatus.signedByMe ||
        state.signStatus == ContractSignStatus.bothSigned);

class _LoveContractView extends StatelessWidget {
  const _LoveContractView({
    required this.myDisplayName,
    required this.entry,
    required this.router,
  });

  final String? Function() myDisplayName;
  final LoveContractEntry entry;
  final OnboardingRouter? router;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final bool inChain = entry == LoveContractEntry.onboardingStep;

    return Scaffold(
      // backgroundColor override intentionally removed (REQ-002 STORY-032
      // AC1): the shared CupidAppBackground app-shell layer now paints the
      // sky-gradient wash behind every screen; a Scaffold-level solid fill
      // here would occlude it.
      appBar: inChain
          ? null
          : CupidHeader(
              title: l10n.loveContractScreenTitle,
              onBack: () => Navigator.of(context).maybePop(),
            ),
      body: SafeArea(
        child: BlocConsumer<LoveContractBloc, LoveContractState>(
          // Requires an already-rendered unsigned state, so the initial load
          // transition into an already-signed contract does not bounce the
          // viewer forward: only a signature made here advances the chain.
          listenWhen: (LoveContractState previous, LoveContractState current) =>
              inChain &&
              previous is LoveContractReady &&
              !_viewerHasSigned(previous) &&
              _viewerHasSigned(current),
          listener: (BuildContext context, LoveContractState state) {
            (router ?? getIt<OnboardingRouter>()).goNext(
              context,
              OnboardingNode.loveContract,
            );
          },
          builder: (context, state) {
            return switch (state) {
              LoveContractLoading() => const _LoveContractSkeleton(),
              LoveContractLoadFailed(:final failure) =>
                _LoveContractErrorBody(failure: failure),
              LoveContractReady() => _LoveContractReadyBody(
                state: state,
                myDisplayName: myDisplayName(),
                inChain: inChain,
                onContinue: () {
                  (router ?? getIt<OnboardingRouter>()).goNext(
                    context,
                    OnboardingNode.loveContract,
                  );
                },
              ),
            };
          },
        ),
      ),
    );
  }
}

/// Loading placeholder (`ux/uiux-spec.md` §6: "reuse the existing card
/// skeleton/placeholder treatment ... not a new spinner"). No shared
/// skeleton widget exists yet in `design_system/`, so this phase builds one
/// locally from tokens rather than adding a `CircularProgressIndicator`.
class _LoveContractSkeleton extends StatelessWidget {
  const _LoveContractSkeleton();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    Widget block(double height, {double widthFactor = 1}) => FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: height,
        margin: EdgeInsets.only(bottom: CupidSpacing.sm),
        decoration: BoxDecoration(
          color: colors.colorSurfaceAlt,
          borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
        ),
      ),
    );

    return Semantics(
      label: 'loading',
      child: Padding(
        key: const Key('love_contract_loading'),
        padding: EdgeInsets.all(CupidSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(CupidSpacing.md),
              decoration: BoxDecoration(
                color: colors.colorSurface,
                borderRadius: BorderRadius.circular(platformTokens.radiusCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  block(14, widthFactor: 0.4),
                  block(28, widthFactor: 0.7),
                  block(16, widthFactor: 0.9),
                ],
              ),
            ),
            SizedBox(height: CupidSpacing.lg),
            block(56),
            block(56),
            block(56),
          ],
        ),
      ),
    );
  }
}

/// Inline mapped-error banner (`ux/uiux-spec.md` §6, STORY-003 §6 convention:
/// never the raw [CupidApiFailure] type name). The card chrome stays visible
/// — this is not a full-screen error state.
class _LoveContractErrorBody extends StatelessWidget {
  const _LoveContractErrorBody({required this.failure});

  final CupidApiFailure failure;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    final String message = switch (failure) {
      NetworkUnavailableFailure() => l10n.loveContractErrorNetwork,
      TimeoutFailure() => l10n.loveContractErrorTimeout,
      _ => l10n.loveContractErrorGeneric,
    };

    return Padding(
      key: const Key('love_contract_load_failed'),
      padding: EdgeInsets.all(CupidSpacing.md),
      child: Container(
        padding: EdgeInsets.all(CupidSpacing.md),
        decoration: BoxDecoration(
          color: colors.colorSurface,
          borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(message, style: type.body.copyWith(color: colors.colorText)),
            SizedBox(height: CupidSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => context.read<LoveContractBloc>().add(
                  const ContractRetryRequested(),
                ),
                child: Text(l10n.loveContractRetryAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Backend clause bound also enforced by `LoveContractBloc` (P1) — mirrored
/// here only for the add-clause row's disabled/enabled affordance, not
/// re-validated.
const int _maxClauseCount = 20;

class _LoveContractReadyBody extends StatelessWidget {
  const _LoveContractReadyBody({
    required this.state,
    required this.myDisplayName,
    this.inChain = false,
    this.onContinue,
  });

  final LoveContractReady state;
  final String? myDisplayName;
  final bool inChain;
  final VoidCallback? onContinue;

  Future<void> _addClause(BuildContext context) async {
    final String? text = await showAddClauseSheet(context);
    if (text != null && context.mounted) {
      context.read<LoveContractBloc>().add(CustomClauseAdded(text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    final String subtitle = myDisplayName != null && state.partnerDisplayName != null
        ? l10n.loveContractSubtitleWithNames(myDisplayName!, state.partnerDisplayName!)
        : l10n.loveContractSubtitleNeutral;

    final String? acknowledgmentLine =
        state.signStatus == ContractSignStatus.partnerAlreadySigned
        ? (state.partnerDisplayName != null
              ? l10n.loveContractPartnerAlreadySignedNamed(
                  state.partnerDisplayName!,
                )
              : l10n.loveContractPartnerAlreadySignedNeutral)
        : null;

    final List<({String id, String text})> clauses = state.allClauses
        .map((clause) => (id: clause.id, text: clause.text))
        .toList(growable: false);

    final bool canAddClause = state.selectedCount < _maxClauseCount && !state.inFlight;

    return SingleChildScrollView(
      key: const Key('love_contract_ready'),
      padding: EdgeInsets.fromLTRB(
        CupidSpacing.md,
        CupidSpacing.md,
        CupidSpacing.md,
        CupidSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.colorSurface,
              borderRadius: BorderRadius.circular(platformTokens.radiusCard),
              boxShadow: platformTokens.elevationShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(
                    CupidSpacing.md,
                    CupidSpacing.lg,
                    CupidSpacing.md,
                    CupidSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        colors.colorAccentPink.withValues(alpha: 0.18),
                        colors.colorAccentPurple.withValues(alpha: 0.18),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.loveContractSequenceLabel.toUpperCase(),
                        style: type.labelMono.copyWith(
                          color: colors.colorAccentPink,
                          fontSize: 10,
                          letterSpacing: 1.8,
                        ),
                      ),
                      SizedBox(height: CupidSpacing.sm),
                      Text(
                        l10n.loveContractScreenTitle,
                        style: type.display.copyWith(
                          color: colors.colorText,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: CupidSpacing.sm),
                      Text(
                        subtitle,
                        style: type.caption.copyWith(
                          color: colors.colorTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                _DashedRule(color: colors.colorLine),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    CupidSpacing.sm,
                    CupidSpacing.sm,
                    CupidSpacing.sm,
                    CupidSpacing.xs,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          l10n.loveContractClauseCounter(state.selectedCount),
                          style: type.caption.copyWith(
                            color: colors.colorTextMuted,
                          ),
                        ),
                      ),
                      if (state.selectedCount == 0)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: CupidSpacing.xs,
                          ),
                          child: Text(
                            l10n.loveContractEmptyHint,
                            style: type.caption.copyWith(
                              color: colors.colorTextMuted,
                            ),
                          ),
                        ),
                      for (int i = 0; i < clauses.length; i++)
                        IgnorePointer(
                          // ADR-019e: the partner viewer sees every clause
                          // (they must know what they are signing) but cannot
                          // toggle any of them; clause_toggle_row.dart is out
                          // of this story's write scope, so the read-only
                          // affordance is applied at the call site.
                          ignoring: !state.canEditClauses,
                          child: ClauseToggleRow(
                            key: ValueKey(clauses[i].id),
                            clauseNumber: i + 1,
                            text: clauses[i].text,
                            selected: state.selectedClauseIds.contains(
                              clauses[i].id,
                            ),
                            onToggle: () => context.read<LoveContractBloc>().add(
                              ClauseToggled(clauses[i].id),
                            ),
                          ),
                        ),
                      if (state.canEditClauses)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            key: const Key('love_contract_add_clause_button'),
                            onPressed: canAddClause
                                ? () => _addClause(context)
                                : null,
                            child: Text(
                              l10n.loveContractAddClauseAction,
                              style: type.body.copyWith(
                                fontWeight: FontWeight.w600,
                                color: canAddClause
                                    ? colors.colorAccentPink
                                    : colors.colorGhost,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                _DashedRule(color: colors.colorLine),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    CupidSpacing.md,
                    CupidSpacing.md,
                    CupidSpacing.md,
                    CupidSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (state.actionFailure != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: CupidSpacing.md),
                          child: _SignActionErrorBanner(
                            failure: state.actionFailure!,
                          ),
                        ),
                      if (acknowledgmentLine != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: CupidSpacing.sm),
                          child: Text(
                            acknowledgmentLine,
                            textAlign: TextAlign.center,
                            style: type.caption.copyWith(
                              color: colors.colorAccentPink,
                            ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(bottom: CupidSpacing.md),
                        child: Text(
                          l10n.loveContractSignCaption,
                          textAlign: TextAlign.center,
                          style: type.caption.copyWith(
                            color: colors.colorTextMuted,
                          ),
                        ),
                      ),
                      switch (state.signStatus) {
                        ContractSignStatus.unsigned ||
                        ContractSignStatus.partnerAlreadySigned =>
                          _SignPromptSection(enabled: state.canSign),
                        ContractSignStatus.signedByMe =>
                          _SignedConfirmationCard(
                            myDisplayName: myDisplayName,
                            statusLine: state.partnerDisplayName != null
                                ? l10n.loveContractAwaitingPartnerNamed(
                                    state.partnerDisplayName!,
                                  )
                                : l10n.loveContractAwaitingPartnerNeutral,
                          ),
                        ContractSignStatus.bothSigned =>
                          _SignedConfirmationCard(
                            myDisplayName: myDisplayName,
                            statusLine: state.partnerDisplayName != null
                                ? l10n.loveContractBothSignedNamed(
                                    state.partnerDisplayName!,
                                  )
                                : l10n.loveContractBothSignedNeutral,
                          ),
                      },
                      if (inChain && _viewerHasSigned(state)) ...<Widget>[
                        SizedBox(height: CupidSpacing.md),
                        _ContinueToVowCta(onPressed: onContinue),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: CupidSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(CupidIcons.lock, size: 16, color: colors.colorMint),
              SizedBox(width: CupidSpacing.sm),
              Flexible(
                child: Text(
                  l10n.loveContractFooterLockNote,
                  textAlign: TextAlign.center,
                  style: type.caption.copyWith(color: colors.colorTextMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// `1px dashed var(--line)` separator between the contract card's header,
/// clause list, and sign sections. Flutter has no dashed [BorderSide], so the
/// dash run is painted directly.
class _DashedRule extends StatelessWidget {
  const _DashedRule({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(painter: _DashedRulePainter(color)),
    );
  }
}

class _DashedRulePainter extends CustomPainter {
  const _DashedRulePainter(this.color);

  final Color color;

  static const double _dash = 3;
  static const double _gap = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += _dash + _gap) {
      canvas.drawLine(
        Offset(x, 0.5),
        Offset((x + _dash).clamp(0, size.width), 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedRulePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Signing prompt (`ux/uiux-spec.md` §5): the [HoldToSignButton] itself. The
/// sign caption and the `partnerAlreadySigned` acknowledgment line sit above
/// it in the shared sign section, matching the design source where the caption
/// is rendered for the signed and unsigned states alike.
class _SignPromptSection extends StatelessWidget {
  const _SignPromptSection({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return HoldToSignButton(
      enabled: enabled,
      label: l10n.loveContractHoldButtonLabel,
      semanticLabel: l10n.loveContractHoldButtonLabel,
      onHoldStarted: () =>
          context.read<LoveContractBloc>().add(const SignHoldStarted()),
      onHoldCancelled: () =>
          context.read<LoveContractBloc>().add(const SignHoldCancelled()),
      onHoldCompleted: () =>
          context.read<LoveContractBloc>().add(const SignHoldCompleted()),
    );
  }
}

/// Signed confirmation card (`ux/uiux-spec.md` §2/§5). Covers both
/// `ContractSignStatus.signedByMe` (this viewer signed, the other has not —
/// [statusLine] is the awaiting-partner copy) and `.bothSigned` ([statusLine]
/// is the both-signed copy, ADR-019c/Assumption A-1). The heading is always
/// this viewer's own signed confirmation; only the status line varies.
class _SignedConfirmationCard extends StatelessWidget {
  const _SignedConfirmationCard({
    required this.myDisplayName,
    required this.statusLine,
  });

  final String? myDisplayName;
  final String statusLine;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    final String heading = myDisplayName != null
        ? l10n.loveContractSignedByMe(myDisplayName!)
        : l10n.loveContractSignedByMeNeutral;

    return Container(
      key: const Key('love_contract_signed_card'),
      constraints: const BoxConstraints(minHeight: 64),
      padding: EdgeInsets.symmetric(
        horizontal: CupidSpacing.md,
        vertical: CupidSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.colorGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        border: Border.all(color: colors.colorGreen.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(CupidIcons.check, size: 18, color: colors.colorGreen),
              SizedBox(width: CupidSpacing.xs),
              Flexible(
                child: Text(
                  heading,
                  textAlign: TextAlign.center,
                  style: type.body.copyWith(
                    color: colors.colorGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            statusLine,
            textAlign: TextAlign.center,
            style: type.caption.copyWith(color: colors.colorTextMuted),
          ),
        ],
      ),
    );
  }
}

/// Inline mapped-error banner for a failed sign attempt
/// (`ux/uiux-spec.md` §6, ADR-006c: never the raw [CupidApiFailure] type
/// name or server string). Retry dispatches the same started -> completed
/// event pair a completed hold would — there is no separate "retry sign"
/// event in `LoveContractBloc` (P1), and this phase's write scope does not
/// add one.
class _SignActionErrorBanner extends StatelessWidget {
  const _SignActionErrorBanner({required this.failure});

  final CupidApiFailure failure;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    final String message = failure.isSignUnavailable
        ? l10n.loveContractSignUnavailable
        : switch (failure) {
            NetworkUnavailableFailure() => l10n.loveContractErrorNetwork,
            TimeoutFailure() => l10n.loveContractErrorTimeout,
            _ => l10n.loveContractErrorGeneric,
          };

    return Container(
      key: const Key('love_contract_sign_error_banner'),
      padding: EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurfaceAlt,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(message, style: type.body.copyWith(color: colors.colorText)),
          SizedBox(height: CupidSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                final bloc = context.read<LoveContractBloc>();
                bloc.add(const SignHoldStarted());
                bloc.add(const SignHoldCompleted());
              },
              child: Text(l10n.loveContractRetryAction),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueToVowCta extends StatelessWidget {
  const _ContinueToVowCta({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final BorderRadius radius = BorderRadius.circular(
      context.cupidPlatform.radiusButton,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: colors.gradientHot,
            borderRadius: radius,
            boxShadow: colors.glowShadow,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              key: const Key('love_contract_continue_button'),
              borderRadius: radius,
              onTap: onPressed,
              child: Center(
                child: Text(
                  Localizations.localeOf(context).languageCode == 'vi'
                      ? 'Tiếp tục → Fingerprint Vow'
                      : 'Continue → Fingerprint Vow',
                  style: type.body.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.colorText,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

