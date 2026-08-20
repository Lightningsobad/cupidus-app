import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/generated/app_l10n.dart';
import '../../data/dream_jar.dart';
import '../../data/dream_jar_amount_format.dart';
import '../../data/dream_jar_repository.dart';
import '../dream_jar_list_cubit.dart';
import '../widgets/create_dream_jar_sheet.dart';
import '../widgets/dream_jar_unpaired_notice.dart';
import 'dream_jar_detail_screen.dart';

/// STORY-014 P3 jar collection screen (`ux/uiux-spec.md` §1.2, §1.5).
/// [repository] is passed in directly, not resolved via `getIt`: P5 (Home
/// entry point) owns the `getIt` registration and navigation route.
///
/// The signed-in backend id is the exception: `HomeScreen` has none to thread,
/// so this screen resolves it from `getIt` (the `ExpensesEntryPoint`
/// precedent) and passes it to every [DreamJarDetailScreen] it opens —
/// without it the per-partner comparison attributes the whole jar to the
/// partner.
class DreamJarListScreen extends StatelessWidget {
  const DreamJarListScreen({super.key, required this.repository});

  final DreamJarRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DreamJarListCubit>(
      create: (_) => DreamJarListCubit(repository)..load(),
      child: _DreamJarListView(
        repository: repository,
        currentUserId: getIt<BackendUserIdStore>().backendUserId,
      ),
    );
  }
}

class _DreamJarListView extends StatelessWidget {
  const _DreamJarListView({
    required this.repository,
    required this.currentUserId,
  });

  final DreamJarRepository repository;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);

    return BlocBuilder<DreamJarListCubit, DreamJarListState>(
      builder: (context, state) {
        // A genuinely single-jar collection skips the list entirely so the
        // back stack stays one level deep (ux/uiux-spec.md §1.2). One active
        // jar plus completed ones is not that case: bypassing there would
        // hide the summary pill and the completed-jars row
        // (`architecture/solution.md` §4 "Single-jar bypass contract").
        if (state is DreamJarListReady &&
            state.jars.length == 1 &&
            state.completed.isEmpty) {
          return DreamJarDetailScreen(
            jarId: state.jars.single.id,
            repository: repository,
            currentUserId: currentUserId,
          );
        }

        return Scaffold(
          appBar: CupidHeader(
            title: l10n.dream_jar_list_title,
            actions: const <Widget>[],
          ),
          body: SafeArea(
            child: switch (state) {
              DreamJarListLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              DreamJarListUnpaired() => const DreamJarUnpairedNotice(),
              DreamJarListFailed() => _LoadErrorView(failure: state.failure),
              DreamJarListEmpty() => _EmptyJarsView(repository: repository),
              DreamJarListReady(jars: final jars, completed: final completed) =>
                _JarListBody(
                  jars: jars,
                  completed: completed,
                  repository: repository,
                  currentUserId: currentUserId,
                ),
            },
          ),
        );
      },
    );
  }
}

Future<void> _openCreateSheet(
  BuildContext context,
  DreamJarRepository repository,
) async {
  final CupidPlatformTokens platformTokens = context.cupidPlatform;
  final DreamJarListCubit cubit = context.read<DreamJarListCubit>();
  final bool? created = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(platformTokens.radiusSheet),
      ),
    ),
    builder: (_) => CreateDreamJarSheet(repository: repository),
  );
  if (created == true) cubit.refresh();
}

class _LoadErrorView extends StatelessWidget {
  const _LoadErrorView({required this.failure});

  final Object failure;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(CupidSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.dream_jar_load_error,
              textAlign: TextAlign.center,
              style: type.body.copyWith(color: colors.colorText),
            ),
            SizedBox(height: CupidSpacing.md),
            CupidPrimaryButton(
              label: l10n.common_actions_retry,
              onPressed: () => context.read<DreamJarListCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }
}

/// `ux/uiux-spec.md` §1.5. Uses a plain text glyph rather than a new
/// `IconData` constant: no verified jar/savings glyph codepoint exists in
/// `cupid_icons.dart`, which is also outside this phase's write scope
/// (mirrors the P2 `DreamJarUnpairedNotice` precedent).
class _EmptyJarsView extends StatelessWidget {
  const _EmptyJarsView({required this.repository});

  final DreamJarRepository repository;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(CupidSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: colors.colorSurfaceAlt,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('🫙', style: TextStyle(fontSize: 40)),
              ),
            ),
            SizedBox(height: CupidSpacing.lg),
            Text(
              l10n.dream_jar_empty_title,
              textAlign: TextAlign.center,
              style: type.cardTitle.copyWith(color: colors.colorText),
            ),
            SizedBox(height: CupidSpacing.lg),
            CupidPrimaryButton(
              leadingIcon: CupidIcons.add,
              label: l10n.dream_jar_new_jar_cta,
              onPressed: () => _openCreateSheet(context, repository),
            ),
          ],
        ),
      ),
    );
  }
}

class _JarListBody extends StatelessWidget {
  const _JarListBody({
    required this.jars,
    required this.completed,
    required this.repository,
    required this.currentUserId,
  });

  final List<DreamJar> jars;
  final List<DreamJar> completed;
  final DreamJarRepository repository;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<DreamJarListCubit>().refresh(),
      child: ListView(
        padding: EdgeInsets.all(CupidSpacing.lg),
        children: <Widget>[
          _SummaryPill(jars: jars),
          SizedBox(height: CupidSpacing.md),
          for (int index = 0; index < jars.length; index++) ...<Widget>[
            _JarCard(
              jar: jars[index],
              // `ux/uiux-spec.md` §5: "currently viewing" is positional, the
              // first jar in list order. No selection state exists to read.
              isCurrent: index == 0,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DreamJarDetailScreen(
                    jarId: jars[index].id,
                    repository: repository,
                    currentUserId: currentUserId,
                  ),
                ),
              ),
            ),
            SizedBox(height: CupidSpacing.md),
          ],
          // "New Dream Jar" CTA stays pinned at the bottom of the list
          // (ux/uiux-spec.md §1.2).
          CupidPrimaryButton(
            leadingIcon: CupidIcons.add,
            label: AppL10n.of(context).dream_jar_new_jar_cta,
            onPressed: () => _openCreateSheet(context, repository),
          ),
          if (completed.isNotEmpty) ...<Widget>[
            SizedBox(height: CupidSpacing.md),
            _CompletedJarsRow(completed: completed),
          ],
        ],
      ),
    );
  }
}

/// AC1. Totals cover the active jars only: the copy reads "đang để dành"
/// (currently saving toward), and completed jars are summarized by
/// [_CompletedJarsRow] instead (`ux/uiux-spec.md` §2).
class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.jars});

  final List<DreamJar> jars;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    final num totalSaved = jars.fold<num>(
      0,
      (sum, jar) => sum + jar.currentAmount,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: CupidSpacing.md,
        vertical: CupidSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colors.colorAccentPinkDark.withValues(alpha: 0.14),
          colors.colorSurfaceAlt,
        ),
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.colorMint.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                CupidIcons.savings,
                size: 20,
                color: colors.colorMint,
              ),
            ),
          ),
          SizedBox(width: CupidSpacing.sm),
          Expanded(
            child: Text(
              l10n.dream_jar_list_summary_pill(
                DreamJarAmountFormat.vnd(totalSaved),
                jars.length,
              ),
              style: type.caption.copyWith(color: colors.colorText),
            ),
          ),
        ],
      ),
    );
  }
}

/// AC5. Presence, copy, and layout only — no completed-jars destination
/// screen exists and none is introduced here
/// (`architecture/solution.md` §1 non-goals).
class _CompletedJarsRow extends StatelessWidget {
  const _CompletedJarsRow({required this.completed});

  final List<DreamJar> completed;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    return Container(
      padding: EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.colorMint.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                CupidIcons.schedule,
                size: 20,
                color: colors.colorMint,
              ),
            ),
          ),
          SizedBox(width: CupidSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dream_jar_list_completed_row_title,
                  style: type.body.copyWith(color: colors.colorText),
                ),
                SizedBox(height: CupidSpacing.xs),
                Text(
                  l10n.dream_jar_list_completed_row_subtitle(
                    completed.length,
                    completed.map((jar) => jar.name).join(', '),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: type.caption.copyWith(color: colors.colorTextMuted),
                ),
              ],
            ),
          ),
          SizedBox(width: CupidSpacing.sm),
          ExcludeSemantics(
            child: Icon(
              CupidIcons.chevronRight,
              size: 20,
              color: colors.colorTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// `ux/uiux-spec.md` §4: a deterministic 3-slot rotation keyed off the jar id
/// rather than the list index, so a jar keeps its tint when another jar
/// completes and drops out of this list. `DreamJar` carries no category field
/// the tint could be driven from.
Color _jarTint(DreamJar jar, CupidColorTokens colors) => <Color>[
  colors.colorMint,
  colors.colorAccentLilac,
  colors.colorAccentPinkDark,
][jar.id.hashCode.abs() % 3];

/// AC3: an explicit literal pattern, not `DateFormat.yMd(locale)` — the `vi_VN`
/// `yMd` skeleton does not zero-pad, so it would render `1/6/2027` where the
/// design draws `01/06/2027` (`ux/uiux-spec.md` §4).
final DateFormat _jarDeadlineFormat = DateFormat('dd/MM/yyyy');

class _JarCard extends StatelessWidget {
  const _JarCard({
    required this.jar,
    required this.isCurrent,
    required this.onTap,
  });

  final DreamJar jar;

  /// AC4: draws the "Đang xem" chip and the pink border ring on this card.
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);
    final DateTime? deadline = jar.deadline;

    return ClipRRect(
      borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      child: Material(
        color: colors.colorSurface,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(platformTokens.radiusCard),
              border: isCurrent
                  ? Border.all(color: colors.colorAccentPink, width: 2)
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.all(CupidSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AC2 thumbnail: a tinted avatar carrying the shared savings
                  // glyph, not `DreamJarIllustration` — that widget holds two
                  // `AnimationController`s per instance, one per row in a
                  // scrolling list (`architecture/solution.md` §4 Mobile lane
                  // guardrails).
                  ExcludeSemantics(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _jarTint(jar, colors).withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        CupidIcons.savings,
                        size: 26,
                        color: _jarTint(jar, colors),
                      ),
                    ),
                  ),
                  SizedBox(width: CupidSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            ExcludeSemantics(
                              child: Icon(
                                CupidIcons.savings,
                                size: 17,
                                color: colors.colorText,
                              ),
                            ),
                            SizedBox(width: CupidSpacing.sm),
                            Expanded(
                              child: Text(
                                jar.name,
                                style: type.cardTitle.copyWith(
                                  color: colors.colorText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: CupidSpacing.sm),
                        // Decorative fill: the amount/percent text below already
                        // conveys progress (ux/uiux-spec.md §3), mirrors the hero
                        // card's `dream_jar_hero_card.dart` progress-bar pattern
                        // with the axis swapped for a horizontal list card.
                        ExcludeSemantics(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              platformTokens.radiusSmall,
                            ),
                            child: SizedBox(
                              height: 8,
                              width: double.infinity,
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Container(color: colors.colorSurfaceAlt),
                                  FractionallySizedBox(
                                    widthFactor: (jar.progressPercent / 100)
                                        .clamp(0, 1),
                                    child: Container(
                                      color: colors.colorAccentLilac,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: CupidSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${DreamJarAmountFormat.vnd(jar.currentAmount)} '
                                '${l10n.dream_jar_of} '
                                '${DreamJarAmountFormat.vnd(jar.targetAmount)} · '
                                '${jar.progressPercent}%',
                                style: type.caption.copyWith(
                                  color: colors.colorTextMuted,
                                ),
                              ),
                            ),
                            // AC3: a jar with no deadline renders no trailing text at
                            // all rather than a placeholder dash (`ux/uiux-spec.md`
                            // §4).
                            if (deadline != null) ...[
                              SizedBox(width: CupidSpacing.sm),
                              Text(
                                _jarDeadlineFormat.format(deadline),
                                style: type.caption.copyWith(
                                  color: colors.colorTextMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (isCurrent) ...[
                          SizedBox(height: CupidSpacing.sm),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: const _CurrentlyViewingBadge(),
                          ),
                        ],
                      ],
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

/// AC4's chip. Its own row under the percent/deadline line, not the top-right
/// slot the removed status badges used — the design has no top-right badge
/// (`ux/uiux-spec.md` §5).
class _CurrentlyViewingBadge extends StatelessWidget {
  const _CurrentlyViewingBadge();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: CupidSpacing.sm,
        vertical: CupidSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.colorAccentPink.withValues(alpha: 0.16),
        border: Border.all(color: colors.colorAccentPink),
        borderRadius: BorderRadius.circular(platformTokens.radiusButton),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Icon(
              CupidIcons.checkCircle,
              size: 14,
              color: colors.colorAccentPink,
            ),
          ),
          SizedBox(width: CupidSpacing.xs),
          Text(
            AppL10n.of(context).dream_jar_list_currently_viewing_badge,
            style: type.labelMono.copyWith(
              fontSize: 12,
              color: colors.colorAccentPink,
            ),
          ),
        ],
      ),
    );
  }
}
