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
import 'dream_jar_create_screen.dart';
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

Future<void> _openCreateScreen(
  BuildContext context,
  DreamJarRepository repository,
) async {
  final DreamJarListCubit cubit = context.read<DreamJarListCubit>();
  final bool? created = await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      builder: (_) => DreamJarCreateScreen(repository: repository),
    ),
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
              onPressed: () => _openCreateScreen(context, repository),
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
            onPressed: () => _openCreateScreen(context, repository),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(121, 226, 205, 0.18),
            Color.fromRGBO(183, 140, 245, 0.14),
          ],
        ),
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        border: Border.all(color: colors.colorLine),
      ),
      child: Row(
        children: [
          Icon(
            CupidIcons.savings,
            size: 21,
            color: colors.colorMint,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              l10n.dream_jar_list_summary_pill(
                DreamJarAmountFormat.vnd(totalSaved),
                jars.length,
              ),
              style: type.caption.copyWith(
                fontSize: 12.5,
                height: 1.5,
                color: colors.colorTextMuted,
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Row(
        children: [
          Icon(
            Icons.history_rounded,
            size: 20,
            color: colors.colorTextMuted,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dream_jar_list_completed_row_title,
                  style: type.body.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: colors.colorText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.dream_jar_list_completed_row_subtitle(
                    completed.length,
                    completed.map((jar) => jar.name).join(', '),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: type.caption.copyWith(
                    fontSize: 11.5,
                    color: colors.colorTextMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 19,
            color: colors.colorTextMuted,
          ),
        ],
      ),
    );
  }
}

/// A deterministic 3-slot rotation keyed off the jar id.
Color _jarTint(DreamJar jar, CupidColorTokens colors) => <Color>[
  colors.colorMint,
  colors.colorAccentLilac,
  colors.colorAccentPink,
][jar.id.hashCode.abs() % 3];

final DateFormat _jarDeadlineFormat = DateFormat('dd/MM/yyyy');

class _MiniJarThumbnail extends StatelessWidget {
  const _MiniJarThumbnail({
    required this.progressPercent,
    required this.tintColor,
  });

  final int progressPercent;
  final Color tintColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 66,
      child: CustomPaint(
        painter: _MiniJarPainter(
          progress: (progressPercent / 100.0).clamp(0.0, 1.0),
          tintColor: tintColor,
        ),
      ),
    );
  }
}

class _MiniJarPainter extends CustomPainter {
  _MiniJarPainter({required this.progress, required this.tintColor});

  final double progress;
  final Color tintColor;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Wood lid: x=14, y=4, w=24, h=8, rx=4
    final Paint lidPaint = Paint()..color = const Color(0xFFFFD79E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(14, 4, 24, 8),
        const Radius.circular(4),
      ),
      lidPaint,
    );

    // 2. Jar body glass
    final Rect bodyRect = const Rect.fromLTWH(6, 14, 40, 48);
    final RRect bodyRRect = RRect.fromRectAndRadius(
      bodyRect,
      const Radius.circular(13),
    );

    final Paint glassPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(bodyRRect, glassPaint);

    // 3. Liquid fill
    if (progress > 0) {
      canvas.save();
      canvas.clipRRect(bodyRRect);
      final double liquidTop = bodyRect.bottom - (bodyRect.height * progress);
      final Rect liquidRect = Rect.fromLTRB(
        bodyRect.left,
        liquidTop,
        bodyRect.right,
        bodyRect.bottom + 4,
      );
      final Paint liquidPaint = Paint()..color = tintColor;
      canvas.drawRect(liquidRect, liquidPaint);
      canvas.restore();
    }

    // 4. Glass border stroke
    final Paint strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(bodyRRect, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _MiniJarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.tintColor != tintColor;
  }
}

class _JarCard extends StatelessWidget {
  const _JarCard({
    required this.jar,
    required this.isCurrent,
    required this.onTap,
  });

  final DreamJar jar;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);
    final DateTime? deadline = jar.deadline;
    final Color tint = _jarTint(jar, colors);

    return Container(
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        border: Border.all(
          color: isCurrent ? colors.colorAccentPink : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(platformTokens.radiusCard),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _MiniJarThumbnail(
                      progressPercent: jar.progressPercent,
                      tintColor: tint,
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.flight_takeoff_rounded,
                                size: 16,
                                color: tint,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  jar.name,
                                  style: type.cardTitle.copyWith(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    color: colors.colorText,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${DreamJarAmountFormat.vnd(jar.currentAmount)} / ${DreamJarAmountFormat.vnd(jar.targetAmount)}',
                            style: type.caption.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.colorTextMuted,
                            ),
                          ),
                          const SizedBox(height: 9),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: SizedBox(
                              height: 8,
                              child: Stack(
                                children: [
                                  Container(color: colors.colorSurfaceAlt),
                                  FractionallySizedBox(
                                    widthFactor: (jar.progressPercent / 100)
                                        .clamp(0, 1),
                                    child: Container(color: tint),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${jar.progressPercent}%',
                                style: type.caption.copyWith(
                                  fontSize: 11,
                                  color: colors.colorTextMuted,
                                ),
                              ),
                              if (deadline != null)
                                Text(
                                  _jarDeadlineFormat.format(deadline),
                                  style: type.caption.copyWith(
                                    fontSize: 11,
                                    color: colors.colorTextMuted,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isCurrent) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: colors.colorAccentPink,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.dream_jar_list_currently_viewing_badge,
                        style: type.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: colors.colorAccentPink,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
