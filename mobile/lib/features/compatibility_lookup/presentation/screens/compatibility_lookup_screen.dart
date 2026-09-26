import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../compatibility_lookup_entry_point.dart';
import '../../data/relationship_label_repository.dart';
import '../cubit/compatibility_lookup_cubit.dart';
import '../widgets/compat_activity_block.dart';
import '../widgets/compat_band_chip.dart';
import '../widgets/compat_facet_block.dart';
import '../widgets/compat_question_block.dart';
import '../widgets/label_capture_card.dart';

/// Screen (10), "Bảng tra ăn khớp".
///
/// Reached only through `openCompatibilityLookup`; it has no route name and
/// nothing in `cupid_app.dart` knows it exists (AC-2/AC-3).
class CompatibilityLookupScreen extends StatelessWidget {
  const CompatibilityLookupScreen({
    super.key,
    required this.from,
    this.createCubit,
  });

  /// Which surface sent the reader here. Carried so that an audit of the
  /// position lock can be done from the call sites alone, and so that adding a
  /// third entry surface is a visible change to a closed enum rather than one
  /// more untracked `push`.
  final CompatibilityEntry from;

  /// Test seam. In the app this stays null and the cubit comes from the service
  /// locator with the real label repository, the real activity store and the
  /// real asset bundle behind it.
  final CompatibilityLookupCubit Function()? createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CompatibilityLookupCubit>(
      create: (_) =>
          (createCubit?.call() ?? getIt<CompatibilityLookupCubit>())..load(),
      child: const _CompatibilityLookupBody(),
    );
  }
}

class _CompatibilityLookupBody extends StatelessWidget {
  const _CompatibilityLookupBody();

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CupidHeader(
        title: l10n.compat_screen_title,
        onBack: Navigator.of(context).canPop()
            ? () => Navigator.of(context).maybePop()
            : null,
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<CompatibilityLookupCubit, CompatibilityLookupState>(
          builder: (BuildContext context, CompatibilityLookupState state) {
            // No spinner while the packs load. The wait is an asset read, and
            // a "đang tra cứu" state would stage it as deliberation about the
            // reader's relationship (AC-28).
            if (state.loading) {
              return const SizedBox.shrink();
            }
            return _LookupList(state: state);
          },
        ),
      ),
    );
  }
}

class _LookupList extends StatelessWidget {
  const _LookupList({required this.state});

  final CompatibilityLookupState state;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    return ListView(
      key: const Key('compat_lookup_list'),
      padding: const EdgeInsets.all(CupidSpacing.md),
      children: <Widget>[
        // Results first: a reader who already declared both sides should not
        // have to walk back through the questions to reach the table
        // (`ux/uiux-spec.md` section 2.1).
        for (final CompatResult result in state.results) ...<Widget>[
          _ResultSection(result: result),
          const SizedBox(height: CupidSpacing.lg),
        ],
        if (state.results.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: CupidSpacing.md),
            child: Text(
              key: const Key('compat_empty_state'),
              l10n.compat_empty_state,
              style: type.body.copyWith(color: colors.colorTextMuted),
            ),
          ),
        for (final CompatAxisInput axis in state.axes)
          for (final LabelSubject subject in LabelSubject.values)
            Padding(
              padding: const EdgeInsets.only(bottom: CupidSpacing.md),
              child: LabelCaptureCard(
                system: axis.system,
                subject: subject,
                values: axis.values,
                selected: axis.labelFor(subject),
                onSelect: (String valueId, LabelCertainty certainty) =>
                    context.read<CompatibilityLookupCubit>().selectLabel(
                      system: axis.system,
                      subject: subject,
                      valueId: valueId,
                      certainty: certainty,
                    ),
                onClear: () => context
                    .read<CompatibilityLookupCubit>()
                    .clearLabel(system: axis.system, subject: subject),
              ),
            ),
        // The design canvas closes screen (10) by saying out loud that the
        // table is a shipped, fixed one that learns nothing from the reader —
        // the same promise AC-28/AC-31 make in code.
        Padding(
          padding: const EdgeInsets.only(bottom: CupidSpacing.md),
          child: Text(
            key: const Key('compat_static_table_note'),
            l10n.compat_static_table_note,
            style: type.caption.copyWith(color: colors.colorTextMuted),
          ),
        ),
        const _SkipBackAction(),
      ],
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({required this.result});

  final CompatResult result;

  /// The push is announced by a 5-second undo snackbar and nothing else: the
  /// screen stays open and the list keeps its scroll offset, because being
  /// thrown back to the previous screen is how a reader loses the rest of the
  /// table they were reading (`ux/uiux-spec.md` section 4).
  Future<void> _addToStore(BuildContext context) async {
    final CompatibilityLookupCubit cubit =
        context.read<CompatibilityLookupCubit>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppL10n l10n = AppL10n.of(context);

    final String cardId = await cubit.addActivityToStore(result);

    messenger.showSnackBar(
      SnackBar(
        key: const Key('compat_card_created_snackbar'),
        duration: const Duration(seconds: 5),
        content: Text(l10n.compat_card_created_snackbar),
        action: SnackBarAction(
          label: l10n.compat_card_created_undo,
          onPressed: () => cubit.undoAddToStore(cardId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    return Column(
      key: Key('compat_result_${result.system.wireValue}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // The provenance line, in STORY-009's style: the table answers for the
        // two labels the reader typed, and says so before it says anything
        // else.
        Text(
          l10n.compat_result_basis(
            result.selfValueLabel,
            result.partnerValueLabel,
          ),
          style: type.caption.copyWith(color: colors.colorTextMuted),
        ),
        const SizedBox(height: CupidSpacing.sm),
        // Fixed order, no exceptions: band, fit, friction, activity, question
        // last (`ux/uiux-spec.md` section 3, AC-19).
        CompatBandChip(band: result.band),
        const SizedBox(height: CupidSpacing.md),
        CompatFacetBlock(kind: CompatFacetKind.fit, text: result.cell.fit),
        const SizedBox(height: CupidSpacing.md),
        CompatFacetBlock(
          kind: CompatFacetKind.friction,
          text: result.cell.friction,
        ),
        const SizedBox(height: CupidSpacing.md),
        CompatActivityBlock(
          cell: result.cell,
          onAddToMyStore: () => _addToStore(context),
        ),
        const SizedBox(height: CupidSpacing.md),
        CompatQuestionBlock(cell: result.cell),
      ],
    );
  }
}

/// AC-10: leaving without answering is a plain, neutral exit — no reproach, no
/// second ask later in the same session.
class _SkipBackAction extends StatelessWidget {
  const _SkipBackAction();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        button: true,
        child: GestureDetector(
          key: const Key('compat_skip_back'),
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).maybePop(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: CupidSpacing.sm),
            child: Text(
              l10n.compat_skip_back_action,
              style: type.body.copyWith(color: colors.colorTextMuted),
            ),
          ),
        ),
      ),
    );
  }
}
