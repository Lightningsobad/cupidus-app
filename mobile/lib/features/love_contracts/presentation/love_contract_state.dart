import 'package:flutter/foundation.dart' show listEquals, setEquals;

import '../../../core/network/cupid_api_failure.dart';
import '../data/love_contract.dart';

/// One clause row shown on the ceremony screen — preset or custom-added.
/// [text] doubles as the exact string sent to the backend's
/// `clauses: string[]` payload; a stable [id] lets the presentation layer
/// toggle a row by identity instead of by list index (`ClauseToggled`).
class LoveContractClause {
  const LoveContractClause({required this.id, required this.text});

  final String id;
  final String text;

  @override
  bool operator ==(Object other) =>
      other is LoveContractClause && other.id == id && other.text == text;

  @override
  int get hashCode => Object.hash(id, text);
}

/// `architecture/solution.md` ADR-006a — sealed, hand-written `==`/
/// `hashCode` states (no `freezed`, no `equatable`), matching the style of
/// `features/auth/presentation/sign_out_cubit.dart`'s `SignOutState`.
sealed class LoveContractState {
  const LoveContractState();
}

class LoveContractLoading extends LoveContractState {
  const LoveContractLoading();

  @override
  bool operator ==(Object other) =>
      other.runtimeType == LoveContractLoading;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// The ceremony's steady state. Never exposes a partner-side signing
/// affordance (ADR-006c) — there is intentionally no such field here.
class LoveContractReady extends LoveContractState {
  const LoveContractReady({
    required this.presetClauses,
    required this.customClauses,
    required this.selectedClauseIds,
    required this.signStatus,
    required this.partnerDisplayName,
    required this.inFlight,
    this.actionFailure,
  });

  final List<LoveContractClause> presetClauses;
  final List<LoveContractClause> customClauses;
  final Set<String> selectedClauseIds;
  final ContractSignStatus signStatus;
  final String? partnerDisplayName;
  final bool inFlight;
  final CupidApiFailure? actionFailure;

  List<LoveContractClause> get allClauses => [
    ...presetClauses,
    ...customClauses,
  ];

  int get selectedCount => selectedClauseIds.length;

  /// UX §4/§5: at least one clause selected, and no save+sign call already
  /// in flight.
  bool get canSign => selectedCount > 0 && !inFlight;

  LoveContractReady copyWith({
    List<LoveContractClause>? presetClauses,
    List<LoveContractClause>? customClauses,
    Set<String>? selectedClauseIds,
    ContractSignStatus? signStatus,
    String? partnerDisplayName,
    bool? inFlight,
    CupidApiFailure? actionFailure,
    bool clearActionFailure = false,
  }) {
    return LoveContractReady(
      presetClauses: presetClauses ?? this.presetClauses,
      customClauses: customClauses ?? this.customClauses,
      selectedClauseIds: selectedClauseIds ?? this.selectedClauseIds,
      signStatus: signStatus ?? this.signStatus,
      partnerDisplayName: partnerDisplayName ?? this.partnerDisplayName,
      inFlight: inFlight ?? this.inFlight,
      actionFailure: clearActionFailure
          ? null
          : (actionFailure ?? this.actionFailure),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LoveContractReady &&
        listEquals(other.presetClauses, presetClauses) &&
        listEquals(other.customClauses, customClauses) &&
        setEquals(other.selectedClauseIds, selectedClauseIds) &&
        other.signStatus == signStatus &&
        other.partnerDisplayName == partnerDisplayName &&
        other.inFlight == inFlight &&
        other.actionFailure == actionFailure;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(presetClauses),
    Object.hashAll(customClauses),
    Object.hashAllUnordered(selectedClauseIds),
    signStatus,
    partnerDisplayName,
    inFlight,
    actionFailure,
  );
}

class LoveContractLoadFailed extends LoveContractState {
  const LoveContractLoadFailed(this.failure);

  final CupidApiFailure failure;

  @override
  bool operator ==(Object other) =>
      other is LoveContractLoadFailed && other.failure == failure;

  @override
  int get hashCode => failure.hashCode;
}
