import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/navigation/pair_gate_shell.dart';
import '../../../../design_system/icons/cupid_icon.dart';
import '../../../../design_system/icons/cupid_icons.dart';
import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../../pairing/presentation/pair_gate_cubit.dart';
import '../../data/stage1_wipe_service.dart';
import '../widgets/close_chapter_dialog.dart';
import '../widgets/wipe_confirm_dialog.dart';

const Key returnScreenKey = Key('return_screen');
const Key returnScreenCloseKey = Key('return_close');
const Key returnScreenWipeLinkKey = Key('return_wipe_link');

/// Tile identity, in render order. Tests assert both the count and the keys, so
/// the three choices cannot silently become two or four (`ux/uiux-spec.md` §6).
const List<Key> returnScreenChoiceKeys = <Key>[
  Key('return_choice_ideas'),
  Key('return_choice_notebook'),
  Key('return_choice_new'),
];

/// Screen J13 — what the app shows when the user comes back after an absence
/// (AC-18, AC-21..AC-25, AC-30, `ux/uiux-spec.md` §6).
///
/// A full-screen takeover with a neutral greeting, three equally-weighted ways
/// forward, and the wipe link. Every exit — all three tiles, the close icon, and
/// the wipe itself — `pushReplacement`es to [PairGateShell], so the screen is
/// never a gate: it cannot be returned to by popping, and it is gone for the
/// rest of the session (AC-24, AC-30).
///
/// Absent by rule, not by omission: any mention of how long the user was away,
/// a day count, a previous-open date, a broken-streak or lost-badge line, a
/// greyed-out or dimmed state, a "recover" progress bar, a "stale"/"neglected"
/// label, a "suggested"/"do this first" badge on any tile, and any ranking
/// between the three (AC-20, AC-21, AC-22). The greeting is the same greeting a
/// user who left yesterday would see.
///
/// The three tiles land on the same usable root rather than each deep-linking to
/// its own destination: `AppShell` exposes no initial-tab seam and `HomeScreen`
/// no initial-pane seam, and building that plumbing would edit files outside
/// this phase's write scope. The phase file collapses the three destinations to
/// "one usable screen" for exactly this reason.
class ReturnScreen extends StatefulWidget {
  const ReturnScreen({
    super.key,
    this.wipeService,
    this.createPairGateCubit,
  });

  final Stage1WipeService? wipeService;
  final PairGateCubit Function()? createPairGateCubit;

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  bool _leaving = false;

  void _leave() {
    if (_leaving) {
      return;
    }
    _leaving = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) =>
            PairGateShell(createPairGateCubit: widget.createPairGateCubit),
      ),
    );
  }

  Future<void> _wipe() async {
    final bool confirmed = await showWipeConfirmDialog(context);
    if (!confirmed || !mounted) {
      return;
    }
    final Stage1WipeService? service =
        widget.wipeService ??
        (getIt.isRegistered<Stage1WipeService>()
            ? getIt<Stage1WipeService>()
            : null);
    await service?.wipeAll();
    if (!mounted) {
      return;
    }
    // Straight back to the first-run empty state, with no farewell screen and
    // no celebratory confirmation in between (AC-29, `ux/uiux-spec.md` §7).
    _leave();
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Scaffold(
      key: returnScreenKey,
      backgroundColor: colors.colorBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(CupidSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: Semantics(
                  button: true,
                  label: closeChapterText(context, _closeLabel),
                  child: GestureDetector(
                    key: returnScreenCloseKey,
                    behavior: HitTestBehavior.opaque,
                    onTap: _leave,
                    child: SizedBox(
                      width: platform.tapTarget,
                      height: platform.tapTarget,
                      child: CupidIcon(
                        CupidIcons.close,
                        variant: CupidIconVariant.line,
                        size: _closeIconSize,
                        color: colors.colorLine,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: CupidSpacing.md),
              Text(
                closeChapterText(context, _greeting),
                style: type.cardTitle.copyWith(color: colors.colorText),
              ),
              const SizedBox(height: CupidSpacing.sm),
              Text(
                closeChapterText(context, _lead),
                style: type.body.copyWith(color: colors.colorTextMuted),
              ),
              const SizedBox(height: CupidSpacing.lg),
              for (int i = 0; i < returnScreenChoices.length; i++) ...<Widget>[
                _ChoiceTile(
                  tileKey: returnScreenChoiceKeys[i],
                  icon: _choiceIcons[i],
                  label: closeChapterText(context, returnScreenChoices[i]),
                  onTap: _leave,
                ),
                if (i < returnScreenChoices.length - 1)
                  const SizedBox(height: CupidSpacing.sm),
              ],
              const SizedBox(height: CupidSpacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: Semantics(
                  button: true,
                  label: closeChapterText(context, _wipeLinkLabel),
                  child: GestureDetector(
                    key: returnScreenWipeLinkKey,
                    behavior: HitTestBehavior.opaque,
                    onTap: _wipe,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: CupidSpacing.sm,
                      ),
                      child: Text(
                        closeChapterText(context, _wipeLinkLabel),
                        style: type.caption.copyWith(color: colors.colorRed),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One of the three ways forward. Every tile is drawn by this one widget, so no
/// tile can carry a badge, a different weight, or a different size that would
/// imply a ranking (AC-22).
class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.tileKey,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Key tileKey;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        key: tileKey,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.colorSurface,
            borderRadius: BorderRadius.circular(platform.radiusCard),
            border: Border.all(color: colors.colorLine),
          ),
          child: Padding(
            padding: const EdgeInsets.all(CupidSpacing.md),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: platform.tapTarget,
                  height: platform.tapTarget,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.colorSurfaceAlt,
                      borderRadius: BorderRadius.circular(platform.radiusSmall),
                    ),
                    child: Center(
                      child: CupidIcon(
                        icon,
                        variant: CupidIconVariant.line,
                        color: colors.colorTextMuted,
                        size: _choiceIconSize,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: CupidSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    style: type.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.colorText,
                    ),
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

const double _closeIconSize = 20;

const double _choiceIconSize = 24;

const List<String> _closeLabel = <String>['Đóng', 'Close'];

/// No reference to the absence, in any direction (AC-21).
const List<String> _greeting = <String>['Chào bạn', 'Hello'];

const List<String> _lead = <String>[
  'Bạn muốn bắt đầu từ đâu?',
  'Where would you like to start?',
];

const List<String> _wipeLinkLabel = <String>[
  'Xoá hết dữ liệu chặng 1',
  'Erase all stage-1 data',
];

/// The three fixed choices, in a fixed order. Nothing here is scored, ranked, or
/// selected from the user's data (AC-22). Public so the phase test asserts the
/// rendered labels against the same source the screen draws from.
const List<List<String>> returnScreenChoices = <List<String>>[
  <String>['Xem kho ý tưởng', 'Browse your ideas'],
  <String>['Xem sổ tay & kỹ năng', 'Open your notebook and skills'],
  <String>['Bắt đầu một việc mới', 'Start something new'],
];

const List<IconData> _choiceIcons = <IconData>[
  CupidIcons.lightbulb,
  CupidIcons.menuBook,
  CupidIcons.add,
];
