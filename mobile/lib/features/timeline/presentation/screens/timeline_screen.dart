import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart'
    hide TimelineOfflineNoCache;
import 'package:cupid_mobile/features/timeline/domain/timeline_entry.dart';
import 'package:cupid_mobile/features/timeline/presentation/timeline_cubit.dart';
import 'package:cupid_mobile/features/timeline/presentation/timeline_state.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/create_memory_sheet.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_countdown_card.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_dashed_border.dart';
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
    final TimelineCountdown? countdown = TimelineCountdown.forEntries(
      entries,
      now: DateTime.now(),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
      children: <Widget>[
        if (countdown != null) ...<Widget>[
          TimelineCountdownCard(countdown: countdown),
          const SizedBox(height: 18),
        ],
        _TimelineRail(entries: entries),
        _AddMemoryButton(onPressed: onAddMemory),
      ],
    );
  }
}

/// The connector timeline: one continuous gradient rail behind the entry
/// column, with each entry's dot punched over it in the 26px gutter.
class _TimelineRail extends StatelessWidget {
  const _TimelineRail({required this.entries});

  final List<TimelineEntry> entries;

  static const double _gutter = 26;
  static const double _railLeft = 7;
  static const double _railWidth = 2;
  static const double _railInset = 6;
  static const double _dotSize = 16;
  static const double _dotTop = 16;
  static const double _rowGap = 16;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final List<Color> accents = <Color>[
      colors.colorAccentPink,
      colors.colorMint,
      colors.colorPeach,
      colors.colorButter,
      colors.colorAccentPurple,
    ];

    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        Positioned(
          left: _railLeft,
          top: _railInset,
          bottom: _railInset,
          width: _railWidth,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  colors.colorAccentPink,
                  colors.colorAccentPurple,
                  // CSS `transparent` fades in premultiplied space; a zero-
                  // alpha purple reproduces that instead of Flutter's
                  // straight-alpha fade through black.
                  colors.colorAccentPurple.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: _gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int index = 0; index < entries.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: _rowGap),
                  child: Stack(
                    fit: StackFit.passthrough,
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      TimelineEntryCard(
                        entry: entries[index],
                        accent: accents[index % accents.length],
                      ),
                      Positioned(
                        left: -_gutter,
                        top: _dotTop,
                        child: Container(
                          width: _dotSize,
                          height: _dotSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accents[index % accents.length],
                            border: Border.all(
                              color: colors.colorBackground,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
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
      child: TimelineDashedBorder(
        color: colors.colorLine,
        radius: platformTokens.radiusButton,
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
                const SizedBox(width: 8),
                Text(
                  AppL10n.of(context).timeline_add_memory_cta,
                  style: type.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
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
