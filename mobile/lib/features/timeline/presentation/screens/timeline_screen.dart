import 'dart:ui' as ui;

import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart'
    hide TimelineOfflineNoCache;
import 'package:cupid_mobile/features/timeline/domain/timeline_entry.dart';
import 'package:cupid_mobile/features/timeline/presentation/timeline_cubit.dart';
import 'package:cupid_mobile/features/timeline/presentation/timeline_state.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/create_memory_sheet.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_entry_card.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_skeleton.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Love Timeline screen (`ux/uiux-spec.md` section 1.2,
/// `coding-plan/phase-P5-timeline-screen.md`): a vertical connector timeline
/// of [TimelineEntryCard]s driven by [TimelineCubit]/[TimelineState], with
/// dedicated surfaces for loading, ready (online and offline-with-cache),
/// empty, offline-with-no-cache, and error.
///
/// [createCubit] is a factory rather than an injected instance so this
/// screen owns the cubit's lifecycle via [BlocProvider] (matching
/// `SplashScreen`'s `createSessionGateCubit` pattern) and stays trivially
/// testable with a stub subclass.
class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key, required this.createCubit, this.repository});

  final TimelineCubit Function() createCubit;

  /// Defaults to the composition-root singleton
  /// (`core/di/service_locator.dart`), matching `HomeScreen`'s
  /// optional-factory-with-default pattern, so `HomeScreen`'s existing
  /// `TimelineScreen(createCubit: ...)` call site needs no change.
  final TimelineRepository? repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TimelineCubit>(
      create: (_) => createCubit()..load(),
      child: Scaffold(
        appBar: CupidHeader(
          title: AppL10n.of(context).timeline_screen_title,
          onBack: () => Navigator.of(context).maybePop(),
        ),
        body: SafeArea(
          child: BlocBuilder<TimelineCubit, TimelineState>(
            builder: (BuildContext context, TimelineState state) {
              // Resolved lazily (only when tapped) rather than in `build`, so
              // screens that never open the sheet -- and tests that never
              // call `setupServiceLocator()` -- don't pay for or fail on a
              // `getIt<TimelineRepository>()` lookup they never need.
              void onAddMemory() => CreateMemorySheet.show(
                context,
                repository: repository ?? getIt<TimelineRepository>(),
                isOffline: () => context.read<TimelineCubit>().isOffline,
              );

              return switch (state) {
                TimelineLoading() => const TimelineSkeleton(),
                TimelineReady(:final entries, :final isOffline) => Column(
                  children: <Widget>[
                    if (isOffline) const _OfflineBanner(),
                    Expanded(
                      child: _ReadyView(
                        entries: entries,
                        onAddMemory: onAddMemory,
                      ),
                    ),
                  ],
                ),
                TimelineEmpty() => _EmptyView(onAddMemory: onAddMemory),
                TimelineOfflineNoCache() => _OfflineNoCacheView(
                  onRetry: () => context.read<TimelineCubit>().retry(),
                ),
                TimelineError() => _ErrorView(
                  onRetry: () => context.read<TimelineCubit>().retry(),
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        color: colors.colorSurfaceAlt,
        padding: EdgeInsets.symmetric(
          horizontal: CupidSpacing.md,
          vertical: CupidSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            ExcludeSemantics(
              child: CupidIcon(
                TimelineGlyphs.symbolFor('wifi_off')!,
                size: 16,
                color: colors.colorTextMuted,
              ),
            ),
            SizedBox(width: CupidSpacing.xs),
            Expanded(
              child: Text(
                AppL10n.of(context).timeline_offline_banner,
                style: type.caption.copyWith(color: colors.colorTextMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadyView extends StatelessWidget {
  const _ReadyView({required this.entries, required this.onAddMemory});

  final List<TimelineEntry> entries;
  final VoidCallback onAddMemory;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(CupidSpacing.md),
      itemCount: entries.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == entries.length) {
          return Padding(
            padding: EdgeInsets.only(top: CupidSpacing.sm),
            child: _AddMemoryButton(onPressed: onAddMemory),
          );
        }
        final TimelineEntry entry = entries[index];
        final bool isLast = index == entries.length - 1;
        return _TimelineRow(entry: entry, showConnector: !isLast);
      },
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.showConnector});

  final TimelineEntry entry;
  final bool showConnector;

  static const double _dotSize = 16;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Padding(
      padding: EdgeInsets.only(bottom: CupidSpacing.md),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              width: CupidSpacing.lg,
              child: Column(
                children: <Widget>[
                  Container(
                    width: _dotSize,
                    height: _dotSize,
                    margin: EdgeInsets.only(top: CupidSpacing.sm),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.colorSurface,
                      border: Border.all(
                        color: colors.colorAccentPink,
                        width: 3,
                      ),
                    ),
                  ),
                  if (showConnector)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: EdgeInsets.symmetric(vertical: CupidSpacing.xs),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              colors.colorAccentPink,
                              colors.colorAccentPurple,
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: CupidSpacing.sm),
            Expanded(child: TimelineEntryCard(entry: entry)),
          ],
        ),
      ),
    );
  }
}

class _AddMemoryButton extends StatelessWidget {
  const _AddMemoryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(platformTokens.radiusButton),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: colors.colorAccentPink,
          radius: platformTokens.radiusButton,
        ),
        child: SizedBox(
          height: 52,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CupidIcon(
                  TimelineGlyphs.symbolFor('add_circle')!,
                  size: 20,
                  color: colors.colorAccentPink,
                ),
                SizedBox(width: CupidSpacing.xs),
                Text(
                  AppL10n.of(context).timeline_add_memory_cta,
                  style: type.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.colorAccentPink,
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

/// Dashed rounded-rect border (`ux/uiux-spec.md` section 1.2, "Add a memory"
/// pill: "1.5px dash border"). Hand-rolled path dashing rather than a new
/// dependency -- `dash_path`-style dashing is a well-known ~15-line
/// `CustomPainter` technique.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const List<double> _dashPattern = <double>[6, 4];

  @override
  void paint(Canvas canvas, Size size) {
    final double cappedRadius = radius > size.height / 2
        ? size.height / 2
        : radius;
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(cappedRadius),
    );
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final Path source = Path()..addRRect(rrect);
    canvas.drawPath(_dashPath(source), paint);
  }

  static Path _dashPath(Path source) {
    final Path dest = Path();
    for (final ui.PathMetric metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      int dashIndex = 0;
      while (distance < metric.length) {
        final double length = _dashPattern[dashIndex % _dashPattern.length];
        final double next = (distance + length).clamp(0, metric.length);
        if (draw) {
          dest.addPath(metric.extractPath(distance, next), Offset.zero);
        }
        distance = next;
        draw = !draw;
        dashIndex++;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onAddMemory});

  final VoidCallback onAddMemory;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    return ListView(
      padding: EdgeInsets.all(CupidSpacing.md),
      children: <Widget>[
        SizedBox(height: CupidSpacing.xxl),
        Text(
          l10n.timeline_empty_heading,
          textAlign: TextAlign.center,
          style: type.cardTitle.copyWith(color: colors.colorText),
        ),
        SizedBox(height: CupidSpacing.sm),
        Text(
          l10n.timeline_empty_body,
          textAlign: TextAlign.center,
          style: type.body.copyWith(color: colors.colorTextMuted),
        ),
        SizedBox(height: CupidSpacing.lg),
        _AddMemoryButton(onPressed: onAddMemory),
      ],
    );
  }
}

class _OfflineNoCacheView extends StatelessWidget {
  const _OfflineNoCacheView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(CupidSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ExcludeSemantics(
              child: CupidIcon(
                TimelineGlyphs.symbolFor('cloud_off')!,
                size: 40,
                color: colors.colorTextMuted,
              ),
            ),
            SizedBox(height: CupidSpacing.md),
            Text(
              l10n.timeline_offline_no_cache_heading,
              textAlign: TextAlign.center,
              style: type.cardTitle.copyWith(color: colors.colorText),
            ),
            SizedBox(height: CupidSpacing.sm),
            Text(
              l10n.timeline_offline_no_cache_body,
              textAlign: TextAlign.center,
              style: type.body.copyWith(color: colors.colorTextMuted),
            ),
            SizedBox(height: CupidSpacing.lg),
            CupidPrimaryButton(
              label: l10n.timeline_error_retry_label,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(CupidSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ExcludeSemantics(
              child: CupidIcon(
                TimelineGlyphs.symbolFor('error')!,
                size: 40,
                color: colors.colorRed,
              ),
            ),
            SizedBox(height: CupidSpacing.md),
            Text(
              l10n.timeline_error_heading,
              textAlign: TextAlign.center,
              style: type.cardTitle.copyWith(color: colors.colorText),
            ),
            SizedBox(height: CupidSpacing.sm),
            Text(
              l10n.timeline_error_body,
              textAlign: TextAlign.center,
              style: type.body.copyWith(color: colors.colorTextMuted),
            ),
            SizedBox(height: CupidSpacing.lg),
            CupidPrimaryButton(
              label: l10n.timeline_error_retry_label,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
