import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../activity_cards/domain/activity_card.dart';
import '../data/before_you_go_dismissal_store.dart';
import '../domain/before_you_go_content.dart';
import '../domain/before_you_go_resolver.dart';

/// Reads the shipped pack off the asset bundle. Asset-only by construction:
/// no HTTP client, no model call, no cache warm-up (AC-22/AC-23). A malformed
/// pack throws out of here rather than degrading to a partial list (BR-17).
Future<BeforeYouGoPack> loadBeforeYouGoPack({AssetBundle? bundle}) async {
  final String jsonSource =
      await (bundle ?? rootBundle).loadString(beforeYouGoAssetKey);
  return parseBeforeYouGoPack(jsonSource, source: beforeYouGoAssetKey);
}

/// Hands [text] to the OS Share Sheet and forgets it. Fire-and-forget by
/// contract (R-1b/AC-19/AC-20): the result is discarded and nothing anywhere
/// records that a share happened. `share_plus` 13.3.0 API, matching
/// `features/invite_composer/presentation/widgets/invite_composer_sheet.dart`.
Future<void> shareBeforeYouGoText(String text) async {
  await SharePlus.instance.share(ShareParams(text: text));
}

typedef BeforeYouGoPackLoader = Future<BeforeYouGoPack> Function();
typedef BeforeYouGoShare = Future<void> Function(String text);

@immutable
class BeforeYouGoState {
  const BeforeYouGoState({this.phase, this.hints = const <ChecklistHint>[]});

  /// `null` until the first resolve settles.
  final BeforeYouGoPhase? phase;

  final List<ChecklistHint> hints;

  /// AC-1/AC-2/AC-3 plus AC-14: the block exists only on a card whose date is
  /// today *and* that has at least one row to show. An empty resolve hides the
  /// whole thing, title included — an empty frame reads as a load error.
  bool get isVisible => (phase?.isActive ?? false) && hints.isNotEmpty;

  bool get isDismissed => phase?.isDismissed ?? false;

  @override
  bool operator ==(Object other) =>
      other is BeforeYouGoState &&
      other.phase == phase &&
      listEquals(other.hints, hints);

  @override
  int get hashCode => Object.hash(phase, Object.hashAll(hints));
}

/// Owns the "trước giờ đi" phase for one card: whether the block applies today,
/// which rows hold, and the close/reopen cycle.
///
/// The card's own lifecycle is not this cubit's business — closing the block
/// never touches `ActivityCard.status` (BR-8) and this class holds no reference
/// to the `activity_cards` cubit. [today] is injected rather than read from a
/// clock here, so the same inputs always give the same rows (AC-10).
class BeforeYouGoCubit extends Cubit<BeforeYouGoState> {
  BeforeYouGoCubit({
    required ActivityCard card,
    required this.today,
    BeforeYouGoDismissalStore? store,
    BeforeYouGoPack? pack,
    BeforeYouGoPackLoader? loadPack,
    BeforeYouGoShare? share,
  })  : _store = store ?? BeforeYouGoDismissalStore(),
        _loadPack = loadPack ?? loadBeforeYouGoPack,
        _share = share ?? shareBeforeYouGoText,
        super(const BeforeYouGoState()) {
    _card = card;
    _pack = pack;
  }

  final DateTime today;
  final BeforeYouGoDismissalStore _store;
  final BeforeYouGoPackLoader _loadPack;
  final BeforeYouGoShare _share;

  late ActivityCard _card;
  BeforeYouGoPack? _pack;
  String? _dismissedOnIso;

  /// Resolves the current phase. The pack and the dismissal key are only
  /// touched once the card is genuinely a today card, so an ordinary detail
  /// screen costs neither an asset read nor a `SharedPreferences` round trip.
  Future<void> load() async {
    if (!BeforeYouGoPhase.fromCard(_card, today: today).isActive) {
      _dismissedOnIso = null;
      _emit();
      return;
    }

    _pack ??= await _loadPack();
    _dismissedOnIso = await _store.dismissedOn(_card.id);
    if (!isClosed) {
      _emit();
    }
  }

  /// The detail screen rebuilds this block after every field edit, so a price
  /// or place typed in on the day changes the rows without leaving the screen.
  Future<void> updateCard(ActivityCard card) async {
    _card = card;
    await load();
  }

  /// AC-17: closes immediately. The state moves first and the key is written
  /// after, so the tap has no dialog, no confirmation, and no wait in it.
  Future<void> dismiss() async {
    final String dateIso = civilDateIso(today);
    _dismissedOnIso = dateIso;
    _emit();
    await _store.dismiss(_card.id, dateIso);
  }

  /// AC-16: back to the full block for the same day (SC-5, no dead end).
  Future<void> reopen() async {
    _dismissedOnIso = null;
    _emit();
    await _store.reopen(_card.id);
  }

  /// AC-18: one tap, one sheet. Nothing is written before or after — no
  /// recipient, no timestamp, no "đã chia sẻ" row anywhere (AC-19/AC-20).
  Future<void> shareLocation() => _share(_shareText());

  String _shareText() {
    final String? location = _card.location;
    return location == null ? _card.title : '${_card.title} · $location';
  }

  void _emit() {
    final BeforeYouGoPhase phase = BeforeYouGoPhase.fromCard(
      _card,
      today: today,
      dismissedOnIso: _dismissedOnIso,
    );
    final BeforeYouGoPack? pack = _pack;
    emit(
      BeforeYouGoState(
        phase: phase,
        hints: !phase.isActive || pack == null
            ? const <ChecklistHint>[]
            : resolveHints(
                hints: pack.hints,
                facts: BeforeYouGoFacts.fromCard(
                  _card,
                  today: today,
                  regions: pack.regions,
                ),
              ),
      ),
    );
  }
}
