import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        // A single non-archived jar skips the list entirely so the back
        // stack stays one level deep (ux/uiux-spec.md §1.2).
        if (state is DreamJarListReady && state.jars.length == 1) {
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
              DreamJarListReady(jars: final jars) => _JarListBody(
                jars: jars,
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
    required this.repository,
    required this.currentUserId,
  });

  final List<DreamJar> jars;
  final DreamJarRepository repository;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<DreamJarListCubit>().refresh(),
      child: ListView.separated(
        padding: EdgeInsets.all(CupidSpacing.lg),
        itemCount: jars.length + 1,
        separatorBuilder: (_, _) => SizedBox(height: CupidSpacing.md),
        itemBuilder: (context, index) {
          if (index == jars.length) {
            // "New Dream Jar" CTA stays pinned at the bottom of the list
            // (ux/uiux-spec.md §1.2).
            return CupidPrimaryButton(
              label: AppL10n.of(context).dream_jar_new_jar_cta,
              onPressed: () => _openCreateSheet(context, repository),
            );
          }
          final DreamJar jar = jars[index];
          return _JarCard(
            jar: jar,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => DreamJarDetailScreen(
                  jarId: jar.id,
                  repository: repository,
                  currentUserId: currentUserId,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _JarCard extends StatelessWidget {
  const _JarCard({required this.jar, required this.onTap});

  final DreamJar jar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      child: Material(
        color: colors.colorSurface,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(CupidSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        jar.name,
                        style: type.cardTitle.copyWith(color: colors.colorText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (jar.status == DreamJarStatus.completed)
                      _StatusBadge(
                        label: l10n.dream_jar_card_status_completed,
                        color: colors.colorMint,
                      )
                    else if (jar.status == DreamJarStatus.archived)
                      _StatusBadge(
                        label: l10n.dream_jar_card_status_archived,
                        color: colors.colorTextMuted,
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
                            widthFactor: (jar.progressPercent / 100).clamp(
                              0,
                              1,
                            ),
                            child: Container(color: colors.colorAccentLilac),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: CupidSpacing.sm),
                Text(
                  '${DreamJarAmountFormat.vnd(jar.currentAmount)} '
                  '${l10n.dream_jar_of} '
                  '${DreamJarAmountFormat.vnd(jar.targetAmount)} · '
                  '${jar.progressPercent}%',
                  style: type.caption.copyWith(color: colors.colorTextMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: CupidSpacing.sm,
        vertical: CupidSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
      ),
      child: Text(label, style: type.labelMono.copyWith(color: color)),
    );
  }
}
