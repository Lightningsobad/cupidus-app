// Field names below are intentionally private while the constructor's
// named parameters stay public without a leading underscore; a `this._field`
// initializing formal would force the named parameter itself to be private.
// ignore_for_file: prefer_initializing_formals

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
import '../../features/gallery/presentation/screens/gallery_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../l10n/generated/app_l10n.dart';
import '../di/service_locator.dart';
import '../realtime/backend_user_id_store.dart';
import '../realtime/cupid_realtime.dart';

/// `photo_library` glyph for the epic-4 gallery tab slot. Defined locally
/// rather than added to `CupidIcons` because STORY-013 P1's write scope did
/// not include `design_system/icons/cupid_icons.dart` (same sourcing rule as
/// `CupidIcons`, confirmed via a `fontTools` cmap lookup on the bundled
/// `MaterialSymbolsRounded-Variable.ttf`).
const IconData _galleryTabIcon = IconData(
  0xe413,
  fontFamily: CupidIcons.fontFamily,
);

/// Root navigation shell. Mounts a [CupidTabBar] with the Home destination
/// always present, the Chat destination gated by [ChatEntryGate] (AC5), and
/// the Gallery destination (STORY-013 epic-4) always present alongside Home.
/// Pet/money/me destinations arrive with their own stories and are
/// intentionally not scaffolded here
/// (`coding-plan/phase-P4-entry-point-and-gate.md` §3).
///
/// STORY-016 `coding-plan/master-plan.md` §6.2 P2 / DEC-4: also wires exactly
/// one entry point into the account hub so AC1 is demonstrable, without
/// building the 5-tab shell (`CupidTabBar` exists but stays otherwise
/// unconsumed for the account/pet/money destinations — a separate Scrum
/// Master routing item).
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
          CupidTabBarItem(
            icon: _galleryTabIcon,
            label: context.viEn('Thư viện ảnh', 'Gallery'),
          ),
        ];
        final int safeIndex = _index < items.length ? _index : 0;
        // Chat only occupies a slot when unlocked, so its index shifts; the
        // Gallery tab is always the last item regardless of Chat's presence.
        final int chatIndex = isUnlocked ? 1 : -1;

        final Widget body;
        if (safeIndex == 0) {
          body = const HomeScreen();
        } else if (safeIndex == chatIndex) {
          body = Stack(
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
        } else {
          // STORY-013 P1 (`ux/uiux-spec.md` §2 screen inventory: "epic-4
          // gallery tab"). Only the selected destination is built (no
          // `IndexedStack` of all tabs at once), so `GalleryScreen`'s
          // `GalleryRepository` lookup only runs once the tab is tapped.
          body = const GalleryScreen();
        }

        return Scaffold(
          body: body,
          bottomNavigationBar: CupidTabBar(
            items: items,
            currentIndex: safeIndex,
            onTap: (int i) => setState(() => _index = i),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'account-hub-entry',
            backgroundColor: colors.colorAccentPink,
            foregroundColor: colors.colorText,
            tooltip: AppL10n.of(context).app_shell_account_entry_tooltip,
            onPressed: () => _openAccountHub(context),
            child: const Icon(Icons.person),
          ),
        );
      },
    );
  }
}
