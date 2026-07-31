/// `architecture/solution.md` ADR-006a — the ceremony ritual's ordered event
/// sequence. The hold gesture is expressed as three discrete lifecycle
/// events (`SignHoldStarted` -> `SignHoldCompleted` | `SignHoldCancelled`)
/// instead of a per-frame progress value, per ADR-006a's rule that hold
/// progress stays out of the `Bloc`.
sealed class LoveContractEvent {
  const LoveContractEvent();
}

/// Fired when the ceremony screen first mounts. Triggers `fetchCurrent()`.
class LoveContractOpened extends LoveContractEvent {
  const LoveContractOpened();
}

/// Fired from the inline retry action after a `LoveContractLoadFailed`.
class ContractRetryRequested extends LoveContractEvent {
  const ContractRetryRequested();
}

/// Toggles one clause (preset or custom) on/off by its stable [clauseId].
/// A pure state update — it never calls the network.
class ClauseToggled extends LoveContractEvent {
  const ClauseToggled(this.clauseId);

  final String clauseId;
}

/// Appends a new custom clause. [text] is trimmed and validated by the
/// `Bloc`: empty/whitespace-only text is rejected, as is a 21st selected
/// clause (`CreateContractDto`'s `ArrayMaxSize(20)`).
class CustomClauseAdded extends LoveContractEvent {
  const CustomClauseAdded(this.text);

  final String text;
}

/// The hold gesture started. Legal only when at least one clause is
/// selected and no save+sign call is already in flight (UX §4/§5) — an
/// illegal start is never acknowledged, so a later `SignHoldCompleted` with
/// no legal `SignHoldStarted` before it is a no-op (ADR-006a: "complete a
/// hold that was never started").
class SignHoldStarted extends LoveContractEvent {
  const SignHoldStarted();
}

/// The hold was released early. Clears any pending sign intent with no
/// network call and no partial state.
class SignHoldCancelled extends LoveContractEvent {
  const SignHoldCancelled();
}

/// The hold dwell completed. Saves the selected clauses, then signs, in
/// that order — the backend upsert resets an already-signed row back to
/// `created`, so clauses must be saved before signing (ADR-006c).
class SignHoldCompleted extends LoveContractEvent {
  const SignHoldCompleted();
}
