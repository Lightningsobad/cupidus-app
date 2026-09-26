import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/thank_you_activation_service.dart';

@immutable
class ThankYouBlockState {
  const ThankYouBlockState({this.isVisible = false});

  final bool isVisible;

  @override
  bool operator ==(Object other) =>
      other is ThankYouBlockState && other.isVisible == isVisible;

  @override
  int get hashCode => isVisible.hashCode;
}

/// Decides whether the "Cảm ơn + chốt việc kế tiếp" block draws on this visit
/// to the card-detail screen, and spends the card's one lifetime turn the
/// moment it does (`ux/uiux-spec.md` mục 1, AC-1/AC-2/AC-3).
///
/// AC-3 counts *presentations*, not uses, so [resolve] calls
/// `ThankYouActivationService.consume` before the block is ever emitted —
/// opening the screen and walking away spends the turn exactly as using all
/// three sections does. The write lands first so an interrupted visit cannot
/// leave a card that already saw the block still eligible for it.
class ThankYouBlockCubit extends Cubit<ThankYouBlockState> {
  ThankYouBlockCubit({
    required this.cardId,
    required this.isRecording,
    required this.service,
  }) : super(const ThankYouBlockState());

  final String cardId;

  /// *Đã đi rồi* — the "ghi lại" mode of the detail screen. The block is a
  /// child of that flow only (AC-7); on every other status this cubit settles
  /// without touching the ledger.
  final bool isRecording;

  /// Deferred on purpose. The block mounts on *every* card the detail screen
  /// shows, but only a *Đã đi rồi* card can ever consult the ledger, so the
  /// database-backed service is built on the one branch that uses it instead of
  /// on every card open.
  final ThankYouActivationService Function() service;

  /// True once this screen visit has made its decision. Guards the turn
  /// against a second [resolve] from a rebuild, which would be harmless at the
  /// ledger (`consume` is idempotent) but would bring a dismissed block back.
  bool _settled = false;

  Future<void> resolve() async {
    if (_settled) {
      return;
    }
    _settled = true;

    if (!isRecording) {
      return;
    }

    final ThankYouActivationService ledger = service();
    if (!await ledger.isEligible(cardId)) {
      return;
    }

    await ledger.consume(cardId);
    if (!isClosed) {
      emit(const ThankYouBlockState(isVisible: true));
    }
  }

  /// The header's `close` icon. Equivalent to having used the block: the turn
  /// was already spent by [resolve], so there is nothing to record here and no
  /// way back — this cubit exposes no reopen (`ux/uiux-spec.md` mục 2).
  void dismiss() => emit(const ThankYouBlockState());
}
