import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/account_repository.dart';
import '../domain/cupid_profile.dart';

/// `me` hub state (`coding-plan/master-plan.md` §6.2 P2, `ux/uiux-spec.md`
/// §1/§3).
sealed class AccountState {
  const AccountState();
}

class AccountLoading extends AccountState {
  const AccountLoading();
}

class AccountLoaded extends AccountState {
  const AccountLoaded(this.profile);

  final CupidProfile profile;
}

/// [failure] is a `CupidApiFailure` — map it with a screen-local helper
/// before showing it, mirroring `RegisterFailed`/`authFailureMessage`.
class AccountFailed extends AccountState {
  const AccountFailed(this.failure);

  final Object failure;
}

class AccountCubit extends Cubit<AccountState> {
  AccountCubit({required this._repository, this._resolveProfile})
    : super(const AccountLoading()) {
    load();
  }

  final AccountRepository _repository;

  /// Preview-only override of `GET /users/me`, mirroring
  /// `HomeScreen.resolveProfile`. Production callers leave it null.
  final Future<CupidProfile> Function()? _resolveProfile;

  Future<void> load() async {
    emit(const AccountLoading());
    try {
      final CupidProfile profile = await (_resolveProfile == null
          ? _repository.fetchProfile()
          : _resolveProfile());
      if (!isClosed) emit(AccountLoaded(profile));
    } catch (failure) {
      if (!isClosed) emit(AccountFailed(failure));
    }
  }

  /// Applies a profile the caller already has in hand (the profile-edit
  /// screen's successful PATCH response) without an extra `GET /users/me`
  /// round trip.
  void applyUpdated(CupidProfile profile) {
    if (!isClosed) emit(AccountLoaded(profile));
  }
}
