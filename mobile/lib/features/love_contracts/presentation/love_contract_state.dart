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

/// The ceremony's steady state. [viewerRole] and [canEditClauses] gate the
/// partner to a sign-only path (ADR-019e); the widget layer must not offer
/// clause affordances when `!canEditClauses`.
class LoveContractReady extends LoveContractState {
  const LoveContractReady({
    required this.presetClauses,
    required this.customClauses,
    required this.selectedClauseIds,
    required this.signStatus,
    required this.viewerRole,
    required this.partnerDisplayName,
    required this.inFlight,
    this.actionFailure,
  });

  final List<LoveContractClause> presetClauses;
  final List<LoveContractClause> customClauses;
  final Set<String> selectedClauseIds;
  final ContractSignStatus signStatus;
  final ContractViewerRole viewerRole;
  final String? partnerDisplayName;
  final bool inFlight;
  final CupidApiFailure? actionFailure;

  List<LoveContractClause> get allClauses => [
    ...presetClauses,
    ...customClauses,
  ];

  int get selectedCount => selectedClauseIds.length;

  /// ADR-019e: the requester can edit clauses, the partner is sign-only.
  bool get canEditClauses => viewerRole == ContractViewerRole.requester;

  /// UX §4/§5: at least one clause selected, no save+sign call already in
  /// flight, and the viewer has not already signed their own side.
  bool get canSign =>
      selectedCount > 0 &&
      !inFlight &&
      (signStatus == ContractSignStatus.unsigned ||
          signStatus == ContractSignStatus.partnerAlreadySigned);

  LoveContractReady copyWith({
    List<LoveContractClause>? presetClauses,
    List<LoveContractClause>? customClauses,
    Set<String>? selectedClauseIds,
    ContractSignStatus? signStatus,
    ContractViewerRole? viewerRole,
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
      viewerRole: viewerRole ?? this.viewerRole,
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
        other.viewerRole == viewerRole &&
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
    viewerRole,
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
