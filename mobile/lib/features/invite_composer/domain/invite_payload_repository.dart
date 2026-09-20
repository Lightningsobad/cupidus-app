import 'invite_payload.dart';

/// Storage for exported invites (`architecture/contract-summary.md` §4).
///
/// The read surface is exactly two point lookups. There is no `countForCard`,
/// no `allPayloads`, and no aggregate, ranking, or comparison query, because
/// R-1e/AC-14 forbid any surface that scores invites against each other — and a
/// count API is precisely the thing a "you sent 5 invites" surface gets built
/// on later. Adding one here is a contract change, not a convenience.
abstract interface class InvitePayloadRepository {
  /// Records one export. Called once per share tap, with no idempotency key:
  /// two taps are two items, and since nothing counts them the duplicate is
  /// unobservable.
  ///
  /// [filledValues] is the mad-libs *input*; passing the rendered sentence in
  /// it violates AC-17. [userEditedText] is the AC-7 manual override, `null`
  /// when the user accepted the rendered draft.
  Future<InvitePayload> savePayload({
    required String cardId,
    required String categoryId,
    required String presetId,
    required String packVersion,
    required Map<String, String> filledValues,
    String? userEditedText,
  });

  /// The most recent export for one card, or `null` if the card has none.
  /// Singular by design: "the last thing I sent", never a history list.
  Future<InvitePayload?> latestForCard(String cardId);

  Future<InvitePayload?> payloadById(String id);
}
