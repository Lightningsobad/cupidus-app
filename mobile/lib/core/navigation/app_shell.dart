import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../features/account/data/account_repository.dart';
import '../../features/account/presentation/screens/me_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../l10n/generated/app_l10n.dart';
import '../di/service_locator.dart';

/// Root navigation shell. Feature routes are added here as they land;
/// v1 boots directly into the placeholder [HomeScreen].
///
/// `coding-plan/master-plan.md` §6.2 P2 / DEC-4: wires exactly one entry
/// point into the account hub so AC1 is demonstrable, without building the
/// 5-tab shell (`CupidTabBar` exists but stays unconsumed — a separate Scrum
/// Master routing item).
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  void _openAccountHub(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MeScreen(accountRepository: getIt<AccountRepository>()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    return Stack(
      children: <Widget>[
        const HomeScreen(),
        Positioned(
          right: CupidSpacing.md,
          bottom: CupidSpacing.md,
          child: SafeArea(
            child: FloatingActionButton(
              heroTag: 'account-hub-entry',
              backgroundColor: colors.colorAccentPink,
              foregroundColor: colors.colorText,
              tooltip: AppL10n.of(context).app_shell_account_entry_tooltip,
              onPressed: () => _openAccountHub(context),
              child: const Icon(Icons.person),
            ),
          ),
        ),
      ],
    );
  }
}
