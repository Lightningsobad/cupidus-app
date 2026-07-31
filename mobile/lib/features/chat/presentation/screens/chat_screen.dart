import 'dart:async';

import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/chat_partner_store.dart';
import '../../data/chat_repository.dart';
import '../../data/ghost_consent_store.dart';
import '../chat_cubit.dart';
import '../chat_strings.dart';
import '../ghost_cubit.dart';
import '../widgets/chat_composer.dart';
import '../widgets/ghost_bubble.dart';
import '../widgets/message_bubble.dart';

/// `chat` screen (`ux/uiux-spec.md` §3). Does not wire its own route/nav
/// entry — that is P4's scope (`coding-plan/phase-P2-chat-screen.md` §1B).
/// Also does not wire a `ghostset` navigation entry point — the design
/// source reaches `ghostset` from a Home dashboard tile, not from inside
/// `chat` (`ux/uiux-spec.md` §2 Flow Map), and either way that wiring is
/// P4's scope (`coding-plan/phase-P3-typing-ghost.md` §6).
class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
    required this.repository,
    required this.coordinator,
    required this.backendUserIdStore,
    required this.partnerStore,
    required this.consentStore,
    this.onBack,
  });

  final ChatRepository repository;
  final RealtimeCoordinator coordinator;
  final BackendUserIdStore backendUserIdStore;
  final ChatPartnerStore partnerStore;
  final GhostConsentStore consentStore;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatCubit>(
          create: (_) => ChatCubit(
            repository: repository,
            coordinator: coordinator,
            backendUserIdStore: backendUserIdStore,
          ),
        ),
        BlocProvider<GhostCubit>(
          create: (_) => GhostCubit(
            coordinator: coordinator,
            consentStore: consentStore,
            partnerStore: partnerStore,
            backendUserIdStore: backendUserIdStore,
          ),
        ),
      ],
      child: _ChatView(
        partnerDisplayName: partnerStore.displayName,
        onBack: onBack,
      ),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView({required this.partnerDisplayName, required this.onBack});

  final String? partnerDisplayName;
  final VoidCallback? onBack;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingOlder = false;
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    unawaited(context.read<ChatCubit>().markThreadSeen());
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final position = _scrollController.position;
    if (!_isLoadingOlder && position.pixels <= position.minScrollExtent) {
      unawaited(_loadOlder());
    }
  }

  Future<void> _loadOlder() async {
    setState(() => _isLoadingOlder = true);
    await context.read<ChatCubit>().loadOlderRequested();
    if (mounted) setState(() => _isLoadingOlder = false);
  }

  bool get _isPinnedToBottom {
    if (!_scrollController.hasClients) return true;
    final position = _scrollController.position;
    return position.pixels >= position.maxScrollExtent - 48;
  }

  void _maybeAutoScrollToBottom(int newMessageCount) {
    final bool grew = newMessageCount > _previousMessageCount;
    _previousMessageCount = newMessageCount;
    if (!grew || !_isPinnedToBottom) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Scaffold(
      // `CupidHeader`'s contract (design_system/adaptive/) exposes a title
      // string only, with no avatar slot — reused as-is rather than
      // reopening a frozen shared component in this phase.
      appBar: CupidHeader(
        title: widget.partnerDisplayName ?? '',
        onBack: widget.onBack,
      ),
      // Only ghost on/off transitions announce assertively here
      // (`ux/uiux-spec.md` §8) — the partner's per-keystroke draft is a
      // polite live region owned by `GhostBubble` itself, never this
      // listener. A "full message arriving" assertive announcement is not
      // added here: it is P2's already-reviewed message-thread surface, not
      // this phase's ghost-specific write scope.
      body: BlocListener<GhostCubit, GhostState>(
        listenWhen: (previous, current) =>
            previous.consentLevel != current.consentLevel &&
            current.consentLevel != GhostConsentLevel.pending,
        listener: (context, state) {
          SemanticsService.sendAnnouncement(
            View.of(context),
            state.consentLevel == GhostConsentLevel.on
                ? ChatStrings.ghostTurnedOnAnnouncement(context)
                : ChatStrings.ghostTurnedOffAnnouncement(context),
            TextDirection.ltr,
            assertiveness: Assertiveness.assertive,
          );
        },
        child: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            _maybeAutoScrollToBottom(state.messages.length);
            return Column(
              children: [
                if (state.connectionDegraded) _DegradedBanner(colors: colors),
                _PrivacyChip(colors: colors),
                if (_isLoadingOlder) const _OlderPageSpinner(),
                Expanded(
                  child: state.showEmptyState
                      ? _EmptyState(colors: colors)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(CupidSpacing.md),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: CupidSpacing.sm,
                              ),
                              child: MessageBubble(
                                message: message,
                                isMine: message.senderId == state.myId,
                              ),
                            );
                          },
                        ),
                ),
                BlocBuilder<GhostCubit, GhostState>(
                  builder: (context, ghostState) {
                    if (!ghostState.isPartnerGhosting) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: CupidSpacing.md,
                        vertical: CupidSpacing.xs,
                      ),
                      child: GhostBubble(
                        keptContent: ghostState.partnerKeptContent,
                        struckContent: ghostState.partnerStruckContent,
                      ),
                    );
                  },
                ),
                BlocBuilder<GhostCubit, GhostState>(
                  builder: (context, ghostState) {
                    return ChatComposer(
                      onSend: context.read<ChatCubit>().sendPressed,
                      showNetworkUnavailableError:
                          state.showNetworkUnavailableError,
                      ghostConsentLevel: ghostState.consentLevel,
                      onGhostTogglePressed: () =>
                          context.read<GhostCubit>().toggleTapped(),
                      partnerDisplayName: widget.partnerDisplayName,
                      onDraftChanged: context.read<GhostCubit>().draftChanged,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PrivacyChip extends StatelessWidget {
  const _PrivacyChip({required this.colors});

  final CupidColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: CupidSpacing.md,
        vertical: CupidSpacing.sm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: CupidSpacing.sm,
        vertical: CupidSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.colorSurfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // `CupidIcons` (design_system/icons/) does not yet carry a
          // verified cmap codepoint for a lock glyph — adding one is out of
          // this phase's write scope. Uses Flutter's bundled Material Icons
          // font directly rather than guessing an unverified codepoint on
          // the app's custom icon font.
          Icon(Icons.lock, size: 14, color: colors.colorTextMuted),
          const SizedBox(width: CupidSpacing.xs),
          Flexible(
            child: Text(
              ChatStrings.privacyChip(context),
              style: context.cupidType.caption.copyWith(
                color: colors.colorTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DegradedBanner extends StatelessWidget {
  const _DegradedBanner({required this.colors});

  final CupidColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        color: colors.colorSurfaceAlt,
        padding: const EdgeInsets.symmetric(
          horizontal: CupidSpacing.md,
          vertical: CupidSpacing.xs,
        ),
        child: Text(
          ChatStrings.degradedIndicator(context),
          style: context.cupidType.caption.copyWith(
            color: colors.colorTextMuted,
          ),
        ),
      ),
    );
  }
}

class _OlderPageSpinner extends StatelessWidget {
  const _OlderPageSpinner();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: CupidSpacing.sm),
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors});

  final CupidColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        ChatStrings.emptyStateFirstOpen(context),
        style: context.cupidType.body.copyWith(color: colors.colorTextMuted),
      ),
    );
  }
}
