import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/love_contract_repository.dart';
import '../love_contract_bloc.dart';
import '../love_contract_event.dart';
import '../love_contract_state.dart';
import '../widgets/add_clause_sheet.dart';
import '../widgets/clause_toggle_row.dart';

String? _noDisplayName() => null;

/// `contract` screen shell (`ux/uiux-spec.md` §1-§4, §6;
/// `architecture/solution.md` §4 Boundaries). This phase (P2) builds the
/// shell, clause list, add-clause entry, and loading/empty/error states.
/// The hold-to-sign control (§5) is P3's addition to this same file.
///
/// [partnerDisplayName] feeds the `Bloc` (ADR-006c A-1: no `GET /users/:id`,
/// so this stays a nullable provider). [myDisplayName] is a screen-local
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
  });

  final LoveContractRepository repository;
  final String? Function() partnerDisplayName;
  final String? Function() myDisplayName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoveContractBloc>(
      create: (_) => LoveContractBloc(
        repository: repository,
        partnerDisplayName: partnerDisplayName,
      )..add(const LoveContractOpened()),
      child: _LoveContractView(myDisplayName: myDisplayName),
    );
  }
}

class _LoveContractView extends StatelessWidget {
  const _LoveContractView({required this.myDisplayName});

  final String? Function() myDisplayName;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;

    return Scaffold(
      backgroundColor: colors.colorBackground,
      appBar: CupidHeader(
        title: l10n.loveContractScreenTitle,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: BlocBuilder<LoveContractBloc, LoveContractState>(
          builder: (context, state) {
            return switch (state) {
              LoveContractLoading() => const _LoveContractSkeleton(),
              LoveContractLoadFailed(:final failure) =>
                _LoveContractErrorBody(failure: failure),
              LoveContractReady() => _LoveContractReadyBody(
                state: state,
                myDisplayName: myDisplayName(),
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
  });

  final LoveContractReady state;
  final String? myDisplayName;

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

    final List<({String id, String text})> clauses = state.allClauses
        .map((clause) => (id: clause.id, text: clause.text))
        .toList(growable: false);

    final bool canAddClause = state.selectedCount < _maxClauseCount && !state.inFlight;

    return SingleChildScrollView(
      key: const Key('love_contract_ready'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.loveContractSequenceLabel,
                  style: type.labelMono.copyWith(
                    color: colors.colorAccentPink,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: CupidSpacing.xs),
                Text(
                  l10n.loveContractScreenTitle,
                  style: type.display.copyWith(color: colors.colorText),
                ),
                SizedBox(height: CupidSpacing.xs),
                Text(
                  subtitle,
                  style: type.caption.copyWith(color: colors.colorTextMuted),
                ),
              ],
            ),
          ),
          SizedBox(height: CupidSpacing.lg),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              l10n.loveContractClauseCounter(state.selectedCount),
              style: type.caption.copyWith(color: colors.colorTextMuted),
            ),
          ),
          if (state.selectedCount == 0)
            Padding(
              padding: EdgeInsets.symmetric(vertical: CupidSpacing.xs),
              child: Text(
                l10n.loveContractEmptyHint,
                style: type.caption.copyWith(color: colors.colorTextMuted),
              ),
            ),
          for (int i = 0; i < clauses.length; i++)
            ClauseToggleRow(
              key: ValueKey(clauses[i].id),
              clauseNumber: i + 1,
              text: clauses[i].text,
              selected: state.selectedClauseIds.contains(clauses[i].id),
              onToggle: () => context.read<LoveContractBloc>().add(
                ClauseToggled(clauses[i].id),
              ),
            ),
          SizedBox(height: CupidSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('love_contract_add_clause_button'),
              onPressed: canAddClause ? () => _addClause(context) : null,
              icon: Icon(
                CupidIcons.add,
                color: canAddClause ? colors.colorAccentPink : colors.colorGhost,
              ),
              label: Text(
                l10n.loveContractAddClauseAction,
                style: type.body.copyWith(
                  color: canAddClause ? colors.colorAccentPink : colors.colorGhost,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
