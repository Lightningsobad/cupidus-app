import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/dream_jar/data/dream_jar_repository.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/screens/dream_jar_list_screen.dart';
import 'package:cupid_mobile/features/dream_jar/presentation/widgets/dream_jar_entry_card.dart';
import 'package:cupid_mobile/features/expenses/expenses_route.dart';
import 'package:cupid_mobile/features/expenses/presentation/expense_strings.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart';
import 'package:cupid_mobile/features/timeline/presentation/screens/timeline_screen.dart';
import 'package:cupid_mobile/features/timeline/presentation/timeline_cubit.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_entry_point_card.dart';
import 'package:flutter/material.dart';

import '../../vibes/presentation/vibe_screen.dart';
import '../../vibes/presentation/widgets/vibe_entry_card.dart';
import '../../reminders/presentation/reminder_strings.dart';
import '../../reminders/presentation/screens/reminder_schedule_screen.dart';
import '../../anti_ghosting/anti_ghosting.dart';
import '../../pet/presentation/widgets/pet_preview_card.dart';
import '../../love_contracts/presentation/widgets/love_contract_entry_tile.dart';

/// Bootable placeholder screen for the Runnable Project Foundation gate.
/// Replaced by real feature routing once F1-F6 foundation stories land.
///
/// Mounts [VibeEntryCard] as the discoverable entry point to the `vibe`
/// screen (`architecture/solution.md` §4 D-010-5); v1 passes no mood
/// snapshot so no duplicate fetch happens ahead of `VibeScreen`'s own load.
/// Additive only — no `AppShell`/tab-bar restructure (out of this phase's
/// scope).
///
/// STORY-009 P4 mounts the Synced Reminder entry card here as the feature's
/// second discoverable navigation edge (`ux/uiux-spec.md` entry-point
/// paragraph before §1.1) -- additive only, no bottom nav bar or router
/// package introduced. The pre-existing readiness `Text` below is left
/// exactly as it was.
///
/// STORY-014 P5 mounts the Dream Jar entry card here as the feature's sole
/// discoverable navigation edge (`ux/uiux-spec.md` entry-point paragraph
/// before §1.1) — no bottom nav bar or router package is introduced.
///
/// STORY-011 mounts [PetPreviewCard] as the Bun Pet feature's discoverable
/// entry point (`architecture/solution.md` §4 Boundaries And Ownership) —
/// additive only, appended after the existing entry cards.
///
/// STORY-012 mounts [TimelineEntryPointCard] (gated behind
/// [_TimelineEntryPointGate]) as the Love Timeline feature's discoverable
/// entry point, appended after the existing entry cards. [resolvePairingStatus]
/// and [createTimelineCubit] default to `getIt`-backed factories (STORY-012
/// P3/P7), matching `SplashScreen`'s `createSessionGateCubit` pattern, so this
/// screen stays testable with a fake pairing store.
///
/// STORY-015 P5 mounts [_ExpensesEntryCard] as the shared-expenses feature's
/// discoverable entry point (`ux/uiux-spec.md` entry-point paragraph before
/// §1.1; R-015.2), appended after the Timeline entry. It always navigates to
/// [ExpensesEntryPoint], which resolves the AC4 pairing gate itself -- this
/// screen does not duplicate that check.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    Future<PairingStatus> Function()? resolvePairingStatus,
    TimelineCubit Function()? createTimelineCubit,
  }) : // ignore: prefer_initializing_formals
       _resolvePairingStatus = resolvePairingStatus,
       // ignore: prefer_initializing_formals
       _createTimelineCubit = createTimelineCubit;

  final Future<PairingStatus> Function()? _resolvePairingStatus;
  final TimelineCubit Function()? _createTimelineCubit;

  static Future<PairingStatus> _defaultResolvePairingStatus() =>
      getIt<CouplePairingStore>().resolve();

  static TimelineCubit _defaultCreateTimelineCubit() =>
      TimelineCubit(getIt<TimelineRepository>());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cupid')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(CupidSpacing.lg),
          // Wrapped in a scrollable container because each additive feature
          // story (anti-ghosting, vibe, reminders, dream jar, bun pet, love
          // contracts, timeline, ...) appends one more discoverable entry
          // card here; a fixed, non-scrolling Column overflows once enough
          // cards accumulate. No entry card's own layout changes.
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Center(
                  child: Text(
                    'Cupid mobile scaffold is running.',
                    key: Key('home_screen_ready_signal'),
                  ),
                ),
                SizedBox(height: CupidSpacing.lg),
                // STORY-008 P2: additive discoverable entry point.
                const AntiGhostEntryCard(),
                SizedBox(height: CupidSpacing.lg),
                VibeEntryCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const VibeScreen()),
                  ),
                ),
                SizedBox(height: CupidSpacing.lg),
                _ReminderEntryCard(
                  key: const Key('home_reminder_entry_card'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ReminderScheduleScreen(),
                    ),
                  ),
                ),
                SizedBox(height: CupidSpacing.lg),
                DreamJarEntryCard(
                  key: const Key('home_dream_jar_entry_card'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DreamJarListScreen(
                        repository: getIt<DreamJarRepository>(),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: CupidSpacing.lg),
                const PetPreviewCard(),
                SizedBox(height: CupidSpacing.lg),
                const LoveContractEntryTile(),
                _TimelineEntryPointGate(
                  resolvePairingStatus:
                      _resolvePairingStatus ?? _defaultResolvePairingStatus,
                  createTimelineCubit:
                      _createTimelineCubit ?? _defaultCreateTimelineCubit,
                ),
                SizedBox(height: CupidSpacing.lg),
                _ExpensesEntryCard(
                  key: const Key('home_expenses_entry_card'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ExpensesEntryPoint(),
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

/// Labelled, tappable affordance into [ReminderScheduleScreen]
/// (`../../coding-plan/phase-P4-entry-point-and-copy-guard.md`: "discoverable
/// navigation affordance ... not direct-route-only access"). Kept private to
/// this file since P4's write scope is `home_screen.dart` plus `app_shell.dart`
/// only -- not a new design-system or feature widget file.
class _ReminderEntryCard extends StatelessWidget {
  const _ReminderEntryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Material(
      color: colors.colorSurface,
      borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        child: Padding(
          padding: EdgeInsets.all(CupidSpacing.md),
          child: Row(
            children: [
              CupidIcon(
                CupidIcons.notificationsActive,
                size: 24,
                color: colors.colorText,
              ),
              SizedBox(width: CupidSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.reminderNotificationsRowTitle,
                      style: type.body.copyWith(
                        color: colors.colorText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: CupidSpacing.xs),
                    Text(
                      context.reminderNotificationsRowSubtitle,
                      style: type.caption.copyWith(
                        color: colors.colorTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Labelled, tappable affordance into [ExpensesEntryPoint]
/// (`ux/uiux-spec.md` entry-point paragraph before §1.1: "discoverable
/// navigation affordance ... not direct-route-only access" -- same precedent
/// as [_ReminderEntryCard]). Kept private to this file since P5's write scope
/// is `home_screen.dart` plus the `expenses` feature files only -- not a new
/// design-system or feature widget file. Always navigable; the AC4 pairing
/// gate is resolved by [ExpensesEntryPoint] itself, not this card.
class _ExpensesEntryCard extends StatelessWidget {
  const _ExpensesEntryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Material(
      color: colors.colorSurface,
      borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        child: Padding(
          padding: EdgeInsets.all(CupidSpacing.md),
          child: Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 24,
                color: colors.colorText,
              ),
              SizedBox(width: CupidSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ExpenseStrings.screenTitle(context),
                      style: type.body.copyWith(
                        color: colors.colorText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: CupidSpacing.xs),
                    Text(
                      ExpenseStrings.addActionLabel(context),
                      style: type.caption.copyWith(
                        color: colors.colorTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Resolves [PairingStatus] once per mount rather than on every rebuild --
/// calling [resolvePairingStatus] directly inside `FutureBuilder.future`
/// would hand it a fresh, never-settling [Future] on every parent rebuild.
class _TimelineEntryPointGate extends StatefulWidget {
  const _TimelineEntryPointGate({
    required this.resolvePairingStatus,
    required this.createTimelineCubit,
  });

  final Future<PairingStatus> Function() resolvePairingStatus;
  final TimelineCubit Function() createTimelineCubit;

  @override
  State<_TimelineEntryPointGate> createState() =>
      _TimelineEntryPointGateState();
}

class _TimelineEntryPointGateState extends State<_TimelineEntryPointGate> {
  late final Future<PairingStatus> _pairingStatus = widget
      .resolvePairingStatus();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PairingStatus>(
      future: _pairingStatus,
      builder: (BuildContext context, AsyncSnapshot<PairingStatus> snapshot) {
        if (snapshot.data != PairingStatus.paired) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: EdgeInsets.only(top: CupidSpacing.md),
          child: TimelineEntryPointCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    TimelineScreen(createCubit: widget.createTimelineCubit),
              ),
            ),
          ),
        );
      },
    );
  }
}
