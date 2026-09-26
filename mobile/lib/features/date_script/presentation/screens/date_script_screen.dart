import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/content_package.dart';
import '../../../../design_system/design_system.dart';
import '../../../activity_cards/domain/activity_card.dart';
import '../../../context_notebook/context_notebook_entry_point.dart';
import '../../domain/date_script_content.dart';
import '../cubit/date_script_cubit.dart';
import '../widgets/date_script_exit_bar.dart';

/// This screen's entry point id for the inline ask mechanism
/// (`architecture/contract-summary.md` §2).
const String dateScriptEntryPointId = 'date_script';

/// The ask targets screen (9) personalises from, most wanted first
/// (`architecture/contract-summary.md` §2). No skill target: a script is about
/// the outing, not about what the reader can do.
final List<String> dateScriptNeededFieldIds = List<String>.unmodifiable(
  <String>[AskTarget.notebookInterest.wireValue, AskTarget.notebookEvent.wireValue],
);

/// `mobile/lib/l10n/` is outside this story's write scope, so this surface uses
/// the same file-local bilingual helper the prepare sheet uses.
String _scriptText(BuildContext context, String vi, String en) =>
    Localizations.localeOf(context).languageCode == 'vi' ? vi : en;

/// Builds the one inline ask card for screen (9). The screen owns the ask's
/// identity and passes it in; a test substitutes the surface without this
/// screen naming a context notebook internal.
typedef DateScriptAskSlotBuilder = Widget Function({
  required String entryPointId,
  required List<String> neededFieldIds,
  required VoidCallback onContextChanged,
});

/// "Kịch bản buổi hẹn", screen (9) of `ux/uiux-spec.md`.
///
/// [card] is required and positional at the entry point on purpose: opening
/// this screen without a source card is a compile error rather than an empty
/// screen waiting for context (BR-1a). The screen itself registers no route and
/// offers no share affordance — `date_script_entry_point.dart` is the only way
/// in (AC-2/SC-6).
class DateScriptScreen extends StatelessWidget {
  const DateScriptScreen({
    super.key,
    required this.card,
    this.contentLoader,
    this.notebook,
    this.askSlotBuilder,
    this.inviteExit,
    this.newCardExit,
    this.journalExit,
  });

  final ActivityCard card;

  /// Test/preview seams. Left null in production so the screen reads the same
  /// shipped asset and the same composition-root notebook every other consumer
  /// reads.
  final ContentPackageLoader? contentLoader;
  final ContextNotebookReader? notebook;

  @visibleForTesting
  final DateScriptAskSlotBuilder? askSlotBuilder;

  /// Seams for the three exits, forwarded to [DateScriptExitBar].
  @visibleForTesting
  final InviteExit? inviteExit;
  @visibleForTesting
  final NewCardExit? newCardExit;
  @visibleForTesting
  final JournalExit? journalExit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DateScriptCubit>(
      create: (_) => DateScriptCubit(
        card: card,
        loader: contentLoader ?? const ContentPackageLoader(),
        notebook: notebook,
      )..load(),
      child: _DateScriptBody(
        card: card,
        askSlotBuilder: askSlotBuilder,
        inviteExit: inviteExit,
        newCardExit: newCardExit,
        journalExit: journalExit,
      ),
    );
  }
}

Widget _defaultAskSlot({
  required String entryPointId,
  required List<String> neededFieldIds,
  required VoidCallback onContextChanged,
}) {
  return AskOnTheSpotSlot(
    entryPointId: entryPointId,
    neededFieldIds: neededFieldIds,
    onContextChanged: onContextChanged,
  );
}

class _DateScriptBody extends StatelessWidget {
  const _DateScriptBody({
    required this.card,
    required this.askSlotBuilder,
    required this.inviteExit,
    required this.newCardExit,
    required this.journalExit,
  });

  final ActivityCard card;
  final DateScriptAskSlotBuilder? askSlotBuilder;
  final InviteExit? inviteExit;
  final NewCardExit? newCardExit;
  final JournalExit? journalExit;

  @override
  Widget build(BuildContext context) {
    final DateScriptCubit cubit = context.read<DateScriptCubit>();

    return Scaffold(
      bottomNavigationBar: DateScriptExitBar(
        card: card,
        inviteExit: inviteExit,
        newCardExit: newCardExit,
        journalExit: journalExit,
        // BR-6: screen (9) is a stop on the way out, so a finished exit closes
        // it and the user lands back in the card's Chuẩn bị area. A cancelled
        // exit never reaches here, so the part being read survives untouched.
        onExitCompleted: () => Navigator.of(context).maybePop(),
      ),
      appBar: CupidHeader(
        title: _scriptText(context, 'Kịch bản buổi hẹn', 'Date script'),
        onBack: Navigator.of(context).canPop()
            ? () => Navigator.of(context).maybePop()
            : null,
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<DateScriptCubit, DateScriptState>(
          builder: (BuildContext context, DateScriptState state) {
            if (state.loading) {
              return const SizedBox(key: Key('date-script-loading'));
            }

            return ListView(
              key: const Key('date-script-body'),
              padding: const EdgeInsets.all(CupidSpacing.md),
              children: <Widget>[
                _PartSegments(selected: state.part, onSelected: cubit.showPart),
                const SizedBox(height: CupidSpacing.lg),
                if (state.part == DateScriptPart.during) const _DuringGuard(),
                Text(
                  state.paragraph,
                  key: const Key('date-script-paragraph'),
                  style: context.cupidType.body.copyWith(
                    color: context.cupidColors.colorText,
                  ),
                ),
                const SizedBox(height: CupidSpacing.lg),
                // Exactly one ask card on this route, below the paragraph.
                // Answering it re-renders in place; the slot renders nothing at
                // all once the cadence policy is satisfied, which is a normal
                // state, not an empty one (AC-25).
                (askSlotBuilder ?? _defaultAskSlot)(
                  entryPointId: dateScriptEntryPointId,
                  neededFieldIds: dateScriptNeededFieldIds,
                  onContextChanged: cubit.reload,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The J7 fence, in Dart rather than in the pack so no content author and no
/// out-of-repo CMS can drop it (BR-3, `ux/uiux-spec.md` §2).
class _DuringGuard extends StatelessWidget {
  const _DuringGuard();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Padding(
      key: const Key('date-script-during-guard'),
      padding: const EdgeInsets.only(bottom: CupidSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(CupidIcons.menuBook, size: 16, color: colors.colorTextMuted),
          const SizedBox(width: CupidSpacing.xs),
          Expanded(
            child: Text(
              _scriptText(
                context,
                'Đọc trước khi đi — không phải nhắc trong lúc hẹn',
                'Read before you go — not a prompt to follow during the date',
              ),
              style: context.cupidType.caption.copyWith(
                color: colors.colorTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Three fixed segments in the order the parts are read, reusing the STORY-001
/// segmented pill style rather than introducing a second chip variant
/// (`ux/uiux-spec.md` §2). Driven off [DateScriptPart.values], so the row is
/// exactly as long as the part vocabulary.
class _PartSegments extends StatelessWidget {
  const _PartSegments({required this.selected, required this.onSelected});

  final DateScriptPart selected;
  final ValueChanged<DateScriptPart> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('date-script-parts'),
      children: <Widget>[
        for (final DateScriptPart part in DateScriptPart.values)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: part == DateScriptPart.values.last ? 0 : CupidSpacing.xs,
              ),
              child: _PartCell(
                part: part,
                isSelected: part == selected,
                onTap: () => onSelected(part),
              ),
            ),
          ),
      ],
    );
  }
}

class _PartCell extends StatelessWidget {
  const _PartCell({
    required this.part,
    required this.isSelected,
    required this.onTap,
  });

  final DateScriptPart part;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        key: Key('date-script-part-${part.wireValue}'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: platform.tapTarget),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isSelected ? colors.colorAccentPink : null,
              borderRadius: BorderRadius.circular(platform.radiusButton),
              border: isSelected
                  ? null
                  : Border.all(color: colors.colorLine),
            ),
            child: Center(
              child: Text(
                _partLabel(context, part),
                style: type.body.copyWith(
                  color: isSelected
                      ? colors.colorOnAccent
                      : colors.colorTextMuted,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget labels for a closed enum, not script prose — script wording stays in
/// the asset package (R-15a).
String _partLabel(BuildContext context, DateScriptPart part) {
  switch (part) {
    case DateScriptPart.before:
      return _scriptText(context, 'Trước', 'Before');
    case DateScriptPart.during:
      return _scriptText(context, 'Trong', 'During');
    case DateScriptPart.after:
      return _scriptText(context, 'Sau', 'After');
  }
}
