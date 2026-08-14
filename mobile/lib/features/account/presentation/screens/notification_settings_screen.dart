import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/generated/app_l10n.dart';
import '../../data/notification_preferences_store.dart';
import '../notification_settings_cubit.dart';

/// `Cupid Screens.dc.html:1381` — the screen column's `gap:13px`, which is off
/// the 8pt [CupidSpacing] scale, so it cannot come from a token.
const double _sectionGap = 13;

/// `notifs` screen (`coding-plan/master-plan.md` §6.2 P5, `ux/uiux-spec.md`
/// §5). AC3 device-local only: no toggle here ever triggers a network call
/// (DEC-2). The banner ships the numeric cap copy only: the design source's
/// "Chỉ Synced Alarm được phép phá Do Not Disturb" clause claims a DND
/// override v1 does not implement, so STORY-031 AC3 drops it permanently
/// rather than deferring it — do not restore it from the design source.
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
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  children: <Widget>[
                    _CapBanner(colors: colors, type: type, l10n: l10n),
                    const SizedBox(height: _sectionGap),
                    _NotifGroup(
                      dotColor: colors.colorPeach,
                      label: l10n.notifs_group_critical,
                      rows: _criticalRows(l10n),
                      preferences: preferences,
                      colors: colors,
                      type: type,
                      platformTokens: platformTokens,
                    ),
                    const SizedBox(height: _sectionGap),
                    _NotifGroup(
                      dotColor: colors.colorAccentPink,
                      label: l10n.notifs_group_engagement,
                      rows: _engagementRows(l10n),
                      preferences: preferences,
                      colors: colors,
                      type: type,
                      platformTokens: platformTokens,
                    ),
                    const SizedBox(height: _sectionGap),
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        // `linear-gradient(150deg, ...)`: CSS 0deg points up and grows
        // clockwise, so 150deg is the axis (sin150, -cos150) = (.5, .87).
        gradient: LinearGradient(
          begin: const Alignment(-0.5, -0.87),
          end: const Alignment(0.5, 0.87),
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
          Icon(Icons.bolt, size: 22, color: colors.colorAmber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.notifs_cap_banner,
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
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 4),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 9),
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
                const SizedBox(width: 9),
                Text(
                  label,
                  style: type.labelMono.copyWith(
                    color: dotColor,
                    fontSize: 9.5,
                    // `letter-spacing:.14em` against the 9.5px size.
                    letterSpacing: 9.5 * 0.14,
                  ),
                ),
              ],
            ),
          ),
          for (final _NotifRow row in rows)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.colorLine)),
              ),
              child: Row(
                children: <Widget>[
                  Icon(row.icon, size: 20, color: colors.colorTextMuted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          row.title,
                          style: type.body.copyWith(
                            fontSize: 14,
                            color: colors.colorText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          row.sub,
                          style: type.caption.copyWith(
                            fontSize: 11,
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
          color: value ? null : colors.colorLine,
        ),
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            shape: BoxShape.circle,
          ),
          child: SizedBox(width: 24, height: 24),
        ),
      ),
    );
  }
}
