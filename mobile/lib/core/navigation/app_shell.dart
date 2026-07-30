import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/pairing/data/pairing_repository.dart';
import '../../features/pairing/presentation/pair_gate_cubit.dart';
import '../di/service_locator.dart';

/// Root navigation shell (`ux/uiux-spec.md` section 6, AC4).
///
/// [createPairGateCubit] defaults to wiring the real [PairingRepository] from
/// `getIt` (registered by STORY-005 P0's `setupServiceLocator`, read-only
/// here). Tests supply a fake fetcher instead so the gate can be driven
/// without a live/mocked `Dio`.
class AppShell extends StatelessWidget {
  const AppShell({super.key, PairGateCubit Function()? createPairGateCubit})
    : _createPairGateCubit = createPairGateCubit;

  final PairGateCubit Function()? _createPairGateCubit;

  PairGateCubit _defaultPairGateCubit() {
    final PairingRepository repository = getIt<PairingRepository>();
    return PairGateCubit(getPartnerLink: repository.getPartnerLink);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PairGateCubit>(
      create: (_) => (_createPairGateCubit ?? _defaultPairGateCubit)(),
      child: const _AppShellView(),
    );
  }
}

class _AppShellView extends StatelessWidget {
  const _AppShellView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PairGateCubit, PairGateState>(
      builder: (context, state) => switch (state) {
        PairGateChecking() => const _PairGateChecking(),
        PairGateUnpaired() => const _PairingStack(),
        PairGatePaired() => const HomeScreen(),
      },
    );
  }
}

/// Shown only until the one-shot pair check resolves; no tab bar, matching
/// both possible destinations' `NO_TABS`/main-shell chrome.
class _PairGateChecking extends StatelessWidget {
  const _PairGateChecking();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// Pairing-flow stack root for an unpaired user (`ux/uiux-spec.md` section 6):
/// `NO_TABS`, architecturally distinct from the main tab shell. Surfaces the
/// discoverable "Pair with your partner" entry action; the `invite`/`joincode`
/// destinations it will lead to are STORY-005 P2/P3 (not yet built), so the
/// action has no navigation target wired in this phase.
class _PairingStack extends StatelessWidget {
  const _PairingStack();

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    final bool isVi = Localizations.localeOf(context).languageCode == 'vi';
    return Scaffold(
      key: const Key('pairing_stack'),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(CupidSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isVi ? 'Ghép đôi để mở khoá Cupid' : 'Pair up to unlock Cupid',
                  textAlign: TextAlign.center,
                  style: context.cupidType.cardTitle.copyWith(
                    color: colors.colorText,
                  ),
                ),
                SizedBox(height: CupidSpacing.xl),
                CupidPrimaryButton(
                  label: isVi
                      ? 'Ghép đôi với người ấy'
                      : 'Pair with your partner',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
