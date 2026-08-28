import 'package:cupid_api/cupid_api.dart'
    show UpdateProfileDto, UpdateProfileDtoCoupleTypeEnum;
import 'package:dio/dio.dart';

import '../../../core/network/cupid_api.dart';
import '../domain/cupid_profile.dart';

/// `coding-plan/master-plan.md` §6.2 P1 `AccountRepository` contract. Reads
/// `GET /users/me` directly off the shared `Dio`, following
/// `AuthRepository._syncBackendProfile`
/// (`mobile/lib/features/auth/data/auth_repository.dart:99-112`): the
/// generated `usersControllerGetProfile` also declares no response schema
/// (`Future<Response<void>>`), so calling it would lose the body's fields at
/// the type level. Writes go through the generated
/// `Epic1UsersApi.usersControllerUpdateProfile`, whose `UpdateProfileDto`
/// already omits unset fields (`includeIfNull: false`), then this
/// re-reads so the returned `CupidProfile` reflects the server's
/// post-write state.
///
/// `UpdateProfileDto` is imported directly from `package:cupid_api` because
/// `core/network/cupid_api.dart` (out of this phase's write scope) does not
/// re-export generated request DTOs, only `CupidApi` itself; the shared
/// `Dio`/interceptor pipeline is still reached exclusively through the
/// injected [CupidApi].
class AccountRepository {
  AccountRepository({required this._api});

  final CupidApi _api;

  Future<CupidProfile> fetchProfile() async {
    try {
      final response = await _api.dio.get<Object?>('/users/me');
      return CupidProfile.fromJson(response.data! as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error ?? const UnexpectedFailure();
    }
  }

  /// Sends only the fields the caller passes; every parameter left `null`
  /// stays absent from the PATCH body. Callers are responsible for sending
  /// `birthday` and `zodiacSign` together or not at all
  /// (`coding-plan/master-plan.md` §6.2 P2) — this method applies no such
  /// coupling itself.
  Future<CupidProfile> updateProfile({
    String? displayName,
    DateTime? birthday,
    String? zodiacSign,
    DateTime? relationshipStartDate,
    String? language,
    String? photoUrl,
    UpdateProfileDtoCoupleTypeEnum? coupleType,
    bool? isGhostModeEnabled,
  }) async {
    final dto = UpdateProfileDto(
      displayName: displayName,
      birthday: birthday == null ? null : _dateOnly(birthday),
      zodiacSign: zodiacSign,
      relationshipStartDate: relationshipStartDate == null
          ? null
          : _dateOnly(relationshipStartDate),
      language: language,
      photoUrl: photoUrl,
      coupleType: coupleType,
      isGhostModeEnabled: isGhostModeEnabled,
    );

    try {
      await _api
          .getEpic1UsersApi()
          .usersControllerUpdateProfile(updateProfileDto: dto);
    } on DioException catch (e) {
      throw e.error ?? const UnexpectedFailure();
    }

    return fetchProfile();
  }

  Future<CupidProfile> markVowTaken() async {
    try {
      await _api.dio.post<Object?>('/users/vow');
    } on DioException catch (e) {
      throw e.error ?? const UnexpectedFailure();
    }
    return fetchProfile();
  }

  String _dateOnly(DateTime date) => date.toIso8601String().split('T').first;
}
