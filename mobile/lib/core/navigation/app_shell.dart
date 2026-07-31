// Field names below are intentionally private while the constructor's
// named parameters stay public without a leading underscore; a `this._field`
// initializing formal would force the named parameter itself to be private.
// ignore_for_file: prefer_initializing_formals

import 'package:cupid_api/cupid_api.dart';
import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../features/chat/data/chat_partner_store.dart';
import '../../features/chat/data/chat_repository.dart';
import '../../features/chat/data/ghost_consent_store.dart';
import '../../features/chat/presentation/chat_entry_gate.dart';
import '../../features/chat/presentation/chat_strings.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/screens/ghost_settings_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../di/service_locator.dart';
import '../realtime/backend_user_id_store.dart';
import '../realtime/cupid_realtime.dart';

/// Root navigation shell. Mounts a [CupidTabBar] with the Home destination
/// always present and the Chat destination gated by [ChatEntryGate] (AC5).
/// Only Home and Chat exist at this phase; pet/money/me destinations arrive
/// with their own stories and are intentionally not scaffolded here
/// (`coding-plan/phase-P4-entry-point-and-gate.md` §3).
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

  // `GhostConsentStore` has no `service_locator.dart` registration yet
  // (adding one is outside this phase's write scope); constructed directly
  // here instead, matching the store's own contract of holding no state
  // beyond the injected `Dio`.
  late final GhostConsentStore _consentStore =
      widget._consentStore ?? GhostConsentStore(dio: getIt<CupidApi>().dio);

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

  @override
  Widget build(BuildContext context) {
    return ChatEntryGate(
      partnerStore: _partnerStore,
      builder: (context, isUnlocked) {
        final List<CupidTabBarItem> items = <CupidTabBarItem>[
          CupidTabBarItem(
            icon: Icons.home_rounded,
            label: context.viEn('Trang chủ', 'Home'),
          ),
          if (isUnlocked)
            CupidTabBarItem(
              icon: Icons.chat_bubble_outline,
              label: context.viEn('Trò chuyện', 'Chat'),
            ),
        ];
        final int safeIndex = _index < items.length ? _index : 0;

        final Widget body = safeIndex == 0
            ? const HomeScreen()
            : Stack(
                children: <Widget>[
                  ChatScreen(
                    repository: _chatRepository,
                    coordinator: _coordinator,
                    backendUserIdStore: _backendUserIdStore,
                    partnerStore: _partnerStore,
                    consentStore: _consentStore,
                  ),
                  // Temporary `ghostset` entry point (Tech Lead exception,
                  // `coding-plan/phase-P4-entry-point-and-gate.md` §3): the
                  // Home dashboard's real `goGhostSet` tile does not exist
                  // yet because Home is still a placeholder screen. Move
                  // this action there and delete this overlay once the real
                  // Home dashboard lands.
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

        return Scaffold(
          body: body,
          bottomNavigationBar: CupidTabBar(
            items: items,
            currentIndex: safeIndex,
            onTap: (int i) => setState(() => _index = i),
          ),
        );
      },
    );
  }
}
