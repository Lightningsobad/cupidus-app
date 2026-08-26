import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/chat_partner_store.dart';

/// Gates the Chat destination on partner-linkage state (AC5). Unlocked when
/// [ChatPartnerStore.partnerId] is non-null, which the store derives from
/// `GET /users/me`. Deliberately depends only on `chat_partner_store.dart`
/// and never on any linked-partner-feature source file, which may not be
/// merged at this story's BaseHead
/// (`coding-plan/phase-P4-entry-point-and-gate.md` §3/§5).
class ChatEntryGate extends StatefulWidget {
  const ChatEntryGate({
    super.key,
    required this.partnerStore,
    required this.builder,
  });

  final ChatPartnerStore partnerStore;
  final Widget Function(BuildContext context, bool isUnlocked) builder;

  @override
  State<ChatEntryGate> createState() => _ChatEntryGateState();
}

class _ChatEntryGateState extends State<ChatEntryGate> {
  late bool _isUnlocked;

  @override
  void initState() {
    super.initState();
    _isUnlocked = widget.partnerStore.partnerId != null;
    unawaited(_refresh());
  }

  Future<void> _refresh() async {
    await widget.partnerStore.refreshFromServer();
    if (!mounted) return;
    final bool unlocked = widget.partnerStore.partnerId != null;
    if (unlocked != _isUnlocked) {
      setState(() => _isUnlocked = unlocked);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _isUnlocked);
}
