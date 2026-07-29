/// The only public REST surface (`architecture/solution.md` §2, §4).
/// Feature code must import this file, must not import
/// `package:cupid_api/...` directly, and must not construct `Dio` itself.
library;

export 'package:cupid_api/cupid_api.dart' show CupidApi;

export '../config/cupid_api_config.dart';
export 'cupid_api_client.dart';
export 'cupid_api_failure.dart';
export 'cupid_auth_token_provider.dart';
export 'cupid_interceptor_slots.dart';
