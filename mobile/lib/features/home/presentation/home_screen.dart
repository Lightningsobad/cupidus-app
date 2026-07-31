import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart';
import 'package:cupid_mobile/features/timeline/presentation/screens/timeline_screen.dart';
import 'package:cupid_mobile/features/timeline/presentation/timeline_cubit.dart';
import 'package:cupid_mobile/features/timeline/presentation/widgets/timeline_entry_point_card.dart';
import 'package:flutter/material.dart';

/// Bootable placeholder screen for the Runnable Project Foundation gate.
/// Replaced by real feature routing once F1-F6 foundation stories land.
///
/// [resolvePairingStatus] and [createTimelineCubit] default to `getIt`-backed
/// factories (STORY-012 P3/P7), matching `SplashScreen`'s
/// `createSessionGateCubit` pattern, so this screen stays testable with a
/// fake pairing store.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    Future<PairingStatus> Function()? resolvePairingStatus,
    TimelineCubit Function()? createTimelineCubit,
  }) :
      // ignore: prefer_initializing_formals
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Cupid mobile scaffold is running.',
              key: Key('home_screen_ready_signal'),
            ),
            _TimelineEntryPointGate(
              resolvePairingStatus:
                  _resolvePairingStatus ?? _defaultResolvePairingStatus,
              createTimelineCubit:
                  _createTimelineCubit ?? _defaultCreateTimelineCubit,
            ),
          ],
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
  late final Future<PairingStatus> _pairingStatus =
      widget.resolvePairingStatus();

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
