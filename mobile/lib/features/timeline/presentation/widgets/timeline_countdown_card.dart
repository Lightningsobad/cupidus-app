import 'dart:math' as math;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

/// Relationship countdown anchored on the couple's own
/// `CupidProfile.relationshipStartDate` from `GET /users/me`. The next
/// [_milestoneStep] multiple is the upcoming milestone.
@immutable
class TimelineCountdown {
  const TimelineCountdown({
    required this.daysTogether,
    required this.milestoneDays,
    required this.milestoneDate,
  });

  /// Milestones the design copy counts toward ("mốc 300 ngày").
  static const int _milestoneStep = 100;

  final int daysTogether;
  final int milestoneDays;
  final DateTime milestoneDate;

  int get daysRemaining => milestoneDays - daysTogether;

  int get percentComplete => (daysTogether / milestoneDays * 100).round();

  /// [relationshipStartDate] is a calendar date, not an instant: the backend
  /// column is `type: 'date'`
  /// (`backend/src/modules/users/entities/user.entity.ts:23`), so its
  /// year/month/day are read as given rather than shifted through a zone.
  static TimelineCountdown since(
    DateTime relationshipStartDate, {
    required DateTime now,
  }) {
    // Day arithmetic in UTC so a DST boundary cannot shift the count by one.
    final DateTime startDay = DateTime.utc(
      relationshipStartDate.year,
      relationshipStartDate.month,
      relationshipStartDate.day,
    );
    final DateTime localNow = now.toLocal();
    final DateTime today = DateTime.utc(
      localNow.year,
      localNow.month,
      localNow.day,
    );
    final int daysTogether = math.max(1, today.difference(startDay).inDays + 1);
    final int milestoneDays =
        (daysTogether ~/ _milestoneStep + 1) * _milestoneStep;

    return TimelineCountdown(
      daysTogether: daysTogether,
      milestoneDays: milestoneDays,
      milestoneDate: DateTime(
        relationshipStartDate.year,
        relationshipStartDate.month,
        relationshipStartDate.day,
      ).add(Duration(days: milestoneDays - 1)),
    );
  }
}

/// Countdown hero at the top of the Love Timeline: gradient card with the
/// remaining-days headline, the milestone subtitle, and the progress ring.
class TimelineCountdownCard extends StatelessWidget {
  const TimelineCountdownCard({super.key, required this.countdown});

  final TimelineCountdown countdown;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    final String milestoneDate =
        Localizations.localeOf(context).languageCode == 'vi'
        ? _viDateFormat.format(countdown.milestoneDate)
        : _enDateFormat.format(countdown.milestoneDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        border: Border.all(color: colors.colorLine),
        gradient: LinearGradient(
          begin: _gradient140Begin,
          end: _gradient140End,
          colors: <Color>[
            colors.colorAccentPink.withValues(alpha: 0.2),
            colors.colorAccentPurple.withValues(alpha: 0.18),
          ],
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.timelineCountdownHeadline(countdown.daysRemaining),
                  style: type.display.copyWith(
                    fontSize: 20,
                    color: colors.colorText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.timelineCountdownSubtitle(
                    countdown.milestoneDays,
                    milestoneDate,
                  ),
                  style: type.caption.copyWith(
                    fontSize: 12.5,
                    color: colors.colorTextMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          TimelineProgressRing(percentComplete: countdown.percentComplete),
        ],
      ),
    );
  }
}

/// 56px conic progress ring with the percentage punched out of the middle.
class TimelineProgressRing extends StatelessWidget {
  const TimelineProgressRing({super.key, required this.percentComplete});

  static const double diameter = 56;
  static const double innerDiameter = 44;

  final int percentComplete;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final double fraction = (percentComplete / 100).clamp(0.0, 1.0);

    return Semantics(
      value: '$percentComplete%',
      child: ExcludeSemantics(
        child: Container(
          width: diameter,
          height: diameter,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              // CSS conic-gradient starts at 12 o'clock; SweepGradient at 3.
              transform: const GradientRotation(-math.pi / 2),
              colors: <Color>[
                colors.colorAccentPink,
                colors.colorAccentPink,
                colors.colorSurfaceAlt,
                colors.colorSurfaceAlt,
              ],
              stops: <double>[0, fraction, fraction, 1],
            ),
          ),
          child: Container(
            width: innerDiameter,
            height: innerDiameter,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.colorBackground,
            ),
            child: Text(
              '$percentComplete%',
              style: type.display.copyWith(
                fontSize: 13,
                color: colors.colorText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// CSS `linear-gradient(140deg, ...)` expressed as Flutter alignments, using
/// the same `(-sin, cos) -> (sin, -cos)` mapping as the 120deg token.
const Alignment _gradient140Begin = Alignment(
  -0.6427876096865393,
  -0.766044443118978,
);
const Alignment _gradient140End = Alignment(
  0.6427876096865393,
  0.766044443118978,
);

final intl.DateFormat _viDateFormat = intl.DateFormat('dd/MM/yyyy');
final intl.DateFormat _enDateFormat = intl.DateFormat('d MMM yyyy');
