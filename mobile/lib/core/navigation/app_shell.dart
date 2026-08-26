// Field names below are intentionally private while the constructor's
// named parameters stay public without a leading underscore; a `this._field`
// initializing formal would force the named parameter itself to be private.
// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:cupid_api/cupid_api.dart';
import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../features/account/data/account_repository.dart';
import '../../features/account/presentation/screens/me_screen.dart';
import '../../features/chat/data/chat_partner_store.dart';
import '../../features/chat/data/chat_repository.dart';
import '../../features/chat/data/ghost_consent_store.dart';
import '../../features/chat/presentation/chat_entry_gate.dart';
import '../../features/chat/presentation/chat_strings.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/screens/ghost_settings_screen.dart';
import '../../features/dream_jar/data/dream_jar_repository.dart';
import '../../features/dream_jar/presentation/screens/dream_jar_list_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/pet/presentation/pet_screen.dart';
import '../di/service_locator.dart';
import '../realtime/backend_user_id_store.dart';
import '../realtime/cupid_realtime.dart';
import '../../features/themes/presentation/theme_cubit.dart';

/// One shell destination: its tab-bar item paired with the body it mounts.
/// Keeping both in a single ordered list is what makes index math safe when
/// Chat's conditional slot appears or disappears — every later destination
/// moves with it instead of being addressed by a hardcoded position.
class _ShellDestination {
  const _ShellDestination({required this.item, required this.buildBody});

  final CupidTabBarItem item;
  final Widget Function() buildBody;
}

/// Root navigation shell. Mounts a [CupidTabBar] with the design's five
/// destinations (Nhà / Trò chuyện / Pet / Ví chung / Tôi), where Chat is gated
/// by [ChatEntryGate] (AC5) and drops out of the list entirely when locked.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    ChatPartnerStore? partnerStore,
    ChatRepository? chatRepository,
    RealtimeCoordinator? coordinator,
    BackendUserIdStore? backendUserIdStore,
    GhostConsentStore? consentStore,
  })  : _partnerStore = partnerStore,
        _chatRepository = chatRepository,
        _coordinator = coordinator,
        _backendUserIdStore = backendUserIdStore,
        _consentStore = consentStore;

  final ChatPartnerStore? _partnerStore;
  final ChatRepository? _chatRepository;
  final RealtimeCoordinator? _coordinator;
  final BackendUserIdStore? _backendUserIdStore;
  final GhostConsentStore? _consentStore;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  late final ChatPartnerStore _partnerStore =
      widget._partnerStore ?? getIt<ChatPartnerStore>();
  late final ChatRepository _chatRepository =
      widget._chatRepository ?? getIt<ChatRepository>();
  late final RealtimeCoordinator _coordinator =
      widget._coordinator ?? getIt<RealtimeCoordinator>();
  late final BackendUserIdStore _backendUserIdStore =
      widget._backendUserIdStore ?? getIt<BackendUserIdStore>();

  late final GhostConsentStore _consentStore =
      widget._consentStore ?? GhostConsentStore(dio: getIt<CupidApi>().dio);

  @override
  void initState() {
    super.initState();
    unawaited(_initRealtime());
    if (getIt.isRegistered<ThemeCubit>()) {
      unawaited(getIt<ThemeCubit>().loadThemeState());
    }
  }

  Future<void> _initRealtime() async {
    try {
      await _partnerStore.refreshFromServer();
      await _coordinator.start();
    } catch (_) {}
  }

  void _openGhostSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GhostSettingsScreen(
          coordinator: _coordinator,
          consentStore: _consentStore,
          partnerStore: _partnerStore,
          backendUserIdStore: _backendUserIdStore,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildChatBody() {
    return Stack(
      children: <Widget>[
        ChatScreen(
          repository: _chatRepository,
          coordinator: _coordinator,
          backendUserIdStore: _backendUserIdStore,
          partnerStore: _partnerStore,
          consentStore: _consentStore,
        ),
        // Temporary `ghostset` entry point (Tech Lead exception,
        // `coding-plan/phase-P4-entry-point-and-gate.md` §3): the Home
        // dashboard's real `goGhostSet` tile does not exist yet because Home
        // is still a placeholder screen. Move this action there and delete
        // this overlay once the real Home dashboard lands.
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CupidSpacing.xs,
                vertical: CupidSpacing.xs,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: context.cupidPlatform.tapTarget,
                  minHeight: context.cupidPlatform.tapTarget,
                ),
                child: IconButton(
                  key: const Key('ghost_settings_entry_action'),
                  tooltip: ChatStrings.ghostSetToggleTitle(context),
                  icon: const Icon(Icons.blur_on),
                  onPressed: _openGhostSettings,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChatEntryGate(
      partnerStore: _partnerStore,
      builder: (context, isUnlocked) {
        final List<_ShellDestination> destinations = <_ShellDestination>[
          _ShellDestination(
            item: CupidTabBarItem(
              icon: Icons.home_rounded,
              label: context.viEn('Nhà', 'Home'),
            ),
            buildBody: () => const HomeScreen(),
          ),
          if (isUnlocked)
            _ShellDestination(
              item: CupidTabBarItem(
                icon: Icons.chat_bubble_outline,
                label: context.viEn('Trò chuyện', 'Chat'),
              ),
              buildBody: _buildChatBody,
            ),
          _ShellDestination(
            item: CupidTabBarItem(
              icon: CupidIcons.pets,
              label: context.viEn('Pet', 'Pet'),
            ),
            buildBody: () => const PetScreen(),
          ),
          _ShellDestination(
            item: CupidTabBarItem(
              icon: CupidIcons.savings,
              label: context.viEn('Ví chung', 'Wallet'),
            ),
            buildBody: () =>
                DreamJarListScreen(repository: getIt<DreamJarRepository>()),
          ),
          _ShellDestination(
            item: CupidTabBarItem(
              icon: CupidIcons.person,
              label: context.viEn('Tôi', 'Me'),
            ),
            buildBody: () =>
                MeScreen(accountRepository: getIt<AccountRepository>()),
          ),
        ];
        final int safeIndex =
            _index < destinations.length ? _index : 0;

        return Scaffold(
          // Only the selected destination is built (no `IndexedStack` of all
          // tabs at once), so each body's `getIt` lookup only runs once its
          // tab is actually selected.
          body: destinations[safeIndex].buildBody(),
          bottomNavigationBar: CupidTabBar(
            items: <CupidTabBarItem>[
              for (final _ShellDestination d in destinations) d.item,
            ],
            currentIndex: safeIndex,
            onTap: (int i) => setState(() => _index = i),
          ),
        );
      },
    );
  }
}
