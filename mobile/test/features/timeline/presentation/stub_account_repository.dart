import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/account/data/account_repository.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:dio/dio.dart';

/// An [AccountRepository] that answers `fetchProfile()` from memory, so
/// timeline widget tests can pin the countdown's `relationshipStartDate`
/// anchor. Matches the `_StubTimelineCubit` pattern in these files: the
/// injected [CupidApi] is real but never reached, so no `Dio` timeout timer
/// is created and a plain `tester.pump()` stays sufficient.
class StubAccountRepository extends AccountRepository {
  StubAccountRepository({this.relationshipStartDate})
    : super(api: CupidApi(dio: Dio(), interceptors: const []));

  final DateTime? relationshipStartDate;

  @override
  Future<CupidProfile> fetchProfile() async {
    return CupidProfile(
      id: 'user-1',
      email: 'alex@example.com',
      language: 'vi',
      vowTaken: false,
      isGhostModeEnabled: true,
      relationshipStartDate: relationshipStartDate,
    );
  }
}
