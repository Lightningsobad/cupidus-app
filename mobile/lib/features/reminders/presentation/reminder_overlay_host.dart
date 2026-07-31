import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import 'reminder_firing_cubit.dart';
import 'reminder_strings.dart';
import 'widgets/reminder_firing_overlay.dart';

/// Mounts the Synced Reminder firing overlay above [child]
/// (`architecture/solution.md` §4 Boundaries And Ownership: "mountable once,
/// above the shell", consumed by P4). Not screen-specific: whichever screen
/// the user happens to be on when `triggerAlarm` arrives gets the overlay on
/// top of it.
class ReminderOverlayHost extends StatelessWidget {
  const ReminderOverlayHost({
    super.key,
    required this.child,
    ReminderFiringCubit Function()? createCubit,
  }) : _createCubit = createCubit;

  final Widget child;
  final ReminderFiringCubit Function()? _createCubit;

  @override
  Widget build(BuildContext context) {
    // `main.dart` does not call `setupServiceLocator()` yet (a pre-existing
    // composition-root gap outside this story's scope), so `AppShell`
    // mounting this host at the top of the widget tree must not crash boot
    // when `ReminderFiringCubit` is not registered -- e.g. `flutter test
    // test/widget_test.dart` pumps `CupidApp()` directly. Render [child]
    // bare in that case; the overlay becomes available once a real
    // composition root registers the cubit before `runApp`.
    final ReminderFiringCubit Function()? factory =
        _createCubit ??
        (getIt.isRegistered<ReminderFiringCubit>()
            ? () => getIt<ReminderFiringCubit>()
            : null);
    if (factory == null) return child;

    return BlocProvider<ReminderFiringCubit>(
      create: (_) => factory(),
      child: _ReminderOverlayHostView(child: child),
    );
  }
}

class _ReminderOverlayHostView extends StatefulWidget {
  const _ReminderOverlayHostView({required this.child});

  final Widget child;

  @override
  State<_ReminderOverlayHostView> createState() =>
      _ReminderOverlayHostViewState();
}

class _ReminderOverlayHostViewState extends State<_ReminderOverlayHostView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onForeground());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onForeground();
    }
  }

  /// D5 partner-dismissed refresh, plus the §7 timeout-acknowledgment notice
  /// -- both run on mount and on every return-to-foreground transition.
  void _onForeground() {
    if (!mounted) return;
    final ReminderFiringCubit cubit = context.read<ReminderFiringCubit>();
    unawaited(cubit.refreshFromForeground());
    unawaited(_showTimeoutNoticeIfPending(cubit));
  }

  Future<void> _showTimeoutNoticeIfPending(ReminderFiringCubit cubit) async {
    final bool shouldShow = await cubit.consumePendingTimeoutNotice();
    if (!shouldShow || !mounted) return;
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(context.reminderTimedOutNotice)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReminderFiringCubit, ReminderFiringState>(
      builder: (context, state) {
        return Stack(
          children: [
            widget.child,
            if (state is ReminderFiringOpen)
              Positioned.fill(
                child: ReminderFiringOverlay(
                  state: state,
                  onDismiss: () =>
                      context.read<ReminderFiringCubit>().dismiss(),
                ),
              ),
          ],
        );
      },
    );
  }
}
