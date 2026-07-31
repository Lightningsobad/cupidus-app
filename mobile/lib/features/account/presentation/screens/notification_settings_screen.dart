import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/generated/app_l10n.dart';
import '../../data/notification_preferences_store.dart';
import '../notification_settings_cubit.dart';

/// `notifs` screen (`coding-plan/master-plan.md` §6.2 P5, `ux/uiux-spec.md`
/// §5). AC3 device-local only: no toggle here ever triggers a network call
/// (DEC-2). The banner ships the numeric cap copy only — the "Only Synced
/// Alarm may break DND" clause is omitted entirely pending STORY-009
/// (DEC-6).
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key, required this.store});

  final NotificationPreferencesStore store;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationSettingsCubit>(
      create: (_) => NotificationSettingsCubit(store: store),
      child: const _NotificationSettingsView(),
    );
  }
}

class _NotificationSettingsView extends StatelessWidget {
  const _NotificationSettingsView();

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Scaffold(
      backgroundColor: colors.colorBackground,
      appBar: CupidHeader(
        title: l10n.notifs_title,
        onBack: () => Navigator.of(context).maybePop(),
        backLabel: l10n.me_hub_title,
      ),
      body: SafeArea(
        child:
            BlocBuilder<NotificationSettingsCubit, NotificationSettingsState>(
              builder: (context, state) {
                if (state is! NotificationSettingsLoaded) {
                  return Center(
                    child: Text(
                      l10n.notifs_loading,
                      style: type.body.copyWith(color: colors.colorTextMuted),
                    ),
                  );
                }

                final Map<String, bool> preferences = state.preferences;

                return ListView(
                  padding: EdgeInsets.all(CupidSpacing.lg),
                  children: <Widget>[
                    _CapBanner(colors: colors, type: type, l10n: l10n),
                    SizedBox(height: CupidSpacing.md),
                    _NotifGroup(
                      dotColor: colors.colorPeach,
                      label: l10n.notifs_group_critical,
                      rows: _criticalRows(l10n),
                      preferences: preferences,
                      colors: colors,
                      type: type,
                      platformTokens: platformTokens,
                    ),
                    SizedBox(height: CupidSpacing.md),
                    _NotifGroup(
                      dotColor: colors.colorAccentPink,
                      label: l10n.notifs_group_engagement,
                      rows: _engagementRows(l10n),
                      preferences: preferences,
                      colors: colors,
                      type: type,
                      platformTokens: platformTokens,
                    ),
                    SizedBox(height: CupidSpacing.md),
                    _NotifGroup(
                      dotColor: colors.colorGhost,
                      label: l10n.notifs_group_info,
                      rows: _infoRows(l10n),
                      preferences: preferences,
                      colors: colors,
                      type: type,
                      platformTokens: platformTokens,
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }
}

/// Row order and default states from
/// `cupid-mobile-design/Cupid Screens.dc.html:1597-1605` (`notifCritical`,
/// `notifEngage`) and `:951-952` (INFO group, hardcoded in markup).
List<_NotifRow> _criticalRows(AppL10n l10n) => <_NotifRow>[
  _NotifRow(
    prefKey: 'syncedAlarm',
    icon: Icons.alarm,
    title: l10n.notifs_row_synced_alarm_title,
    sub: l10n.notifs_row_synced_alarm_sub,
  ),
  _NotifRow(
    prefKey: 'emojiStorm',
    icon: Icons.cyclone,
    title: l10n.notifs_row_emoji_storm_title,
    sub: l10n.notifs_row_emoji_storm_sub,
  ),
];

List<_NotifRow> _engagementRows(AppL10n l10n) => <_NotifRow>[
  _NotifRow(
    prefKey: 'vibeCheck',
    icon: Icons.mood,
    title: l10n.notifs_row_vibe_check_title,
    sub: l10n.notifs_row_vibe_check_sub,
  ),
  _NotifRow(
    prefKey: 'petNeedsYou',
    icon: Icons.pets,
    title: l10n.notifs_row_pet_needs_you_title,
    sub: l10n.notifs_row_pet_needs_you_sub,
  ),
  _NotifRow(
    prefKey: 'baeTyping',
    icon: Icons.blur_on,
    title: l10n.notifs_row_bae_typing_title,
    sub: l10n.notifs_row_bae_typing_sub,
  ),
];

List<_NotifRow> _infoRows(AppL10n l10n) => <_NotifRow>[
  _NotifRow(
    prefKey: 'dreamJarMilestone',
    icon: Icons.savings,
    title: l10n.notifs_row_dream_jar_milestone_title,
    sub: l10n.notifs_row_dream_jar_milestone_sub,
  ),
  _NotifRow(
    prefKey: 'loveTimelineOnThisDay',
    icon: Icons.timeline,
    title: l10n.notifs_row_love_timeline_title,
    sub: l10n.notifs_row_love_timeline_sub,
  ),
];

class _NotifRow {
  const _NotifRow({
    required this.prefKey,
    required this.icon,
    required this.title,
    required this.sub,
  });

  final String prefKey;
  final IconData icon;
  final String title;
  final String sub;
}

class _CapBanner extends StatelessWidget {
  const _CapBanner({required this.colors, required this.type, required this.l10n});

  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: CupidSpacing.md,
        vertical: CupidSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colors.colorAmber.withValues(alpha: 0.2),
            colors.colorAccentPink.withValues(alpha: 0.14),
          ],
        ),
        borderRadius: BorderRadius.circular(context.cupidPlatform.radiusCard),
        border: Border.all(color: colors.colorLine),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.bolt, color: colors.colorAmber),
          SizedBox(width: CupidSpacing.sm),
          Expanded(
            child: Text(
              l10n.notifs_cap_banner,
              style: type.caption.copyWith(color: colors.colorTextMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifGroup extends StatelessWidget {
  const _NotifGroup({
    required this.dotColor,
    required this.label,
    required this.rows,
    required this.preferences,
    required this.colors,
    required this.type,
    required this.platformTokens,
  });

  final Color dotColor;
  final String label;
  final List<_NotifRow> rows;
  final Map<String, bool> preferences;
  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: CupidSpacing.sm),
            child: Row(
              children: <Widget>[
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: CupidSpacing.xs),
                Text(
                  label,
                  style: type.labelMono.copyWith(
                    color: dotColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          for (final _NotifRow row in rows)
            Container(
              padding: EdgeInsets.symmetric(vertical: CupidSpacing.sm),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.colorLine)),
              ),
              child: Row(
                children: <Widget>[
                  Icon(row.icon, size: 20, color: colors.colorTextMuted),
                  SizedBox(width: CupidSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          row.title,
                          style: type.body.copyWith(
                            color: colors.colorText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          row.sub,
                          style: type.caption.copyWith(
                            color: colors.colorTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _TogglePill(
                    key: Key('notif-toggle-${row.prefKey}'),
                    value: preferences[row.prefKey] ?? false,
                    colors: colors,
                    onChanged: (bool value) => context
                        .read<NotificationSettingsCubit>()
                        .setEnabled(row.prefKey, value),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A manually drawn pill toggle matching the design source's fixed-style
/// switch (`cupid-mobile-design/Cupid Screens.dc.html:938`) rather than the
/// Material [Switch] (`ux/uiux-spec.md` §5: "keep this structure and visuals
/// verbatim").
class _TogglePill extends StatelessWidget {
  const _TogglePill({
    super.key,
    required this.value,
    required this.onChanged,
    required this.colors,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final CupidColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 50,
        height: 30,
        padding: const EdgeInsets.all(3),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: value ? colors.gradientHot : null,
          color: value ? null : colors.colorSurfaceAlt,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.colorText,
            shape: BoxShape.circle,
          ),
          child: const SizedBox(width: 24, height: 24),
        ),
      ),
    );
  }
}
