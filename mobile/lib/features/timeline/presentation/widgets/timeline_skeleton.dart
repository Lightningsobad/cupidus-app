import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Loading placeholder for the Timeline screen (`ux/uiux-spec.md` section
/// 1.2 "Loading" state row, `coding-plan/phase-P5-timeline-screen.md`):
/// exactly [cardCount] skeleton cards so a slow first sync never reads as
/// the true empty state.
class TimelineSkeleton extends StatelessWidget {
  const TimelineSkeleton({super.key});

  static const int cardCount = 5;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(CupidSpacing.md),
      itemCount: cardCount,
      separatorBuilder: (BuildContext context, int index) =>
          SizedBox(height: CupidSpacing.md),
      itemBuilder: (BuildContext context, int index) =>
          const TimelineSkeletonCard(),
    );
  }
}

/// A single placeholder card matching [TimelineEntryCard]'s outer shape.
class TimelineSkeletonCard extends StatelessWidget {
  const TimelineSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return ExcludeSemantics(
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: colors.colorSurfaceAlt,
          borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        ),
      ),
    );
  }
}
