import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/cupid_api_failure.dart';
import '../data/love_contract.dart';
import '../data/love_contract_repository.dart';
import 'love_contract_event.dart';
import 'love_contract_state.dart';

/// Backend clause bounds (`CreateContractDto`'s `ArrayMinSize(1)`/
/// `ArrayMaxSize(20)`), enforced client-side per `../ux/uiux-spec.md` §4.
const _maxClauseCount = 20;

/// UX §4's preset/suggested clause catalog (`hint-placeholder-count="4"`).
/// Mobile-owned content, not an ARB key set — l10n integration for this
/// feature's chrome copy is P2's scope, not this phase's.
const _presetClauses = <LoveContractClause>[
  LoveContractClause(id: 'preset-honesty', text: 'Always tell the truth'),
  LoveContractClause(id: 'preset-cooldown', text: "Don't sleep angry"),
  LoveContractClause(id: 'preset-check-in', text: 'Check in once a day'),
  LoveContractClause(
    id: 'preset-apology',
    text: 'Say sorry first, argue about it later',
  ),
];

/// `architecture/solution.md` ADR-006a: the ceremony ritual as a full
/// `Bloc`, not a `Cubit` (confirms D2) — the hold lifecycle and clause
/// rules are an ordered, guarded event sequence, not a plain-method
/// surface. Re-entrancy is guarded by the `inFlight` flag on
/// `LoveContractReady` plus a start-acknowledgement flag, instead of a
/// `bloc_concurrency` transformer (no new pub dependency).
class LoveContractBloc extends Bloc<LoveContractEvent, LoveContractState> {
  LoveContractBloc({required this._repository, required this._partnerDisplayName})
    : super(const LoveContractLoading()) {
    on<LoveContractOpened>((event, emit) => _load(emit));
    on<ContractRetryRequested>((event, emit) => _load(emit));
    on<ClauseToggled>(_onClauseToggled);
    on<CustomClauseAdded>(_onCustomClauseAdded);
    on<SignHoldStarted>(_onSignHoldStarted);
    on<SignHoldCancelled>(_onSignHoldCancelled);
    on<SignHoldCompleted>(_onSignHoldCompleted);
  }

  final LoveContractRepository _repository;
  final String? Function() _partnerDisplayName;

  int _customClauseSequence = 0;

  /// Set by a legal `SignHoldStarted` (at least one clause selected, not
  /// already in flight) and consumed by the next `SignHoldCompleted`.
  /// Guards the "complete a hold that was never started" illegal
  /// transition named in ADR-006a.
  bool _holdAcknowledged = false;

  Future<void> _load(Emitter<LoveContractState> emit) async {
    emit(const LoveContractLoading());
    final partnerDisplayName = _partnerDisplayName();
    try {
      final contract = await _repository.fetchCurrent();
      if (contract == null) {
        emit(
          LoveContractReady(
            presetClauses: _presetClauses,
            customClauses: const [],
            selectedClauseIds: const {},
            signStatus: ContractSignStatus.unsigned,
            viewerRole: ContractViewerRole.requester,
            partnerDisplayName: partnerDisplayName,
            inFlight: false,
          ),
        );
        return;
      }
      emit(_readyFromContract(contract, partnerDisplayName));
    } on CupidApiFailure catch (failure) {
      emit(LoveContractLoadFailed(failure));
    }
  }

  LoveContractReady _readyFromContract(
    LoveContract contract,
    String? partnerDisplayName,
  ) {
    final selectedClauseIds = <String>{};
    final customClauses = <LoveContractClause>[];
    for (final text in contract.clauses) {
      final preset = _matchingPreset(text);
      if (preset != null) {
        selectedClauseIds.add(preset.id);
        continue;
      }
      final custom = _nextCustomClause(text);
      customClauses.add(custom);
      selectedClauseIds.add(custom.id);
    }
    return LoveContractReady(
      presetClauses: _presetClauses,
      customClauses: customClauses,
      selectedClauseIds: selectedClauseIds,
      signStatus: contract.status,
      viewerRole: contract.viewerRole,
      partnerDisplayName: partnerDisplayName,
      inFlight: false,
    );
  }

  LoveContractClause? _matchingPreset(String text) {
    for (final preset in _presetClauses) {
      if (preset.text == text) return preset;
    }
    return null;
  }

  LoveContractClause _nextCustomClause(String text) {
    _customClauseSequence += 1;
    return LoveContractClause(id: 'custom-$_customClauseSequence', text: text);
  }

  void _onClauseToggled(ClauseToggled event, Emitter<LoveContractState> emit) {
    final state = this.state;
    if (state is! LoveContractReady || !state.canEditClauses) return;
    final selectedClauseIds = Set<String>.from(state.selectedClauseIds);
    if (selectedClauseIds.contains(event.clauseId)) {
      selectedClauseIds.remove(event.clauseId);
    } else {
      if (selectedClauseIds.length >= _maxClauseCount) return;
      selectedClauseIds.add(event.clauseId);
    }
    emit(state.copyWith(selectedClauseIds: selectedClauseIds));
  }

  void _onCustomClauseAdded(
    CustomClauseAdded event,
    Emitter<LoveContractState> emit,
  ) {
    final state = this.state;
    if (state is! LoveContractReady || !state.canEditClauses) return;
    final trimmed = event.text.trim();
    if (trimmed.isEmpty) return;
    if (state.selectedClauseIds.length >= _maxClauseCount) return;
    final clause = _nextCustomClause(trimmed);
    emit(
      state.copyWith(
        customClauses: [...state.customClauses, clause],
        selectedClauseIds: {...state.selectedClauseIds, clause.id},
      ),
    );
  }

  void _onSignHoldStarted(
    SignHoldStarted event,
    Emitter<LoveContractState> emit,
  ) {
    final state = this.state;
    _holdAcknowledged = state is LoveContractReady && state.canSign;
  }

  void _onSignHoldCancelled(
    SignHoldCancelled event,
    Emitter<LoveContractState> emit,
  ) {
    _holdAcknowledged = false;
  }

  Future<void> _onSignHoldCompleted(
    SignHoldCompleted event,
    Emitter<LoveContractState> emit,
  ) async {
    final state = this.state;
    if (!_holdAcknowledged || state is! LoveContractReady || !state.canSign) {
      return;
    }
    _holdAcknowledged = false;
    emit(state.copyWith(inFlight: true, clearActionFailure: true));
    try {
      // ADR-019e: the partner never writes clauses — saveClauses() upserts
      // by requesterId, so a partner-side call would create a second,
      // split-state contract row (solution.md §1). Only the requester path
      // saves; both paths always sign.
      if (state.viewerRole == ContractViewerRole.requester) {
        final selectedTexts = state.allClauses
            .where((clause) => state.selectedClauseIds.contains(clause.id))
            .map((clause) => clause.text)
            .toList(growable: false);
        await _repository.saveClauses(selectedTexts);
      }
      final signed = await _repository.sign();
      final latest = this.state;
      if (latest is! LoveContractReady) return;
      emit(
        latest.copyWith(
          signStatus: signed.status,
          viewerRole: signed.viewerRole,
          inFlight: false,
        ),
      );
    } on CupidApiFailure catch (failure) {
      final latest = this.state;
      if (latest is! LoveContractReady) return;
      emit(latest.copyWith(inFlight: false, actionFailure: failure));
    }
  }
}
